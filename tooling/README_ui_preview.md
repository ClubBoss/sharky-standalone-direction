# UI Preview

## Features
- Search box with live filtering and match highlighting.
- Keyboard navigation: ArrowUp/ArrowDown/j/k, Enter, Home/End.
- Clickable "See also" links to jump between modules.
- Hash deep-links: `#<module-id>/<tab>` (tabs: theory, demo, drill).
- EN/RU toggle for labels via exported i18n.

## Hotkeys
- ArrowUp / k: move up
- ArrowDown / j: move down
- Enter: select current
- Home / End: jump to first/last

## Deep-link examples
- `build/ui_preview.html#live_tells_and_dynamics/theory`
- `build/ui_preview.html#live_tells_and_dynamics/demo`
- `build/ui_preview.html#live_tells_and_dynamics/drill`

## Local usage
- Build: `make ui-preview`
- Open: `make ui-preview-open`

## CI
- Artifact name: `ui-preview` (single HTML file).
- Included in snapshots at `ci/snapshots/ui_preview.html` when present.
- CI Job Summary prints a one-line size for the UI preview when the file exists.

## KPIs
- Above the tabs, a compact KPIs box appears for the selected module when `build/ui_assets/review_plan.json` is available. It shows totals: Tokens, Spot kinds, and Intervals (comma-separated). Missing fields render as `-`.
- The same box also shows counters: Answered, Correct, Missed probes, Family errors — sourced from the same `review_plan.json`; missing counters display as `-`.

## Footer stats
- A small footer in the bottom-right shows bundle stats read from `build/ui_assets/manifest.json`: files, raw bytes, gzip bytes (or `-`), modules, tokens, spot kinds, i18n keys, telemetry events, and a timestamp. When the manifest is absent or fields are missing, placeholders `-` are shown.
