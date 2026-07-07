# W1-W6 Learning Closure Ledger v1

Source review: `docs/_reviews/w1_w6_deep_learning_reconciliation_v1.md`

Status: implementation-ready ledger. No repair implemented in this pass.

> **Canonical route corrections:**
>
> `W1W6-DLR-001` is **`MISSCOPED_NO_CANONICAL_ASSESSMENT`** and is **removed
> from the active P1 count**. It was derived from the non-canonical Flow-B /
> legacy JSON `showdown_winner_choice_v1` drill kind, not from the canonical
> learner route. The canonical W1 route owns dedicated `hand_rankings_table`
> and `showdown_winning` lessons whose teaching task gates every drill and
> prove-it assessment. The optional `w1.s11` Flow-B session is **not** counted
> as closure evidence.
>
> `W1W6-DLR-002` is
> **`MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER`** and is also **removed from
> the active P1 count**. The old session-drill audit was valid for the owner it
> inspected, but invalid as a canonical Act0 W6 blocker. Canonical W6 uses
> task-centric repair and retention replay; no broken link was found in the
> canonical error -> repair -> aged recheck -> `recheck_completed` ->
> owned-candidate chain. Later session-drill target-launch improvements remain
> optional history, and no canonical W6 product repair is admitted.
>
> Active P1 count is now **0**. The DLR-001/DLR-002 rows and Waves A/B below
> are preserved for history and struck through, not deleted.

## Ledger

