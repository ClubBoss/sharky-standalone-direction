# Act0 First Value + Daily Loop Closeout Audit v1

Date: 2026-06-18
Mode: audit-only closeout / recalibration
Scope: active Act0 first-value, Home return, daily completion, and Review repair proof loop.

## 1. Purpose

This closeout asks whether the current Act0 first-value and daily repair loop is coherent enough to stop local micro-polish and move to the next macro-layer.

The target loop is:

`placement route proof -> useful first hand -> visible table clue -> feedback proof -> same-signal next rep -> daily completion -> repair proof -> return reason`

This artifact is not an implementation packet. It must not be used as approval for runtime logic, route changes, dashboards, Skill Map, Leak Profile, monetization, screenshots, Playwright, table geometry, content expansion, or fake AI/adaptive claims.

## 2. Current Loop Summary

The current Act0 loop is coherent end to end.

1. Placement result frames the learner's start and the first hand:
   - `Your first hand will teach one table clue.`
   - `Start with the useful hand`
2. Direct handoff launches the recommended runner instead of returning Home first.
3. First feedback creates a concrete learning receipt:
   - `Table read improved`
   - `You noticed No bet yet before choosing an action.`
   - `Next: practice the same table clue once more.`
4. Home carries the first-value receipt into a same-signal next rep:
   - `Next: one more action-read rep`
   - `You started with No bet yet. One more rep makes it stick.`
5. Wrong first-value path carries a repair-oriented Home route:
   - `Repair: Action read`
   - `The No bet yet clue is waiting. One repair rep makes it easier next time.`
6. Daily completion closes the short practice loop:
   - `Daily set complete`
   - `Short practice done. Today's table clue is warmer, and the next useful hand will be ready when you return.`
7. Review closes the repair loop:
   - `Recovered lately`
   - `Repaired`
   - `Replay for perfect`

Closeout read:

- The loop now tells a beginner what improved, what table clue mattered, what to repeat, and why returning is useful.
- Deterministic proof is strong enough to stop local first-value/Home/Review copy work.
- The next gap is macro-level: Day 2 persistence/perception and premium product confidence, not another narrow copy tweak.

## 3. Evidence / Proof Table

| layer | current behavior | proof source: test/doc/screenshot/code | status | remaining concern | next action |
| --- | --- | --- | --- | --- | --- |
| Placement result | Shows route proof and says the first hand teaches one table clue. | `test/ui_v2/act0_shell_preview_screen_v1_test.dart` assertions for `Your first hand will teach one table clue.` and `Start with the useful hand`; `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart` copy owner. | green | Still mostly route/learning promise; not a broad premium proof surface. | Close local copy arc; include in later premium QA. |
| First hand handoff | `Start with the useful hand` direct-starts the runner. | Placement direct-start tests and prior accepted placement handoff waves. | green | No current local blocker. | Keep. |
| First correct feedback | Shows `Table read improved`, `You noticed No bet yet before choosing an action.`, and next same-clue practice. | Focused first-value tests; `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` first-value receipt copy. | green | First clue is intentionally narrow: action-read/no-bet. | Keep; broader first-table identity belongs to future product QA, not local copy churn. |
| First wrong feedback | Shows safe repair framing and the missed clue. | Wrong first-value Home carry test and feedback tests. | green | Full repaired proof is only visible if user enters repair path. | Accept; do not force Review into first session. |
| Same-signal next rep | Home launches mapped `actions_check_drill`; telemetry includes receipt, signal, target, and mapping type. | `first_value_today_shown`, `first_value_today_consumed`, and `first_value_daily_rep_launched` test assertions. | green | Persistence after app relaunch remains a macro question. | Audit Day 2 persistence next. |
| Home first-return copy | Correct path says `You started with No bet yet. One more rep makes it stick.` | Home First-Return Reason Line v1 focused tests. | green | Session-local clarity is strong; return-after-time behavior is not yet proven. | Move to Day 2 persistence audit. |
| Home repair carry | Wrong path says `The No bet yet clue is waiting. One repair rep makes it easier next time.` | Wrong first-value receipt Home carry test. | green | Repair value is clear, but only after wrong answer. | Keep. |
| Home daily checklist | Home can show Learn/Practice/Review/Fix rows, repair/recheck/prove jobs, and daily progress. | Daily checklist and daily progress tests. | green | Could still feel utilitarian rather than premium. | Include in Product Surface Premium QA later. |
| Practice daily completion | `Daily set complete` with table-clue return reason. | `Home shows done-for-today state after daily goal is reached` focused test. | green | Copy proves completion; persistence and notification/return mechanics are out of scope. | Day 2 persistence audit. |
| Home done state | Shows `Today complete` and table-clue completion reason. | Daily completion test and Home done card copy owner. | green | Same as above: visible after same-session completion; relaunch path unknown. | Day 2 persistence audit. |
| Open repair | Mistake creates repair item; Home/Review can start repair. | Repair Loop Coverage Matrix v1; repair lifecycle tests. | green | Some advanced/source families remain outside first-loop scope. | Defer broad repair v2 unless real blocker appears. |
| Repaired proof | Correct repair shows `Recovered lately`, `Repaired`, `Replay for perfect`. | Review Repaired Proof Drift Fix v1 verification; repaired proof tests. | green | Full broad preview suite may still contain unrelated stale drift. | Stop local Review copy work; run targeted proof lanes only. |
| Screenshot proof | Exact first correct feedback capture harness exists for `runner_first_correct_feedback`; manual screenshot QA produced readable feedback screenshots. | `docs/_reviews/first_session_manual_screenshot_qa_v1.md`; `output/playwright/first_correct_feedback_capture_harness_v1/`. | partial | Screenshot tooling had separate reliability/blank-lane triage; no new capture was run here. | Do not prioritize screenshot tooling unless it blocks a launch proof packet. |
| Compact runner stability | Runner compact loop passed in recent corrective waves. | `./tools/fast_loop_runner_compact_v1.sh` prior wave verification. | green | This closeout did not rerun tests by design. | Continue using focused lanes for implementation waves. |

