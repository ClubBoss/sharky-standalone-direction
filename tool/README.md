# tool/ (Compatibility / Legacy Staging)

STATUS: DEPRECATED / COMPATIBILITY SHIM

- SSOT for maintained tooling is `tools/`.
- Do not add new scripts here.
- Keep `tool/` only for backward-compatible entrypoints used by legacy docs/CI/local workflows.

Migration examples (old -> new):

- `dart run tool/validate_training_content.dart --ci`
  -> `dart run tools/validate_training_content.dart --ci`
- `dart run tool/generate_and_export_packs.dart`
  -> `dart run tools/generate_and_export_packs.dart`

Notes:

- Some `tool/*` paths are still referenced by legacy CI jobs and historical docs.
- Prefer updating callers to `tools/*` where safe; keep wrappers to avoid breakage.
