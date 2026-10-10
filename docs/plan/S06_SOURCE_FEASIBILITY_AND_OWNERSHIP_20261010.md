# S06 source feasibility and ownership - 2026-10-10

Inspection baseline: main `8c6d780b394685a9f663c305ce8c90a24c7d337d`, tree `959ca3440d3d72334b008e58a336e632ac9c2ab2`. S05 merged via #258; all five internal checks SUCCESS on exact head 11c5b28c69f336097d29d4e206931b7cab76e0a0. No local product tests or native runs were executed for this planning document. Static source inspection supports ownership, not runtime acceptance.

## 29-state crosswalk (not 29 engineering tasks)

Paths below are relative to `lib/ui_v2/act0_shell/`. Decision = final approved table-boundary override. KEEP keeps behavior/state while consuming the shared academy presentation where needed. REPLACE replaces presentation, never grading/progression. Wave is the primary implementation owner; shared grammar and failure states are tested in every later wave.

| State | Wave | Disposition | Current source entry | Actual source contract | Feasibility | Write role |
|---|---|---|---|---|---|---|
| `placement` | A | RESTRUCTURE | `act0_placement_shell_v1.dart` | Placement questions/result; preserve first-start owners | UI_ADAPTER_NEEDED | A1 |
| `welcome` | A | REPLACE | `act0_welcome_shell_v1.dart` | Welcome completion preferences; orientation, not demo assessment | UI_ADAPTER_NEEDED | A1 |
| `home` | A | RESTRUCTURE | `act0_home_shell_v1.dart` | Root recommendation + progressed Worlds; no demo debt flag | STATE_CONTRACT_MAPPING_NEEDED | A1 |
| `home_next` | B | RESTRUCTURE | `act0_shell_preview_screen_v1.dart` | Existing next-useful-hand receipt from actual queues/history | STATE_CONTRACT_MAPPING_NEEDED | I1 |
| `learn` | A | RESTRUCTURE | `act0_learn_path_shell_v1.dart` | Progressed worlds, selected lesson/task and locked gates | UI_ADAPTER_NEEDED | A1 |
| `worlds` | A | RESTRUCTURE | `act0_learn_path_shell_v1.dart` | Ordered actual lesson.taskList; no invented lesson inventory | UI_ADAPTER_NEEDED | A1 |
| `locked` | A | KEEP | `act0_learn_path_shell_v1.dart` | Actual world/lesson prerequisite; adapt presentation only | ALREADY_SUPPORTED | A1 |
| `theory` | A | RESTRUCTURE | `act0_lesson_runner_shell_v1.dart` | Authored teachingSteps and theory advance lock; F07 | UI_ADAPTER_NEEDED | I1 |
| `decision` | B | RESTRUCTURE | `act0_lesson_runner_shell_v1.dart` | Live runner options and unchanged table stage; not PNG | UI_ADAPTER_NEEDED | I1 |
| `decision_wrong` | B | KEEP | `act0_shell_preview_screen_v1.dart` | Alternate entry to same real task; never pre-seed wrong result | STATE_CONTRACT_MAPPING_NEEDED | I1 |
| `correct` | B | RESTRUCTURE | `act0_causal_feedback_contract_v1.dart` | Selected source option / grade; runner presents receipt | ALREADY_SUPPORTED | B1 |
| `wrong` | B | RESTRUCTURE | `act0_causal_feedback_contract_v1.dart` | Selected vs expected and exact missed signal | ALREADY_SUPPORTED | B1 |
| `repair` | B | RESTRUCTURE | `act0_repair_intent_contract_v1.dart` | Existing target world/lesson/task mapping; guidance flagged | ALREADY_SUPPORTED | I1 |
| `repair_outcome` | B | RESTRUCTURE | `act0_repair_outcome_projection_v1.dart` | Assisted correction distinct from independent proof | ALREADY_SUPPORTED | B1 |
| `summary_success` | B | RESTRUCTURE | `act0_lesson_runner_shell_v1.dart` | Act0BlockCompletionSummaryV1 and actual assessed boundaries | UNPROVEN_RUNTIME_ASSUMPTION | I1 |
| `summary_review` | B | RESTRUCTURE | `act0_lesson_runner_shell_v1.dart` | Actual assessed totals and Needs Review, not fixed 3/4 | STATE_CONTRACT_MAPPING_NEEDED | I1 |
| `practice` | B | RESTRUCTURE | `act0_play_shell_v1.dart` | Current practice groups / repair queue consumer | UI_ADAPTER_NEEDED | B1 |
| `review_active` | B | RESTRUCTURE | `act0_review_shell_v1.dart` | Review history/resolution and saved original signal; F09 | UI_ADAPTER_NEEDED | B1 |
| `review_notdue` | B | KEEP | `act0_durable_retention_contract_v1.dart` | Actual clock/history eligibility; optional guided practice | ALREADY_SUPPORTED | I1 |
| `review_due` | B | KEEP | `act0_durable_retention_contract_v1.dart` | dueItemsAt(widget.clock.nowUtc()); real eligible task | ALREADY_SUPPORTED | I1 |
| `review_empty` | B | RESTRUCTURE | `act0_review_shell_v1.dart` | Loaded valid sources with no active/due item; native unproven | UNPROVEN_RUNTIME_ASSUMPTION | B1 |
| `independent` | B | RESTRUCTURE | `act0_lesson_runner_shell_v1.dart` | Source review kind and assistance none; no Coach/hint | UI_ADAPTER_NEEDED | I1 |
| `independent_feedback` | B | RESTRUCTURE | `act0_learning_evidence_contract_v1.dart` | Actual completed decision, original attempt and review kind | ALREADY_SUPPORTED | I1 |
| `profile` | C | RESTRUCTURE | `act0_profile_shell_v1.dart` | Profile evidence consumer and insufficient-sample threshold | UI_ADAPTER_NEEDED | C1 |
| `return` | C | RESTRUCTURE | `act0_personalized_return_reason_v1.dart` | Existing fromSources + persisted last session, no urgency | ALREADY_SUPPORTED | C1 |
| `loading` | A | RESTRUCTURE | `act0_shell_preview_screen_v1.dart` | _bootSurfaceReady / _bootstrapFirstStartRouteV1 | STATE_CONTRACT_MAPPING_NEEDED | I1 |
| `error` | A | RESTRUCTURE | `act0_shell_preview_screen_v1.dart` | Typed transient boot failure/retry around existing restore | STATE_CONTRACT_MAPPING_NEEDED | I1 |
| `longcopy` | B | KEEP | `act0_content_copy_v1.dart` | Stress condition on existing causal copy, not new lesson | UNPROVEN_RUNTIME_ASSUMPTION | B1 |
| `settings` | C | REPLACE | `act0_profile_shell_v1.dart` | Existing first-start tools only; F11, no account promise | UI_ADAPTER_NEEDED | C1 |

