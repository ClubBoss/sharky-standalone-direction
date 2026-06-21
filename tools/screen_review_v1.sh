#!/usr/bin/env bash
set -euo pipefail

group="${1:-}"
device="${2:-}"

usage() {
  echo 'Usage: ./tools/screen_review_v1.sh <core|learning_flow> compact' >&2
}

if [[ "$device" != "compact" ]]; then
  usage
  exit 64
fi

case "$group" in
  core)
    surfaces=(home learn practice review profile)
    ;;
  learning_flow)
    echo 'learning_flow is deferred in v1: no existing native real-text selector covers table_decision, answer_correct, answer_wrong, lesson_summary, result_receipt, or review_after_error without product/harness expansion.' >&2
    exit 2
    ;;
  *)
    usage
    exit 64
    ;;
esac

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bundle_id='com.example.pokerAnalyzer'
simulator_name='iPhone 17'
udid="$(xcrun simctl list devices available | sed -nE 's/^    iPhone 17 \(([0-9A-F-]+)\) \((Booted|Shutdown)\) *$/\1/p' | tail -n 1)"

if [[ -z "$udid" ]]; then
  echo "No available $simulator_name simulator was found for $device capture." >&2
  exit 1
fi

current_root="$root/output/screen_review/current"
final_dir="$current_root/$group"
staging_root="$root/output/screen_review/.staging"
staging_dir="$staging_root/${group}.$(date -u +%Y%m%dT%H%M%SZ).$$"
mkdir -p "$staging_dir"

cleanup() {
  local status=$?
  if [[ "$status" -ne 0 ]]; then
    echo "screen_review_v1: capture failed; previous output preserved at $final_dir" >&2
    echo "screen_review_v1: failed staging output left at $staging_dir" >&2
  fi
  exit "$status"
}
trap cleanup EXIT

run_with_timeout() {
  local seconds="$1"
  shift
  local pid
  "$@" &
  pid=$!
  local waited=0
  while kill -0 "$pid" 2>/dev/null; do
    if [[ "$waited" -ge "$seconds" ]]; then
      kill "$pid" 2>/dev/null || true
      sleep 1
      kill -9 "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      return 124
    fi
    sleep 1
    waited=$((waited + 1))
  done
  wait "$pid"
}

capture_surface() {
  local surface="$1"
  echo "screen_review_v1: building $surface for $simulator_name..." >&2
  (
    cd "$root"
    flutter build ios --simulator --debug \
      --dart-define="SHARKY_CAPTURE_SURFACE=$surface"
  )

  local app_path="$root/build/ios/iphonesimulator/Runner.app"
  if [[ ! -d "$app_path" ]]; then
    echo "Missing simulator app bundle after build: $app_path" >&2
    exit 1
  fi

  # CoreSimulator can hang launch/container commands when multiple simulator
  # devices are left booted from prior manual probes. Keep this lane isolated:
  # only the target compact simulator is booted for each surface.
  xcrun simctl shutdown all 2>/dev/null || true
  xcrun simctl boot "$udid"
  open -a Simulator
  xcrun simctl bootstatus "$udid" -b
  xcrun simctl terminate "$udid" "$bundle_id" 2>/dev/null || true
  xcrun simctl uninstall "$udid" "$bundle_id" 2>/dev/null || true
  xcrun simctl install "$udid" "$app_path"

  local stdout_log="$staging_dir/$device.$surface.launch.stdout.log"
  local stderr_log="$staging_dir/$device.$surface.launch.stderr.log"
  if ! run_with_timeout 30 xcrun simctl launch \
    --terminate-running-process \
    --stdout="$stdout_log" \
    --stderr="$stderr_log" \
    "$udid" "$bundle_id" >/dev/null; then
    echo "simctl launch failed or timed out for $surface." >&2
    [[ -s "$stderr_log" ]] && tail -n 40 "$stderr_log" >&2
    exit 1
  fi

  sleep 5

  local output="$staging_dir/$device.$surface.png"
  xcrun simctl io "$udid" screenshot "$output" >/dev/null
  if [[ ! -s "$output" ]]; then
    echo "Screenshot was not created or is empty: $output" >&2
    exit 1
  fi
  echo "$output"
}

captured_files=()
for surface in "${surfaces[@]}"; do
  capture_surface "$surface"
  captured_files+=("$staging_dir/$device.$surface.png")
done

xcrun simctl shutdown all 2>/dev/null || true
rm -f "$staging_dir"/*.launch.stdout.log "$staging_dir"/*.launch.stderr.log

commit="$(git -C "$root" rev-parse HEAD)"
if [[ -z "$(git -C "$root" status --short)" ]]; then
  worktree_status='clean'
else
  worktree_status='dirty'
fi

manifest="$staging_dir/manifest.json"
{
  printf '{\n'
  printf '  "schema": "screen_review_v1",\n'
  printf '  "group": "%s",\n' "$group"
  printf '  "git_commit": "%s",\n' "$commit"
  printf '  "git_status": "%s",\n' "$worktree_status"
  printf '  "captured_at": "%s",\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '  "device": "%s",\n' "$device"
  printf '  "simulator": "%s",\n' "$simulator_name"
  printf '  "surfaces": ['
  for index in "${!surfaces[@]}"; do
    [[ "$index" -gt 0 ]] && printf ', '
    printf '"%s"' "${surfaces[$index]}"
  done
  printf '],\n'
  printf '  "output_files": ['
  for index in "${!surfaces[@]}"; do
    [[ "$index" -gt 0 ]] && printf ', '
    printf '"%s"' "output/screen_review/current/$group/$device.${surfaces[$index]}.png"
  done
  printf '],\n'
  printf '  "note": "Generated screenshots are local-only and uncommitted."\n'
  printf '}\n'
} > "$manifest"

"$root/tools/package_screen_review_v1.sh" current "$group" "$staging_dir"

mkdir -p "$current_root"
rm -rf "$final_dir.previous"
if [[ -d "$final_dir" ]]; then
  mv "$final_dir" "$final_dir.previous"
fi
mv "$staging_dir" "$final_dir"
rm -rf "$final_dir.previous"
"$root/tools/package_screen_review_v1.sh" current "$group" "$final_dir" >/dev/null

echo "$final_dir/contact_sheet.png"
echo "$final_dir/screen_review_${group}.zip"
