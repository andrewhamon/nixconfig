#!/usr/bin/env bash
set -eufx -o pipefail
scp -r ./nixos/ root@router.adh.io:/etc/
ssh root@router.adh.io nixos-rebuild ${1:-switch}
