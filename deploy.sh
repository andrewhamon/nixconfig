#!/usr/bin/env bash
set -eufx -o pipefail
scp configuration.nix root@router.adh.io:/etc/nixos/configuration.nix
ssh root@router.adh.io nixos-rebuild ${1:-switch}