| ID | World/seam | Severity | Defect class | Learner impact | Evidence | Current owner | Minimum repair | Dependencies | Validation | Estimated scope |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ~~`W1W6-DLR-001`~~ (MISSCOPED_NO_CANONICAL_ASSESSMENT — historical; not in active count) | W1 (`showdown_winner_choice_v1` rows — **W2-owned Flow-B/legacy JSON kind, not canonical W1**) | ~~P1~~ withdrawn | Hidden prerequisite (assessed before taught) — **premise absent on canonical route; corrected by `canonical_act0_w1_showdown_learning_truth_v1.md`** | A learner can be scored on showdown/hand-ranking/best-5/kicker outcomes inside W1 without W1 ever teaching hand ranking, showdown resolution, the best-five-card rule, or kicker. | `docs/_reviews/w1_w6_prerequisite_chain_repair_batch_v1.md` Section 5, "Source-Blocked Items": no W1-owned hand-ranking/showdown-resolution/best-5-of-7/kicker task exists; W2's showdown source cannot be imported into W1 without an ownership overclaim. | Content authoring (W1 source owner) | Author one small, bounded W1 source family (session or drill slice) that teaches hand ranking, showdown resolution, best-5-of-7, and kicker before the first `showdown_winner_choice_v1` assessed row, using the same beginner-term-guard pattern already proven in Wave 1. Do not import W2 source; do not rewrite W1 broadly. | `content/_meta/term_introduction_contract_v1.json` pattern (reuse, don't invent); existing W1.s01-adjacent session slot | New W1 fixture passes `content_schema_l2_l3_validator_v1.dart` as `learner_playable_route_ready`; a focused test proves the new teaching row precedes every existing `showdown_winner_choice_v1` row in session order. | One bounded content wave (single session/drill slice + one validator/test pass), same size class as the Wave-5.1 W5 `basic_outs_awareness` repair. |
| ~~`W1W6-DLR-002`~~ (MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER — historical; not in active count) | W6 optional/session-drill repair family, not canonical Act0 W6 | ~~P1~~ withdrawn | Repair-continuity gap in the session-drill receipt/queue owner inspected by the old audit — premise absent as a canonical Act0 blocker | The old audit proved that the optional session-drill queue could not safely launch a target drill, but the canonical admission gate found Act0 W6 uses task-centric repair and retention replay instead. | `docs/_reviews/w6_cross_family_route_contract_prerequisite_audit_v1.md` remains valid for the session-drill owner it inspected; `docs/_reviews/w6_repair_recheck_canonical_admission_gate_v1.md` corrects canonical applicability and finds no broken link in the Act0 chain. | Historical optional/session-drill owner only | No canonical W6 product repair admitted. Later session-drill target-launch work remains optional history and must not be counted as W6 canonical score/closure evidence. | Canonical Act0 route ownership map; canonical-only W1-W6 re-audit | Validate only through canonical Act0 evidence: error -> repair -> aged recheck -> `recheck_completed` -> owned-candidate. | Docs-only correction; no product/content/test/tooling/route change. |
| `W1W6-DLR-003` | Learn/Home hierarchy (Act0 shell) | P2 | Beginner cognitive load / action-hierarchy ambiguity (unconfirmed) | Possible competing `Now`/`Current lesson`/`Current step`/progress/mission-CTA emphasis could make the primary action ambiguous on compact mobile; not proven from source, not disproven either. | `docs/_reviews/w1_w6_final_repair_ledger_v1.md` `W1W6-LT-011`; `docs/_reviews/surface_role_cta_coherence_audit_v1.md` downgrades to "needs visual evidence," confirms one structural primary CTA exists in `act0_learn_path_shell_v1.dart` but could not confirm or deny the emphasis-competition claim without a capture. | Act0 Learn/Home shell owner | Do not redesign. Add one compact-portrait widget/screenshot proof that the mission-card CTA visually dominates the `Now`/`Current lesson`/`Current step`/progress labels; if the proof fails, the minimum repair is copy/order/emphasis adjustment only (no layout rebuild). | None outside the existing Act0 Learn/Home shell files | One widget test (or deterministic screenshot lane per the original grouped-program Wave-4 allowance) asserting mission CTA is the single highest-emphasis element at 360x640. | Small: one proof pass, plus a bounded copy/emphasis fix only if the proof fails. |
| `W1W6-DLR-004` | W1-W3 rows + non-admitted W4/W5/W6 families | P2 | Repair-continuity breadth (same-signal receipts too narrow) | Repeated learner misses outside the four admitted same-signal families (W4 denial, W5 dry texture, W6 board-fit strong/missed, W6 width wider/narrower) silently fall back to normal route repetition instead of a durable, provable repair receipt. | `docs/_reviews/w1_w6_final_learner_truth_audit_v1.md` "Repair lifecycle findings"; confirmed still-narrow in Wave 5 closure (`docs/_reviews/w1_w6_repair_wave5_telemetry_repair_proof_v1.md` Section 15: telemetry proof closed, receipt breadth unchanged). | Session-drill repair-receipt owner | Extend receipt admission to the next-highest-EV family only (candidate: W1 starting-hand discipline, given its size and repair-lifecycle maturity per Section 4 evidence), reusing the existing adapter/persistence/consumer/queue seam. Do not attempt full W1-W6 coverage in one pass. | Existing `session_drill_repair_receipt_adapter_v1.dart` / persistence / consumer / queue seam | Focused repair-lifecycle test proving the new family's miss -> receipt -> persistence -> consumer -> queue -> retained-recheck-result chain, mirroring the four already-proven families. | One bounded family-extension wave, same size class as the original Stage 1B family admissions. |
| `W1W6-DLR-005` | W1-W6 prompt/option templates (residue of `W1W6-LT-014`) | P2 | Assessment validity (pattern-guessing / template exploitation) | Repeated template phrasing (e.g. `Which simple action fits best`) and label-heavy options outside the Wave-1/Wave-2 repaired slice may let a pattern-guesser pass without table understanding. | `docs/_reviews/w1_w6_repair_wave1_beginner_truth_v1.md` "Deferred `W1W6-LT-014` remainder"; `docs/_reviews/w1_w6_repair_wave2_feedback_completeness_v1.md` Section 14, "Remaining residue stays deferred... no broad rewrite was attempted." | Content copy / assessment-option policy owner | Run the anti-leak prompt/option scan the grouped program originally specified (representative sampling across W2-W6, not a full rewrite), and patch only the highest-offense template family found, reusing the same clue-owned-feedback pattern already proven in Wave 1's W1.s01 repair. | `tools/term_coverage_scanner.dart` pattern (reuse structure, new rule); Wave-1 W1.s01 before/after as the template. | Scan produces a bounded violation list; representative widget tests confirm patched rows require the table clue, not label elimination. | Bounded scan-and-patch wave, sized to the number of violations the scan actually finds (expect small, based on Wave-1/2 precedent). |
| `W1W6-DLR-006` | W1-W6 content schema (`concept_family_id`) | P3 | Tooling/audit-repeatability debt (not learner-facing) | Same-signal/concept-family grouping is inferred from filenames/intents rather than a validated schema field, which gates future audit repeatability and spaced-repetition tooling, not current learner correctness. | `docs/_reviews/wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md`: "Concept family is implied by filename/intent, not canonical field" (repeated across W1-W6 rows in the coverage table). | Content schema owner | Add `concept_family_id` (and, where already inferable, `same_signal_group`) as an optional schema field on existing rows, backfilled from the same filename/intent convention already in use; no runtime, UI, or scoring change. | `content_schema_l2_l3_validator_v1.dart` (extend, don't replace) | Schema validator accepts the new optional field; existing `coverage_ready` computations are unchanged for rows that already had inferred family identity. | Small, low-risk, backfill-only wave. Not urgent; include only if a future wave already has validator/schema-file access open for another reason. |

## Severity summary

Revised after the canonical Act0 route audits
(`docs/_reviews/canonical_act0_w1_showdown_learning_truth_v1.md` and
`docs/_reviews/w6_repair_recheck_canonical_admission_gate_v1.md`):

- P0: 0
- P1: **0**. `W1W6-DLR-001` withdrawn as
  `MISSCOPED_NO_CANONICAL_ASSESSMENT`; `W1W6-DLR-002` withdrawn as
  `MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER` (was 2, then 1).
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
3. closure or proof-of-nonissue for learner-facing P2 findings;
4. bounded repairs for confirmed canonical gaps;
5. per-world re-score;
6. fixed-build novice Human QA;
7. final bounded repair if QA finds material gaps;
8. hard close only when every W1-W6 world is individually at least 9/10.

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
2. ~~**Wave B — W6 Repair-Recheck Route Contract** (`W1W6-DLR-002`).~~
   **WITHDRAWN AS ACTIVE PRODUCT REPAIR — preserve as historical evidence
   only.** The canonical W6 admission gate found the old finding was scoped to
   optional/session-drill infrastructure, not the canonical Act0 repair owner.
   No W6 product repair is admitted from DLR-002, and no W6 score cap remains
   from that noncanonical evidence.
3. **Canonical W1-W6 ownership map.** Prove route, content, progression,
   completion, telemetry, repair, targeted recheck, payoff, and next-step
   owners for each world before any remaining closure claim.
4. **Canonical-only deep learning re-audit.** Re-read the remaining P2/P3
   items only against the normal Act0 Home/Learn route. Do not automatically
   promote `W1W6-DLR-003`, `W1W6-DLR-004`, or `W1W6-DLR-005` to confirmed
   canonical defects.
5. **Learner-facing P2 closure/proof pass** (`W1W6-DLR-003` through
   `W1W6-DLR-005`). Close as nonissues where canonical proof is sufficient;
   repair only confirmed canonical learner-facing gaps.
6. **Bounded repairs for confirmed canonical gaps.** Scope each repair only
   after the canonical-only re-audit proves the gap is learner-facing and
   required.
7. **Per-world re-score.** Assign evidence-backed scores individually; no
   average-score compensation can offset a world below 9/10.
8. **Fixed-build novice Human QA.** Run only after the canonical-only audit,
   P2 proof pass, and any confirmed bounded repairs.
9. **Final bounded repair and hard close.** Close W1-W6 only when every world
   individually reaches at least 9/10.

W6 score is frozen pending canonical-only W1-W6 re-audit and Human QA. No new
W6 score is assigned here.

## Human QA sequencing

Human QA should run after the canonical ownership map, canonical-only deep
learning re-audit, learner-facing P2 closure/proof pass, and any confirmed
bounded canonical repairs. It should explicitly probe the nine items listed in
Section 8 of `docs/_reviews/w1_w6_deep_learning_reconciliation_v1.md`. Per the
canonical Act0 route audits, W1 Human QA should confirm first-time
comprehension/pacing of the `hand_rankings_table` and `showdown_winning`
lessons, and W6 Human QA should judge canonical task-centric repair/retention
replay only. The old DLR-002 session-drill dead end is historical and must not
cap W6.

## Final verdict

`w1_w6_learning_truth_repair_ledger_ready`
