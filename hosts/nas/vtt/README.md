# Virtual Table Top Runbook

## How it works

There are two components:

- a systemd unit. When it launches, two things happen:
  - latest changes from [stevenpetryk/vtt-private](https://github.com/stevenpetryk/vtt-private)
    are fetched
  - the vtt node server is launched

- an nginx virtual host. Currently this is set up with `vtt.adh.io`. To change
  it, first add `CNAME` record pointed at `router.adh.io`. Then make a pull
  request.

The service is wrapped in a NixOS module, with arguments passed in from
[hosts/nas/configuration.nix](../configuration.nix) (see the `services.vtt.*`
options).

## Accessing the server
Users with keys setup under `services.vtt.serviceUserAuthorizedKeys` in
[configuration.nix](../configuration.nix) can log in as `vtt` using the
following:

```bash
ssh vtt@vtt.adh.io -p 2222
```

The home directory for `vtt` is `/var/lib/vtt`, which is also the data directory
that the vtt service is configured for.

## Adding a new user

Make a pull request! Or you can add some keys to `~/.ssh/authorized_keys`.

## Updating the vtt code
On every launch, the `vtt` service pulls the latest changes, so to refresh you
can run the following:

```bash
sudo systemctl restart vtt
```

The vtt source code is located at `/var/lib/vtt/src`. If needed, you can also
manually manage the git repo there. You should be able to `git pull` with no
additional setup.

## Managing the service

The `vtt` user is granted sudo permissions to run the following commands:

```bash
sudo systemctl start vtt
sudo systemctl stop vtt
sudo systemctl restart vtt
```

## Viewing logs

The `vtt` user should be able to view logs without sudo by running:

```bash
journalctl --unit vtt
```

For a nice colorized output of recent logs, try this:

```bash
journalctl --unit vtt --lines 100 --follow | ccze -o nolookups
```

## Installing new software
Search for packages [here](https://search.nixos.org/packages) and install them
with `nix-env`. For example:

```bash
nix-env -iA nixos.cowsay
```
