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

# The dated current-dispatch section owns live assignments. Historical
# dispatches below the next H2 heading must never supply missing values.
CURRENT_DISPATCH="$(
  awk '
    /^## [[:alpha:]]+ 20[0-9][0-9] exact current dispatch([[:space:]]|$)/ { active=1; next }
    active && /^## / { exit }
    active { print }
  ' "$STATE"
)"

extract_assignment() {
  local key="$1"
  local line
  line="$(printf '%s\n' "$CURRENT_DISPATCH" | grep -m1 -E "^\`$key = " || true)"
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
  line="$(printf '%s\n' "$STATE_HEADER" | grep -m1 -E "^${key}:" || true)"
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

# Required authority is the campaign header, exactly one current dispatch,
# its principal plan, stage, and implementation owner. Optional status keys
# (including B8, visual flags, and frozen-key hints) remain optional.
authority_error() {
  printf 'ERROR=AUTHORITY_UNRESOLVED\nAUTHORITY_FIELD=%s\n' "$1" >&2
  exit 4
}

authority_unresolved() {
  case "$1" in
    ""|UNKNOWN|UNRESOLVED|TBD|TODO|NOT_SET|UNKNOWN\ *|UNRESOLVED\ *) return 0 ;;
    *) return 1 ;;
  esac
}

dispatch_count="$(grep -Ec '^## [[:alpha:]]+ 20[0-9][0-9] exact current dispatch([[:space:]]|$)' "$STATE" || true)"
[ "$dispatch_count" -eq 1 ] && [ -n "$CURRENT_DISPATCH" ] || authority_error CURRENT_DISPATCH

STATE_HEADER="$(awk '/^## / { exit } { print }' "$STATE")"
for field in Status 'Freshness date'; do
  count="$(printf '%s\n' "$STATE_HEADER" | grep -Ec "^$field:" || true)"
  [ "$count" -eq 1 ] || authority_error "$field"
  value="$(extract_header "$field")"
  if authority_unresolved "$value"; then authority_error "$field"; fi
done
STATE_STATUS="$(extract_header Status)"
STATE_FRESHNESS="$(extract_header 'Freshness date')"

require_dispatch_field() {
  local field="$1" count value
  count="$(printf '%s\n' "$CURRENT_DISPATCH" | grep -Ec "^\`$field = " || true)"
  [ "$count" -eq 1 ] || authority_error "$field"
  value="$(extract_assignment "$field")"
  if authority_unresolved "$value"; then authority_error "$field"; fi
}

for field in PRINCIPAL_PLAN CURRENT_STAGE CURRENT_ACTIVE_IMPLEMENTATION_FAMILY; do
  require_dispatch_field "$field"
done

PRINCIPAL_PLAN="$(extract_assignment PRINCIPAL_PLAN)"
# The principal strategy is fixed by the existing AGENTS.md / adopted v5 contract.
[ "$PRINCIPAL_PLAN" = 'docs/plan/MASTER_PLAN_v5.0_TOP1_BULLDOZER_SSOT.md' ] \
  && [ -f "$PRINCIPAL_PLAN" ] || authority_error PRINCIPAL_PLAN
[ -f "$CONTRACT" ] || authority_error PROMPT_CONTRACT

BRANCH="$(git branch --show-current 2>/dev/null || true)"
[ -n "$BRANCH" ] || BRANCH="DETACHED"
HEAD="$(git rev-parse HEAD)"
# origin/main below is a local remote-tracking ref, NOT verified live GitHub main.
# Never fetch or infer remote freshness from HEAD_MATCHES_ORIGIN_MAIN.
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

ACTIVE_FAMILY="$(extract_assignment CURRENT_ACTIVE_IMPLEMENTATION_FAMILY)"
next_count="$(printf '%s\n' "$CURRENT_DISPATCH" | grep -Ec '^`EXACT_NEXT_ACTION = ' || true)"
[ "$next_count" -le 1 ] || authority_error EXACT_NEXT_ACTION
EXACT_NEXT_ACTION="$(extract_assignment EXACT_NEXT_ACTION)"
if [ "$next_count" -eq 0 ]; then
  case "$ACTIVE_FAMILY" in
    NONE|"NONE / "*) EXACT_NEXT_ACTION="NONE" ;;
    *) authority_error EXACT_NEXT_ACTION ;;
  esac
else
  if authority_unresolved "$EXACT_NEXT_ACTION"; then authority_error EXACT_NEXT_ACTION; fi
fi

# No implementation owner must never dispatch an implementation action.
case "$ACTIVE_FAMILY" in
  NONE|"NONE / "*)
    [ "$EXACT_NEXT_ACTION" = "NONE" ] || authority_error EXACT_NEXT_ACTION
    ;;
  *)
    [ "$EXACT_NEXT_ACTION" != "NONE" ] || authority_error EXACT_NEXT_ACTION
    ;;
esac

if [ -z "$CURRENT_DISPATCH" ]; then
  FROZEN_KEYS="UNKNOWN"
else
  FROZEN_KEYS="$(
    printf '%s\n' "$CURRENT_DISPATCH" \
      | grep -E '^`[A-Z0-9_]+ = .*FROZEN' \
      | sed -E 's/^`([^ ]+) = .*$/\1/' \
      | sort -u \
      | paste -sd, - || true
  )"
  [ -n "$FROZEN_KEYS" ] || FROZEN_KEYS="NONE_DECLARED"
fi

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
  "ACTIVE_FAMILY=$ACTIVE_FAMILY" \
  "EXACT_NEXT_ACTION=$EXACT_NEXT_ACTION" \
  "STRUCTURAL_VISUAL_EXPLORATION=$(extract_assignment STRUCTURAL_VISUAL_EXPLORATION)" \
  "HUMAN_PROOF=$(extract_assignment HUMAN_PROOF)" \
  "B8=$(extract_assignment B8)" \
  "FROZEN_KEYS=$FROZEN_KEYS" \
  "PROMPT_CONTRACT=$CONTRACT" \
  "END_SHARKY_CONTEXT_CAPSULE_V2"
