---
status: "Recommended Stage 1A batch verdict: `batch_closed_after_bounded_repairs"
status_source: "derived"
baseline: "cb1d2e0e3f3c"
generated_by: "docs_frontmatter_v1"
---

# Stage 1A W1-W3 Repair Closure v1

## 1. Verdict

Recommended Stage 1A batch verdict: `batch_closed_after_bounded_repairs`.

Stage 1A source-level admitted repairs are closed after two bounded repair waves. Human-QA-only judgment questions remain available for owner review, but no confirmed admitted source issue remains unfixed.

No Stage 1B work was started. No Claude re-audit was run.

## 2. Frozen authority

| Item | Value |
| --- | --- |
| Canonical base | `cb1d2e0e3f3c956b9e729a9307343a3cfc734b86` |
| Repair branch | `codex/stage-1a-w1-w3-complete-repair-program-v1` |
| Accepted verification branch | `codex/stage-1a-w1-w3-claude-findings-verification-v1` |
| Accepted verification HEAD | `949c1e7450bcd1bcaf3fcd09aac4bec32c56f7b9` |
| Verification artifact | `docs/_reviews/stage_1a_w1_w3_claude_findings_verification_v1.md` |
| Wave 1 commit | `b1bb29418b8adf208be0beb825530ab9e7d565b6` |
| Wave 2 commit | `ce5d52f50b046bd28fd9630a5f5824f053f5b618` |
| Targeted post-fix baseline | `5b537250877d102c62724145255e13196947fe50` |

## 3. Exact files changed

### Wave 1

- `content/worlds/world1/v1/sessions/w1.s01/session.md`
- `content/worlds/world1/v1/sessions/w1.s02/session.md`
- `content/worlds/world2/v1/sessions/w2.s01/session.md`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `test/tools/stage1a_wave1_signposting_terminology_contract_test.dart`

### Wave 2

- 27 W1 selected-family drill JSON files under `content/worlds/world1/v1/sessions/w1.s02` through `w1.s10`.
- `content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_raise_flop_bluff.json`
- `content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_raise_flop_denial.json`
- `content/worlds/world2/v1/sessions/w2.s05/drills/d.choose_raise_turn_pressure.json`
- `content/worlds/world2/v1/sessions/w2.s06/drills/d.choose_raise_river_bluff.json`
- `content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_call_btn_facing_open_transfer_v1.json`
- `content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_fold_bb_weak_facing_open_transfer_v1.json`
- `content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_raise_btn_clean_transfer_v1.json`
- `content/worlds/world3/v1/sessions/w3.s10/drills/index.md`
- `test/tools/stage1a_wave2_feedback_transfer_contract_test.dart`

### Closure artifact

- `docs/_reviews/stage_1a_w1_w3_repair_closure_v1.md`

### Final targeted post-fix correction

- `content/worlds/world1/v1/sessions/w1.s02/session.md`
- `content/worlds/world1/v1/sessions/w1.s04/drills/d.choose_button_open_repeat_stability_v1.json`
- `content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_cutoff_raise_clean_start_v1.json`
- `content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_small_blind_raise_oop_clean_start_v1.json`
- `content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_raise_flop_denial.json`
- `content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_raise_btn_clean_transfer_v1.json`
- `content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_call_btn_facing_open_transfer_v1.json`
- `test/tools/stage1a_wave1_signposting_terminology_contract_test.dart`
- `test/tools/stage1a_wave2_feedback_transfer_contract_test.dart`
- `docs/_reviews/stage_1a_w1_w3_repair_closure_v1.md`
- `docs/_reviews/stage_1a_w1_w3_targeted_postfix_packet_v1.md`

## 4. Finding-by-finding closure

