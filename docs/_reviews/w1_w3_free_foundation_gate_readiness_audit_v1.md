# W1-W3 Free Foundation Density / W4-W5 Gate Readiness Audit v1

Status: docs/code/content audit only
Date: 2026-06-18

## 1. Executive verdict

**Preserve `W5+` as the launch-default paid-depth boundary.**

`W4` is a credible challenger, but not ready to become the default public hard
gate from current repo evidence.

The key reason is not raw content volume. W1-W3 are no longer a thin demo:
the active Act0 route exposes about 150 W1-W3 tasks, with meaningful decisions,
feedback, repairs, and a concrete W3 position-repair loop. The blocker is
product truth and learner momentum:

- In the active Act0 shell, `W4` is `Preflop Framework`, the synthesis layer
  that connects bucket, seat, and action frame.
- In the authored `content/worlds` tree and older content plan, `W4` is `Bet
  Purpose + Price`, a clearer first paid-depth strategy pivot.
- Gating the active shell at W4 would charge before the learner receives the
  preflop framework synthesis that makes W1-W3 feel complete.
- Gating at W5 gives W4 free, preserves trust, and places the first paid gate at
  the next bigger depth step.

Boundary recommendation:

- Launch-default: **W5 boundary after W1-W4 free**.
- Strategy challenger: **W4 boundary only after the W4 meaning is normalized and
  W1-W3 completion telemetry proves high trust / high momentum**.
- Immediate next wave: **Premium Value Preview Surface v1**.

No product code, content, UI, copy, tests, routes, telemetry, commerce,
entitlement, screenshots, Playwright tooling, table geometry, or localization
changes were made.

## 2. Evidence reviewed

Planning / policy:

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/CURRICULUM_DENSITY_WORLD_VOLUME_CANON_v1.md`
- `docs/plan/WORLD_PROGRESSION_PACING_SSOT_v1.md`
- `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`
- `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md`
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`
- `docs/plan/MONETIZATION_TIMING_GUARD_v1.md`
- `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md`
- `docs/content/CONTENT_EXCELLENCE_CANON_v1.md`

Recent monetization / proof reviews:

- `docs/_reviews/final_first_week_commercial_proof_packet_v1.md`
- `docs/_reviews/monetization_ev_scenario_analysis_v1.md`
- `docs/_reviews/blind_monetization_strategy_challenge_v1.md`
- `docs/_reviews/repair_loop_coverage_matrix_v1.md`

Active runtime/content evidence:

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `content/worlds/world1/v1/**`
- `content/worlds/world2/v1/**`
- `content/worlds/world3/v1/**`
- `content/worlds/world4/v1/**`
- `content/worlds/world5/v1/**`

Count method:

- Active Act0 counts are based on the visible `Act0WorldCardV1` lesson/task
  lists in `act0_shell_state_v1.dart`.
- Authored content counts are based on files under `content/worlds/world*/v1`.
- Telemetry read is based on `Act0LessonRunnerShellV1` event fields.

Important evidence caveat:

The active Act0 shell and the authored content tree use different practical
world labels around W2-W5. The audit therefore separates **active shell route
truth** from **authored content inventory** instead of treating one as a full
substitute for the other.

## 3. W1 density findings

Active Act0 W1:

| Item | Count / read |
| --- | --- |
| Active shell world title | `Poker from Zero` |
| Learner promise | Table literacy: cards, seats, blinds, stack, pot, first hand, actions, rankings, showdown. |
| Lessons | 9 |
| Tasks | 70 |
| Theory-only tasks | 9 |
| Interactive / review tasks | 61 |
| Drill tasks | 51 |
| Review / prove tasks | 10 |
| Meaningful table-decision moments | High: seat taps, card/rank reads, board reads, action choice, showdown comparison, fold/check/call/raise. |
| Correct/wrong feedback coverage | Systemic through runner option feedback title/reason and review state. |
| Repair/recheck coverage | Strong for first-value signals: action/no-bet, board cards, hero cards, table read, price-read carry. |
| Telemetry | `task_shown`, `task_result`, `feedback_viewed`; includes `choiceId`, `result`, `errorType`, `feedbackSignal`, `tableSignal` when available. No `time_to_decision` evidence found. |
| Estimated completion | 9 lessons; likely multiple short sessions or a motivated long first block. |

Authored content W1:

