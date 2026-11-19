#!/usr/bin/env bash
# P1: measure response, frames and memory of the profile build on a real iPhone.
#
#   SHARKY_BUNDLE_ID=com.<you>.sharky.dev SHARKY_TEAM=<Team ID> \
#     tools/p1/run_p1_on_iphone.sh <device id> [last world, default 4]
#
# Device id: `xcrun xctrace list devices`. Free Personal Team signing is enough
# (docs/RELEASE.md). integration_test and flutter_driver are added only for the
# run and removed afterwards, so they never reach the release build. The run
# clears this build's saved progress on the phone. Report: build/p1_perf_report.json.
set -euo pipefail
cd "$(dirname "$0")/../.."
device="${1:?device id}"
last_world="${2:-4}"
: "${SHARKY_BUNDLE_ID:?set SHARKY_BUNDLE_ID}" "${SHARKY_TEAM:?set SHARKY_TEAM}"

restore() {
  git checkout -- pubspec.yaml pubspec.lock ios/Podfile.lock ios/Flutter/AppIdentity.xcconfig
  flutter pub get >/dev/null
}
trap restore EXIT

python3 - <<'PY'
import pathlib
p = pathlib.Path('pubspec.yaml')
s = p.read_text()
anchor = 'dev_dependencies:\n'
add = '  integration_test:\n    sdk: flutter\n  flutter_driver:\n    sdk: flutter\n'
assert anchor in s
p.write_text(s.replace(anchor, anchor + add, 1))
PY
printf 'SHARKY_BUNDLE_ID = %s\nDEVELOPMENT_TEAM = %s\n' "$SHARKY_BUNDLE_ID" "$SHARKY_TEAM" \
  > ios/Flutter/AppIdentity.xcconfig
flutter pub get >/dev/null

flutter drive --profile -d "$device" \
  --dart-define=P1_LAST_WORLD="$last_world" \
  --driver=tools/p1/act0_p1_perf_driver.dart \
  --target=tools/p1/act0_p1_device_perf_test.dart
echo "Report: build/p1_perf_report.json"
