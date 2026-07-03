# Targeted Content Repairs v1

Status: CLOSED.
Date: 2026-07-03.
Scope: bounded W1-W12 Phase 7 content/correctness repair ledger only.

## 1. Verdict

targeted_content_repairs_landed_with_explicit_deferrals

All actionable bounded P1-P4 content/correctness items from the accepted
Poker Correctness Review, Solver-Light Selected Checks, and prior same-signal
repair ledger are resolved for current route scope. The only non-fixed item is
the already-known W11/W12 broad `drills/*.json` corpus parity follow-up, which
requires source-truth expansion rather than a correctness repair.

## 2. Preflight

- Worktree:
  `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Expected HEAD: `32da0cd6bdfc109d3dad0cd6d65ad0a82ae2c6e1`
- Actual HEAD: `32da0cd6bdfc109d3dad0cd6d65ad0a82ae2c6e1`
- Pre-repair tracked/staged diff: empty
- Pre-repair status: correct branch with only pre-existing untracked `output/**`
- `graphify hook-check`: passed

No `blocked_by_dirty_scope` or `wrong_worktree_or_head` condition was found.

## 3. Authority check

No `stale_capsule_scope` conflict was found. The active route capsule showed
`Targeted Content Repairs v1` active and Solver-Light closed. Accepted review
artifacts supplied the ledger; exact source, fixture, runtime-owner, and test
files supplied repair truth.

## 4. Merged P1-P4 repair ledger

| ID | Sev | Root cause | Owner | Disposition |
| --- | --- | --- | --- | --- |
| PC-001 / SLCR-001 | P2 | texture presented as action prescription | W5 source JSON, canonical fixtures | fixed |
| PC-002 / SLCR-004 | P3 | continue/fold overcertainty | W11 source packet and campaign fixture | fixed |
| PC-003 / SLCR-002 | P3 | half-pot/value sizing overprecision | W4 source JSON, canonical fixtures | fixed |
| PC-004 / SLCR-003 | P3 | raise-purpose overclaim | W4 source JSON, canonical fixtures | fixed |
| PC-005 / SLCR-005 | P3 | value/bluff binary oversimplification | W10 hidden runtime owner | fixed |
| PC-006 / SLCR-006 | P3 | W3 best-first-action overclaim | W3 source chain and fixture | fixed |
| PC-007 | P4 | W6 beginner range-width simplification | existing W6 fixtures | intentionally_accepted_with_negligible_ev |
| PC-008 | P4 | W8 draw comparison simplification | existing W8 route owner | intentionally_accepted_with_negligible_ev |
| PC-009 / SLCR-007 | P4 | heuristic wording stronger than evidence | touched W3/W5 families | fixed |
| PC-010 | P4 | W9 price classification simplification | existing W9 route owner | intentionally_accepted_with_negligible_ev |
| PC-011 / SLCR-008 | P4 | W11/W12 broad corpus parity | W11/W12 corpus/source truth | deferred_with_explicit_reason |

## 5. W5 texture repair

W5 texture and board-shift prompts now frame texture as the first cue and the
response as drill-scoped. Deterministic phrases such as `Choose the best
action`, `should lead to a raise`, and texture-as-automatic-action wording were
removed from affected source and fixture copy. Answer keys and IDs were not
changed.

## 6. W4 sizing repair

W4 half-pot and pot-value sizing copy now presents sizing as a reasonable or
practical beginner example, not a unique or optimal answer. Accepted alternate
sizes remain intact. No new sizing system or solver claim was introduced.

## 7. W4 raise-purpose repair

W4 protection, bluff-pressure, and denial tasks now say the learner is choosing
the action for the taught purpose in a simplified rep. The repair preserves the
raise answer keys while preventing the copy from sounding like complete
strategy adjudication.

## 8. W11 continue/fold repair

W11 one-focus source and campaign feedback now scopes continues to the
one-focus drill and avoids exact-EV language such as `gives up value` or `too
tight here`. Continue/fold answer keys remain unchanged.

## 9. W10 taxonomy repair

W10 `bet_purpose_transfer_check` now asks for the safest first question among
the beginner purposes taught here. The value-versus-stronger-fold pressure
distinction remains, but the copy no longer implies all bets fit only two
universal buckets.

## 10. PC ledger closure

PC-001 through PC-006 and PC-009 are fixed. PC-007, PC-008, and PC-010 are
intentionally accepted safe beginner simplifications with negligible current
route EV. PC-011 is deferred with explicit source-truth reason.

## 11. Explanation precision pass

Affected W3/W4/W5/W10/W11 source owners were checked for unsupported absolute
phrases including `best action`, `correct size`, `optimal`, `pot is right`,
`should lead`, `gives up value`, and `too tight here`. The remaining use of
`best one-focus decision` in W11 prompts is intentionally scoped by the
one-focus route and repaired feedback; it does not claim solver certainty.

## 12. Beginner simplification safety

The repairs keep each lesson's beginner focus explicit:

- texture is an observation cue before action;
- sizing is a practical beginner example;
- raise tasks are purpose-recognition reps;
- continue/fold is one-focus transfer, not exact EV;
- W10 purpose taxonomy is limited to the taught beginner purpose set.

No false doctrine, advanced terminology, GTO authority, or solver language was
introduced.

## 13. Route/transfer integrity

Route/admission behavior is unchanged. W1-W12 remains the active Volume I
boundary, W13+ remains blocked, Practice mapper scope remains unchanged,
same-signal/transfer IDs remain intact, and repair/proof/telemetry identity
fields were preserved.

## 14. Repairs landed

- Added `test/guards/targeted_content_repairs_contract_test.dart`.
- Repaired W5 texture/action source copy and regenerated W5 canonical fixtures.
- Repaired W4 value-sizing and raise-purpose source copy and regenerated W4
  canonical fixtures.
- Repaired W3 source-framed continue/fold wording and regenerated W3 fixture.
- Repaired W10 transfer taxonomy runtime copy.
- Repaired W11 source packet and campaign fixture feedback precision.
- Updated content-factory exporter overrides to preserve repaired fixture text.
- Added this review artifact and advanced route capsules.

## 15. Explicit deferrals

- PC-011 / SLCR-008: W11/W12 broad `drills/*.json` corpus parity remains
  deferred because fixing it requires source-truth expansion, not bounded
  correctness repair. Current admitted W11/W12 route truth is safe through
  source packets, campaign fixtures, and route-owner guards.
- Practice mapper expansion remains deferred as a separate target-contract
  product scope, not a content correctness issue.

## 16. Final disposition summary

- P1 total: 0.
- P2 total: 1; fixed: 1.
- P3 total: 5; fixed: 5.
- P4 total: 5; fixed: 1; accepted: 3; deferred: 1.
- Fixed count: 7 merged items.
- Accepted count: 3 merged items.
- Deferred count: 1 merged item.

No remaining item affects current-route learning trust. Phase 7 can advance
because the remaining defer is source expansion outside bounded content repair.

## 17. Evidence result

Evidence result: `targeted_content_repairs_landed_with_explicit_deferrals`.

Screenshots were captured local-only under:

- `output/targeted_content_repairs_v1/core_fast/`
- `output/targeted_content_repairs_v1/first_week_fast/`
- `output/targeted_content_repairs_v1/active_route_w7_w12_fast/`
- `output/targeted_content_repairs_v1/full_scroll_fast/`

`output/**` remains uncommitted.

## 18. Tests/validation

Final validation is recorded in the implementation response. Required coverage
includes focused repaired-content tests, correctness guards, same-signal and
route-admission guards, repair/proof tests, mapper/Practice guard coverage,
screenshot lanes, analyzer, graphify hook-check, diff checks, capsule route
checks, and git status.

## 19. Closure decision

close_targeted_content_repairs

## 20. Rolling Capsule Advance

Advance route state:

- `Targeted Content Repairs v1` -> CLOSED
- `Phase 7 Closure Audit v1` -> ACTIVE
- verified active route artifact ->
  `docs/_reviews/targeted_content_repairs_v1.md`

## 21. Scope safety

No W13+, new route/screen, Modern Table change, Practice mapper expansion,
new dependency, full solver layer, broad curriculum expansion, generic
taxonomy framework, or speculative poker advice was introduced.

## 22. Known limitations

This wave does not perform Human QA, launch readiness, public learning-effect
validation, broad W11/W12 corpus expansion, or a full solver/GTO certification.

## 23. Next recommendation

Phase 7 Closure Audit v1
