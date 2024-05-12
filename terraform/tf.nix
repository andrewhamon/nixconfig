{ config, lib, pkgs, inputs, ... }: let
  proxmoxImage = inputs.nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ../hosts/defaults/configuration.nix
      {
        services.qemuGuest.enable = true;

        # Enable serial terminal in proxmox
        boot.kernelParams = [
          "console=ttyS0,115200"
          "console=tty1"
        ];
      }
    ];
    format = "qcow-efi";
  };

  proxmoLxcImage = inputs.nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ../hosts/defaults/configuration.nix
    ];
    format = "proxmox-lxc";
  };
in {
  terraform.required_providers.proxmox = {
    source = "bpg/proxmox";
    version = "0.54.0";
  };

  provider = {
    proxmox = {
      # API token set in flake.nix wrapper
      endpoint = "https://10.69.13.2:8006/";
      insecure = true;
      tmp_dir  = "/var/tmp";
      ssh = {
        agent = true;
        username = "root";
      };
    };
  };

  resource.proxmox_virtual_environment_file = {
    nixos_base = {
      content_type = "iso";
      node_name = "elodin";
      datastore_id = "local";
      source_file = {
        path = "${proxmoxImage}/nixos.qcow2";
        file_name = "nixos_base_2.img";
      };
      overwrite = true;
    };

    nixos_base_lxc = {
      content_type = "vztmpl";
      node_name = "elodin";
      datastore_id = "local";
      source_file = {
        path = "${proxmoLxcImage}/tarball/nixos-system-x86_64-linux.tar.xz";
        file_name = "nixos_base_lxc.tar.xz";
      };
      overwrite = true;
    };
  };

  resource.proxmox_virtual_environment_vm.nixos_vm = {
    name = "nixos.local";
    node_name = "elodin";
    vm_id = 100;

    disk = {
      datastore_id = "local-zfs";
      file_id = "local:iso/nixos_base_2.img";
      interface    = "scsi0";
      size = 208;
    };

    memory = {
      dedicated = 4096;
    };

    agent.enabled = true;

    network_device = {
      bridge = "vmbr0";
    };

    serial_device = {};

    cpu = {
      cores = 4;
      type = "host";
    };

    bios = "ovmf";
    machine = "q35";
    operating_system = {
      type = "l26";
    };

    efi_disk = {
      datastore_id = "local-zfs";
      type = "4m";
      file_format = "raw";
    };

    tpm_state = {
      datastore_id = "local-zfs";
      version = "v2.0";
    };
  

    depends_on = [
      "proxmox_virtual_environment_file.nixos_base"
    ];
  };

  resource.proxmox_virtual_environment_vm.nixos_vm_2 = {
    name = "nixos.local3";
    node_name = "elodin";
    vm_id = 101;

    disk = {
      datastore_id = "local-zfs";
      file_id = "local:iso/nixos_base_2.img";
      interface    = "scsi0";
      size = 208;
    };

    memory = {
      dedicated = 4096;
    };

    agent.enabled = true;

    network_device = {
      bridge = "vmbr0";
    };

    serial_device = {};

    cpu = {
      cores = 4;
      type = "host";
    };

    bios = "ovmf";
    machine = "q35";
    operating_system = {
      type = "l26";
    };

    efi_disk = {
      datastore_id = "local-zfs";
      type = "4m";
      file_format = "raw";
    };

    tpm_state = {
      datastore_id = "local-zfs";
      version = "v2.0";
    };
  

    depends_on = [
      "proxmox_virtual_environment_file.nixos_base"
    ];
  };
}
