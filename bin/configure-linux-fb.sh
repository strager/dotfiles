#!/bin/sh
set -e
set -u

# Stop blinking the cursor.
echo 0 | sudo tee /sys/class/graphics/fbcon/cursor_blink

# Make pressing capslock trigger ESC.
printf 'keymaps 0-127\nkeycode 58 = Escape\n' | sudo loadkeys -
