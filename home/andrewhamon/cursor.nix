{ pkgs, ... }:
{
  home.pointerCursor.package = pkgs.apple-cursor;
  home.pointerCursor.name = "macOS";
  home.pointerCursor.x11.enable = true;
  home.pointerCursor.gtk.enable = true;
}
