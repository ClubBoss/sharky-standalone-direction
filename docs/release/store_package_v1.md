# Store Package v1 SSOT

## PIEC Scan

- Searches for existing "store package" or "release packaging" SSOTs returned no applicable documentation. This file serves as the single source of truth.

## Required Screenshot Sets

**iOS** (App Store Connect)
- **Hero / App Icon Focus** - 1 hero portrait + 1 landscape screenshot showing the premium poker table experience (4K, no overlays).
- **Table-Native Training** - 3 screenshots (portrait, landscape, split view) showing a training pack spot and action buttons.
- **Streak / Daily Goals** - 2 portrait screenshots highlighting streak badges and daily hand counters.
- **Offline / Practice Mode** - 1 landscape view of offline-friendly mode (low lighting, no network indicator).
- **Facts-Only UI** - 1 portrait screenshot of explanations/recap cards with minimal chrome.

**Android** (Google Play Console)
- **Hero / Table Overview** - 2 portrait screenshots emphasizing the table layout and chip stack UI.
- **Training Flow** - 2 screenshots covering a hand reveal and decision buttons.
- **Progress / Rewards** - 2 screenshots showing streak progress, reward chips, or star meter.
- **Stats / Insights** - 1 screenshot of the analytics overlay or recap highlight.
- **Offline / Busy Mode** - 1 screenshot of the app in low-bandwidth stance (dimmed background, offline badge).

For every platform set the filenames to follow `<platform>-<set>-<index>.png` (e.g., `ios-hero-01.png`) and, when using the local repo asset layout, keep assets under `assets/store/<platform>/<set>/` (some release flows generate/store assets elsewhere before import).

## Value Statements

1. **Premium Learning Path** - "Sharky Poker's guided learning path keeps every decision-focused player honing in on high-impact spots."
2. **Modern Table Performance** - "Optimized rendering and adaptive scaling deliver smooth live-actions for both small phones and large tablets."
3. **Psychology-First Coaching** - "Every streak, recap, and adaptive insight is engineered to reinforce confidence and reduce tilt."
4. **Anywhere Practice** - "Offline-ready drills and compact stats let champions train between flights or while waiting for seats."

## Metadata Checklist

- Canonical submission-only metadata owner: `docs/release/submission_metadata_truth_v1.md`
- **App Subtitle (iOS/Android)**: concise benefit line (e.g., "Precision training for serious poker players").
- **Keywords (App Store)**: "poker training, hand analysis, betting coach, live poker, adaptive replay".
- **Privacy Labels**: reference `docs/release/IAP_CONFIGURATION.md` for purchase indicators and point to `assets/store/privacy_labels/README.md` if it exists in the current repo snapshot (some release flows keep these assets/docs outside the repo and import later).
- **Support contact (current main runtime truth)**: `support@sharky.app`.
- **Privacy / Terms runtime truth**: the current build ships in-app legal surfaces via `lib/ui_v2/settings/legal_screen_v1.dart`; do not point runtime copy at placeholder web pages.
- **Support URL / Marketing URL for store submission**: see `docs/release/submission_metadata_truth_v1.md`; unresolved on current main.
- **Legal entity / Copyright for store submission**: see `docs/release/submission_metadata_truth_v1.md`; unresolved on current main.

## App Store Copy SSOT v1

### Subtitle variants (<=30 chars)

1. Table-First Poker Training
2. Sharpen Every Poker Decision
3. Daily Poker Skill Builder

### Promotional text variants (<=170 chars)

1. Train with table-first drills, climb worlds, and keep streak momentum with deterministic practice loops built for serious poker decision work.
2. Run focused sessions in minutes: pick your next world, play interactive spots, and track progress with a repeatable learning loop.
3. Improve decision quality through daily table scenarios, clear progress signals, and a stable practice flow you can trust.

### Description (short)

Sharky Poker is a table-first poker training app with world progression, interactive decisions, and a deterministic learning loop.

### Description (long)

#### What it is

Sharky Poker is a focused training product for poker decision-making. Each session keeps the table context front and center and reduces noise.

#### How it works (table-first, worlds, progress)

You practice through world-based progression and table scenarios. Start from your recommended next step, run drills, and track completed progress over time.

#### Why it is different (interactive decisions, deterministic learning loop)

The learning loop is deterministic and repeatable, which makes regressions visible and practice outcomes stable. Interactive decisions stay anchored to table context.

#### Privacy (offline-first, no account)

The app is designed for offline-first usage and does not require account creation for core training flows.

### Keywords variants (target <=100 chars)

1. poker training,table drills,hand analysis,decision coach,offline poker,streak tracker
2. poker practice,table strategy,hand trainer,poker coach,world progression,daily run
3. poker skills,decision training,table simulator,practice packs,progress map,offline mode

## Screenshot Selection Checklist v1

Use the deterministic outputs from `out/store_assets/v1/`.

