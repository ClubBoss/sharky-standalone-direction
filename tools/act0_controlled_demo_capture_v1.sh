#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/output/playwright/controlled_demo}"
APP_URL="${ACT0_CAPTURE_URL:-http://127.0.0.1:7357/}"
VIEWPORT_WIDTH="${ACT0_CAPTURE_WIDTH:-393}"
VIEWPORT_HEIGHT="${ACT0_CAPTURE_HEIGHT:-852}"
CAPTURE_HOST="${ACT0_CAPTURE_HOST:-127.0.0.1}"
CAPTURE_PORT="${ACT0_CAPTURE_PORT:-7357}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
PWCLI="$CODEX_HOME/skills/playwright/scripts/playwright_cli.sh"
SESSION_ID="cd$(date +%s)"
SERVER_LOG="$OUTPUT_DIR/flutter-web-server.log"
VIEWPORT_JSON_FILE="$OUTPUT_DIR/viewport.json"
MANIFEST_FILE="$OUTPUT_DIR/manifest.json"
INITIAL_SNAPSHOT_FILE="$OUTPUT_DIR/initial_snapshot.txt"
STARTED_SERVER=0
SERVER_PID=""

log() {
  printf '[controlled-demo-capture] %s\n' "$1"
}

fail() {
  printf '[controlled-demo-capture] ERROR: %s\n' "$1" >&2
  exit 1
}