## Exact producer/consumer boundaries

| Boundary | Existing source owner and symbol | Reuse / likely admitted writes |
|---|---|---|
| Canonical boot | app_root.dart `_EntryGate`; ui_v2_beta_shell.dart; act0_canonical_path_root_v1.dart `buildCanonicalPathRootV1` | KEEP default Act0 entry. No replacement by legacy map. Root locale supplied by AppRoot |
| Route and learner state | act0_shell_preview_screen_v1.dart `_Act0ShellPreviewScreenV1State`; tab enum/runner models in act0_shell_state_v1.dart | I1 exclusively binds shell callbacks to existing route/state. Preserve enums/IDs and entry ownership |
| Home reason | root `_learningRecommendation`, `_nextUsefulHandReasonReceiptV1`, `_homeNextUsefulHandReasonLine`; act0_personalized_return_reason_v1.dart `fromSources` | One read-only presentation adapter over these existing projections for Home/summary/return. No new recommendation service or HTML debt/correct model |
| Boot/loading/restore | root `_bootstrapFirstStartRouteV1`, `_bootSurfaceReady`, `_restorePersistedProgress` | Transient loaded/failed status around current operations; catch/report actual failure and retry without clear/reset. Null/corrupt payload handling must not fabricate success/empty |
| Persistence | root `_Act0PersistedProgressV1`, `_persistProgress`, `_writePersistedProgress`; SharedPreferences key act0_shell_progress_v1; act0_first_start_preferences_v1.dart | KEEP schema/generation fence. First-start flags separate. Do not persist transient summary as long-term achievement |
| Choice/grade/feedback | runner `_handleChooseOptionTelemetry`, `_decisionSubmittedForTaskV1`; act0_shell_state_v1.dart `Act0RunnerOptionV1`; act0_completed_decision_contract_v1.dart; act0_causal_feedback_contract_v1.dart | Single callback and source option IDs/quality. Preserve grade, assistance_kind, attempt and ready lock. Literal A/B/C in prototype are not engine IDs |
| Repair | act0_repair_intent_contract_v1.dart `Act0RepairIntentV1`; root mapping/open-repair target; act0_multi_repair_queue_v1.dart | KEEP exact source/target IDs, assistance and unresolved other debt. No second repair queue |
| Summary/progress | runner `Act0BlockCompletionSummaryV1`; root lesson-run evidence boundaries and completion consumer; act0_learning_run_payoff_v1.dart | Current-run payoff is deliberately transient. Project assessed totals/earned lesson completion separately from persisted history; positive native route still unproven |
| Review timing | act0_durable_retention_contract_v1.dart `dueItemsAt`; act0_durable_learning_time_contract_v1.dart `Act0SystemUtcClockV1`; act0_spaced_repetition_engine_v1.dart | KEEP current eligibility and elapsed-time source. No arbitrary clocks, due fixtures or accelerated review admitted |
| Review readable copy | act0_review_mistake_history_consumer_v1.dart `_readableAction`, source records; act0_review_shell_v1.dart | B1 translates source IDs through existing content atoms / source context, not underscore replacement; F09. Telemetry IDs remain unchanged |
| Telemetry | runner task/choice/result/feedback; root repair/payoff/route; act0_telemetry_sink_v1.dart; ACT0_TELEMETRY_TRUTH_MAP_v1.md | KEEP user_choice, correct/error_type, attempt_id, decisionTimeBucket. Timing is buckets, not new raw milliseconds. Local proof sink opt-in and non-release; no release analytics pipeline is inferred |
| Table/view bridge | runner build/`Act0AccessibilityPrototypeStepV1 {evidence, decision}`, `_AccessibilityDirectDecisionV1`; act0_learning_scene_v3.dart prompt/guide | Reuse existing measured evidence/decision seam; source-driven production adapter required. Never substitute S05 PNG. Existing fixed48px reader rows need flexible wrapping52px+ |
| Frozen rendering | runner table stage + act0_table_presentation_config_v1.dart; act0_scene_* files, scene hybrid shell, cards/cast/assets/choreography | No write owner admitted for geometry/art. Existing 1.0 render context remains. Shell bridge owner I1 must prove unchanged frame/coordinates |
| Coach | act0_sharky_presence_v1.dart, phrase contract/runtime copy; canonical 3q authority in assets/design/sharky_character_v1/references | One academy presenter uses unchanged framed authority. Current source maps moods to provisional neutral fallback; do not claim approved art already integrated. No table/cast art change or new state-art generation |

