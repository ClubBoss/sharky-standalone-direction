#!/usr/bin/env bash
# Opt-in exact-commit static preflight. No CI/PR/score/owner mutations.
set -euo pipefail

usage() {
  echo "Usage: bash tools/sharky_candidate_preflight_v1.sh --head SHA40 --base SHA40 [--run-static]"
  echo "Default is read-only plan. --run-static requires a clean, non-main isolated checkout."
}

HEAD_ARG=""
BASE_ARG=""
RUN_STATIC=0
while (( $# )); do
  case "$1" in
    --head|--base)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      if [[ "$1" == "--head" ]]; then HEAD_ARG="$2"; else BASE_ARG="$2"; fi
      shift 2 ;;
    --run-static) RUN_STATIC=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR=UNKNOWN_ARG" >&2; usage >&2; exit 2 ;;
  esac
done

[[ "$HEAD_ARG" =~ ^[0-9a-f]{40}$ && "$BASE_ARG" =~ ^[0-9a-f]{40}$ ]] || {
  echo "ERROR=EXACT_SHA40_REQUIRED" >&2; exit 2;
}
[[ "$HEAD_ARG" != "$BASE_ARG" ]] || { echo "ERROR=SAME_BASE_AND_HEAD" >&2; exit 2; }
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR=NOT_GIT_CHECKOUT" >&2; exit 2;
}
cd "$ROOT"
ACTUAL_HEAD="$(git rev-parse HEAD)"
[[ "$ACTUAL_HEAD" == "$HEAD_ARG" ]] || {
  echo "ERROR=HEAD_MISMATCH expected=$HEAD_ARG actual=$ACTUAL_HEAD" >&2; exit 3;
}
[[ "$(git cat-file -t "$BASE_ARG" 2>/dev/null)" == "commit" ]] || {
  echo "ERROR=BASE_COMMIT_NOT_LOCAL" >&2; exit 3;
}
git merge-base --is-ancestor "$BASE_ARG" "$HEAD_ARG" || {
  echo "ERROR=BASE_NOT_ANCESTOR" >&2; exit 3;
}
TREE="$(git rev-parse 'HEAD^{tree}')"
BRANCH="$(git symbolic-ref --quiet --short HEAD || echo DETACHED)"
echo "SCHEMA=SHARKY_CANDIDATE_PREFLIGHT_V1"
echo "HEAD=$ACTUAL_HEAD"
echo "TREE=$TREE"
echo "BASE=$BASE_ARG"
echo "BRANCH=$BRANCH"
echo "SOURCE_TESTS=NOT_RUN"
echo "NATIVE=NOT_VERIFIED"
echo "INDEPENDENT_DOD=NOT_INFERRED"
echo "SCORECARD=UNTOUCHED"

ALL_DART_FILES=()
FORMAT_DART_FILES=()
DELETED_DART_FILES=()
MISSING_DART_FILES=()
while IFS= read -r -d '' path; do
  ALL_DART_FILES+=("$path")
  if git cat-file -e "$HEAD_ARG:$path" 2>/dev/null; then
    if [[ -f "$path" ]]; then
      FORMAT_DART_FILES+=("$path")
    else
      MISSING_DART_FILES+=("$path")
    fi
  else
    DELETED_DART_FILES+=("$path")
  fi