### Recommended order

1. Map + progress first
2. Table action middle
3. Reward/progress recap last

### Pick list (6 screenshots)

1. `modern_table_default_portrait.png`
   - Caption template: Progress map and next world
2. `modern_table_json_portrait.png`
   - Caption template: Track streak and daily goals
3. `modern_table_default.png`
   - Caption template: Make better table decisions
4. `modern_table_json.png`
   - Caption template: Learn from interactive spots
5. `modern_table_asset.png`
   - Caption template: Review outcomes instantly
6. `modern_table_asset_portrait.png`
   - Caption template: Build consistent poker habits

### Optional expansion (up to 8)

1. Repeat one map/progress frame with alternate crop if platform requires additional portrait ratio.
2. Repeat one table-action frame with alternate crop for landscape slot coverage.

### Caption constraints

- Keep each caption within 30-40 characters.
- Lead with value, not feature names.
- Keep tense consistent and action-oriented.

## Versioning Rule

- **Identifier**: `StorePackageV1`.
- **Date Stamp**: include the ISO date when assets were last refreshed (`YYYY-MM-DD`).
- **Updated By**: include editor initials or name after the date.
_Example entry_: `StorePackageV1 - 2026-01-22 - Updated by EL`.

## Process

1. **Produce Assets**
   - Capture iOS and Android screenshots via the Emulator / TestFlight builds; verify adaptive text and safe areas.
   - Export PNGs at required resolutions (portrait: 1284x2778 or similar, landscape: 1284x720).
   - Optimize each asset (lossless PNG) and name per the `<platform>-<set>-<index>` convention.
2. **Store Assets**
   - Place images under `assets/store/<platform>/<set>/` when using the in-repo layout (e.g., `assets/store/ios/hero/ios-hero-01.png`); otherwise keep the same naming and import them before release handoff.
   - Update `assets/store/README.md` (see nerve file) if naming changes or new sets added.
3. **Validate Checklist**
   - Confirm all listed screenshot counts exist with correct naming.
   - Ensure metadata entries are current in App Store Connect / Google Play.
   - Run a quick smoke build to confirm the assets load (use `flutter test` or manual preview).
4. **Document Updates**
   - Refresh the "Versioning Rule" field above with the current date + owner.
   - Note in release notes any new imagery or metadata adjustments so stakeholders can audit.

## Enforcement Protocol (Store Package Guard)

- Canonical repo proof path: `out/modern_table_screenshots_v1.zip` with pipeline notes in `docs/release/store_assets_v1.md`.
- Default behavior: the store package guard **skips** if `out/modern_table_screenshots_v1.zip` is missing.
- Enforce mode: set `STORE_PACKAGE_GUARD=1` to require the canonical proof artifact, zip contents, and supporting docs.
- When to enforce: only during Store Package preparation / release checklist steps.

`assets/store/` remains an optional import layout for external store-console handoff. It is not the enforced repo proof path.

### Telemetry guard

- Purpose: verify release-critical telemetry references exist before release.
- Command: `dart test test/contracts/store_package_telemetry_guard_test.dart -r expanded --concurrency=1 --timeout 2m`
- Run when preparing the Store Package or ticking the pre-release checklist.

## Reference Paths

- Canonical repo proof artifact: `out/modern_table_screenshots_v1.zip`
- Canonical repo proof notes: `docs/release/store_assets_v1.md`
- Optional import layout: `assets/store/` (see `assets/store/README.md`).
- Metadata guidance: `docs/release/IAP_CONFIGURATION.md`.
- Release notes: `docs/release/RELEASE_NOTES.md`.

## Current Bounded Proof On Main

- This owner records bounded store-package truth on current `main`.
- It stays explicitly subordinate to:
  - `docs/release/submission_metadata_truth_v1.md`
  - `docs/release/go_hold_rollback_truth_v1.md`
  - `docs/release/operational_review_packet_truth_v1.md`
  - `docs/release/release_owner_decision_template_v1.md`
  - `docs/release/release_owner_review_v1.md`
  - `docs/release/release_confidence_baseline_v1.md`
- Current-main machine-readable anchors for this owner are:
  - `support@sharky.app`
  - `STORE_PACKAGE_GUARD=1`
  - `out/modern_table_screenshots_v1.zip`
  - `docs/release/store_assets_v1.md`
  - `assets/store/README.md`
  - `dart test test/contracts/store_package_telemetry_guard_test.dart -r expanded --concurrency=1 --timeout 2m`
- Submission-only support URL, marketing URL, legal entity, and copyright
  remain owned by `docs/release/submission_metadata_truth_v1.md` and remain
  unresolved on current `main`.
- This owner does not claim store readiness.
- This owner does not claim final release completion.
- This owner does not claim GO.
- If a release surface implies the store package is fully complete or that
  unresolved submission metadata has been finalized on current `main`, that
  surface is overstating repo truth and must be corrected.