## Feasibility findings and bounded resolution

- **ALREADY_SUPPORTED:** source options/grading, causal feedback, exact repair intent, assisted vs independent evidence, persisted history, source-due eligibility and meaningful-return projections exist. No MATERIAL_ENGINE_GAP demonstrated in this bounded inspection. This is absence of a proven gap, not blanket engine completeness.
- **UI_ADAPTER_NEEDED:** V3 editorial hierarchy, one task/chapter shell, responsive source-fed reader and canonical framed Coach. Current dark Act0VisualCanon/Act0ShellTokens are shared by protected scene consumers: do not globally recolor them.
- **STATE_CONTRACT_MAPPING_NEEDED:** HTML starting choices -> real placement result; summary run/history scope; Home reason/target parity; failure/empty distinction. `decision_wrong` is a design entry fixture, not a production flag to fabricate a wrong answer. Mapping must retain source IDs such as two_three_six, not A.
- **UNPROVEN_RUNTIME_ASSUMPTION:** native positive summary, naturally empty Review, joined Result -> Home action, RU/large-text, reader-switch task lifecycle and exact frozen geometry. Prove at admitted candidate; do not promote browser checks to native.

Technical constraints resolved at planning level, with explicit S07 admission prerequisites:

1. Root currently hardcodes `_isRuLocaleV1 => false`; Home/Learn/Review/Profile also return false. Reuse AppRoot locale and act0 runtime/content copy atoms in the academy adapter; no second language controller. RU dictionary coverage needs source-bound tests.
2. Root currently clamps scale to 1.0 at lines 6620-6636; AppRoot upstream allows up to1.4. Future A1/I1 must scope scaling to academy/reader while keeping frozen table at its existing1.0 render context. S07 must explicitly admit this bounded policy update; no global unclamp changing table labels or geometry.
3. Existing reader enum/measured activation is usable, but current fixed48px rows and typography do not satisfy enlarged reader contracts. Replace reader presentation only, keep task state/callback/stopwatch. Inspection facts can be exposed in equivalent accessible semantics; never compute/highlight the correct answer.
4. No bundled `.ttf`/`.otf` or pubspec font registration was found; CSS Georgia/Arial is not a proven Flutter font identity. S07 must approve licensed native font provisioning or an evidenced platform fallback with matching hierarchy/line metrics, before A1 acceptance. No Google Fonts/network/dependency assumption.
5. Canonical 3q reference exists but is not registered in pubspec. Future A1 may register the exact unchanged framed reference after S07 asset admission; no transparent export, regeneration or new Coach variants are required. Current fallback remains on protected table consumers.
6. Release/default telemetry export is not enabled; proof sink is local opt-in/non-release. Later machine/native evidence must record that configuration, bounded capacity and full trace export. No production analytics service is added by this plan.

