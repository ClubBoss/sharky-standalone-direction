#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/output/playwright/controlled_demo}"
APP_URL="${ACT0_CAPTURE_URL:-http://127.0.0.1:7357/}"
CAPTURE_HOST="${ACT0_CAPTURE_HOST:-127.0.0.1}"
CAPTURE_PORT="${ACT0_CAPTURE_PORT:-7357}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
PWCLI="$CODEX_HOME/skills/playwright/scripts/playwright_cli.sh"
SESSION_ID="cd$(date +%s)"
SERVER_LOG="$OUTPUT_DIR/flutter-web-server.log"
MANIFEST_FILE="$OUTPUT_DIR/manifest.json"
FLOW_ERROR_FILE="$OUTPUT_DIR/flow_error.txt"
PLAYWRIGHT_CONFIG_FILE="$OUTPUT_DIR/playwright-cli.json"
ENTRY_JSONL_FILE="$OUTPUT_DIR/.manifest_entries.jsonl"
SURFACE_SCRIPT_FILE="$OUTPUT_DIR/.capture_surface.js"
STARTED_SERVER=0
SERVER_PID=""

declare -a VIEWPORT_SPECS=(
  "compact_phone:393:852"
  "large_phone:430:932"
  "tablet:834:1194"
)

declare -a SURFACE_SPECS=(
  "placement:walkthrough:?act0_capture=placement"
  "welcome:walkthrough:?act0_capture=welcome"
  "home:walkthrough:?act0_capture=home"
  "learn:walkthrough:?act0_capture=learn"
  "runner_theory:direct_state:?act0_capture=runner_theory"
  "runner_drill:direct_state:?act0_capture=runner_drill"
  "runner_feedback_or_review:direct_state:?act0_capture=runner_feedback"
  "review:direct_state:?act0_capture=review"
  "practice:direct_state:?act0_capture=practice"
  "profile:direct_state:?act0_capture=profile"
  "world_completion:direct_state:?act0_capture=world_completion"
)

log() {
  printf '[controlled-demo-capture] %s\n' "$1"
}

fail() {
  printf '[controlled-demo-capture] ERROR: %s\n' "$1" >&2
  exit 1
}

cleanup() {
  (
    cd "$OUTPUT_DIR" 2>/dev/null || exit 0
    PLAYWRIGHT_CLI_SESSION="$SESSION_ID" "$PWCLI" close >/dev/null 2>&1 || true
  )
  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    log "Stopping Flutter web server pid=$SERVER_PID"
    kill "$SERVER_PID" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

pw() {
  (
    cd "$OUTPUT_DIR"
    PLAYWRIGHT_CLI_SESSION="$SESSION_ID" "$PWCLI" "$@"
  )
}

pw_raw() {
  (
    cd "$OUTPUT_DIR"
    PLAYWRIGHT_CLI_SESSION="$SESSION_ID" "$PWCLI" "$@" --raw
  )
}

json_quote() {
  node -e 'process.stdout.write(JSON.stringify(process.argv[1]));' "$1"
}

decode_pw_json_string() {
  node -e '
const value = JSON.parse(process.argv[1]);
process.stdout.write(
  typeof value === "string" ? value : JSON.stringify(value),
);
' "$1"
}

ensure_server() {
  if curl -sS --max-time 5 "$APP_URL" >/dev/null 2>&1; then
    log "Using existing Flutter web server at $APP_URL"
    return
  fi

  log "Starting Flutter web server at $APP_URL"
  : >"$SERVER_LOG"
  (
    cd "$ROOT_DIR"
    flutter run -d web-server \
      --web-hostname "$CAPTURE_HOST" \
      --web-port "$CAPTURE_PORT"
  ) >"$SERVER_LOG" 2>&1 &
  SERVER_PID=$!
  STARTED_SERVER=1

  for _ in $(seq 1 90); do
    if curl -sS --max-time 5 "$APP_URL" >/dev/null 2>&1; then
      log "Flutter web server is ready"
      return
    fi
    sleep 1
  done

  tail -n 80 "$SERVER_LOG" >&2 || true
  fail "Flutter web server did not become ready at $APP_URL"
}

write_playwright_config() {
  cat >"$PLAYWRIGHT_CONFIG_FILE" <<'EOF'
{
  "browser": {
    "launchOptions": {
      "headless": true
    },
    "contextOptions": {
      "deviceScaleFactor": 1,
      "locale": "en-US"
    }
  }
}
EOF
}

open_browser_session() {
  local viewport_width="$1"
  local viewport_height="$2"
  pw close >/dev/null 2>&1 || true
  pw open "$APP_URL" --config "$PLAYWRIGHT_CONFIG_FILE" >/dev/null
  pw run-code "async page => {
    await page.setViewportSize({ width: ${viewport_width}, height: ${viewport_height} });
    return JSON.stringify({ ok: true, width: ${viewport_width}, height: ${viewport_height} });
  }" --raw >/dev/null
  pw localstorage-set flutter.app_language_code '"en"' >/dev/null
  pw reload >/dev/null
}

