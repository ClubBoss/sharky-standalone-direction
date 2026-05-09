# Content SSOT v1

Canonical authored training assets live under `content/`.

## Canonical paths

- Module bundles: `content/<module_id>/v1/`
- Module manifests: `content/<module_id>/v1/manifest.json`
- World and session manifests: `content/_meta/world_sessions_manifest_v1.json`
- World drill manifests: `content/_meta/world_drills_manifest_v1.json`
- Runtime schedule and gauntlet assets: `content/schedules/` and `content/gauntlets/`

`pubspec.yaml` bundles these `content/` paths directly, and the canonical validator entrypoint is `dart run tools/validate_training_content.dart`.

## Non-SSOT paths

- `lib/content/` is Dart code only: contracts, validators, helpers, and metadata surfaces. It is not authored training content.
- `assets/content/` is legacy. Do not add new authored content there and do not treat it as the source of truth.
- `content/_manifest.json` is not the canonical readiness source. Prefer explicit module manifests under `content/<module_id>/v1/manifest.json` and explicit `_meta` manifests under `content/_meta/`.

## Adding new content

1. Add the authored bundle under `content/<module_id>/v1/`.
2. Add or update `manifest.json` in that bundle.
3. Ensure the asset path is declared in `pubspec.yaml` if the runtime needs it.
4. Run `dart run tools/validate_training_content.dart`.
5. Keep any helper code in `lib/content/` aligned to the `content/` asset path, never the other way around.
