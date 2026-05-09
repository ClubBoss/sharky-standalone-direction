#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

open_after=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --open)
      open_after=1
      shift
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      echo "Usage: $0 [--open]" >&2
      exit 1
      ;;
  esac
done

screenshot_tool_rel="tools/modern_table_screenshot_v1.dart"
screenshot_tool_abs="$repo_root/$screenshot_tool_rel"
if [ ! -f "$screenshot_tool_abs" ]; then
  echo "ERROR: Missing required tool: $screenshot_tool_rel" >&2
  exit 1
fi

# Optional: skip generation and only zip existing PNGs.
if [ "${SKIP_GENERATE:-0}" != "1" ]; then
  if ! command -v dart >/dev/null 2>&1; then
    echo "ERROR: dart is not available on PATH." >&2
    exit 1
  fi
  (cd "$repo_root" && dart run "$screenshot_tool_rel")
fi

zip_path="$repo_root/out/modern_table_screenshots_v1.zip"

files=(
  "out/modern_table_default.png"
  "out/modern_table_json.png"
  "out/modern_table_asset.png"
  "out/modern_table_default_portrait.png"
  "out/modern_table_json_portrait.png"
  "out/modern_table_asset_portrait.png"
  "out/modern_table_action_context.png"
  "out/modern_table_action_context_portrait.png"
  "out/runner_outcome_store.png"
)

files_abs=()
for file in "${files[@]}"; do
  file_abs="$repo_root/$file"
  files_abs+=("$file_abs")
  if [ ! -f "$file_abs" ]; then
    ls -la "$repo_root/out" | rg "modern_table_.*\.png$" || true
    echo "ERROR: Missing required screenshot: $file" >&2
    exit 1
  fi
done

if ! command -v zip >/dev/null 2>&1; then
  echo "ERROR: zip is not available on PATH." >&2
  exit 1
fi

rm -f "$zip_path"
zip -j -q "$zip_path" "${files_abs[@]}"

echo "$zip_path"

no_open_default="${NO_OPEN:-1}"
if [ "$open_after" = "1" ]; then
  no_open_default=0
fi

if [ "$no_open_default" = "0" ] &&
  command -v open >/dev/null 2>&1 &&
  [ "$(uname -s)" = "Darwin" ]; then
  open -R "$zip_path"
fi
