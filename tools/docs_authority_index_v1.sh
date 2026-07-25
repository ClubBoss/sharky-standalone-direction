#!/usr/bin/env bash
# docs_authority_index_v1.sh — emit a compact status index over the docs corpus.
#
# Why: a superseded review document reads as authoritative, because status lives
# in prose rather than metadata. Reading N documents to learn which one is
# current is the single largest token sink in this repository. This prints the
# status-bearing lines only, so an agent can pick the current authority without
# opening files.
#
# Output goes to stdout and is NOT committed (generated artifact).
#
# Usage:
#   tools/docs_authority_index_v1.sh                  # plan + context + reviews
#   tools/docs_authority_index_v1.sh docs/_reviews     # one directory
#   tools/docs_authority_index_v1.sh --open            # only non-closed docs
#   tools/docs_authority_index_v1.sh --tsv             # machine-readable
set -euo pipefail

cd "$(dirname "$0")/.."

ONLY_OPEN=0
TSV=0
DIRS=()
for arg in "$@"; do
  case "$arg" in
    --open) ONLY_OPEN=1 ;;
    --tsv) TSV=1 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) DIRS+=("$arg") ;;
  esac
done
if [ ${#DIRS[@]} -eq 0 ]; then
  DIRS=(docs/plan docs/context docs/_reviews)
fi

# Status vocabulary actually used in this repo.
CLOSED_RE='CLOSED|ADMITTED|SUPERSEDED|HISTORICAL|DISPROVED|REFERENCE|CLOSED_PROVEN|CLOSED_FIXED'

emit() {
  local file="$1" status="$2" date="$3" baseline="$4"
  if [ "$TSV" -eq 1 ]; then
    printf '%s\t%s\t%s\t%s\n' "$file" "$status" "$date" "$baseline"
  else
    printf '%-72s | %-34s | %-12s | %s\n' "$file" "$status" "$date" "$baseline"
  fi
}

if [ "$TSV" -eq 0 ]; then
  printf '%-72s | %-34s | %-12s | %s\n' "FILE" "STATUS" "DATE" "BASELINE"
  printf '%s\n' "$(printf '=%.0s' {1..150})"
fi

total=0
shown=0
while IFS= read -r file; do
  total=$((total + 1))

  # First status-like declaration in the head of the file.
  status=$(grep -m1 -oiE '^(status|verdict)[: ][^|]{0,60}' "$file" 2>/dev/null \
            | head -1 | cut -c1-34 | tr -s ' ' || true)
  [ -z "$status" ] && status='(none declared)'

  date=$(grep -m1 -oE '20[0-9]{2}-[01][0-9]-[0-3][0-9]' "$file" 2>/dev/null || true)
  [ -z "$date" ] && date='-'

  # Baseline / evidence commit, if the doc pins one.
  baseline=$(grep -m1 -oE '\b[0-9a-f]{8,40}\b' "$file" 2>/dev/null | head -1 | cut -c1-12 || true)
  [ -z "$baseline" ] && baseline='-'

  if [ "$ONLY_OPEN" -eq 1 ] && printf '%s' "$status" | grep -qiE "$CLOSED_RE"; then
    continue
  fi

  emit "$file" "$status" "$date" "$baseline"
  shown=$((shown + 1))
done < <(find "${DIRS[@]}" -maxdepth 1 -name '*.md' -type f 2>/dev/null | sort)

if [ "$TSV" -eq 0 ]; then
  echo
  echo "scanned: $total   shown: $shown   (filter: $([ "$ONLY_OPEN" -eq 1 ] && echo 'open only' || echo 'all'))"
  echo "Reminder: this index is a routing aid, not authority. Confirm status in the"
  echo "document before relying on it, and prefer the campaign state file first."
fi
