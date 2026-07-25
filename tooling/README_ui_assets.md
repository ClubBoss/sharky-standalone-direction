# UI assets bundle

The `export_ui_assets.dart` script collects several generated JSON files into
`build/ui_assets/`:

- `badges.json`
- `search_index.json`
- `see_also.json`
- `lesson_flow.json`
- `review_plan.json`
- `i18n/en.json`
- `i18n/ru.json`
- `telemetry_schema.json`

The directory also includes `manifest.json`. The manifest lists all files, their
byte counts in a `sizes` map, a generation timestamp and useful counts.

The exporter is deterministic. Recompute outputs with
`dart run tooling/export_ui_assets.dart --recompute` (or `make ui-assets`). No
additional dependencies are required.

## Size budgets & verify

- Budget file: `tooling/budgets/ui_assets_budget.json`
- Local check: `make ui-assets-verify`
- Included in `make green-run`

Per-file limits are an accepted generated baseline plus small explicit
engineering headroom. When an accepted asset changes, measure a clean,
deterministic export and update only that asset's limit; do not use a blanket
multiplier or silently exclude the asset from the bundle.

Note: CI Job Summary includes a "UI assets" size table (raw bytes and gzip bytes when available) for quick review after runs.
