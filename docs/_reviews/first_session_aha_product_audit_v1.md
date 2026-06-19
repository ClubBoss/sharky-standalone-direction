# First Session Aha Product Audit v1

Status: audit-only product review
Scope: active Act0 first-session path from placement entry through first table decision, feedback, Home handoff, and first repair perception
Date: 2026-06-18

## 1. Purpose

This artifact evaluates whether Sharky's current first-session path gives a new learner a fast, clear product-level aha:

`I can read the poker table better now.`

This is not an implementation packet. It must not be used as approval to change runtime logic, route order, content, UI, telemetry, tests, table geometry, dashboards, monetization, or fake AI/adaptive claims.

## 2. Current First-Session Path Summary

Current first-session path from the active Act0 shell:

1. First start opens placement before the app shell.
2. Placement intro promises a short route check:
   - `Find your start`
   - `Answer two quick questions. Then Sharky opens the first useful hand.`
   - `No exam. Just your starting point.`
3. Placement asks two intake questions:
   - `Where are you starting from?`
   - `How should Sharky start?`
4. Non-beginner path shows a quick table check before the first hand:
   - `Three short checks before your first hand.`
   - `No score. Just read what is visible.`
   - `Read hand, board, and first actions.`
5. Placement result shows deterministic route proof:
   - `Your start is ready`
   - level such as `Ready for action basics`
   - focus chips such as `Table read` and `Action basics`
   - `Start first hand`
6. `Start first hand` launches the recommended runner directly.
7. First runner decision currently proves an early action-read signal:
   - `No one has bet on this street.`
   - `What action keeps playing for free?`
   - correct answer: `Check`
8. First feedback shows compact proof:
   - correct path: `Action read improved`, `You used No bet yet before acting.`
   - wrong path: `Good spot to repair`, `The missed signal was No bet yet.`
   - both avoid raw `Skill:` / `Signal:` labels.
9. Home carries the first-value receipt:
   - learned path: `Next: one more action-read rep`, `Use No bet yet before the next action.`
   - repair path: `Repair: Action read`, `Try No bet yet once more.`
10. The deterministic repair system exists beyond the first hand:
   - repair item -> repair runner -> correct answer -> `Repaired` proof.

## 3. First Value Moment Assessment

Current first-session aha is real but narrow.

What works:

- The learner reaches table interaction quickly after a short placement flow.
- The first table decision uses a visible signal: `No bet yet`.
- Feedback explicitly ties outcome to that signal.
- Home carries the exact signal into a next rep or repair-oriented daily action.
- The flow avoids paywall pressure and avoids fake AI/GTO/solver claims.

What is weaker:

- The first product promise says "first useful hand" and "table read", but the first normal proof is action-read/no-bet. This is useful, but it may feel like learning a button/action rule rather than a broader "I read the table better" moment.
- The strongest table-read aha (`Hero cards + board + pot`, same scan/new spot) exists in W1 same-signal/content, but it is not necessarily the dominant first emotional receipt.
- Personal repair is visible if the first answer is wrong and then Home is reached, but the full repair queue/Repaired proof is not naturally demonstrated in the first few minutes unless the learner takes the repair route.
- Placement has strong trust copy, but it still includes enough steps that the first table interaction may feel delayed for impatient users.

Overall read:

Current first-session aha is good enough to prove early value, but the next highest-EV pass should make the first feedback/Home receipt sound more like a table-reading win and less like an isolated action-rule win.

## 4. Aha Rubric

Scores use 1-5, where 5 means strong first-session product proof.

| key state | clarity of user job | speed to table interaction | table-first teaching quality | feedback clarity | personal repair visibility | copy density | beginner safety | premium/trainer perception | next-action clarity |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Placement intro | 5 | 3 | 3 | n/a | 2 | 4 | 5 | 4 | 5 |
| Placement Q1/Q2 | 5 | 3 | 2 | n/a | 2 | 4 | 5 | 4 | 5 |
| Quick-check ready | 4 | 3 | 4 | n/a | 2 | 4 | 5 | 4 | 5 |
| Placement diagnostic | 4 | 4 | 5 | 4 | 2 | 4 | 5 | 4 | 4 |
| Placement result | 5 | 5 | 4 | n/a | 3 | 4 | 5 | 4 | 5 |
| First runner decision | 5 | 5 | 4 | n/a | 2 | 5 | 5 | 4 | 4 |
| First feedback, correct | 5 | 5 | 4 | 5 | 3 | 5 | 5 | 4 | 5 |
| First feedback, wrong | 5 | 5 | 4 | 5 | 4 | 5 | 5 | 4 | 5 |
| Home first-value carry | 5 | 5 | 4 | 4 | 4 | 5 | 5 | 4 | 5 |
| Review/Repaired proof if reached | 5 | 4 | 5 | 5 | 5 | 4 | 5 | 4 | 5 |

