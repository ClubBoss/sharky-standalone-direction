# W1-W6 Learning Closure Ledger v1

Source review: `docs/_reviews/w1_w6_deep_learning_reconciliation_v1.md`

Status: Waves 1-3 implemented and canonical-only source re-score complete
(`docs/_reviews/w1_w6_post_repair_canonical_rescore_v1.md`,
verdict `w1_w6_ready_for_bounded_wave4_then_human_qa`). Provisional source-only
scores: W1 8.5, W2 8.5, W3 8.5, W4 8.0, W5 8.0, W6 7.5. W1-W5 are
`SOURCE_READY_FOR_FIXED_BUILD_HUMAN_QA`; W6 is `BOUNDED_WAVE4_REPAIR_REQUIRED`
(scope/payoff reconciliation + checkpoint/forward bridge). Do not assign final
9/10 closure from these implementation waves or the source re-score alone;
final closure remains gated on fixed-build novice Human QA.

This is a local W1-W6 closure route, not a global Alpha route change. Human QA
is not automatically the next global project step. After W1-W6 source closure,
execution returns to the active Alpha backlog and `MASTER_PLAN_v3.0.md` unless
the current execution context explicitly admits W1-W6 fixed-build novice Human
QA.

Latest consolidated admission program:
`docs/_reviews/w1_w6_consolidated_repair_admission_program_v1.md`.

That program supersedes the older placeholder repair-wave ordering below for
implementation admission. The canonical sequence is now:

1. Wave 1 - correctness and trust: incongruent correct-answer feedback titles,
   W2 `apply_hj_decision` binding, and optionally same-owner subtitle copy
   corrections.
2. Wave 2 - assessment validity: prompt-leakage cleanup, W3 six-seat coverage,
   and W2 bucket differentiation.
3. Wave 3 - repair/recheck coverage: canonical W2/W4/W5/W6 same-world
   repairFocus/same-signal targets with first-value telemetry and
   `recheck_completed` proof.
4. Wave 4 - bounded W6 scope/payoff reconciliation and checkpoint/forward
   bridge only; do not automatically admit W4 purpose-to-size, W5
   texture-to-action, W1 load reduction, W2 weak-ace expansion, or full-ring
   curriculum.

No legacy/session-drill repair evidence counts toward W1-W6 canonical scoring.
No final 9/10 score is assigned until fixed-build Human QA.

Wave 1 implementation record:
`docs/_reviews/w1_w6_wave1_canonical_correctness_trust_v1.md`.
This implements CAP-001, CAP-002, and same-source CAP-008 only.

Wave 2 implementation record:
`docs/_reviews/w1_w6_wave2_canonical_assessment_validity_v1.md`.
This implements CAP-003, CAP-004, and confirmed CAP-005 assessment-validity
repairs only.

Wave 3 implementation record:
`docs/_reviews/w1_w6_wave3_canonical_repair_recheck_coverage_v1.md`.
This implements CAP-006 for admitted canonical W2/W4/W5/W6 same-world repair
and recheck coverage only. The post-repair source re-score now assigns W6 a
provisional source-only score of 7.5/10 and admits only bounded W6 Wave 4 work
before local W1-W6 Human QA.

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
| `W1W6-DLR-004` (**SUPERSEDED FOR CANONICAL SCORING by Wave 3** — see note below) | W1-W3 rows + non-admitted W4/W5/W6 families | P2 | Repair-continuity breadth (same-signal receipts too narrow) | Repeated learner misses outside the four admitted same-signal families (W4 denial, W5 dry texture, W6 board-fit strong/missed, W6 width wider/narrower) silently fall back to normal route repetition instead of a durable, provable repair receipt. | `docs/_reviews/w1_w6_final_learner_truth_audit_v1.md` "Repair lifecycle findings"; confirmed still-narrow in Wave 5 closure (`docs/_reviews/w1_w6_repair_wave5_telemetry_repair_proof_v1.md` Section 15: telemetry proof closed, receipt breadth unchanged). | ~~Session-drill repair-receipt owner~~ **Canonical Act0 owner** (`act0FirstValueSameSignalRepMappingV1` in `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`) | ~~Extend receipt admission to the next-highest-EV family reusing the session-drill adapter/persistence/consumer/queue seam.~~ **Superseded:** Wave 3 (`W1W6-CAP-006`) implemented canonical same-world repair/recheck coverage for W2/W4/W5/W6 through the canonical Act0 mapper. Any remaining repair-breadth work must target that canonical mapper, **not** the session-drill receipt seam. Do not follow the struck-through session-drill instruction. | ~~Existing `session_drill_repair_receipt_adapter_v1.dart` / persistence / consumer / queue seam~~ Canonical `act0FirstValueSameSignalRepMappingV1` + repair-intent contract | Focused repair-lifecycle test on the canonical mapper (miss -> same-world target -> repair intent -> aged recheck -> `recheck_completed`), mirroring the Wave 3 proof. | One bounded canonical-mapper extension, if a re-audit proves a still-open canonical family. |
| `W1W6-DLR-005` (**PARTIALLY CLOSED by Wave 2 CAP-005**; only deferred template residue remains) | W1-W6 prompt/option templates (residue of `W1W6-LT-014`) | P2 | Assessment validity (pattern-guessing / template exploitation) | Confirmed prompt/hint leakage in W1/W2/W4/W5 was removed by Wave 2 (CAP-005); the remaining risk is only the deferred template-phrasing residue (e.g. `Which simple action fits best`) and label-heavy options outside the repaired slice, which may let a pattern-guesser pass without table understanding. | `docs/_reviews/w1_w6_repair_wave1_beginner_truth_v1.md` "Deferred `W1W6-LT-014` remainder"; `docs/_reviews/w1_w6_repair_wave2_feedback_completeness_v1.md` Section 14, "Remaining residue stays deferred... no broad rewrite was attempted." | Content copy / assessment-option policy owner | Run the anti-leak prompt/option scan the grouped program originally specified (representative sampling across W2-W6, not a full rewrite), and patch only the highest-offense template family found, reusing the same clue-owned-feedback pattern already proven in Wave 1's W1.s01 repair. | `tools/term_coverage_scanner.dart` pattern (reuse structure, new rule); Wave-1 W1.s01 before/after as the template. | Scan produces a bounded violation list; representative widget tests confirm patched rows require the table clue, not label elimination. | Bounded scan-and-patch wave, sized to the number of violations the scan actually finds (expect small, based on Wave-1/2 precedent). |
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
3. **Wave 3 — Canonical repair/recheck coverage** (`W1W6-CAP-006`).
   **IMPLEMENTED PENDING RE-SCORE AND HUMAN QA.** Canonical Act0 now maps
   admitted W2 bucket, W4 purpose/price/protection, W5 texture/connectedness,
   and W6 range-bucket/pressure misses to same-world launchable repair targets
   while preserving exact replay fallback and source-task attribution. This
   does not assign a new score and does not admit Wave 4 transfer/mastery depth.
