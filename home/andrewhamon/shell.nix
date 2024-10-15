{ ... }:
{
  programs.atuin.enable = true;
  programs.atuin.settings = {
    enter_accept = false;
  };
  
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    autosuggestion.enable = true;
    enableCompletion = true;
    autocd = false;
    syntaxHighlighting.enable = true;
    initExtra = ''
      # Keep nix in the PATH even after macos upgrades which overwrite files in /etc
      [[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]] && source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    '';
  };

  programs.wezterm.enable = true;
  programs.wezterm.extraConfig = ''
    ${builtins.readFile ./wezterm.lua}
  '';

  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.oh-my-zsh.theme = "robbyrussell";
}
