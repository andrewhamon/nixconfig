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
      # check if the exact nix version of ssh-agent is running, if not, start it
      # this is a workaround for the issue that the wrong ssh-agent started by
      # the system on darwin
      if ! pgrep -f -u $USER ${pkgs.openssh}/bin/ssh-agent > /dev/null; then
        ${pkgs.openssh}/bin/ssh-agent | sed -e "/^echo/d" > ''${HOME}/.ssh/agent-env
        source ''${HOME}/.ssh/agent-env

        if [ -f ${config.homeage.file.desk_yubikey_ssh_key.path} ]; then
          ssh-add ${config.homeage.file.desk_yubikey_ssh_key.path}
        fi

        if [ -f ${config.homeage.file.keychain_yubikey_ssh_key.path} ]; then
          ssh-add ${config.homeage.file.keychain_yubikey_ssh_key.path}
        fi

        if [ -f ${config.homeage.file.discord_desk_yubikey_ssh_key.path} ]; then
          ssh-add ${config.homeage.file.discord_desk_yubikey_ssh_key.path}
        fi
      else
        source ''${HOME}/.ssh/agent-env
      fi
    '';
  };
}
