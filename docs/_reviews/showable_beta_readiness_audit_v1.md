# Showable Beta Readiness Audit v1

## 1. Verdict

showable_beta_ready_with_p0_blockers

## 2. Current accepted spine

The accepted first-week repair-learning spine is real and visible:

`mistake -> repair intent -> Review history -> Practice repair queue -> Practice this -> repair target -> source handoff -> repair outcome -> local proof -> Session Summary Fixes you've banked -> Profile evidence / earned moments`

Recent accepted stack:

- Repair Loop Copy / Claim-Safety Pass v1
- TOP1 Product Attack Plan Refresh v2
- Achievement Taxonomy v1 - No Art
- Evidence-Based Skill/RPG Taxonomy Contract v1
- Fixes You've Banked / Proof Home Contract v1
- Session Summary Fixes Banked Label v1 - Local Only

The spine is beta-relevant because it gives Sharky a concrete learning promise:
the user makes one choice, sees the table signal, repairs the miss, and receives
local proof. The remaining problem is product showability around that spine.

## 3. Audit method and evidence used

Evidence used:

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/fixes_youve_banked_proof_home_contract_v1.md`
- `docs/_reviews/session_summary_fixes_banked_label_v1.md`
- Active Act0 shell owners under `lib/ui_v2/act0_shell/`
- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- Screen packet indexes under:
  - `output/screen_review/current/first_week_fast/`
  - `output/screen_review/current/day2_return_fast/`
  - `output/screen_review/current/full_scroll_fast/`

No product code was changed. Existing screenshot packets were present and recent
enough for this audit because they were generated after the Session Summary
label pass and include first-week, day-2 return, and full-scroll surfaces.

## 4. Overall beta-readiness assessment

Sharky is not ready for a showable beta yet, but the gap is now productization,
not repair-loop truth.

The app can explain its core learning loop. It cannot yet be shown to 10-30
real beta users without caveats because several surfaces still read like an
internal preview:

- Practice implies a broader drill system than the visible reps support.
- Review is useful when a repair exists but too empty/thin otherwise.
- Profile shows proof, but still carries RPG-like `Level` presentation and
placeholder-feeling proof cards.
- Learn is coherent but still more like a route list than a finished first-week
journey.
- Session Summary has the right proof label, but the payoff is mostly static
and dense.
- Some dormant/edge copy still uses `fixed` / `recovered` semantics that should
not be beta-visible until resolution ownership exists.

Fastest path to showable beta: stop adding internal contracts and run three
larger implementation waves:

1. Beta Surface Cleanup Wave v1.
2. Drill Readiness Wave v1.
3. First-Week UX / Payoff Wave v1.

## 5. Surface-by-surface findings

| Surface | Finding | beta_blocker_severity | learning_ev | product_feel_ev | implementation_complexity | risk | recommended_priority |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| Home / launch state | Home has a clear next action and can prioritize repair on day 2, but the checklist still exposes system-like progress language and a `Fix this now` CTA that may overpromise resolution. | 3 | 4 | 4 | 2 | 2 | P1 high EV before beta |
| Learn / route | First-week route is coherent and readable. It still feels like a structured path rather than a memorable first-week journey with landmarks and payoff. | 3 | 4 | 4 | 3 | 2 | P1 high EV before beta |
| Practice / drills | Practice is the biggest showability risk. It says `Sharpen your game`, `Quick daily drill`, and `Topic reps`, but several topic categories look thin or disabled, and the system does not yet feel like a complete drill gym. | 5 | 5 | 5 | 3 | 3 | P0 beta blocker |
| Review | Review has the right `One miss to fix` concept when there is an active repair. Clean/empty Review is too sparse and may feel like a dead tab. | 4 | 4 | 4 | 2 | 2 | P1 high EV before beta |
| Session Summary | `Fixes you've banked` is the right local proof label. The screen is still dense and mostly static; payoff exists but does not yet feel like a memorable moment. | 4 | 4 | 5 | 3 | 2 | P1 high EV before beta |
| Profile / You | Profile is proof-oriented, but `Level 1`, XP, streak, `Progress proof`, and skills tiles create RPG/dashboard expectations that the accepted source contracts do not fully support. | 5 | 3 | 5 | 3 | 4 | P0 beta blocker |
| Onboarding / placement | First action is short and the `no exam` tone works. Welcome/handoff is now simpler, but it still needs visual confidence and less card-stack density. | 3 | 4 | 4 | 2 | 2 | P1 high EV before beta |
| Empty / unfinished states | Empty Review, inactive repair, disabled/locked drill packs, and account/settings rows are honest enough for internal QA but not polished enough for external beta. | 5 | 3 | 5 | 2 | 3 | P0 beta blocker |
| Visual / animation / payoff | The UI is consistent, but important beats are static: first good fix, session complete, one miss to fix, and three-day rhythm need a small authored payoff grammar. | 4 | 4 | 5 | 4 | 3 | P1 high EV before beta |
| Content route quality | W1 first-week content is teachable, but drill breadth and term introduction still need a beta-facing pass so the promise does not outrun available reps. | 4 | 5 | 4 | 4 | 3 | P1 high EV before beta |