| Item | Count / read |
| --- | --- |
| Sessions | 10 |
| Drill JSON files | 98 |
| Drill mix | 54 `choose`, 20 `find`, 14 `tap`, 10 `chain` |
| Session arc | Position-first choices, blind/button basics, action-order tracking, repeated preflop starts, in-position/OOP focus, mixed checkpoints. |

Emotional payoff:

- Strong first-value proof: user chooses, sees a table signal, gets feedback,
  and sees the same clue carry forward.
- Strong "I learned something" moment.
- Good "I fixed a mistake" support because early action/board/price/table
  signals map into repairs or rechecks.

Density risk:

- W1 is dense enough and may be the strongest free-trust unit.
- Main risk is not thinness; it is that a complete beginner may need pacing so
  W1 does not feel like too many discrete poker labels at once.

Commercial value:

- W1 must stay free.
- It proves Sharky is real, not a teaser.
- It does not by itself justify a hard paywall immediately afterward.

## 4. W2 density findings

Active Act0 W2:

| Item | Count / read |
| --- | --- |
| Active shell world title | `Hand Discipline` |
| Learner promise | Sort hands before putting chips in; fold discipline; continue vs let go; apply bucket/seat/frame. |
| Lessons | 6 |
| Tasks | 36 |
| Theory-only tasks | 6 |
| Interactive / review tasks | 30 |
| Drill tasks | 24 |
| Review / prove tasks | 6 |
| Meaningful table-decision moments | Medium-high: bucket classification, fold/continue, pressure fold, apply UTG/BTN/HJ decisions. |
| Correct/wrong feedback coverage | Systemic in active runner options; task families include practice, fixMistakes, transfer, proveIt. |
| Repair/recheck coverage | Good: fold discipline and apply tasks use fixMistakes; checkpoint includes real-table discipline transfer. |
| Telemetry | Same runner telemetry path as W1; no `time_to_decision` evidence found. |
| Estimated completion | 6 lessons; enough for 2-4 short sessions depending pace. |

Authored content W2:

| Item | Count / read |
| --- | --- |
| Sessions | 14 |
| Drill JSON files | 111 |
| Drill mix | 63 `choose`, 17 `find`, 9 `tap`, 8 `chain`, plus classify/count/review/bridge tasks. |
| Session arc | Showdown, position, initiative, board texture, outs, price-sensitive continue decisions, linked hand chains. |

Emotional payoff:

- Active W2 can produce "I avoided a bad continue" and "folding can be a good
  decision."
- It is commercially useful because it teaches a mistake recreational players
  feel immediately: overplaying familiar or weak hands.

Density risk:

- Active W2 is solid, but narrower than authored content W2.
- The active shell's W2 is not the same as authored content W2, which creates
  boundary/copy risk if monetization claims are based on one numbering system
  while runtime uses another.

Commercial value:

- W2 is strong free trust content.
- It should not be gated; it is part of the product's beginner confidence
  foundation.

## 5. W3 density findings

Active Act0 W3:

| Item | Count / read |
| --- | --- |
| Active shell world title | `Position Thinking` |
| Learner promise | See why seat order changes hand value and comfort. |
| Lessons | 6 |
| Tasks | 44 |
| Theory-only tasks | 6 |
| Interactive / review tasks | 38 |
| Drill tasks | 32 |
| Review / prove tasks | 6 |
| Meaningful table-decision moments | High: BTN/UTG seat reads, early-vs-late order, same hand/different seat, BTN open, early fold, position checkpoint. |
| Correct/wrong feedback coverage | Systemic runner feedback; W3 has signal-bound table/seat proof support. |
| Repair/recheck coverage | Strong relative to prior state: BTN seat-ID, UTG seat-ID, BTN-last postflop, UTG players-behind, early/late order, same-hand/different-seat, CO players-behind/position checkpoint. |
| Telemetry | Same runner telemetry path; repair queue lifecycle is supported by existing repair MVP seams. No `time_to_decision` evidence found. |
| Estimated completion | 6 lessons; likely 2-4 short sessions. |

Authored content W3:

| Item | Count / read |
| --- | --- |
| Sessions | 14 |
| Drill JSON files | 18 |
| Drill mix | 14 `chain`, 4 `choose` |
| Session arc | Preflop framework through hand categories, open/call/fold logic, category reuse, position-aware open/fold/call bridges. |

