{pkgs, pkgsUnstable, inputs, ...}: {
    imports = [
        ./home.nix
        ./cursor.nix
    ];

    home.packages = with pkgs; [
        inputs.roc.packages."${pkgs.system}".cli

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
        wl-clipboard
        wlr-randr
        wpaperd
        xorg.xev
        xorg.xeyes
        yambar
    ];
}