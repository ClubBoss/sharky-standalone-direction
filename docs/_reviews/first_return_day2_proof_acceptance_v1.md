# First Return / Day 2 Proof Acceptance v1

## Scope

Audit / evidence acceptance only. No product code, UI, copy, tests, routes,
telemetry, Modern Table, screenshot tooling, Daily Trainer UI, dashboard, XP,
economy, AI/persona, or monetization behavior changed.

## Evidence used

- `docs/_reviews/first_return_day2_persistence_contract_audit_v1.md`
- `docs/_reviews/persist_open_repair_day2_relaunch_v1.md`
- `docs/_reviews/review_queue_fixture_contract_repair_v1.md`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `test/ui_v2/act0_review_shell_v1_test.dart`
- Current pushed main through `90df4979`

## Day 2 story verdict

**Accepted by contract tests.** The intended return story is now covered:
first session miss -> persisted open repair -> later relaunch -> Home repair
priority -> Practice same repair target -> Review active repair continuation ->
Profile does not falsely mark the state clear.

This is not yet accepted as a visual proof packet because the current fast
evidence lanes do not package the Day 2 relaunch story as one review artifact.

## Surface verdicts

### Home

**Accepted.** `Open repair remains actionable after carry is consumed and a
later relaunch` proves Home promotes the open repair after the one-time carry is
gone. `Home prioritizes open repair over aged recheck` proves open repair stays
above recheck work.

### Practice

**Accepted.** The relaunch regression proves Practice launches the same stored
repair target (`actions_check_drill`) after remount.

### Review

**Accepted.** The relaunch regression proves the active repair-coach card
returns. `review queue prioritizes open repair before aged recheck` proves open
repair appears before unrelated recovered/recheck proof and is not duplicated in
the recovered queue.

### Profile

**Accepted.** The relaunch regression verifies Profile remains available and
does not contradict the active repair by showing the clear-state line.

## Fallback priority verdict

**Accepted by tests.** The proven priority is:

1. open repair;
2. aged recheck;
3. owned proof / keep-sharp;
4. route continuation.

`fixedRecent` aging, aged recheck promotion, owned-candidate proof, and Home
prove-job coverage remain in the existing retention test set.

## Tests / evidence map

| Contract | Evidence |
| --- | --- |
| Correct first-value carry relaunch | `Correct first-value receipt survives relaunch and launches same-signal rep` |
| Wrong first-value carry before consumption | `Wrong first-value receipt survives relaunch but open repair still wins` |
| Open repair after carry consumption and later relaunch | `Open repair remains actionable after carry is consumed and a later relaunch` |
| Home open-repair priority over recheck | `Home prioritizes open repair over aged recheck` |
| Review open-repair priority over recheck | `review queue prioritizes open repair before aged recheck` |
| Review repair coach contract | `test/ui_v2/act0_review_shell_v1_test.dart` |
| Aged/owned retention fallback | Existing retention sequence, aged recheck, and owned-candidate tests in `act0_shell_preview_screen_v1_test.dart` |

## Remaining proof gaps

- Historical v1-v9 snapshots can be read but cannot recreate open-repair
  intents they never stored.
- No dedicated Day 2 screenshot/proof packet currently shows the relaunch story
  end-to-end for product/design/commercial review.
- Existing first-week packets prove the first-session story, not the Day 2
  return state after carry consumption.

## Day 2 capture lane needed

**Yes, for evidence review.** Tests are enough for this code checkpoint, but a
narrow Day 2 proof packet is the right next evidence step before using the
return loop in commercial/design review.

The lane should reuse current fast real-text capture infrastructure where
possible and capture only deterministic return states; it should not add
product behavior.

## Next candidates ranked

1. **Add a Day 2 proof capture lane.** Best next step because behavior is now
   contract-proven but not packaged visually.
2. **Commercial screenshot / renderer acceptance.** Useful after Day 2 proof is
   capturable as a packet.
3. **Content-depth / term-introduction audit.** Valuable, but should follow the
   return-proof packet so product evidence stays coherent.
4. **First Return UI / CTA improvement.** Defer until visual evidence shows the
   return action is unclear.
5. **Release / commercial proof packet.** Defer until Day 2 proof is included or
   explicitly waived.

## Final recommendation

Proceed with a local-only Day 2 proof packet/capture lane. Do not start a Daily
Trainer card, new UI layer, or return-dashboard work.

## Exact recommended next prompt title

`First Return / Day 2 Proof Packet Capture Lane v1 — Local Only`

## Validation

- `git status --short`
- `git diff --check`

Generated outputs remain local-only and uncommitted.
