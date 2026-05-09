# Content Authoring Workflow v1

Canonical authored module content lives under `content/<module_id>/v1/`.

## Steps

1. Copy the scaffold from `content/_templates/module_bundle_v1_template.md`.
2. Create `theory.md`, `drills.jsonl`, and `manifest.json` under `content/<module_id>/v1/`.
3. Use `snake_case` for `module_id` and keep drill IDs unique with `<module_id>_NN`.
4. Keep beginner content concise, factual, and free of unexplained jargon.

## Required checks

Run both commands before opening a PR:

```bash
dart run tools/validate_training_content.dart
./tools/run_gates_changed_v1.sh
```

## SSOT reminder

- `content/` is SSOT for authored training assets.
- `assets/learning_paths/` and `assets/packs/v2/manual_legacy/` are active transitional runtime/path-definition shelves, not authored-module SSOT.
- `lib/content/` is code/runtime/build infrastructure only.
- `assets/content/` is legacy and must not be used for new authored bundles.

## Learning-Path Canonical Bridge Rule

- For the learning-path practice slice, `canonicalModuleId` on a learning-path stage is the only approved bridge for verified stage -> canonical World1 module identity truth.
- Add `canonicalModuleId` only after explicit content-truth confirmation that the stage and canonical module are the same practical content unit.
- Related pedagogy or topical similarity is not enough to justify this field.
- Runtime and launcher layers must not infer stage -> canonical-module equivalence on their own.
