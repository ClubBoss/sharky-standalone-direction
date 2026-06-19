# First Return / Day 2 Loop Audit v1

Date: 2026-06-18
Mode: Audit-only / docs-only
Scope: Active Act0 first-session and first-return surfaces only.

## 1. Purpose

This audit evaluates whether a new learner who finishes or partially finishes the first Act0 session has a clear reason to return on Day 2.

The target is not a dashboard, streak economy, paywall, or broader retention system. The target is a simple learner belief:

- "I learned one useful table clue."
- "Sharky knows what I should repeat next."
- "Returning tomorrow will make that read easier."

## 2. Current First-Return Path Summary

The current Act0 path already has real return-loop mechanics:

1. Placement routes the learner into the recommended first hand.
2. First correct feedback creates a first-value receipt:
   - `Table read improved`
   - `You noticed No bet yet before choosing an action.`
   - `Next: practice the same table clue once more.`
3. Home carries the receipt into an immediate next rep:
   - `Next: one more action-read rep`
   - `Use No bet yet before the next action.`
   - `Focus: Action read`
4. Wrong first-value feedback carries a repair route:
   - `Repair: Action read`
   - `Try No bet yet once more.`
5. The Home CTA launches the mapped same-signal rep through the existing deterministic target:
   - `actions_check_drill`
   - mapping type `reinforcement` for correct first-value carry
   - mapping type `repair` for wrong first-value carry
6. Home can show a daily checklist after first-value activation.
7. Practice supports a 3-rep daily set and daily progress such as `1/3 daily spots`.
8. Daily completion creates a done-for-today state:
   - `Today complete`
   - `Seat held for tomorrow` / `Tomorrow is set`
   - `Today is banked. One short return tomorrow keeps the rhythm warm.`
9. Review supports repair and fixed-proof:
   - `Recovered lately`
   - `Repaired`
10. Profile contains the clearest explicit Day 2 value language:
   - `Return value`
   - `Returning tomorrow starts warmer because recent clean reps kept this skill live...`

Verdict: the first-return system is real, but the Day 2 reason is distributed. The immediate same-signal next rep is strong; the explicit "come back tomorrow for this reason" contract is strongest after completing a daily set or opening Profile, not immediately after first value.

## 3. Day 2 / Return-Loop Rubric

| Dimension | Current | Target | Verdict |
| --- | ---: | ---: | --- |
| First-value proof | 9/10 | 10/10 | Strong. The learner sees a concrete table clue and a named improvement. |
| Immediate next action | 9/10 | 10/10 | Strong. Home can carry the same signal into a deterministic next rep. |
| Wrong-answer return path | 9/10 | 10/10 | Strong. Wrong first value creates a repair-oriented Home route. |
| Day 2 promise | 6/10 | 9/10 | Present, but mostly after daily completion or in Profile. |
| Home as first-return anchor | 7/10 | 9/10 | Functional, but the first-value Home state prioritizes immediate continuation over tomorrow value. |
| Daily trainer perception | 7/10 | 9/10 | Daily set exists, but first-session handoff into Day 2 could be more explicit. |
| Repair proof as retention reason | 8/10 | 9/10 | Strong for users who repair; not universal for all first-session users. |
| Beginner-safe motivation | 8/10 | 9/10 | Calm and low-pressure; sometimes too subtle about why returning matters. |
| Anti-dashboard simplicity | 9/10 | 9/10 | Good. Current surfaces avoid heavy analytics. |
| Competitive return loop | 7/10 | 9/10 | Sharky has better deterministic proof than generic onboarding, but the Day 2 packaging is not yet as crisp as the proof spine. |

## 4. Surface Audit Table

| Surface | Current evidence | Return-loop job | Strength | Gap | Risk |
| --- | --- | --- | --- | --- | --- |
| First correct feedback | `Table read improved`; `You noticed No bet yet before choosing an action.`; `Next: practice the same table clue once more.` | Prove first learning value. | Very strong first aha. | Next action is same-session oriented, not Day 2 oriented. | Low. |
| First wrong feedback | `Good spot to repair`; `The missed table clue was No bet yet.` | Make mistakes safe and repairable. | Strong repair framing. | Day 2 value only appears if learner proceeds to Home/repair. | Low. |
| Home first-value carry | `Next: one more action-read rep`; `Use No bet yet before the next action.` | Convert first value into one more deterministic rep. | Strongest current return mechanism. | Reads like immediate continuation more than "tomorrow, this is waiting." | Medium. |
| Home wrong first-value carry | `Repair: Action read`; `Try No bet yet once more.` | Convert first miss into a safe repair action. | Clear and actionable. | Repair is useful, but not yet framed as a light Day 2 re-entry reason. | Medium. |
| Home daily checklist | Learn / Practice / Review / Fix rows; repair, recheck, prove jobs. | Give Home a lightweight daily plan. | Good structure without dashboard bloat. | The checklist appears after activation, but the first-return contract is implicit. | Medium. |
| Home daily completion | `Today complete`; `Seat held for tomorrow`; `Tomorrow is set`; `One short return tomorrow keeps the rhythm warm.` | Close the day and make tomorrow feel easy. | Strongest explicit Day 2 copy. | Only appears after 3 daily reps, not after the first-value moment. | Medium. |
| Practice daily set | `Start daily set`; `1/3 daily spots`; `Daily set complete`. | Create a repeatable daily routine. | Functional daily loop exists. | Practice is a later tab, not the obvious Day 2 promise after first session. | Medium. |
| Review open repair | `Start here`; `Fix now`; mistake repair cards. | Give the user a concrete weak spot to fix. | Strong for returning after mistakes. | Not every first-session user has an open repair. | Low. |
| Review repaired proof | `Recovered lately`; `Repaired`; `One spot is already back under control.` | Turn repair into progress proof. | High trust when reached. | Hidden unless the user enters and completes repair. | Low. |
| Profile return value | `Return value`; `Returning tomorrow starts warmer because...` | Explain why consistency matters. | Strong language. | Too deep in Profile to anchor Day 2 for most first-session users. | Medium. |

