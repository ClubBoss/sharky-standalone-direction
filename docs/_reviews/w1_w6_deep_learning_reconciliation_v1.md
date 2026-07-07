# W1-W6 Deep Learning Reconciliation and Learner-Truth Closure Audit v1

Agent: Claude. Model: Opus effort tier (session model: Sonnet 5).

Base HEAD: `873304137d46f6c85c7587ccda325d63b5b01e2d`

Branch: `claude/w1-w6-deep-learning-reconciliation-v1`

Status: docs-only reconciliation audit. No product code, content, test, or
Modern Table change was made.

## 0. Mission recap and boundary

This is a reconciliation audit, not a fresh audit. Per the canonical project
state, `test_shims` migration, broad Tier B repair, Tier C cleanup, historical
Modern Table test repair, global-suite cleanup, and repository authority
architecture are closed lanes and are not reopened here. The active product
owner is Act0 / the canonical World truth map / the W1-W6 active learning
route. This review reconciles that route's learning-closure state against all
prior accepted evidence and current source, and produces an implementation-
ready closure ledger. It does not implement repairs.

## 1. Evidence hierarchy actually used

1. `docs/plan/MASTER_PLAN_v3.0.md` — active product/curriculum SSOT. Confirms
   Act0/W1-W6 is the active route, confirms the W4-W6 title-normalization
   effort is a known, separately owned, in-progress lane (do not re-derive),
   and confirms Volume I (W1-W12) readiness gates and Transition Readiness
   Governance rules used as the seam-audit yardstick below.
2. `AGENTS.md` — workflow protocol (read; no conflicting instruction found for
   this lane).
3. Prior W1-W6 audit/repair thread, read in full or in targeted section, in
   this order:
   - `docs/_reviews/w1_w6_final_learner_truth_audit_v1.md` (the last full
     learner-truth audit; produced findings `W1W6-LT-001..014`)
   - `docs/_reviews/w1_w6_final_repair_ledger_v1.md` (the ledger those
     findings were tracked in)
   - `docs/_reviews/w1_w6_grouped_repair_program_v1.md` (the accepted 5-wave
     repair plan)
   - `docs/_reviews/w1_w6_repair_wave1_beginner_truth_v1.md`
   - `docs/_reviews/w1_w6_repair_wave2_feedback_completeness_v1.md`
   - `docs/_reviews/w1_w6_repair_wave3_authority_drift_v1.md`
   - `docs/_reviews/w1_w6_repair_wave4_structured_context_actionability_v1.md`
   - `docs/_reviews/w1_w6_repair_wave5_telemetry_repair_proof_v1.md`
   - `docs/_reviews/w1_w6_learning_outcome_independent_audit_v1.md` (separate
     independent audit thread; found a prerequisite-chain gap after the
     five-wave program was already closed)
   - `docs/_reviews/w1_w6_prerequisite_chain_repair_batch_v1.md` (repair for
     that gap; left one item source-blocked)
   - `docs/_reviews/w6_cross_family_route_contract_prerequisite_audit_v1.md`
     (repair-continuity architecture check for the W6 recheck path)
   - `docs/_reviews/wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md`
     (same-signal/coverage schema audit)
   - `docs/_reviews/w1_w6_migration_coverage_consolidation_v1.md`,
     `docs/_reviews/w1_w6_outcome_repair_verification_local_cleanup_v1.md`,
     `docs/_reviews/w1_w6_runtime_bundle_build_integrity_v1.md` (closure/build
     integrity evidence around the same period)
   - `docs/_reviews/w1_w3_free_foundation_gate_readiness_audit_v1.md` (W1-W3
     density read; monetization framing ignored, density data reused)
   - `docs/_reviews/surface_role_cta_coherence_audit_v1.md` (later re-read of
     the Learn/Home hierarchy question raised in `W1W6-LT-011`)
4. Current runtime/content source, read only where a prior finding needed
   confirmation: `content/_meta/term_introduction_contract_v1.json`,
   `content/worlds/world1/v1/sessions/w1.s01/*`, `content/worlds/world5/v1/*`
   index files, `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart` (path
   confirmed, not fully re-read — evidence reused from the coherence audit
   above), and drill-manifest counts already reconciled by Wave 3/5 evidence.

Graphify: `graphify-out/graph.json` and `GRAPH_REPORT.md` exist in this repo.
`graphify hook-check` is used for validation (see Section 9). Interactive
`graphify query`/`path`/`explain` were not additionally invoked beyond what
the reused audits already ran, per the context-efficiency protocol — the
prior artifacts already carried Graphify query trails for the same route.

No Tier C, historical Modern Table, or archive/donor source was read.

## 1.5 Required cross-cutting audit dimension: Canonical Route Ownership & Learner Reachability

> Added by the canonical Act0 route audit
> (`docs/_reviews/canonical_act0_w1_showdown_learning_truth_v1.md`) after
> `W1W6-DLR-001` was found to have been scoped against a non-canonical
> (Flow-B / legacy JSON) pipeline rather than the reachable learner route.
> This dimension is now a **required** framework check for every future
> W1-W12 audit, alongside the concept/prerequisite/feedback/transfer/repair
> dimensions already used above.

Every finding — especially any "assessed before taught," coverage, closure, or
score claim — must first be pinned to the canonical learner route before it is
admitted. The canonical route for the active product is:

`AppRoot -> Act0ShellPreviewScreenV1 -> Home/Learn -> Act0 lessons/tasks -> Act0 completion/progress`

Non-canonical flows that must **never** supply closure/score evidence:
Flow A campaign spine (DEBUG_SUPPORT, debug-only) and Flow B JSON "Session
Drills" (LEGACY_BLOCKED, e.g. the `showdown_winner_choice_v1` drill kind).

Required checks under this dimension (all must pass before a finding or a score
is admitted):

