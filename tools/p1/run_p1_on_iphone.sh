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
# Simulator activation gate (requires cached SDK and pods):
#   tools/p1/run_p1_on_iphone.sh --simulator <reference simulator UDID>
set -euo pipefail
cd "$(dirname "$0")/../.."
simulator=false
if [[ "${1:-}" == --simulator ]]; then
  simulator=true
  shift
fi
device="${1:?device id}"
last_world="${2:-4}"
if $simulator; then
  SHARKY_BUNDLE_ID=com.example.sharky.b47gate
  SHARKY_TEAM=
  xcrun simctl list devices booted --json | python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
if not any(d["udid"] == sys.argv[1] and d["state"] == "Booted"
           for group in devices.values() for d in group):
    sys.exit("Provide the booted reference simulator UDID")
' "$device"
else
  : "${SHARKY_BUNDLE_ID:?set SHARKY_BUNDLE_ID}" "${SHARKY_TEAM:?set SHARKY_TEAM}"
fi
git diff HEAD --quiet -- pubspec.yaml pubspec.lock ios/Podfile.lock ios/Flutter/AppIdentity.xcconfig ||
  { echo "P1 setup files must be clean" >&2; exit 1; }

restore() {
  git checkout -- pubspec.yaml pubspec.lock ios/Podfile.lock ios/Flutter/AppIdentity.xcconfig
  flutter pub get --offline >/dev/null
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
flutter pub get --offline >/dev/null

if $simulator; then
  export COCOAPODS_DISABLE_STATS=true
  rm -f build/p1_first_decision_gate.json
  samples=()
  for run in 1 2 3 4 5; do
    if xcrun simctl get_app_container "$device" "$SHARKY_BUNDLE_ID" >/dev/null 2>&1; then
      xcrun simctl uninstall "$device" "$SHARKY_BUNDLE_ID"
    fi
    rm -f build/p1_perf_report.json
    flutter drive --debug --no-pub -d "$device" \
      --dart-define=P1_LAST_WORLD=1 --dart-define=P1_ACTIVATION_ONLY=true \
      --driver=tools/p1/act0_p1_perf_driver.dart \
      --target=tools/p1/act0_p1_device_perf_test.dart
    sample="$(python3 -c 'import json; print(json.load(open("build/p1_perf_report.json"))["first_w1_decision_ms"])')"
    echo "[F1] run $run: $sample ms"
    samples+=("$sample")
  done
  python3 tools/p1/first_decision_gate.py "${samples[@]}"
  exit
fi

flutter drive --profile --no-pub -d "$device" \
  --dart-define=P1_LAST_WORLD="$last_world" \
  --driver=tools/p1/act0_p1_perf_driver.dart \
  --target=tools/p1/act0_p1_device_perf_test.dart
echo "Report: build/p1_perf_report.json"
