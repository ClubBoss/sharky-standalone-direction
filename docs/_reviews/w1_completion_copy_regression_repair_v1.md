# W1 Completion Copy Regression Repair v1

## 1. Verdict

`w1_completion_copy_regression_repaired`

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `54e9199d3a892c595f79cd300fde884f6300af0b`
- Tracked/staged changes at start: none
- Untracked scope at start: `output/**` only
- `graphify hook-check`: passed

## 3. Regression Reproduction

Focused red run before production repair:

- `flutter test test/ui_v2/act0_world1_completion_payoff_v1_test.dart`

Failure:

- `completed W1 shows milestone role and full copy hierarchy`
- Expected W1 text: `You banked the first table read.`
- Actual: no matching widget, because the phrase resolver returned the generic Foundation world-completion copy.

Added a phrase-contract regression assertion and confirmed the owner seam also failed:

- `Act0SharkyCoachMomentV1.worldOneCompletionPayoff` returned `World complete with a real table read.`

## 4. Accepted W1 Copy Truth

Source of truth: `docs/_reviews/w1_completion_payoff_v1.md`.

Accepted W1 hierarchy:

- identity/payoff: `You banked the first table read.`
- learning takeaway: `You learned how to read the table before acting.`
- no-proof fallback: `Repair proof banks the next time you fix one.`
- next-world label: `Next: Hand Discipline`
- next-world preview: `World 2 starts with a simple question: which hands deserve action?`
- CTA: `Open next world`

## 5. Root Cause

The Foundation/Developing phrase migration preserved a separate legacy moment,
`Act0SharkyCoachMomentV1.worldOneCompletionPayoff`, but its legacy phrase
context was indistinguishable from the generic `worldCompletionPayoff` context.

Both resolved through the same `worldComplete` branch with no W1 semantic
world marker, so W1 collapsed into the generic Foundation line.

## 6. Repair

Restored W1-specific phrase ownership in
`act0_sharky_coach_phrase_contract_v1.dart`:

- `worldOneCompletionPayoff` now builds a completion context with
  `worldNumber: 1` and `nextWorldNumber: 2`.
- The existing `worldComplete` resolver returns
  `You banked the first table read.` only when `context.worldNumber == 1`.
- Generic Foundation and Developing world-completion copy remains unchanged.

No widget hardcoding was reintroduced.

## 7. Ownership Preservation

The shared phrase resolver remains the copy owner. The W1 widget still calls
`summary.worldOneCompletionPayoffLabel`, which resolves through the phrase
contract. No second resolver, phrase library expansion, generic completion
refactor, or rendered-string parsing was added.

## 8. W2-W6 / W4->W5 Regression Safety

Regression tests prove:

- W2, W3, W5, and W6 ordinary completion payoff behavior remains unchanged.
- W4 still uses the dedicated W4->W5 band-transition milestone, not the
  ordinary completion card.
- W4->W5 copy remains `Foundation complete.` / `Next: Developing Player`.
- W13+ remains outside completion-payoff scope.

## 9. Phrase / State Consistency

Companion state resolution is unchanged. Both `worldOneCompletionPayoff` and
`worldCompletionPayoff` still resolve to the `milestone` companion state from
structured completion context, not from phrase text. Tier still controls copy
only where already admitted; this repair adds no Home migration or visual
growth behavior.

## 10. Tests / Validation

Focused validation passed:

- `flutter test test/ui_v2/act0_world1_completion_payoff_v1_test.dart test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart`
- `flutter test test/ui_v2/act0_world1_completion_payoff_v1_test.dart test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart test/ui_v2/act0_w4_w5_band_transition_milestone_v1_test.dart test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart test/ui_v2/act0_sharky_companion_state_v1_test.dart test/ui_v2/act0_sharky_companion_states_consumer_v1_test.dart`

Final validation also passed:

- `flutter analyze`
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`
- targeted route capsule checks for `W1 Completion Copy Regression`,
  `Sharky Visual Growth / Evolution`, `Companion State Consumer Follow-up`,
  and `w1_completion_copy_regression`

## 11. Capsule Status

Capsules remain on the active route:

- Sharky Companion States - CLOSED
- Sharky Visual Growth / Evolution - ACTIVE
- Companion State Consumer Follow-up - deferred

The repair is recorded as a temporary regression repair before resuming the
active Visual Growth route.

## 12. Scope Safety

Not changed:

- Home companion-state migration
- new consumer
- phrase-library expansion
- W2-W6 copy
- W4->W5 transition copy
- Sharky visual growth
- assets
- animation
- route, persistence, telemetry, or Modern Table behavior
- broad localization
- W13+ behavior
- dependencies

## 13. Known Limitations

No screenshot lane was run for this repair because the existing deterministic
lanes do not naturally expose the W1 completion state. The repaired behavior
is covered by focused widget and phrase-contract tests.

The small `dart format` pass also normalized nearby formatting in the phrase
contract file; no behavior outside the W1 phrase branch changed.

## 14. Next Recommendation

`Sharky Visual Growth / Evolution v1`
