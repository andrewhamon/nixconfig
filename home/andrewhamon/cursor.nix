{ pkgs, ... }:
{
  home.pointerCursor = if pkgs.stdenv.isLinux then {} else {};
}
