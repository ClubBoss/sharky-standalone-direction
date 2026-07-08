# W7-W9 Content Audit Verification v1

Date: 2026-07-08

Branch: `codex/w7-w9-content-audit-verification-v1`

Integrated main base: `299ea751800d9f54d3835e2a73168b677167d076`

Input artifacts:

- `docs/_reviews/w7_w9_deep_content_audit_evidence_packet_v1.md`
- `docs/_reviews/w7_w9_adversarial_content_learning_audit_v1.md`

Terminal verdict: `w7_w9_audit_findings_verified_with_one_bounded_repair_wave_recommended`

## Scope

This is verification-only. No content repair, route reopening, ownership
re-audit, payoff architecture re-audit, telemetry architecture re-audit, or
W7-W9 admission re-audit was performed.

Primary source owner:

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`

Directly needed support owners:

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart`
- `lib/ui_v2/act0_shell/act0_w8_stack_depth_hidden_runtime_session_owner_v1.dart`
- `lib/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart`

## Disposition Ledger

| Finding | Disposition | Summary |
|---|---|---|
| W7W9-DCA-001 | `partially_confirmed` | The structural answer leak is real across all three bridge checkpoints, but one subclaim is not exact: W7's second wrong option is not a single-concept subset. |
| W7W9-DCA-002 | `confirmed` | W9 visible route does not teach or assess ladder pressure, while the W9 payoff claims it. |
| W7W9-DCA-003 | `confirmed` | The absolute/extreme-distractor family is real and broad, but "dozens" should be replaced by the exact bounded count below. |
| W7W9-DCA-004 | `confirmed` | W7's paired-board visible-card case is taught but not independently assessed in the same visible-card concept family. |
| W7W9-DCA-005 | `confirmed` | `blocker` appears before a required plain-language explanation on the canonical Act0 route. |

## W7W9-DCA-001 - Bridge Checkpoint Template

Exact rendered source order, resolved from runners:

| Task ID | Prompt | Option order | Correct index |
|---|---|---|---:|
| `range_checkpoint_review` | `What carries this read into World 8?` | `Range plus stack depth`; `Range only`; `Guess the line` | 0 |
| `w7_stack_checkpoint` | `What does stack-depth thinking add to range thinking?` | `Range plus stack risk`; `Range only`; `Chip count only` | 0 |
| `w9_checkpoint_review` | `What does tournament-pressure thinking add before player adjustment?` | `Map pressure first, then adjust by player`; `Adjust only by player type`; `Use only hole cards and ignore pressure` | 0 |

No render-time randomization was found in the relevant runner-shell path. The
option widget iterates over `options.indexed`, selection uses option `id`, and
the search found no shuffle/randomization path for these options.

Verification:

- exact prompts: verified;
- exact option text/order: verified;
- correct index: verified as 0 for all three;
- both distractors are single-concept subsets: true for W8, mostly true for W9,
  false for W7 because `Guess the line` is a non-concept guess option;
- same structural heuristic: confirmed as "choose the combined/layered answer
  over a narrow or silly answer";
- poker-reasoning bypass: confirmed as plausible after seeing the repeated
  bridge pattern.

Minimum repair remains family-level: rewrite the three bridge checkpoint
distractor sets so each has at least one plausible two-concept wrong answer and
the correct answer is not always option 0.

## W7W9-DCA-002 - W9 Ladder-Pressure Payoff

Visible W9 route tasks are the 23 tasks under:

- `survival_pressure_basics`
- `m_ratio_zones_lite`
- `bubble_risk_premium`
- `tournament_pressure_checkpoint`

Visible route evidence:

- Required W9 teaching covers survival pressure, M-ratio urgency, bubble risk
  premium, medium/big/short stack adjustments, and player-adjustment preview.
- `ladder pressure` / `payout ladder` does not appear in the visible W9 task
  list or visible W9 runner copy.
- The hidden source `short_stack_ladder_pressure_lite` does teach ladder
  pressure, but it is hidden repair-source content, not normal-route required
  teaching.
- W9 payoff copy says: `You learned how survival pressure, ladder pressure, and
  risk premium change decisions.`

