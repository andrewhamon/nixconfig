{ config, pkgs, inputs, lib, ... }:
{
  imports = [];

  home.packages = [
    pkgs.yubikey-manager
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
    "/opt/homebrew/bin"
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    FLEXPORT_EMAIL = "andrew.hamon@flexport.com";
    MPR_SKIP_BUNDLE = "1";
    BUILDKITE_API_TOKEN = "$(cat ~/.config/secrets/buildkite_api_key)";
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
    nixconfig = "cd ~/code/nixconfig; code .";
    nixpkgs = "cd ~/code/nixpkgs; code .";
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

  programs.vim.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = false;

  programs.ssh = import ./ssh;

  programs.alacritty = {
    enable = true;
  };
}
