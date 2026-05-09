#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$PWD}"
if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  while [[ "$ROOT" != "/" ]]; do
    ROOT="$(dirname "$ROOT")"
    if [[ -f "$ROOT/pubspec.yaml" ]]; then
      break
    fi
  done
fi
cd "$ROOT"

ROADMAP_DEFAULT="docs/ROADMAP_FINAL_100_SSOT.md"
ROADMAP="${1:-$ROADMAP_DEFAULT}"

fail() {
  echo "[ssot-guard] FAIL: $1" >&2
  exit 1
}

run_guard() {
  local roadmap_file="$1"
  [[ -f "$roadmap_file" ]] || fail "missing roadmap file: $roadmap_file"

  local execution_count
  execution_count="$(rg -n "^- Current execution state:" "$roadmap_file" | wc -l | tr -d ' ')"
  [[ "$execution_count" == "1" ]] || fail "expected exactly 1 authoritative execution line, found $execution_count"

  local execution_line
  execution_line="$(rg "^- Current execution state:" "$roadmap_file")"

  local active next
  active="$(echo "$execution_line" | sed -E -n 's/.*ACTIVE=(R[0-9]+).*/\1/p')"
  next="$(echo "$execution_line" | sed -E -n 's/.*NEXT=(R[0-9]+).*/\1/p')"
  [[ -n "$active" ]] || fail "could not parse ACTIVE milestone from execution line"
  [[ -n "$next" ]] || fail "could not parse NEXT milestone from execution line"

  if ! rg -q "^# Milestone ${active}([[:space:]]|$)" "$roadmap_file"; then
    fail "ACTIVE milestone section missing: # Milestone ${active}"
  fi

  if rg -q "^# Milestone ${next}([[:space:]]|$)" "$roadmap_file"; then
    echo "[ssot-guard] PASS: ACTIVE=${active}, NEXT=${next}, continuity intact."
    return 0
  fi

  local expected_note
  expected_note="- \`# Milestone ${next}\` is not defined yet; define it before executing ${next} scope."
  if rg -F -q -- "$expected_note" "$roadmap_file"; then
    echo "[ssot-guard] PASS: ACTIVE=${active}, NEXT=${next}, NEXT explicitly deferred by continuity note."
    return 0
  fi
  fail "NEXT milestone section missing without explicit continuity note: # Milestone ${next}"
}

self_test() {
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  local ok_file="$tmp/ok.md"
  cat >"$ok_file" <<'EOF'
# Milestone R1 — Test
# Milestone R2 — Test
# Milestone switching rule
- Current execution state: ACTIVE=R1; NEXT=R2; R0 completed (closed).
EOF
  run_guard "$ok_file" >/dev/null

  local missing_active="$tmp/missing_active.md"
  cat >"$missing_active" <<'EOF'
# Milestone R2 — Test
# Milestone switching rule
- Current execution state: ACTIVE=R1; NEXT=R2; R0 completed (closed).
EOF
  if (run_guard "$missing_active" >/dev/null 2>&1); then
    fail "self-test expected missing ACTIVE failure"
  fi

  local missing_next_with_note="$tmp/missing_next_note.md"
  cat >"$missing_next_with_note" <<'EOF'
# Milestone R1 — Test
# Milestone switching rule
- Current execution state: ACTIVE=R1; NEXT=R2; R0 completed (closed).
- `# Milestone R2` is not defined yet; define it before executing R2 scope.
EOF
  run_guard "$missing_next_with_note" >/dev/null

  local duplicate_line="$tmp/duplicate_line.md"
  cat >"$duplicate_line" <<'EOF'
# Milestone R1 — Test
# Milestone R2 — Test
# Milestone switching rule
- Current execution state: ACTIVE=R1; NEXT=R2; R0 completed (closed).
- Current execution state: ACTIVE=R1; NEXT=R2; R0 completed (closed).
EOF
  if (run_guard "$duplicate_line" >/dev/null 2>&1); then
    fail "self-test expected duplicate execution line failure"
  fi

  echo "[ssot-guard] SELF-TEST PASS"
  rm -rf "$tmp"
  trap - EXIT
}

if [[ "${ROADMAP}" == "--self-test" ]]; then
  self_test
  exit 0
fi

run_guard "$ROADMAP"
