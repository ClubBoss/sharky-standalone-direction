#!/usr/bin/env bash
set -euo pipefail

transport_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
product_root="${1:?usage: run_hnp_native_preflight_v1.sh <exact-product-checkout> [output-dir]}"
product_root="$(cd "$product_root" && pwd)"
out="${2:-$transport_root/output/hnp_native_preflight_v1}"
mkdir -p "$out"
out="$(cd "$out" && pwd)"

bundle_id='com.example.pokerAnalyzer'
expected_sha="${EXPECTED_PRODUCT_SHA:-}"

cd "$product_root"
actual_sha="$(git rev-parse HEAD)"
if [[ -n "$expected_sha" && "$actual_sha" != "$expected_sha" ]]; then
  echo "exact product SHA mismatch: expected=$expected_sha actual=$actual_sha" >&2
  exit 10
fi
printf '%s\n' "$actual_sha" > "$out/product_sha.txt"
git status --short --branch > "$out/product_git_status_before.txt"

flutter pub get 2>&1 | tee "$out/flutter_pub_get.log"

# Prove the operator materialization payload before paying the native build cost.
# The emitter imports Flutter-backed current product state, so run it with the
# Flutter test engine rather than a bare Dart VM (which has no dart:ui).
HNP_PROFILE_B_OUTPUT="$out/profile_b_progress.json" \
  flutter test "$transport_root/tools/emit_hnp_profile_b_progress_v1.dart" \
  --reporter expanded 2>&1 | tee "$out/profile_b_emitter.log"
progress_json="$(tr -d '\n' < "$out/profile_b_progress.json")"

flutter build ios --simulator --debug --dart-define=HNP_TELEMETRY=true 2>&1 | tee "$out/flutter_build_ios.log"
runner="$product_root/build/ios/iphonesimulator/Runner.app"
[[ -d "$runner" ]] || { echo "Runner.app missing: $runner" >&2; exit 11; }
runner_bundle="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$runner/Info.plist")"
[[ "$runner_bundle" == "$bundle_id" ]] || { echo "unexpected bundle id: $runner_bundle" >&2; exit 12; }
shasum -a 256 "$runner/Runner" > "$out/runner_sha256.txt"

# Resolve a real available iPhone by UDID. Human-readable SIM_NAME is evidence
# only and is never interpolated into an xcrun target argument; this avoids the
# historical transport/quoting failure without changing product behavior.
xcrun simctl list devices available -j > "$out/simulators.json"
python3 - "$out/simulators.json" "$out/simulator_selected.json" <<'PY'
import json, sys
src, dst = sys.argv[1:]
payload = json.load(open(src))
preferred = ('iPhone 16 Pro', 'iPhone 17 Pro', 'iPhone 15 Pro', 'iPhone 16', 'iPhone 15')
candidates = []
for runtime, devices in payload.get('devices', {}).items():
    for d in devices:
        if d.get('isAvailable') and str(d.get('name', '')).startswith('iPhone'):
            candidates.append((runtime, d))
for wanted in preferred:
    for runtime, d in candidates:
        if d.get('name') == wanted:
            json.dump({'udid': d['udid'], 'name': d['name'], 'runtime': runtime}, open(dst, 'w'), indent=2)
            open(dst, 'a').write('\n')
            raise SystemExit(0)
if candidates:
    runtime, d = candidates[0]
    json.dump({'udid': d['udid'], 'name': d['name'], 'runtime': runtime}, open(dst, 'w'), indent=2)
    open(dst, 'a').write('\n')
    raise SystemExit(0)
raise SystemExit('no available iPhone Simulator')
PY
sim_udid="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["udid"])' "$out/simulator_selected.json")"

xcrun simctl help > "$out/simctl_help.txt" 2>&1 || true
xcrun simctl io help > "$out/simctl_io_help.txt" 2>&1 || true
xcrun simctl ui help > "$out/simctl_ui_help.txt" 2>&1 || true
xcrun simctl boot "$sim_udid" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$sim_udid" -b 2>&1 | tee "$out/simulator_bootstatus.log"

clean_install() {
  xcrun simctl terminate "$sim_udid" "$bundle_id" >/dev/null 2>&1 || true
  xcrun simctl uninstall "$sim_udid" "$bundle_id" >/dev/null 2>&1 || true
  if xcrun simctl get_app_container "$sim_udid" "$bundle_id" data >/dev/null 2>&1; then
    echo 'old app data container survived uninstall' >&2
    return 20
  fi
  xcrun simctl install "$sim_udid" "$runner"
}

# Profile A: exact HNP-enabled Runner, genuinely clean installed container.
clean_install
profile_a_launch="$(xcrun simctl launch "$sim_udid" "$bundle_id")"
printf '%s\n' "$profile_a_launch" > "$out/profile_a_launch.txt"
sleep 4
xcrun simctl io "$sim_udid" screenshot "$out/profile_a_launch.png"
profile_a_container="$(xcrun simctl get_app_container "$sim_udid" "$bundle_id" data)"
printf '%s\n' "$profile_a_container" > "$out/profile_a_container.txt"
[[ -d "$profile_a_container" ]] || { echo 'Profile A data container missing after launch' >&2; exit 21; }
xcrun simctl terminate "$sim_udid" "$bundle_id" >/dev/null 2>&1 || true

