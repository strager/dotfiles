#!/bin/sh

mkdir -p "$OUT/.config/sapling"
"$S" "$HEREP/sapling.conf" "$OUT/.config/sapling/sapling.conf"
"$S" "$HEREP/sapling.conf" "$OUT/Library/Preferences/sapling/sapling.conf"
