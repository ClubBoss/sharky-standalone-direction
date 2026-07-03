# Targeted Same-Signal / Transfer Repairs v1

Status: CLOSED.
Date: 2026-07-03.
Scope: W1-W12 admitted route only.

## 1. Verdict

targeted_same_signal_transfer_repairs_landed_with_explicit_deferrals

## 2. Preflight

- Expected HEAD matched: `6f1311aa47b3ce4d93d64176f96bc1a28e66e790`.
- Worktree scope was clean except pre-existing untracked `output/`.
- `graphify hook-check` passed during preflight.
- Active route capsule lagged the prompt by marking Poker Correctness active; the prompt inserted this targeted repair wave as the active route authority.

## 3. Authority check

The repair authority for this wave is the user prompt plus
`docs/_reviews/same_signal_transfer_coverage_audit_v1.md`. Existing route
capsules were updated only after the targeted repairs closed. No W13+ route,
Practice target, solver-light, monetization, or Human QA scope was opened.

## 4. Full P1-P4 gap ledger

- P1 stale historical W11-only guard: fixed.
- P2 W7-W12 repeated answer-slot arc wording / memorization risk: fixed for answer-position pattern.
- P2 W11/W12 source-packet-first shape and registry parity: fixed at current source-owned packet/fixture level; broad `drills/*.json` parity deferred.
- P2 mapper target follow-up: deferred with explicit reason.
- P3 W5/W8 draw nuance: fixed for non-strategic same-slot repetition and existing bounded draw coverage proof; deeper poker nuance deferred to correctness review.
- P3 W10 value/bluff nuance: fixed for non-strategic same-slot repetition and current beginner-safe transfer shape; deeper poker nuance deferred to correctness review.
- P4 W3 drill density: intentionally accepted for current route with negligible EV; no new source-owned W3 spot was fabricated.
- P4 W6 range breadth: intentionally accepted for current route with negligible EV; broader range coverage remains correctness/source dependent.

## 5. W3 repair

W3 was not expanded with a fabricated spot. Focused coverage now asserts the
existing two canonical W3 groups, 12 total tasks, per-group density of 6, and
multiple transfer surfaces. Disposition:
`intentionally_accepted_with_negligible_ev` for this route, because adding a
new W3 spot without source truth would be more risky than the optional density
benefit.

## 6. W5/W8 repair

W5 existing canonical texture, shift, and outs fixtures remain validated,
including flush, open-ended, and gutshot transfer surfaces. W8 hidden runtime
choices now vary correct-answer position across its source-owned four-task arc.
Disposition: non-strategic repetition risk fixed; deeper draw nuance remains
`deferred_with_explicit_reason` to Poker Correctness Review.

## 7. W6 repair

W6 existing canonical coverage remains two six-task same-signal groups with
multiple transfer surfaces. Disposition:
`intentionally_accepted_with_negligible_ev` for current route breadth, with
broader range claims deferred to correctness/source truth rather than invented
inside this repair wave.

## 8. W10 repair

W10 hidden runtime choices now vary correct-answer position across value,
pressure, thin-value caution, and transfer tasks. Disposition: non-strategic
memorization risk fixed; value/bluff correctness nuance remains
`deferred_with_explicit_reason` to Poker Correctness Review.

## 9. W11/W12 parity repair

W11/W12 registry parity is now explicit in guard coverage: both W11 and W12
admitted pack sets are asserted, W13+ remains absent, and both hidden owners
remain Practice-CTA blocked. Broad W11/W12 `drills/*.json` corpus parity is
not fabricated and remains `deferred_with_explicit_reason`.

## 10. Repeated arc wording repair

The repair targets the concrete repeated-answer-position pattern across W7-W12
without changing expected answers or strategic copy. W7, W8, W9, W10, W11, and
W12 each now include at least two correct-answer positions across their hidden
task arcs, and the aggregate covers positions 0, 1, and 2.

## 11. Stale guard repair

`test/guards/w11_route_admission_runtime_contract_test.dart` no longer expects
W12 packs to be absent. It now asserts current W11 and W12 admission, W13+
absence, W11 contract source isolation, mapper no-target reasons, and Practice
CTA absence for W11/W12 hidden owners.

## 12. Mapper follow-up disposition

Mapper follow-up is `deferred_with_explicit_reason`. No W7-W12 Practice target
tuples were fabricated. Focused coverage asserts every W7-W12 hidden task maps
to no target under the default concept-candidate mapper, preserving the current
W1-W6-only target policy.

## 13. Repairs landed

- Added `test/guards/targeted_same_signal_transfer_repairs_contract_test.dart`.
- Varied W7-W12 hidden task answer ordering.
- Updated the stale W11 route-admission guard to current W11/W12 truth.
- Added this review artifact.
- Advanced route and learning capsules.

## 14. Explicit deferrals

- W5/W8 deeper draw correctness nuance: Poker Correctness Review.
- W10 deeper value/bluff correctness nuance: Poker Correctness Review.
- W11/W12 broad `drills/*.json` corpus parity: source-truth follow-up.
- W7-W12 Practice target mapping: blocked until exact source-owned target tuples exist.
- W3 additional density and W6 broader range breadth: accepted for current route; reopen only with source-owned content or correctness findings.

## 15. Remaining risk

Remaining risk is correctness-side, not route-admission-side: draw, range, and
value/bluff nuance still require poker correctness review. W11/W12 source
shape is source-packet-first rather than broad corpus parity.

## 16. Evidence result

Focused repair evidence shows the stale guard fixed, same-slot answer pattern
closed across W7-W12, W3/W5/W6 bounded coverage preserved, W11/W12 parity
asserted, W13+ blocked, and mapper expansion explicitly deferred.

## 17. Tests/validation

Required validation was run after implementation and recorded in the final
turn. Screenshot lanes were required because answer ordering is learner-visible
and were captured under `output/targeted_same_signal_transfer_repairs_v1/`.

## 18. Closure decision

close_transfer_repairs_and_advance

## 19. Rolling Capsule Advance

`Targeted Same-Signal / Transfer Repairs v1` is CLOSED. `W1-W12 Poker
Correctness Review v1` is ACTIVE.

## 20. Scope safety

No W13+ route, Practice target mapping, solver-light check, monetization,
Human QA, broad visual polish, or unrelated app surface was opened. Existing
expected answers and source-owned task meanings were preserved.

## 21. Known limitations

This wave does not certify poker correctness, launch readiness, Human QA,
public learning effect, premium readiness, or broad W11/W12 corpus parity.

## 22. Next recommendation

W1-W12 Poker Correctness Review v1
