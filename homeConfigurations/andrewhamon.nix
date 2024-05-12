{ root, ...}:
root.lib.mkHomeConfiguration {
  username = "andrewhamon";
  modules = [
    ../home/andrewhamon/desktop-linux.nix
  ];
  extraSpecialArgs = {
    isDiscord = false;
  };
}