## 6. Empty/unfinished surface inventory

| Surface/state | Evidence | Problem | Recommendation | Priority |
| --- | --- | --- | --- | --- |
| Practice topic reps | Full-scroll Practice shows topic cards such as Actions, Blinds and ranges, Position, Showdown, plus locked/low-density rows. | Implies broad drill coverage before the drill system feels complete. | Hide disabled/underfilled categories or collapse them behind `More topics coming after beta`; keep only reps that are real and useful. | P0 beta blocker |
| Practice no-active-fix state | Practice can show `No active fixes` / empty repair card. | Honest, but feels like missing functionality if shown prominently. | Keep as secondary context; do not let an empty repair state compete with Quick daily drill. | P1 high EV before beta |
| Review clean state | Screens show `Review` with `One miss to fix` when active; clean state is likely thin. | A beta user may tap Review and find little value if no repair exists. | Add compact honest empty state: what Review is for, how to create a review item, and where to continue. | P1 high EV before beta |
| Profile account/settings row | Profile has `Account & settings` style bottom row. | Can feel like a placeholder app shell if it does not do much. | Hide nonessential settings or keep one small safe row only. | P1 high EV before beta |
| Profile achievements/milestones | Earned moments are real but visually small and sparse. | Feels underpowered compared with the implied `Level` and proof language. | Keep earned moments, but remove unsupported RPG expectation and make the few supported moments feel intentional. | P0 beta blocker |
| Learn locked/future route | Learn route contains locked/next state language. | Fine if honest, risky if it implies a complete 36-world runtime. | Show W1-W4 beta route cleanly; avoid visual breadth that suggests unavailable depth. | P1 high EV before beta |
| Premium preview | `Premium adds later` exists in code. | Commercial copy is out of scope for showable beta unless deliberately scoped. | Keep hidden from first-week beta unless a deliberate beta commercial preview is requested. | defer |

## 7. Drill readiness findings

Practice should be treated as the largest beta blocker because beta users will
expect training depth from a tab named `Practice`.

Current strengths:

- Quick daily drill has a clear CTA.
- Active repair rows can launch the exact repair target.
- `Practice this` connects the repair loop to action.
- Topic reps are visually organized.

Current weaknesses:

- Topic reps look broader than the current content/readiness supports.
- Some groups are disabled or feel like placeholders.
- `0/3 daily spots` communicates count, but not enough training intent.
- Repair queue is useful after a miss but not enough to carry the Practice tab
  alone.
- Practice lacks a visible sense of drill families, progression inside reps,
  or a satisfying completed state.

Beta requirement: Practice should either feel like a small real drill gym or
hide/defer the parts that make it look fake. A narrow honest Practice tab is
better than a broad one that looks underfilled.

## 8. First-week route/content findings

The first-week route is coherent enough to test learning trust, especially
around action reading and repair.

Risks:

- The first-week path relies on W1-style action/seat/table clues; beta users may
  expect more variety if Learn and Practice visually imply a broader course.
- Some terminology is compact but still needs novice-facing repetition:
  `action reading`, `table clue`, `repair`, `one miss to fix`.
- The lesson route is clean, but it does not yet feel authored as a week-long
  arc with start, mid, end, and return motivation.
- W1-W4 can be enough for beta only if the app is explicit that this beta tests
  the first proof loop, not the full 36-world course.

