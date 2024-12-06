{pkgs, modulesPath, ...}:
{
  imports = [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];
}
