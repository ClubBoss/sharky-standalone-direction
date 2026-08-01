#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
evidence="$root/output/visual_control_center/evidence/current"
port=4173
watch=1
for arg in "$@"; do
  case "$arg" in
    --evidence=*) evidence=${arg#*=} ;;
    --port=*) port=${arg#*=} ;;
    --no-watch) watch=0 ;;
    *) echo "Usage: $0 [--evidence=<path>] [--no-watch] [--port=<port>]" >&2; exit 2 ;;
  esac
done
if [[ ! -f "$evidence/MASTER_MANIFEST.json" || ! -f "$evidence/screen_inventory.json" ]]; then
  echo "Stable evidence is missing. Copy or regenerate it at: $root/output/visual_control_center/evidence/current/" >&2
  exit 1
fi
build() {
  (cd "$root" && dart run tools/act0_visual_state_discovery_v1.dart --output=output/visual_control_center/current/runtime_discovery.json && python3 tools/build_visual_control_center_v1.py --evidence="$evidence" --discovery=output/visual_control_center/current/runtime_discovery.json)
}
build
site="$root/output/visual_control_center/current/site"
cleanup() { [[ -n "${watch_pid:-}" ]] && kill "$watch_pid" 2>/dev/null || true; [[ -n "${server_pid:-}" ]] && kill "$server_pid" 2>/dev/null || true; }
trap cleanup EXIT INT TERM
if [[ "$watch" == 1 ]]; then
  (
    last=""
    while :; do
      now=$(find "$root/tools/visual_state_atlas_registry_v1.json" "$root/tools/act0_visual_state_discovery_v1.dart" "$evidence" -type f -maxdepth 2 -print0 2>/dev/null | xargs -0 stat -f '%m %N' 2>/dev/null | shasum | awk '{print $1}')
      if [[ -n "$last" && "$now" != "$last" ]]; then build || echo "Atlas rebuild failed; serving last successful site." >&2; fi
      last="$now"; sleep 2
    done
  ) & watch_pid=$!
fi
echo "Dashboard path: $site"
echo "URL: http://127.0.0.1:$port"
(cd "$site" && python3 -m http.server "$port" --bind 127.0.0.1) & server_pid=$!
wait "$server_pid"
