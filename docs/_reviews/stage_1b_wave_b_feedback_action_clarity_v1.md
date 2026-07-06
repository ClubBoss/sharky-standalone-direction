# Stage 1B Wave B Feedback and Action-Model Clarity v1

## Verdict

Stage 1B Wave B learner-facing feedback/action-model clarity is implemented for the admitted W4/W5 scope only.

No Wave C or Wave D work was started.

## Exact W4 row count and IDs

Changed W4 correct-feedback rows: 28.

| Session | Stable ID |
| --- | --- |
| `w4.s01` | `choose_call_trap` |
| `w4.s01` | `choose_fold_release` |
| `w4.s01` | `choose_raise_value` |
| `w4.s02` | `choose_call_control` |
| `w4.s02` | `choose_fold_trap` |
| `w4.s03` | `choose_call_trap` |
| `w4.s03` | `choose_fold_release` |
| `w4.s03` | `choose_raise_value` |
| `w4.s04` | `choose_call_repeat` |
| `w4.s04` | `choose_fold_repeat` |
| `w4.s04` | `choose_raise_repeat` |
| `w4.s05` | `choose_call_repeat` |
| `w4.s05` | `choose_fold_repeat` |
| `w4.s06` | `choose_call_repeat` |
| `w4.s06` | `choose_fold_repeat` |
| `w4.s06` | `choose_raise_repeat` |
| `w4.s07` | `choose_call_focus` |
| `w4.s07` | `choose_fold_focus` |
| `w4.s07` | `choose_raise_focus` |
| `w4.s08` | `choose_call_focus` |
| `w4.s08` | `choose_fold_focus` |
| `w4.s08` | `choose_raise_focus` |
| `w4.s09` | `choose_call_focus` |
| `w4.s09` | `choose_fold_focus` |
| `w4.s09` | `choose_raise_focus` |
| `w4.s10` | `choose_call_focus` |
| `w4.s10` | `choose_fold_focus` |
| `w4.s10` | `choose_raise_focus` |

Every changed W4 row keeps its prompt, `expected`, `acceptable_actions`, `id`, and `why_v1` unchanged. Only `feedback_correct_v1` changed from label-only copy to one compact reason-bearing sentence.

## Exact W5 admitted row count and IDs

Changed W5 wet/dry acceptable-feedback rows: 6.

| Session | Stable ID | Change |
| --- | --- | --- |
| `w5.s01` | `classify_texture_intro_dry_raise_v1` | Added `feedback_acceptable_v1` |
| `w5.s01` | `classify_texture_intro_dry_call_control_v1` | Added `feedback_acceptable_v1` |
| `w5.s01` | `classify_texture_intro_wet_call_v1` | Added `feedback_acceptable_v1` |
| `w5.s01` | `classify_texture_intro_wet_fold_pressure_v1` | Added `feedback_acceptable_v1` |
| `w5.s10` | `classify_texture_synthesis_dry_raise_v1` | Added `feedback_acceptable_v1` |
| `w5.s10` | `classify_texture_synthesis_wet_fold_v1` | Added `feedback_acceptable_v1` |

Every changed W5 row keeps its prompt, cards/board/context fields, `expected_action`, `acceptable_actions`, `id`, session order, kind, and route unchanged.

## Opportunistic W4 denial rows

Opportunistic W4 denial acceptable-feedback rows added: 0.

Reason: the denial rows with real acceptable alternates are W4 sizing files, not the same 28 W4 action-choice files already edited for Part A. Adding them would broaden Wave B beyond the admitted same-file/root-cause boundary.

## Representative before / after feedback

W4 example:

- File: `content/worlds/world4/v1/sessions/w4.s01/drills/d.choose_call_trap.json`
- Before: `Correct. Call is expected in this trap spot.`
- After: `Correct. The trap cue favors a call because it keeps weaker bluffs in without inflating the pot.`

W5 example:

- File: `content/worlds/world5/v1/sessions/w5.s01/drills/d.classify_texture_intro_wet_call_v1.json`
- Before authored acceptable feedback: none
- After: `Folding is playable because wet boards can become volatile, but call is preferred when live improvements make control worth taking.`

## Invariance proof

Bounded diff script compared every changed W4/W5 drill against base `f6e8f0e31d6aa1ddd380a6ece12b7125f3543874`.

Results:

- W4 changed content files: 28
- W5 changed content files: 6
- W6 changed content files: 0
- `id` changes: 0
- `expected` changes: 0
- `expected_action` changes: 0
- `acceptable_actions` changes: 0
- `acceptable_preset_ids` changes: 0

## W5 decisive-cue rationale

The admitted W5 rows are wet/dry intro and wet/dry synthesis rows with real acceptable alternate actions.

Each new authored acceptable feedback:

- explains why the alternate remains playable;
- names the wet or dry texture cue;
- explains why the expected action is preferred in the exact simplified spot;
- avoids false texture absolutes.

No row teaches wet -> call, dry -> raise, or paired -> fold as a universal rule.

## Guard coverage

Added focused guard:

- `test/guards/stage1b_wave_b_feedback_action_clarity_contract_test.dart`

It proves:

- the exact 28 W4 rows no longer use label-only expected-action templates;
- W4 expected actions, stable IDs, acceptable actions, and `why_v1` remain unchanged;
- the exact 6 W5 admitted rows have authored `feedback_acceptable_v1`;
- W5 expected actions and acceptable actions remain unchanged;
- W5 acceptable feedback names the decisive wet/dry cue and explains the preferred action;
- false texture absolutes are absent;
- active W5.s11 content truth is not reintroduced.

## Validation

Commands run:

- JSON validation script over 34 changed drill JSON files
- bounded invariance script against base `f6e8f0e31d6aa1ddd380a6ece12b7125f3543874`
- `flutter test test/guards/stage1b_wave_b_feedback_action_clarity_contract_test.dart test/tools/drill_runtime_evaluator_v1_test.dart test/ui_v2/runner/shared_learner_feedback_explanation_v1_test.dart test/guards/world5_early_runtime_truth_contract_test.dart test/guards/world5_campaign_routing_contract_test.dart`
- `flutter analyze test/guards/stage1b_wave_b_feedback_action_clarity_contract_test.dart`
- `git diff --check`
- `graphify hook-check`

Results:

- Changed drill JSON validation: pass, 34 files.
- Bounded invariance script: pass, 28 W4 rows, 6 W5 rows, 0 W6 content files, no action/stable-ID/acceptable-action changes.
- Focused Flutter tests: pass, 29 tests.
- Targeted analyze: pass.
- Diff hygiene: pass.
- Graphify hook check: pass.

## Excluded families

Excluded by design:

- W4 sizing acceptable-feedback families
- W4 value/bluff/protection acceptable-feedback families
- W4 anchor rows
- W4 chain rows
- W5 paired/high-card families outside the exact admitted wet/dry boundary
- W6 content
- W6 campaign guard
- repair receipt architecture
- routes/progression files
- schema/evaluator/runtime architecture
- telemetry
- Modern Table
- mascot/assets
- W7+

## Wave C admission status

Wave B closes only W4/W5 feedback and W5 action-model clarity. Wave C remains blocked until owner review of this artifact, then may be admitted as:

`stage_1b_wave_c_admitted_after_wave_b_review`

## Exact next owner action

Review Wave B and authorize Wave C W6 proxy-context repair.
