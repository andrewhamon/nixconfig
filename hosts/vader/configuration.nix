{ config, pkgs, inputs, pkgsUnstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../defaults/configuration.nix
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.andrewhamon = import ../../home/andrewhamon/home.nix;
  home-manager.extraSpecialArgs = { inherit inputs pkgsUnstable; };

  hardware.bluetooth.enable = true;

  services.fwupd.enable = true;

  programs.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "vader"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    enable = false;
    layout = "us";
    xkbVariant = "";
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  hardware.opengl.enable = true;
  fonts.enableDefaultFonts = true;
  programs.dconf.enable = true;
  programs.xwayland.enable = true;
  # For screen sharing (this option only has an effect with xdg.portal.enable):
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  xdg.portal.enable = true;
  
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [];
  security.pam.services.waylock = {};

  services.upower.enable = true;

  nixpkgs.overlays = with pkgs; [
    (self: super: {
      mpv-unwrapped = super.mpv-unwrapped.override {
        ffmpeg_5 = ffmpeg_5-full;
      };
    })
  ];

  system.stateVersion = "23.05"; # Did you read the comment?
}
