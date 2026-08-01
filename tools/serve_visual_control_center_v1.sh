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
if [[ ! -f "$evidence/VISUAL_EVIDENCE_IDENTITY_MANIFEST_V1.json" || ! -f "$evidence/screen_inventory.json" ]]; then
  echo "Stable evidence is missing. Copy or regenerate it at: $root/output/visual_control_center/evidence/current/" >&2
  exit 1
fi
build() {
  (cd "$root" && dart run tools/act0_visual_state_discovery_v1.dart --output=output/visual_control_center/current/runtime_discovery.json && python3 tools/build_visual_control_center_v1.py --evidence="$evidence" --discovery=output/visual_control_center/current/runtime_discovery.json)
}
build
site="$root/output/visual_control_center/current/site"
watch_pid=""
server_pid=""
cleanup_done=0
terminate_and_reap() {
  local pid="$1"
  [[ -z "$pid" ]] && return 0
  if kill -0 "$pid" 2>/dev/null; then
    kill -TERM "$pid" 2>/dev/null || true
    for _ in 1 2 3 4 5; do
      kill -0 "$pid" 2>/dev/null || break
      sleep 0.1
    done
    kill -0 "$pid" 2>/dev/null && kill -KILL "$pid" 2>/dev/null || true
  fi
  wait "$pid" 2>/dev/null || true
}
cleanup() {
  [[ "$cleanup_done" == 1 ]] && return
  cleanup_done=1
  trap - EXIT INT TERM
  terminate_and_reap "$watch_pid"
  terminate_and_reap "$server_pid"
}
trap cleanup EXIT
trap 'cleanup; exit 0' INT TERM
if [[ "$watch" == 1 ]]; then
  (
    rebuild_pid=""
    watcher_cleanup_done=0
    watcher_cleanup() {
      [[ "$watcher_cleanup_done" == 1 ]] && return
      watcher_cleanup_done=1
      trap - EXIT INT TERM
      terminate_and_reap "$rebuild_pid"
    }
    trap watcher_cleanup EXIT
    trap 'exit 0' INT TERM
    last=""
    while :; do
      now=$(find "$root/tools/visual_state_atlas_registry_v1.json" "$root/tools/act0_visual_state_discovery_v1.dart" "$evidence" -type f -print0 2>/dev/null | xargs -0 stat -f '%m %N' 2>/dev/null | shasum | awk '{print $1}')
      if [[ -n "$last" && "$now" != "$last" ]]; then
        build & rebuild_pid=$!
        wait "$rebuild_pid" || echo "Atlas rebuild failed; serving last successful site." >&2
        rebuild_pid=""
      fi
      last="$now"; sleep 2
    done
  ) & watch_pid=$!
fi
echo "Dashboard path: $site"
echo "URL: http://127.0.0.1:$port"
(cd "$site" && exec python3 -m http.server "$port" --bind 127.0.0.1) & server_pid=$!
wait "$server_pid"
