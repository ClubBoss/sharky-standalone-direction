#!/usr/bin/env bash
set -euo pipefail

surface_request="${1:-}"
device="${2:-}"

if [[ "$device" != "compact" ]]; then
  echo 'Usage: ./tools/capture_act0_screens_v1.sh <home|learn|practice|review|profile|all> compact' >&2
  exit 64
fi

case "$surface_request" in
  home|learn|practice|review|profile)
    surfaces=("$surface_request")
    ;;
  all)
    surfaces=(home learn practice review profile)
    ;;
  *)
    echo 'Usage: ./tools/capture_act0_screens_v1.sh <home|learn|practice|review|profile|all> compact' >&2
    exit 64
    ;;
esac

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$root/output/screen_review/current"
bundle_id='com.example.pokerAnalyzer'
simulator_name='iPhone 17'
udid="$(xcrun simctl list devices available | sed -nE 's/^    iPhone 17 \(([0-9A-F-]+)\) \((Booted|Shutdown)\) *$/\1/p' | tail -n 1)"

if [[ -z "$udid" ]]; then
  echo "No available $simulator_name simulator was found for compact capture." >&2
  exit 1
fi

mkdir -p "$output_dir"
find "$output_dir" -mindepth 1 -maxdepth 1 -type f -delete

captured_files=()
for surface in "${surfaces[@]}"; do
  echo "Building $surface for $simulator_name..." >&2
  (
    cd "$root"
    flutter build ios --simulator --debug \
      --dart-define="SHARKY_CAPTURE_SURFACE=$surface"
  )

  app_path="$root/build/ios/iphonesimulator/Runner.app"
  if [[ ! -d "$app_path" ]]; then
    echo "Missing simulator app bundle after build: $app_path" >&2
    exit 1
  fi

  # Relaunching an already running Simulator app can leave `simctl launch`
  # blocked even after the new debug bundle has been installed. A fresh
  # simulator boot per surface is slower but deterministic for this local lane.
  xcrun simctl shutdown "$udid" 2>/dev/null || true
  xcrun simctl boot "$udid"
  open -a Simulator
  xcrun simctl bootstatus "$udid" -b
  xcrun simctl uninstall "$udid" "$bundle_id" 2>/dev/null || true
  xcrun simctl install "$udid" "$app_path"
  xcrun simctl launch "$udid" "$bundle_id" >/dev/null
  sleep 5

  output="$output_dir/$device.$surface.png"
  xcrun simctl io "$udid" screenshot "$output" >/dev/null
  if [[ ! -s "$output" ]]; then
    echo "Screenshot was not created or is empty: $output" >&2
    exit 1
  fi
  captured_files+=("$output")
  echo "$output"
done

commit="$(git -C "$root" rev-parse HEAD)"
if [[ -z "$(git -C "$root" status --short)" ]]; then
  worktree_status='clean'
else
  worktree_status='dirty'
fi

manifest="$output_dir/manifest.json"
{
  printf '{\n'
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
  for index in "${!captured_files[@]}"; do
    [[ "$index" -gt 0 ]] && printf ', '
    printf '"%s"' "${captured_files[$index]#"$root/"}"
  done
  printf '],\n'
  printf '  "note": "Generated screenshots are local-only and uncommitted."\n'
  printf '}\n'
} > "$manifest"

echo "$manifest"
