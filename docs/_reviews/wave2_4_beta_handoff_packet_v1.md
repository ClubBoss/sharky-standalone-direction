# Wave 2.4 - Beta Handoff Packet v1

Date: 2026-06-26
Base: `origin/main` at `80082e0ec78e36414cf88a4f4391058a33f502c4`
Verdict: `wave2_4_beta_handoff_packet_ready`

## 1. Current Product State

Wave 1 - Alpha / Proof Spine Complete is closed.

Wave 2 - Premium Beta Productization is active and packet-ready for controlled
external review. Waves 2.1, 2.2, and 2.3 are closed:

- Wave 2.1 made local repair proof and Session Summary close read as a payoff.
- Wave 2.2 made the Practice and Session Summary hierarchy read as one calm
  repair story.
- Wave 2.3 made Practice and first-week support copy more confidence-building.

Current first proof loop:

`placement / first route -> table decision -> mistake or correct read -> feedback -> repair focus -> Practice this spot -> repair outcome -> Session Summary proof -> Review / Profile proof`

Narrow beta promise:

Sharky should prove one beginner-safe poker learning loop in the first week:
one decision, one visible table clue, one local explanation, one repair, one
short rep, and one local proof moment.

This packet is for small controlled beta review, not public launch.

## 2. What Beta Testers Should Test

Ask testers to focus on whether the product makes one first-week learning loop
clear without explanation:

1. Can they tell what to do next from Home?
2. Does the first table decision feel readable and not overloaded?
3. Does feedback explain the mistake or correct read through a visible table
   clue?
4. Does the repair focus feel useful instead of punitive?
5. Does `Practice this spot` feel like a valuable next step?
6. Does the repair result / `Fix landed` moment feel rewarding enough?
7. Does Session Summary make progress feel real and local?
8. Do Review and Profile proof surfaces feel honest, not inflated?
9. Does the first-week rhythm feel worth returning to tomorrow?
10. Does any surface feel like an internal shell rather than a beta product?

## 3. What Testers Should Not Evaluate As Missing

These are intentional limitations for this beta scope:

- no broad drill catalog yet;
- no AI coach, chat, or persona system;
- no solver or GTO trainer claim;
- no public premium/paywall route;
- no rating, radar, or level-as-proof system;
- no durable all-time repair history;
- no full W5-W36 content breadth;
- no final App Store / public monetization packaging;
- no Modern Table redesign or micro-polish pass.

Missing these should not be scored as beta blockers unless the current narrow
promise becomes confusing without them.

## 4. Claim-Safety Statement

Current beta promise:

- first-week table-signal learning;
- one decision;
- one local explanation;
- one repair;
- one short rep;
- one local proof moment.

Do not describe Sharky as proving:

- a leak is fixed;
- mastery;
- GTO or solver correctness;
- AI personalization;
- long-term performance improvement;
- all-time analytics;
- premium value readiness.

Acceptable language should stay local and deterministic: the user noticed or
missed a table clue, repeated it once, and saw a local proof moment.

## 5. Suggested Tester Script

Use this script for a 10-15 minute small-beta session:

1. Start from first route / Home.
2. Follow the primary Home action.
3. Complete one table decision.
4. Make or observe one mistake or one correct read.
5. Read the feedback and say what table clue mattered.
6. Follow the repair focus.
7. Use `Practice this spot`.
8. Complete the short repair rep.
9. Reach Session Summary and read the proof / next step.
10. Open Review and Profile if they are visible in the flow.
11. Answer the feedback questions below.

The tester should narrate confusion in the moment. Do not explain the product
before they try the loop.

## 6. Feedback Collection Questions

### Clarity

1. On Home, did you know what to do next without help?
2. On the table, did you understand the decision you were making?
3. Did the feedback explain the table clue in plain language?

### Trust

4. Did any wording feel exaggerated, fake, or too game-like?
5. Did Review or Profile feel honest about what Sharky knows so far?

### Payoff

6. Did the repair result or Session Summary feel like real progress?
7. Was the end of the session memorable enough to make the loop feel complete?

### Practice Usefulness

8. Did `Practice this spot` feel worth tapping?
9. Did the short rep feel connected to the mistake or table clue?

### First-Week Confidence

10. After the loop, did you feel clearer about one real poker decision?
11. Would you come back tomorrow for one more short rep?

### Claim Safety

12. Did the app imply mastery, solver correctness, AI magic, a permanent fix,
    ratings, radar, or paywall value before earning trust?

## 7. Known Limitations And Caveats

