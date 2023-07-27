{ config, pkgs, inputs, lib, ... }:
{
  imports = [];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      nvim-treesitter
    ];
    extraLuaConfig = builtins.readFile ./config.lua;
  };
}
