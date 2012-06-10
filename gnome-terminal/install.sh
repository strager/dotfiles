#!/bin/sh

gterm_out="$OUT/.gconf/apps/gnome-terminal"
outfile="$gterm_out/profiles/strager/%gconf.xml"

if [ ! -e "$outfile" ]; then
    echo "Be sure to add the 'strager' profile to $gterm_out/global/%gconf.xml" >&2
fi

"$S" "$HEREP/%gconf.xml" "$outfile"
