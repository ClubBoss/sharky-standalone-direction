---
status: "undeclared"
status_source: "absent"
baseline: "cb1d2e0e3f3c"
generated_by: "docs_frontmatter_v1"
---

# Stage 1A W1-W3 Targeted Post-Fix Quality Packet v1

## 0. Frozen state

| Item | Value |
| --- | --- |
| Branch | `codex/stage-1a-w1-w3-complete-repair-program-v1` |
| Canonical base | `cb1d2e0e3f3c956b9e729a9307343a3cfc734b86` |
| Wave 1 commit | `b1bb29418b8adf208be0beb825530ab9e7d565b6` |
| Wave 2 commit | `ce5d52f50b046bd28fd9630a5f5824f053f5b618` |
| Closure commit | `d4903e5560d205564dacbadbc26fe43f7beef41c` |
| Current HEAD before final targeted correction | `5b537250877d102c62724145255e13196947fe50` |
| Clean-worktree precheck | clean |
| Closure artifact | `docs/_reviews/stage_1a_w1_w3_repair_closure_v1.md` |

This packet is only for a compact targeted post-fix quality check. It is not a new audit, ownership review, readiness evaluation, Human QA pass, or Stage 1B input.

Claude may judge only clarity, brevity, beginner safety, feedback usefulness, acceptable-vs-best distinction, transfer quality, world-job consistency, and whether W4 novelty is preserved.

Claude must not reopen F05, F07, F11, or F13; request content relocation; redesign world architecture; infer runtime beyond supplied evidence; make readiness claims; simulate Human QA; or introduce new findings outside these changed surfaces.

## 1. W2/W3/W4 framing

### W2 world card

Active path: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`

Stable ID: `world_2`

Intended learner job: W2 teaches hand discipline while introducing compact visible table clues that can change whether a hand deserves chips.

| Field | Before | After |
| --- | --- | --- |
| title | `Hand Discipline` | `Hand Discipline` |
| subtitle / promise | `Learn which hands deserve chips and which can fold.` | `Choose which hands deserve chips, then use table clues.` |

### W3 world card

Active path: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`

Stable ID: `world_3`

Intended learner job: W3 teaches position-informed preflop decisions by combining seat, hand category, and raising-first versus facing-open action frame.

| Field | Before | After |
| --- | --- | --- |
| title | `Position Thinking` | `Position Thinking` |
| subtitle / promise | `See why seat order changes hand value and comfort.` | `Use position to choose the preflop open, call, or fold.` |

### W3 completion to W4 bridge