## 5. Screen / State Audit Table

| state/screen | user job | current visible promise/action | first-session value contribution | issue, if any | severity | likely fix type | implementation risk | recommended action | rationale |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Placement intro | Understand why setup exists and start. | `Answer two quick questions. Then Sharky opens the first useful hand.` | Strong trust setup, no payment pressure, clear route. | "Useful hand" is good, but not yet a concrete table-signal promise. | medium | copy | low | copy_tune_later | A small promise like "read one visible table signal" could sharpen the later aha without changing flow. |
| Placement Q1 | Say experience level. | `This is not a test. It only sets your pace.` | Strong beginner safety. | No direct table proof yet. | low | defer | low | keep | This is intentionally low-friction and should not expand. |
| Placement Q2 | Choose start speed. | `Pick the start that feels easiest.` | Gives user control without exam pressure. | Personalization is felt as pacing, not yet as deterministic route proof. | low | defer | low | keep | Current two-question count is appropriate. |
| Quick-check ready | Consent to table read. | `Three short checks before your first hand.`, `No score. Just read what is visible.` | Good "not an exam" framing and table-first expectation. | Three checks may feel like an extra gate after two questions. | medium | pacing/copy | low | audit_deeper | Only tune if manual first-session review confirms perceived drag. |
| Placement diagnostic | Read visible table signals. | hand/board/action checks with feedback proof. | Strong table-first teaching before first hand. | Diagnostic value may be cognitively separate from the "first hand" aha. | medium | flow/copy | medium | copy_tune_later | Handoff copy should bridge diagnostic signal -> first hand signal. |
| Placement result | Understand recommended start. | `Your start is ready`, `Ready for action basics`, `Start first hand`. | Strong deterministic route proof and direct runner launch. | Still more route-proof than learning-proof. | medium | copy | low | copy_tune_later | Add/adjust microcopy later to say what signal they just proved. |
| First runner teaching | Learn the first action signal. | `No one has bet on this street.`, `Checking keeps your hand without adding chips.` | Clear, compact, beginner-safe action-read setup. | Teaches an action rule more than a broad table-read identity. | medium | copy | low | keep_with_watch | Good first-value anchor; next pass should frame it as table reading, not replace it. |
| First runner decision | Make first table choice. | `What action keeps playing for free?` | Fast and concrete. | CTA/action choice is obvious, but the table signal could be emotionally framed more strongly. | medium | copy | low | copy_tune_later | A "read the table first" line may increase aha without route changes. |
| First feedback, correct | Understand why correct. | `Action read improved`, `You used No bet yet before acting.` | Strong proof: choice -> visible signal -> skill receipt -> next rep. | "Action read improved" is clear but may undersell "I understand the table better." | high | copy | low | implement_next | Highest small-EV opportunity: make first receipt feel like table-reading progress. |
| First feedback, wrong | Understand missed signal and repair. | `Good spot to repair`, `The missed signal was No bet yet.` | Strong emotional safety and deterministic repair setup. | Personal repair is promised, but full `Repaired` proof requires taking next route. | medium | repair visibility | low | keep_with_watch | Current wrong path is strong; avoid adding shame or heavy explanations. |
| Home first-value carry | Know what to do next. | `Next: one more action-read rep` or `Repair: Action read`. | Strong same-signal return loop. | Repair specificity is visible, but daily trainer perception could be stronger. | medium | copy | low | copy_tune_later | The row is good; tune only if first feedback copy changes. |
| Home repair checklist row | See personal repair action when open repair exists. | `Repair`, `Repair this signal`. | Strong personal training signal. | This may not appear in every first session because first-value carry uses the primary mission. | low | defer | low | keep | Works as the broader daily repair proof. |
| Review repair item | Understand mistake and start repair rep. | selected/better/reason/context/repair plan + `Start repair rep`. | Strong deterministic trainer perception if reached. | Not naturally part of first few minutes. | low | defer | low | keep | Do not force Review into first session unless actual user research shows confusion. |
| Repaired proof | Feel the loop close. | `Recovered lately`, `Repaired`. | Strong proof after repair completion. | Hidden unless user enters repair loop. | medium | repair visibility | medium | audit_deeper | Later first-session manual QA should decide whether one lightweight repaired proof demo is needed. |

## 6. Top Blockers To First-Session Aha