| Finding | Closure status | Evidence |
| --- | --- | --- |
| F01 W3 ownership/coherence | closed | W3 world-card copy now names position-informed preflop open/call/fold instead of under-describing the delivered W3 job. |
| F02 W2 cross-role scope | closed | W2 world-card copy now preserves `Hand Discipline` while explicitly including compact table clues. |
| F03 W2 acceptable actions | closed | All 14 true W2 alternate-action drills now have authored `feedback_acceptable_v1`; 25 expected-only rows remain expected-only. |
| F04 W3 independent-decision reinforcement | closed | W3 gained exactly three standalone transfer decisions in `w3.s10` using existing W3 concepts only. |
| F06 W1 correct-feedback richness | closed | The selected W1 family is all 27 top-level action-choice drills with `feedback_correct_v1`; none still use bare `Correct.`. |
| F08 terminology | closed | Bounded first-use copy now clarifies price, dealer button, and compact seat abbreviations. |
| F12 W3 -> W4 novelty/overlap | closed | The W3 -> W4 completion bridge now distinguishes W3 preflop action from W4 bet purpose/price. |
| F14 opportunistic IP/OOP abbreviations | closed as opportunistic-only | OOP stayed on the same existing W2 first-use surface; no IP copy was added because IP was not active W1-W3 learner-facing text in the accepted verification. |

## 5. Excluded findings

| Finding | Status | Reason |
| --- | --- | --- |
| F05 W3 acceptable/suboptimal nuance | excluded | Human-QA-dependent and not admitted before a specific objectively learner-valid W3 alternate is proven. |
| F07 repair-proof asymmetry | excluded | Accepted verification classified it as `evidence_provenance_only_no_product_repair`; no concrete uncovered repair mapping was proven. |
| F11 W2 review density | excluded | Human-QA/pacing-dependent; no review-density expansion authorized. |
| F13 W1 binary framing | excluded | Rejected as appropriate for absolute-beginner W1. |

## 6. Final totals

### W2 acceptable feedback

| Metric | Final value |
| --- | ---: |
| W2 `acceptable_actions` rows | 39 |
| True alternate-action rows | 14 |
| True alternate-action rows with `feedback_acceptable_v1` | 14 |
| Expected-only rows | 25 |

The four repaired true alternate-action drills are:

- `choose_raise_flop_bluff`
- `choose_raise_flop_denial`
- `choose_raise_turn_pressure`
- `choose_raise_river_bluff`

### W1 selected feedback family

Selected family: all top-level W1 `action_choice` drills with `feedback_correct_v1`.

| Metric | Final value |
| --- | ---: |
| Selected family size | 27 |
| Bare `Correct.` remaining | 0 |

The family was selected because every verified W1 top-level bare-correct feedback instance belonged to the same decision family.

### W3 independent decisions

| Metric | Final value |
| --- | ---: |
| W3 standalone `action_choice` drills | 7 |
| New standalone transfer decisions | 3 |
| W3 acceptable/suboptimal tier rows | 0 |

New W3 transfer decision IDs:

- `choose_raise_btn_clean_transfer_v1`
- `choose_call_btn_facing_open_transfer_v1`
- `choose_fold_bb_weak_facing_open_transfer_v1`

## 7. Final framing excerpts

W2 world card:

- `Hand Discipline`
- `Choose which hands deserve chips, then use table clues.`

W3 world card:

- `Position Thinking`
- `Use position to choose the preflop open, call, or fold.`

W3 -> W4 bridge:

- `World 4 starts with a simple question: why did that bet happen, and what price did it create?`

## 8. Final terminology first-use excerpts

- W1 price: `Price means what you must pay to continue.`
- W1 dealer button: `The dealer button is the seat marked BTN.`
- W1 seat abbreviations:
  - `Seat labels stay short: UTG acts first preflop, while HJ and CO are middle-to-late seats.`
  - `BTN is the button, and SB/BB are the blinds.`
- W2 price: `Price means what calling costs before you continue.`
- W2 OOP: `OOP, or out of position, means acting before your opponent on later streets.`

## 9. Focused guard and validation results

Integrated closure validation command:

```bash
flutter test test/tools/stage1a_wave1_signposting_terminology_contract_test.dart test/tools/stage1a_wave2_feedback_transfer_contract_test.dart test/tools/world2_action_choice_policy_validator_v1_test.dart test/tools/drill_runtime_evaluator_v1_test.dart test/ui_v2/runner/session_drill_hand_chain_projection_contract_v1_test.dart
```

Result: `34` tests passed, `0` failed.

Analyze command:

