#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
site="$root/output/visual_control_center/current/site"
if [[ ! -f "$site/index.html" ]]; then
  echo "Visual Control Center missing; run flutter pub run tools/act0_visual_state_discovery_v1.dart then python3 tools/build_visual_control_center_v1.py" >&2
  exit 1
fi
echo "Dashboard path: $site"
echo "URL: http://127.0.0.1:4173"
cd "$site"
exec python3 -m http.server 4173 --bind 127.0.0.1
