#!/bin/sh

if [ -d "$OUT/Library/LaunchAgents" ]; then
  "$S" "$HEREP/local.strager.back-up.plist" "$OUT/Library/LaunchAgents/local.strager.back-up.plist"
fi
