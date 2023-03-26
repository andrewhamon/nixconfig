{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.homeage.homeManagerModules.homeage
  ];

  homeage = {
    identityPaths = [ "~/.ssh/id_ed25519" ];
    installationType = "activation";
    mount = "/Users/andrewhamon/.config/secrets";

    file.buildkite_api_key = {
      # Path to encrypted file tracked by the git repository
      source = ../../secrets/buildkite_api_key.age;
    };

    file.jupyter_token = {
      # Path to encrypted file tracked by the git repository
      source = ../../secrets/jupyter_token.age;
    };
  };

  home.packages = [
    pkgs.cargo
    pkgs.direnv
    pkgs.flyctl
    pkgs.nixpkgs-fmt
    pkgs.nmap
    pkgs.postgresql_11
    pkgs.redis
    pkgs.ripgrep
    pkgs.ruby
    pkgs.tree
    pkgs.wget
  ];

  home.sessionPath = [
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    FLEXPORT_EMAIL = "andrew.hamon@flexport.com";
    MPR_SKIP_BUNDLE = "1";
    BUILDKITE_API_TOKEN = "$(cat ${config.homeage.file.buildkite_api_key.path})";
    JUPYTER_TOKEN = "$(cat ${config.homeage.file.jupyter_token.path})";
    DIRENV_LOG_FORMAT = "";
  };

  home.shellAliases = {
    gs = "git status";
    nix-system-configuration = "code ~/.config/nix";
    idea = "open -na \"IntelliJ IDEA.app\"";
    bastion = "/Users/andrewhamon/flexport/flexport/env-improvement/bin/bastion";
    mpr = "./mpr --branch-prefix=ah";
    snowflake = "/Applications/SnowSQL.app/Contents/MacOS/snowsql --accountname FLEXPORT --username \"ANDREW.HAMON@FLEXPORT.COM\" --rolename ENGINEERING_ROLE --warehouse REPORTING_WH --authenticator externalbrowser";
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableSyntaxHighlighting = false;
    enableAutosuggestions = false;
    enableCompletion = false;
    autocd = false;
  };

  programs.git = {
    enable = true;

    delta = {
      enable = true;
    };

    extraConfig = (import ./git.nix);

    includes = [
      (import ./git-flexport.nix)
    ];
  };

  programs.vim.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = false;

  programs.alacritty = {
    enable = true;
  };
}