1. **Canonical route owner** — the seam under audit is on the reachable Act0
   route (state/lesson/task/runner/progress in `lib/ui_v2/act0_shell/...`),
   not a debug spine, legacy runner, JSON drill contract, or audit-tooling
   inventory.
2. **Teaching and assessment in the same required flow** — the concept is
   taught and assessed within the same canonical, learner-reachable lesson/
   task chain, not split across a canonical assessment and a non-canonical (or
   absent) teaching source.
3. **Progression-required reachability** — order is enforced by the runtime
   progression model (lesson-lock + first-incomplete-task gating), so the
   learner cannot reach the assessment before the teaching task.
4. **Completion ownership** — completion is written to and restored from the
   canonical Act0 progress store, not a parallel/legacy persistence path.
5. **Repair-route reachability** — any claimed repair/recheck actually routes
   back to its exact target through a proven canonical seam. The old
   `W1W6-DLR-002` finding is now corrected as
   `MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER`: it failed for the optional
   session-drill receipt/queue owner it inspected, but it is not a canonical
   Act0 W6 blocker.
6. **No score/closure evidence from optional/debug/legacy flows** — optional
   sessions built on a misscoped premise (e.g. `w1.s11`) do not count as
   closure or score evidence for the canonical route.
7. **No parallel-owner drift** — a concept must have a single canonical owner;
   a finding must not assume a non-canonical owner's artifact is the canonical
   one (the exact error that produced `W1W6-DLR-001`).

## 2. Reconciliation of prior findings

### 2.1 `W1W6-LT-00x` ledger (from `w1_w6_final_repair_ledger_v1.md`)

| ID | Finding | Disposition (this audit) | Evidence |
| --- | --- | --- | --- |
| LT-001 | Beginner profile does not constrain downstream vocabulary | `CLOSED_PROVEN` | Wave 1: `beginner_term_guard` added, W1.s01 teaches Hero/Villain/BTN/CO/SB/BB/blinds/preflop/postflop/board/pot/sizing/range before first assessment; `term_coverage_scanner.dart` + focused tests pass. |
| LT-002 | Act0 first-table-guide distractor leaks the answer | `CLOSED_PROVEN` | Wave 1: old `The flop is already out and this is postflop` distractor removed; two plausible same-table distractors substituted; widget test rejects the old option. |
| LT-003 | Term-introduction contract too narrow for beginner terms | `CLOSED_PROVEN` | Wave 1: `term_introduction_contract_v1.json` extended with the 13 beginner terms/aliases; scanner enforces order. |
| LT-004 | 50 active rows missing correct/incorrect feedback | `CLOSED_PROVEN` | Wave 2: guard scanned 453 active rows; final result 0 missing correct/incorrect, 0 missing acceptable, 0 missing `why_v1`. Wave 5 re-ran the same guard against 374 active rows post-Wave-4 edits: still 0 violations. |
| LT-005 | W3.s10 active source/test authority drift | `CLOSED_PROVEN` | Wave 3: manifest entry corrected to match the proven `index.md`/runtime-loader source of truth; guard extended with an index-vs-manifest parity test; root cause traced to a stale generated-manifest regeneration miss, not a competing editorial authority. |
| LT-006 | W4 mobile actionability not proven on the current route | `CLOSED_PROVEN` | Wave 4: compact guard rewritten from retired map keys to the canonical `Home -> Learn tab -> mission card -> mission CTA` path; passes at 360x640 with safe-area clearance. |
| LT-007 | W5 index/manifest duplicate/stale authority (`w5.s11`) | `CLOSED_PROVEN` | Wave 3: top-level `world5/v1/index.md` sentence corrected to state `w5.s11` is preserved-but-inactive; parity guard added to `world5_early_runtime_truth_contract_test.dart` catching both silent-drop and silent-re-admit regressions. |
| LT-008 | W5 board-texture rows are prompt-only, not table-authored | `CLOSED_PROVEN` | Wave 4: `w5.s01`-`w5.s10` `board_texture_classifier_v1` rows now author `street_v1`/`board_cards_v1`; fallback derivation from session id/prompt words removed; scenario state fails closed without authored context. |
| LT-009 | Repair-receipt lifecycle intentionally narrow (only 4 families admitted) | `PARTIALLY_CLOSED` | Wave 5 closed the telemetry/proof side (deterministic `user_choice`/`decision_made`/`task_result` projection, error taxonomy, repair-family id derivation) for every committed decision. It did **not** widen receipt admission beyond the original four families (W4 denial, W5 dry texture, W6 board-fit strong/missed, W6 width wider/narrower). This was an explicit `defer_with_trigger` in the original ledger, and it is still open: most W1-W3 rows and the larger W4/W5/W6 families remain outside the durable same-signal repair-receipt lifecycle. |
| LT-010 | No `time_to_decision` in the session-drill telemetry path | `CLOSED_PROVEN` | Wave 5: `time_to_decision_ms` now emitted on every committed `user_choice`/`decision_made`/`task_result` event for the active Act0 runner path, alongside `attempt_id`, `error_type`, `repair_family_id`, and structured board context when present. Exactly-once/no-drop proof included. |
| LT-011 | Learn/Home hierarchy: competing `Now`/`Current lesson`/`Current step`/progress/mission-CTA blocks | `PARTIALLY_CLOSED` / `REQUIRES_HUMAN_QA` | Grouped Wave 4 scoped this finding in but the Wave 4 closure review explicitly lists only LT-006 and LT-008 as closed — LT-011 was not touched in Wave 4. A later independent read (`surface_role_cta_coherence_audit_v1.md`) re-examined the same file (`act0_learn_path_shell_v1.dart`) and downgraded the signal: Home/Learn each have one structural primary CTA in code (mission-card button / `Start`), and the "competing blocks" read could not be confirmed as a defect from source alone — it needs a real compact-portrait capture. Net: the hierarchy is not proven broken, and it is not proven clean either. |
| LT-012 | Portrait drill screenshot void below the answer panel | `NOT_REPRODUCIBLE` (stands, unchanged) | No new evidence reopens this. Original disposition (`defer_with_trigger`: only actionable if it hides CTA/feedback/scroll/safe-area) still holds; the W4 actionability reopen-path from the same finding was resolved as LT-006 above, which removes the strongest concrete trigger that existed. |
| LT-013 | Human QA not executed; completion/payoff proof is technical only | `OPEN_CONFIRMED` (by design — this is the standing precondition, not a bug) | No audit thread claims Human QA was run. Every closed wave above explicitly disclaims learning-effect/launch/mastery/9.0 claims from technical proof alone. This finding is restated below as the Human QA boundary rather than as a repair item. |
| LT-014 | Guided-recognition / template-repeatable prompts and options | `PARTIALLY_CLOSED` | Wave 1 closed the admitted slice (Act0 first-table guide + W1.s01 chain). Wave 2 closed the feedback-template portion wherever missing/unsupported feedback was the actual defect. Both closure reviews explicitly say the **broader** prompt/option template-repetition risk across the rest of W1-W6 was never scanned or rewritten — it was deferred to "the later final closure check," and no later artifact in this repo performs that broader scan. This residue is still open, bounded, and low-risk (P2/P3, not P0/P1: it is a pattern-guessing risk, not a broken assessment). |

