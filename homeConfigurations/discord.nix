{ root, ...}:
root.lib.mkHomeConfiguration {
  username = "discord";
  modules = [
    ../home/andrewhamon/home.nix
    ../home/andrewhamon/discord.nix
  ];
  extraSpecialArgs = {
    isDiscord = true;
  };
}