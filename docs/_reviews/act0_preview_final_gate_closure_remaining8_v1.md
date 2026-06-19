# Act0 Preview Final Gate Closure - Remaining 8 Controlled Pass v1

## 1. Current broad status

Starting command:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Starting result: failed, `+648 -8`

Starting failures:

1. `Opening a lower lesson auto-scrolls its inline hub into view`
2. `Returning to the current lesson from a completed lesson reopens only the target after scroll`
3. `Second wrong answer becomes a deeper Review leak`
4. `First related seat-tap drill restores the same table targets after recall close`
5. `Trail history drill embeds temporal context into the prompt owner`
6. `Action trail reveals appended step after state change`
7. `Your first hand teaches street board growth in order`
8. `World completion seeds compact recheck targets and Home surfaces the return reason`

## 2. Starting failure inventory

| failure | family | classification | confidence |
|---|---|---|---|
| `Opening a lower lesson auto-scrolls its inline hub into view` | Learn selected-panel behavior | stale_test_contract | high |
| `Returning to the current lesson from a completed lesson reopens only the target after scroll` | Learn selected-panel behavior | stale_test_contract | high |
| `Second wrong answer becomes a deeper Review leak` | Review/Practice repair-state semantics | product_fix_candidate plus harness drift | high |
| `First related seat-tap drill restores the same table targets after recall close` | Theory recall target restore | safe_harness_drift | high |
| `Trail history drill embeds temporal context into the prompt owner` | Action-trail ownership | product_decision_blocker | low |
| `Action trail reveals appended step after state change` | Action-trail ownership | product_decision_blocker | low |
| `Your first hand teaches street board growth in order` | Street-board chronology | stale_test_contract | high |
| `World completion seeds compact recheck targets and Home surfaces the return reason` | World-completion retention return copy | retention_contract_blocker | medium |

## 3. Phase-by-phase decisions

### Phase 1 - Learn selected-panel behavior

Decision: A.

Old tests expected stale selected-panel timing and stale lower-lesson auto-scroll behavior. Current Learn is mission-first. Tapping a locked lower lesson must not open a selected panel or steal the active route. Returning to the current lesson may retarget the existing selected panel instead of unmounting it during a transient frame.

### Phase 2 - Theory recall target restore

Decision: A.

The recall helper was stale after the quick-hint/full-idea split. Some recall paths expose `act0_shell_hint_body`; others expose the full idea body directly through `act0_shell_theory_recall_body`. The product behavior under test remains: opening recall, viewing the relevant idea, closing it, and restoring the same table targets.

### Phase 3 - Review/Practice repair-state semantics

Decision: B plus C.

Product fix: Practice weak-spots card was built only from quick-fix records. After a second wrong answer, Review had an open/deep mistake, but Practice had no launchable weak-spots repair card. The recommendation path already prioritized open mistakes, so the smallest product fix was to let the Practice weak-spots group use the top open mistake before quick fixes.

Harness update: current Practice does not auto-launch a runner on tab switch. The test now opens Practice, taps the weak-spots card, and verifies the repair runner opens.

### Phase 4 - Action-trail ownership

Decision: D.

The strings and action-trail widgets exist in source, but the current failing states do not prove whether the old prompt-owner phrase `Read what happened` and appended-step visibility are still product-authoritative. Prior audits classified these as low-confidence ownership blockers. They remain explicit blockers.

### Phase 5 - Street-board chronology

Decision: A.

Current content intentionally includes `your_first_hand_private_cards_recheck` before the flop as a same-signal micro-rep for first-value carry gaps. The test now asserts the street-owner tasks still progress board count in order: preflop `0`, flop `3`, turn `4`, river `5`, while also preserving the inserted private-card recheck before the flop.

### Phase 6 - World-completion retention return copy

Decision: D.

The expected copy `Still yours? Run this spot once more.` still exists in Review aged-recheck code, while Home uses newer copy: `Still yours? One calm replay keeps it honest.` The tested world-completion path currently finds zero instances of the old Review copy. This needs a retention-copy contract decision before changing copy or assertions.

## 4. Fixes applied by group

- Learn selected-panel tests were refreshed to current mission-first behavior.
- Theory recall helper now accepts current quick-hint or full-idea body ownership and then verifies the full idea body.
- Practice weak-spots group now uses the top open mistake before quick fixes.
- Repair-state test now taps the Practice weak-spots card before expecting a runner.
- Street chronology test now checks board growth on street-owner task ids and preserves the private-card recheck ordering.

## 5. Product fixes vs harness fixes vs test updates

Product fix:

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
  - `_practiceGroups` now builds the weak-spots group from `_topOpenMistake()` before `_quickFixMistakes()`.

Harness/test updates:

- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
  - Learn locked-lower-lesson behavior.
  - Learn current-panel return behavior.
  - Recall helper quick-hint/full-idea body detection.
  - Repair-state Practice launch path.
  - Street chronology assertion scope.

## 6. Blockers left explicit and why

Remaining blockers:

1. `Trail history drill embeds temporal context into the prompt owner`
   - Reason: action-trail prompt ownership remains low-confidence product truth.
2. `Action trail reveals appended step after state change`
   - Reason: appended action-history visibility remains low-confidence product truth.
3. `World completion seeds compact recheck targets and Home surfaces the return reason`
   - Reason: retention return-copy contract is not locked between Review aged-recheck copy and newer Home return copy.

These were not forced green because the wave rule required product-truth support before changing tests or product behavior.

## 7. Broad suite before/after

Before:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result: failed, `+648 -8`

After local closure pass:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result: failed, `+653 -3`

Closed failures:

- two Learn selected-panel failures;
- one Review/Practice repair-state failure;
- one theory recall restore failure;
- one street-board chronology failure.

## 8. Fast-loop status

Command:

- `./tools/fast_loop_world1_v1.sh`

Result:

- Failed, `+676 -3`

Fast loop passed tools lint and `flutter analyze`, then failed in the selected broad preview file on the same three explicit blockers:

1. `Trail history drill embeds temporal context into the prompt owner`
   - First assertion: expected text `Read what happened`, found `0`.
2. `Action trail reveals appended step after state change`
   - First assertion: expected key `act0_shell_action_trail_step_2`, found `0`.
3. `World completion seeds compact recheck targets and Home surfaces the return reason`
   - First assertion: expected text `Still yours? Run this spot once more.` twice, found `0`.

The remaining selected fast-loop tests after the broad preview file continued to pass.

## 9. Repair-intent test status

Command:

- `flutter test test/ui_v2/act0_repair_intent_contract_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart --reporter expanded`

Result:

- Passed, `+28`

## 10. Exact next recommended wave or final gate status

Recommended next wave:

`Action-Trail Ownership Truth v1`

Reason: the broad preview gate is now blocked by the smallest remaining blocker family: two action-trail ownership assertions. The retention return-copy blocker should follow once action-history truth is locked.
