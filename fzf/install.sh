#!/bin/sh

# NOTE(strager): fzf itself does not use the FZF_DEFAULT_COMMAND file. My zshrc
# uses it.
"$S" "$HEREP/FZF_DEFAULT_COMMAND" "$OUT/.config/fzf/FZF_DEFAULT_COMMAND"
