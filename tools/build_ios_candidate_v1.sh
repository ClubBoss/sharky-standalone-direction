#!/usr/bin/env bash
# Unsigned preparation only. Never an installable or TestFlight-ready RC.
set -euo pipefail
cd "$(dirname "$0")/.."
candidate_number="${1:-1}"
if [[ ! "$candidate_number" =~ ^[1-9][0-9]*$ ]]; then
  echo 'Usage: tools/build_ios_candidate_v1.sh [positive build number]' >&2
  exit 2
fi
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo 'Commit tracked changes before building a reproducible candidate.' >&2
  exit 2
fi
candidate_sha="$(git rev-parse HEAD)"
candidate_out="output/ios-candidate-${candidate_sha:0:8}-${candidate_number}"
mkdir -p "$candidate_out"
candidate_out="$(mktemp -d "$candidate_out/run.XXXXXX")"
flutter --version --machine > "$candidate_out/flutter.json"
xcodebuild -version > "$candidate_out/xcode.txt"
flutter pub get --enforce-lockfile > "$candidate_out/dependencies.log" 2>&1
flutter build ios --release --no-codesign --no-pub --target=lib/main.dart \
  --build-number="$candidate_number" > "$candidate_out/build.log" 2>&1
python3 - "$candidate_out" "$candidate_sha" "$candidate_number" <<'PY'
import hashlib, json, pathlib, plistlib, sys
out, sha, number = sys.argv[1:]
root = pathlib.Path.cwd()
app = root / 'build/ios/iphoneos/Runner.app'
p = plistlib.loads((app / 'Info.plist').read_bytes())
assert p['UIDeviceFamily'] == [1], 'Candidate must target iPhone only'
assert p['CFBundleLocalizations'] == ['en'], 'Candidate must declare English only'
assert p['UISupportedInterfaceOrientations'] == ['UIInterfaceOrientationPortrait']
assert p['CFBundleVersion'] == number
metadata = {
    'classification': 'UNSIGNED_DEVICE_BUILD_NOT_RC',
    'source_commit': sha, 'build_number': number,
    'bundle_id': p['CFBundleIdentifier'], 'version': p['CFBundleShortVersionString'],
    'device_family': p['UIDeviceFamily'], 'localizations': p['CFBundleLocalizations'],
    'orientations': p['UISupportedInterfaceOrientations'],
    'input_sha256': {f: hashlib.sha256((root/f).read_bytes()).hexdigest()
                     for f in ['pubspec.yaml', 'pubspec.lock', 'ios/Podfile.lock']},
    'runtime_performance': 'NOT_MEASURED_ON_SIGNED_DEVICE_BUILD',
}
pathlib.Path(out, 'candidate.json').write_text(json.dumps(metadata, indent=2)+'\n')
print(json.dumps(metadata, indent=2))
PY
# Preserve this device build before a later simulator build replaces build/ios.
ditto build/ios/iphoneos/Runner.app "$candidate_out/Runner.app"
printf 'Unsigned candidate: %s\n' "$candidate_out"
