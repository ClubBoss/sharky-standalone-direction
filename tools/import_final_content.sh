#!/usr/bin/env bash
set -eu
SRC="$HOME/Desktop/final content"
DST="content"
if [ -d "$SRC" ]; then
  echo "[import] copying from $SRC -> $DST"
  cp -R "$SRC"/* "$DST"/
  echo "[import] done"
  echo "[import] run git add/commit manually"
else
  echo "[import] source directory does not exist: $SRC"
fi
