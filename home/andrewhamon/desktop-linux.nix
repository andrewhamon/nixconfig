{ pkgs, pkgsUnstable, inputs, ... }:
let
  volctl = import ../../packages/volctl/default.nix { inherit pkgs; };
in
{
  imports = [
    ./home.nix
    ./desktop.nix
    ./cursor.nix
  ];

  home.packages = with pkgs; [
    inputs.roc.packages."${pkgs.system}".cli

    pkgsUnstable.bambu-studio
    pkgsUnstable.waybar

    _1password-gui
    bemenu
    bluez
    brightnessctl
    captive-browser
    discord
    element-desktop
    firefox
    fprintd
    jellyfin-mpv-shim
    libsecret
    mpv
    playerctl
    prusa-slicer
    pulseaudioFull
    pulsemixer
    slack
    swaybg
    swayidle
    swaylock
    virt-manager
    volctl
    winbox
    wl-clipboard
    wlr-randr
    wpaperd
    xorg.xev
    xorg.xeyes
    yambar
  ];
}
