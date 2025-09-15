{ config, pkgs, inputs, lib, isDiscord, ... }:
{
  imports = [
    ./nvim.nix
    ./shell.nix
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    inputs.nil.packages."${pkgs.system}".default
    gh
    gh-dash
    direnv
    bun
    fd
    font-awesome
    git
    home-manager
    hyperfine
    mpv
    ncdu
    nixpkgs-fmt
    nmap
    (pkgs.lib.lowPrio nodejs)
    #raycast
    ripgrep
    ruby
    tmate
    tree
    # vscode
    wireguard-tools
    xdg-utils
    yubikey-manager
    libnotify
    age-plugin-yubikey
    gleam
  ] ++ (lib.optionals (!isDiscord) [
    # Since Discord also uses nix, there are some conflicts in my nix env
    redis
    wget
  ]);

  home.sessionPath = [
    "/opt/homebrew/bin"
  ];

  home.sessionVariables = {
    # GITHUB_TOKEN = "$(cat ~/.config/secrets/github_token)";
    DIRENV_LOG_FORMAT = "";
    NIXOS_OZONE_WL = "1";
  };

  home.shellAliases = {
    gs = "git status";
    nixconfig = "cd ~/nixconfig";
    nixpkgs = "cd ~/nixpkgs";
    gch = "git checkout $(git branch --all | fzf| tr -d '[:space:]')";
    clear = ''
      printf "\e[H\e[22J"
    '';
    wip = "git commit -m WIP -n";
    gfm = "git fetch origin main:main";
  };


  programs.ssh.enable = true;
  programs.ssh.package = pkgs.openssh;

  programs.git = {
    enable = true;

    delta = {
      enable = true;
      options = {
        navigate = true;
      };
    };

    extraConfig = (import ./git.nix);

    includes = [
      (import ./git-work.nix)
    ];
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = false;

  home.stateVersion = "22.05";
}
