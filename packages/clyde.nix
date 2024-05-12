{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "clyde";
  text = ''
    ~/discord/discord/clyde "$@"
  '';
}
