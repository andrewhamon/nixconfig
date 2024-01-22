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
    discord
    swaybg
    swayidle
    wl-clipboard
    playerctl
    volctl
    slack
    jellyfin-mpv-shim
    element-desktop
    virt-manager
    prusa-slicer
    btlejack
    firefox
    pkgsUnstable.waybar
    font-awesome
    pulseaudioFull
    bluez
    pulsemixer
    brightnessctl
    cargo
    delve
    direnv
    fd
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
    swaylock
    mpv
    git
    xorg.xeyes
    xorg.xev
    wlr-randr
    pkgsUnstable.vscode
    _1password-gui
    librewolf
    captive-browser
    bemenu
    yambar
    libsecret
    xdg-utils
    wpaperd
    pkgsUnstable.flyctl
    wireguard-tools
    fprintd
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
    ARTIFACTORY_TOKEN = "$(cat ~/.config/secrets/artifactory_token)";
    DIRENV_LOG_FORMAT = "";
    # BROWSER = "${xdg-firefox-wrapper}/bin/xdg-firefox-wrapper";
  };

  home.shellAliases = {
    gs = "git status";
    idea = "open -na \"IntelliJ IDEA.app\"";
    bastion = "~/flexport/flexport/env-improvement/bin/bastion";
    mpr = "./mpr --branch-prefix=ah";
    snowflake = "/Applications/SnowSQL.app/Contents/MacOS/snowsql --accountname FLEXPORT --username \"ANDREW.HAMON@FLEXPORT.COM\" --rolename ENGINEERING_ROLE --warehouse REPORTING_WH --authenticator externalbrowser";
    nixconfig = "cd ~/nixconfig";
    nixpkgs = "cd ~/nixpkgs";
    flexport = "cd ~/flexport/flexport";
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
