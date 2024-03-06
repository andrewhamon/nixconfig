{ config, pkgs, inputs, lib, homeDirectory, username, pkgsUnstable, isDiscord, ... }:
let
  bambu-studio = import ./bambu-studio.nix { inherit pkgs; };
  firefox = pkgs.firefox;
  xdg-firefox-wrapper = import ./xdg-firefox-wrapper.nix { inherit pkgs firefox; };
  volctl = import ../../packages/volctl/default.nix { inherit pkgs; };
in
{
  imports = [
    ./nvim.nix
  ];

  fonts.fontconfig.enable = true;

  home.homeDirectory = homeDirectory;
  home.username = username;

  home.packages = with pkgs; [
    inputs.nil.packages."${pkgs.system}".default

    pkgsUnstable.flyctl
    pkgsUnstable.vscode

    direnv
    fd
    font-awesome
    git
    home-manager
    mpv
    ncdu
    nixpkgs-fmt
    nmap
    nodejs
    ripgrep
    ruby
    tmate
    tree
    wireguard-tools
    xdg-utils
    yubikey-manager
  ] ++ (lib.optionals (!isDiscord) [
    # Since Discord also uses nix, there are some conflicts in my nix env
    redis
    wget
  ]);

  home.sessionPath = [
    "/opt/homebrew/bin"
  ];

  home.sessionVariables = {
    GITHUB_TOKEN = "$(cat ~/.config/secrets/github_token)";
    DIRENV_LOG_FORMAT = "";
  };

  home.shellAliases = {
    gs = "git status";
    nixconfig = "cd ~/nixconfig";
    nixpkgs = "cd ~/nixpkgs";
    gch = "git checkout $(git branch --all | fzf| tr -d '[:space:]')";
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = false;
    syntaxHighlighting.enable = true;
  };

  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.oh-my-zsh.theme = "robbyrussell";

  programs.fzf.enable = true;

  programs.ssh.enable = true;
  programs.ssh.package = pkgs.openssh;

  programs.git = {
    enable = true;

    delta = {
      enable = true;
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
