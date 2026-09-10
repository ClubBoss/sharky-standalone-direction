#!/usr/bin/env bash
# sharky_context_capsule_v2.sh - emit minimum sufficient live context for an agent.
#
# Read-only. The output is intentionally compact and machine-readable.
# It does not replace authority documents; it routes the next targeted read.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR=NOT_GIT_REPOSITORY"
  exit 2
}
cd "$ROOT"

STATE="${SHARKY_STATE_FILE:-docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md}"
CONTRACT="${SHARKY_PROMPT_CONTRACT:-docs/context/SHARKY_PROMPT_CONTRACT_V1.md}"

if [ ! -f "$STATE" ]; then
  echo "ERROR=STATE_FILE_MISSING"
  echo "STATE_FILE=$STATE"
  exit 3
fi

extract_assignment() {
  local key="$1"
  local line
  line="$(grep -m1 -F "\`$key = " "$STATE" 2>/dev/null || true)"
  if [ -z "$line" ]; then
    printf 'UNKNOWN'
    return
  fi
  line="${line#\`$key = }"
  line="${line%\`}"
  printf '%s' "$line"
}

extract_header() {
  local key="$1"
  local line
  line="$(grep -m1 -F "$key:" "$STATE" 2>/dev/null || true)"
  if [ -z "$line" ]; then
    printf 'UNKNOWN'
    return
  fi
  line="${line#"$key:"}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line#\`}"
  line="${line%\`}"
  printf '%s' "$line"
}

BRANCH="$(git branch --show-current 2>/dev/null || true)"
[ -n "$BRANCH" ] || BRANCH="DETACHED"
HEAD="$(git rev-parse HEAD)"
ORIGIN_MAIN="$(git rev-parse refs/remotes/origin/main 2>/dev/null || true)"
[ -n "$ORIGIN_MAIN" ] || ORIGIN_MAIN="UNRESOLVED"

if [ "$ORIGIN_MAIN" = "UNRESOLVED" ]; then
  HEAD_MATCHES_ORIGIN_MAIN="UNRESOLVED"
elif [ "$HEAD" = "$ORIGIN_MAIN" ]; then
  HEAD_MATCHES_ORIGIN_MAIN="YES"
else
  HEAD_MATCHES_ORIGIN_MAIN="NO"
fi

DIRTY_TRACKED_COUNT="$(
  git status --porcelain --untracked-files=no 2>/dev/null | wc -l | tr -d '[:space:]'
)"
STATE_BLOB="$(git rev-parse "HEAD:$STATE" 2>/dev/null || true)"
[ -n "$STATE_BLOB" ] || STATE_BLOB="UNTRACKED_OR_MODIFIED"

FROZEN_KEYS="$(
  grep -E '^`[A-Z0-9_]+ = .*FROZEN' "$STATE" 2>/dev/null \
    | sed -E 's/^`([^ ]+) = .*$/\1/' \
    | sort -u \
    | paste -sd, - || true
)"
[ -n "$FROZEN_KEYS" ] || FROZEN_KEYS="NONE_DECLARED"

printf '%s\n' \
  "SHARKY_CONTEXT_CAPSULE_V2" \
  "REPO=ClubBoss/sharky-standalone-direction" \
  "BRANCH=$BRANCH" \
  "HEAD=$HEAD" \
  "ORIGIN_MAIN=$ORIGIN_MAIN" \
  "HEAD_MATCHES_ORIGIN_MAIN=$HEAD_MATCHES_ORIGIN_MAIN" \
  "DIRTY_TRACKED_COUNT=$DIRTY_TRACKED_COUNT" \
  "STATE_FILE=$STATE" \
  "STATE_BLOB=$STATE_BLOB" \
  "STATE_STATUS=$(extract_header Status)" \
  "STATE_FRESHNESS=$(extract_header 'Freshness date')" \
  "CURRENT_STAGE=$(extract_assignment CURRENT_STAGE)" \
  "ACTIVE_FAMILY=$(extract_assignment ACTIVE_FAMILY)" \
  "EXACT_NEXT_ACTION=$(extract_assignment EXACT_NEXT_ACTION)" \
  "STRUCTURAL_VISUAL_EXPLORATION=$(extract_assignment STRUCTURAL_VISUAL_EXPLORATION)" \
  "HUMAN_PROOF=$(extract_assignment HUMAN_PROOF)" \
  "B8=$(extract_assignment B8)" \
  "FROZEN_KEYS=$FROZEN_KEYS" \
  "PROMPT_CONTRACT=$CONTRACT" \
  "END_SHARKY_CONTEXT_CAPSULE_V2"
