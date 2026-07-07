# W1-W6 Learning Closure Ledger v1

Source review: `docs/_reviews/w1_w6_deep_learning_reconciliation_v1.md`

Status: implementation-ready ledger. No repair implemented in this pass.

> **Correction (canonical Act0 route audit,
> `docs/_reviews/canonical_act0_w1_showdown_learning_truth_v1.md`):**
> `W1W6-DLR-001` is **`MISSCOPED_NO_CANONICAL_ASSESSMENT`** and is **removed
> from the active P1 count**. It was derived from the non-canonical Flow-B /
> legacy JSON `showdown_winner_choice_v1` drill kind (W2-owned; found only in
> `lib/archive/legacy_runners/...`, `lib/services/drill_contract_v1.dart`,
> `lib/services/world2_showdown_truth_validator_v1.dart`,
> `lib/audit_hub_v1/...`), not from the canonical learner route. The canonical
> W1 route (`AppRoot -> Act0ShellPreviewScreenV1 -> _pokerFromZeroLessons`)
> owns dedicated `hand_rankings_table` and `showdown_winning` lessons whose
> teaching (`learn`/theory) task is the gating first task and provably precedes
> every drill and prove-it assessment. There is no canonical assessed-before-
> taught event, so the finding's premise does not exist on the reachable route.
> The optional `w1.s11` Flow-B session is **not** counted as closure evidence.
> The DLR-001 row and Wave A below are preserved for history and struck through,
> not deleted. No replacement canonical finding is warranted (canonical
> contract closed). Active P1 count is now **1** (`W1W6-DLR-002` only).

## Ledger