## 4. Remaining Gaps Table

| gap | affected layer | severity | EV if fixed | implementation risk | recommended timing | rationale |
| --- | --- | --- | --- | --- | --- | --- |
| Day 2 / relaunch persistence contract is not proven. | Home return, daily loop, first-value carry | high | high | low-medium | next | Current loop is coherent in-session. Market retention depends on whether the learner returns later and still sees the same useful next step. |
| Premium trainer perception is still behind benchmark packaging. | Placement, Home, Practice, Review, visual hierarchy | high | high | medium | second | Runout-style perceived polish remains stronger. Sharky should QA premium feel without redesigning the core loop. |
| First clue is narrow action-read/no-bet. | first feedback, first identity proof | medium | medium | low-medium | later | It is beginner-safe and useful, but not the full "I read the table" identity. Do not churn copy unless QA shows weak perception. |
| Repair breadth is strong enough for now, but not complete. | W3/W5/W6 repair coverage | medium | medium | medium | defer | Many exact repairs now exist. More W3 micro-reps risk local overfitting unless a coverage blocker appears. |
| Full broad preview test drift may remain. | test suite confidence | medium | medium | medium | opportunistic | Focused proof lanes are green, but broad preview drift should not block macro product work unless it hides active regressions. |
| Screenshot/capture reliability is partial. | proof tooling | low-medium | low-medium | medium | defer | Useful for review packets, but the product loop does not depend on capture tooling. |
| Trust/monetization readiness is not yet the next move. | paywall/trial/store trust | medium | high later | medium-high | after value/persistence proof | Monetization before stronger return proof would weaken the current trust advantage. |
| Format scalability is intentionally constrained. | future cash/MTT/all-format support | low now | high later | high | defer | Core Act0 loop should be proven before broad format promises. |

## 5. Benchmark Comparison

This comparison uses only proven current Sharky behavior and previously accepted benchmark direction.

| benchmark | where benchmark is stronger | where Sharky is stronger now | current gap | implication |
| --- | --- | --- | --- | --- |
| Runout | Premium packaging, trainer perception, broad adaptive-feeling promise, polished onboarding. | Deterministic table-signal proof before monetization: clue -> action -> feedback -> same-signal rep -> repaired proof. | Sharky's mechanics are credible; packaging/perceived trainer confidence can still lag. | Next macro should improve return/premium perception without copying Runout text/assets/paywall framing. |
| GTO Wizard | Deep solver architecture, breadth, advanced study credibility. | Beginner-safe table-first learning with no GTO/solver burden. | Sharky cannot and should not compete on solver depth in Act0. | Keep Act0 focused on novice table literacy and deterministic repairs. |
| Poker Trainer-style beginner apps | Simple beginner ramp and low cognitive overhead. | More explicit causal proof and repair loop. | Sharky must keep the loop feeling simple despite more machinery underneath. | Avoid dashboards and jargon; QA for perceived simplicity. |
| Pairrd / PokerCoaching-style habit/trust stack | Perceived coaching ecosystem, habit/trust packaging, market credibility. | Concrete first-value proof and honest non-AI personalization. | Sharky still needs stronger first-return trust packaging before monetization. | Day 2 persistence and product-surface QA are higher EV than paywall work now. |

## 6. Direction Score

Current direction score: 8.9 / 10.

Why this is high:

- The first session now has a real first-value receipt.
- The first-value receipt maps into a deterministic same-signal next rep.
- Wrong answers produce safe repair framing.
- Review can close the loop with `Recovered lately`, `Repaired`, and `Replay for perfect`.
- Daily completion now says why returning matters in table-clue language.
- The app avoids fake AI, GTO/solver, and pressure-based habit claims.

Why it is not yet 9.5+:

