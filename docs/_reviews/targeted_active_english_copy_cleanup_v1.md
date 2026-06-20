# Targeted Active English Copy Cleanup v1

- Branch: `codex/act0-learn-route-clarity-v1`
- Scope: active first-week copy in `act0_play_shell_v1.dart` and `act0_runtime_surface_copy_v1.dart`
- Product behavior: unchanged; copy-only cleanup

## Fixed

- Replaced active Practice/Play Cyrillic lane intro snippets with English.
- Replaced active runtime RU alternate strings with English fallbacks so the active first-week path stays English-first.
- Softened the secondary completed-session premium preview entry from direct premium wording to extra practice options.

## Intentionally not changed

- Existing localization plumbing and atom lookup seams remain in place.
- Non-visible topic-sort compatibility aliases for older RU labels remain because they are matcher inputs, not rendered copy.
- Internal widget keys and deterministic seed strings were not changed because they are not visible copy.
- Broad content bundles, dormant surfaces, generated audit output, screenshot output, and Modern Table were not touched.

## Checks

- `./tools/audit_english_copy_v1.sh` passed; refreshed audit output written to `output/copy_audit/current/`.
- Scoped audit result: target-file Cyrillic and premium-copy findings cleared.
- Remaining target-file findings are non-visible keys/deterministic seeds plus generic `Open`.
- `./tools/screen_review_fast_v1.sh core compact` passed.
- Fast screen-review output: `output/screen_review/current/core_fast/contact_sheet.png`.
- `dart format lib/ui_v2/act0_shell/act0_play_shell_v1.dart lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart` passed.
- `flutter analyze` passed.
- `git diff --check` passed.
