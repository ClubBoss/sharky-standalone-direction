#!/usr/bin/env bash
set -euo pipefail

ROOT="$PWD"
if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  while [[ "$ROOT" != "/" ]]; do
    ROOT="$(dirname "$ROOT")"
    if [[ -f "$ROOT/pubspec.yaml" ]]; then
      break
    fi
  done
fi
cd "$ROOT"
source "$ROOT/tools/_test_policy_v1.sh"
source "$ROOT/tools/_fast_loop_test_tiers_v1.sh"

test_policy_should_run_full_suite_v1 "$@"
test_policy_require_full_suite_enabled_v1

collect_changed_dart_files_v1() {
  printf '%s\n' "$changed_files" | while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    [[ "$path" == *.dart ]] || continue
    [[ -f "$path" ]] || continue
    case "$path" in
      lib/*|test/*|bin/*|tool/*|tools/*) ;;
      *) continue ;;
    esac
    echo "$path"
  done
}

# Capture exit status directly, not inside mapfile process substitution.
fast_loop_read_changeset_v1 "$ROOT" || exit $?
changed_files="$SHARKY_CHANGED_FILES_V1"
echo "[gate] changeset scope: $SHARKY_CHANGE_SCOPE_V1 (full-scope is not baseline proof)"

echo "[gate] Policy: full-suite $([[ "$TEST_POLICY_FULL_SUITE_V1" == "1" ]] && echo "ON" || echo "OFF") ($TEST_POLICY_REASON_V1)"
echo "[gate] 1/5 git diff hygiene"
git diff --check

mapfile -t changed_dart_files < <(collect_changed_dart_files_v1)
if [[ ${#changed_dart_files[@]} -gt 0 ]]; then
  echo "[gate] 2/5 dart format (changed Dart files)"
  dart format --set-exit-if-changed "${changed_dart_files[@]}"
else
  echo "[gate] 2/5 dart format -> skip (no changed Dart files)"
fi

echo "[gate] pre-clean unit test assets"
rm -rf build/unit_test_assets || true
mkdir -p build || true

if [[ "$SHARKY_CHANGE_SCOPE_V1" == "full-scope" ]] || grep -Eq '^content/' <<< "$changed_files"; then
  echo "[gate] content changed -> validate training content"
  dart run tools/validate_training_content.dart
else
  echo "[gate] content unchanged -> skip validation"
fi

echo "[gate] 3/5 fast loop (tier checks)"
# Optional orchestration evidence. Standalone execution keeps its prior path.
write_world1_step_receipt() {
  python3 - "$SHARKY_WORLD1_STEP_RECEIPT" "$SHARKY_WORLD1_STEP_TOKEN" "$1" "$2" <<'PY_RECEIPT'
import json, os, pathlib, sys, tempfile
path = pathlib.Path(sys.argv[1])
previous = json.loads(path.read_text())
command = ["./tools/fast_loop_world1_v1.sh", "--force-tests", "--all-selected-guards"]
assert previous.get("schema") == 1 and previous.get("token") == sys.argv[2]
assert previous.get("cmd") == command
state = sys.argv[3]
assert (state == "STARTED" and previous.get("state") == "NOT_EXECUTED") or (
    state in ("PASS", "FAIL", "SKIPPED") and previous.get("state") == "STARTED")
value = dict(previous, state=state, exit_code=None if sys.argv[4] == "none" else int(sys.argv[4]))
fd, temporary = tempfile.mkstemp(prefix="receipt-", dir=path.parent)
try:
    with os.fdopen(fd, "w") as stream:
        json.dump(value, stream)
    os.replace(temporary, path)
finally:
    if os.path.exists(temporary):
        os.unlink(temporary)
PY_RECEIPT
}

if [[ -n "${SHARKY_WORLD1_STEP_RECEIPT:-}" || -n "${SHARKY_WORLD1_STEP_TOKEN:-}" ]]; then
  [[ -n "${SHARKY_WORLD1_STEP_RECEIPT:-}" && -n "${SHARKY_WORLD1_STEP_TOKEN:-}" ]]
  write_world1_step_receipt STARTED none
  if SHARKY_CONTENT_OWNER_V1=release-gate-full-validation-complete ./tools/fast_loop_world1_v1.sh --force-tests --all-selected-guards; then
    if [[ "${FAST_LOOP_ALREADY_RAN:-0}" == "1" ]]; then
      write_world1_step_receipt SKIPPED 0
    else
      write_world1_step_receipt PASS 0
    fi
  else
    fast_loop_rc=$?
    # Never replace the child failure with a receipt-writer failure.
    write_world1_step_receipt FAIL "$fast_loop_rc" || true
    exit "$fast_loop_rc"
  fi
else
  SHARKY_CONTENT_OWNER_V1=release-gate-full-validation-complete ./tools/fast_loop_world1_v1.sh --force-tests --all-selected-guards
fi





if [[ "$SHARKY_CHANGE_SCOPE_V1" == "full-scope" ]] || grep -Eq '^(l10n\.yaml|lib/l10n/.*\.arb)$' <<< "$changed_files"; then
  echo "[gate] 5/5 l10n changed -> flutter gen-l10n"
  flutter gen-l10n
else
  echo "[gate] 5/5 l10n unchanged -> skip gen-l10n"
fi

if [[ "$TEST_POLICY_FULL_SUITE_V1" == "1" ]]; then
  echo "[gate] checkpoint full-suite -> flutter test -r expanded"
  # A SIGINT can make Flutter's test runner exit 0 after failed tests without
  # the terminal success marker. Never count an incomplete run as checkpoint PASS.
  mkdir -p build/test_authority
  full_suite_log="$(mktemp "$ROOT/build/test_authority/world1_full_suite.XXXXXXXX")"
  if flutter test -r expanded 2>&1 | tee "$full_suite_log"; then
    full_suite_exit=0
  else
    full_suite_exit=$?
  fi

  if [[ "$full_suite_exit" -ne 0 ]]; then
    echo "[gate] FAIL full-suite command exit=$full_suite_exit; log=$full_suite_log" >&2
    exit "$full_suite_exit"
  fi
  if ! tail -n 1 "$full_suite_log" | grep -Eq '^[0-9]{2}:[0-9]{2} \+[0-9]+( ~[0-9]+)?: All tests passed!$'; then
    echo "[gate] FAIL full-suite terminal PASS receipt missing (possibly interrupted); log=$full_suite_log" >&2
    exit 1
  fi
  if grep -Eq '\[E\]|^[0-9]{2}:[0-9]{2} \+[0-9]+( ~[0-9]+)? -[1-9][0-9]*:' "$full_suite_log"; then
    echo "[gate] FAIL full-suite failures present despite command exit 0; log=$full_suite_log" >&2
    exit 1
  fi
  echo "[gate] checkpoint full-suite verified COMPLETE; raw_log=$full_suite_log"
fi

echo "[gate] World1 release gate passed."
