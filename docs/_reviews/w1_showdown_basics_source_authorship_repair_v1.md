# W1 Showdown Basics Source/Authorship Repair v1

Status: REVIEW ARTIFACT.
Branch: `codex/w1-showdown-basics-source-authorship-repair-v1`.
Baseline: `7a16d387` (`w1_w6_prerequisite_chain_repair_partial_needs_followup`).
Verdict: `w1_showdown_basics_repair_ready_recommends_outcome_verification`.

## 1. Verdict

Path B passes. A tiny W1-owned source/authorship slice now covers beginner hand
ranking, best-5-of-7, visible-card showdown winners, kicker tiebreaks, and a
board-plays tie. The generated six-task canonical fixture passes foundation and
L2/L3 validation.

This resolves the remaining known Tier A prerequisite-chain source blocker. It
does not prove Human QA readiness, 9.0, launch readiness, full beginner mastery,
or every poker hand-comparison edge case.

## 2. Baseline

The accepted prerequisite-chain repair batch closed IP/OOP, equity/protection,
draw, basic outs, range, pot, and defend gaps. It left W1 hand ranking,
showdown, best-5-of-7, and kicker source-blocked because W1 owned no source
family for those concepts.

W1 was technical 8.5; W2-W6 were bounded technical 8.0; W1-W12 readiness was
8.1; overall top-1 readiness was 6.6.

## 3. Source / Authorship Decision

Selected: Path B.

Created
`content/worlds/world1/v1/source_repairs/showdown_basics_v1/` as a narrow,
non-routed W1-owned source slice. W1 world goals name this bounded foundation;
the active ten-session runtime index remains unchanged.

## 4. Why Path B Was Selected

Path A was unavailable because existing W1 source did not contain the required
tasks. Path C would have preserved honesty but weakened the literal `Poker from
Zero` job despite a safe bounded source repair being feasible.

Path B adds the missing foundation without copying or promoting W2 bridge
evidence and without adding strategy.

## 5. W1 Showdown Blocker Disposition

Resolved with six W1-owned source tasks and one generated canonical fixture:

- concept family: `showdown_basics`;
- same-signal group: `w1.showdown_basics.best_five_comparison`;
- repair focus: `best_five_before_showdown_winner`;
- five transfer surfaces;
- `launch_coverage_claimed=false` on every task.

## 6. Hand Ranking Coverage

Two direct recognition tasks establish that:

- a straight outranks two pair;
- a flush outranks a straight.

The session source provides the full beginner hand-rank order from high card
through straight flush. The claim remains basic recognition, not mastery of
all tie-resolution edge cases.

## 7. Best-5-of-7 Coverage

The source states that a hold'em hand is the strongest five-card hand available
from two hole cards plus five board cards, and that the best five may use two,
one, or zero hole cards.

One task requires selecting the 9-8-7-6-5 straight from seven available cards.

## 8. Showdown Winner Coverage

One visible-card task compares hero's pair of aces with villain's pair of
queens. The feedback requires building each best five before naming hero as the
winner.

## 9. Kicker Coverage

One visible-card task ties the main pair of aces, then resolves the winner with
hero's king kicker over villain's queen kicker. Source copy states that a kicker
applies only after the main hand rank ties and never makes a lower rank beat a
higher rank.

One board-plays task also proves that identical best-five hands tie rather than
forcing a kicker comparison.

## 10. Claim-Safety Review

Passed:

- beginner visible-card comparisons only;
- no ranges, equity math, pot odds, stack/tournament/ICM, exploit strategy,
  advanced hand reading, solver, or GTO content;
- no 9.0, Human QA, launch, monetization, or full-mastery claim;
- safe status remains `canonical_pilot`;
- launch coverage remains false.

## 11. Bridge / Canonical Preservation

No W2 source file, source ID, bridge task, or bridge metadata was copied or
promoted. Every migration source points to the W1-owned
`source_repairs/showdown_basics_v1` slice, and every task is owned and routed
by `world_1`.

W2-W6 bridge/canonical contracts and fixtures are unchanged.

## 12. Validation

Passed:

- factory import/export generated the fixture deterministically;
- W1 foundation validator: 6 tasks, 6 countable, 6 migration sources;
- W1 fixture L2/L3: `learner_playable_route_ready`;
- aggregate W1 L2/L3: 7 fixtures, 42 countable tasks,
  `learner_playable_route_ready`;
- W2-W6 bridge plus canonical negative controls remain
  `bridge_or_legacy_limited`;
- focused tests: 49 passed after the RED failures proved the missing source,
  fixture, and runtime-session-isolation contracts;
- W1 deterministic world-source scan: no W1 errors; the full legacy validator
  still reports pre-existing W5/W6 findings outside this wave;
- Dart format and Flutter analyze;
- graphify hook-check;
- tracked and cached diff checks;
- direct and diff-only ASCII, trailing whitespace, CRLF, and final-newline
  checks.

## 13. Score / Ledger Impact

- W1 remains technical 8.5.
- W2-W6 remain bounded technical 8.0.
- W1-W12 Volume I Premium Product Readiness: `8.1 -> 8.2`.
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0`.
- Overall top-1 readiness: unchanged at `6.6`.

The +0.1 reflects one real W1-owned, validator-backed prerequisite family. It
does not represent Human QA or learning-effect proof.

## 14. Route Impact

No runtime session, route, title, lock, or handoff changed. W7-W12 remain
closed or non-routed. W13-W36 remain deferred.

## 15. Remaining Blockers

- live novice Human QA has not run;
- durable cross-session learner outcome proof remains incomplete;
- broad W1-W6 migration remains incomplete;
- local P2/P3 outcome cleanup remains queued;
- no public learning-effect or launch claim is safe.

## 16. Anti-Theater Check

This wave adds source, six executable tasks, deterministic factory output,
same-signal/transfer/repair metadata, and validators. It does not relabel W2
bridge evidence or treat a document as learner-outcome proof.

## 17. Next Wave Decision

Recommended next wave:

`W1-W6 Outcome Repair Verification / Local Cleanup v1`

That wave should verify the repaired prerequisite chain as a whole and close
only directly evidenced local terminology/ordering issues before Human QA
planning. It must not open W7-W12 or claim 9.0.
