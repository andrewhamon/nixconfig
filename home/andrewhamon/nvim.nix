{ config, pkgs, inputs, lib, ... }:
{
  imports = [ ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      nvim-treesitter
      neo-tree-nvim
      nvim-lspconfig
      coq_nvim
      coq-artifacts
      coq-thirdparty
    ];
    extraLuaConfig = builtins.readFile ./config.lua;
  };
}
