---
status: "terminal_copy_leak_fixed"
status_source: "derived"
baseline: "cbbebdea4138"
generated_by: "docs_frontmatter_v1"
---

# Terminal Evidence Refresh + Copy Leak Verification v1

## 1. Verdict

`terminal_copy_leak_fixed`

The attached `Sharky Visual Ceiling Audit v1.pdf` was available and used as the primary audit evidence. Its terminal findings matched the prompt summary: terminal capture needed fresh evidence, the keep-sharp terminal question exposed `Tap Button for a keep-sharp review`, and terminal clue text could truncate in the phone capture.

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- HEAD: `cbbebdea4138f259a9d970b4fac43f976bebfc62`
- Tracked dirty files at preflight: none
- Staged files at preflight: none
- Local-only output at preflight: `output/design_review_packet_pre_human_10_10_v1/`, `output/full_product_10_10_claude_design_lite_packet_v1/`, `output/full_product_10_10_claude_design_packet_v1/`, `output/screen_review/`
- `graphify hook-check`: passed

## 3. Source Search Results

- `docs/_reviews/sharky_visual_ceiling_audit_v1.md`: not available locally.
- `/Users/elmarsalimzade/Downloads/Sharky Visual Ceiling Audit v1.pdf`: available; text extraction confirmed the audit called out terminal evidence refresh, possible blank CTA, `Tap Button` copy leak, and on-felt clue truncation.
- `lib/campaign/campaign_pack_registry_v1.dart`: terminal pack source contained `Volume I review is complete. Tap Button for a keep-sharp review.`
- `tools/act0_real_text_surface_capture_v1.dart`: active capture harness maps terminal task 0 to `volume_i_terminal_review` and terminal task 3 to `terminal_no_w13_state`; copy-detail primary CTA source is non-empty (`Continue review`) and feedback CTA source is non-empty (`Continue`).
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`: feedback CTA renders `Text(isWrong ? 'Try one like this' : 'Continue')`, so the copy-detail bottom CTA is source-backed as non-empty.
- `test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`: existing guard requires terminal copy to include Volume I review completion, W13 not open, keep-sharp, intentional review, and later-world blocking.

`Tap Button` was source-backed and live in the terminal pack before this task. It is now guarded absent for the exact leak phrase.

## 4. Fresh Capture Results

Regenerated:

```bash
./tools/screen_review_fast_v1.sh active_route_w7_w12 compact
```

Relevant outputs:

- `output/screen_review/current/active_route_w7_w12_fast/compact.volume_i_terminal_review_table.png`
- `output/screen_review/current/active_route_w7_w12_fast/compact.terminal_no_w13_copy_detail.png`
- `output/screen_review/current/active_route_w7_w12_fast/active_route_w7_w12_meta.json`

The metadata identifies the capture as `active_act0_runtime_test_only_wrapper` using `Act0LessonRunnerShellV1`, with `legacy_archive_runner_used: false`.

Post-fix terminal table capture shows:

- terminal prompt: `Volume I review is complete. Start the keep-sharp review.`
- answer label: `Start the keep-sharp review.`
- no `Tap Button for a keep-sharp review`

The no-W13 copy-detail capture still shows a white test-font block on the bottom blue feedback CTA, but source binds a non-empty `Continue` label. The full terminal no-W13 concept appears in the copy-detail feedback sheet.

## 5. CTA Classification

`terminal_cta_live_label_ok_capture_artifact`

The terminal table capture has visible answer labels. The no-W13 copy-detail bottom CTA visually appears as a white test-font block, but source proves the live label is non-empty (`Continue`), and the capture harness also supplies non-empty CTA labels. This is a capture/font rendering artifact, not a confirmed live blank-label bug.

## 6. Tap Button Classification

`tap_button_copy_leak_confirmed`

The leak was confirmed in source and fresh pre-fix capture. It was fixed by replacing the terminal prompt with the already-intended user-facing label.

## 7. Clue Truncation Classification

`clue_truncation_acceptable_full_text_available`

On-felt clue chips can truncate in compact terminal captures, including terminal no-W13 wording. The full concept is available in the main question/feedback copy-detail sheet and remains source-backed by the terminal pack. No layout or clue-copy fix was made in this task.

## 8. Changes Made

- Replaced terminal prompt copy in `lib/campaign/campaign_pack_registry_v1.dart`:
  - from `Volume I review is complete. Tap Button for a keep-sharp review.`
  - to `Volume I review is complete. Start the keep-sharp review.`
- Added a focused guard in `test/guards/w12_route_admission_review_payoff_gate_contract_test.dart` to prevent the exact copy leak from returning.

No layout, route, mapper, W13+, monetization, Practice, Learn, Profile, Welcome, Review, Table, Session Summary, or CTA-token work was performed.

## 9. Validation

Red-green evidence:

- Red: `flutter test test/guards/w12_route_admission_review_payoff_gate_contract_test.dart` failed on the exact `tap button for a keep-sharp review` leak before the source change.
- Green: the same focused guard passed after the source change.

Final validation:

- `flutter test test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`: passed, 6/6 tests
- `flutter analyze`: passed, no issues found
- `graphify hook-check`: passed
- `git diff --check`: passed
- `git diff --cached --check`: passed

`flutter analyze` regenerated `macos/Flutter/GeneratedPluginRegistrant.swift`; only that generated drift was restored before final status.

## 10. Output / Local-Only Status

Do not commit `output/**`. Current local output includes the refreshed screen-review lane and prior local-only output packets.

## 11. Next Recommendation

`Welcome Variant B Composition PR`
