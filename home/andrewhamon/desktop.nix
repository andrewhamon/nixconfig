{ config, pkgs, lib, ... }: {
  imports = [
    ./secrets.nix
  ];

  programs.ssh = import ./ssh { inherit config pkgs; };

  programs.kitty = {
    enable = true;
    extraConfig = ''
      map alt+left send_text all \x1b\x62
      map alt+right send_text all \x1b\x66
    '' + lib.optionalString pkgs.stdenv.isLinux ''
      map ctrl+v paste_from_clipboard
      map ctrl+c copy_or_interrupt
    '';
  };
}
