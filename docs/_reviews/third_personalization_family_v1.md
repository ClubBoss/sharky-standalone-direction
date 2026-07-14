# Third Personalization Family v1

Status: ADMITTED, pending normal publication

Base: `3d6d29e8`
Implementation commits: `aa946780`, `3db4b78d`

## Admission decision

Selected family: **W4 price read**.

- Canonical source: `world_4` / `call_price` / `w4_bad_price_fold`.
- Source-owned signal: `pot_to_call` (`Pot 8 BB`, `To call 7 BB`).
- Correct answer: `fold`; canonical wrong family: `call`.
- Typed contract: `price_read` / `missed_price_read`.
- Same-signal target: `w4_good_price_call`; it preserves the Pot / to call
  comparison while asking the learner to recognize a small call price.

The candidate is materially distinct from Action (`no_bet_yet`) and Position
(`hero_button`) reading. It reuses the existing source-owned receipt,
repair-intent queue, runner, feedback, payoff, local telemetry, and Learning
Run owners. No new content, dependency, persistence, engine, or Modern Table
change was required.

## Candidate ranking

| Rank | Candidate | Decision |
| --- | --- | --- |
| 1 | W4 price / pot / cost awareness | Selected: canonical source, precise `pot_to_call` signal, reciprocal same-signal W4 repair, small owner surface. |
| 2 | W2 hand bucket / hand strength | Not selected: useful but current source and repair ownership are broader and less direct for one deterministic family. |
| 3 | W5 board context / texture | Not selected: source and repair paths exist, but this mission must not open a later-world content/repair surface when W4 already meets the contract. |

## Learner contract

The canonical miss says why calling is weaker: it risks `7 BB` to win an
`8 BB` pot with a weak pair. Feedback directs the learner to compare the pot
with the call before choosing. Repair presents the same `Pot / to call` clue
in `w4_good_price_call`; a correct recheck yields `price_signal_recovered`,
and a failed recheck yields `price_signal_still_needs_rep`. A correct first
answer produces `price_signal_read_cleanly`. These are local observations,
not mastery claims.

## Learning Run and telemetry

`Act0LearningRunOutcomeV1` remains the single generic normalized outcome
contract. The price family supplies `price_read`, `missed_price_read`,
first-attempt correctness, repair/recheck result, `pot_to_call`,
`compare_pot_to_call`, and stable event ordering. The payoff policy uses its
extensible skill descriptor registry; unresolved evidence still outranks
recovered and clean evidence.

Price-family telemetry is bounded and ordered through the existing sink:
`user_choice` → classification/feedback → `repair_started` → recheck →
payoff. Learning Run also emits the existing normalized outcome, focus,
recommendation, and payoff events with replay protection.

## Validation

- Price contract, correct-first, wrong/repair/failed-recheck/recovered flow,
  compact CTA reachability, telemetry, and normalized Learning Run: PASS.
- Action and Position personalization regressions: PASS.
- Three-skill payoff scenarios A-G, duplicate protection, incomplete handling,
  and source-grounded focus: PASS.
- Canonical progression and W4 repair mapping: PASS.
- `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, Alpha QA Factory,
  `graphify hook-check`, and diff checks: PASS.
- No Modern Table file changed; P0/P1: 0.

Known unrelated baseline debt was reproduced on published `3d6d29e8`: the
legacy telemetry UI file has multiple pre-existing option/CTA failures, and
the W7 owner-contract test expects an older W7 lesson/task count. Neither
failure intersects the admitted W4/Act0 Learning Run owner set.
