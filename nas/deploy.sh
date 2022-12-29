#!/usr/bin/env bash
set -eufx -o pipefail
scp -r ./nixos/ root@nas.lan.adh.io:/etc/
ssh root@nas.lan.adh.io nixos-rebuild ${1:-switch}