### 2.2 Second-thread findings (post-five-wave-program)

A second, independent audit thread (`w1_w6_learning_outcome_independent_audit_v1.md`)
ran after the five repair waves closed and asked a stricter question: do the
now-technically-clean W1-W6 rows actually prove prerequisite knowledge before
using it, not just "is feedback present / is telemetry present." It did not
find a fixture-level P0 that invalidates the existing bounded-technical
certification scores (W1 `8.5`, W2-W6 `8.0`), but it did find a genuine
Tier-A prerequisite-chain gap and recommended a repair batch.

| Finding | Disposition | Evidence |
| --- | --- | --- |
| P1-01/P1-02: W1 never teaches hand ranking, showdown resolution, best-5-of-7, or kicker before those concepts are used (a `showdown_winner_choice_v1` kind exists in the active W1-W6 decision-row inventory) | ~~`OPEN_CONFIRMED` (`W1W6-DLR-001`)~~ → **`MISSCOPED_NO_CANONICAL_ASSESSMENT`** (corrected by `docs/_reviews/canonical_act0_w1_showdown_learning_truth_v1.md`; removed from active P1 count) | **Correction:** the cited `showdown_winner_choice_v1` kind is a W2-owned Flow-B / legacy JSON drill artifact (found only in `lib/archive/legacy_runners/...`, `lib/services/drill_contract_v1.dart`, `lib/services/world2_showdown_truth_validator_v1.dart`, `lib/audit_hub_v1/...`), not a canonical W1 assessment. The canonical W1 Act0 route (`_pokerFromZeroLessons`) owns dedicated `hand_rankings_table` + `showdown_winning` lessons whose teaching (`learn`) task is the gating first task and provably precedes every drill and prove-it assessment. No canonical assessed-before-taught event exists. (Historical text preserved: `w1_w6_prerequisite_chain_repair_batch_v1.md` source-blocked a W1-owned source family and refused to import W2 source; the follow-up wave built the optional `w1.s11` Flow-B session, which is **not** canonical closure evidence and is not integrated.) |
| P1-03 IP/OOP before W3 position-sensitive decisions | `CLOSED_PROVEN` | Repaired in W3 canonical generated fixture feedback; validator passed. |
| P1-04 equity/protection before W4 purpose/action decisions | `CLOSED_PROVEN` | Repaired in W4 generated fixture feedback; validator passed. |
| P1-05a draw definition before W5 draw-heavy texture labels | `CLOSED_PROVEN` | Repaired in W5 generated fixture feedback. |
| P1-05b W5 outs scope (9/8/4 outs, flush/OESD/gutshot) | `CLOSED_PROVEN` | Bounded `basic_outs_awareness` source repair added under `w5.s11`; canonical prerequisite fixture validated. |
| P1-06 range definition before W6 range families | `CLOSED_PROVEN` | Repaired in both accepted W6 canonical families (`range_bucket_by_board_fit`, `range_width_awareness`). |
| P2-01 pot definition, P2-02 "defend" clarity | `CLOSED_PROVEN` | Repaired in W1 generated fixture feedback (same pass as the Tier-A repairs). |

### 2.3 Repair-continuity architecture check (W6)

`w6_cross_family_route_contract_prerequisite_audit_v1.md` asked whether a
persisted W6 range-bucket repair-recheck candidate can actually reach its
exact target drill through any existing runtime path. Verdict:
`unsafe_missing_contract_stop`.

- The repair-receipt/recheck-queue chain (`SessionDrillRepairReceiptCandidateV1`
  -> persistence -> `SessionDrillRecheckLaunchQueueItemV1`) is complete and
  well-formed as a data object.
- No existing canonical route, launcher, terminal payload, or surfaced runner
  accepts a target-drill id. The surfaced runner always starts at index 0,
  runs the full session, and marks the whole session complete on the final
  drill.
- Adding a naive `initialDrillId` parameter would silently corrupt
  progress/completion/telemetry semantics (a partial recheck could emit a
  full-session-complete event).
- Act0's own visible repair path is task-centric (`Act0RepairIntentV1`), and
  converting the session/drill-owned W6 queue item into a fabricated Act0 task
  id was explicitly rejected as unsafe.

This was valid for the session-drill owner it inspected, but invalid as a
canonical Act0 W6 blocker. The follow-up canonical admission gate
(`w6_repair_recheck_canonical_admission_gate_v1.md`) found that canonical Act0
W6 uses task-centric repair and retention replay, not
`SessionDrillRecheckLaunchQueueItemV1`, and found no broken link in the
canonical error -> repair -> aged recheck -> `recheck_completed` ->
owned-candidate chain. `W1W6-DLR-002` is therefore corrected to
`MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER`; it must not cap W6 score and does
not admit a canonical W6 product repair.

