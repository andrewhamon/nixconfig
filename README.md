## Deploying nix-darwin

```sh
darwin-rebuild switch --flake .
```

## Bootstrap home-manager

```sh
nix run .#home-manager -- switch --flake .
```

## Deploying nixos

Currently NixOS hosts are deployed using [deploy-rs](https://github.com/serokell/deploy-rs).


### Check if config builds

```sh
nix flake check
```

### Dry run activation

```sh
nix run .#deploy -- --dry-activate
```


### Apply config to all hosts

```sh
nix run .#deploy
```

## Secrets

Secrets are managed and deployed to nixos hosts with [agenix](https://github.com/ryantm/agenix).

For macOS hosts, run `activate-macos-secrets` inside a nix shell.

### Edit a secret

```
agenix -e secrets/your_secret.age
```

### Installing via disko
Quick documentation of what I did last time. Need to try out https://github.com/nix-community/nixos-anywhere/
to make this simpler.

```
ssh -A nixos@<installer ip>
git clone git@github.com:andrewhamon/nixconfig.git
sudo nixos-generate-config --no-filesystems --show-hardware-config
# update config accordingly
sudo nix run .#disko-install -- --flake .#<nixosConfigName> --disk root /dev/disk/by-id/<target-disk>
```