Minimum honest repair:

- A. Remove `ladder pressure` from the default W9 payoff. This is the smallest
  trust-preserving repair because the visible route already supports survival
  pressure and risk premium.
- B. Add a visible-route ladder-pressure explanation and assessment. This has
  higher learning EV only if the future W9 curriculum explicitly wants ladder
  pressure in the default route now.

Recommendation: choose A for the bounded repair wave. Do not choose B merely to
preserve existing payoff wording.

## W7W9-DCA-003 - Absolute/Extreme Distractor Inventory

Bounded count:

- visible route affected rows: 30;
- hidden-source-only additional affected specs: 7;
- total affected source rows in this verification boundary: 37.

Visible-route inventory:

| Task ID | World | Correct answer | Extreme/absolute distractor texts | Plausible elimination without domain reasoning | Family |
|---|---|---|---|---|---|
| `range_checkpoint_pressure` | W7 | `Bluff candidate` | `Always barrel as pressure` | yes | automatic action |
| `visible_ace_combo_reduction_intro` | W7 | fewer ace combos | unchanged; must have ace; never have ace | yes | exact-hand overclaim |
| `visible_king_combo_reduction_intro` | W7 | fewer king combos | unchanged; must have king; never have king | yes | exact-hand overclaim |
| `paired_board_texture_lite_intro` | W7 | fewer seven hands, trips possible | all strong hands removed; always trips | yes | all/always |
| `visible_card_combo_density_transfer_check` | W7 | visible rank reduces matching-rank combos | only low board cards matter; exact hand | yes | only/exact-hand |
| `visible_card_combo_reduction_recap` | W7 | visible rank reduces matching-rank combos | only low board cards matter; exact hand | yes | repeated transfer copy |
| `w7_100bb_tighter` | W8 | more room and more risk | mostly jam now | yes | short-stack overgeneralization |
| `w7_40bb_middle` | W8 | some room, not carefree deep | mostly shove-or-fold only; just like 100 BB | yes | endpoint-only contrast |
| `w7_ajs_btn_25bb_transfer` | W8 | use short-stack read | depth irrelevant; too fragile | partly | ignore cue |
| `w7_low_spr_commit` | W8 | one bet can commit | plenty of room; same as SPR 8 | yes | opposite/extreme contrast |
| `w7_high_spr_room` | W8 | more room to maneuver | immediate commitment; no difference from preflop | yes | opposite/extreme contrast |
| `w7_spr4_middle` | W8 | some room, some commitment | automatic commitment; same as SPR 8 | yes | endpoint-only contrast |
| `w7_top_pair_spr2_transfer` | W8 | less room, more commitment pressure | treat it like SPR 8; stack pressure can wait | yes | ignore cue |
| `w7_fullring_tighter` | W8 | range tightens | only stack depth matters | yes | only-cue distractor |
| `w7_format_table_notice` | W8 | count players behind and tighten | only watch stack depth | yes | only-cue distractor |
| `w7_stack_checkpoint` | W8 | range plus stack risk | range only; chip count only | yes | single-cue checkpoint |
| `w9_cash_vs_tournament` | W9 | survival pressure matters more | avoid all risk until paid | yes | total shutdown |
| `w9_short_stack_survival` | W9 | reasonable jam/reshove spot | wait only for premium pairs | yes | wait-only |
| `w9_m_ratio_red_zone` | W9 | controlled urgency | wait for perfect premium only | yes | wait-only |
| `w9_m_ratio_green_zone` | W9 | patience/table selection | avoid pressure spots entirely | yes | total avoidance |
| `w9_m_ratio_yellow_zone` | W9 | prepare action windows | ignore urgency; force any spot immediately | yes | ignore/panic |
| `w9_m_ratio_table_window_transfer` | W9 | practical action window now | wait until red; instant all-in panic | yes | wait/panic |
| `w9_medium_stack_tighten` | W9 | tighten marginal calls | fold everything until paid | yes | total shutdown |
| `w9_big_stack_leverage` | W9 | selective open pressure | jam any two cards every hand | yes | reckless absolute |
| `w9_bubble_short_stack` | W9 | take practical jam spots | fold every hand until payouts | yes | total shutdown |
| `w9_bubble_table_risk_transfer` | W9 | tighten thin stack-offs | over-fold every close hand | yes | overfold absolute |
| `w9_checkpoint_survival_line` | W9 | disciplined urgency | panic any two; wait only aces | yes | panic/wait-only |
| `w9_checkpoint_bubble_line` | W9 | tighten defend, avoid thin all-ins | fold every hand until payout | yes | total shutdown |
| `w9_checkpoint_table_notice` | W9 | respect bubble pressure | fold everything | yes | total shutdown |
| `w9_checkpoint_review` | W9 | map pressure, then adjust by player | only player type; only hole cards and ignore pressure | yes | single-cue checkpoint |

