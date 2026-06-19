# Compact First-Week Proof Packet v1

Date: 2026-06-19
Branch: `codex/compact-first-week-proof-packet-v1`
Base commit: `9b3ec313`
Mode: compact first-week proof packet; internal product proof; not public
marketing or App Store packaging.

## 1. Files Inspected

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/act0_rule_based_repair_visible_reason_surface_v1.md`
- `docs/_reviews/act0_repair_reason_copy_normalization_v1.md`
- `docs/_reviews/act0_rule_based_repair_result_receipt_v1.md`
- `docs/_reviews/act0_session_repair_summary_v1.md`
- `docs/_reviews/act0_rule_based_repair_telemetry_truth_v1.md`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart`
- `lib/ui_v2/act0_shell/act0_rule_based_repair_personalization_v1.dart`
- `test/ui_v2/act0_repair_intent_contract_v1_test.dart`
- `test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
- `test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart`
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`

## 2. Files Changed

- `docs/_reviews/compact_first_week_proof_packet_v1.md`

No runtime code, tests, routes, workflows, generated outputs, screenshots,
commerce files, or `external_competitors/` files were changed.

## 3. Proof Chain Status

### First Decision / Missed Signal

Status: proven.

Evidence:

- `test/ui_v2/act0_repair_intent_contract_v1_test.dart`
  - `wrong answer creates deterministic mapped repair intent`
  - `same input creates same target and reason code`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
  - `open repair intent resolves next useful hand to stored target`

The current deterministic contract records source task, choice, result,
error type, missed signal, skill atom, target task, mapping type, and reason
code.

### Visible Repair Reason

Status: proven.

Evidence:

- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
  - `mapped repair bridge renders same-clue review copy`
  - `mapped repair reason is visible on Home next useful hand`
  - `exact replay bridge renders exact-replay review copy`
  - `exact replay reason is visible on Home without same-signal copy`
- `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
  - `repair_same_clue_v1 renders accepted same-clue sentence`
  - `repair_exact_replay_v1 renders accepted replay sentence`

Current learner-facing same-signal copy:

`You missed that nobody has bet yet. This hand repeats that table clue.`

Exact replay copy:

`Replay this spot to fix the no-bet-yet clue.`

### Repair Attempt

Status: proven.

Evidence:

- `test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart`
  - `successful mapped repair completion clears matching intent`
  - `failed repair completion keeps matching intent open`
  - `exact replay fallback clears after correct replay completion`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
  - `successful repair clears resolver priority`
  - `failed repair keeps resolver priority`

The repair attempt is local and deterministic. A fixed mapped repair clears the
stored repair intent. A failed mapped repair keeps repair priority available.

### Fixed / Repeated Receipt

Status: proven.

Evidence:

- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
  - `successful repair clears resolver priority`
  - `failed repair keeps resolver priority`
  - `exact replay fixed receipt avoids same-signal claims`
  - `exact replay repeated receipt avoids same-signal claims`
- `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
  - `repair result receipt renders fixed and repeated same-signal copy`
  - `repair result receipt renders exact replay copy`

Current mapped fixed receipt:

`Repair fixed: you caught the no-bet-yet clue.`

Current mapped repeated receipt:

`Still missed: nobody had bet yet. One more repair hand will help.`

Exact replay receipts avoid same-signal transfer claims.

### Session Repair Summary

Status: proven for the active / most-recent repair result.

Evidence:

- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
  - `successful repair clears resolver priority`
  - `failed repair keeps resolver priority`
  - `exact replay fixed receipt avoids same-signal claims`
  - `exact replay repeated receipt avoids same-signal claims`
- `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
  - `session repair summary renders fixed and repeated same-signal copy`
  - `session repair summary renders exact replay copy`

Current fixed summary:

`Today you repaired the no-bet-yet clue.`

Current repeated summary:

- `Still fragile: the no-bet-yet clue.`
- `Next focus: one more no-bet-yet repair hand.`

Exact replay summaries avoid generalized same-signal improvement claims.

### Non-Repair Preservation

Status: proven.

Evidence:

- `test/ui_v2/act0_repair_intent_contract_v1_test.dart`
  - `correct answer does not create open repair intent`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
  - `correct answer does not override existing recommendation`
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`
  - `Act0 runner emits safe task telemetry without changing answer route`

