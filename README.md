## Deploying nix-darwin

```sh
darwin-rebuild switch --flake .
```

## Bootstram home-manager

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