1. First feedback is specific but slightly narrow.
   - The first actual aha is `No bet yet -> Check`.
   - This is good table-reading behavior, but the product-level feeling may be "I learned check" rather than "I read the table better."

2. Placement route proof is stronger than learning proof before the runner.
   - The result explains where Sharky starts, not exactly what the learner already learned from the quick check.

3. The strongest table-read transfer proof is not guaranteed to be the first emotional receipt.
   - `what_poker_is_table_read_recheck` is the best "same scan, new spot" proof, but the first handoff can begin with action basics.

4. Full personal repair proof is present but not guaranteed in first few minutes.
   - Wrong first-value feedback and Home carry show repair intent.
   - The full `Repaired` proof requires a second action.

5. Runout-style trainer perception remains stronger in packaging.
   - Sharky is more honest and deterministic, but the first session could still sound more like a guided table trainer than a clean quiz flow.

## 7. Top 1-3 Recommended Implementation Arcs

### 1. First Feedback Aha Copy Pass v1

Goal:

Make the first correct/wrong feedback and Home carry express the product-level learning proof:

`You read the table signal before acting.`

Why:

- Highest EV / lowest risk.
- No route or content change required.
- Builds on existing `feedbackSignal/tableSignal`, skill receipt, and same-signal rep.

Guard:

- Keep `feedbackSignal/tableSignal`, telemetry, table highlights, and same-signal launch unchanged.
- Do not add metadata labels like `Skill:` / `Signal:`.
- Do not introduce AI/adaptive or GTO/solver wording.

### 2. Placement Result Learning-Proof Microcopy v1

Goal:

Make placement result bridge the quick check into first hand:

`You just used visible table clues. First hand continues that read.`

Why:

- Increases perceived personalization and payoff before the runner.
- Low risk if limited to copy.

Guard:

- No extra screens, no new route order, no longer intake.
- Keep `Start first hand` direct.

### 3. First-Session Manual Screenshot QA v1

Goal:

Run a manual/screenshot pass across the first-session path to verify perceived pacing and hierarchy on real compact/mobile viewports.

Why:

- Current tests prove behavior and copy, but the remaining risk is perception: whether the first few minutes feel premium and trainer-like.

Guard:

- Audit-only unless a specific copy/pacing blocker is proven.
- Do not reopen table geometry.

## 8. Deferred List

- New onboarding questions.
- New route order.
- Broad Home/Review redesign.
- Skill Map / Leak Profile / dashboard.
- Paywall/trial/commerce.
- Fake AI/adaptive claims.
- GTO/solver/chart framing.
- Table geometry or answer dock geometry.
- New worlds or broad content expansion.
- Forcing Review/Repaired proof into first session before manual evidence supports it.

## 9. Stop Rules For Future Product-Pass Work

Stop a future first-session product pass if any condition is true:

1. The change adds setup friction before the first table decision.
2. The change hides or delays `Start first hand`.
3. The change weakens deterministic table-signal proof.
4. The change introduces AI/adaptive claims not backed by current behavior.
5. The change adds GTO, solver, chart, optimal-frequency, or all-format claims.
6. The change requires table geometry, answer dock geometry, dashboard, paywall, or new scoring.
7. The change makes repair feel punitive instead of useful.
8. The change broadens beyond first-session aha and first repair perception.

## 10. Direction Score

Current first-session aha direction score: 8.2 / 10.

What is strong:

- Fast enough path to a real table decision.
- Excellent beginner safety.
- No paywall before value.
- Clear first feedback signal proof.
- Same-signal Home carry exists.
- Wrong path shows a safe repair-oriented next step.
- Deterministic repair loop now has strong breadth beyond first session.

Why not higher:

- The first emotional receipt is action-read-specific rather than broad table-read-specific.
- Placement proof is more about route selection than learned signal payoff.
- Full `Repaired` proof is not guaranteed in the first few minutes.
- Premium trainer perception still depends on copy hierarchy more than a strong "trainer found and repaired your leak" package.

## 11. Runout / Benchmark-Stack Comparison

This audit uses no new Runout evidence.

Based only on proven current Sharky behavior:

- Sharky is stronger in honest deterministic proof: user choice -> visible signal -> why -> same-signal next rep / repair.
- Sharky is stronger for beginner-safe language and avoiding fake AI/GTO/solver framing.
- Runout remains the benchmark for perceived trainer packaging and "adaptive trainer finds your leaks" presentation from prior accepted audits.

The competitive next move is not to copy Runout's adaptive packaging. It is to make Sharky's first feedback sound unmistakably like table-reading improvement:

`You saw the visible clue, acted from it, and Sharky knows what signal to repeat next.`