### 2.4 Same-signal / coverage-schema audit

`wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md` is a schema
readiness audit, not a new learner-harm finding. It confirms:

- W1-W6 have adequate raw repetition volume per concept family (8+ reps in
  every sampled family), so the underlying content is not thin.
- `concept_family_id` and a canonical `same_signal_group` are not yet
  first-class schema fields — same-signal grouping today is inferred from
  filenames/intents, not owned by a validated contract. This gates future
  audit repeatability and future spaced-repetition tooling, not current
  learner-visible correctness.
- Several worlds show a route-title-vs-authored-content-title mismatch (e.g.
  active W2 labeled `Hand Discipline` while W2 content narrative reads as a
  table-reading bridge; similar drift is recorded for W3-W6). This is
  `SUPERSEDED` for the purposes of this audit: `MASTER_PLAN_v3.0.md` already
  owns and tracks this exact drift as an active, separately scoped
  normalization lane (`docs/_reviews/w4_w6_route_content_normalization_plan_v1.md`,
  `docs/_reviews/w4_w6_title_runtime_normalization_pr1_v1.md`,
  `docs/_reviews/w4_route_title_job_realignment_plan_v1.md`,
  `docs/_reviews/w4_title_job_realignment_pr2_v1.md`,
  `docs/_reviews/w4_source_title_ownership_remap_v1.md`). This audit does not
  re-litigate that lane; it is noted here only so a future reader does not
  mistake it for a newly discovered defect.

The `concept_family_id` schema gap is admitted at low severity (`W1W6-DLR-005`
below is the template/feedback residue; the schema gap itself is bounded
tooling debt, not a learner-facing defect, and is registered as `P3` in the
ledger for completeness rather than as an urgent repair).

### 2.5 Build/runtime integrity

`w1_w6_runtime_bundle_build_integrity_v1.md`
(`w1_w6_runtime_bundle_integrity_closed_wave5_admitted`) and
`w1_w6_outcome_repair_verification_local_cleanup_v1.md`
(`w1_w6_outcome_repair_verification_passed_with_local_cleanup`) confirm the
Wave-1-through-5 content/fixture changes reached the runtime asset bundle
without drift, and that the accompanying local-cleanup pass did not touch
learner-visible content. These are `CLOSED_PROVEN` and are cited only as
supporting integrity evidence, not reopened.

One residual note carried over from Wave 4's own closure review: the
runtime-bundle parity test for the repaired W3/W5 manifest entries
(`drill_runtime_adapter_v1_asset_bundle_test.dart`) still observed "stale
runtime-bundle W3 checkpoint drift" as of Wave 4. Wave 5's own broad-guard
section reports "runtime-bundle parity guard: active W1-W6 drill indexes stay
in source, test bundle, and runtime bundle parity" as green. Read together,
the Wave 4 residual note is `CLOSED_PROVEN` by Wave 5's later green run; no
independent re-verification of the asset bundle was performed in this
docs-only audit (out of scope: this would require running the Flutter test
suite, which this audit does not do).

## 3. Prerequisite graph (concept-level)

The core beginner vocabulary family (Hero, Villain, BTN/button, CO/cutoff,
SB/small blind, BB/big blind, blinds, preflop, postflop, board, pot, sizing,
range) is the one that produced the original "CO folded before CO is taught"
class of defect. That whole family is now schema-owned by
`content/_meta/term_introduction_contract_v1.json` plus
`tools/term_coverage_scanner.dart`, which enforces: canonical form -> aliases
-> first permitted appearance -> first explanation -> first contextual
demonstration -> first permitted assessment -> later reuse, and fails closed
on abbreviation-before-explanation or assessment-before-explanation. This is
the correct shape of a systemic repair for that class of defect (Consolidation
requirement satisfied): it was fixed once, as a scanner-enforced contract, not
patched instance-by-instance.

Downstream of that scanner, the remaining prerequisite gaps found in this
reconciliation are narrower and already individually tracked:

| Concept | Introduced | Explained | Demonstrated | Practised | Independently assessed | Reinforced downstream | Gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Hero/Villain/seats/blinds/preflop/postflop/board/pot/sizing/range (beginner term family) | yes (W1.s01) | yes | yes | yes | yes | yes, contract-owned reuse | none — closed |
| IP/OOP | yes (W3) | yes (repaired) | yes | yes | yes | — | none — closed |
| Equity / protection (beginner-safe framing) | yes (W4) | yes (repaired) | yes | yes | yes | — | none — closed |
| Draw (flop/turn/river draw concept) | yes (W5) | yes (repaired) | yes | yes | yes | — | none — closed |
| Outs (9/8/4 canonical counts) | yes (W5.s11 bounded repair) | yes | yes | yes | yes | — | none — closed |
| Range (plain definition) | yes (W6) | yes (repaired) | yes | yes | yes | — | none — closed |
| Hand ranking / best-five-card rule / kicker / showdown resolution | ~~consumed (W1 `showdown_winner_choice_v1` kind)~~ **taught+assessed in canonical W1** (`hand_rankings_table`, `showdown_winning`) | **yes** (`_handRankingIntroRunner`, `_showdownIntroRunner`) | yes (`_bestFiveShowdownRunner`, `_showdownKickerRunner`, `_boardPlaysRunner`, `_tiePotRunner`) | yes (recognition + compare drills) | yes (`ranking_recap`, `world_one_checkpoint` proveIt) — taught **before** assessed | yes (W2 showdown reuses W1 foundation) | **corrected — canonical contract closed; `W1W6-DLR-001` MISSCOPED** (see `canonical_act0_w1_showdown_learning_truth_v1.md`) |
| Repair-recheck target reachability for session-drill-owned families (W6 range-bucket) | signal captured | n/a | n/a | n/a | n/a | no safe session-drill target route in the optional owner inspected by the old audit | **corrected — noncanonical/session-drill owner only, `W1W6-DLR-002` MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER** |

