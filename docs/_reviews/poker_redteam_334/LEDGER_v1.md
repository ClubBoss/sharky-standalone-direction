# #334 poker-truth closure ledger v1

Status date: 2026-10-30. Base: #332 `c1f69e1d36897f4a4d389e2b22dee511a2687a7d`
(tree `4f8116115ba2f5f990525ea8e612c617b29938a6`). English V1 only.

- S1 solver fix: Draft PR #335, branch `claude/poker-solver-p1-ranking-20261030`,
  commit `e1224511` (tree `c144b185`).
- S2 guard + S3 packet: stacked Draft PR on `claude/poker-truth-guard-334-20261030`.
- Content source `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` and runner
  `act0_lesson_runner_shell_v1.dart` are frozen by the paused Codex #333
  worktree, so every content fix here is an apply-ready patch, not a commit.

Statuses: `FIXED_AND_TESTED`, `READY_FOR_SERIAL_INTEGRATION`,
`NEEDS_OWNER_POLICY`, `UNVERIFIED`.

## Summary

| ID | Finding | Task IDs | Status | Fix |
| --- | --- | --- | --- | --- |
| S1 | `poker_solver 1.0.0` ranks straight/flush above full house/quads | runtime tap insight, W2 validator, `HandEvaluator`, `determineWinners` | FIXED_AND_TESTED | PR #335 |
| S2 | No live-catalog poker-truth guard | 367 live tasks | FIXED_AND_TESTED | `test/poker/act0_live_poker_truth_guard_v1_test.dart` |
| L1 | W6 full house described as trips | `w6_board_pair_strength_compare` | READY_FOR_SERIAL_INTEGRATION | patch A |
| L2 | "9-8 flopped two pair" on 8-7-6 | `w6_value_wet_board` | READY_FOR_SERIAL_INTEGRATION | patch A |
| L3 | "A-Q has two overcards" on K-7-2 | `w6_bluff_candidate`, `range_checkpoint_pressure` | READY_FOR_SERIAL_INTEGRATION | patch A |
| L4 | "With 5-6-7-8 on board" (board is 8-7-2) | `outs_improvement_w5_straight_out` | READY_FOR_SERIAL_INTEGRATION | patch A |
| L5 | Illegal "Flop: BB calls 3 BB"; contradicts `w4_bluff_pressure` | `w4_bad_bluff` | READY_FOR_SERIAL_INTEGRATION | patch A |
| L6 | Pot-odds wording leaves out the villain's bet | `w4_bad_price_fold`, `w4_checkpoint_price`, `w4_big_price_marginal_fold` | READY_FOR_SERIAL_INTEGRATION | patch A |
| L7 | "12 BB = yellow zone" (M ≤ 8); BTN "To call 0 BB" preflop | `w9_m_ratio_table_window_transfer` | READY_FOR_SERIAL_INTEGRATION | patch A |
| L8 | `blinds_theory` keys BTN for "Which blind posts 1 BB?" (latent) | `blinds_theory` | READY_FOR_SERIAL_INTEGRATION | patch A |
| L9 | Factually wrong options graded `suboptimal` | 14 tasks below | READY_FOR_SERIAL_INTEGRATION | patch A |
| L10 | Winner's cards lit before a winner question is answered | 5 tasks below | READY_FOR_SERIAL_INTEGRATION | patch A |
| L11 | Displayed `Pot` excludes the outstanding bet | 9 tasks below | READY_FOR_SERIAL_INTEGRATION (reconcile with #333 pot semantics first) | patch B |
| L12 | Decision-time center label states the answer | 9 tasks (+1 not machine-detected) | READY_FOR_SERIAL_INTEGRATION | patch A |
| P1 | ATo UTG (6-max) Fold keyed, Raise graded `wrong` | `same_hand_different_seat_same_hand_early_fold`, `position_apply_early_fold` | NEEDS_OWNER_POLICY | — |
| P2 | Top pair weak kicker vs 6 BB into 9 BB: Call graded `wrong` with no opponent assumption | `w4_big_price_marginal_fold` | NEEDS_OWNER_POLICY | — |
| P3 | Teaching preambles that show the winner before a "who wins" drill | L10 tasks | NEEDS_OWNER_POLICY | — |
| P4 | L9 regrades a first-exposure W1 task through a shared runner | `what_poker_is_showdown_win`, `your_first_hand_showdown` | NEEDS_OWNER_POLICY (acknowledge) | patch A |
| R1 | Runner tap path throws on duplicate cards | `showdown_board_plays_drill`, `showdown_tie_drill` (not reachable today) | READY_FOR_SERIAL_INTEGRATION | runner snippet below |
| N1 | Native visual proof of any of the above | — | UNVERIFIED | — |

Applying patch A then patch B to `c1f69e1d` content in a scratch tree makes
every guard rule clean with an empty ledger (90/90 in `test/poker`, the W11
truth test and the Tier A terminology/feedback guards). The 34 existing tests
that name touched tasks show no new failures: the 14 that fail with the patches
also fail on unpatched base content.

## Poker proof per finding

**L1** Board J♥ 8♣ 8♦ 2♠ 2♣. K♣8♠ makes 8-8-8-2-2, a full house. A♠J♦ makes
J-J-8-8-A, two pair. The key (Villain) is right. All three explanations and the
"Trips" focus label name the wrong class. Option `hero_aj` (the losing hand of a
fixed showdown) is graded `suboptimal` (see L9).

**L2** 9-8 on 8-7-6: ranks 9, 8, 8, 7, 6 make one pair (eights, top pair). Four
to a straight (6-7-8-9) gives an open-ender: 5 or T. Two pair needs a 9 on the
board. The key (Value) stands.

**L3** A-Q on K-7-2: only the ace is above the king. K-Q on 8-7-6
(`w6_wrong_board`) correctly has two overcards.

**L4** Hole 6♠5♦, board 8♣7♥2♠. The four in a row is 5-6-7-8 with 5-6 in hand.
The key (9) stands, and 4 is also an out.

**L5** On the flop BB acts first and Hero (BTN) has not bet, so nobody can call.
Same Hero cards, board and preflop line as `w4_bluff_pressure`, which keys a
one-third bet, so the verdict needs a stated differentiator. Patch: trail
"BB checks", caption names a sticky opponent ("This BB calls almost every flop
bet"). The key (Check) and the option set are unchanged.

**L6** Pot 8, bet 7: risk 7 to win 15, needs 7 / 22 = 31.8%. Pot 9, bet 6:
risk 6 to win 15, needs 6 / 21 = 28.6%. The guard now verifies any
"risk X BB to win Y BB … needs about N%" sentence.

**L7** M = stack / (SB + BB + antes) ≤ 12 / 1.5 = 8: orange in Harrington's
scheme, red in the three-zone scheme. Patch uses 18 BB (M ≤ 12, yellow) so the
keyed "plan an action window" stays right. Preflop only BB can face 0 to call.
BTN "To call 1 BB".

**L8** BB posts 1 BB by definition. Patch gives `_blindsOrderRunner` its own
SB / BB / BTN options with BB keyed. Theory options do not render today
(harness-proven), so this is latent.

**L9** One factual answer, every other option `wrong` (pre-accepted owner
policy). Tasks: `showdown_best_hand_drill`, `showdown_review`,
`what_poker_is_showdown_win`, `your_first_hand_showdown` (shared runner),
`w6_ak_combos`, `range_checkpoint_combos`, `w6_pair_combos`,
`w6_combo_weight_compare`, `w6_suited_offsuit_weight_compare`,
`w6_pair_vs_suited_weight_compare`, `w6_checkpoint_table_combo_weight`,
`w6_kicker_showdown_compare`, `w6_board_pair_strength_compare`,
`w6_checkpoint_table_best_five`. Combo facts: unpaired family 16, suited 4,
offsuit 12, pair 6. All seven combo keys are right; only the tiers change.
Feedback titles are unchanged.

**L10** Decision-time `highlightedCardIds` light the winner's cards and none of
the loser's: `hand_rankings_full_house_vs_flush_drill`,
`hand_rankings_quads_vs_full_house_drill`, `hand_rankings_royal_vs_flush_drill`,
`w6_kicker_showdown_compare`, and the shared board in
`w6_checkpoint_table_best_five` (split). Patch empties those decision-table
highlights. Teaching-step focus cards are untouched (see P3).

**L11** Copy proves the displayed pot is the pot before the bet ("bets 12 BB"
into "pot is 12 BB"; "the 8 BB pot plus the 7 BB bet"). Policy: displayed pot
includes the outstanding bet. Patch B: `w11_trigger_small_price_continue`
8→10, `w11_trigger_bad_price_fold` 12→24, `w11_checkpoint_mixed_table_line`
8→13, `w12_checkpoint_full_loop_line` 8→10, `w12_revenge_raise_trap` 8→10,
`w12_pretty_hand_bad_price_fold` 20→38, `w4_bad_price_fold` and
`w4_checkpoint_price` 8→15, `w4_big_price_marginal_fold` 9→15, with W4 captions
and the W11 truth-test expectations updated. Prices are unchanged (12 / 36 =
33%). 14 other postflop facing-bet tables cannot be classified from their copy
and are excluded, not certified. #333 is reworking chip, to-call and pot
semantics (D2/D3), so reconcile before applying B.

**L12** Center labels that state the keyed answer: `cards_ranks_suits_board_count`
("Five board cards"), `hand_rankings_best_five_drill`, `showdown_kicker_drill`
("… by kicker"), `board_texture_basics_w5_wet_board` ("Wet board"),
`connected_boards_w5_disconnected_board` ("Disconnected"),
`turn_river_changes_w5_river_misses` ("Draw missed"), and the three
"Hero X beats CO Y" labels. A real-runner probe shows "Draw missed",
"Disconnected" and `what_poker_is_side_pot_intro`'s "Hero cannot win side pot"
rendered at decision time. The others are hidden by the runner's clue gate today.
The side-pot label is a paraphrase the guard does not detect, so patch A fixes it
by hand.

## Owner decisions still open

- **P1** Most 100 BB 6-max opening charts open ATo UTG at least part of the
  time. Options: grade Raise `suboptimal`, or swap the hand to A9o (already
  used in `position_checkpoint_position_checkpoint_early_fold`).
- **P2** 6 BB into 9 BB needs 28.6%. Top pair weak kicker can have that against
  a wide range. Options: add an opponent assumption to the caption (as W11/W12
  do), or grade Call `suboptimal`.
- **P3** The L10 drills open with teaching steps whose focus cards show the
  winning five. If that counts as assisted, the drill should not count as
  independent evidence.
- **P4** Fixing L9 at its source regrades `what_poker_is_showdown_win` (W1
  first exposure) and `your_first_hand_showdown`, which share
  `_showdownBestHandRunner`. Acknowledge, or split the runner.

## Runner integration snippet (R1, Codex-owned file)

In `_computeShowdownInsight` (`act0_lesson_runner_shell_v1.dart`), wrap the
`Hand.solveHand` calls so a duplicate physical card returns no insight instead
of throwing inside the tap handler:

```dart
    final hands = <int, Hand>{};
    try {
      for (var i = 0; i < participants.length; i++) {
        hands[i] = Hand.solveHand(<String>[...board, ...participants[i].cards]);
      }
    } catch (_) {
      return null; // duplicate or unreadable card: no showdown insight
    }
```

Observation for the same owner (not verified natively): the tap insight lights
board cards but not the hole-card widgets.

## Guard coverage at this commit (current content)

| Rule | Checked | Excluded | Violations (all ledgered) |
| --- | ---: | ---: | ---: |
| showdown_winner_key | 6 | 25 | 0 |
| hero_hand_key | 3 | 1 | 0 |
| hand_claim | 15 | 0 | 1 |
| stated_hand_claim | 21 | 0 | 3 |
| board_claim | 2 | 0 | 1 |
| action_legality | 161 | 0 | 2 |
| pot_odds_wording | 4 | 0 | 3 |
| effective_stack_key | 2 | 0 | 0 |
| combo_count_key | 7 | 0 | 0 |
| m_ratio_zone | 1 | 0 | 1 |
| seat_rule_key | 12 | 0 | 1 |
| deterministic_tier | 32 | 0 | 14 |
| pre_answer_reveal | 6 | 3 | 5 |
| answer_in_center_label | 275 | 0 | 9 |
| pot_label_convention | 9 | 14 | 9 |

The universe is 367 tasks. Only the rows above are proven. Tasks a rule does not
reach are neither checked nor certified: for example, showdowns without a
face-up opponent, strategy questions, and pots whose meaning the copy does not
fix. The ledger test fails on any new violation and on any listed violation that
stops reproducing. Each rule with open entries is reported as skipped
`KNOWN_MATERIAL_FAIL`.

## Applying the packet (after #333 is frozen and the owner re-admits)

1. On the integration branch: `git apply docs/_reviews/poker_redteam_334/patch_a_content_v1.diff`
   (sha256 `044ec185…ac548`). Regenerate with `make_patch_a_v1.py` if #333
   moved lines.
2. Optional, after reconciling #333 pot semantics:
   `git apply docs/_reviews/poker_redteam_334/patch_b_pot_labels_v1.diff`
   (sha256 `19975c43…faf86`).
3. Delete the fixed entries from `_knownMaterialFails` in
   `test/poker/act0_live_poker_truth_guard_v1_test.dart`. The ledger test
   enforces this.
4. Run `flutter test test/poker test/ui_v2/act0_w11_poker_source_truth_v1_test.dart`
   and the Tier A lane.