Correct / non-repair flows do not render repair summaries, repair receipts, or
repair-reason copy, and continue through existing fallback behavior.

## 4. Existing Evidence Links

- Visible reason surface:
  `docs/_reviews/act0_rule_based_repair_visible_reason_surface_v1.md`
- Copy normalization:
  `docs/_reviews/act0_repair_reason_copy_normalization_v1.md`
- Repair result receipt:
  `docs/_reviews/act0_rule_based_repair_result_receipt_v1.md`
- Session repair summary:
  `docs/_reviews/act0_session_repair_summary_v1.md`
- Telemetry truth:
  `docs/_reviews/act0_rule_based_repair_telemetry_truth_v1.md`

Together, these artifacts document the current chain:

`missed signal -> visible repair reason -> repair attempt -> fixed/repeated receipt -> session repair summary`

## 5. Test Evidence

No new proof test was added in this wave.

Reason: the current focused tests already prove each required dimension and the
main product sequence through the existing real shell harness. Adding another
test would duplicate the same resolver/feedback path without increasing
meaningful product confidence.

Targeted tests to rerun for this packet:

- `test/ui_v2/act0_repair_intent_contract_v1_test.dart`
- `test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
- `test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart`
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`

Verification run:

- `flutter test test/ui_v2/act0_repair_intent_contract_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart test/ui_v2/act0_telemetry_sink_v1_test.dart --reporter expanded`
  - passed, `+55`
- `flutter analyze`
  - passed, no issues found
- `git diff --check`
  - passed
- `./tools/fast_loop_world1_v1.sh`
  - passed, `FAST LOOP PASS`

Final verification status: passed.

## 6. Copy Safety

Status: proven by copy-guard and resolver tests.

Forbidden language remains blocked or absent:

- AI
- adaptive
- GTO
- solver
- optimal
- win-rate
- guarantee / guaranteed
- premium
- paywall
- trial
- unlock
- leak detected
- mastered forever

The packet does not introduce new learner-facing copy.

## 7. Telemetry Safety

Status: proven by existing targeted telemetry regression tests.

Current telemetry truth:

- no new telemetry owner;
- no network telemetry;
- `user_choice` is emitted before `task_result`;
- required `user_choice` fields are preserved:
  - `schemaVersion`
  - `worldId`
  - `lessonId`
  - `taskId`
  - `choiceId`
  - `decisionTimeBucket`
  - `attemptOrdinal`
- repair completion events remain local and existing-owner only.

## 8. UX / Commercial Implication

Sharky now has a deterministic first-session repair-proof spine:

`I made a mistake -> Sharky showed the table clue -> I repaired it or saw it still needs work -> Sharky summarized the next focus.`

This is enough to proceed to a surface-level `10/10` coherence audit.

It is not enough to launch public premium, public paywall, public trial,
pricing, purchase, restore, Premium Hub activation, or App Store marketing.

## 9. What Was Intentionally Not Changed

- No route.
- No Modern Table visual work.
- No table geometry change.
- No commerce, premium, paywall, pricing, purchase, restore, trial, or Premium
  Hub work.
- No dashboard.
- No full leak profile.
- No Practice / Review / You / Learn UX coherence pass yet.
- No generated screenshots or proof outputs committed.
- No content expansion.
- No workflow changes.
- No `external_competitors/` changes.
- No Runout docs, assets, binaries, screenshots, or extracted materials.

## 10. Remaining Honest Gaps

- Multi-result repair aggregation remains deferred. Current summary proof covers
  the active / most-recent repair result, not a session-wide rollup across
  multiple distinct signals.
- Home / Learn / Practice / Review / You / result / summary / premium surfaces
  still need a full UX/UI coherence audit before claiming a top-tier surface.
- Pills / chips / compact proof cards need a design-language audit before any
  broad polish pass.
- Live UX benchmark and public marketing proof remain later work.

## 11. PR Readiness Verdict

Ready for PR.

## 12. Exact Next Wave

`Full Surface 10/10 UX/UI Coherence Gate v1`

This next gate should be an audit/spec wave first, not immediate visual
implementation.
