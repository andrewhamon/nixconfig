{ pkgs, firefox }:
pkgs.writeShellApplication {
  name = "xdg-firefox-wrapper";

  text = ''
    unset LD_PRELOAD
    unset LD_LIBRARY_PATH
    exec ${firefox}/bin/firefox "$@"
  '';
}