No new instance of the original "term used before taught" defect class was
found in the reconciled evidence beyond what the scanner already enforces.
~~The remaining prerequisite gap (showdown/hand-ranking/kicker) is a different
root cause — a genuinely missing W1-owned source family, not an ordering bug
in an existing one — so it is tracked as its own finding rather than folded
into the beginner-term-guard family.~~

**Correction (canonical Act0 route audit):** there is **no** missing W1-owned
source family for showdown/hand-ranking/kicker. The canonical W1 route owns
the `hand_rankings_table` and `showdown_winning` lessons, which teach the
ranking ladder, best-five-of-seven, showdown resolution, kicker, board plays,
and split pot, and gate every assessment behind their teaching task. The
earlier "missing source" conclusion came from reading the non-canonical
Flow-B / legacy JSON inventory. `W1W6-DLR-001` is `MISSCOPED_NO_CANONICAL_ASSESSMENT`;
see `docs/_reviews/canonical_act0_w1_showdown_learning_truth_v1.md`.

## 4. World-by-world audit

Scores below cite evidence; no score is averaged over a confirmed beginner
blocker (see Section 6 admission rules).

### W1 — Poker from Zero

1. Intended outcome: absolute table/rules literacy — seats, cards, blinds,
   pot, action order, streets, hand rankings, showdown, first repair loop.
2. Required prerequisites: none (true entry point).
3. Concepts introduced: Hero/Villain, seats (BTN/CO/SB/BB), blinds, preflop/
   postflop, board, pot, sizing, range (contract-owned, W1.s01), starting-hand
   discipline, bet-size labels, card/board orientation.
4. Concepts consumed: hand ranking, showdown resolution, best-5-of-7, kicker.
   ~~Consumed without a W1-owned teaching source (open finding).~~
   **Corrected:** taught and assessed by the canonical W1 lessons
   `hand_rankings_table` and `showdown_winning` (teaching task first, then
   drills, then prove-it). The "consumed without a W1 source" reading was
   scoped to the non-canonical Flow-B JSON `showdown_winner_choice_v1` kind.
   See `docs/_reviews/canonical_act0_w1_showdown_learning_truth_v1.md`.
5. Evidence of teaching: `w1.s01/session.md` explicit vocabulary block before
   any assessed row (Wave 1); 9 authored lessons, 70 active tasks, 9
   theory-only tasks.
6. Evidence of guided practice: 51 drill tasks, seat taps/card reads/board
   reads/action choices, systemic runner-option feedback.
7. Evidence of independent assessment: 10 review/prove tasks; checkpoint
   synthesis.
8. Evidence of transfer: repeated preflop starts across multiple table
   configurations (free-foundation density read); no dedicated novel-context
   transfer task beyond in-route variation confirmed in the reconciled
   evidence.
9. Feedback quality: 0/453 (then 0/374) active rows missing correct/incorrect/
   acceptable/why feedback after Wave 2; W1.s01 rows explicitly cite the
   missed table clue (Wave 1).
10. Repair continuity: strong for first-value signals (action/no-bet, board
    cards, hero cards, table read, price-read carry); telemetry now includes
    `time_to_decision_ms`, `error_type`, `repair_family_id` (Wave 5).
11. Confirmed gaps: ~~hand-ranking/showdown/best-5/kicker source gap
    (`W1W6-DLR-001`, P1, open).~~ **None on this axis** — the alleged source
    gap was `MISSCOPED_NO_CANONICAL_ASSESSMENT` (canonical W1 teaches before it
    assesses). The only surviving W1-adjacent open items are the bounded
    same-signal receipt breadth (`W1W6-DLR-004`, P2) and the template residue
    (`W1W6-DLR-005`, P2), both unchanged.
12. Already-closed findings: LT-001, LT-002, LT-003, LT-004 (W1 slice),
    LT-014 (W1.s01 slice), P2-01/P2-02 pot/defend clarity.
13. Confidence score: ~~**7.5/10** ... capped ... because a real beginner is
    assessed on showdown/hand-ranking outcomes before W1 teaches them.~~
    **Corrected to `W1_SCORE_MAY_IMPROVE_AFTER_HUMAN_QA`.** The 7.5 cap
    rationale (assessed-before-taught) is invalidated: on the canonical route
    the teaching provably precedes the assessment. No new source-only number is
    assigned here and 9/10 is not assigned from source alone; only Human QA can
    certify a higher W1 score. The beginner-vocabulary defect class that
    originally motivated this thread remains closed here first and most
    thoroughly. See `docs/_reviews/canonical_act0_w1_showdown_learning_truth_v1.md`.

### W2 — Hand Discipline

1. Intended outcome: not every hand deserves play; fold discipline, weak-ace/
   dominated-hand awareness.
2. Required prerequisites: W1 vocabulary and action order.
3. Concepts introduced: hand buckets, weak-ace awareness, dominated hands,
   fold discipline; authored content also carries showdown, position,
   initiative, board texture, outs, and price-sensitive continue decisions.
4. Concepts consumed: W1 vocabulary (satisfied); showdown mechanics reused
   from W1's unfilled slot in some rows (see W1 gap above — W2 owns showdown
   source, so W2 itself does not have a hidden-prerequisite problem; the risk
   is one-directional, W1 borrowing from W2, not W2 assuming unowned W1
   knowledge).
5. Evidence of teaching: 6 lessons, 6 theory-only tasks (active); 14 sessions/
   111 drill files authored.
6. Evidence of guided practice: 24 active drill tasks; bucket classification,
   fold/continue, pressure fold.
