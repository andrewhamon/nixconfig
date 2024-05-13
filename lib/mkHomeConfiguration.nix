{ pkgs, inputs, root, ... }:
{ username, modules, extraSpecialArgs }:
let
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = extraSpecialArgs // {
    inherit inputs root;
  };
  modules = modules ++ [
    {
      home.homeDirectory = homeDirectory;
      home.username = username;
    }
  ];
}
