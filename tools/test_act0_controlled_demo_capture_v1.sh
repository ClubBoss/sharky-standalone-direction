#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CAPTURE_SCRIPT="$ROOT_DIR/tools/act0_controlled_demo_capture_v1.sh"
OUTPUT_DIR="${1:-$ROOT_DIR/output/playwright/act0_capture_smoke}"
TIMEOUT_SECONDS="${ACT0_CAPTURE_SMOKE_TIMEOUT_SECONDS:-480}"

[[ -x "$CAPTURE_SCRIPT" ]] || {
  printf 'missing executable capture script: %s\n' "$CAPTURE_SCRIPT" >&2
  exit 1
}

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

python3 - "$CAPTURE_SCRIPT" "$OUTPUT_DIR" "$TIMEOUT_SECONDS" <<'PY'
import json
import pathlib
import subprocess
import sys

script = pathlib.Path(sys.argv[1])
output_dir = pathlib.Path(sys.argv[2])
timeout_seconds = int(sys.argv[3])

try:
    completed = subprocess.run(
        [str(script), str(output_dir)],
        cwd=str(script.parent.parent),
        timeout=timeout_seconds,
        check=False,
        text=True,
        capture_output=True,
    )
except subprocess.TimeoutExpired as error:
    print(
        json.dumps(
            {
                "status": "timeout",
                "timeout_seconds": timeout_seconds,
                "stdout_tail": (error.stdout or "")[-1200:],
                "stderr_tail": (error.stderr or "")[-1200:],
            },
            indent=2,
        )
    )
    raise SystemExit(1)

manifest_file = output_dir / "manifest.json"
required_pngs = [
    "compact_phone.home.png",
    "large_phone.home.png",
    "tablet.home.png",
    "compact_phone.runner_theory.png",
    "compact_phone.world_completion.png",
]

failure = {
    "exit_code": completed.returncode,
    "manifest_exists": manifest_file.exists(),
    "missing_pngs": [name for name in required_pngs if not (output_dir / name).exists()],
    "stdout_tail": completed.stdout[-1200:],
    "stderr_tail": completed.stderr[-1200:],
}

if completed.returncode != 0 or not manifest_file.exists() or failure["missing_pngs"]:
    print(json.dumps(failure, indent=2))
    raise SystemExit(1)

manifest = json.loads(manifest_file.read_text())
if manifest.get("lane_type") != "literal_browser":
    print(
        json.dumps(
            {
                **failure,
                "manifest_lane_type": manifest.get("lane_type"),
            },
            indent=2,
        )
    )
    raise SystemExit(1)

print(
    json.dumps(
        {
            "status": "ok",
            "manifest": str(manifest_file),
            "entries": len(manifest.get("entries", [])),
        },
        indent=2,
    )
)
PY
