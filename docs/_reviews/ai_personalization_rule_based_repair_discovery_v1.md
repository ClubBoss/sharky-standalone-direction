# AI Personalization / Rule-Based Repair Discovery v1

Date: 2026-06-18
Mode: audit-first, docs-only
Scope: deterministic Act0 repair / personalization seams only

## 1. Wave Admission

Admitted as an audit-only discovery and contract pass for the next active arc:

`AI Personalization / Rule-Based Repair Layer v1`

No product code, UI/copy, routes, content, tests, telemetry implementation,
commerce, entitlement, paywall, Premium Hub, screenshots, Playwright tooling,
table geometry, or localization changes were made.

Strategic boundary:

- Use the locked top-1 route: `user choice -> visible table signal -> clear why -> repair or transfer`.
- Keep all behavior deterministic and explainable.
- Do not introduce fake AI/adaptive/ML, GTO/solver, guaranteed improvement, or win-rate claims.
- Do not reopen monetization, route truth, premium preview, screenshot proof, W4/W5 boundary, trial, or commerce debates.

## 2. Evidence Reviewed

Active SSOT and locks:

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/plan/MONETIZATION_SSOT_v1.md`
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`
- `docs/plan/MONETIZATION_TIMING_GUARD_v1.md`
- `docs/_reviews/top1_product_attack_plan_lock_v1.md`
- `docs/_reviews/monetization_route_truth_ssot_lock_v1.md`
- `docs/_reviews/compact_english_premium_preview_proof_v1.md`

Repair / personalization references:

- `docs/plan/ACT0_TELEMETRY_TRUTH_MAP_v1.md`
- `docs/plan/LEAK_MAP_AND_RECOMMENDATION_SYSTEM_SSOT_v1.md`
- `docs/plan/SKILL_GRAPH_PROGRESS_MAP_SSOT_v1.md`
- `docs/content/DRILL_CONTRACT_v1.md`
- `docs/content/CONTENT_EXCELLENCE_CANON_v1.md`
- `docs/_reviews/first_return_day2_persistence_contract_audit_v1.md`
- `docs/_reviews/repair_loop_coverage_matrix_v1.md`
- `docs/_reviews/repair_transfer_quality_audit_v1.md`