# Profile B starts from a second clean install. Materialize only the already-
# canonical production-equivalent persistence fixture, before normal bootstrap.
clean_install
profile_b_container="$(xcrun simctl get_app_container "$sim_udid" "$bundle_id" data)"
printf '%s\n' "$profile_b_container" > "$out/profile_b_container.txt"

# SharedPreferences on Apple is NSUserDefaults-backed. Write the same production
# domain/keys through the booted Simulator's defaults tool so cfprefsd owns the
# materialization; do not inject widget state, routes, answers, or debug flags.
xcrun simctl spawn "$sim_udid" defaults write "$bundle_id" flutter.intake_completed_v1 -bool true
xcrun simctl spawn "$sim_udid" defaults write "$bundle_id" flutter.act0_welcome_completed_v1 -bool true
xcrun simctl spawn "$sim_udid" defaults write "$bundle_id" flutter.act0_shell_progress_v1 -string "$progress_json"
xcrun simctl spawn "$sim_udid" defaults export "$bundle_id" - > "$out/profile_b_preferences_before_launch.plist"

profile_b_launch="$(xcrun simctl launch "$sim_udid" "$bundle_id")"
printf '%s\n' "$profile_b_launch" > "$out/profile_b_launch.txt"
sleep 5
xcrun simctl io "$sim_udid" screenshot "$out/profile_b_bootstrap.png"
xcrun simctl spawn "$sim_udid" defaults export "$bundle_id" - > "$out/profile_b_preferences_after_launch.plist"

python3 - "$out/profile_b_preferences_after_launch.plist" "$out/profile_b_validation.json" <<'PY'
import json, plistlib, sys
plist_path, out_path = sys.argv[1:]
with open(plist_path, 'rb') as fh:
    prefs = plistlib.load(fh)
required = ['flutter.intake_completed_v1', 'flutter.act0_welcome_completed_v1', 'flutter.act0_shell_progress_v1']
missing = [key for key in required if key not in prefs]
if missing:
    raise SystemExit(f'missing persisted keys after bootstrap: {missing}')
progress = json.loads(prefs['flutter.act0_shell_progress_v1'])
lessons = progress.get('completedLessonIds', [])
tasks = progress.get('completedTaskIds', [])
verdict = {
    'intakeCompleted': prefs['flutter.intake_completed_v1'] is True,
    'welcomeCompleted': prefs['flutter.act0_welcome_completed_v1'] is True,
    'schemaVersion': progress.get('schemaVersion'),
    'completedLessonCount': len(lessons),
    'completedTaskCount': len(tasks),
    'selectedWorldId': progress.get('selectedWorldId'),
    'selectedLessonId': progress.get('selectedLessonId'),
    'selectedTaskId': progress.get('selectedTaskId'),
}
json.dump(verdict, open(out_path, 'w'), indent=2)
open(out_path, 'a').write('\n')
assert verdict['intakeCompleted'] and verdict['welcomeCompleted']
assert verdict['completedLessonCount'] == 4, verdict
assert verdict['completedTaskCount'] == 28, verdict
assert verdict['selectedWorldId'] == 'world_1', verdict
assert verdict['selectedLessonId'] == 'fold_check_call_raise', verdict
assert verdict['selectedTaskId'] == 'actions_theory', verdict
PY

trace="$profile_b_container/Library/Application Support/act0_hnp_trace_v1.jsonl"
if [[ -f "$trace" ]]; then
  cp "$trace" "$out/profile_b_bootstrap_hnp_trace.jsonl"
  python3 - "$trace" "$out/profile_b_bootstrap_trace_validation.json" <<'PY'
import json, pathlib, sys
src, dst = sys.argv[1:]
data = pathlib.Path(src).read_bytes()
lines = data.splitlines()
for line in lines:
    json.loads(line)
result = {'exists': True, 'events': len(lines), 'newlineTerminated': data.endswith(b'\n')}
pathlib.Path(dst).write_text(json.dumps(result, indent=2) + '\n')
PY
else
  printf '%s\n' '{"exists":false,"events":0}' > "$out/profile_b_bootstrap_trace_validation.json"
fi

xcrun simctl terminate "$sim_udid" "$bundle_id" >/dev/null 2>&1 || true

git status --short --branch > "$out/product_git_status_after.txt"
python3 - "$out" <<'PY'
import hashlib, json, pathlib, sys
root = pathlib.Path(sys.argv[1])
files = []
for path in sorted(p for p in root.rglob('*') if p.is_file()):
    files.append({'path': str(path.relative_to(root)), 'sha256': hashlib.sha256(path.read_bytes()).hexdigest(), 'bytes': path.stat().st_size})
(root / 'manifest.json').write_text(json.dumps({'schema': 'sharky_hnp_native_preflight_v1', 'files': files}, indent=2) + '\n')
PY

echo 'PASS HNP native preflight: exact Runner clean Profile A launch + canonical Profile B persistence bootstrap'
