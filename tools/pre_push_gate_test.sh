#!/usr/bin/env bash
set -euo pipefail

gate="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/pre_push_gate.sh"
fixture="$(mktemp -d "$(dirname "$gate")/.pre_push_gate_test.XXXXXX")"
trap 'rm -rf "$fixture"' EXIT
cd "$fixture"

git init -q
git -c user.name=Fixture -c user.email=fixture@example.test commit -qm base --allow-empty
git update-ref refs/remotes/origin/main HEAD
mkdir -p bin lib/features 'test/with spaces'
printf 'name: fixture\n' > pubspec.yaml
touch lib/features/stem.dart lib/features/imported.dart lib/features/unmapped.dart
touch 'test/with spaces/stem_test.dart'
cat > test/package_import_test.dart <<'DART'
import 'package:fixture/features/imported.dart';
import 'package:fixture/features/stem.dart';
DART
cat > test/relative_import_test.dart <<'DART'
import "../lib/features/imported.dart";
DART
cat > test/unrelated_test.dart <<'DART'
// import 'package:fixture/features/unmapped.dart';
const example = 'package:fixture/features/unmapped.dart';
DART

cat > bin/dart <<'SH'
#!/usr/bin/env bash
case "$1" in
  format) exit "${FORMAT_RESULT:-0}" ;;
  analyze) exit "${ANALYZE_RESULT:-0}" ;;
  *) exit 99 ;;
esac
SH
chmod +x bin/dart
export PATH="$fixture/bin:$PATH"

# Keep the test files unchanged so the assertions exercise mapping alone.
git add pubspec.yaml test
git -c user.name=Fixture -c user.email=fixture@example.test commit -qm tests
git update-ref refs/remotes/origin/main HEAD
git add lib/features/stem.dart lib/features/imported.dart

output="$("$gate" --sandbox)"
expected="flutter test test/package_import_test.dart test/relative_import_test.dart 'test/with spaces/stem_test.dart'"
[[ "$(grep '^flutter test ' <<< "$output")" == "$expected" ]]
[[ "$(grep '^WARNING ' <<< "$output")" == 'WARNING [4] No mapped test for lib/features/unmapped.dart' ]]
grep -Fxq 'tests left to the tick' <<< "$output"

# Verify that either Dart check can stop the gate before mapping.
status=0
FORMAT_RESULT=7 "$gate" --sandbox > /dev/null || status=$?
[[ "$status" == 1 ]]
status=0
ANALYZE_RESULT=7 "$gate" HEAD --sandbox > /dev/null || status=$?
[[ "$status" == 2 ]]

echo 'Pre-push gate fixture passed.'