The W7 visible-card recap repeats the same transfer source and should be
repaired through the shared source spec rather than as a separate authored row.

Hidden-source-only additional rows:

| Task ID | World | Extreme/absolute distractor texts | Family |
|---|---|---|---|
| `short_stack_pressure_lite` | W8 | must always move all-in | all-in always |
| `deep_stack_room_lite` | W8 | all-in risk can never appear | never |
| `spr_transfer_check` | W8 | only current cards matter; small pot is always all-in | only/always |
| `risk_premium_medium_stack_intro` | W9 | any action fine | any-action |
| `short_stack_ladder_pressure_lite` | W9 | ladder ignores survival | ignore |
| `pressure_transfer_check` | W9 | higher pressure means automatic all-in; lower pressure is always a fold | automatic/always |
| `bubble_survival_pressure_intro` | W9 | bubble pressure removes risk | absolute removal |

Root-cause families:

- total shutdown / total avoidance;
- reckless action / any-two / automatic all-in;
- wait-only / premium-only;
- only-cue / ignore-cue distractors;
- exact-hand or all/never visible-card overclaims;
- bridge-checkpoint single-cue distractors.

A family-level repair is sufficient: replace one implausibly absolute
distractor per affected family with a plausible-but-wrong moderate distractor.
Do not rewrite every row automatically. Some contrast-teaching rows are
legitimate as teaching contrast, but they become invalid assessment support when
they appear repeatedly in prove/checkpoint tasks.

## W7W9-DCA-004 - W7 Paired-Board Transfer

W7 visible-card arc:

- teaching/example: A72 visible ace;
- guided practice/source: K84 visible king;
- guided practice/source: 772 paired board;
- independent transfer: A72 and K84 only;
- recap: repeats the A72/K84 transfer source.

The paired-board 772 case is independently assessed elsewhere only as showdown
strength (`w6_board_pair_strength_compare`), not as visible-card combo-density
logic. That does not close this visible-card transfer gap.

Disposition: confirmed P2. Extending the existing transfer task to include 772
can preserve one clear correct answer if the correct answer remains the shared
principle: visible ranks reduce matching-rank combinations without proving one
exact hand.

## W7W9-DCA-005 - Blocker Terminology

Bounded W1-W6 lookup:

- First canonical Act0 learner-facing use found: W6 range checkpoint feedback
  says `A-Q has two overcards and ace-blocker`.
- First `before blockers` combo-count use found: `w6_ak_combos` /
  `range_checkpoint_combos`.
- First plain-language explanation found in the canonical Act0 route before W7:
  none.
- Required before W7: yes, because the range-checkpoint tasks are on the W7
  continuation route before the visible-card lesson.

Disposition: confirmed bounded terminology gap. This is comprehension friction,
not answer-key failure: `before blockers` does not change the graded combo
answers. The smallest later repair is a short first-use clause defining blocker
as a visible/known card that removes possible private-card combinations.

## Verification Commands

- `git fetch origin`
- `git diff --name-status 27a862ed2055bd62f5bda3ca5aae8ef6faf04b64..299ea751800d9f54d3835e2a73168b677167d076`
- `git merge --ff-only claude/w7-w9-adversarial-content-learning-audit-v1`
- `git diff --check`
- `graphify hook-check`

Further post-artifact checks are recorded by the branch validation output.
