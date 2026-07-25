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

# Terminal-status vocabulary observed in this repo. HEURISTIC: --open means
# "not obviously terminal", not "authoritatively open". Use --status for precision.
CLOSED_RE='CLOSED|ADMITTED|SUPERSEDED|HISTORICAL|DISPROVED|REFERENCE|PROVEN|FIXED|accepted|landed|_ready|ready_|implemented|closeout|no_code|complete'

emit() {
  local file="$1" status="$2" date="$3" baseline="$4"
  if [ "$TSV" -eq 1 ]; then
    printf '%s\t%s\t%s\t%s\n' "$file" "$status" "$date" "$baseline"
  else
    printf '%-72s | %-34s | %-12s | %s\n' "$file" "$(printf '%s' "$status" | cut -c1-34)" "$date" "$baseline"
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

  # Prefer machine-readable frontmatter (tools/docs_frontmatter_v1.py) when the
  # document carries it: one cheap read of known fields beats regex-guessing prose.
  if head -1 "$file" 2>/dev/null | grep -q '^---$'; then
    # Every extraction is || true guarded: under `set -e` a non-matching grep
    # would abort the whole loop and silently truncate the index.
    fm=$(sed -n '2,/^---$/p' "$file" 2>/dev/null || true)
    status=$(printf '%s' "$fm" | grep -m1 '^status:' 2>/dev/null | sed 's/^status: *//; s/^"//; s/"$//' || true)
    date=$(printf '%s' "$fm" | grep -m1 '^doc_date:' 2>/dev/null | sed 's/^doc_date: *//; s/"//g' || true)
    baseline=$(printf '%s' "$fm" | grep -m1 '^baseline:' 2>/dev/null | sed 's/^baseline: *//; s/"//g' || true)
  else
    # Fallback for unstamped documents (top-authority docs and code-referenced ones).
    status=$(grep -m1 -oiE '^(status|verdict)[: ][^|]{0,60}' "$file" 2>/dev/null \
              | head -1 | tr -s ' ' || true)
    date=$(grep -m1 -oE '20[0-9]{2}-[01][0-9]-[0-3][0-9]' "$file" 2>/dev/null || true)
    baseline=$(grep -m1 -oE '\b[0-9a-f]{8,40}\b' "$file" 2>/dev/null | head -1 | cut -c1-12 || true)
  fi

  [ -z "$status" ] && status='(none declared)'
  [ -z "$date" ] && date='-'
  [ -z "$baseline" ] && baseline='-'

  if [ "$ONLY_OPEN" -eq 1 ] && printf '%s' "$status" | grep -qiE "$CLOSED_RE"; then
    continue
  fi

  # Truncate for display only — filtering above uses the full value, or a status
  # like "..._ui_ready" would be cut to "..._ui_read" and evade the match.
  emit "$file" "$status" "$date" "$baseline"
  shown=$((shown + 1))
done < <(find "${DIRS[@]}" -maxdepth 1 -name '*.md' -type f 2>/dev/null | sort)

if [ "$TSV" -eq 0 ]; then
  echo
  echo "scanned: $total   shown: $shown   (filter: $([ "$ONLY_OPEN" -eq 1 ] && echo 'open only' || echo 'all'))"
  echo "Reminder: this index is a routing aid, not authority. Confirm status in the"
  echo "document before relying on it, and prefer the campaign state file first."
fi