capture_viewport_snapshot() {
  local viewport_name="$1"
  local viewport_width="$2"
  local viewport_height="$3"
  local viewport_file="$OUTPUT_DIR/.viewport_${viewport_name}.json"
  local viewport_json_quoted

  viewport_json_quoted="$(
    pw_raw eval "({
      href: location.href,
      innerWidth: window.innerWidth,
      innerHeight: window.innerHeight,
      outerWidth: window.outerWidth,
      outerHeight: window.outerHeight,
      language: navigator.language,
      storedLanguage: localStorage.getItem('flutter.app_language_code'),
    })"
  )"
  decode_pw_json_string "$viewport_json_quoted" >"$viewport_file"

  node -e '
const fs = require("fs");
const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
if (data.innerWidth !== Number(process.argv[2]) || data.innerHeight !== Number(process.argv[3])) {
  console.error(JSON.stringify(data, null, 2));
  process.exit(1);
}
' "$viewport_file" "$viewport_width" "$viewport_height" \
    || fail "Viewport ${viewport_name} was not ${viewport_width}x${viewport_height}"
}

write_surface_probe_script() {
  local viewport_name="$1"
  local viewport_width="$2"
  local viewport_height="$3"
  local surface_name="$4"
  local surface_mode="$5"
  local surface_url="$6"

  cat >"$SURFACE_SCRIPT_FILE" <<EOF
async page => {
  const surfaceName = $(json_quote "$surface_name");
  const surfaceMode = $(json_quote "$surface_mode");
  const surfaceUrl = $(json_quote "$surface_url");
  const viewportName = $(json_quote "$viewport_name");
  const viewportWidth = Number($(json_quote "$viewport_width"));
  const viewportHeight = Number($(json_quote "$viewport_height"));

  await page.goto(surfaceUrl, { waitUntil: 'domcontentloaded' });
  await page.waitForLoadState('networkidle').catch(() => {});
  await page.waitForTimeout(1200);

  const gate = page.locator(
    'flt-semantics-placeholder[aria-label="Enable accessibility"]',
  );
  if (await gate.count()) {
    await gate.evaluate(element => element.click());
    await page.waitForTimeout(900);
  }
  await page.waitForTimeout(700);

  const bodyText = (await page.locator('body').innerText().catch(() => ''))
    .replace(/\\s+/g, ' ')
    .trim();
  const buttonNames = (await page.getByRole('button').allTextContents().catch(() => []))
    .map(text => text.replace(/\\s+/g, ' ').trim())
    .filter(Boolean);

  return JSON.stringify({
    surface: surfaceName,
    mode: surfaceMode,
    url: surfaceUrl,
    viewport: viewportName,
    viewportWidth,
    viewportHeight,
    buttonCount: buttonNames.length,
    excerpt: bodyText.slice(0, 220),
    bodyTextLength: bodyText.length,
    gateVisible: /Enable accessibility/i.test(bodyText),
    blank: bodyText.length === 0,
    forbiddenLessonSequenceChrome:
      surfaceName === 'learn' && viewportName === 'compact_phone'
        ? /\\b\\d+\\s+Lesson\\s+\\d+\\s+(Done|Now|Next|Locked)\\b/.test(bodyText)
        : false,
  });
}
EOF
}

record_surface_entry() {
  local viewport_name="$1"
  local viewport_width="$2"
  local viewport_height="$3"
  local surface_name="$4"
  local surface_mode="$5"
  local surface_query="$6"
  local png_file_name="${viewport_name}.${surface_name}.png"
  local png_path="$OUTPUT_DIR/$png_file_name"
  local surface_url="${APP_URL}${surface_query}"
  local probe_json_quoted
  local decoded_probe_file="$OUTPUT_DIR/.entry.${viewport_name}.${surface_name}.json"

  write_surface_probe_script \
    "$viewport_name" \
    "$viewport_width" \
    "$viewport_height" \
    "$surface_name" \
    "$surface_mode" \
    "$surface_url"

  set +e
  probe_json_quoted="$(pw_raw run-code --filename "$(basename "$SURFACE_SCRIPT_FILE")" 2>&1)"
  local capture_status=$?
  set -e

  if [[ $capture_status -ne 0 ]]; then
    printf '%s\n' "$probe_json_quoted" >"$FLOW_ERROR_FILE"
    fail "Capture probe failed for ${viewport_name}/${surface_name}. See $FLOW_ERROR_FILE"
  fi

  if ! decode_pw_json_string "$probe_json_quoted" >"$decoded_probe_file"; then
    printf '%s\n' "$probe_json_quoted" >"$FLOW_ERROR_FILE"
    fail "Capture probe returned non-JSON output for ${viewport_name}/${surface_name}. See $FLOW_ERROR_FILE"
  fi

  pw screenshot --filename "$png_file_name" >/dev/null

  node - "$decoded_probe_file" "$png_path" "$ROOT_DIR" <<'NODE' >>"$ENTRY_JSONL_FILE"
const fs = require('fs');

const decodedProbeFile = process.argv[2];
const pngPath = process.argv[3];
const rootDir = process.argv[4];

const entry = JSON.parse(fs.readFileSync(decodedProbeFile, 'utf8'));
const bytes = fs.existsSync(pngPath) ? fs.statSync(pngPath).size : 0;
entry.file = pngPath.replace(`${rootDir}/`, './');
entry.screenshotBytes = bytes;
entry.visualNonBlank = bytes >= 12000;
entry.blankCheck = !entry.blank || entry.visualNonBlank;
entry.gatedCheck = !entry.gateVisible;
entry.captured = Boolean(
  entry.blankCheck &&
    entry.gatedCheck &&
    !entry.forbiddenLessonSequenceChrome &&
    bytes > 0,
);
if (!entry.blankCheck) {
  entry.failureReason = 'Blank surface';
} else if (entry.gateVisible) {
  entry.failureReason = 'Accessibility gate still visible';
} else if (entry.forbiddenLessonSequenceChrome) {
  entry.failureReason = 'Forbidden compact lesson sequence chrome visible';
}
process.stdout.write(`${JSON.stringify(entry)}\n`);
NODE
}