Active code seams inspected:

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_telemetry_sink_v1.dart`
- `lib/models/evaluation_result.dart`
- `lib/models/error_entry.dart`
- `lib/models/session_task_result.dart`
- `lib/models/mistake_pack.dart`
- `lib/services/personalization_hint_v1.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`
- `test/services/personalization_hint_v1_test.dart`

## 3. Existing Data Contracts

### Runner / answer contract

Active Act0 runner state has the necessary local facts for a deterministic
repair contract:

- `Act0RunnerStateV1`: `lessonId`, `beatIndex`, `phase`, `question`, `options`, `selectedOptionId`, `feedbackTitle`, `feedbackReason`, `table`.
- `Act0RunnerOptionV1`: `id`, `label`, `seatId`, `isCorrect`, `preferredLabel`, `betterAnswerLabel`, `quality`, `feedbackTitle`, `feedbackReason`, `repairFocusSeatIds`, `repairFocusCardIds`, `repairFocusLabels`.
- `Act0FeedbackQualityV1`: `correct`, `wrong`, `suboptimal`.
- `Act0TaskFamilyV1`: includes `decision`, `sizing`, `repair`, `review`, `transfer`.

This is enough to say:

- what the user chose: `selectedOptionId`, `selectedLabel`, `option.id`;
- whether the result was correct: `option.isCorrect`, `quality`;
- what the better answer was: `betterAnswerLabel`;
- why: `feedbackReason`;
- what visible repair clue was intended: `repairFocus*` or derived table signal.

Gap:

- `errorType` is currently emitted as `none` or `unknown` in active Act0 `task_result` telemetry. There is no Act0-wide controlled error taxonomy yet for `incorrect_seat`, `missed_price`, `missed_board`, etc.
- Severity exists as review labels (`Quick fix`, `Needs repair`, `Deep leak`, `Recheck`) and retention statuses, not as a normalized contract field on the original answer event.
- Confidence is not present in active Act0 repair state. Older/non-active models have fields such as `EvaluationResult` equity/EV and `ErrorEntry.errorType`, but those are not the canonical Act0 learner route.

### Table-signal contract

Active table signal derivation exists in `Act0LessonRunnerShellV1`:

- `Act0FeedbackSignalProofV1`: `signalId`, `label`, `proofLine`, `seatIds`, `cardIds`, `statKeys`.
- `_feedbackSignalProofForRunnerV1(...)` derives visible clues from repair focus metadata, target seat, table text, board cards, pot/to-call, and no-bet/check state.
- `_skillReceiptForSignalProofV1(...)` converts a signal into `skillAtomId`, `skillLabel`, `sourceSignalId`, `sourceSignalLabel`, `outcome`, `nextRepId`, and `nextRepLabel`.

Current signal families include:

- `hero_button` -> table-position read
- `hero_cards` -> starting-hand read
- `board_cards` -> board read
- `no_bet_yet` -> action read
- `pot_to_call` -> price read
- `hero_cards_board_pot` -> table read

Gap:

- Signals are derived in runner/helper code, not authored as a stable metadata field on every task. This is acceptable for MVP if the next wave creates a small deterministic repair-intent adapter around the current derivation rather than inventing a broad metadata migration.

### Skill / world / lesson mapping

Act0 tasks carry stable `worldId`, `lessonId`, and `taskId` through the shell and telemetry. `Act0SkillReceiptV1` gives a compact bridge from visible signal to skill atom and next rep. Profile state also tracks skill gains and weak/strong categories, but these are summary surfaces, not the repair queue authority.

Gap:

- There is no single public `RepairIntent` / `PersonalizationDecision` object that joins source task, selected choice, missed signal, skill atom, target task, and reason code.

## 4. Existing Repair / Review Seams

### Creation

Wrong or suboptimal answers flow through `_recordAnswer(...)` in
`Act0ShellPreviewScreenV1`.

On misses, the shell writes:

- `_mistakeRecords[sourceTaskId]`
- `_retentionMemoryByTaskId[sourceTaskId]` with status `openRepair`
- selected option id/label
- better label
- hardened reason
- context labels
- repair action label
- attempts

Debug/proof helpers can also seed `_Act0MistakeRecordV1` directly.

### Surfacing

Review is owned by `Act0ReviewShellV1` and `Act0ReviewStateV1`.

Open repair cards show:

- selected vs better answer
- title
- weakness label
- reason
- context labels
- repair action CTA

`_openMistakes()` sorts open mistakes by severity and attempts. `_fixedMistakes()` surfaces repaired/recheck/prove states from mistake records and retention memory.

Home and Practice can surface the same repair pressure through top open mistake / first-value carry / weak-spots practice group logic.

### Launching

Repair launch uses `_startRepair(...)`.

Resolver behavior:

- retention replay for `agedRecheck` / `ownedCandidate`;
- allowlisted mapped repair target via `_repairVariantTargetForSourceV1(...)`;
- exact source replay fallback.

Same-signal first-value launch uses:

- `_Act0FirstValueReceiptCarryV1`
- `_firstValueDailyRepTargetV1(...)`
- `act0FirstValueSameSignalRepMappingV1(...)`

Current first-value mappings include action/no-bet, board, price, starting hand,
table read, and table-position read.

### Completion

Correct repair:

- adds source and target to clean task ids;
- adds source task to `_resolvedMistakeTaskIds`;
- changes retention memory to `fixedRecent`;
- emits repair completion telemetry;
- enables repaired proof in Review.

Incorrect repair:

- keeps or reopens `_mistakeRecords`;
- increments attempts;
- sets retention memory to `openRepair`;
- can classify repeated misses as deeper repair pressure through run-local sets.

Gap:

- The lifecycle is strong enough, but the reason for target selection is currently implicit in resolver branches and telemetry `mappingType`. The product cannot yet say a complete deterministic sentence like: "This rep was chosen because `sourceTaskId` missed `no_bet_yet`, which maps to `actions_check_drill` by `same_signal_action_read_v1`."

## 5. Existing Telemetry Seams

Active local-only telemetry seam:

- `Act0TelemetryEventV1`
- `Act0TelemetrySinkV1`
- `Act0InMemoryTelemetrySinkV1`

Implemented / observed Act0 events include:

- `task_shown`
- `task_result`
- `feedback_viewed`
- `repair_started`
- `repair_completed`
- `repair_item_shown`
- `repair_item_started`
- `repair_item_completed`
- `practice_started`
- `practice_completed`
- `first_value_today_shown`
- `first_value_today_consumed`
- `first_value_daily_rep_launched`
- `recheck_completed`
- `prove_completed`

Useful existing payload fields:

- `worldId`, `lessonId`, `taskId`
- `choiceId`
- `result`
- `errorType`
- `repairStatus`
- `feedbackSignal`
- `tableSignal`
- `skillReceiptId`
- `skillAtomId`
- `nextRepId`
- `sourceTaskId`
- `repairTaskId`
- `targetTaskId`
- `mappingType`
- `missedSignal`
- `correct`

Gaps:

- `user_choice` is defined in the telemetry truth map but not clearly emitted by the active Act0 runner path inspected here; active runner emits `task_result` with `choiceId`.
- `decisionTimeBucket` / `time_to_decision` is planned in the telemetry truth map but not wired in the active Act0 runner seam.
- `errorType` is still too generic (`unknown`) for a truthful rule-based repair layer.
- `repair_item_*` events are useful but are not yet an explicitly documented public event contract in `ACT0_TELEMETRY_TRUTH_MAP_v1`.
- Telemetry is observability, not the product state contract. The next implementation should use the same fields in a local deterministic repair-intent object, then optionally mirror them to the local sink.

## 6. Personalization Candidate Seams

### Candidate A: Act0 repair-intent adapter

Create a small deterministic adapter near the Act0 shell/runner boundary that builds:

- source world/lesson/task
- selected choice id
- correctness/result
- normalized error type
- feedback signal id/label
- skill atom id/label
- source reason code
- target world/lesson/task
- mapping type
- user-facing explanation seed, without storing copy

Verdict: best MVP seam.

Why:

- It joins existing data without broad refactor.
- It makes the recommendation auditable.
- It can power Review, Home, Practice, and telemetry consistently.
- It can stay local, deterministic, and non-AI.

### Candidate B: Expand `_Act0MistakeRecordV1`

Add fields directly to the existing private mistake record:

- `errorType`
- `missedSignalId`
- `skillAtomId`
- `repairTargetTaskId`
- `repairReasonCode`

Verdict: useful but should probably be fed by Candidate A, not become the only logic owner.

Why:

- The mistake record is already central for Review.
- However, stuffing resolver logic into the record risks making persistence and display state own routing truth.

### Candidate C: Telemetry-first event expansion

Add richer telemetry fields and use them for personalization later.

Verdict: not the MVP.

Why:

- Telemetry should not own route behavior.
- Privacy posture remains local-only.
- The learner-facing route needs deterministic state even when telemetry sink is null.

### Candidate D: Dormant legacy personalization / mistake services

Reuse older services such as `personalization_hint_v1`, mistake replay pack generators, or broad analytics-style services.

Verdict: do not use as active owner.

Why:

- Active topology marks Act0 shell as the learner-facing route owner.
- Older services can be references, but they do not carry Act0 table-signal proof, first-value carry, or current repair lifecycle.

## 7. Minimal MVP Recommendation

Recommended next implementation wave:

**Act0 Deterministic Repair Intent Contract v1**

Goal:

Make the product state able to answer, from one local object:

1. "You missed this table clue."
2. "Your next useful hand repairs the same clue."
3. "This is why this rep was chosen."

Minimal contract shape:

| field | source |
| --- | --- |
| `schemaVersion` | constant `1` |
| `sourceWorldId` | selected world |
| `sourceLessonId` | selected lesson |
| `sourceTaskId` | selected task / repair source |
| `choiceId` | `Act0RunnerOptionV1.id` |
| `result` | `correct`, `incorrect`, `suboptimal` from option/quality |
| `errorType` | new deterministic enum from option/signal/task family |
| `missedSignalId` | `Act0FeedbackSignalProofV1.signalId` |
| `missedSignalLabel` | `Act0FeedbackSignalProofV1.label` |
| `skillAtomId` | `Act0SkillReceiptV1.skillAtomId` |
| `skillLabel` | `Act0SkillReceiptV1.skillLabel` |
| `targetWorldId` | mapped repair / same-signal target |
| `targetLessonId` | mapped repair / same-signal target |
| `targetTaskId` | mapped repair / same-signal target |
| `mappingType` | `exact`, `mapped`, `replay`, `repair`, `reinforcement` |
| `reasonCode` | e.g. `same_signal_action_read_no_bet`, `exact_source_replay`, `retention_recheck` |

MVP rules:

- Build the object in memory first.
- Use existing Act0 signal proof and same-signal mapping helpers.
- Keep targets allowlisted.
- Keep fallback as exact replay.
- Do not add network telemetry, dashboard, vendor analytics, ML, AI coach/chat, paywall/trial logic, or broad content migration.
- Do not expose raw labels/copy in telemetry; labels may remain local UI state only.

Expected immediate product value:

- Review can show a clearer deterministic "why this repair" line later.
- Home can choose "next useful hand" from the same contract instead of scattered resolver state.
- Practice daily set can prioritize open repair / same-signal target without claiming adaptivity.
- Tests can assert target selection by stable IDs and reason codes.

## 8. Risks / Missing Contracts

1. `errorType` is not normalized.
   - Current active result telemetry uses `unknown` for incorrect answers.
   - Next wave needs a small enum derived from signal/task family, not free text.

2. Signal derivation is partly heuristic.
   - `_feedbackSignalProofForRunnerV1(...)` is useful, but it derives from table text and labels when explicit focus metadata is absent.
   - MVP should prefer `repairFocus*` and known signal IDs, then use current fallback only for compatibility.

3. Repair target reason is implicit.
   - Mapping functions return target and mapping type, but not a stable reason code.

4. Open repair details are partly non-durable.
   - Retention memory persists open/fixed status, but rich original mistake card details may be reconstructed.
   - This is acceptable for MVP if the repair-intent object is initially in-memory, but a future persistence wave should decide whether to store a compact sanitized intent.

5. Decision timing is not active.
   - `decisionTimeBucket` is planned, but current runner path does not supply it.
   - Do not block MVP on timing; add `unknown` later only if telemetry/user-choice wave is admitted.

6. World route labels and monetization boundaries must stay untouched.
   - W1-W4 free public foundation and W5+ future paid-depth boundary remain locked.
   - No premium/trial/paywall logic belongs in this repair contract.

## 9. What Not To Build Yet

- No AI coach/chat.
- No ML or adaptive model.
- No GTO/solver/optimal-frequency claims.
- No win-rate, guaranteed improvement, or permanent mastery claims.
- No broad analytics dashboard.
- No vendor telemetry integration.
- No privacy-sensitive identifiers.
- No Skill Map UI expansion.
- No Leak Profile public surface.
- No route order rewrite.
- No W4/W5 monetization/content normalization.
- No paywall, trial, price, restore, purchase, Premium Hub, commerce, or entitlement work.
- No screenshot/tooling/table-geometry work.
- No content rewrite or new dependency.

## 10. Files Changed

Created:

- `docs/_reviews/ai_personalization_rule_based_repair_discovery_v1.md`

No other files were intentionally changed.

## 11. Verification

Required:

- `git diff --check`

Not required:

- tests, because this is a docs-only audit;
- screenshots, because no UI, copy, route, or visual surface changed.

## 12. Recommended Next Wave

Run:

**Act0 Deterministic Repair Intent Contract v1**

Bounded implementation scope:

1. Add a small private/local contract and pure builder for repair intent.
2. Feed it from existing runner option, feedback signal proof, skill receipt, and repair target mapping.
3. Add focused unit/widget tests proving:
   - wrong answer produces `missedSignalId`, `skillAtomId`, `errorType`, `targetTaskId`, and `reasonCode`;
   - same input produces same target and same reason code;
   - fallback exact replay stays deterministic;
   - forbidden copy/commerce/AI fields do not enter telemetry payloads.
4. Do not change user-facing copy in that wave unless the user explicitly admits a later UI surface wave.

Acceptance target for that next wave:

The app can internally produce a deterministic explanation packet for one missed
table clue and one next useful repair hand, without claiming AI and without
changing monetization, route, premium preview, or public commerce behavior.