Emotional payoff:

- W3 has a strong "same hand changes by seat" aha.
- W3 now has concrete repair proof, which matters for trust before any future
  gate.

Density risk:

- Active W3 is dense and repair-rich.
- Authored W3 has many sessions but only 18 drill JSON files, so underlying
  generated/session content depth is less uniform than W1/W2/W4.
- W3 still does not fully close active preflop synthesis because active shell
  W4 is `Preflop Framework`.

Commercial value:

- W3 creates paid intent, especially for motivated beginners and recreational
  players who feel position affects real decisions.
- W3 is not enough by itself to make a hard W4 gate feel safe for all beginners
  because W4 is the synthesis of preflop frame before action.

## 6. W1-W3 foundation verdict

W1-W3 are strong enough to support:

- soft premium preview after completed learning value;
- a future paid-depth explanation;
- W4 as a high-priority boundary experiment candidate;
- high-intent segmentation later.

W1-W3 are not yet strong enough to make W4 the launch-default hard gate.

Why:

1. W1-W3 do feel like a real product, not a demo.
2. W1-W3 create real free trust through table-signal feedback and repair.
3. W1-W3 have enough decisions and repairs to support monetization interest.
4. But active W4 is still a foundational synthesis layer, not obvious paid
   depth.
5. Blocking active W4 risks the message: "pay before Sharky shows the full
   preflop framework."
6. The content-plan W4 and active-shell W4 mismatch would make W4 paywall copy
   easy to overclaim or misplace.

Threshold read:

| W4 launch-default threshold | Current read |
| --- | --- |
| Enough playable decisions, not just theory | Pass |
| At least one strong repair loop | Pass |
| Clear "I improved" moment | Pass |
| Enough table-signal proof | Pass |
| Gate does not feel sudden | Mixed |
| No severe beginner-confidence gap | Mixed |
| No content/repair/telemetry blocker | Mixed: telemetry lacks time-to-decision; W4 numbering/meaning mismatch remains. |

Verdict:

**Mixed. Keep W5 default; promote W4 to challenger, not launch default.**

## 7. W4 paid-gate candidate findings

Active Act0 W4:

| Item | Count / read |
| --- | --- |
| Active shell world title | `Preflop Framework` |
| Learner promise | Use bucket, seat, and action frame before choosing. |
| Lessons | 5 |
| Tasks | 21 |
| Theory-only tasks | 5 |
| Interactive / review tasks | 16 |
| Drill tasks | 11 |
| Review / prove tasks | 5 |
| Meaningful table-decision moments | Medium: first-in open, facing open, open/call/fold, same hand/different action, table frame transfer. |
| Repair/recheck coverage | Some through inherited source tasks and checkpoint transfer, but less broad than W3. |
| Telemetry | Same active runner telemetry; no `time_to_decision` evidence found. |

Authored content W4:

| Item | Count / read |
| --- | --- |
| Authored world title | `Bet Purpose + Price` |
| Sessions | 10 |
| Drill JSON files | 123 |
| Drill mix | 73 `choose`, 27 `find`, 20 `tap`, 3 `chain` |
| Session arc | Value/protection/bluff/denial intent, price awareness, size presets, purpose-and-price checkpoints. |

Commercial case for W4 gate:

- If W4 means authored `Bet Purpose + Price`, it is a real strategy pivot.
- It preserves high-value material behind premium.
- It may capture high-intent user impulse earlier.

Commercial case against W4 gate:

- If W4 means active `Preflop Framework`, gating it blocks the synthesis layer
  that makes W1-W3 feel complete.
- Active W4 is only 5 lessons / 21 tasks, materially thinner than W1 and W3.
- The world-numbering mismatch is a product-truth risk for paywall copy and
  App Store review safety.
- A W4 hard gate would be more likely to feel like "the real training starts
  after payment" for complete beginners.

Verdict:

**W4 is a challenger only after the route contract is normalized and high-intent
telemetry proves W1-W3 completion momentum.**

## 8. W5 paid-gate candidate findings

Active Act0 W5:

