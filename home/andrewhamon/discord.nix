{ pkgs, ... }: {
  home.packages = [
    (import ./clyde.nix { inherit pkgs; })
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
    '';
  };

  home.shellAliases = {
    discord = "cd ~/discord/discord";
  };
}
