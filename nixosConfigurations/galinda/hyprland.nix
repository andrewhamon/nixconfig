{ ... }:
{
  security.pam.services.swaylock = { };
  security.pam.services.waylock = { };
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
}