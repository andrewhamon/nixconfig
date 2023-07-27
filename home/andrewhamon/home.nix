{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ./nvim.nix
    ./cursor.nix
  ];

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    btlejack
    firefox
    waybar
    font-awesome
    pulseaudioFull
    bluez
    pulsemixer
    brightnessctl
    cargo
    delve
    direnv
    flyctl
    go
    fd
    go-tools
    gopls
    nixpkgs-fmt
    nmap
    nodejs
    postgresql_11
    redis
    ripgrep
    ruby
    tmate
    tree
    wget
    yubikey-manager
    ((dwl.override { conf = ./dwl_config.h; }).overrideAttrs (final: prev: {
      src = pkgs.fetchFromGitHub {
        owner = "djpohly";
        repo = "dwl";
        rev = "68a17f962e05895603d0f409fb8da4493cbe52aa";
        hash = "sha256-MnEylBPuqZuZgRybMQt8OfnFMEVzUuntOQJrWlDr5p8=";
      };
    }))
    ((somebar.override { conf = null; }).overrideAttrs (final: prev: {
      patches = [
        "${prev.src}/contrib/hide-vacant-tags.patch"
      ];
    }))
    waylock
    mpv
    git
    xorg.xeyes
    xorg.xev
    wlr-randr
    vscodium
    _1password-gui
    librewolf
    captive-browser
    bemenu
    yambar
  ];

  home.sessionPath = [
    "/opt/homebrew/bin"
  ];

  home.sessionVariables = {
    FLEXPORT_EMAIL = "andrew.hamon@flexport.com";
    MPR_SKIP_BUNDLE = "1";
    BUILDKITE_API_TOKEN = "$(cat ~/.config/secrets/buildkite_api_key)";
    BUILDKITE_TOKEN = "$(cat ~/.config/secrets/buildkite_api_key)";
    GITHUB_TOKEN = "$(cat ~/.config/secrets/github_token)";
    JUPYTER_TOKEN = "$(cat ~/.config/secrets/jupyter_token)";
    DIRENV_LOG_FORMAT = "";
  };

  home.shellAliases = {
    gs = "git status";
    nix-system-configuration = "code ~/.config/nix";
    idea = "open -na \"IntelliJ IDEA.app\"";
    bastion = "/Users/andrewhamon/flexport/flexport/env-improvement/bin/bastion";
    mpr = "./mpr --branch-prefix=ah";
    snowflake = "/Applications/SnowSQL.app/Contents/MacOS/snowsql --accountname FLEXPORT --username \"ANDREW.HAMON@FLEXPORT.COM\" --rolename ENGINEERING_ROLE --warehouse REPORTING_WH --authenticator externalbrowser";
    nixconfig = "cd ~/nixconfig";
    nixpkgs = "cd ~/nixpkgs";
    flexport = "cd ~/flexport/flexport; code .";
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableSyntaxHighlighting = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = false;
  };

  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.oh-my-zsh.theme = "robbyrussell";

  programs.fzf.enable = true;

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

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = false;

  programs.ssh = import ./ssh;

  programs.alacritty = {
    enable = true;
  };

  home.stateVersion = "22.05";
}
