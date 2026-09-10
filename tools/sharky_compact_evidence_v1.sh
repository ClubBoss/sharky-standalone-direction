#!/usr/bin/env bash
# sharky_compact_evidence_v1.sh - capture raw command output, emit bounded evidence.
#
# The wrapped command is never streamed into agent context. Full output remains in
# an ignored *.log file; stdout receives only the compact summary.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  tools/sharky_compact_evidence_v1.sh --id <evidence-id> [--max-lines N] [--dir PATH] -- <command> [args...]

Example:
  tools/sharky_compact_evidence_v1.sh --id r23-analyze -- dart analyze
  tools/sharky_compact_evidence_v1.sh --id r23-tests -- flutter test test/ui_v2 -r compact
EOF
}

ID=""
MAX_LINES=20
OUT_DIR="${SHARKY_EVIDENCE_DIR:-output/context-economy}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --id)
      [ "$#" -ge 2 ] || { echo "ERROR=MISSING_ID_VALUE"; exit 2; }
      ID="$2"
      shift 2
      ;;
    --max-lines)
      [ "$#" -ge 2 ] || { echo "ERROR=MISSING_MAX_LINES_VALUE"; exit 2; }
      MAX_LINES="$2"
      shift 2
      ;;
    --dir)
      [ "$#" -ge 2 ] || { echo "ERROR=MISSING_DIR_VALUE"; exit 2; }
      OUT_DIR="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR=UNKNOWN_ARGUMENT:$1"
      usage
      exit 2
      ;;
  esac
done

if [ -z "$ID" ]; then
  echo "ERROR=ID_REQUIRED"
  exit 2
fi
if ! printf '%s' "$ID" | grep -Eq '^[A-Za-z0-9._-]+$'; then
  echo "ERROR=INVALID_ID"
  exit 2
fi
if ! printf '%s' "$MAX_LINES" | grep -Eq '^[1-9][0-9]*$'; then
  echo "ERROR=INVALID_MAX_LINES"
  exit 2
fi
if [ "$#" -eq 0 ]; then
  echo "ERROR=COMMAND_REQUIRED"
  exit 2
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR=NOT_GIT_REPOSITORY"
  exit 2
}
cd "$ROOT"

mkdir -p "$OUT_DIR"
RAW_LOG="$OUT_DIR/$ID.raw.log"
SUMMARY_LOG="$OUT_DIR/$ID.summary.log"

printf -v COMMAND_Q '%q ' "$@"
COMMAND_Q="${COMMAND_Q% }"

set +e
"$@" >"$RAW_LOG" 2>&1
COMMAND_EXIT="$?"
set -e

BYTES="$(wc -c <"$RAW_LOG" | tr -d '[:space:]')"
TEST_HEADLINE="$(
  grep -oE '\+[0-9]+ ~?[0-9]* ?-[0-9]+:' "$RAW_LOG" 2>/dev/null | tail -1 || true
)"
[ -n "$TEST_HEADLINE" ] || TEST_HEADLINE="NONE"

COMPILE_FAILURE_COUNT="$(
  grep -c 'Failed to load' "$RAW_LOG" 2>/dev/null || true
)"
[ -n "$COMPILE_FAILURE_COUNT" ] || COMPILE_FAILURE_COUNT=0

ASSERTION_FILES="$(
  grep -oE "dart test [^ ]+\.dart -p vm --plain-name '[^']*'" "$RAW_LOG" 2>/dev/null \
    | grep -v "plain-name 'loading" \
    | sed "s#.*/test/#test/#; s# -p vm.*##" \
    | sort -u || true
)"
if [ -n "$ASSERTION_FILES" ]; then
  ASSERTION_FILE_COUNT="$(printf '%s\n' "$ASSERTION_FILES" | wc -l | tr -d '[:space:]')"
else
  ASSERTION_FILE_COUNT=0
fi

ERROR_PREVIEW="$(
  grep -Ein '(^|[[:space:]])(error|exception|failed|failure)(:|[[:space:]])' "$RAW_LOG" 2>/dev/null \
    | head -n "$MAX_LINES" || true
)"
[ -n "$ERROR_PREVIEW" ] || ERROR_PREVIEW="NONE"

{
  printf '%s\n' \
    "SHARKY_COMPACT_EVIDENCE_V1" \
    "EVIDENCE_ID=$ID" \
    "COMMAND=$COMMAND_Q" \
    "EXIT_CODE=$COMMAND_EXIT" \
    "RAW_LOG=$RAW_LOG" \
    "RAW_BYTES=$BYTES" \
    "TEST_HEADLINE=$TEST_HEADLINE" \
    "COMPILE_FAILURE_COUNT=$COMPILE_FAILURE_COUNT" \
    "ASSERTION_FAILURE_FILE_COUNT=$ASSERTION_FILE_COUNT"

  echo "ASSERTION_FAILURE_FILES_BEGIN"
  if [ -n "$ASSERTION_FILES" ]; then
    printf '%s\n' "$ASSERTION_FILES" | head -n "$MAX_LINES"
  else
    echo "NONE"
  fi
  echo "ASSERTION_FAILURE_FILES_END"

  echo "ERROR_PREVIEW_BEGIN"
  printf '%s\n' "$ERROR_PREVIEW"
  echo "ERROR_PREVIEW_END"
  echo "END_SHARKY_COMPACT_EVIDENCE_V1"
} | tee "$SUMMARY_LOG"

exit "$COMMAND_EXIT"