cleanup() {
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

mkdir -p "$OUTPUT_DIR"
rm -f \
  "$OUTPUT_DIR"/*.png \
  "$OUTPUT_DIR"/capture_surfaces.js \
  "$OUTPUT_DIR"/enable_accessibility.js \
  "$OUTPUT_DIR"/flow_error.txt \
  "$OUTPUT_DIR"/initial_snapshot.txt \
  "$OUTPUT_DIR"/manifest.json \
  "$OUTPUT_DIR"/playwright-cli.json \
  "$OUTPUT_DIR"/seed_english.js \
  "$OUTPUT_DIR"/viewport.json

require_command npx
require_command node
require_command flutter
require_command curl
[[ -x "$PWCLI" ]] || fail "Playwright CLI wrapper not found at $PWCLI"

cat >"$OUTPUT_DIR/playwright-cli.json" <<EOF
{
  "browser": {
    "launchOptions": {
      "headless": true
    },
    "contextOptions": {
      "viewport": { "width": $VIEWPORT_WIDTH, "height": $VIEWPORT_HEIGHT },
      "deviceScaleFactor": 1,
      "isMobile": true,
      "hasTouch": true,
      "locale": "en-US"
    }
  }
}
EOF

cat >"$OUTPUT_DIR/seed_english.js" <<'EOF'
async page => {
  await page.goto('about:blank');
  await page.goto('http://127.0.0.1:7357/', { waitUntil: 'domcontentloaded' });
  await page.waitForLoadState('networkidle').catch(() => {});
  await page.evaluate(() => {
    window.localStorage.setItem(
      'flutter.app_language_code',
      JSON.stringify('en'),
    );
  });
}
EOF

cat >"$OUTPUT_DIR/enable_accessibility.js" <<'EOF'
async page => {
  const gate = page.locator(
    'flt-semantics-placeholder[aria-label="Enable accessibility"]',
  );
  if (await gate.count()) {
    await gate.evaluate(element => element.click());
    await page.waitForTimeout(800);
  }
}
EOF

cat >"$OUTPUT_DIR/capture_surfaces.js" <<EOF
async page => {
  const outputDir = '.';
  const baseUrl = "$APP_URL";
  const viewportWidth = ${VIEWPORT_WIDTH};
  const viewportHeight = ${VIEWPORT_HEIGHT};
  const startedServer = ${STARTED_SERVER};
  const surfaces = [
    { name: 'placement', mode: 'walkthrough', query: '?act0_capture=placement' },
    { name: 'welcome', mode: 'walkthrough', query: '?act0_capture=welcome' },
    { name: 'home', mode: 'walkthrough', query: '?act0_capture=home' },
    { name: 'learn', mode: 'walkthrough', query: '?act0_capture=learn' },
    { name: 'runner_theory', mode: 'direct_state', query: '?act0_capture=runner_theory' },
    { name: 'runner_drill', mode: 'direct_state', query: '?act0_capture=runner_drill' },
    { name: 'runner_feedback_or_review', mode: 'direct_state', query: '?act0_capture=runner_feedback' },
    { name: 'review', mode: 'direct_state', query: '?act0_capture=review' },
    { name: 'practice', mode: 'direct_state', query: '?act0_capture=practice' },
    { name: 'profile', mode: 'direct_state', query: '?act0_capture=profile' },
    { name: 'world_completion', mode: 'direct_state', query: '?act0_capture=world_completion' },
  ];

  const normalizeText = text => text.replace(/\\s+/g, ' ').trim();

  const inspectSurface = async () => {
    const bodyText = normalizeText(
      await page.locator('body').innerText().catch(() => ''),
    );
    const gateVisible = /Enable accessibility/i.test(bodyText);
    const buttonNames = (await page.getByRole('button').allTextContents().catch(() => []))
      .map(normalizeText)
      .filter(Boolean);
    return {
      bodyText,
      gateVisible,
      blank: bodyText.length === 0,
      buttonCount: buttonNames.length,
      buttonNames,
    };
  };

  const prepareSurface = async url => {
    await page.goto(url, { waitUntil: 'domcontentloaded' });
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
  };

  const waitForWarmRuntime = async () => {
    const warmUrl = baseUrl + '?act0_capture=learn';
    for (let attempt = 0; attempt < 4; attempt += 1) {
      await prepareSurface(warmUrl);
      const inspection = await inspectSurface();
      const warmShot = await page.screenshot({ fullPage: false });
      if (!inspection.blank || warmShot.length >= 12000) {
        return;
      }
      await page.waitForTimeout(1500);
    }
  };

  await page.goto(baseUrl, { waitUntil: 'domcontentloaded' });
  await page.waitForLoadState('networkidle').catch(() => {});
  await page.waitForTimeout(700);

  const viewport = await page.evaluate(() => ({
    href: location.href,
    innerWidth: window.innerWidth,
    innerHeight: window.innerHeight,
    outerWidth: window.outerWidth,
    outerHeight: window.outerHeight,
    devicePixelRatio: window.devicePixelRatio,
    language: navigator.language,
    storedLanguage: localStorage.getItem('flutter.app_language_code'),
  }));

  const manifest = {
    generatedAt: new Date().toISOString(),
    appUrl: baseUrl,
    outputDir,
    viewport,
    startedFlutterServer: Boolean(startedServer),
    surfaces: [],
  };

  await waitForWarmRuntime();

  for (const surface of surfaces) {
    const timestamp = new Date().toISOString();
    const url = baseUrl + surface.query;
    const entry = {
      surface: surface.name,
      mode: surface.mode,
      url,
      viewportWidth,
      viewportHeight,
      captured: false,
      blankCheck: false,
      gatedCheck: false,
      timestamp,
    };

    try {
      await prepareSurface(url);
      const inspection = await inspectSurface();
      const file = outputDir + '/' + surface.name + '.png';
      const screenshotBytes = await page.screenshot({
        path: file,
        fullPage: false,
      });
      const visualNonBlank = screenshotBytes.length >= 12000;
      entry.blankCheck = !inspection.blank || visualNonBlank;
      entry.gatedCheck = !inspection.gateVisible;
      entry.buttonCount = inspection.buttonCount;
      entry.excerpt = inspection.bodyText.slice(0, 220);
      if (surface.name === 'learn') {
        entry.forbiddenLessonSequenceChrome =
          /\b\d+\s+Lesson\s+\d+\s+(Done|Now|Next|Locked)\b/.test(
            inspection.bodyText,
          );
      }
      entry.screenshotBytes = screenshotBytes.length;
      entry.visualNonBlank = visualNonBlank;
      if (!entry.blankCheck) {
        throw new Error('Blank surface');
      }
      if (inspection.gateVisible) {
        throw new Error('Accessibility gate still visible');
      }
      if (entry.forbiddenLessonSequenceChrome) {
        throw new Error('Forbidden compact lesson sequence chrome visible');
      }
      entry.captured = true;
      entry.file = file;
    } catch (error) {
      entry.failureReason = String(error && error.message ? error.message : error);
    }

    manifest.surfaces.push(entry);
  }

  return JSON.stringify(manifest);
}
EOF

ensure_server

pw close >/dev/null 2>&1 || true
pw open "$APP_URL" >/dev/null
pw resize "$VIEWPORT_WIDTH" "$VIEWPORT_HEIGHT" >/dev/null
pw_raw snapshot >"$INITIAL_SNAPSHOT_FILE" || true
pw run-code --filename seed_english.js >/dev/null
pw reload >/dev/null
pw resize "$VIEWPORT_WIDTH" "$VIEWPORT_HEIGHT" >/dev/null

viewport_json_quoted="$(pw_raw eval "({
  href: location.href,
  innerWidth: window.innerWidth,
  innerHeight: window.innerHeight,
  outerWidth: window.outerWidth,
  outerHeight: window.outerHeight,
  language: navigator.language,
  storedLanguage: localStorage.getItem('flutter.app_language_code'),
})")"
decode_pw_json_string "$viewport_json_quoted" >"$VIEWPORT_JSON_FILE"

node -e '
const fs = require("fs");
const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
if (data.innerWidth !== Number(process.argv[2]) || data.innerHeight !== Number(process.argv[3])) {
  console.error(JSON.stringify(data, null, 2));
  process.exit(1);
}
' "$VIEWPORT_JSON_FILE" "$VIEWPORT_WIDTH" "$VIEWPORT_HEIGHT" || fail "Viewport was not ${VIEWPORT_WIDTH}x${VIEWPORT_HEIGHT}"

set +e
manifest_json_quoted="$(pw_raw run-code --filename capture_surfaces.js 2>&1)"
capture_status=$?
set -e

if [[ $capture_status -ne 0 ]]; then
  printf '%s\n' "$manifest_json_quoted" >"$OUTPUT_DIR/flow_error.txt"
  fail "Controlled demo surface capture failed. See $OUTPUT_DIR/flow_error.txt"
fi

if ! decode_pw_json_string "$manifest_json_quoted" >"$MANIFEST_FILE"; then
  printf '%s\n' "$manifest_json_quoted" >"$OUTPUT_DIR/flow_error.txt"
  fail "Controlled demo surface capture returned non-JSON output. See $OUTPUT_DIR/flow_error.txt"
fi

node -e '
const fs = require("fs");
const manifest = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const required = [
  "home",
  "learn",
  "runner_theory",
  "runner_drill",
  "runner_feedback_or_review",
  "review",
  "practice",
  "profile",
];
const missing = [];
for (const name of required) {
  const entry = manifest.surfaces.find(surface => surface.surface === name);
  if (!entry || !entry.captured) {
    missing.push(name);
  }
}
if (missing.length > 0) {
  console.error(JSON.stringify({ missing }, null, 2));
  process.exit(1);
}
const learn = manifest.surfaces.find(surface => surface.surface === "learn");
if (!learn) {
  console.error(JSON.stringify({ missing: ["learn"] }, null, 2));
  process.exit(1);
}
if (learn.forbiddenLessonSequenceChrome) {
  console.error(JSON.stringify({ learnAcceptance: "forbidden Lesson N label visible" }, null, 2));
  process.exit(1);
}
' "$MANIFEST_FILE" || fail "Required controlled-demo captures are still missing. See $MANIFEST_FILE"

log "Capture complete"
log "Manifest: $MANIFEST_FILE"
log "Artifacts: $OUTPUT_DIR"
