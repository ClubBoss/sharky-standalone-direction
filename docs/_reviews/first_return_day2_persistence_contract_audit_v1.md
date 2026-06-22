# First Return / Day 2 Persistence Contract Audit v1

## Scope

Audit / PIEC only. This checks whether the existing deterministic return loop
survives relaunch and time separation after first-session repair activity.

No product UI, copy, tests, assets, routes, telemetry, Modern Table,
screenshot tooling, monetization, AI/persona, dashboard, XP, or economy
behavior changed.

## Evidence used

- `docs/_reviews/daily_trainer_habit_loop_learning_depth_piec_v1.md`
- `docs/_reviews/first_week_proof_packet_acceptance_v1.md`
- `docs/_reviews/profile_review_proof_hierarchy_pass_v1.md`
- `docs/_reviews/visual_slice_completion_next_gap_audit_v1.md`
- Home, Practice, Review, Profile, preview-shell, and persisted-progress seams
- relaunch, retention-memory, recheck, and priority-order tests in
  `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

## Persisted-state map

| Event/state | Durable state | Transient state | Day 2 implication |
| --- | --- | --- | --- |
| Wrong feedback | `firstValueReturnCarry`; retention entry with `openRepair`; selected world/lesson/task and progress snapshot. | `_Act0MistakeRecordV1` and `Act0RepairIntentV1`. | Immediate first relaunch can use the carry; later open-repair reconstruction is incomplete. |
| Repair focus | Source repair intent determines mapped/exact target and learner-facing reason. | `_openRepairIntentBySourceTaskId`. | The exact reason/mapping is not independently serialized for a later mount. |
| Repair result | Retention entry becomes `fixedRecent`, with sequence and attempts; skill gains/profile progress persist. | Active receipt/session-summary lines. | Later return can retain the repair outcome, though the immediate receipt ceremony is intentionally session-local. |
| Session repair | Result is reflected through retention/progress state and recent gains. | Feedback/session receipt copy block. | Appropriate for Day 2: carry state, not replay the prior ceremony. |
| Aged recheck | `retentionSequence`, `fixedAtSequence`, `agedRecheck`, and recheck counts persist. | None required. | Rehydrates deterministically into Home/Review recheck work. |
| Owned-skill proof | `ownedCandidate`, `lastRecheckSequence`, and successful recheck count persist. | None required. | Rehydrates deterministically into a calm prove/keep-sharp action. |

## Source-of-truth map

- **Persistence authority:** `_Act0PersistedProgressV1` in the local progress
  snapshot stores daily progress, streak, first-value carry, retention sequence,
  retention entries, profile skill gains, selected route state, and resume
  metadata.
- **Day 2 derivation:** preview-shell hydration restores the snapshot, refreshes
  `fixedRecent -> agedRecheck`, then derives Home jobs and Review replay cards.
- **Home priority:** open repair -> aged recheck -> owned-skill proof -> route
  continuation.
- **Gap:** visible open repair and mapped repair reason also depend on
  `_mistakeRecords` and `_openRepairIntentBySourceTaskId`, which are in-memory
  maps and are not represented in the persisted snapshot.

## Surface verdicts

### Home Day 2

**Partial.** Correct first-value and wrong first-value carry both survive one
fresh mount and launch the same mapped rep. Aged recheck and owned-skill jobs
also rehydrate from retention memory. However, after the first-value carry is
consumed, persisted `openRepair` alone cannot rebuild `_openMistakes()`; Home
can lose the repair-priority job on a later relaunch.

### Practice Day 2

**Partial.** Practice correctly executes a featured repair when the active
recommendation is present and supports daily drills otherwise. It relies on the
same in-memory open-mistake/repair-intent data for an open-repair recommendation,
so the later-relaunch gap propagates here.

### Review Day 2

**Partial.** Aged rechecks and owned candidates rehydrate into deterministic
replay cards and ordering. Persisted `openRepair` is explicitly excluded from
fixed/recovered reconstruction and does not rebuild an active mistake card,
so an unresolved repair can disappear from Review after the immediate carry.

### Profile Day 2

**Partial but non-primary.** Recent skill gains, level/progress, and retained
proof can rehydrate. Profile correctly mirrors proof rather than owning action,
but it cannot mirror an open repair if Home's underlying open-repair
recommendation is no longer reconstructible.

## Existing tests and missing tests

Existing coverage proves:

- correct first-value receipt survives relaunch and launches the same-signal rep;
- wrong first-value carry survives relaunch and wins the immediate Home route;
- progress, retention sequence, and review-memory entries round-trip;
- `fixedRecent` promotes to `agedRecheck` at the deterministic threshold;
- aged recheck ordering is deterministic;
- successful recheck promotes to owned candidate and later stable proof;
- Home and Review prioritize visible open repair over aged recheck while the
  open mistake record is live in memory.

Missing coverage exposes the contract gap:

1. consume the wrong first-value carry, remount again, then verify the same
   unresolved repair is still a Home primary action;
2. verify that later-relaunch Practice launches the persisted repair target;
3. verify that later-relaunch Review shows the unresolved repair above an aged
   recheck;
4. verify Profile's current focus remains coherent with that persisted open
   repair.

## Priority-order verdict

Priority is contract-proven for live state and for rehydrated aged/owned
retention state. It is **not fully contract-proven across a later relaunch for
persisted open repair**, because the source record and repair intent are not
durable.

## Implementation candidates

| Rank | Candidate | Verdict | Rationale |
| ---: | --- | --- | --- |
| 1 | Narrow open-repair persistence fix | Recommended. | Persist or reconstruct the actionable repair record and deterministic target/reason, then add the four relaunch contracts above. |
| 2 | Persistence contract tests only | Insufficient alone. | A new test will correctly fail until the missing open-repair reconstruction exists. |
| 3 | First Return Home Card | Defer. | Home already has a return owner; the issue is missing durable state, not absent UI. |
| 4 | Practice or Review UI fix alone | Reject. | Both depend on the same source-of-truth gap. |
| 5 | Full Daily Trainer card | Reject. | It would duplicate Home/Practice ownership and hide, rather than solve, persistence truth. |
| 6 | Content-depth audit | Later. | Return contract must be correct before broadening content work. |

## Final recommendation

**B. Implement a narrow persistence fix.**

The smallest high-EV next wave should make an unresolved repair fully durable
across a later relaunch: persist or deterministically reconstruct the open
repair's actionable task, source context, and safe repair target/reason; then
lock Home, Practice, Review, and Profile return contracts with targeted tests.

This is not a new Daily Trainer, route, telemetry, or UI system.

## Not now

- no new Daily Trainer card, streak mechanics, notifications, or pressure;
- no dashboard, XP/economy, monetization, AI/persona, or Sharky expansion;
- no Home/Practice/Review/Profile redesign;
- no content/drill expansion or term rewrite;
- no Modern Table or screenshot-tooling work.

## Exact recommended next prompt title

`Persist Open Repair Across Day 2 Relaunch v1 — Local Only`
