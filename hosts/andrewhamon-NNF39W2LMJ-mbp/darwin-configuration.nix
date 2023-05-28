{ config, pkgs, inputs, ... }:
let
  postgresPkg = pkgs.postgresql_11;
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  homebrew = import ./homebrew.nix;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.andrewhamon = import ./home.nix;
  home-manager.extraSpecialArgs = { inherit inputs; };

  users.users.andrewhamon = {
    name = "andrewhamon";
    home = "/Users/andrewhamon";
  };

  environment.shells = [ pkgs.zsh pkgs.bash ];
  environment.systemPackages = with pkgs; [
    git
    openssh
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix.buildMachines = [{
    hostName = "nas.lan.adh.io";
    systems = [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
    ];
    sshUser = "remotebuilder";
    sshKey = "/Users/andrewhamon/.config/secrets/nix_remote_builder_id_ed25519";
    maxJobs = 16;
  }];

  nix.distributedBuilds = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  nix.settings.substituters = [
    "https://artifactory.flexport.io/artifactory/nix-binary-cache-dev/?trusted=1&priority=50"
  ];

  programs.zsh = {
    enable = true;  
    promptInit = "";
    enableCompletion = false;
    enableBashCompletion = false;
  };

  programs.bash = {
    enable = true;
  };

  environment.systemPath = [
    "/Users/andrewhamon/.nix-profile/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/usr/sbin"
    "/bin"
    "/sbin"
  ];

  environment.etc."sudoers.d/000-sudo-touchid" = {
    text = ''
      Defaults pam_service=sudo-touchid
      Defaults pam_login_service=sudo-touchid
    '';
  };
  environment.etc."pam.d/sudo-touchid" = {
    text = ''
      auth       sufficient     pam_tid.so
      auth       sufficient     pam_smartcard.so
      auth       required       pam_opendirectory.so
      account    required       pam_permit.so
      password   required       pam_deny.so
      session    required       pam_permit.so
    '';
  };

  system.defaults.dock.autohide = true;
  system.defaults.dock.tilesize = 8;
  system.defaults.dock.launchanim = false;
  system.defaults.finder.AppleShowAllFiles = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
