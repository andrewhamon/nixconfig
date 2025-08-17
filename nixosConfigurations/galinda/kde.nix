{ ... }:
{
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  xdg.portal.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
}