write_manifest() {
  node - "$ENTRY_JSONL_FILE" "$MANIFEST_FILE" "$OUTPUT_DIR" "$ROOT_DIR" "$APP_URL" "$STARTED_SERVER" <<'NODE'
const fs = require('fs');

const entryJsonlPath = process.argv[2];
const manifestPath = process.argv[3];
const outputDir = process.argv[4];
const rootDir = process.argv[5];
const appUrl = process.argv[6];
const startedFlutterServer = process.argv[7] === '1';

const entries = fs
  .readFileSync(entryJsonlPath, 'utf8')
  .split('\n')
  .map(line => line.trim())
  .filter(Boolean)
  .map(line => JSON.parse(line));

const surfaces = [...new Set(entries.map(entry => entry.surface))];
const viewports = [...new Map(
  entries.map(entry => [
    entry.viewport,
    {
      id: entry.viewport,
      width: entry.viewportWidth,
      height: entry.viewportHeight,
    },
  ]),
).values()];

const manifest = {
  generatedAt: new Date().toISOString(),
  lane_type: 'literal_browser',
  render_kind: 'active_route_browser',
  appUrl,
  artifact_dir: outputDir.replace(`${rootDir}/`, './'),
  startedFlutterServer,
  surfaces,
  viewports,
  entries,
  done_for_today_supported: false,
};

fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
NODE
}

assert_manifest_complete() {
  node - "$MANIFEST_FILE" <<'NODE'
const fs = require('fs');

const manifest = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const requiredSurfaces = [
  'placement',
  'welcome',
  'home',
  'learn',
  'runner_theory',
  'runner_drill',
  'runner_feedback_or_review',
  'review',
  'practice',
  'profile',
  'world_completion',
];
const requiredViewports = ['compact_phone', 'large_phone', 'tablet'];
const missing = [];

for (const viewport of requiredViewports) {
  for (const surface of requiredSurfaces) {
    const entry = manifest.entries.find(candidate =>
      candidate.viewport === viewport && candidate.surface === surface,
    );
    if (!entry || !entry.captured) {
      missing.push(`${viewport}/${surface}`);
    }
  }
}

if (missing.length > 0) {
  console.error(JSON.stringify({ missing }, null, 2));
  process.exit(1);
}
NODE
}

mkdir -p "$OUTPUT_DIR"
rm -f \
  "$OUTPUT_DIR"/*.png \
  "$OUTPUT_DIR"/.entry.*.json \
  "$OUTPUT_DIR"/.manifest_entries.jsonl \
  "$OUTPUT_DIR"/.capture_surface.js \
  "$FLOW_ERROR_FILE" \
  "$MANIFEST_FILE" \
  "$PLAYWRIGHT_CONFIG_FILE"

require_command curl
require_command flutter
require_command node
require_command npx
[[ -x "$PWCLI" ]] || fail "Playwright CLI wrapper not found at $PWCLI"

write_playwright_config
ensure_server
: >"$ENTRY_JSONL_FILE"

for viewport_spec in "${VIEWPORT_SPECS[@]}"; do
  IFS=':' read -r viewport_name viewport_width viewport_height <<<"$viewport_spec"
  open_browser_session "$viewport_width" "$viewport_height"
  capture_viewport_snapshot "$viewport_name" "$viewport_width" "$viewport_height"
  for surface_spec in "${SURFACE_SPECS[@]}"; do
    IFS=':' read -r surface_name surface_mode surface_query <<<"$surface_spec"
    record_surface_entry \
      "$viewport_name" \
      "$viewport_width" \
      "$viewport_height" \
      "$surface_name" \
      "$surface_mode" \
      "$surface_query"
  done
done

write_manifest
assert_manifest_complete || fail "Required controlled-demo browser captures are missing. See $MANIFEST_FILE"

pw close >/dev/null 2>&1 || true

log "Capture complete"
log "Manifest: $MANIFEST_FILE"
log "Artifacts: $OUTPUT_DIR"