Recommendation: make first-week beta deliberately narrow. Do not expand content
before hiding fake breadth and improving the payoff of the existing loop.

## 9. UX/UI coherence findings

The UI is visually coherent: dark shell, teal/blue/gold accents, consistent
cards, bottom navigation, and compact proof surfaces. It no longer reads like a
raw technical harness.

Remaining issues:

- Too many surfaces use the same card rhythm, so Home, Learn, Practice, Review,
  Profile, and Summary can feel visually samey.
- Session Summary is dense and card-stacked; it proves value but not enough
  emotion.
- Profile looks polished at first glance but has claims (`Level`, XP, skill
  proof) that create expectations beyond current contracts.
- Learn has a lot of route machinery and can feel like a map UI rather than a
  guided beta path.
- Practice needs stronger hierarchy between `daily`, `repair`, and `topics`.

## 10. Visual/dopamine/payoff findings

Necessary beta payoff moments:

| Moment | Current state | Needed beta treatment | Priority |
| --- | --- | --- | --- |
| First correct table read | Exists as feedback and earned moment. | Small visual beat tied to the exact table signal, not generic confetti. | P1 high EV before beta |
| First good fix | Exists through repair outcome and Session Summary. | Stronger `Good fix landed` moment inside feedback/summary with source-safe copy. | P1 high EV before beta |
| Session complete | Summary exists and has `Fixes you've banked`. | Reduce density and add a single hero payoff so the user remembers what improved. | P1 high EV before beta |
| One miss to fix | Exists in Review/Home. | Make it feel like a helpful next step, not a stale correction log. | P1 high EV before beta |
| Three-day rhythm | Exists in Profile/Home. | Keep light; do not add streak pressure. Use only after actual evidence. | P2 after beta |

Do not add generic confetti, fake badges, ratings, or RPG leveling. The payoff
should come from the table signal and repair proof.

## 11. Claim-safety findings

Safe and accepted:

- `Fixes you've banked` in Session Summary only.
- `Good fixes`, `Still to fix`, `Fixes tried`.
- `One miss to fix`.
- `Small wins Sharky can prove`.
- `Practiced: <skill>` / recent proof language when source-backed.

Unsafe or risky before showable beta:

- Profile `Level 1` / XP presentation: reads like RPG leveling, while current
  contracts block skill levels/rating/radar-style systems.
- Profile skill tile icon uses radar-like visual language even though radar is
  blocked as a claim family.
- Review dormant/edge recovered copy includes `Fixed spots` / `Recovered`
  semantics in code paths; do not expose this until resolution ownership exists.
- Learn `Cleared` for completed worlds may be acceptable route language, but do
  not reuse it for repair or Review outcomes.
- Home `Fix this now` is action-oriented, but should be reviewed for resolution
  implication in the Beta Surface Cleanup wave.

## 12. P0 beta blockers

| Issue | beta_blocker_severity | learning_ev | product_feel_ev | implementation_complexity | risk | recommended_priority |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Practice tab implies a fuller drill system than the current visible reps can support. | 5 | 5 | 5 | 3 | 3 | P0 beta blocker |
| Profile still presents `Level` / XP / skill proof in a way that can imply unsupported RPG progression. | 5 | 3 | 5 | 3 | 4 | P0 beta blocker |
| Empty/disabled/underfilled surfaces make the app feel like an internal shell instead of a showable beta. | 5 | 3 | 5 | 2 | 3 | P0 beta blocker |
| Dormant/edge Review recovered/fixed semantics risk violating the no-resolution boundary if surfaced. | 4 | 3 | 4 | 2 | 4 | P0 beta blocker |

P0 means the app should not be shown to real beta users without addressing or
hiding these areas. It does not mean the repair loop is broken.

## 13. P1 high-EV beta polish

| Issue | beta_blocker_severity | learning_ev | product_feel_ev | implementation_complexity | risk | recommended_priority |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Session Summary payoff is source-safe but too dense/static. | 4 | 4 | 5 | 3 | 2 | P1 high EV before beta |
| First good fix / first correct read need a small authored emotional beat. | 4 | 4 | 5 | 4 | 3 | P1 high EV before beta |
| Review clean/empty state needs a useful honest explanation. | 4 | 4 | 4 | 2 | 2 | P1 high EV before beta |
| Learn first-week arc needs stronger week-level framing and landmarks. | 3 | 4 | 4 | 3 | 2 | P1 high EV before beta |
| Home day-2 repair CTA and checklist should be checked for resolution-safe, beta-friendly copy. | 3 | 4 | 4 | 2 | 2 | P1 high EV before beta |
| Onboarding/welcome could use one more density/visual confidence pass. | 3 | 4 | 4 | 2 | 2 | P1 high EV before beta |

