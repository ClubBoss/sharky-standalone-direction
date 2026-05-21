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

test_policy_should_run_full_suite_v1 "$@"
test_policy_require_full_suite_enabled_v1

collect_changed_dart_files_v1() {
  {
    git diff --name-only HEAD
    git ls-files --others --exclude-standard
  } | sort -u | while IFS= read -r path; do
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

echo "[gate] 3/5 fast loop (tier checks)"
./tools/fast_loop_world1_v1.sh --force-tests

changed_files="$(git diff --name-only HEAD)"

if echo "$changed_files" | rg -q '^content/'; then
  echo "[gate] 4/5 content changed -> validate training content"
  dart run tools/validate_training_content.dart --ci
else
  echo "[gate] 4/5 content unchanged -> skip validation"
fi

if echo "$changed_files" | rg -q '^(l10n\.yaml|lib/l10n/.*\.arb)$'; then
  echo "[gate] 5/5 l10n changed -> flutter gen-l10n"
  flutter gen-l10n
else
  echo "[gate] 5/5 l10n unchanged -> skip gen-l10n"
fi

if [[ "$TEST_POLICY_FULL_SUITE_V1" == "1" ]]; then
  echo "[gate] checkpoint full-suite -> flutter test -r expanded"
  flutter test -r expanded
fi

echo "[gate] World1 release gate passed."