- Day 2 / relaunch persistence is not proven.
- Premium trainer perception still needs a macro QA pass.
- The loop is strong mechanically, but market perception depends on how it feels across a real first return.

## 7. Closeout Verdict

Ready to move macro-layer.

Local Act0 first-value + daily repair loop work should close for now.

No local blocker remains that justifies more immediate first-feedback/Home/Review micro-polish. Further local work risks overfitting copy and W3 repair details instead of improving market competitiveness.

Do not proceed to monetization or broad dashboards yet. The next macro-layer should validate whether the loop survives the first real return and feels premium enough to compete.

## 8. Recommended Next 1-3 Macro Arcs

### 1. First Return / Day 2 Persistence Contract Audit v1

Priority: highest.

Goal:

Audit what the learner sees after closing and reopening the app after first value or daily completion.

Questions:

- Does first-value carry persist or intentionally expire?
- Does Home still show the same useful next step?
- Does daily completion reset cleanly the next day?
- Does repaired proof remain understandable after time passes?
- Does the learner know "what to do next" without remembering the prior session?

Why this wins:

- Directly affects retention perception.
- Builds on the accepted loop instead of adding local polish.
- Bounded as an audit first.
- Avoids dashboards, monetization, and fake adaptive claims.

### 2. Product Surface Premium QA v1

Priority: second.

Goal:

Run a bounded QA pass across the now-accepted first-session/return surfaces for premium trainer feel, hierarchy, density, and consistency.

Include:

- Placement result
- First feedback
- Home first-value carry
- Daily completion
- Review repaired proof

Guard:

- QA first, no broad redesign.
- Only admit implementation if a blocker-class hierarchy/copy issue is proven.

Why:

Runout remains stronger in perceived polish. Sharky should make the accepted deterministic loop feel premium rather than merely functional.

### 3. Trust / Monetization Readiness Audit v1

Priority: third, not immediate implementation.

Goal:

Audit when Sharky can introduce premium/trial trust messaging without weakening first-value credibility.

Guard:

- Audit only.
- No paywall implementation.
- Must preserve value-before-monetization.

Why:

The loop is close enough to start asking when monetization can be trustworthy, but Day 2 persistence should come first.

## 9. Deferred List

- More W3 repair micro-reps unless a real coverage blocker appears.
- Broad Review/Home copy cleanup.
- Dashboard, Skill Map, Leak Profile, or heavy analytics.
- Screenshot/tooling work unless it blocks a specific proof packet.
- New onboarding questions.
- Table geometry or answer dock changes.
- Content expansion beyond a proven macro need.
- Paywall/trial implementation.
- Fake AI/adaptive claims.
- GTO/solver/optimal-frequency copy.
- All-format expansion before the core return loop is proven.

## 10. Stop Rules For Avoiding Micro-Polish Drift

Stop a future wave if:

1. It changes first-feedback/Home/Review copy without a newly proven user-facing blocker.
2. It adds another W3 micro-rep without showing a current repair coverage blocker.
3. It proposes dashboard, Skill Map, or Leak Profile as the immediate next step.
4. It prioritizes screenshot tooling over learner-facing proof.
5. It introduces paywall/trial messaging before Day 2 persistence is understood.
6. It broadens to all-format or solver-adjacent claims.
7. It touches table geometry, answer dock geometry, or route order without a blocker-class regression.
8. It weakens the deterministic proof chain: table clue -> answer -> feedback -> next rep/repair -> proof.

## 11. Macro Candidate Ranking

| candidate | rank | EV | risk | decision | rationale |
| --- | ---: | --- | --- | --- | --- |
| First Return / Day 2 Persistence Contract Audit v1 | 1 | high | low-medium | do next | Highest retention/perception leverage after in-session loop closeout. |
| Product Surface Premium QA v1 | 2 | high | medium | do after Day 2 audit | Addresses Runout packaging gap, but should not become visual polish without learner EV. |
| Trust/Monetization Readiness Audit v1 | 3 | medium-high | medium | audit after return proof | Important commercially, but premature before return proof is stable. |
| Daily Repair Queue Visibility Pass v1 | 4 | medium | medium | defer | Repair visibility is good enough; avoid local Review/Home churn. |
| Curriculum/Teaching Depth Audit v1 | 5 | medium | medium | defer | Useful later, but current first-value loop does not need content depth work next. |
| Broader Repair Coverage Matrix v2 | 6 | medium | medium-high | defer | Existing repair coverage is strong enough to stop local repair expansion. |
| Format Scope Guard Audit v1 | 7 | low now | medium | defer | Keep Act0 focused before format scalability. |

## 12. Final Closeout

The Act0 first-value + daily loop arc is closed.

Recommended next macro-layer:

`First Return / Day 2 Persistence Contract Audit v1`

Reason:

Sharky now proves value in-session. The next competitive question is whether that proof survives the first real return without becoming a dashboard, fake adaptive promise, or premium-paywall jump.
