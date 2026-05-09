#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

out_dir="$repo_root/out/store_assets/v1"
archive_root="$repo_root/out/store_assets/archive"
final_zip="$repo_root/out/store_assets_v1.zip"
runner_zip="$repo_root/out/runner_store_assets_v1.zip"
table_component_zip="$repo_root/out/table_component_assets_v1.zip"
canonical_repo_zip="$repo_root/out/modern_table_screenshots_v1.zip"
write_zip=0
clean=1
for arg in "$@"; do
  case "$arg" in
    --clean)
      clean=1
      ;;
    --no-clean)
      clean=0
      ;;
    --write-zip)
      write_zip=1
      ;;
    *)
      echo "ERROR: unsupported argument: $arg" >&2
      echo "usage: $0 [--clean|--no-clean] [--write-zip]" >&2
      exit 1
      ;;
  esac
done
canonical_backup=""
restore_canonical_zip() {
  if [[ "$write_zip" -eq 1 ]]; then
    return
  fi
  if [[ -n "$canonical_backup" && -f "$canonical_backup" ]]; then
    cp "$canonical_backup" "$canonical_repo_zip"
    rm -f "$canonical_backup"
    canonical_backup=""
  fi
}
trap restore_canonical_zip EXIT

table_component_pngs=(
  "modern_table_default.png"
  "modern_table_json.png"
  "modern_table_asset.png"
  "modern_table_default_portrait.png"
  "modern_table_json_portrait.png"
  "modern_table_asset_portrait.png"
  "modern_table_action_context.png"
  "modern_table_action_context_portrait.png"
)

runner_pngs=(
  "runner_outcome_store.png"
  "session_result_screen_v1.png"
  "session_result_screen_v1_ts115.png"
  "theory_runner_instruction_override_v1.png"
  "theory_runner_instruction_e2e_v1.png"
  "runner_portrait_fullwidth_v1.png"
  "runner_intro_prelude_coach_v1.png"
  "runner_vertical_final_v1.png"
  "runner_9max_overlay_proof_v1.png"
  "runner_10max_overlay_proof_v1.png"
  "today_plan_runner_vertical_proof_v1.png"
  "runner_table_first_iphone_v1.png"
  "seat_quiz_order_v1.png"
)

map_pngs=(
  "campaign_map_duolingo_v1.png"
  "campaign_map_single_spine_v2.png"
  "map_world_detail_sheet_v1.png"
  "map_world_detail_sheet_v1_ts115.png"
  "map_ladder_iphone_v1.png"
)

intake_pngs=(
  "device_entry_path_parity_v1.png"
  "intake_seat_order_v1.png"
  "intake_table_vertical_proof_v1.png"
)

required_pngs=(
  "${table_component_pngs[@]}"
  "${runner_pngs[@]}"
  "${map_pngs[@]}"
  "${intake_pngs[@]}"
)

png_min_bytes=5000
zip_min_bytes=20000

if ! command -v dart >/dev/null 2>&1; then
  echo "ERROR: dart is not available on PATH." >&2
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "ERROR: zip is not available on PATH." >&2
  exit 1
fi

cd "$repo_root"

if [[ "$write_zip" -eq 0 && -f "$canonical_repo_zip" ]]; then
  canonical_backup="$(mktemp "${TMPDIR:-/tmp}/store_assets_zip_backup.XXXXXX")"
  cp "$canonical_repo_zip" "$canonical_backup"
fi

echo "[store-assets] generating canonical deterministic screenshots"
dart run tools/modern_table_screenshot_v1.dart
SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh

archive_dir=""
if [[ "$clean" -eq 1 ]]; then
  if [[ -d "$out_dir" || -f "$final_zip" || -f "$runner_zip" || -f "$table_component_zip" ]]; then
    timestamp="$(date -u +"%Y%m%dT%H%M%SZ")"
    archive_dir="$archive_root/$timestamp"
    if [[ -e "$archive_dir" ]]; then
      archive_dir="${archive_dir}_$$"
    fi
    mkdir -p "$archive_dir"
    if [[ -d "$out_dir" ]]; then
      mv "$out_dir" "$archive_dir/v1"
    fi
    if [[ -f "$final_zip" ]]; then
      mv "$final_zip" "$archive_dir/"
    fi
    if [[ -f "$runner_zip" ]]; then
      mv "$runner_zip" "$archive_dir/"
    fi
    if [[ -f "$table_component_zip" ]]; then
      mv "$table_component_zip" "$archive_dir/"
    fi
    echo "[store-assets] archived previous outputs: $archive_dir"
  fi
fi