| ID | World/seam | Severity | Defect class | Learner impact | Evidence | Current owner | Minimum repair | Dependencies | Validation | Estimated scope |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ~~`W1W6-DLR-001`~~ (MISSCOPED_NO_CANONICAL_ASSESSMENT — historical; not in active count) | W1 (`showdown_winner_choice_v1` rows — **W2-owned Flow-B/legacy JSON kind, not canonical W1**) | ~~P1~~ withdrawn | Hidden prerequisite (assessed before taught) — **premise absent on canonical route; corrected by `canonical_act0_w1_showdown_learning_truth_v1.md`** | A learner can be scored on showdown/hand-ranking/best-5/kicker outcomes inside W1 without W1 ever teaching hand ranking, showdown resolution, the best-five-card rule, or kicker. | `docs/_reviews/w1_w6_prerequisite_chain_repair_batch_v1.md` Section 5, "Source-Blocked Items": no W1-owned hand-ranking/showdown-resolution/best-5-of-7/kicker task exists; W2's showdown source cannot be imported into W1 without an ownership overclaim. | Content authoring (W1 source owner) | Author one small, bounded W1 source family (session or drill slice) that teaches hand ranking, showdown resolution, best-5-of-7, and kicker before the first `showdown_winner_choice_v1` assessed row, using the same beginner-term-guard pattern already proven in Wave 1. Do not import W2 source; do not rewrite W1 broadly. | `content/_meta/term_introduction_contract_v1.json` pattern (reuse, don't invent); existing W1.s01-adjacent session slot | New W1 fixture passes `content_schema_l2_l3_validator_v1.dart` as `learner_playable_route_ready`; a focused test proves the new teaching row precedes every existing `showdown_winner_choice_v1` row in session order. | One bounded content wave (single session/drill slice + one validator/test pass), same size class as the Wave-5.1 W5 `basic_outs_awareness` repair. |
| `W1W6-DLR-002` | W6 (range-bucket repair family) / W5→W6 seam | P1 | Repair-continuity gap (no recovery proof reachable) | A captured, classified, queued W6 range-bucket repair signal has no safe existing route back to its exact target drill; a repeated-error learner at the route's terminal gate (before W7-W10) cannot be proven to receive recovery. | `docs/_reviews/w6_cross_family_route_contract_prerequisite_audit_v1.md`: verdict `unsafe_missing_contract_stop`; no canonical route/launcher/terminal payload/surfaced runner accepts a target-drill id; naive `initialDrillId` would corrupt progress/completion/telemetry semantics. | Act0 canonical launch / session-drill runner owner | Implement the two contracts the audit already scoped as minimal-safe: (1) a validated `SessionDrillLaunchTargetV1`-class payload carrying `sessionId` + `targetDrillId` + a named recheck purpose, failing closed on invalid ids without progress/telemetry mutation; (2) a distinct targeted-recheck completion policy in the surfaced runner (ordering, completion, persistence, telemetry) separate from normal session completion. Visible Act0 consumer wiring stays a later, separately scoped decision. | `SessionDrillRecheckLaunchQueueItemV1` (already exists); `CanonicalLauncherV1`/`CanonicalTerminalSessionDrillSurfacedRunnerV1` (existing owners to extend, not replace) | Focused contract tests proving: invalid target id fails closed with no progress/telemetry mutation; valid targeted recheck completes without emitting a full-session `session_drills_complete_v1`; existing normal-session completion path is unchanged (regression lock). | One dedicated cross-family route-contract wave, exactly as recommended in the source audit's "Required next wave" section — bounded, does not touch UI, Modern Table, or W7+. |
| `W1W6-DLR-003` | Learn/Home hierarchy (Act0 shell) | P2 | Beginner cognitive load / action-hierarchy ambiguity (unconfirmed) | Possible competing `Now`/`Current lesson`/`Current step`/progress/mission-CTA emphasis could make the primary action ambiguous on compact mobile; not proven from source, not disproven either. | `docs/_reviews/w1_w6_final_repair_ledger_v1.md` `W1W6-LT-011`; `docs/_reviews/surface_role_cta_coherence_audit_v1.md` downgrades to "needs visual evidence," confirms one structural primary CTA exists in `act0_learn_path_shell_v1.dart` but could not confirm or deny the emphasis-competition claim without a capture. | Act0 Learn/Home shell owner | Do not redesign. Add one compact-portrait widget/screenshot proof that the mission-card CTA visually dominates the `Now`/`Current lesson`/`Current step`/progress labels; if the proof fails, the minimum repair is copy/order/emphasis adjustment only (no layout rebuild). | None outside the existing Act0 Learn/Home shell files | One widget test (or deterministic screenshot lane per the original grouped-program Wave-4 allowance) asserting mission CTA is the single highest-emphasis element at 360x640. | Small: one proof pass, plus a bounded copy/emphasis fix only if the proof fails. |
| `W1W6-DLR-004` | W1-W3 rows + non-admitted W4/W5/W6 families | P2 | Repair-continuity breadth (same-signal receipts too narrow) | Repeated learner misses outside the four admitted same-signal families (W4 denial, W5 dry texture, W6 board-fit strong/missed, W6 width wider/narrower) silently fall back to normal route repetition instead of a durable, provable repair receipt. | `docs/_reviews/w1_w6_final_learner_truth_audit_v1.md` "Repair lifecycle findings"; confirmed still-narrow in Wave 5 closure (`docs/_reviews/w1_w6_repair_wave5_telemetry_repair_proof_v1.md` Section 15: telemetry proof closed, receipt breadth unchanged). | Session-drill repair-receipt owner | Extend receipt admission to the next-highest-EV family only (candidate: W1 starting-hand discipline, given its size and repair-lifecycle maturity per Section 4 evidence), reusing the existing adapter/persistence/consumer/queue seam. Do not attempt full W1-W6 coverage in one pass. | Existing `session_drill_repair_receipt_adapter_v1.dart` / persistence / consumer / queue seam | Focused repair-lifecycle test proving the new family's miss -> receipt -> persistence -> consumer -> queue -> retained-recheck-result chain, mirroring the four already-proven families. | One bounded family-extension wave, same size class as the original Stage 1B family admissions. |
| `W1W6-DLR-005` | W1-W6 prompt/option templates (residue of `W1W6-LT-014`) | P2 | Assessment validity (pattern-guessing / template exploitation) | Repeated template phrasing (e.g. `Which simple action fits best`) and label-heavy options outside the Wave-1/Wave-2 repaired slice may let a pattern-guesser pass without table understanding. | `docs/_reviews/w1_w6_repair_wave1_beginner_truth_v1.md` "Deferred `W1W6-LT-014` remainder"; `docs/_reviews/w1_w6_repair_wave2_feedback_completeness_v1.md` Section 14, "Remaining residue stays deferred... no broad rewrite was attempted." | Content copy / assessment-option policy owner | Run the anti-leak prompt/option scan the grouped program originally specified (representative sampling across W2-W6, not a full rewrite), and patch only the highest-offense template family found, reusing the same clue-owned-feedback pattern already proven in Wave 1's W1.s01 repair. | `tools/term_coverage_scanner.dart` pattern (reuse structure, new rule); Wave-1 W1.s01 before/after as the template. | Scan produces a bounded violation list; representative widget tests confirm patched rows require the table clue, not label elimination. | Bounded scan-and-patch wave, sized to the number of violations the scan actually finds (expect small, based on Wave-1/2 precedent). |
| `W1W6-DLR-006` | W1-W6 content schema (`concept_family_id`) | P3 | Tooling/audit-repeatability debt (not learner-facing) | Same-signal/concept-family grouping is inferred from filenames/intents rather than a validated schema field, which gates future audit repeatability and spaced-repetition tooling, not current learner correctness. | `docs/_reviews/wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md`: "Concept family is implied by filename/intent, not canonical field" (repeated across W1-W6 rows in the coverage table). | Content schema owner | Add `concept_family_id` (and, where already inferable, `same_signal_group`) as an optional schema field on existing rows, backfilled from the same filename/intent convention already in use; no runtime, UI, or scoring change. | `content_schema_l2_l3_validator_v1.dart` (extend, don't replace) | Schema validator accepts the new optional field; existing `coverage_ready` computations are unchanged for rows that already had inferred family identity. | Small, low-risk, backfill-only wave. Not urgent; include only if a future wave already has validator/schema-file access open for another reason. |

## Severity summary

Revised after the canonical Act0 route audit
(`docs/_reviews/canonical_act0_w1_showdown_learning_truth_v1.md`):

- P0: 0
- P1: **1** (`W1W6-DLR-002` only). `W1W6-DLR-001` withdrawn as
  `MISSCOPED_NO_CANONICAL_ASSESSMENT` (was 2).
- P2: 3 (`W1W6-DLR-003`, `W1W6-DLR-004`, `W1W6-DLR-005`)
- P3: 1 (`W1W6-DLR-006`)
- P4: 0

## Canonical route ownership closure gate

No W1-W6 world can receive score, closure, readiness, Human QA readiness, or
progression-admission credit until its canonical learner chain is proven:

`App launch -> Home/Learn entry -> required lesson/task -> teaching -> guided practice -> independent assessment -> feedback -> repair -> targeted recheck -> completion -> next task/lesson/world`

The proof packet for each world must identify the canonical owners for route
entry, content source, progression, completion, telemetry, repair, targeted
recheck, payoff, and next-step routing. Optional, debug-support,
legacy-blocked, dormant, archived, and parallel flows can be noted as context,
but they do not count toward canonical W1-W6 score or closure unless proved
required by the normal learner route.

`W1W6-DLR-001` is the controlling precedent: Flow-B JSON Session Drills and
optional `w1.s11` coverage do not improve canonical W1 because the normal route
is Act0 Home/Learn. The historical P1 was misscoped, not fixed by Flow-B
content.

Every remaining closure packet must scan these defect classes:

1. parallel route owners;
2. content exists but is not progression-required;
3. teaching in one flow and assessment in another;
4. completion written outside canonical progress;
5. telemetry emitted by a noncanonical owner;
6. repair receipts without reachable canonical recheck;
7. score claims based on optional/debug/legacy surfaces;
8. canonical UI using a different content owner than the audited source;
9. duplicate or competing progression owners;
10. learner-reachable but nonrequired side paths mistaken for curriculum.

W1-W6 closure sequence:

1. canonical route-ownership map for W1-W6;
2. canonical-only deep-learning re-audit;
3. bounded repair of confirmed canonical gaps;
4. closure or proof-of-nonissue for learner-facing P2 findings;
5. reconcile title, job, and identity drift affecting learning;
6. evidence-backed re-score for each world;
7. fixed-build novice Human QA;
8. final bounded repair if QA finds material gaps;
9. hard close only when every W1-W6 world is individually at least 9/10.

No average can compensate for a world below 9/10. P3 tooling remains optional
unless it affects learner quality, canonical proof, or audit repeatability.

## Consolidated repair waves (implementation order)

Ordered by prerequisite dependency and learner EV, per the consolidation
requirement (no unrelated UI/architecture work; smallest change that restores
the learning contract).

1. ~~**Wave A — W1 Showdown/Hand-Ranking Source Closure** (`W1W6-DLR-001`).~~
   **WITHDRAWN — do not execute.** The canonical Act0 route already teaches
   hand ranking and showdown before assessing them
   (`docs/_reviews/canonical_act0_w1_showdown_learning_truth_v1.md`); this wave
   would have authored source against the non-canonical Flow-B pipeline. The
   optional `w1.s11` session built under the original DLR-001 premise is not
   canonical closure evidence and must not be integrated. (Historical text:
   "Highest EV: closes the one remaining hidden-prerequisite defect in the
   world every learner starts from, and unblocks Human QA planning that the
   prerequisite-chain audit explicitly gated on this item.")
2. **Wave B — W6 Repair-Recheck Route Contract** (`W1W6-DLR-002`).
   Second-highest EV: closes the repair-continuity gap at the route's
   terminal gate before any W7-W12 expansion is considered, and is already
   fully scoped by the source architecture audit (two named contracts, no
   design work left to do).
3. **Wave C — Learn/Home Hierarchy Proof** (`W1W6-DLR-003`).
   Cheapest wave: one proof pass, with a fix only if the proof fails. Should
   run before Human QA so the Human QA protocol does not have to rediscover
   an already-suspected ambiguity from scratch.
4. **Wave D — Same-Signal Receipt Extension, next family only** (`W1W6-DLR-004`).
   Bounded extension of an existing seam; do not batch with Wave B even
   though both touch repair-receipt machinery, because Wave B is an
   architecture/contract fix and Wave D is a content-family admission —
   mixing them risks re-litigating Wave B's scope.
5. **Wave E — Prompt/Option Anti-Leak Scan** (`W1W6-DLR-005`).
   Run after Waves B-D. (No longer gated on the withdrawn Wave A.) The
   canonical-route audit noted a few generic/templated `feedbackTitle` strings
   in the W1 showdown/hand-ranking runners; fold that cosmetic residue into
   this scan rather than opening a dedicated wave.
6. **Wave F — `concept_family_id` Schema Backfill** (`W1W6-DLR-006`, optional).
   Only bundle into a wave that already has validator/schema access open for
   another reason; do not open a dedicated wave for this alone.

Recommend running Wave B first (the one surviving self-contained P1 closure),
then C-E in one combined small-wave pass, with F opportunistic. Wave A is
withdrawn (see above).

## Human QA sequencing

Human QA should run after Wave B closes (matching every prior closed wave's own
disclaimer that technical proof does not equal learner-outcome proof), and
should explicitly probe the nine items listed in Section 8 of
`docs/_reviews/w1_w6_deep_learning_reconciliation_v1.md`. Per the canonical
Act0 route audit, W1 Human QA should also confirm first-time comprehension /
pacing of the `hand_rankings_table` and `showdown_winning` lessons, since the
W1 score is now `W1_SCORE_MAY_IMPROVE_AFTER_HUMAN_QA` (the prior 7.5 cap
rationale — assessed-before-taught — is invalidated).

## Final verdict

`w1_w6_learning_truth_repair_ledger_ready`
