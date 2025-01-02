{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" "mlx5_core" "mlx5_ib" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "tmpfs";
      fsType = "tmpfs";
    };

  fileSystems."/iso" =
    { device = "/dev/disk/by-uuid/1980-01-01-00-00-00-00";
      fsType = "iso9660";
    };

  fileSystems."/nix/.ro-store" =
    { device = "/iso/nix-store.squashfs";
      fsType = "squashfs";
      options = [ "loop" ];
    };

  fileSystems."/nix/.rw-store" =
    { device = "tmpfs";
      fsType = "tmpfs";
    };

  fileSystems."/nix/store" =
    { device = "overlay";
      fsType = "overlay";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp38s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp39s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp42s0f3u5u3c2.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp45s0f0np0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp45s0f1np1.useDHCP = lib.mkDefault true;
  # networking.interfaces.tailscale0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}