#!/usr/bin/env bash
set -euo pipefail

# This script intentionally avoids running unless the caller opts in to seeded logs,
# so it can be checked in CI when the gate has deterministic artifacts available.

if [[ "${PUBLIC_DEMO_SEEDED:-0}" != "1" ]]; then
  echo "SKIP: PUBLIC_DEMO_SEEDED not set" >&2
  exit 0
fi

stdout_file=$(mktemp)
stderr_file=$(mktemp)
trap 'rm -f "$stdout_file" "$stderr_file"' EXIT

if ! PUBLIC_DEMO_SEEDED=1 ./public_demo_gate.sh >"$stdout_file" 2>"$stderr_file"; then
  cat "$stderr_file" >&2
  echo "ERROR: public_demo_gate.sh failed; cannot validate stdout" >&2
  cat "$stdout_file" >&2
  exit 1
fi

python3 <<'PY' "$stdout_file"
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
for lineno, raw in enumerate(path.read_text().splitlines(), start=1):
    line = raw.strip()
    if not line:
        continue
    try:
        payload = json.loads(line)
    except json.JSONDecodeError:
        sys.stderr.write(f"ERROR: stdout line {lineno} is not JSON: {line}\n")
        sys.exit(1)
    if not isinstance(payload, dict) or "schema" not in payload:
        sys.stderr.write(f"ERROR: stdout line {lineno} missing schema: {line}\n")
        sys.exit(1)
PY
