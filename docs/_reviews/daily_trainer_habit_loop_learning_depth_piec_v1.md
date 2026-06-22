# Daily Trainer / Habit Loop Expansion and Learning Depth PIEC v1

## Scope

Audit / PIEC only after the completed first-week proof, visual hierarchy, and
Sharky-presence audits.

No product code, UI, copy, tests, assets, routes, telemetry, Modern Table,
screenshot tooling, monetization, AI/persona, dashboard, XP, or economy
behavior changed.

## Evidence used

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/visual_slice_completion_next_gap_audit_v1.md`
- `docs/_reviews/sharky_character_coaching_presence_v1.md`
- `docs/_reviews/full_surface_visual_design_spec_v1.md`
- `docs/_reviews/first_week_proof_packet_acceptance_v1.md`
- `docs/_reviews/retention_habit_loop_expansion_v1.md`
- `docs/_reviews/act0_first_value_daily_loop_closeout_v1.md`
- Home, Practice, Review, Profile, and preview-shell retention seams
- current local `first_week` packet, already refreshed during the preceding
  visual pass

## Current Day 2 / return-loop map

The app already has a deterministic return system, not only isolated streak or
daily-copy cues:

1. A first correct/wrong result creates a same-signal carry or repair route.
2. Home builds a daily plan from current state in this order: open repair,
   aged recheck, owned-skill proof, and route continuation.
3. Retention memory persists with progress state, including sequence, status,
   fixed/recheck history, and successful recheck count.
4. Fixed recent items become aged rechecks after the deterministic sequence
   threshold; repeated clean rechecks can become an owned-skill candidate.
5. Practice exposes a featured repair or quick daily drill rather than a
   generic content library.
6. Review presents repair/recheck/replay entries, preserving open repair above
   later rechecks.
7. Profile mirrors current focus, recent proof, streak-lite, and progress after
   the return action; it does not own the next action.

This is a real Day 2 / Day 7 capable mechanism, but the current proof packet
does not show a time-separated relaunch journey end to end.

## Surface verdicts

### Home

Home is the return-loop owner. It already maps deterministic state into
`Repair`, `Recheck old spot`, `Prove it`, and route-continuation jobs. It gives
the learner a practical next action without fake urgency. No new Today's Repair
card is justified before proving the existing priority order survives a real
relaunch/day transition.

### Practice

Practice already behaves as the execution surface for a Daily Trainer:

- featured repair takes priority when an open repair exists;
- a short daily drill appears when repair is not the lead job;
- the featured entry carries a signal-specific repair reason when available;
- it avoids turning into a second Learn map.

No rep-surface expansion is justified now.

### Review

Review is the repair/recheck queue, not a separate daily planner. Its current
priority and replay behavior provide useful continuation once Home has chosen a
return reason. Keep its role narrow; do not add a separate daily queue section.

### Profile

Profile is an after-action growth mirror. Current focus and recent proof now
precede metrics. It supports return confidence but should not become an action
planner or a retention dashboard.

## Learning-depth verdict

No concrete content-depth blocker is proven by the first-week packet or the
current deterministic return paths. The active route already has same-signal
replay, repair, recheck, and skilled-proof mechanisms.

The likely learning-depth question is not "add more drills" but whether the
learner still understands vocabulary, examples, and concept progression after
returning. That should be evaluated only after the time-separated return
contract is proven. Broad content expansion, term rewrites, or new spaced-rep
inventory are not admitted by this audit.

## Habit-loop gaps

1. Product-visible Day 2 / relaunch proof is incomplete: the current
   first-week packet is session-centric rather than time-separated.
2. The persisted retention contract is well represented in code and targeted
   tests, but this audit did not inspect a dedicated evidence packet for
   reopen-after-first-value, reopen-after-open-repair, and aged-recheck cases.
3. The product should prove that the same deterministic priority survives a
   fresh mount before adding new daily cards, streak mechanics, or content.

## Implementation candidates

| Rank | Candidate | Verdict | Reason |
| ---: | --- | --- | --- |
| 1 | First Return / Day 2 Persistence Contract Audit | Recommended next. | Existing retention mechanics need a narrow time-separated product/evidence verdict before any new habit UI. |
| 2 | Daily Trainer / Today's Repair Card | Defer. | Home and Practice already expose the underlying object; another card risks duplicate ownership. |
| 3 | Review-driven repair queue | Defer. | Review already owns repair/recheck/replay continuation and should not become a planner/dashboard. |
| 4 | Content-depth / term-introduction audit | Later. | High-EV after return behavior is evidenced; no concrete depth blocker is currently proven. |
| 5 | Release/commercial proof review | Later. | Value proof exists, but trustworthy return proof should precede commercial framing. |

## Final recommendation

**E. Run a narrow First Return / Day 2 Persistence Contract Audit before new
habit implementation.**

The Daily Trainer / habit layer is already materially present through existing
deterministic seams. The highest-EV uncertainty is whether the learner returns
after time/relaunch and receives one stable, meaningful next action based on
real repair or retention state. A new card, queue, or drill expansion before
that proof would duplicate current surface ownership.

## Not now

- no new Daily Trainer / Today's Repair card;
- no new streak, notification, guilt, or scarcity mechanic;
- no dashboard/charts/XP/economy;
- no broad content/drill expansion or terminology rewrite;
- no Review planner or Profile action dashboard;
- no monetization/paywall/trial;
- no Sharky implementation, AI/persona, or Modern Table work;
- no capture tooling changes or generated output commits.

## Exact recommended next prompt title

`First Return / Day 2 Persistence Contract Audit v1 — Local Only`
