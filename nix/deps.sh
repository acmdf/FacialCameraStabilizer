#! /usr/bin/env sh
set -euxo pipefail
nix build ..#facialcamerastabilizer.fetch-deps
./result ./deps.json
rm ./result