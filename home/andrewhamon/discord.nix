{ pkgs, root, ... }: {
  home.packages = [
    root.packages.clyde
  ];

  programs.zsh = {
    initExtra = ''
      . "$HOME/.cargo/env"
      #compdef clyde
      _clyde() {
        eval $(env COMMANDLINE="''${words[1,''$CURRENT]}" _CLYDE_COMPLETE=complete-zsh  clyde)
      }
      if [[ "$(basename -- ''${(%):-%x})" != "_clyde" ]]; then
        compdef _clyde clyde
      fi

      source ${./ssh/fixup-ssh-auth-sock.sh}
    '';
  };

  home.sessionVariables = {
    CODER_SSH_CONFIG_FILE = "~/nixconfig/home/andrewhamon/ssh/discord-config";
  };

  home.shellAliases = {
    discord = "cd ~/discord/discord";
  };

  programs.ssh.includes = [
    "/Users/andyhamon/nixconfig/home/andrewhamon/ssh/discord-config"
    "/Users/andrewhamon/nixconfig/home/andrewhamon/ssh/discord-config"
  ];
}