4. **Canonical W1-W6 ownership map.** Prove route, content, progression,
   completion, telemetry, repair, targeted recheck, payoff, and next-step
   owners for each world before any remaining closure claim.
5. **Canonical-only deep learning re-audit.** Re-read the remaining P2/P3
   items only against the normal Act0 Home/Learn route. Do not automatically
   promote `W1W6-DLR-003`, `W1W6-DLR-004`, or `W1W6-DLR-005` to confirmed
   canonical defects.
6. **Learner-facing P2 closure/proof pass** (`W1W6-DLR-003` through
   `W1W6-DLR-005`). Close as nonissues where canonical proof is sufficient;
   repair only confirmed canonical learner-facing gaps.
7. **Bounded repairs for confirmed canonical gaps.** Scope each repair only
   after the canonical-only re-audit proves the gap is learner-facing and
   required.
8. **Per-world re-score.** Assign evidence-backed scores individually; no
   average-score compensation can offset a world below 9/10.
9. **Fixed-build novice Human QA.** Run only after the canonical-only audit,
   P2 proof pass, and any confirmed bounded repairs.
10. **Final bounded repair and hard close.** Close W1-W6 only when every world
   individually reaches at least 9/10.

W6 provisional source-only score is 7.5/10. It remains below source-readiness
because of bounded scope/payoff and checkpoint/forward-bridge gaps. No final
9/10 closure is assigned.

## Human QA sequencing

Human QA remains the local W1-W6 fixed-build closure gate after W6 bounded Wave
4 work. It is not automatically the next global Alpha step. After W1-W6 source
closure, execution returns to the active Alpha backlog unless the active
execution context explicitly admits W1-W6 novice Human QA. When admitted, Human
QA should explicitly probe the nine items listed in Section 8 of
`docs/_reviews/w1_w6_deep_learning_reconciliation_v1.md`. Per the canonical
Act0 route audits, W1 Human QA should confirm first-time comprehension/pacing
of the `hand_rankings_table` and `showdown_winning` lessons, and W6 Human QA
should judge canonical task-centric repair/retention replay plus the bounded
Wave 4 scope/payoff bridge. The old DLR-002 session-drill dead end is
historical and must not cap W6.

## Post-repair canonical re-score outputs (factual record)

Source: `docs/_reviews/w1_w6_post_repair_canonical_rescore_v1.md`
(branch `claude/w1-w6-post-repair-canonical-rescore-v1`, base `cdf89b9e`).

- Re-score verdict: `w1_w6_ready_for_bounded_wave4_then_human_qa`.
- Wave 1/2/3 canonical claims verified against live source (PASS).
- Wave 4 admission: only W6 admitted — `ADMIT_WAVE4` for (a) W6 scope/payoff
  reconciliation and (b) a bounded W6 checkpoint/forward bridge. W4
  purpose-to-size, W5 texture-to-action, and W1 load mitigation are
  `HUMAN_QA_FIRST`; W3 6-max/full-ring framing is
  `DEFERRED_BOUNDED_LEARNER_TRUST_CANDIDATE`; residual W2 weak-ace depth is
  `DEFER`.
- 6-max/full-ring framing: `DEFERRED_BOUNDED_LEARNER_TRUST_CANDIDATE` (likely
  high-EV and low-risk; foundation currently teaches 6-max; may be admitted
  when the next W3/content seam opens or product evidence confirms the need;
  no table-layout change and no full-ring assessments).
- Pre-existing failing test
  `test/ui_v2/act0_completed_decision_callback_contract_v1_test.dart`:
  `STALE_TEST_EXPECTATION_PENDING_BOUNDED_TEST_ONLY_FIX` — the helper passes
  `world_5` for the `world_4`-owned `small_half_pot`/`w4_half_pot_bet` sizing
  lesson. Product content is correct and untouched by Waves 1-3. Expected
  bounded test-only repair: change the world argument to `world_4`. Not fixed
  here (out of scope for docs-only).

## Final verdict

`w1_w6_learning_truth_repair_ledger_ready`