No material architecture contradiction remains unresolved in the plan: each conflict has one owner, bounded action and gate. Native font and scaling admission still require S07 verification; they are not silently considered completed.

## Write ownership and likely file scopes

- **I1 integration/route/bridge owner:** exclusive writer of act0_shell_preview_screen_v1.dart and act0_lesson_runner_shell_v1.dart throughout A -> B -> C. AppRoot/canonical root only if necessary for existing locale/scale propagation; no route swap. State/grade/repair/time/telemetry owner files are read-only by default. A proven mapping defect needs a separately bounded amendment before edits.
- **A1 first-value UI owner:** placement/welcome/home/learn-path/chrome/copy and proposed `act0_academy_design_tokens_v1.dart` + `act0_academy_shell_v1.dart`. These proposed files do not yet exist. One token authority; unchanged old scene-token modules remain. Pubspec may register approved static assets/fonts only after S07; no dependencies. Root/runner changes supplied as a patch to I1.
- **B1 learning/repair UI owner:** practice/review, causal presentation/reader/summary within I1-owned runner through a patch; Review readable copy consumer. No grading/queue/scheduler rewrite.
- **C1 return/profile UI owner:** profile, academy Coach presenter and non-guilt copy; existing return/profile evidence projections consumed without changing thresholds. Root callback patch to I1.
- **Q1 acceptance owner:** source-bound functional/widget/native evidence and final independent verdict; tests/evidence can be prepared separately, but no production file overlap.

Parallelism: after A1 shared token/component interface is merged, separate UI leaves or acceptance work may proceed. Root, runner, shared token/chrome/copy and asset registry always have one serialized write owner. No competing Flutter PRs or concurrent engine edits.
