# Persist Open Repair Across Relaunch v1

## Scope

Persist the existing deterministic open-repair intent after the one-time
first-value carry is consumed, without adding a new learner-facing surface,
route, telemetry event, or repair state.

## Root cause

`openRepair` retention memory survived relaunch, but the matching in-memory
mistake record and `Act0RepairIntentV1` did not. Once the first-value carry was
consumed, Home could no longer choose the existing repair target.

## Contract

- Persist validated `Act0RepairIntentV1` payloads in
  `_Act0PersistedProgressV1.openRepairIntents` alongside retention memory.
- Restore an intent only when its matching retention entry remains `openRepair`
  for the same source world and lesson.
- Rebuild the existing mistake presentation record from the canonical source
  task and selected option.
- Give an open repair the existing Home primary recommendation after the
  one-time carry has been consumed.
- Keep Practice, Review, and Profile on their existing repair-state seams.

The persisted intent supplies the compact source task, selected choice, missed
signal, skill label, deterministic target, mapping type, and reason code. The
snapshot schema advances from v9 to v10 while continuing to accept v1-v9.

## Return priority

`openRepair` remains ahead of `agedRecheck`, `ownedCandidate`, and route
continuation. Existing target resolution still uses the mapped same-signal hand
when launchable and otherwise falls back to the exact source replay.

## Surface behavior

- Home promotes the existing open-repair recommendation once the one-time
  carry has been consumed.
- Practice launches the stored deterministic repair target.
- Review restores its existing repair-coach card.
- Profile remains the existing compact growth mirror and does not report the
  active repair as clear.

## Coverage

`Open repair remains actionable after carry is consumed and a later relaunch`
proves the persisted intent, Home repair priority, Practice target, Review
repair-coach card, and non-contradictory Profile state across remounts.

## Not changed

- No new UI/card/copy.
- No route, curriculum, telemetry, or persistence of ephemeral feedback.
- No Daily Trainer, screenshot tooling, Modern Table, monetization, or AI work.

## Remaining limitation

Historical v1-v9 snapshots remain readable but cannot recreate an open-repair
intent they never stored. The existing unrelated test
`review queue prioritizes open repair before aged recheck` still fails on the
Step A baseline and is intentionally outside this wave.

## Checks

- Targeted relaunch regression test.
- Repair intent and lifecycle tests.
- Existing carry-relaunch and retention-priority tests, except the documented
  pre-existing Review-queue failure above.
- `flutter analyze`.
- `git diff --check`.
