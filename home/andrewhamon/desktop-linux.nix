{ pkgs, inputs, ... }:
let
  volctl = import ../../packages/volctl/default.nix { inherit pkgs; };
in
{
  imports = [
    ./home.nix
    ./desktop.nix
    ./cursor.nix
    ./hyprland.nix
  ];

  home.packages = with pkgs; [
    inputs.roc.packages."${pkgs.stdenv.hostPlatform.system}".cli

    _1password-gui
    bemenu
    bluez
    brightnessctl
    captive-browser
    chromium
    discord
    element-desktop
    firefox
    fprintd
    jellyfin-mpv-shim
    kapow
    libsecret
    localsend
    mpv
    playerctl
    prusa-slicer
    pulseaudioFull
    pulsemixer
    slack
    spotify
    swaybg
    swayidle
    swaylock
    swaynotificationcenter
    virt-manager
    volctl
    wl-clipboard
    wlr-randr
    wpaperd
    xorg.xev
    xorg.xeyes
    yambar
  ];
}
