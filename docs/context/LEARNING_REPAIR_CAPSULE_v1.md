# Learning Repair Capsule v1

Status: ACTIVE learning/repair capsule.
Freshness date: 2026-07-03.
Verified product HEAD: pending commit (this task's own commit advances it).
Verified active route artifact: `docs/_reviews/sharky_saw_you_improve_v1.md`.
Refresh trigger: every committed learning-loop, repair, proof, Practice,
Review, Session Summary, telemetry, or learning-claim change.

## Phase 7 Content Depth Gate

`W1-W12 Content Depth Gate v1` closed with
`w1_w12_content_depth_ready_with_optional_gaps`. The current W1-W12 route has
enough content depth to advance to `Term Introduction / Glossary Audit v1`, but
the result does not certify poker correctness, Human QA, launch readiness,
public learning effect, premium readiness, or mastery.

World matrix summary:

- W1-W2 and W4 are content-depth ready for the current route.
- W3, W5, W6, W8, W10, W11, and W12 are route-ready with optional gaps.
- W7 and W9 are route-ready for their active owner specs.
- W11/W12 now have source-owned packets and campaign fixtures, but not broad
  `drills/*.json` corpus parity with W1-W10.

Thin concepts and repair candidates are deferred, not active implementation:
W3 raw drill density, W5/W8 draw-term first use, W6 range scope boundaries,
W10 value/bluff nuance, W11/W12 drill-corpus parity, and per-family
same-signal/transfer inventory. Route impact is capsule-only: content depth is
closed, glossary/term introduction is active, Practice mapping remains blocked,
W13+ remains closed, and no learner-facing repair or proof claim changes.

## Phase 7 Term Introduction / Glossary Audit

`Term Introduction / Glossary Audit v1` closed with
`term_introduction_glossary_ready_with_optional_gaps`. Existing lightweight
ownership is sufficient: `content/_meta/term_introduction_contract_v1.json`
owns priority first-use definitions, `tools/term_coverage_scanner.dart`
enforces ordering, and lesson-local definitions remain preferred over glossary
UI.

High-risk terms were classified as route-safe with optional gaps: W5/W8 draw
language, W6/W7 range language, W9 price/pot-odds language, W10 value/bluff
target language, W11 texture/danger language, and W12 review/process language.
Scanner-owned terms pass first-use order: `EQUITY`, `PROBE`, `BLOCKERS`,
`OUTS`, `OOP`, `PAIRED`, `SPR`, `ICM`, `EV`, `EXPLOIT`, and `COMBO`.
Reference-only `PFA` and `DB` remain excluded from active learner content.

Deferred glossary/watch items: compact seat labels (`SB`, `BB`, `BTN`, `CO`),
late `UTG`, `one-gap`, and `No-bet-yet clue`. No learner-visible
concept-family ids, route ids, snake_case, telemetry keys, or source task ids
were found in screenshot lanes. Route impact is capsule-only: glossary audit is
closed and advanced to `Same-Signal / Transfer Coverage Audit v1`; later route
state is recorded below. Practice mapping remains blocked, W13+ remains closed,
and no learner-facing proof claim changes.

## Phase 7 Same-Signal / Transfer Coverage Audit

`Same-Signal / Transfer Coverage Audit v1` closed with
`same_signal_transfer_coverage_ready_with_optional_gaps`. The admitted W1-W12
route has enough same-signal, changed-context, and later-transfer evidence to
advance to `W1-W12 Poker Correctness Review v1`, but this does not certify
poker correctness, Human QA, launch readiness, public learning effect, Practice
target admission, or W13+.

Concept-family matrix summary:

- W1-W2 and W4 are same-signal/transfer ready for current route claims.
- W3, W5, W6, W8, W10, W11, and W12 are route-ready with optional gaps.
- W7 and W9 are route-ready for their active owner specs.
- W7-W12 each keep a source-owned four-task arc with a later transfer/checkpoint
  task, while Practice CTA and mapper target admission remain blocked.

Transfer-thin families and exact-repeat risks are deferred, not active
implementation: W3 raw drill density, W5/W8 draw-term and draw-example nuance,
W6 broad range-scope claims, W10 value/bluff nuance, W11/W12 drill-corpus
parity, and W7-W12 Practice target mapping. No family was found to be
exact-repeat-only for route advancement.

Repair-to-transfer chain result: source-backed miss, repair focus, repair
outcome, Review resolution, later same-family transfer evidence, Fix Proof,
Profile proof, and Sharky acknowledgement are available for admitted
source-backed families. The chain remains conservative: same-task, same-session,
different-family, unsafe-order, malformed, duplicate, and unmapped evidence fail
closed.

Mapper/Practice relationship: W1-W6 mapping policy remains unchanged and the
only default concept-candidate mapper target is the source-owned W1 no-bet-yet
target. W7-W12 remain route-locked no-target for Practice/mapper purposes.
Spaced repetition remains engine-ready but consumer-blocked without exact
source-owned target tuples.

Route impact is capsule-only: same-signal/transfer audit is closed,
`W1-W12 Poker Correctness Review v1` is active, Practice mapping remains
blocked, W13+ remains closed, and no learner-facing proof or Practice claim
changes.

## Canonical Learning Loop

`choice -> visible table signal -> why -> repair -> proof -> return reason`

Every learner-facing improvement claim must map back to this loop or name the
reason it is not an improvement claim.

## Accepted Durable Truth

- Concept-family state uses source-owned family ids and raw outcomes; it does
  not create mastery or a score.
- Session identity is local, deterministic, persisted, and ordered across
  source-backed evidence.
- Transfer measurement is conservative local evidence, not causal proof of
  practice transfer or a public learning-effect claim.
- Personalized return reasons are deterministic explanations, not scheduling
  or AI/adaptive recommendations.
- Spaced repetition is engine-ready; its Practice consumer and concept-family
  target mapping remain deferred.
- Repair identity is the exact composite of source task, missed signal, skill
  atom, and error type. Same-family but different exact identity stays distinct.
- Practice queue and Review share exact resolution truth and durable receipts.
- The queue holds three active unresolved items while the visible Practice
  consumer remains one pinned row.
- Review pattern coaching reads repeated source-backed evidence across sessions
  without resurrecting resolved work or owning queue state.
- Banked-fix proof derives from Review resolution receipts, matching successful
  repair outcomes, and later same-family transfer evidence. Its aggregate uses
  a recent-session window, not calendar-week reporting.
- Profile's existing `Progress proof` card consumes source-backed lifetime and
  recent banked-fix proof without owning or mutating the proof projection.
- Sharky Phrase Tier Contract v1 makes learner-facing Sharky phrases consume
  structured evidence state instead of owning truth. Direct-observation,
  repair, transfer, pattern, and completion claims require matching source
  evidence; missing evidence resolves to a neutral fallback.
- Foundation + Developing Phrase Sets v1 moves the first Welcome, Home, and
  Session Summary Sharky support/proof lines into the deterministic phrase
  resolver. Foundation wording stays concrete and one-clue/local-proof based;
  Developing wording may connect action, table state, position, price, and
  signal-action links without adding mastery, AI, solver, fixed-forever, or
  W13+ claims.
- Sharky Saw You Improve v1 derives a companion observation only from
  reinforced Fix Proof: successful resolved repair plus later same-family
  improved transfer on a different task and different session, with later
  evidence order after the repair. The only admitted consumer is the existing
  Session Summary banked-fix receipt; no new persistence, telemetry, Review or
  Profile expansion, mastery claim, or broad history UI exists.

## Constraints

- No AI/adaptive claims.
- No chat coach.
- No fake mastery.
- No queue clearing without a resolution contract.
- No Review recovery claim without a resolution contract.
- No fixed-forever, solved, mastered, launch-ready, or Human-QA-proven copy.
- No W13+ expansion, route opening, or monetization gating through repair work.
- No Practice target mapping, multi-repair visible expansion, passive recovered
  history, calendar-week proof, or broad dashboard in this active wave.

## Current Proof Source Chain

`concept-family state + session identity + transfer evidence + repair outcomes + Review resolution receipts -> banked-fix projection -> bounded proof consumer`

Profile consumes this chain through the accepted Cross-Session Proof contract.
It must not invent mastery, scores, percentages, causal learning claims, or
broad outcome history.

## Telemetry Ownership

- Local events support truth.
- Telemetry does not own product state.
- Product state must remain explainable from local source/runtime contracts.
- Phrase selection belongs to the deterministic phrase resolver, not telemetry.
- Full learner-facing phrase text is not logged by default.
- Server analytics, privacy policy work, cohort analysis, and remote dashboards
  remain later scope.

## Proof Requirements

- Every improvement claim needs evidence.
- Every achievement must cite a real trigger.
- Cross-session claims require transfer/state proof.
- Session Summary can report local proof, but cannot imply global learning
  effect or mastery.
- Review and Profile can show evidence, not invented identity growth.
- Sharky can say what the current evidence supports, but cannot infer mastery,
  biggest leaks, AI discovery, always/never behavior, memory guarantees, or
  unsupported personality/emotion state.

## Key Owner Seams

Search before reading exact owners. Useful search terms:

- `repair_focus_id`
- `user_choice`
- `error_type`
- `time_to_decision`
- `Practice this`
- `active repair`
- `Session Summary`
- `repair outcome`
- `return reason`
- `proof`

Likely owner areas:

- Act0 shell repair and feedback seams
- Session Summary receipt seams
- Review repair/proof seams
- Profile evidence seams
- local learning evidence history/projection seams
- focused repair and proof tests

## Relevant Artifact Pointers

- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/review_multi_session_pattern_coaching_v1.md`
- `docs/_reviews/fixes_banked_weekly_proof_v1.md`
- `docs/_reviews/cross_session_proof_profile_v1.md`
- `docs/_reviews/sharky_phrase_tier_contract_v1.md`
- `docs/_reviews/foundation_developing_phrase_sets_v1.md`
- `docs/_reviews/sharky_saw_you_improve_v1.md`

## Claim Language

Allowed:

- deterministic repair
- local proof
- missed signal
- next useful hand
- return reason
- evidence-backed achievement

Forbidden:

- AI coach
- adaptive solver
- GTO recommendation
- leak solved
- mastered
- fixed forever
- Human-QA-proven
- launch-ready
