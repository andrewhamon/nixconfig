{ config, pkgs, pkgsUnstable, inputs, lib, ... }:
let
  bambu-studio = import ./bambu-studio.nix { inherit pkgs; };
  firefox = pkgs.firefox;
  xdg-firefox-wrapper = import ./xdg-firefox-wrapper.nix { inherit pkgs firefox; };
  volctl = import ../../packages/volctl/default.nix { inherit pkgs; };
in
{
  imports = [
    ./nvim.nix
    ./cursor.nix
  ];

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    inputs.nil.packages."${pkgs.system}".default
    inputs.roc.packages."${pkgs.system}".cli

    pkgsUnstable.flyctl
    pkgsUnstable.vscode
    pkgsUnstable.waybar
  
    _1password-gui
    bemenu
    bluez
    brightnessctl
    btlejack
    captive-browser
    cargo
    delve
    direnv
    discord
    element-desktop
    fd
    firefox
    font-awesome
    fprintd
    git
    jellyfin-mpv-shim
    librewolf
    libsecret
    mpv
    nixpkgs-fmt
    nmap
    nodejs
    playerctl
    postgresql_11
    prusa-slicer
    pulseaudioFull
    pulsemixer
    redis
    ripgrep
    ruby
    slack
    swaybg
    swayidle
    swaylock
    tmate
    tree
    virt-manager
    volctl
    wget
    wireguard-tools
    wl-clipboard
    wlr-randr
    wpaperd
    xdg-utils
    xorg.xev
    xorg.xeyes
    yambar
    yubikey-manager
  ];

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

  programs.kitty = {
    enable = true;
    extraConfig = ''
      map ctrl+v paste_from_clipboard
      map ctrl+c copy_or_interrupt
    '';
  };

  home.stateVersion = "22.05";
}
