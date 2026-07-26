---
status: "undeclared"
status_source: "absent"
baseline: "c597ca1ab76a"
generated_by: "docs_frontmatter_v1"
---

# Tier0 Root-Cause Repair + Wave 4 Admission Core v1

Status:
`tier0_root_cause_repaired_wave4_admission_core_still_blocked_by_act0_preview_backlog`

Branch:
`codex/tier0-root-cause-repair-wave4-admission-core-v1`

Parent branch:
`codex/baseline-guard-debt-wave4-admission-v1`

Required parent HEAD:
`c597ca1ab76a3f2a0cb9ea695112fffccb052d19`

## Scope

This artifact records the bounded Tier0 root-cause repair pass for Wave 4
admission. It did not begin Wave 4. It did not attempt the known 31 World 1
foundations behavioral failures or the 21 Modern Table behavioral failures.

The active prompt and live branch state supersede stale capsule references to
`1d7a76215ac008eb3066c5030e514c5fa80029c7` as the frozen Wave 4 HEAD.

## Compact Matrix

| Root cause | Initial evidence | Owner | Repair | Result |
| --- | ---: | --- | --- | --- |
| Act0 W4-W6 normalized route drift | Act0 preview source-contract tests still expected deprecated W4 Preflop / W5 Bet Purpose / W6 Board Awareness order | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`, `test/ui_v2/act0_shell_preview_screen_v1_test.dart` | Re-aligned the test contract to current SSOT/runtime truth: W4 Bet Purpose / Price, W5 Board Awareness, W6 Range Thinking. | Focused W4-W6 checks pass. |
| Act0 W7 locked scaffold integrity | generated W7 visible-card lesson ended on drill | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | Appended one locked review recap task to the generated visible-card lesson. | Integrity-matrix focused check passes. |
| RU localization residue | `Learn`, `Volume`, W-status English, and `Poker` remained in RU surface strings | Act0 welcome, Learn path, and placement shells | Translated visible RU residues while preserving allowed `Sharky` brand token. | RU no-unapproved-Latin guard passes. |
| Campaign follow-up registry count | invariant expected 30 follow-up packs; registry exposes 36 | `test/guards/campaign_followup_pack_registry_invariants_test.dart`, `lib/campaign/campaign_pack_registry_v1.dart` | Updated count assertion to current registry truth while retaining per-pack invariants. | Follow-up registry guard passes. |
| Practice active-repair phrase | Play shell test expected stale hard-coded copy while UI uses shared Sharky phrase contract | `test/ui_v2/act0_play_shell_v1_test.dart`, `lib/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart` | Aligned test to the current contract line. | Play shell guard passes. |

## Files Changed

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `test/ui_v2/act0_play_shell_v1_test.dart`
- `test/guards/campaign_followup_pack_registry_invariants_test.dart`
- `docs/_reviews/baseline_guard_debt_repair_ledger_v1.md`
- `docs/_reviews/tier0_root_cause_repair_wave4_admission_core_v1.md`

## Validation Evidence

Green individual selected Tier0 files:

- `flutter test -r expanded test/ui_v2/act0_play_shell_v1_test.dart`
- `flutter test -r expanded test/ui_v2/act0_en_alpha_residue_guard_test.dart`
- `flutter test -r expanded test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart`
- `flutter test -r expanded test/guards/campaign_pack_registry_invariants_test.dart`
- `flutter test -r expanded test/guards/campaign_followup_pack_registry_invariants_test.dart`
- `flutter test -r expanded test/ui_v2/act0_shell_state_v1_feedback_test.dart`

Green focused Act0 preview checks:

- `Task-family inference is typed and overridable`
- `First active broadway use defines the term before later broadway reuse`
- `World 4 has a real bet-purpose and price spine`
- `World 4 content covers purpose and price without math overload`
- `World 4 includes a real-table price transfer rep`
- `World 5 has a real board-awareness spine`
- `World 5 content covers board texture and draws without math overload`
- `World 6 has a real range-thinking spine`
- `World 6 content covers range thinking without solver overload`
- `World 7 is locked but has a real range-thinking scaffold`
- `First 12 worlds keep integrity-matrix structural invariants`
- `Prefixed W5-W12 task ids follow the current allowlisted owner convention`
- `RU coverage report keeps W4 to W12 fallback explicit instead of silent`

Full selected seven-file command:

```bash
flutter test -r json \
  test/ui_v2/act0_shell_preview_screen_v1_test.dart \
  test/ui_v2/act0_play_shell_v1_test.dart \
  test/ui_v2/act0_en_alpha_residue_guard_test.dart \
  test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart \
  test/guards/campaign_pack_registry_invariants_test.dart \
  test/guards/campaign_followup_pack_registry_invariants_test.dart \
  test/ui_v2/act0_shell_state_v1_feedback_test.dart \
  > .dart_tool/codex_tier0_root_cause_wave4/tier0_7files_after.jsonl
```

Result:
`success=false`, with `602 success / 128 error`.

The remaining errors are concentrated in
`test/ui_v2/act0_shell_preview_screen_v1_test.dart` broad widget/copy behavior,
including debug feedback flows, Home/Review/Learn widget expectations, RU
runner localization expectations, and retention/review UI expectations. Those
were not admitted in this pass.

## Admission Verdict

Wave 4 is not admitted.

The canonical Tier0 root-cause groups selected by this repair pass are closed,
but the authoritative seven-file Tier0 set is still red because the large Act0
preview file retains broad behavioral/copy backlog outside the admitted lane.
A separate admission wave must either repair, retire, or reclassify that
remaining Act0 preview backlog before Wave 4 can start.

## Token Efficiency

This pass reused the existing `.dart_tool` JSON/log inventory, avoided
repeating the original 164-failure discovery until after targeted repairs, and
used focused `--plain-name` Act0 preview runs before one full seven-file JSON
evidence run.
