{ config, pkgs, ... }: {
  imports = [
    ./secrets.nix
  ];

  programs.ssh = import ./ssh { inherit config pkgs; };

  programs.kitty = {
    enable = true;
    extraConfig = ''
      map ctrl+v paste_from_clipboard
      map ctrl+c copy_or_interrupt
    '';
  };
}
