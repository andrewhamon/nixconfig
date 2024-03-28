{ config, lib, pkgs, inputs, ... }: let
  proxmoxImage = inputs.nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./hosts/defaults/configuration.nix
      {
        services.qemuGuest.enable = true;

        # Enable serial terminal in proxmox
        boot.kernelParams = [
          "console=ttyS0,115200"
          "console=tty1"
        ];
      }
    ];
    format = "qcow";
  };

  proxmoLxcImage = inputs.nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./hosts/defaults/configuration.nix
    ];
    format = "proxmox-lxc";
  };
in {
  terraform.required_providers.proxmox = {
    source = "bpg/proxmox";
    version = "0.49.0";
  };

  provider = {
    proxmox = {
      endpoint = "https://10.69.42.10:8006/";
      api_token = "root@pam!terraform=4cbd54b6-7525-4324-aadf-0138da4e5f8e";
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
      node_name = "pve";
      datastore_id = "local";
      source_file = {
        path = "${proxmoxImage}/nixos.qcow2";
        file_name = "nixos_base.img";
      };
      overwrite = true;
    };

    nixos_base_lxc = {
      content_type = "vztmpl";
      node_name = "pve";
      datastore_id = "local";
      source_file = {
        path = "${proxmoLxcImage}/tarball/nixos-system-x86_64-linux.tar.xz";
        file_name = "nixos_base_lxc.tar.xz";
      };
      overwrite = true;
    };
  };

  resource.proxmox_virtual_environment_vm.nixos_vm = {
    name = "nixos.local2";
    node_name = "pve";
    vm_id = 100;

    disk = {
      datastore_id = "local-zfs";
      file_id = "local:iso/nixos_base.img";
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

    depends_on = [
      "proxmox_virtual_environment_file.nixos_base"
    ];
  };
}
