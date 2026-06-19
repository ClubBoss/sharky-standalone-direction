#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/output/playwright/first_week_compact_capture_v1}"
APP_URL="${ACT0_CAPTURE_URL:-http://127.0.0.1:7357/}"
CAPTURE_HOST="${ACT0_CAPTURE_HOST:-127.0.0.1}"
CAPTURE_PORT="${ACT0_CAPTURE_PORT:-7357}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
PWCLI="$CODEX_HOME/skills/playwright/scripts/playwright_cli.sh"
SESSION_ID="fw$(date +%s)"
SERVER_LOG="$OUTPUT_DIR/flutter-web-server.log"
MANIFEST_FILE="$OUTPUT_DIR/manifest.json"
FLOW_ERROR_FILE="$OUTPUT_DIR/flow_error.txt"
PLAYWRIGHT_CONFIG_FILE="$OUTPUT_DIR/playwright-cli.json"
SURFACE_SCRIPT_FILE="$OUTPUT_DIR/.capture_surface.js"
ENTRY_JSONL_FILE="$OUTPUT_DIR/.manifest_entries.jsonl"
VIEWPORT_NAME="compact_phone"
VIEWPORT_WIDTH=393
VIEWPORT_HEIGHT=852
STARTED_SERVER=0
SERVER_PID=""

declare -a SURFACE_SPECS=(
  "home_first_week:direct_state:?act0_capture=first_week_home"
  "review_open_repair:direct_state:?act0_capture=first_week_review"
  "learn_first_week_path:direct_state:?act0_capture=first_week_learn"
  "profile_return_rhythm:direct_state:?act0_capture=first_week_profile"
)

log() {
  printf '[first-week-compact-capture] %s\n' "$1"
}

fail() {
  printf '[first-week-compact-capture] ERROR: %s\n' "$1" >&2
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
  pw close >/dev/null 2>&1 || true
  pw open about:blank --config "$PLAYWRIGHT_CONFIG_FILE" >/dev/null
  pw run-code "async page => {
    await page.setViewportSize({
      width: ${VIEWPORT_WIDTH},
      height: ${VIEWPORT_HEIGHT},
    });
    return JSON.stringify({ ok: true });
  }" --raw >/dev/null
  pw localstorage-set flutter.app_language_code '"en"' >/dev/null
}

expected_text_for_surface() {
  case "$1" in
    home_first_week) printf '%s' 'Week 1: build table-reading habits' ;;
    review_open_repair) printf '%s' 'Week 1 repair' ;;
    learn_first_week_path) printf '%s' 'Your first week is about seeing the table before choosing.' ;;
    profile_return_rhythm) printf '%s' 'Week 1: each short return keeps one table clue warm.' ;;
    *) fail "Unknown surface $1" ;;
  esac
}

screenshot_file_for_surface() {
  case "$1" in
    home_first_week) printf '%s' 'first_week_home_compact.png' ;;
    review_open_repair) printf '%s' 'first_week_review_open_repair_compact.png' ;;
    learn_first_week_path) printf '%s' 'first_week_learn_compact.png' ;;
    profile_return_rhythm) printf '%s' 'first_week_profile_compact.png' ;;
    *) fail "Unknown surface $1" ;;
  esac
}

write_surface_probe_script() {
  local surface_name="$1"
  local surface_mode="$2"
  local surface_url="$3"
  local expected_text="$4"

  cat >"$SURFACE_SCRIPT_FILE" <<EOF
async page => {
  const surfaceName = $(json_quote "$surface_name");
  const surfaceMode = $(json_quote "$surface_mode");
  const surfaceUrl = $(json_quote "$surface_url");
  const expectedText = $(json_quote "$expected_text");
  let lastNavigationError = '';
  for (let attempt = 0; attempt < 4; attempt += 1) {
    try {
      await page.goto(surfaceUrl, { waitUntil: 'domcontentloaded' });
      lastNavigationError = '';
      break;
    } catch (error) {
      lastNavigationError = String(error && error.message ? error.message : error);
      await page.waitForTimeout(700);
    }
  }
  if (lastNavigationError) {
    throw new Error('Navigation failed after retries: ' + lastNavigationError);
  }
  await page.waitForLoadState('networkidle').catch(() => {});
  await page.waitForTimeout(1200);

  const gate = page.locator(
    'flt-semantics-placeholder[aria-label="Enable accessibility"]',
  );
  if (await gate.count()) {
    await gate.evaluate(element => element.click());
    await page.waitForTimeout(900);
  }

  await page.mouse.move(196, 426).catch(() => {});
  if (surfaceName === 'review_open_repair') {
    await page.mouse.wheel(0, 680);
    await page.waitForTimeout(500);
  } else if (surfaceName === 'profile_return_rhythm') {
    await page.mouse.wheel(0, 280);
    await page.waitForTimeout(500);
  }

  const bodyText = (await page.locator('body').innerText().catch(() => ''))
    .replace(/\\s+/g, ' ')
    .trim();

  return JSON.stringify({
    surface: surfaceName,
    mode: surfaceMode,
    url: surfaceUrl,
    viewport: 'compact_phone',
    viewportWidth: ${VIEWPORT_WIDTH},
    viewportHeight: ${VIEWPORT_HEIGHT},
    expectedText,
    expectedTextVisible: bodyText.includes(expectedText),
    excerpt: bodyText.slice(0, 260),
    bodyTextLength: bodyText.length,
    blank: bodyText.length === 0,
  });
}
EOF
}