done < <(git diff --name-only --diff-filter=ACMRTD -z "$BASE_ARG" "$HEAD_ARG" -- '*.dart')
echo "CHANGED_DART_COUNT=${#ALL_DART_FILES[@]}"
echo "CHANGED_DART_BEGIN"
if (( ${#ALL_DART_FILES[@]} )); then printf '%s\n' "${ALL_DART_FILES[@]}"; else echo "NONE"; fi
echo "CHANGED_DART_END"
echo "FORMAT_DART_COUNT=${#FORMAT_DART_FILES[@]}"
echo "DELETED_DART_COUNT=${#DELETED_DART_FILES[@]}"
if (( ${#DELETED_DART_FILES[@]} )); then
  printf 'DELETED_DART=%s\n' "${DELETED_DART_FILES[@]}"
fi
if (( ${#MISSING_DART_FILES[@]} )); then
  echo "CHECKOUT_COVERAGE=INCOMPLETE"
  echo "MISSING_DART_COUNT=${#MISSING_DART_FILES[@]}"
  printf 'MISSING_DART=%s\n' "${MISSING_DART_FILES[@]}"
else
  echo "CHECKOUT_COVERAGE=COMPLETE_FOR_CHANGED_DART"
fi

if (( ! RUN_STATIC )); then
  echo "MODE=PLAN_ONLY"
  echo "FORMAT=NOT_RUN"
  echo "ANALYZE=NOT_RUN"
  echo "DIFF_CHECK=NOT_RUN"
  echo "NEXT=Owner selects applicable tests and existing gates; no tests launched."
  exit 0
fi

if (( ${#MISSING_DART_FILES[@]} )); then
  echo "ERROR=INCOMPLETE_CHANGED_FILE_CHECKOUT" >&2
  exit 4
fi
[[ "$BRANCH" != "main" && "$BRANCH" != "DETACHED" ]] || {
  echo "ERROR=OWNED_NON_MAIN_BRANCH_REQUIRED" >&2; exit 4;
}
[[ -z "$(git status --porcelain --untracked-files=normal)" ]] || {
  echo "ERROR=DIRTY_CHECKOUT" >&2; exit 4;
}
[[ -f tools/sharky_compact_evidence_v1.sh ]] || {
  echo "ERROR=EXISTING_EVIDENCE_WRAPPER_MISSING" >&2; exit 4;
}
echo "MODE=RUN_STATIC_ONLY"
EVIDENCE_ROOT="${SHARKY_EVIDENCE_DIR:-output/context-economy}"
mkdir -p "$EVIDENCE_ROOT"
ATTEMPT_DIR="$(mktemp -d "${EVIDENCE_ROOT%/}/preflight-${HEAD_ARG:0:12}-XXXXXXXX")"
STARTED_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
{
  printf '%s\n' "SCHEMA=SHARKY_PREFLIGHT_ATTEMPT_V1" \
    "HEAD=$HEAD_ARG" "TREE=$TREE" "BASE=$BASE_ARG" \
    "BRANCH=$BRANCH" "STARTED_UTC=$STARTED_UTC" \
    "DOD=NOT_INFERRED" "SCORECARD=UNTOUCHED"
} > "$ATTEMPT_DIR/identity.txt"
echo "EVIDENCE_DIR=$ATTEMPT_DIR"
echo "ATTEMPT_STARTED_UTC=$STARTED_UTC"
echo "DIFF_CHECK=RUNNING"
bash tools/sharky_compact_evidence_v1.sh --dir "$ATTEMPT_DIR" --id diff-check -- \
  git diff --check "$BASE_ARG" "$HEAD_ARG"
echo "DIFF_CHECK=PASS"
if (( ${#FORMAT_DART_FILES[@]} )); then
  echo "FORMAT=RUNNING"
  bash tools/sharky_compact_evidence_v1.sh --dir "$ATTEMPT_DIR" --id format -- \
    dart format --output=none --set-exit-if-changed "${FORMAT_DART_FILES[@]}"
  echo "FORMAT=PASS"
else
  echo "FORMAT=SKIPPED_NO_EXISTING_DART_FILES"
fi
if (( ${#ALL_DART_FILES[@]} )); then
  echo "ANALYZE=RUNNING"
  bash tools/sharky_compact_evidence_v1.sh --dir "$ATTEMPT_DIR" --id analyze -- flutter analyze
  echo "ANALYZE=PASS"
else
  echo "ANALYZE=SKIPPED_NO_DART_CHANGES"
fi
echo "STATIC_PREFLIGHT=PASS_SCOPED"
echo "NEXT=Run already-required targeted/source/CI/native gates under the actual owner."
