#!/bin/sh

set -e
set -u

set -x
nix-env --delete-generations 14d
nix-store --gc
nix-store --optimise
