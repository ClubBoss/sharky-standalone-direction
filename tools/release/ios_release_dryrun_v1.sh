#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/../.."
version=$(awk '/^version:[[:space:]]/ {print $2; exit}' pubspec.yaml)
version_pattern='^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$'
if [[ ! $version =~ $version_pattern ]]; then
  printf 'Expected version: x.y.z+build in pubspec.yaml\n' >&2
  exit 1
fi
printf 'Version: %s\nBuild number: %s\n' "${version%+*}" "${version##*+}"

# B89 guards the default-OFF release profile: no custom --dart-define flags.
unset DART_DEFINES FLUTTER_BUILD_MODE
flutter build ios --release --no-codesign

app=build/ios/iphoneos/Runner.app
python3 tools/release/check_release_profile_v1.py "$app/Info.plist" \
  --xcconfig ios/Flutter/Generated.xcconfig --version "$version"
size=$(du -sh "$app")
printf 'Unsigned app size: %s\n' "$size"
