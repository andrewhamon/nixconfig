# override winbox to use wine-wayland, and also wrap it in a script which unsets DISPLAY if running
# on wayland
{ pkgs, ... }:
let
  winbox = pkgs.winbox.override {
    wine = pkgs.wine64Packages.waylandFull;
  };
in
pkgs.writeShellApplication {
  name = "winbox";
  runtimeInputs = [ winbox ];
  text = ''
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      unset DISPLAY
    fi

    winbox "$@"
  '';
}
