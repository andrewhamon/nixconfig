{ root, ... }:
{
  programs.winbox = {
    package = root.packages.winbox;
    enable = true;
    openFirewall = true;
  };
}