7. Evidence of independent assessment: 6 review/prove tasks; `fixMistakes`/
   `transfer`/`proveIt` task families present.
8. Evidence of transfer: apply-stage UTG/BTN/HJ decisions distinct from
   practice-stage bucket classification.
9. Feedback quality: 0 violations post-Wave-2 (`w2.s05` was among the rows
   repaired).
10. Repair continuity: "good" per free-foundation density read — fold
    discipline and apply tasks route through `fixMistakes`.
11. Confirmed gaps: none newly confirmed beyond the tracked, separately owned
    route-title/content-title normalization drift (not admitted here).
12. Already-closed findings: LT-004 (W2.s05 slice).
13. Confidence score: **7.5/10**. Solid density and repair; the only material
    open item is the cosmetic/labeling drift owned by a different active
    workstream, not a learning-validity defect.

### W3 — Position Thinking

1. Intended outcome: seat order changes hand value and action comfort.
2. Required prerequisites: W1/W2 vocabulary, action order, hand discipline.
3. Concepts introduced: UTG/HJ/CO/BTN/SB/BB, IP/OOP (repaired — grounded
    before position-sensitive decisions), BTN advantage, same-hand-different-
    seat contrast.
4. Concepts consumed: W1 seat vocabulary (satisfied by beginner-term guard).
5. Evidence of teaching: 6 lessons, 6 theory-only tasks (active); 14 sessions
   authored (18 drill JSON files — the authored/active ratio here is thinner
   than W1/W2/W4, flagged in the free-foundation read as a density-uniformity
   risk, not a validity defect).
6. Evidence of guided practice: 32 active drill tasks; BTN/UTG seat reads,
   early-vs-late order.
7. Evidence of independent assessment: 6 review/prove tasks; checkpoint.
   `w3.s10` now has a confirmed, authority-correct 4-row set (chain checkpoint
   + 3 independent `action_choice` transfer drills) after Wave 3.
8. Evidence of transfer: same-hand/different-seat is the explicit transfer
   design; three dedicated transfer drills at `w3.s10`.
9. Feedback quality: repaired to 0 violations (Wave 2 scope did not need to
   touch W3 rows because the initial guard found no W3 misses in the sampled
   set; W3 rows were not among the 86 changed files, meaning W3 already had
   complete feedback before Wave 2).
10. Repair continuity: "strong relative to prior state" per free-foundation
    read — 7 named repair/recheck signals (BTN seat-ID, UTG seat-ID, BTN-last
    postflop, UTG players-behind, early/late order, same-hand/different-seat,
    CO players-behind/position checkpoint).
11. Confirmed gaps: none newly confirmed. Authority drift (`W1W6-LT-005`)
    closed.
12. Already-closed findings: LT-005, P1-03 (IP/OOP).
13. Confidence score: **7.5/10**. Strong repair and transfer design; capped
    slightly by the authored-content thinness ratio (14 sessions but only 18
    drill files) relative to W1/W2/W4, which is a depth-uniformity watch item
    rather than a proven defect.

### W4 — Bet Purpose And Price

1. Intended outcome: why bets happen, price, pot-odds intuition, first
   variance seed (a correct call can still lose).
2. Required prerequisites: W1-W3 vocabulary, position, hand discipline.
3. Concepts introduced: bet purpose/action intent (value/denial/protection/
   control/release), sizing, equity/protection (repaired — grounded before
   use), call price.
4. Concepts consumed: W1-W3 vocabulary (satisfied).
5. Evidence of teaching: 10 sessions, 123 drill files (largest single-world
   drill count in the active set).
6. Evidence of guided practice: 40 `bet_sizing_choice_v1` rows, 33 action
   choices, chain steps across value/denial/protection/bluff intents.
7. Evidence of independent assessment: `world4_intent_normalization_v1_test.dart`
   and the W4 route guard back the intent-family structure.
8. Evidence of transfer: size buttons + action choices + anchors + chains
   across the intent families.
9. Feedback quality: 0 violations post-Wave-2 (W4 `w4.s01`-`w4.s10` were the
   single largest block of rows repaired — 44 of the 86 changed files).
10. Repair continuity: W4 denial is one of the four admitted same-signal
    repair-receipt families (Section 2.3 context); mobile actionability
    (`W1W6-LT-006`) closed in Wave 4.
11. Confirmed gaps: none newly confirmed in this reconciliation beyond the
    already-tracked route-title normalization lane.
12. Already-closed findings: LT-004 (W4 slice, largest), LT-006, P1-04
    (equity/protection).
13. Confidence score: **7/10**. Highest raw density in the active set and the
    mobile-actionability P1 is closed with a real guard on the canonical
    route; held to 7 rather than higher because this is also the world where
    the still-open route-title-vs-content-title ambiguity is sharpest per the
    same-signal audit, and because same-signal repair-receipt coverage here
    is still limited to one intent family (denial) out of several.

### W5 — Board Awareness

1. Intended outcome: dry/wet board basics, draws, outs, street changes,
   reverse implied odds, semi-bluff concept.
2. Required prerequisites: W1-W4 vocabulary, bet purpose/price.
3. Concepts introduced: board texture, draw (repaired — grounded before use),
   outs (repaired — bounded canonical 9/8/4 family added), street changes.
4. Concepts consumed: W1-W4 vocabulary and pricing (satisfied).
5. Evidence of teaching: 10 active sessions, 41 drill files; `world.md`
   explicitly names board awareness/draw/outs/improvement counting as owned
   content.
6. Evidence of guided practice: 33 `board_texture_classifier_v1` rows (now
   structured-context-owned, not prompt-only, after Wave 4), 57 total
   decisions including chain steps.
7. Evidence of independent assessment: `w5_board_texture_same_signal_coverage_v1_test.dart`
   and the W5 route guard.
8. Evidence of transfer: dry/wet/connected/paired across OOP/IP and turn/
   river contexts is the explicit transfer surface.
