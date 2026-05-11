#!/usr/bin/env bash
set -eu
SRC="$HOME/Desktop/final content"
DST="content"
if [ ! -d "$SRC" ]; then
  echo "[sync] source directory missing: $SRC"
  exit 0
fi

echo "[sync] scanning $SRC for ZIPs and folders"
shopt -s nullglob
for zipfile in "$SRC"/*.zip; do
  echo "[sync] unzipped: $(basename "$zipfile")"
  unzip -o "$zipfile" -d "$DST"
done

for folder in "$SRC"/*/; do
  echo "[sync] copied folder: $(basename "$folder")"
  cp -R "$folder"* "$DST"/
done

echo "[sync] running analyzer..."
dart analyze || echo "[sync] analyzer warnings (non-fatal)"

echo "[sync] staging"
git add .

echo "[sync] ready for commit: git commit -m 'sync content'"