rm -rf "$out_dir"
mkdir -p "$out_dir/runner" "$out_dir/map" "$out_dir/intake" "$out_dir/table_component"

copy_png_group() {
  local subdir="$1"
  shift
  local name abs
  for name in "$@"; do
    abs="$repo_root/out/$name"
    if [[ ! -f "$abs" ]]; then
      echo "ERROR: missing required output: out/$name" >&2
      exit 1
    fi
    cp "$abs" "$out_dir/$subdir/"
  done
}

copy_png_group "table_component" "${table_component_pngs[@]}"
copy_png_group "runner" "${runner_pngs[@]}"
copy_png_group "map" "${map_pngs[@]}"
copy_png_group "intake" "${intake_pngs[@]}"

if [[ ! -f "$canonical_repo_zip" ]]; then
  echo "ERROR: missing required output: out/modern_table_screenshots_v1.zip" >&2
  exit 1
fi
cp "$canonical_repo_zip" "$out_dir/table_component/"

cat > "$out_dir/README.txt" <<EOF
Store Assets v1 (generated)

runner/, map/, intake/ contain runner/product proofs that reflect current app UX.
table_component/ contains isolated ModernTable component scenes for visual QA.
Component scenes may not match full app screens, layout chrome, or navigation.
Use runner/map/intake screenshots for store/app UX reviews.
Use table_component screenshots for component regression checks only.

Latest run folder: $out_dir
When --clean is enabled (default), previous runs are moved to:
  $archive_root/<UTC timestamp>/v1
Archive folders keep older outputs and zips for traceability.
If you need to preserve current outputs, run with --no-clean.
Legacy zip out/store_assets_v1.zip now contains runner/map/intake proofs only.
EOF

# Confidence gate: existence + non-trivial file size checks.
for png in "${required_pngs[@]}"; do
  case "$png" in
    modern_table_*)
      abs="$out_dir/table_component/$png"
      ;;
    campaign_map_*|map_ladder_iphone_v1.png|map_world_detail_sheet_v1.png|map_world_detail_sheet_v1_ts115.png)
      abs="$out_dir/map/$png"
      ;;
    intake_*|device_entry_path_parity_v1.png)
      abs="$out_dir/intake/$png"
      ;;
    *)
      abs="$out_dir/runner/$png"
      ;;
  esac
  if [[ ! -f "$abs" ]]; then
    echo "ERROR: missing required screenshot in split store assets output: $png" >&2
    exit 1
  fi
  size="$(wc -c < "$abs")"
  if [[ "$size" -lt "$png_min_bytes" ]]; then
    echo "ERROR: screenshot too small (${size}B < ${png_min_bytes}B): $png" >&2
    exit 1
  fi
done

canonical_zip="$out_dir/table_component/modern_table_screenshots_v1.zip"
canonical_zip_size="$(wc -c < "$canonical_zip")"
if [[ "$canonical_zip_size" -lt "$zip_min_bytes" ]]; then
  echo "ERROR: canonical screenshot zip too small (${canonical_zip_size}B < ${zip_min_bytes}B): modern_table_screenshots_v1.zip" >&2
  exit 1
fi

if [[ "$write_zip" -eq 0 ]]; then
  restore_canonical_zip
fi

rm -f "$final_zip" "$runner_zip" "$table_component_zip"
(
  cd "$out_dir"
  zip -qr "$runner_zip" runner map intake README.txt
  zip -qr "$final_zip" runner map intake README.txt
  zip -qr "$table_component_zip" table_component README.txt
)

for zip_path in "$runner_zip" "$final_zip" "$table_component_zip"; do
  zip_size="$(wc -c < "$zip_path")"
  if [[ "$zip_size" -lt "$zip_min_bytes" ]]; then
    echo "ERROR: consolidated store zip too small (${zip_size}B < ${zip_min_bytes}B): $(basename "$zip_path")" >&2
    exit 1
  fi
done

echo "[store-assets] generated"
echo "  folder: $out_dir"
echo "  zip (legacy runner/map/intake): $final_zip"
echo "  zip (runner proofs): $runner_zip"
echo "  zip (table component): $table_component_zip"
if [[ -n "$archive_dir" ]]; then
  echo "  archive: $archive_dir"
fi
echo "[store-assets] checklist"
echo "  - 20 deterministic screenshots copied into split folders"
echo "  - canonical screenshot zip copied under table_component/"
echo "  - runner/map/intake zip created (+ legacy compatibility zip)"
echo "  - table component zip created"
echo "[store-assets] confidence gate"
echo "  - png minimum bytes: ${png_min_bytes}"
echo "  - zip minimum bytes: ${zip_min_bytes}"
