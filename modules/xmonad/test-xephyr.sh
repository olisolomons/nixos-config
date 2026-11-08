#!/usr/bin/env bash
set -e

nix build

DEV_XDG="$(pwd)/.dev-xdg"
CONFIG_DIR="$DEV_XDG/config/xmonad"
CACHE_DIR="$DEV_XDG/cache/xmonad"

mkdir -p "$CONFIG_DIR" "$CACHE_DIR"

ln -sfn "$(pwd)/xmonad.hs" "$CONFIG_DIR/xmonad.hs"
cp ./result/bin/xmonad-x86_64-linux "$CACHE_DIR/xmonad-x86_64-linux"
chmod +x "$CACHE_DIR/xmonad-x86_64-linux"

# Start Xephyr
Xephyr :1 -screen 1280x720 -ac -br +extension RANDR &
XEPHYR_PID=$!
sleep 1

# Launch XMonad
DISPLAY=:1 \
  XDG_CONFIG_HOME="$DEV_XDG/config" \
  XDG_CACHE_HOME="$DEV_XDG/cache" \
  "$CACHE_DIR/xmonad-x86_64-linux" &
XMONAD_PID=$!

# Launch xclock to verify window tiling and rendering
DISPLAY=:1 xclock &
XCLOCK_PID=$!

trap "kill $XMONAD_PID $XCLOCK_PID $XEPHYR_PID 2>/dev/null" EXIT

wait $XEPHYR_PID
