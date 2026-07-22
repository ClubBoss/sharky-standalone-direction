# Post-Merge AI Personalization Re-entry v1

Status: implementation-ready planning record; no product implementation in this
change.

## Canonical main and stale-authority reconciliation

- Canonical main and `origin/main`: `6b6a6894909e780a17ca072eeff14fee9d8efbc4`.
- Reviewed heads are ancestors: Action continuity `76b175eb064d7d9def8644055fc67e5ac77ffedb`, privacy `75727018550e0e343e4affc52b9f2b128f08a2e9`, onboarding `76c62aa94c505aaba1571c405b8c894c9bfd0ed7`.
- Stack merges: `f5b5a702` (PR #33), `d70ad7c5` (effective privacy PR #36), and `6b6a6894` (effective onboarding PR #37). PR #35/#34 were superseded only by stale GitHub synthetic PR state; reviewed heads were preserved.
- Action theory-to-decision continuity, canonical `misread_action_legality`, bounded HNP privacy projection, required learning-loop telemetry, and Onboarding Density & Confidence Wave 1 are integrated. Independent source review and required remote product CI passed. Claude Design verdict: `WAVE1_VISUAL_ACCEPTED_WITH_NONBLOCKING_P3`.

The route capsule's former local pre-audit, blocked-publication, and downstream-personalization statements are historical evidence, not execution authority. Its opening section now names canonical main and exactly one active stage: **AI Personalization Layer v1**.

## Claim boundary

Human Novice Proof has not occurred. Screenshots, tests, telemetry, and AI review are not participant evidence and do not establish learner comprehension, accessibility certification, release readiness, or whole-product visual 10/10. Modern Table is Maintenance Mode. Premium Motion, further visual waves, ML/remote AI, dashboards, and screenshot-pipeline product claims remain deferred.

## Existing personalization inventory

| Area | Canonical owner and verified behavior |
| --- | --- |
| Decision and feedback | `Act0LessonRunnerShellV1` records actual user choice, canonical decision projection, feedback, and result. |
| W1 Action | `Act0ActionSequencePersonalizationPolicyV1` and `Act0ActionSessionPayoffPolicyV1` own session-scoped action-legality recommendation and payoff. |
| Integrated families | `Act0PositionPersonalizationV1` owns W3 Button/`hero_button`; `Act0PricePersonalizationV1` owns W4 `pot_to_call`. |
| Concept errors | `act0_concept_error_contract_v1.dart` owns canonical concept identities; legacy `missed_*` values are compatibility aliases only. |
| Repair/recheck | `Act0RepairIntentV1`, its resolver, and `act0_repair_gap_adjudication_v1.dart` select an approved same-signal target or intentional exact replay. |
| Payoff and continuation | `Act0LearningRunPayoffV1` owns generic session-local normalized payoff; `Act0PersonalizedReturnReasonV1` and `Act0ShellPreviewScreenV1` own one evidence-backed Home/Learn continuation. |
| Telemetry | `Act0TelemetrySinkV1` owns bounded events; opt-in non-release `Act0HnpTelemetrySinkV1` writes local JSONL without the forbidden Action context key. |
| Route fixtures | Fresh install starts in W1 with Action locked; the unlocked Action recovery fixture requires production-equivalent prerequisite completion. |

Legitimate inputs: route/task identity, placement classification/recommended start, choice, correctness, canonical error, missed signal/skill, repair and recheck result, decision-time bucket, and session/run evidence. Outputs: clue-specific feedback, repair/exact replay, recheck, clean/recovered/unresolved payoff, and Home/Learn continuation. Covered family-specific contracts: W1 action legality, W3 Button position, W4 price read. Contract-compatible but not family-specific: W2 starting-hand discipline, W5 board texture/draws, and later canonical-error families. Dormant `lib/personalization/*`, generic aliases, and profile copy are not authorities.

Focused proof already exists under `test/ui_v2/` for Action, Position, Price, repair intent, personalized return, Learning Run/payoff, telemetry/HNP, and fresh/unlocked routes.

## Top-3 unfinished macro comparison

| Candidate | Evidence and learner value | Readiness, risk, and dependency | Decision |
| --- | --- | --- | --- |
| AI Personalization Layer v1 | Three integrated families prove choice -> clue feedback -> repair -> recheck -> payoff -> continuation. | Exact owner pattern and bounded telemetry are ready. A fourth family is contained and needs no Human Novice for deterministic admission. | **Next.** Master Plan first step and highest-EV evidence-backed expansion. |
| Learning Effect / Training Flow | Repair, payoff, retention, and return signals exist, but no participant learning-effect result. | Needs a stable next vertical plus a claim-safe measurement design; telemetry alone is not proof. | Wait. |
| Minimal End-to-End Alpha / human-proof preparation | Fresh/unlocked fixtures and HNP trace exist; live GUI proof remains distinct from fresh-install behavior. | Must validate a stable integrated loop; Human Novice dependency applies only to human claims. | Wait. |

Deferred, not competitors: Hub visual differentiation, feedback animation, new Sharky runtime states, Premium Motion, onboarding empty-space P3, Modern Table polish.

## Selected vertical: W2 starting-hand discipline

### Learner problem, route, and owner map

The learner can see a medium preflop hand and facing action yet continue on hope instead of hand/seat/frame evidence. Source: `world_2` / `hand_discipline_apply` / `apply_hj_decision`. Approved same-signal target: `world_2` / `continue_or_let_go` / `continue_or_let_go_medium_call_or_fold`. Existing route: Act0 Learn runner -> feedback -> repair -> recheck -> generic payoff/return. This does not alter fresh-install gating.

Source owners:

- `act0_shell_state_v1.dart`: source/target task and correct-answer truth.
- `act0_concept_error_contract_v1.dart`: `misread_starting_hand_discipline`.
- `act0_repair_gap_adjudication_v1.dart`: approved alternate mapping.
- `act0_repair_intent_contract_v1.dart` plus resolver: intent/target resolution.
- `act0_lesson_runner_shell_v1.dart`: choice, feedback, decision-time bucket, event ownership.
- `act0_learning_run_payoff_v1.dart`, `act0_personalized_return_reason_v1.dart`, `act0_shell_preview_screen_v1.dart`: generic payoff/continuation consumption.
- `act0_telemetry_sink_v1.dart`: bounded event sink.

### Implementation-ready contract

Add one typed W2 adapter following the Position/Price pattern only when the resolved intent exactly matches source world/lesson/task, canonical error, W2 discipline skill/signal, target world/lesson/task, and `mappingType == repair`. It accepts no profile history, remote data, raw milliseconds, or mutable copy. A nonmatching intent falls back to the existing resolver rather than being reclassified.

Rules: correct first decision yields `hand_discipline_read_cleanly`; an incorrect source decision names the medium hand, HJ, and facing-action clue and starts the approved target; a correct recheck yields `hand_discipline_recovered`; a failed recheck yields `hand_discipline_still_needs_rep`. These are current-session outcomes, never mastery labels. Generic Learning Run keeps unresolved evidence above recovered then clean evidence; the existing Home/Learn receipt owns continuation. No new surface, tab, dashboard, or profile card.

Persistence is session-scoped for the adapter. Existing durable repair/concept evidence may flow through its present contract; add no personalization profile, cross-day model, or recommendation history.

### Telemetry contract

Preserve ordered existing events: `user_choice`, decision and `task_result` (choice, correctness, canonical error, decision-time bucket), `feedback_viewed`, repair start, recheck, generic normalized Learning Run outcome/payoff, then session completion or explicit exit. Family fields must be stable sequence/skill/error/signal/phase/mapping/outcome values following the existing family pattern. Do not emit raw cards, copy/context labels, identity/network data, exact milliseconds, or the forbidden Action context key. HNP JSONL remains opt-in, local, non-release, and projection-bounded.

### UI, forbidden scope, tests, evidence, and DoD

UI impact is existing feedback/repair/recheck/payoff/continuation only; preserve route, scoring, authored tasks, and correct answers. Forbidden: fresh unlock changes, Modern Table, visual redesign, ML/remote service, dashboard, new persistence, telemetry refactor, another family, W5+ work, Human Novice, or release claims.

Required deterministic tests: typed-adapter admission/rejection; correct-first; wrong -> feedback -> repair -> successful recheck; wrong -> failed recheck; duplicate/replay/incomplete handling; Learning Run payoff precedence; return recommendation agreement; bounded telemetry/physical HNP projection. Re-run Action, Position, Price, and fresh/unlocked route regressions.

Native evidence after implementation: real Act0 route traversal at compact, tall, and large phone sizes showing the W2 loop, plus HNP-enabled local JSONL validation with its named dart-define. It is machine/native evidence only.

Definition of Done: one canonical typed W2 decision owner; source and repair truth unchanged; deterministic paths pass; one visible loop works in one session; telemetry is ordered, bounded, privacy-safe; no unapproved source/test/workflow/dependency/platform drift; no human or release claim. Stop/rollback on absent exact mapping, source/correct-answer conflict, required new persistence/schema, cross-family owner conflict, Modern Table dependency, or inability to preserve fresh-install/unlocked split.

## Deferred ledger

After this one slice: Learning Effect / Training Flow, minimal E2E Alpha, bounded telemetry closure, and Alpha admission evidence in Master Plan order. Human Novice remains a separate future participant gate. Visual, motion, hub, mascot, Modern Table, dashboard, ML/remote AI, and broad-content work stay deferred.
