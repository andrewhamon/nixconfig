{...}:
let
  rpoolName = "rpool";
  rootDevice = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_24065S801786";
in
{
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = rootDevice;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = rpoolName;
              };
            };
          };
        };
      };
    };

    zpool = {
      "${rpoolName}" = {
        type = "zpool";

        options = {
          # root pool, so there is no FS to hold the cachefile anyway
          cachefile = "none";
          ashift = "12";
          autotrim = "on";
          failmode = "continue";
        };

        rootFsOptions = {
          dedup = "off";
          acltype = "posix";
          dnodesize = "auto";
          xattr = "sa";
          atime = "on";
          relatime = "on";
          compression = "lz4";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          normalization="formD";
          utf8only="on";
        };

        postCreateHook = ''
          zfs list -t snapshot -H -o name | grep -E '^${rpoolName}@blank$' || zfs snapshot ${rpoolName}@blank
        '';

        datasets = {
          "local" = {
            type = "zfs_fs";
            mountpoint = null;
          };

          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
          };

          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };

          "safe" = {
            type = "zfs_fs";
            mountpoint = null;
          };

          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
          };

          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
          };
        };
      };
    };
  };
}