| Item | Count / read |
| --- | --- |
| Active shell world title | `Bet Purpose And Price` |
| Learner promise | Understand value, bluff, protection, and call price. |
| Lessons | 7 |
| Tasks | 33 |
| Theory-only tasks | 7 |
| Interactive / review tasks | 26 |
| Drill tasks | 19 |
| Review / prove tasks | 7 |
| Meaningful table-decision moments | High commercial value: value/bluff/protection/price/sizing/action reads. |
| Repair/recheck coverage | Price-read same-signal repair exists; W5/W6 board and draw repair mappings exist in review evidence. |
| Telemetry | Same runner telemetry; no `time_to_decision` evidence found. |

Authored content W5:

| Item | Count / read |
| --- | --- |
| Authored world title | `Board Awareness` |
| Sessions | 10 |
| Drill JSON files | 38 |
| Drill mix | 30 `classify`, 8 `chain` |
| Session arc | Texture buckets, dry/wet boards, turn/river shifts, draw completion, blocker context, texture synthesis. |

Commercial case for W5 gate:

- W1-W4 free gives the learner table literacy, hand discipline, position, and
  preflop framework in the active route.
- Active W5 is a cleaner paid-depth promise: bet purpose, price, and sizing are
  intuitively "deeper training."
- W5 reduces refund/churn risk because the user has had enough route depth to
  understand what Sharky teaches.
- Soft premium preview can reduce gate surprise before W5.

Commercial risk:

- W5 is later, so some high-intent impulse may cool.
- If W4 remains free, Sharky gives away a meaningful preflop framework layer.
- W5 gate still cannot ship until commerce safety is production-ready.

Verdict:

**W5 remains the max-EV default boundary.**

## 9. W4 vs W5 score table

Score convention: `10` is best. For risk columns, higher means safer.

| Candidate | Activation | First-session trust | D1 retention | D7 retention | Paid intent at gate | Chance reaches gate | Conversion direction | Revenue quality | Refund/churn safety | App review safety | Beginner confidence | High-intent momentum | Free value sufficiency | Free value leakage control | Implementation risk | Commerce-safety compatibility | Top-1 ambition | Avg |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A. W4 hard boundary after W1-W3 free | 8.0 | 7.4 | 7.2 | 7.1 | 8.3 | 7.8 | 8.0 | 8.0 | 6.8 | 6.8 | 6.9 | 8.6 | 7.2 | 8.3 | 5.5 | 3.5 | 7.8 | 7.3 |
| B. W5 hard boundary after W1-W4 free | 8.7 | 8.8 | 8.4 | 8.2 | 7.7 | 7.2 | 7.8 | 8.3 | 8.4 | 8.3 | 8.6 | 7.8 | 8.9 | 7.4 | 6.3 | 3.8 | 8.7 | 8.0 |
| C. W4 high-intent / W5 default experiment | 8.5 | 8.4 | 8.2 | 8.2 | 8.4 | 7.6 | 8.4 | 8.7 | 7.8 | 7.6 | 8.1 | 9.0 | 8.5 | 8.1 | 4.2 | 3.0 | 9.0 | 7.9 |
| D. W5 default now, W4 future A/B candidate | 8.8 | 8.9 | 8.5 | 8.4 | 8.1 | 7.4 | 8.1 | 8.6 | 8.6 | 8.5 | 8.8 | 8.3 | 9.0 | 7.8 | 7.4 | 8.3 | 9.0 | 8.5 |

Winner:

**D. W5 default now, W4 future A/B candidate.**

Why D beats B slightly:

- It preserves the safer W5 launch default.
- It keeps W4 alive as a primary experiment instead of burying the revenue
  upside.
- It avoids premature hard-coding in premium copy.
- It matches current commerce reality: preview now, hard gate later.

## 10. Impulse / momentum analysis

W4 gate upside:

- Captures high-intent users earlier.
- Makes premium feel tied to strategy, not late advanced study.
- Prevents giving away too much preflop/value logic if W4 is interpreted as
  bet-purpose/price.

W4 gate downside:

- Active shell W4 is `Preflop Framework`; blocking it may interrupt the first
  coherent strategy synthesis.
- Complete beginners may feel they learned labels but not yet the usable
  framework.
- W4 gate requires more explanation and thus more copy risk.

W5 gate upside:

- Lets the free path feel whole.
- Makes paid depth feel earned.
- Reduces refund and negative-review risk.
- Still preserves meaningful premium curiosity because active W5 owns bet
  purpose/price.

W5 gate downside:

- Later gate can cool some high-intent impulse.
- Needs a soft preview so the W5 lock does not feel sudden.

