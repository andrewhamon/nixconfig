{
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";

  inputs.nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

  inputs.darwin.url = "github:lnl7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/release-23.11";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nil.url = "github:oxalica/nil";

  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  inputs.authfish.url = "github:andrewhamon/authfish";
  inputs.authfish.inputs.nixpkgs.follows = "nixpkgs";
  inputs.authfish.inputs.flake-utils.follows = "flake-utils";

  inputs.nvidia-patch.url = "github:arcnmx/nvidia-patch.nix";
  inputs.nvidia-patch.inputs.nixpkgs.follows = "nixpkgs";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.deploy-rs.inputs.utils.follows = "flake-utils";

  inputs.hyprland.url = "github:hyprwm/Hyprland";
  # inputs.hyprland.inputs.nixpkgs = "nixpkgs";

  inputs.roc.url = "github:roc-lang/roc";

  inputs.homeage.url = "github:jordanisaacs/homeage";
  inputs.homeage.inputs.nixpkgs.follows = "nixpkgs";

  inputs.terranix.url = "github:terranix/terranix";
  inputs.terranix.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    { self
    , darwin
    , deploy-rs
    , flake-utils
    , home-manager
    , nixos-generators
    , nixpkgs
    , terranix
    , ...
    }@inputs:
    let
      mkPkgsUnstable = system: import inputs.nixpkgs-unstable {
        config.allowUnfree = true;
        system = system;
      };
      mkPkgs = system: import inputs.nixpkgs {
        config.allowUnfree = true;
        system = system;
      };

      mkNixos = { system ? "x86_64-linux", modules }: inputs.nixpkgs.lib.nixosSystem {
        inherit system modules;
        pkgs = mkPkgs system;
        specialArgs = { inherit inputs; pkgsUnstable = mkPkgsUnstable system; };
      };

      mkNixosDeploy = hostname:
        let
          nixos = self.nixosConfigurations.${hostname};
          system = nixos.pkgs.system;
          activate = inputs.deploy-rs.lib.${system}.activate.nixos nixos;
        in
        {
          hostname = "${hostname}.platypus-banana.ts.net";
          user = "root";
          sshUser = "root";
          profiles.system.path = activate;
        };

    in
    {
      nixosConfigurations."router" = mkNixos {
        modules = [
          ./hosts/defaults/configuration.nix
          ./hosts/router/configuration.nix
        ];
      };

      nixosConfigurations."nas" = mkNixos {
        modules = [
          ./hosts/defaults/configuration.nix
          ./hosts/nas/configuration.nix
        ];
      };

      nixosConfigurations."vader" = mkNixos {
        modules = [
          ./hosts/vader/configuration.nix
        ];
      };

      nixosConfigurations."thumper" = mkNixos {
        modules = [
          ./hosts/thumper/configuration.nix
        ];
      };



      deploy.nodes.router = mkNixosDeploy "router";
      deploy.nodes.nas = mkNixosDeploy "nas";
      deploy.nodes.vader = mkNixosDeploy "vader";
      deploy.nodes.thumper = mkNixosDeploy "thumper";

      installIso = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/defaults/configuration.nix
        ];
        format = "install-iso";
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    } // flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = mkPkgs system;
        agenixPkg = inputs.agenix.packages.${pkgs.system}.agenix;
        # Wrap agenix to point it at the yubikey identity
        agenix = pkgs.writeShellApplication {
          name = "agenix";
          runtimeInputs = with pkgs; [ rage age-plugin-yubikey ];
          text = ''
            yubikey_identities="$(mktemp)"
            age-plugin-yubikey --identity > "$yubikey_identities"
            "${agenixPkg}/bin/agenix" -i "$yubikey_identities" "$@"
            rm "$yubikey_identities"
          '';
        };
        pkgsUnstable = mkPkgsUnstable system;
        tfJson = terranix.lib.terranixConfiguration {
          inherit system;
          modules = [ ./tf.nix ];
          extraArgs = { inherit inputs; };
        };
      in
      {
        devShells.default = import ./shell.nix { inherit pkgs inputs; };
        apps.deploy = {
          type = "app";
          program = "${deploy-rs.defaultPackage.${system}}/bin/deploy";
        };
        apps.home-manager = {
          type = "app";
          program = "${pkgs.home-manager}/bin/home-manager";
        };

        apps.tf-plan = let 
          program = pkgs.writers.writeBash "tf-plan" ''
            export PROXMOX_VE_API_TOKEN="$(${agenix}/bin/agenix -d secrets/proxmox_api_token.age)"
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${tfJson} config.tf.json \
              && ${pkgs.opentofu}/bin/tofu init \
              && ${pkgs.opentofu}/bin/tofu plan -out tf_plan
          '';
        in {
          type = "app";
          program = "${program}";
        };

        apps.tf-apply = let 
          program = pkgs.writers.writeBash "tf-plan" ''
            export PROXMOX_VE_API_TOKEN="$(${agenix}/bin/agenix -d secrets/proxmox_api_token.age)"
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${tfJson} config.tf.json \
              && ${pkgs.opentofu}/bin/tofu init \
              && ${pkgs.opentofu}/bin/tofu plan -out tf_plan \
              && ${pkgs.opentofu}/bin/tofu apply tf_plan
          '';
        in {
          type = "app";
          program = "${program}";
        };

        # Super mega hack - `nix flake show` complains if packages.<system>.homeConfigurations
        # is not a derivation. So appease it by merging in pkgs.hello.
        packages.homeConfigurations = pkgs.hello // {
          andrewhamon = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit inputs pkgsUnstable;
              isDiscord = false;
              username = "andrewhamon";
              homeDirectory = "/home/andrewhamon";
            };
            modules = [
              ./home/andrewhamon/desktop-linux.nix
            ];
          };
          andyhamon =
            let
              # Mega-hack: force aarch64-darwin even when running nix with rosetta
              systemOverride = if system == "x86_64-darwin" then "aarch64-darwin" else system;
            in
            home-manager.lib.homeManagerConfiguration {
              pkgs = mkPkgs systemOverride;
              extraSpecialArgs = {
                inherit inputs;
                isDiscord = true;
                pkgsUnstable = mkPkgsUnstable systemOverride;
                username = "andyhamon";
                homeDirectory = "/Users/andyhamon";
              };
              modules = [
                ./home/andrewhamon/desktop-darwin.nix
                ./home/andrewhamon/discord.nix
              ];
            };
          discord =
            let
              # Mega-hack: force aarch64-darwin even when running nix with rosetta
              systemOverride = if system == "x86_64-darwin" then "aarch64-darwin" else system;
            in
            home-manager.lib.homeManagerConfiguration {
              pkgs = mkPkgs systemOverride;
              extraSpecialArgs = {
                inherit inputs;
                isDiscord = true;
                pkgsUnstable = mkPkgsUnstable systemOverride;
                username = "discord";
                homeDirectory = "/home/discord";
              };
              modules = [
                ./home/andrewhamon/home.nix
                ./home/andrewhamon/discord.nix
              ];
            };
        };
      }
      );
}
