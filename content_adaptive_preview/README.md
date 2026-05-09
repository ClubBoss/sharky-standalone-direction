# content_adaptive_preview

Bucket type: `PREVIEW / GENERATED ADAPTIVE SHELF`

Purpose:
- Stores tooling-produced adaptive preview and mirror artifacts.
- May contain partial or `_meta`-only outputs during preview workflows.

Policy:
- Do not treat this folder as canonical authored-content SSOT; canonical authored modules live under `content/`.
- Do not treat this folder as active runtime/path-definition authority; it is a tooling preview shelf, not a production content source.
- Promotion, retention, or replacement of anything here must be an explicit future integration decision.

Tooling evidence:
- `tools/adaptive_module_composer.dart`
- `tools/adaptive_quiz_composer.dart`
- `tools/content_evolution_refactor.dart`