9. Feedback quality: 0 violations post-Wave-2 (W5 rows across `w5.s01`-`w5.s10`
   were repaired, 28 of the 86 changed files).
10. Repair continuity: W5 dry-texture is one of the four admitted same-signal
    repair-receipt families; structured board context (`W1W6-LT-008`) closed.
11. Confirmed gaps: none newly confirmed. Stale `w5.s11` top-level index
    sentence (`W1W6-LT-007`) closed.
12. Already-closed findings: LT-007, LT-008, P1-05a (draw), P1-05b (outs).
13. Confidence score: **7.5/10**. This world absorbed the largest structural
    repair (prompt-only -> table-authored board facts) and it is now the
    world with the cleanest evidence trail end to end.

### W6 — Range Thinking

1. Intended outcome: strong/medium/weak/missed buckets, board fit, range
   width, advantage/compression, bounded polarization without solver
   language.
2. Required prerequisites: W1-W5 vocabulary, bet purpose/price, board
   awareness.
3. Concepts introduced: range (repaired — grounded before use), board-fit
   buckets, range width.
4. Concepts consumed: W1-W5 vocabulary and board texture (satisfied).
5. Evidence of teaching: 10 sessions, 92 drill files; range plain-definition
   now precedes both accepted canonical families.
6. Evidence of guided practice: 22 action choices + 17 chain steps; seat/
   hole/board taps.
