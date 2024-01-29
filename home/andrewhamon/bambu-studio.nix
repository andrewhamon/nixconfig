{ pkgs }:
pkgs.appimageTools.wrapType2 {
  # or wrapType1
  name = "bambu-studio";
  src = fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v01.07.04.52/Bambu_Studio_linux_ubuntu-v01.07.04.52.AppImage";
    hash = "sha256-1qTitCeZ6xmWbqYTXp8sDrmVgTNjPZNW0hzUPW++mq4=";
  };
  extraPkgs = pkgs: with pkgs; [
    webkitgtk
  ];
}
