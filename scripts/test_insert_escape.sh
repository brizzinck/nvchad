#!/usr/bin/env bash
# Native Neovim only: no real config/plugin bootstrap, desktop tools or user files.
set -euo pipefail
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRATCH=$(mktemp -d /tmp/nvim-insert-layout.XXXXXX)
trap 'rm -rf "$SCRATCH"' EXIT
mkdir -p "$SCRATCH"/{home,config,data,cache,state,runtime,fake}
for tool in bw rbw fzf-menu ghostty notify-send hyprctl wl-copy; do
  cat >"$SCRATCH/fake/$tool" <<'STUB'
#!/bin/sh
printf 'blocked\n' >> "$NVIM_TEST_TOOL_LOG"
exit 97
STUB
  chmod 700 "$SCRATCH/fake/$tool"
done
env -i PATH="$SCRATCH/fake:/usr/bin:/bin" HOME="$SCRATCH/home" LANG=C.UTF-8 \
  XDG_CONFIG_HOME="$SCRATCH/config" XDG_DATA_HOME="$SCRATCH/data" XDG_CACHE_HOME="$SCRATCH/cache" \
  XDG_STATE_HOME="$SCRATCH/state" XDG_RUNTIME_DIR="$SCRATCH/runtime" NVIM_TEST_TOOL_LOG="$SCRATCH/blocked-tools" \
  /usr/bin/timeout 10 /usr/bin/nvim --headless --noplugin -u NONE -i NONE -n -l "$HERE/test_insert_escape.lua"
test ! -e "$SCRATCH/blocked-tools"
