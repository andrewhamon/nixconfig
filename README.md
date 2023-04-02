## Deploying nix-darwin

```sh
darwin-rebuild switch --flake .
```

## Deploying nixos

Currently NixOS hosts are deployed using [Colmena](https://github.com/zhaofengli/colmena).


### Check if config builds

```sh
colmena build
```

### Dry run activation

```sh
colmena apply -v dry-activate
```


### Apply config to all hosts

```sh
colmena apply
```

### Test config on all hosts (reboot to restore previous)

```sh
colmena apply test
```

## Secrets

Secrets are managed and deployed to nixos hosts with [agenix](https://github.com/ryantm/agenix).

For macOS hosts, run `script/activate-macos-secrets`