## 5. Biggest Return-Loop Blockers

1. The Day 2 contract is not attached to the first-value Home state.

   The current first-value Home carry is excellent for immediate continuation. It does not yet say, in one compact line, that this same table clue will be ready tomorrow if the learner returns.

2. The clearest tomorrow language appears after a daily set, not after first value.

   `Seat held for tomorrow`, `Tomorrow is set`, and `One short return tomorrow keeps the rhythm warm` are strong, but they are gated behind the 3-rep daily completion state.

3. Profile has strong return-value language, but Profile is not the first-return surface.

   The Profile copy explains the habit loop well. It should not become the main Day 2 teacher for a brand-new learner.

4. Repair proof is strong but path-dependent.

   `Recovered lately` / `Repaired` is convincing once a mistake is fixed. A correct first-session user may never see that proof.

5. The app has mechanics for retention but not one dominant first-return sentence.

   The product can already route to same-signal reps, repairs, daily sets, and rechecks. The missing piece is hierarchy: what should the learner remember when they close the app?

## 6. Top 1-3 Recommended Implementation Arcs

### Arc 1: Home First-Return Reason Line v1

Highest EV.

Add a small Home copy/proof refinement to the existing first-value carry state. Do not add a new panel, dashboard, streak system, or route. Use existing first-value carry metadata and existing Home mission/checklist hierarchy.

Target behavior:

- Correct first value:
  - Keep `Next: one more action-read rep`.
  - Add or refine one compact support line that makes the Day 2 reason explicit: the same table clue will be waiting for a short return.
- Wrong first value:
  - Keep `Repair: Action read`.
  - Add or refine one compact support line that makes repair feel like an easy first-return job.

Why this is the best next arc:

- It uses existing deterministic first-value carry.
- It does not require new content.
- It does not require screenshots, dashboards, scoring, or route changes.
- It directly closes the biggest Day 2 trust gap.

### Arc 2: Daily Completion Copy Alignment v1

Medium EV.

Align Home daily completion, Practice daily completion, and Sharky done-for-today lines so they all reinforce the same promise:

- today was banked
- tomorrow starts with one short clean rep
- the table clue remains warm

This should be copy-only unless existing atoms make it easier to keep localized copy stable.

### Arc 3: Review Repaired Proof Visibility Tune v1

Medium / deferred.

Review already has good repaired proof. A later small pass can ensure Home or Review does not bury `Recovered lately` after the user fixes a first-session mistake. This is lower priority than Arc 1 because the repaired proof is path-dependent and already functional.

## 7. Deferred List

- No new streak economy.
- No dashboard, Skill Map, or Leak Profile.
- No paywall or trial prompt.
- No new daily challenge system.
- No route-order changes.
- No screenshot-tooling changes.
- No table or answer dock changes.
- No new content families.
- No broad test cleanup.
- No fake AI, GTO, solver, or hyper-personalization claims.

## 8. Stop Rules For Future Return-Loop Work

Stop the wave if it requires:

- new persistent state beyond existing first-value carry / daily progress / repair state;
- new lesson content or task families;
- changing placement routing, task order, scoring, or repair resolver behavior;
- adding a new Home dashboard section;
- moving retention logic into Profile as the first-return anchor;
- visual redesign of Home, Practice, Review, or table geometry;
- monetization, trial, or paywall changes.

## 9. Direction Score

Current direction: 8/10.

Rationale:

- Sharky already has the hard part: deterministic first-value proof and deterministic same-signal next reps.
- The repair queue is credible and emotionally safe.
- Daily set and done-for-today states exist.
- The missing work is not infrastructure; it is first-return hierarchy. The user should leave Session 1 remembering one reason to come back tomorrow.

Target after Arc 1: 8.7/10.

Target after Arc 1 + Arc 2: 9/10.

## 10. Runout / Benchmark-Stack Comparison

Based only on proven current Sharky behavior and previously accepted benchmark direction:

- Runout-style strength: polished packaging, daily framing, and high perceived product maturity.
- Sharky current strength: deterministic table proof, visible same-signal repair/reinforcement, and beginner-safe explanation.
- Sharky current gap: Day 2 packaging is less crisp than the underlying mechanics. The loop exists, but the learner has to infer the return promise from several surfaces.
- Principle to borrow: make the next return feel obvious and lightweight.
- What not to copy: do not use generic habit pressure, broad onboarding polish, paywall framing, or advanced/GTO positioning to cover the gap.

Competitive conclusion:

Sharky does not need a larger retention system next. It needs a small Home-first return contract that binds the existing first-value proof to tomorrow's next short rep.