record_surface_entry() {
  local surface_name="$1"
  local surface_mode="$2"
  local surface_query="$3"
  local surface_url="${APP_URL}${surface_query}"
  local expected_text
  expected_text="$(expected_text_for_surface "$surface_name")"
  local png_file_name
  png_file_name="$(screenshot_file_for_surface "$surface_name")"
  local png_path="$OUTPUT_DIR/$png_file_name"
  local decoded_probe_file="$OUTPUT_DIR/.entry.${VIEWPORT_NAME}.${surface_name}.json"
  local probe_json_quoted

  write_surface_probe_script \
    "$surface_name" \
    "$surface_mode" \
    "$surface_url" \
    "$expected_text"

  set +e
  probe_json_quoted="$(pw_raw run-code --filename "$(basename "$SURFACE_SCRIPT_FILE")" 2>&1)"
  local capture_status=$?
  set -e

  if [[ $capture_status -ne 0 ]]; then
    printf '%s\n' "$probe_json_quoted" >"$FLOW_ERROR_FILE"
    fail "Capture probe failed for ${VIEWPORT_NAME}/${surface_name}. See $FLOW_ERROR_FILE"
  fi

  if ! decode_pw_json_string "$probe_json_quoted" >"$decoded_probe_file"; then
    printf '%s\n' "$probe_json_quoted" >"$FLOW_ERROR_FILE"
    fail "Capture probe returned non-JSON output for ${VIEWPORT_NAME}/${surface_name}. See $FLOW_ERROR_FILE"
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
entry.semanticExpectedTextVisible = entry.expectedTextVisible;
entry.captured = Boolean(!entry.blank && entry.visualNonBlank && bytes > 0);
if (!entry.expectedTextVisible) {
  entry.proofWarning = 'Expected text was not available through body semantics; inspect screenshot visually.';
}
if (entry.blank || !entry.visualNonBlank) {
  entry.failureReason = 'Blank or tiny screenshot artifact';
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

const manifest = {
  generatedAt: new Date().toISOString(),
  lane_type: 'targeted_first_week_compact_capture',
  render_kind: 'active_route_browser',
  appUrl,
  artifact_dir: outputDir.replace(`${rootDir}/`, './'),
  startedFlutterServer,
  surfaces: entries.map(entry => entry.surface),
  viewports: [
    {
      id: 'compact_phone',
      width: 393,
      height: 852,
    },
  ],
  entries,
};

fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
NODE
}

main() {
  require_command curl
  require_command flutter
  require_command node
  [[ -x "$PWCLI" ]] || fail "Missing Playwright CLI at $PWCLI"

  rm -rf "$OUTPUT_DIR"
  mkdir -p "$OUTPUT_DIR"
  : >"$ENTRY_JSONL_FILE"

  ensure_server
  write_playwright_config
  open_browser_session

  for spec in "${SURFACE_SPECS[@]}"; do
    IFS=':' read -r surface_name surface_mode surface_query <<<"$spec"
    log "Capturing ${VIEWPORT_NAME}/${surface_name}"
    record_surface_entry "$surface_name" "$surface_mode" "$surface_query"
  done

  write_manifest

  node - "$MANIFEST_FILE" <<'NODE'
const fs = require('fs');
const manifest = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const failures = manifest.entries.filter(entry => !entry.captured);
if (failures.length > 0) {
  console.error(JSON.stringify(failures, null, 2));
  process.exit(1);
}
console.log(`Captured ${manifest.entries.length} compact first-week surfaces.`);
for (const entry of manifest.entries) {
  console.log(` - ${entry.file}`);
}
NODE
}

main "$@"