Active path: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`

Stable ID: `_worldCompletionMetaByNumberV1[3].previewLine`

Intended learner job: The bridge should separate W3's preflop action fit from W4's bet-purpose and price job.

| Field | Before | After |
| --- | --- | --- |
| completion preview | `World 4 starts with a simple question: why did that bet happen?` | `World 4 starts with a simple question: why did that bet happen, and what price did it create?` |

### Session-level framing changed to clarify W2/W3 scope

No W2 or W3 session-level scope framing was changed. W2/W3 scope clarification happened through world-card and completion-bridge copy. The only W2 session change in this packet is a bounded terminology first-use line listed in Section 2.

### W4 first-contact line for novelty judgment

Active path: `content/worlds/world4/v1/sessions/w4.s01/session.md`

Stable ID: `w4.s01`

Unchanged W4 first-contact line:

- Objective: `Teach the first stable bet-purpose cluster by matching a size preset to what it is trying to accomplish.`
- Scenario excerpt: `The learner succeeds by connecting the preset to the purpose instead of treating size as decoration.`
- Explanation excerpt: `World 4 begins by turning the proven sizing pilot into a mainline competency.`

Intended learner job: W4 remains novel because it starts with bet purpose and preset/price meaning, not preflop open/call/fold action selection.

## 2. Terminology changes

### Price first-use copy

Active path: `content/worlds/world1/v1/sessions/w1.s01/session.md`

Stable ID: `w1.s01`

| Before | After |
| --- | --- |
| No explicit one-line price definition in this session. | `Price means what you must pay to continue.` |

Active path: `content/worlds/world2/v1/sessions/w2.s01/session.md`

Stable ID: `w2.s01`

| Before | After |
| --- | --- |
| No explicit one-line price definition in this session. | `Price means what calling costs before you continue.` |

### Dealer button and seat abbreviations

Active path: `content/worlds/world1/v1/sessions/w1.s02/session.md`

Stable ID: `w1.s02`

| Term | Before | After |
| --- | --- | --- |
| dealer button / BTN | No explicit one-line dealer-button definition in this session. | `The dealer button is the seat marked BTN.` |
| UTG / HJ / CO / BTN / SB / BB | No compact seat-label definition in this session. | `Seat labels stay short: UTG acts first preflop, while HJ and CO are middle-to-late seats.` / `BTN is the button, and SB/BB are the blinds.` |

### OOP

Active path: `content/worlds/world2/v1/sessions/w2.s03/session.md`

Stable ID: `w2.s03`

| Before | After |
| --- | --- |
| `OOP, or out of position, means acting before your opponent on later streets.` | `OOP, or out of position, means acting before your opponent on later streets.` |

OOP was not changed. It is included only to show the opportunistic F14 surface remained unchanged because it was already defined on the same existing first-use surface.

### Terminology structural notes

- Definition repeated: price is defined once in W1 as general vocabulary preview and once in W2 as the action-facing variant because W2 actively uses price language.
- Copy density increase: W1.s01 +1 line, W1.s02 +2 lines, W2.s01 +1 line.
- IP introduced: no.
- New jargon introduced: no new poker term family was introduced; existing abbreviations were defined.

## 3. W1 correct-feedback family

Selected family: all top-level W1 `action_choice` drills with `feedback_correct_v1`.

Structural totals:

- Changed drills: 27.
- Remaining bare `Correct.` in selected family: 0.
- Lines with `why_v1`: 27.
- Duplicate or near-duplicate new `feedback_correct_v1` strings: 0 exact duplicates observed. Several strings intentionally share the same concise pattern because they belong to the same beginner decision family.

| # | Drill ID | Active path | Prompt | Expected | Old `feedback_correct_v1` | New `feedback_correct_v1` | `why_v1` |
| ---: | --- | --- | --- | --- | --- | --- | --- |
| 1 | `choose_big_blind_continue_defend_v1` | `content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_big_blind_continue_defend_v1.json` | `The button opened first and hero is in the big blind with QJs. Which simple action fits best?` | `call` | `Correct.` | `Correct. QJs is strong enough to continue from the big blind, and calling answers the button open cleanly.` | `A stronger broadway hand can continue from the big blind, but the clean response to late-position pressure is a call.` |
| 2 | `choose_button_open_clean_v1` | `content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_button_open_clean_v1.json` | `Hero is on the button with KTs and nobody has entered the pot. Which simple action fits best?` | `raise` | `Correct.` | `Correct. KTs on the button in an unopened pot is a clean late-position raise.` | `Late position plus a playable broadway hand gives a clean first-in open.` |
| 3 | `choose_small_blind_release_caution_v1` | `content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_small_blind_release_caution_v1.json` | `Hero is in the small blind with J7o and nobody has entered the pot. Which simple action fits best?` | `fold` | `Correct.` | `Correct. J7o is too weak from the small blind, so folding protects the out-of-position spot.` | `Out of position from the small blind, a weak offsuit hand should release instead of forcing a continue.` |
| 4 | `choose_call_when_pressure_reaches_you_v1` | `content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_call_when_pressure_reaches_you_v1.json` | `Cutoff opened first and hero is on the button with KQs. Which simple action fits best when the pressure reaches you?` | `call` | `Correct.` | `Correct. KQs can continue after the cutoff opens, but calling fits the facing-open frame.` | `Once an open reaches you, the hand can still continue, but the cleaner response is a call rather than treating it like a first-in raise.` |
| 5 | `choose_first_in_raise_after_folds_v1` | `content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_first_in_raise_after_folds_v1.json` | `Cutoff folded, button folded, and hero is in the small blind with AQs. Which simple action fits best now?` | `raise` | `Correct.` | `Correct. AQs is strong enough to raise once the earlier seats fold and the start is clean.` | `Once earlier players fold, a strong hand in a clean first-in spot should raise before the big blind acts.` |
| 6 | `choose_fold_when_multiway_pressure_stacks_v1` | `content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_fold_when_multiway_pressure_stacks_v1.json` | `Cutoff opened, button called, and hero is in the big blind with T7o. Which simple action fits best now?` | `fold` | `Correct.` | `Correct. T7o should fold when an open and call already stack pressure in front.` | `When pressure stacks from multiple players, a weak offsuit hand should release instead of guessing.` |
| 7 | `choose_big_blind_call_repeat_stability_v1` | `content/worlds/world1/v1/sessions/w1.s04/drills/d.choose_big_blind_call_repeat_stability_v1.json` | `Cutoff opened and hero is in the big blind with KTo. Which simple action fits best if the defend habit stays stable?` | `call` | `Correct.` | `Correct. KTo can defend from the big blind by calling instead of treating the spot like a raise.` | `The big blind can still continue by calling with a playable broadway hand instead of treating the spot like a first-in raise.` |
| 8 | `choose_button_open_repeat_stability_v1` | `content/worlds/world1/v1/sessions/w1.s04/drills/d.choose_button_open_repeat_stability_v1.json` | `Hero is on the button with QJs and nobody has entered the pot. Which simple action fits best if position discipline stays stable?` | `raise` | `Correct.` | `Correct. QJs on the button keeps the clean raise habit when no one has entered yet.` | `Late position with a playable suited broadway hand should keep the same clean raise habit when no one has entered yet.` |
| 9 | `choose_small_blind_fold_repeat_stability_v1` | `content/worlds/world1/v1/sessions/w1.s04/drills/d.choose_small_blind_fold_repeat_stability_v1.json` | `Hero is in the small blind with T6o and nobody has entered the pot. Which simple action fits best if the release habit stays stable?` | `fold` | `Correct.` | `Correct. T6o is too weak from the small blind, so the stable answer is still fold.` | `From the small blind, a weak offsuit hand should still release instead of forcing a continue.` |
| 10 | `choose_button_call_playable_pressure_v1` | `content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_button_call_playable_pressure_v1.json` | `Hijack opened and hero is on the button with QTs. Which simple action fits best once pressure is already on?` | `call` | `Correct.` | `Correct. QTs can continue on the button, and calling respects that pressure is already on.` | `Once an open reaches the button, a playable suited broadway hand can continue cleanly by calling.` |
| 11 | `choose_cutoff_raise_clean_start_v1` | `content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_cutoff_raise_clean_start_v1.json` | `Hero is in the cutoff with ATs and everyone folded to them. Which simple action fits best if the start is still clean?` | `raise` | `Correct.` | `Correct. ATs in the cutoff is a clean raise because everyone has folded so far.` | `A playable suited ace should still raise when everyone has folded and later pressure has not appeared.` |
| 12 | `choose_small_blind_fold_weak_start_v1` | `content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_small_blind_fold_weak_start_v1.json` | `Hero is in the small blind with Q6o and nobody has entered the pot. Which simple action best protects clean start quality?` | `fold` | `Correct.` | `Correct. Q6o is not strong enough to start from the small blind, so folding keeps discipline.` | `A weak offsuit hand from the small blind is not a clean enough start to continue.` |
| 13 | `choose_call_facing_open_checkpoint_v1` | `content/worlds/world1/v1/sessions/w1.s06/drills/d.choose_call_facing_open_checkpoint_v1.json` | `Cutoff opened and hero is on the button with KJs. Which simple action fits best at the checkpoint when pressure reaches you?` | `call` | `Correct.` | `Correct. KJs stays playable after the cutoff opens, and calling is the clean checkpoint response.` | `Once the pot is opened in front of you, a playable hand like KJs continues most cleanly by calling rather than acting first-in.` |
| 14 | `choose_fold_oop_pressure_checkpoint_v1` | `content/worlds/world1/v1/sessions/w1.s06/drills/d.choose_fold_oop_pressure_checkpoint_v1.json` | `Button opened and hero is in the big blind with J4o. Which simple action fits best at the checkpoint under out-of-position pressure?` | `fold` | `Correct.` | `Correct. J4o is too weak out of position against a button open, so folding is disciplined.` | `Out of position with a weak offsuit hand, the disciplined checkpoint answer is still to fold.` |
| 15 | `choose_raise_clean_first_in_checkpoint_v1` | `content/worlds/world1/v1/sessions/w1.s06/drills/d.choose_raise_clean_first_in_checkpoint_v1.json` | `Hero is in the cutoff with AJs and everyone folded so far. Which simple action fits best at the checkpoint?` | `raise` | `Correct.` | `Correct. AJs in an unopened cutoff spot is strong enough to raise at the checkpoint.` | `A strong suited broadway hand in a clean unopened spot should still raise at the checkpoint.` |
| 16 | `choose_button_fold_in_position_discipline_v1` | `content/worlds/world1/v1/sessions/w1.s07/drills/d.choose_button_fold_in_position_discipline_v1.json` | `Cutoff opened and hero is on the button with 94o. Which simple action fits best if position does not rescue a weak hand?` | `fold` | `Correct.` | `Correct. 94o is too weak to continue, even when the button has position.` | `Even in position, a weak offsuit hand should still fold once pressure reaches you.` |
| 17 | `choose_button_raise_in_position_focus_v1` | `content/worlds/world1/v1/sessions/w1.s07/drills/d.choose_button_raise_in_position_focus_v1.json` | `Hero is on the button with KJo and everyone folded so far. Which simple action fits best when position is clearly in your favor?` | `raise` | `Correct.` | `Correct. KJo on the button in an unopened pot is a clean in-position raise.` | `On the button in a clean first-in spot, a playable broadway hand should still raise.` |
| 18 | `choose_cutoff_call_in_position_pressure_v1` | `content/worlds/world1/v1/sessions/w1.s07/drills/d.choose_cutoff_call_in_position_pressure_v1.json` | `Hijack opened and hero is in the cutoff with QJs. Which simple action fits best when position still lets you continue cleanly?` | `call` | `Correct.` | `Correct. QJs can continue with position after the hijack opens, so calling fits.` | `With position and a playable suited broadway hand, the clean response to existing pressure is a call.` |
| 19 | `choose_big_blind_call_oop_defend_focus_v1` | `content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_big_blind_call_oop_defend_focus_v1.json` | `Button opened and hero is in the big blind with QTo. Which simple action fits best for a clean out-of-position defend?` | `call` | `Correct.` | `Correct. QTo can defend from the big blind by calling, even without position.` | `From the big blind, a playable broadway hand can still continue by calling even without position.` |
| 20 | `choose_small_blind_fold_oop_focus_v1` | `content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_small_blind_fold_oop_focus_v1.json` | `Hero is in the small blind with J6o and nobody has entered the pot. Which simple action fits best when acting out of position?` | `fold` | `Correct.` | `Correct. J6o is too weak from the small blind, so folding avoids forcing an out-of-position hand.` | `Out of position from the small blind, a weak offsuit hand should still release.` |
| 21 | `choose_small_blind_raise_oop_clean_start_v1` | `content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_small_blind_raise_oop_clean_start_v1.json` | `Hero is in the small blind with AQs and everyone folded so far. Which simple action fits best if the start is strong enough despite being out of position?` | `raise` | `Correct.` | `Correct. AQs is strong enough to raise when no one has entered yet, even from the small blind.` | `A strong hand can still raise when no one has entered yet, even from the small blind.` |
| 22 | `choose_call_when_open_reaches_you_focus_v1` | `content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_call_when_open_reaches_you_focus_v1.json` | `Cutoff opened and hero is on the button with KTs. Which simple action fits best once the open reaches you?` | `call` | `Correct.` | `Correct. KTs can continue after the cutoff opens, and calling keeps the response simple.` | `When the pot is already opened, a playable hand like KTs continues most cleanly with a call.` |
| 23 | `choose_fold_when_pressure_and_position_fail_focus_v1` | `content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_fold_when_pressure_and_position_fail_focus_v1.json` | `Hijack opened and hero is in the big blind with T5o. Which simple action fits best when pressure and position both work against you?` | `fold` | `Correct.` | `Correct. T5o is weak and out of position against pressure, so folding is the disciplined response.` | `Under pressure and out of position with a weak offsuit hand, the disciplined response is still to fold.` |
| 24 | `choose_raise_when_action_folds_to_you_focus_v1` | `content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_raise_when_action_folds_to_you_focus_v1.json` | `Cutoff folded, button folded, and hero is in the small blind with ATs. Which simple action fits best when the action folds to you?` | `raise` | `Correct.` | `Correct. ATs becomes a clean raise once the action folds to the small blind.` | `Once everyone folds, a clean first-in spot with a playable hand should raise.` |
| 25 | `choose_call_focus` | `content/worlds/world1/v1/sessions/w1.s10/drills/d.choose_call_focus.json` | `Cutoff opened and hero is on the button with KQs. Which simple action fits best for the final World 1 checkpoint?` | `call` | `Correct.` | `Correct. KQs can continue in position after the cutoff opens, so the final checkpoint call fits.` | `Facing an open with a playable hand in position, the stable World 1 checkpoint response is to continue by calling.` |
| 26 | `choose_fold_focus` | `content/worlds/world1/v1/sessions/w1.s10/drills/d.choose_fold_focus.json` | `Hijack opened and hero is in the big blind with T6o. Which simple action fits best for the final World 1 checkpoint?` | `fold` | `Correct.` | `Correct. T6o is weak and out of position against the hijack open, so folding closes the spot.` | `Out of position against pressure with a weak offsuit hand, the disciplined World 1 checkpoint answer is to fold.` |
| 27 | `choose_raise_focus` | `content/worlds/world1/v1/sessions/w1.s10/drills/d.choose_raise_focus.json` | `Hijack folded, cutoff folded, and hero is on the button with AQs. Which simple action fits best for the final World 1 checkpoint?` | `raise` | `Correct.` | `Correct. AQs on the button with no prior open is a strong final-checkpoint raise.` | `With position, no prior open, and a strong starting hand, the final World 1 checkpoint answer is still to raise.` |

## 4. W2 acceptable feedback

Final structural totals:

- Rows with `acceptable_actions`: 39.
- Real alternate-action drills: 14.
- Real alternate-action drills with explicit acceptable feedback: 14.
- Expected-only tolerance rows: 25.

| Drill ID | Active path | Prompt | Expected action | Alternate acceptable action | `feedback_correct_v1` | New `feedback_acceptable_v1` | `feedback_incorrect_v1` | `why_v1` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `choose_raise_flop_bluff` | `content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_raise_flop_bluff.json` | `Approved flop bluff c-bet spot: choose action.` | `raise` | `call` | `Correct. Bluff c-bet is enabled in this specific spot.` | `Acceptable. Calling keeps the hand alive, but this flop is a better bluff spot because raising applies fold pressure now.` | `Incorrect. This flop is one of the better bluffing spots, so betting now creates fold pressure that checking gives away.` | `This drill flags a permitted bluff continuation branch.` |
| `choose_raise_flop_denial` | `content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_raise_flop_denial.json` | `Flop denial spot versus overcards: choose action.` | `raise` | `call` | `Correct. Denial line is bet in this spot.` | `Acceptable. Calling keeps the pot smaller, but raising is preferred because it keeps weaker overcards from catching up for free.` | `Incorrect. This denial spot wants a bet now so weaker overcards do not get a free turn.` | `Denial spots use the bet branch to keep weaker overcards from catching up for free.` |
| `choose_raise_turn_pressure` | `content/worlds/world2/v1/sessions/w2.s05/drills/d.choose_raise_turn_pressure.json` | `Approved pressure continuation spot on turn: choose action.` | `raise` | `call` | `Correct. Continue betting in this pressure node.` | `Acceptable. Calling controls the pot, but the preferred turn action keeps pressure on weaker continues.` | `Incorrect. This turn still lets you pressure weaker continues, so a second barrel is stronger than backing off.` | `This turn node keeps the continuation-bet branch active.` |
| `choose_raise_river_bluff` | `content/worlds/world2/v1/sessions/w2.s06/drills/d.choose_raise_river_bluff.json` | `Approved river bluff branch with blocker cue: choose action.` | `raise` | `call` | `Correct. Bluff line is active in this river spot.` | `Acceptable. Calling keeps the pot smaller, but the blocker cue makes raising better because it creates fold pressure.` | `Incorrect. The blocker cue matters here, so betting the river applies fold pressure better than checking.` | `Raise as a river bluff with this blocker profile. Calling keeps the pot small and gives up fold pressure.` |

## 5. W3 independent transfer

Structural confirmation:

- Previous standalone independent W3 decisions: 4.
- Added: 3.
- Final standalone independent W3 decisions: 7.
- Guided-chain choices remain: 42.
- Acceptable/suboptimal tier added: no.

### `choose_raise_btn_clean_transfer_v1`

Active path: `content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_raise_btn_clean_transfer_v1.json`

Session placement: `w3.s10`, listed after `chain_preflop_final_checkpoint_v1` in `content/worlds/world3/v1/sessions/w3.s10/drills/index.md`.

| Field | Evidence |
| --- | --- |
| Prompt | `Hero is on the button with AJs and the pot is unopened. Which compact preflop action fits this transfer spot?` |
| Cards | `AJs` |
| Seat / position | button / in position |
| Prior action | pot unopened |
| Available options | `fold`, `call`, `raise` |
| Expected action | `raise` |
| Correct feedback | `Correct. AJs plus button position in an unopened pot makes raising the clean preflop action.` |
| Incorrect feedback | `Incorrect. AJs on the button with no open in front should not drift into call or fold; the clean position-informed action is raise.` |
| `why_v1` | `The pot is unopened, the suited broadway hand is strong, and the button has position, so this is the clean open-raise frame.` |
| Concepts integrated | hand category, button position, unopened-pot frame, open/raise action |
| Nearest existing drill and difference | Nearest existing surface is `chain_preflop_final_checkpoint_v1` step 1 with KQs/button/unopened/raise; this new drill keeps the same expected action but changes the hand surface to AJs and makes it standalone independent transfer rather than guided chain step. |

### `choose_call_btn_facing_open_transfer_v1`

Active path: `content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_call_btn_facing_open_transfer_v1.json`

Session placement: `w3.s10`, listed after `chain_preflop_final_checkpoint_v1` in `content/worlds/world3/v1/sessions/w3.s10/drills/index.md`.

| Field | Evidence |
| --- | --- |
| Prompt | `Cutoff opened first and hero is on the button with KQs. Which compact preflop action fits this transfer spot?` |
| Cards | `KQs` |
| Seat / position | button / in position |
| Prior action | cutoff opened first |
| Available options | `fold`, `call`, `raise` |
| Expected action | `call` |
| Correct feedback | `Correct. KQs can continue in position after the cutoff opens, and calling respects the facing-open frame.` |
| Incorrect feedback | `Incorrect. Once the cutoff opens first, KQs on the button is a strong in-position continue, but the compact action is call instead of raising first.` |
| `why_v1` | `The suited broadway hand is strong and hero has position, but the open in front changes the action from raising first to calling.` |
| Concepts integrated | hand category, position, facing-open frame, call action |
| Nearest existing drill and difference | Nearest existing surface is `chain_preflop_final_checkpoint_v1` step 2 with QJs/button/facing cutoff open/call; this new drill keeps the same expected action but changes the hand surface to KQs and makes the transfer independent instead of guided. |

### `choose_fold_bb_weak_facing_open_transfer_v1`

Active path: `content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_fold_bb_weak_facing_open_transfer_v1.json`

Session placement: `w3.s10`, listed after `chain_preflop_final_checkpoint_v1` in `content/worlds/world3/v1/sessions/w3.s10/drills/index.md`.

| Field | Evidence |
| --- | --- |
| Prompt | `Button opened first and hero is in the big blind with T6o. Which compact preflop action fits this transfer spot?` |
| Cards | `T6o` |
| Seat / position | big blind / out of position |
| Prior action | button opened first |
| Available options | `fold`, `call`, `raise` |
| Expected action | `fold` |
| Correct feedback | `Correct. Weak offsuit hand plus out-of-position pressure makes folding the disciplined preflop action.` |
| Incorrect feedback | `Incorrect. T6o in the big blind is too weak to continue cleanly after the button opens, so the compact action is fold.` |
| `why_v1` | `The big blind is out of position and T6o is too weak to continue cleanly against a button open.` |
| Concepts integrated | hand category, big-blind position, facing-open pressure, fold action |
| Nearest existing drill and difference | Nearest existing standalone surface is `choose_fold_final_preflop_checkpoint_v1`, which tests unopened cutoff J8o/fold; this new drill changes the surface to facing a button open from the big blind with T6o. |

## 6. Guard and scope proof

Final targeted correction evidence:

- Claude targeted post-fix verdict supplied for this pass: `targeted_postfix_minor_correction_required`.
- W1 seat-label copy is split into two lines while preserving `UTG`, `HJ`, `CO`, `BTN`, `SB`, and `BB`.
- The three targeted W1 feedback rows above avoid final learner-facing `first-in` / `first in` wording.
- The W2 denial acceptable feedback and `why_v1` avoid advanced `equity` wording.
- W3 Drill A now uses AJs, not the nearest chain step's KQs, while retaining expected `raise`.
- W3 Drill B now uses KQs, not the nearest chain step's QJs, while retaining expected `call`.
- Final poker-clarity micro-correction changed Drill B from KTs to KQs; bounded W3 inspection found no existing exact KQs/button/facing-cutoff-open surface.

Focused guard evidence:

- Wave 1 focused guard: `test/tools/stage1a_wave1_signposting_terminology_contract_test.dart`
- Wave 2 focused guard: `test/tools/stage1a_wave2_feedback_transfer_contract_test.dart`
- Final Stage 1A Wave 2 focused guard result: 6 tests passed, 0 failed.
- W3/session-drill projection result: 3 tests passed, 0 failed.
- Analyze result after final poker-clarity micro-correction: `No issues found`.
- JSON validation result after final poker-clarity micro-correction: `choose_call_btn_facing_open_transfer_v1` validated.
- `git diff --check`: passed.
- `graphify hook-check`: passed.

Scope proof:

- No schema/evaluator changes.
- No route behavior changes.
- No world ordering changes.
- No content relocation.
- No production Dart route/evaluator/schema changes in this final correction pass.
- Focused guard tests changed only to lock the accepted correction surfaces.
- Content changes were limited to the accepted W1/W2/W3 targeted correction files listed in this packet.
- Excluded findings remained excluded: F05, F07, F11, F13.
- No Claude prompt was run.
- No push was performed.
