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
      scrollback_lines 1000000
      term xterm-256color
      confirm_os_window_close 0
    '' + lib.optionalString pkgs.stdenv.isLinux ''
      map ctrl+v paste_from_clipboard
      map ctrl+c copy_or_interrupt
    '';
  };
}
