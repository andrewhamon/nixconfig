{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ./home.nix
    ./desktop.nix
  ];

  home.packages = with pkgs; [
    lima
    colima
    docker
  ];

  programs.zsh = {
    initExtra = ''
      export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };
}