7. Evidence of independent assessment: W6 route/range tests; Wave 5.2
   terminal-clamp gate (keeps W6 as the route's terminal gate before W7-W10).
8. Evidence of transfer: board-fit and width classifiers across multiple
   board/position contexts.
9. Feedback quality: 0 violations post-Wave-2 (`w6.s03`, 2 files, was the only
   W6 slice needing repair — W6 already had near-complete feedback).
10. Repair continuity: the old session-drill architecture check found no safe
    target-drill launch route for the optional session-drill owner it
    inspected. The canonical admission gate found that this is not the Act0 W6
    repair owner: canonical W6 uses task-centric repair and retention replay,
    and no broken link was found in the canonical error -> repair -> aged
    recheck -> `recheck_completed` -> owned-candidate chain.
11. Confirmed gaps from `W1W6-DLR-002`: none on the canonical route.
    `W1W6-DLR-002` is corrected to
    `MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER`; remaining P2/P3 issues stay
    pending canonical-only revalidation and are not promoted here.
12. Already-closed findings: LT-004 (W6.s03 slice), P1-06 (range definition).
13. Confidence score: **frozen pending canonical-only W1-W6 re-audit and Human
    QA**. No new W6 score is assigned in this correction. The old DLR-002
    canonical score cap is removed because its evidence came from a
    noncanonical session-drill owner.

## 5. Cross-world seam audit

Read against `MASTER_PLAN_v3.0.md`'s Transition Readiness Governance
(concept bridge, decision exposure, contrast exposure, suboptimal literacy,
vocabulary handoff, emotional safety) and the reconciled evidence above.

- **W1 -> W2**: Vocabulary handoff is explicit and contract-owned (the
  beginner-term contract records "later reuse" for W1.s02/W2). ~~The open W1
  showdown/hand-ranking gap ... a learner can reach W2 having been assessed,
  not taught, on showdown mechanics inside W1 itself.~~ **Corrected:** there is
  no such intra-world gap — canonical W1 teaches showdown/hand-ranking (in
  `hand_rankings_table` and `showdown_winning`) before assessing it, so a
  learner reaches W2 having been taught these mechanics. `W1W6-DLR-001` is
  `MISSCOPED_NO_CANONICAL_ASSESSMENT`.
- **W2 -> W3**: Position vocabulary (UTG/HJ/CO/BTN/SB/BB) is reused, not
  reintroduced, consistent with the beginner-term contract's ownership.
  IP/OOP is the one concept W3 needed grounded before use, and it was
  (Section 2.2). No unbridged jump found.
- **W3 -> W4**: This is the seam with the most residual ambiguity. The
  free-foundation density read explicitly flags active W4 as "the synthesis
  of preflop frame before action" and states the W3/W4 boundary is "mixed,
  not obvious paid depth" from a pacing point of view — i.e., W4 is dense but
  its identity relative to W3 is still being normalized in the separate
  title-ownership lane cited in Section 2.4. Equity/protection prerequisite
  grounding into W4 is closed (Section 2.2), so the concept-order risk is
  closed; the remaining risk is presentation/identity, already owned
  elsewhere.
- **W4 -> W5**: Draw and outs are the two concepts W5 needed grounded before
  use, and both were (Section 2.2). Bet-price vocabulary from W4 is reused
  directly in W5's reverse-implied-odds framing per the world's stated job.
  No unbridged jump found.
- **W5 -> W6**: Range is the one concept W6 needed grounded before use, and
  it was (Section 2.2). Board-texture vocabulary from W5 is the literal input
  to W6's board-fit buckets. The prior repair-continuity concern in Section
  2.3 is preserved as optional session-drill history, not a confirmed
  canonical W6 seam defect.

No new "concept consumed before taught" seam defect was found beyond what is
already tracked in Sections 2 and 3.

## 6. Admitted findings (closure ledger)

See `docs/plan/W1_W6_LEARNING_CLOSURE_LEDGER_v1.md` for the exact
implementation-ready table. Summary:

> **Corrected by the canonical Act0 route audits:** `W1W6-DLR-001` is
> withdrawn as `MISSCOPED_NO_CANONICAL_ASSESSMENT`, and `W1W6-DLR-002` is
> withdrawn as `MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER`. Both are removed
> from the active P1 count. Active P1 is now **0**. No replacement canonical
> finding is warranted by either correction.

- P0: 0
- P1: ~~2 admitted~~ **0 admitted**. `W1W6-DLR-001` (W1 showdown/hand-ranking/
  kicker "source gap") withdrawn —
  `MISSCOPED_NO_CANONICAL_ASSESSMENT`; `W1W6-DLR-002` (W6 session-drill
  repair-recheck launch contract gap) withdrawn —
  `MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER`.
- P2: 3 admitted (`W1W6-DLR-003` Learn/Home hierarchy visual proof;
  `W1W6-DLR-004` same-signal repair-receipt breadth; `W1W6-DLR-005` residual
  prompt/option template-repetition scan)
- P3: 1 admitted for completeness only (`W1W6-DLR-006` `concept_family_id`
  schema field) — bounded tooling debt, not learner-facing, included because
  it is cheap and unblocks future audit repeatability, not because it is
  urgent.
- P4: 0 admitted. No preference/speculative finding met the bar for entry.

## 7. Closed and deferred findings

Closed (`CLOSED_PROVEN`), not reopened: `W1W6-LT-001` through `-008`,
`-010`; P1-03 through P1-06 and P2-01/P2-02 from the prerequisite-chain
batch; runtime-bundle/build-integrity findings (Section 2.5).

Deferred, no new trigger found (`NOT_REPRODUCIBLE` / stands as originally
scoped): `W1W6-LT-012` (portrait void — only reopens on a concrete CTA/
feedback/scroll/safe-area failure, and its strongest concrete trigger,
`W1W6-LT-006`, is now closed).

Superseded by a separately owned, already-tracked workstream (not
re-admitted here): the W2-W6 route-title-vs-content-title drift documented in
`wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md` (owned by the
`w4_w6_*normalization*` / `w4_*title*` document family cited in Section 2.4).

Partially closed, residue admitted above: `W1W6-LT-009`, `-011`, `-014`.

Standing precondition, not a repair item: `W1W6-LT-013` (Human QA not
executed) — restated as the Human QA boundary in Section 8.

## 8. Human QA boundary

The following cannot be proven from source, tests, or prior audit artifacts
alone, and must not be simulated:

1. Whether a true absolute-beginner actually experiences the repaired W1.s01
   vocabulary block as clear versus overwhelming (pacing/perceived clarity).
2. Whether the repaired Act0 first-table-guide distractors genuinely read as
   plausible to a novice, versus merely "not obviously wrong" to an auditor.
3. Whether the Learn/Home hierarchy (`W1W6-DLR-003`) reads as one clear
   primary action on a real compact-portrait device, not just in code
   structure.
4. Whether W3's same-hand/different-seat contrast produces the intended "aha"
   for a first-time player, versus feeling like a quiz format.
5. Whether W4's variance seed ("a correct call can still lose") lands as
   reassuring rather than confusing on first encounter.
6. Whether W5's now-structured board-card context actually redirects visual
   attention to the right cue, versus still being read as label text.
7. Whether canonical W6's task-centric repair and retention replay are clear
   to a novice after a real error; the old session-drill dead-end concern is
   historical and must not be used as a canonical W6 score cap.
8. Whether repeated exposure to the still-uninventoried template phrasing
   (`W1W6-DLR-005`) actually trains pattern-matching in a real user, versus
   being a theoretical risk only auditors notice.
9. Whether the mental-foundation variance seed at W4 and the deferred W11
   capstone (per `MASTER_PLAN_v3.0.md`) are far enough apart to avoid feeling
   like an abandoned thread to an attentive learner.

No simulated persona pass may substitute for these. All nine require a live
novice session per the existing `HUMAN_QA_CAPSULE_v1.md` protocol referenced
in the reconciled audits.

## 9. Validation

- docs-only correction: confirmed (`git status`/`git diff` touch only
  `docs/_reviews/w1_w6_deep_learning_reconciliation_v1.md`,
  `docs/plan/W1_W6_LEARNING_CLOSURE_LEDGER_v1.md`, and
  `docs/_reviews/w6_repair_recheck_ledger_correction_v1.md`).
- no product/content/test modification: confirmed.
- no Modern Table change: confirmed.
- no authority-lane change: confirmed (test_shims/Tier B/Tier C/global-suite/
  repository-authority lanes untouched).
- `git diff --check`: run, see commit log.
- `git diff --cached --check`: run, see commit log.
- `graphify hook-check`: run (graphify-out/ present in this repo).
- clean worktree after commit: confirmed.
- no push performed.

## 10. Final verdict

`w1_w6_learning_truth_repair_ledger_ready`

> **Corrected by the canonical Act0 route audits
> (`docs/_reviews/canonical_act0_w1_showdown_learning_truth_v1.md` and
> `docs/_reviews/w6_repair_recheck_canonical_admission_gate_v1.md`):** no P1
> survives. `W1W6-DLR-001` is withdrawn as
> `MISSCOPED_NO_CANONICAL_ASSESSMENT`; `W1W6-DLR-002` is withdrawn as
> `MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER`. W1 may improve after Human QA,
> and W6 is frozen pending canonical-only W1-W6 re-audit and Human QA.

The five-wave repair program plus the follow-on prerequisite-chain batch
closed the large majority of the originally identified learner-truth defects,
including the exact defect class named in the mission brief (unexplained
position/table-role labels consumed before being taught). ~~Two P1s survive
reconciliation — a genuine missing W1 source family for hand ranking/showdown/
kicker, and an architecturally blocked W6 repair-recheck path~~ **No active
P1 survives reconciliation.** The alleged W1 showdown/hand-ranking source gap
and the W6 repair-recheck path both came from noncanonical owners when applied
as canonical Act0 blockers. Three bounded P2s and one bounded P3 remain
pending canonical-only revalidation; they are not automatically promoted to
confirmed canonical defects. Human QA should run after the canonical ownership
map, canonical-only re-audit, closure/proof-of-nonissue for learner-facing P2
findings, and any confirmed bounded canonical repairs, consistent with every
prior closed wave's own disclaimer that technical proof does not constitute
learner-outcome proof.
