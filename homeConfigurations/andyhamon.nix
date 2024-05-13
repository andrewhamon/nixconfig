{ root, ... }:
root.lib.mkHomeConfiguration {
  username = "andyhamon";
  modules = [
    ../home/andrewhamon/desktop-darwin.nix
    ../home/andrewhamon/discord.nix
  ];
  extraSpecialArgs = {
    isDiscord = true;
  };
}
