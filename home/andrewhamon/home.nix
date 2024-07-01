{ config, pkgs, inputs, lib, isDiscord, ... }:
{
  imports = [
    ./nvim.nix
  ];

  fonts.fontconfig.enable = true;

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
    libnotify
    age-plugin-yubikey
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
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    autosuggestion.enable = true;
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
