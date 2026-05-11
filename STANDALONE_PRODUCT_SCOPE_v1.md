## Sharky_1.0 Standalone Scope

Source:
- `/Users/elmarsalimzade/poker_ai_analyzer/Sharky_main`

Purpose:
- Keep one standalone active product root.
- Exclude build cache, archive tails, release reports, and old recovery junk.
- Leave older products and historical material in the original workspace as archive/reference.

Included:
- App source and UI under `lib/`
- Active product content under `content/`
- Runtime assets under `assets/`
- Platform folders: `android/`, `ios/`, `macos/`, `linux/`, `web/`, `windows/`
- Tests and active tooling: `test/`, `tool/`, `tools/`
- Active docs and repo instructions needed for product work
- Local stubs and support folders required by `pubspec.yaml`

Excluded on purpose:
- Build and cache output: `build/`, `.dart_tool/`, `Pods/`, `.symlinks/`
- Tool-generated sidecars and preview mirrors:
  `content_adaptive_generated/`, `content_adaptive_preview/`
- Historical/archive tails: `archive/`, `backup_content/`, `baseline/`, `legacy/`
- Old release artifacts and report bundles: `release/`, `docs/_archive/`, `docs/reference/history/`, `docs/plan/archive/`
- Old audit dumps, logs, and generated temp files
- Bracket/syntax mass-fix scripts that previously caused unsafe cascades

Operational note:
- `Sharky_main` remains the archive/source donor.
- `Sharky_1.0` is the new standalone working root for active product work.
- If adaptive preview/generated outputs are needed later, tooling may recreate
  them from scratch; they are not product truth and should not be treated as
  source content.