## 14. P2/deferred items

- Premium/paywall/trial surfaces.
- Badge art.
- Rating/radar/level systems.
- Durable all-time fixes bank.
- Queue resolution and Review clearing.
- Full RPG profile.
- Share cards/social sharing.
- Modern Table micro-polish unless a specific screenshot blocker appears.
- Full W5+ route/content expansion.
- Runout-style dashboards, analytics, reports, or commercial packaging.
- AI/chat/persona expansion.

## 15. Recommended next 3 implementation waves

### 1. Beta Surface Cleanup Wave v1

Goal: remove fake breadth and unsupported claims before any beta.

Scope:

- Hide/defer underfilled Practice topic categories.
- Keep only real drill/repair surfaces visible.
- Remove or rename Profile `Level` / unsupported RPG-facing copy.
- Hide or reframe empty settings/placeholder rows.
- Ensure Review recovered/fixed semantics are not beta-visible without source
  ownership.
- Keep route/progression/telemetry unchanged.

Why first: this turns the app from internal preview into honest beta surface.

### 2. Drill Readiness Wave v1

Goal: make Practice feel like a small real training system.

Scope:

- Clarify Quick daily drill intent.
- Make repair drill rows and active repair handoff feel like a training lane.
- Collapse topic reps to the strongest supported families.
- Add a clear completed/empty state that feels intentional.
- Avoid new content expansion unless a drill is visibly underfilled and already
  source-safe.

Why second: Practice is the highest-EV tab for beta retention after the first
repair loop.

### 3. First-Week UX / Payoff Wave v1

Goal: make the first loop feel alive and memorable.

Scope:

- Improve Session Summary hierarchy around `Fixes you've banked`.
- Add small source-safe payoff moments for first correct read and first good
  fix.
- Strengthen `one miss to fix` as a friendly next-step story.
- Improve first-week route landmarking without expanding content.
- Use subtle animation only where it reinforces learning proof.

Why third: once the app is honest and the drills feel real, payoff can carry
beta motivation.

## 16. What not to build yet

Do not build:

- dashboards;
- broad Profile RPG;
- rating/radar/levels;
- badge art;
- durable fix bank;
- Review clearing/resolution;
- queue done/remove state;
- premium/paywall/trial;
- content expansion as a substitute for hiding fake breadth;
- Runout-style reports or analytics;
- AI coach/chat;
- Modern Table micro-polish without a concrete beta screenshot blocker.

These are not the fastest path to showable beta. They either violate accepted
guardrails or increase breadth before the visible product feels finished.

## 17. Beta test acceptance checklist

Before showing Sharky to 10-30 beta users:

- Home points to one obvious next action.
- Learn first-week route is coherent and does not imply unavailable breadth.
- Practice shows only real, useful drills or honest empty states.
- Active repair from Review/Home/Practice can be launched and understood.
- Review clean state is useful, not dead.
- Session Summary makes `Fixes you've banked` feel like payoff, not a report.
- Profile shows source-backed proof without unsupported RPG claims.
- No visible `fixed forever`, `cleared repair`, `resolved`, `mastered`,
  `rating`, `radar`, unsupported `level`, `GTO`, `solver`, AI, premium, or
  paywall claims.
- Generated screenshot packets show no obvious truncation/overlap.
- The beta is framed as first-week repair-learning proof, not the full
  36-world course.
- Feedback collection asks about:
  - what the user thought they learned;
  - whether the repair hand made sense;
  - whether Practice felt useful;
  - whether Profile felt motivating or fake;
  - where the app felt unfinished.

## 18. Validation

Validation run:

- `git diff --check` - passed.
- `graphify hook-check` - passed.
- `git status --short` - audit doc only, plus generated output directories.

Screenshot packets were present and used:

- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/full_scroll_fast/`

No generated screenshot artifacts should be committed.
