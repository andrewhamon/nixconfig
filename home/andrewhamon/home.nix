{ config, pkgs, inputs, lib, homeDirectory, username, isDiscord, ... }:
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
    vscode
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
    clear = ''
      printf "\e[H\e[22J"
    '';
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = false;
    syntaxHighlighting.enable = true;
    initExtra = ''
      # Keep nix in the PATH even after macos upgrades which overwrite files in /etc
      [[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]] && source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    '';
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