```bash
flutter analyze lib/ui_v2/act0_shell/act0_shell_state_v1.dart lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart test/tools/stage1a_wave1_signposting_terminology_contract_test.dart test/tools/stage1a_wave2_feedback_transfer_contract_test.dart
```

Result: `No issues found`.

Additional validation:

- JSON parse / minimal schema check for changed Wave 2 drill files: `44` files validated.
- `git diff --check`: passed.
- `graphify hook-check`: passed.

## 10. Scope proof

- No content relocation occurred.
- No stable IDs were renamed.
- No route behavior or world ordering was changed.
- No evaluator/schema changes were made.
- No new architecture or dependencies were added.
- No W4+ authoring occurred beyond the accepted W3 -> W4 bridge/signposting copy.
- No generated output was added or tracked.
- F05, F07, F11, and F13 did not enter implementation scope.

## 11. Regression assessment

Regression risk is low and bounded to learner-facing copy and admitted W1-W3 drill content:

- Wave 1 changes are copy-only and protected by a focused signposting/terminology guard.
- Wave 2 changes preserve existing expected and acceptable action IDs.
- New W3 transfer drills use existing `action_choice` schema and existing W3 vocabulary.
- Existing W2 policy, evaluator, and W3/session projection focused tests remain green.

## 12. Remaining Human-QA-only questions

- Whether W2 breadth feels paced well after the copy now names compact table clues.
- Whether W3's three new independent transfer decisions feel like enough transfer proof after guided chains.
- Whether the revised W1/W2 feedback copy is sufficiently concise in-device.

These are quality-review questions, not source-level closure blockers.

## 13. Targeted Claude post-fix recommendation

Recommend one compact targeted Claude post-fix check, not a full Stage 1A re-audit.

Justification:

- revised W2/W3/W4 framing needs product-judgment review;
- revised W1/W2 feedback needs quality-judgment review;
- three W3 independent decisions materially affect the learner experience.

Suggested scope: only the final excerpts and changed W1/W2/W3 drills listed in this closure artifact.

Final correction note: the owner supplied that targeted post-fix review, with verdict `targeted_postfix_minor_correction_required`. This correction pass did not issue or run any Claude prompt.

## 14. Final targeted post-fix correction

Claude targeted post-fix verdict received from owner packet: `targeted_postfix_minor_correction_required`.

The final correction-only pass closed exactly four bounded categories:

1. W1 seat-label density: the compact seat definition was split into two beginner-readable lines while preserving all six abbreviations.
2. W1 premature first-in wording: three targeted W1 raise feedback surfaces now avoid `first-in` / `first in` final learner-facing copy.
3. W2 denial equity jargon: the denial acceptable feedback and rationale now avoid `equity` and use beginner-safe overcard language.
4. W3 transfer independence: the two non-fold W3 transfer drills now differ from the nearest guided chain steps by card/hand surface while preserving expected action and concept job.

Final W3 transfer surfaces:

- Drill A: `Hero is on the button with AJs and the pot is unopened. Which compact preflop action fits this transfer spot?` Expected action: `raise`.
- Drill B: `Cutoff opened first and hero is on the button with KQs. Which compact preflop action fits this transfer spot?` Expected action: `call`.
- Drill C remained unchanged: `Button opened first and hero is in the big blind with T6o. Which compact preflop action fits this transfer spot?` Expected action: `fold`.

Final poker-clarity micro-correction: Drill B was changed from KTs to KQs because KQs is already active W3 suited-broadway vocabulary, is stronger and less borderline than QJs, and does not duplicate an existing W3 button-facing-cutoff-open exact surface.

Final validation after this correction:

- JSON parse/minimal schema validation for `choose_call_btn_facing_open_transfer_v1`: passed.
- Wave 2 feedback/transfer guard: passed.
- W3 session-drill hand-chain projection guard: passed.
- `flutter analyze` on the affected focused guard: passed.
- `git diff --check`: passed.
- `graphify hook-check`: passed.

Updated Stage 1A verdict remains `batch_closed_after_bounded_repairs`.

No Stage 1B work was started. No Claude prompt was issued or run during this correction pass.

## 15. Batch verdict

`batch_closed_after_bounded_repairs`