Momentum verdict:

W4 is the right **experiment question**. W5 is the right **launch default**.

## 11. Trust / refund / churn risk analysis

Trust is strongest when the learner reaches a paid boundary after these moments:

1. "I read a visible table clue."
2. "I made a decision."
3. "The feedback showed why."
4. "A mistake became a repair."
5. "I completed enough route to understand the app's method."

W1-W3 satisfy the first four. They partially satisfy the fifth, but active W4 is
the missing synthesis layer for many learners.

Refund/churn risk:

- W4 gate: medium risk for beginners, lower risk for high-intent users.
- W5 gate: lower risk across the default cohort.

App Store review risk:

- W4 gate has higher risk because the route-numbering/content-meaning mismatch
  can make premium promises harder to state precisely.
- W5 gate is easier to defend: W1-W4 free is a visible foundation; W5 is paid
  depth.

## 12. Revenue / LTV analysis

Short-term revenue:

- W4 likely wins for high-intent users if commerce were ready.
- W4 may also increase trial-start volume by reaching the pay moment earlier.

Revenue quality:

- W5 likely wins on paid quality because the user has more proof before the
  purchase decision.
- W5 should lower refund, early cancellation, and "not enough free value"
  complaints.

LTV:

- W5 default plus future high-intent W4 experiment is the strongest path.
- It keeps launch trust high while preserving the ability to capture earlier
  intent later with data.

## 13. Recommendation

Recommended boundary:

**W5 launch-default. W4 challenger.**

Meaning:

- Do not implement W4 hard gate now.
- Do not write premium copy that assumes W4 is the default paid boundary.
- Preserve `W1-W4` as the public free foundation in launch-default strategy.
- Treat W4 as the primary future A/B candidate after commerce safety and route
  telemetry improve.

W4 can graduate to launch-default only if:

1. Active shell and content-plan world meanings are normalized.
2. W1-W3 completion telemetry shows strong trust and momentum.
3. Time-to-decision or equivalent confidence telemetry exists.
4. W4 gate copy can truthfully say paid depth starts without implying the free
   route withheld the first real framework.
5. Commerce is production-safe.

## 14. Recommended immediate next wave

**Premium Value Preview Surface v1**

Reason:

- W1-W3 are not too thin for value packaging.
- The audit does not find a W1-W3 blocker requiring foundation strengthening
  before preview.
- A preview can make either future boundary more coherent.
- It must remain non-commerce while paywall safety is unresolved.

Scope constraints for that wave:

- preview-only;
- after completed learning value;
- no price, purchase, trial, restore, or Premium Hub route;
- no W4/W5 hard-boundary copy;
- no AI/adaptive/GTO/solver/guaranteed claims;
- primary action remains free-route continuation.

## 15. Deferred experiments

- W4 vs W5 hard boundary A/B after commerce readiness.
- W4 gate only for high-intent users who click preview, finish W1-W3 quickly, or
  repeatedly choose extra reps.
- Trial at D2 return vs W5 locked-depth attempt.
- Dynamic boundary copy after time-to-decision or confidence telemetry exists.
- One-time starter pack for price-sensitive high-intent learners.
- Analytics/leak-profile paid layer after real behavioral data exists.

## 16. Risks and assumptions

Risks:

- Active shell W4/W5 meaning differs from authored content W4/W5 meaning.
- Content-tree drill counts are not the same as active runtime proof.
- Telemetry includes choice/result/error type, but no clear `time_to_decision`
  field was found.
- W3 authored drill count is low despite active shell W3 being repair-rich.
- Future premium copy could accidentally rely on authored content names instead
  of active route names.

Assumptions:

- Active Act0 shell route is the launch-facing product truth.
- Authored content tree matters as depth evidence but does not replace active
  shell proof.
- The public hard paywall remains blocked until commerce safety is closed.

## 17. Direction score

Current hard-boundary direction: **8.6 / 10**.

The direction is strong because Sharky now has a real W1-W3 free foundation,
strong first-week commercial proof, and a clear monetization guard. It is not
`10/10` because W4/W5 route meaning is not fully normalized, W4 remains a real
revenue challenger, and telemetry lacks time-to-decision evidence for boundary
confidence.

Final read:

**Build the soft preview next. Keep W5 as the default future paid boundary. Do
not close the door on W4, but do not hard-code it yet.**