- Generated output folders may exist locally under `output/`, but they are not
  committed.
- Screenshot packets are local-only artifacts and should not be treated as
  source truth.
- `docs/_reviews/current_agent_context_v1.md` is absent in this checkout; the
  active handoff uses the Wave 2.1-2.3 review artifacts instead.
- This beta scope is for 10-30 controlled external reviewers, not public launch.
- Premium/paywall packaging is deferred.
- Review clean-state rider remains deferred unless later evidence elevates it.
- Queue resolution, Review clearing, durable all-time repair history, and broad
  drill/catalog depth remain intentionally out of scope.
- `TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` still contains older active-wave header
  wording, but the Wave 2.1-2.3 closure artifacts and this prompt define the
  current handoff state.

## 8. Validation Summary

Recent accepted validation includes:

- Wave 2.1: focused repair outcome, repair intent, and Session Summary tests;
  `flutter analyze`; `git diff --check`; `graphify hook-check`.
- Wave 2.2: focused Practice ordering and Session Summary ordering tests;
  affected Play / Session Summary / preview slices; `flutter analyze`;
  `git diff --check`; `graphify hook-check`; day2_return screenshot proof.
- Wave 2.3: focused Practice tests and first-week preview slices; touched-file
  format check; `flutter analyze`; `git diff --check`; `graphify hook-check`.

Fresh validation for this docs-only handoff wave:

- `git diff --check`
- `git status --short`
- `graphify hook-check`

No Flutter tests were run in this wave because no product code changed.

## 9. Screenshot Packet Status

Screenshots were not regenerated in this wave.

Reason: the prompt default is not to regenerate screenshots, this handoff is a
docs packet, and no product/layout contradiction was found.

Latest local packet paths currently present:

- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/full_scroll_fast/`

Caution: these are local-only generated artifacts. They should be refreshed
before Claude review if the reviewer needs exact post-Wave-2.3 visuals rather
than directional current packet evidence.

Smallest refresh command if needed:

```bash
./tools/screen_review_fast_v1.sh day2_return compact
```

Add `first_week compact` only if first-week proof needs fresh visual evidence.
Add `full_scroll compact` only if broad surface proof is required.

## 10. Claude Visual/UX Challenger Prompt

```text
Sharky Poker / Poker Analyzer - Claude Visual/UX Challenger Prompt

Task:
Review Sharky's current small-beta readiness. Decide whether Sharky can proceed
to 10-30 controlled beta testers, or whether one concrete P0/P1 blocker must be
fixed first.

Use these local screenshot packet paths if they are available and freshly
regenerated for the current commit:
- output/screen_review/current/day2_return_fast/
- output/screen_review/current/first_week_fast/
- output/screen_review/current/full_scroll_fast/

If the packets are stale, ask for refreshed packets before making visual
judgments. Do not treat generated screenshots as source truth; use them as UX
evidence only.

Product promise:
Sharky should prove one beginner-safe poker learning loop:
choice -> table signal -> local explanation -> repair focus -> Practice this
spot -> short rep -> local proof.

Evaluate:
1. Can a new beta user understand what to do without explanation?
2. Does the first table decision feel clear?
3. Does feedback explain the mistake or correct read through the table?
4. Does repair focus feel useful and emotionally light?
5. Does Practice feel valuable as a narrow short-rep surface?
6. Does repair result / Session Summary create enough payoff?
7. Do Review and Profile feel honest, not fake-RPG?
8. Does any copy overclaim AI, GTO/solver correctness, mastery, permanent fix,
   all-time analytics, rating/radar/level proof, or premium value?
9. Does the first-week rhythm feel worth returning to?

Do not recommend:
- broad drill engine;
- W5-W36 expansion;
- AI coach/chat/persona;
- premium/paywall route;
- Modern Table redesign or micro-polish;
- badge art;
- rating/radar/level systems;
- durable all-time repair history;
- Runout/Duolingo copying.

Return:
- verdict: proceed_to_small_beta, proceed_after_one_p1, or blocked_p0;
- surface-by-surface notes;
- any P0 blockers;
- top 3 P1 polish items, if any;
- whether Sharky can proceed to small beta after at most one polish PR.
```

## 11. Next Recommendation

Proceed to Claude visual/UX challenger first.

If Claude finds no P0 and at most one concrete P1, prepare the small beta tester
packet. If Claude finds a concrete P0/P1 contradiction in the actual current
UI, fix that single blocker in a bounded follow-up wave before inviting testers.
