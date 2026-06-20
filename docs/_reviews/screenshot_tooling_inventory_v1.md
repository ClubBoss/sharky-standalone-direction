# Screenshot Tooling Inventory v1

- Main commit: `2847c0cd27bf14c7e3cf7e4a486e165cd4de4df1`.
- Purpose: choose the cheapest existing capture path for acceptance evidence without creating new tooling.
- Verdict: use the direct Act0 proof capture for deterministic layout geometry and the native batch lane for real-text Act0 proof.

## Canonical recommendation

| Need | Use | Why | Limitations |
| --- | --- | --- | --- |
| Act0 layout geometry | `dart run tools/act0_product_100_proof_capture_v1.dart` | Reliable Flutter-test capture of main Act0 surfaces at three presets. | Output uses nonliteral/masked text; not copy proof. |
| Act0 real-text product proof | `./tools/screen_review_v1.sh core compact` | Native iOS Simulator captures and packages actual rendered Flutter text for Home, Learn, Practice, Review, and Profile. | Local-only; rebuilds once per surface and supports the compact preset/core group only in v1. |
| First-week real browser proof | `./tools/act0_first_week_compact_capture_v1.sh <absolute-output-dir>` | Playwright/web capture of compact Home, Learn, Review, and Profile first-week states. | Requires local web server/Playwright; not confirmed in this pass. |
| Full Act0 browser proof | `./tools/act0_controlled_demo_capture_v1.sh <absolute-output-dir>` | Covers onboarding, Home, Learn, runner, Review, Practice, Profile, and completion across compact, large, and tablet. | Prior local runs stopped after placement; pass an absolute output directory. |
| Modern Table/store proof | `dart run tools/modern_table_screenshot_v1.dart` then `SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh` | Canonical release/store asset lane. | Legacy/Modern Table only; not Act0 acceptance. |
| World session evidence | `dart run tools/world_screenshot_evidence_capture_v1.dart --world=0` or `--world=10` | Deterministic session evidence for supported worlds. | Only W0/W10; not an Act0 surface lane. |

## Tool inventory

### `act0_product_100_proof_capture_v1.dart`

- Surfaces: placement, Home, Learn, Learn detail, Practice, Review, Profile, table, and result.
- Devices: compact phone, large phone, tablet; portrait presets.
- Output: `output/device_audit/act0_product_100/` plus manifest.
- Text: intentionally nonliteral/masked (`render_kind: nonliteral_preview_contract`).
- Reliability: confirmed exit success in the Learn acceptance pass; local/test-only, outputs should remain uncommitted unless an explicit evidence policy says otherwise.

### `screen_review_v1.sh`

- Surfaces: Home, Learn, Practice, Review, Profile.
- Devices: compact portrait (`iPhone 17`) only in v1.
- Output: `output/screen_review/current/core/` with `compact.<surface>.png`, `manifest.json`, `contact_sheet.png`, and `screen_review_core.zip`.
- Text: literal native Flutter text; use this lane for learner-facing copy and commercial acceptance.
- Reliability: sequential build/fresh-simulator-boot/install/launch/capture per surface, with single-target simulator isolation and staging promotion so a failed capture does not destroy the previous good core packet.
- Safety: `SHARKY_CAPTURE_SURFACE` is ignored by release builds and does nothing when absent or unsupported.
- Policy: output is generated local evidence and must not be committed.

### `capture_act0_screens_v1.sh`

- Surfaces: Home, Learn, Practice, Review, Profile.
- Devices: compact portrait (`iPhone 17`) only in v1.
- Output: legacy flat `output/screen_review/current/compact.<surface>.png` and `manifest.json`.
- Text: literal native Flutter text.
- Reliability: useful for one-off single-surface probes, but the grouped `screen_review_v1.sh core compact` command is canonical for review packets.
- Policy: output is generated local evidence and must not be committed.

### Playwright capture scripts

- `act0_controlled_demo_capture_v1.sh`: broad surface and viewport coverage; writes `output/playwright/...`; real browser text is expected, but local reliability is currently unconfirmed because the controlled flow previously stopped after placement.
- `act0_first_week_compact_capture_v1.sh`: compact 393x852 first-week Home/Review/Learn/Profile proof; writes `output/playwright/...`; real browser text is expected, but it was not rerun in this discovery pass.
- Both are local-only helpers, require Flutter web plus the local Playwright wrapper, and should receive absolute output paths.

## Learn Route Acceptance implication

- Layout proof: use `act0_product_100_proof_capture_v1.dart` and inspect `compact_phone.learn.png`, `large_phone.learn.png`, and `tablet.learn.png`.
- Copy proof: use `./tools/screen_review_v1.sh core compact` and inspect `output/screen_review/current/core/contact_sheet.png` or `compact.learn.png`.
- Remaining gap: v1 has no large-phone/tablet native batch preset.

## Future rule

- Use direct proof capture for geometry and safe-area acceptance.
- Use `screen_review_v1.sh core compact` for native real-text Act0 proof; do not use web Playwright as the canonical lane.
- Do not treat masked captures as copy approval.
