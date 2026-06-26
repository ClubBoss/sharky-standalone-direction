# TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1

Status: ACTIVE strategy SSOT for top-1 product attack planning.
Date: 2026-06-18
Last refreshed: 2026-06-26 after Repair Loop Copy / Claim-Safety Pass v1
landed on `main` at `a92bbdd7`.
Current active candidate: Achievement Taxonomy v1 - No Art.
Next strategic contract after that: Evidence-Based Skill/RPG Taxonomy Contract
v1.

Authority note:

- `docs/plan/MASTER_PLAN_v3.0.md` remains the day-to-day product priority
  authority.
- This document is the active top-1 product attack planning SSOT.
- If there is a conflict, `MASTER_PLAN_v3.0.md`,
  `docs/plan/MONETIZATION_SSOT_v1.md`, and active route truth win.
- This document constrains product attack direction; it does not replace the
  Master Plan.

## Post-Repair Loop Copy status (2026-06-26)

The deterministic learning-causality loop is now visible across the core
first-week repair path:

`mistake -> repair intent -> Review history -> Practice repair queue -> Practice this -> repair target -> source handoff -> repair outcome -> local proof -> Session Summary repair receipt -> Profile evidence / earned moments`

Repair Loop Copy / Claim-Safety Pass v1 is closed by `a92bbdd7`. The loop now
uses learner-safe fix language instead of implementation vocabulary:

- `Fix attempt`
- `You gave the fix a try.`
- `Nice - you chose the better action.`
- `Not fixed yet - one more.`
- `Fix attempts`
- `Good fixes`
- `Still to fix`
- `Fixes tried`
- `What to fix next`
- `Cleared a fix`
- `One miss to fix`

Profile skill claims are now evidence-safe:

- `Skill snapshot`, `Lv N`, and unitless `+N` skill claims are gated away from
  the learner-facing Profile copy.
- Profile uses practiced/proof language such as `Skills practiced`,
  `Recent proof from this route.`, and `Practiced: <skill>`.
- Exact badge count copy was removed from Profile proof and replaced with
  `Small wins Sharky can prove`.

Current proof lanes:

```bash
./tools/screen_review_fast_v1.sh first_week compact
./tools/screen_review_fast_v1.sh day2_return compact
./tools/screen_review_fast_v1.sh full_scroll compact
```

Completed repair-loop stack now accepted on `main`:

- Review mistake history contract, projection, write integration, and
  read-only consumer.
- Profile evidence projection, consumer, and capture.
- Achievement seed contract, projection, and consumer.
- Profile earned moments.
- Session Summary earned moment.
- Practice repair queue projection and consumer.
- Practice active-repair row CTA.
- Practice queue target launch audit.
- Practice queue repair source handoff.
- Repair outcome projection.
- Local repair proof.
- Session Summary repair outcome receipt.
- Repair Loop Copy / Claim-Safety Pass v1.

Claude Repair Loop UX Audit v1 implication:

- The loop was real and visible, but pre-copy language read too much like
  plumbing.
- Family A, repair-loop copy / clarity / claim-safety, was the highest-EV fix
  and is now closed by `a92bbdd7`.
- Remaining product implications are taxonomy and proof cohesion, not art or
  abstract RPG surfaces.

Next candidate: `Achievement Taxonomy v1 - No Art`. The goal is to define what
Sharky may truthfully award, group, and name before committing badge art,
ratings, levels, radar charts, or premium packaging.

Optional next external review: a Claude/Gemini post-copy visual or UX recheck
may be useful after this refresh, but it is not the active bottleneck.

Sharky Character expansion, Welcome/Placement expansion, commerce,
stamina/energy, Modern Table polish, rating/radar/level systems, badge art, and
monetization remain deferred unless concrete evidence reopens them as the
active bottleneck. Generated screenshot and audit outputs remain local-only and
must not be committed.

## 1. Mission

Sharky is the best first-value poker coach: one real spot, one answer, one
clear why.

The user should feel within 2-3 minutes:

> I read the table better.

Sharky is not trying to be only a trainer, only a course, only a GTO app, or a
Runout clone. The top-1 path is to prove learning value on the table before
asking for deeper trust.

10/10 interpretation:

Sharky reaches `10 / 10` when the learner can feel in one session:

`I made a mistake -> Sharky showed the table signal -> I repaired it -> I can do it better now.`

This is deterministic table-signal coaching, not AI magic.

Core positioning:

- Runout sells the idea of improvement.
- Sharky proves improvement before asking for trust.

## 2. Enemy Benchmark

Runout is the current competitive packaging benchmark from local reference
evidence. Use it as a principle benchmark only. Do not copy Runout assets,
text, layouts, video treatment, icons, charts, typography, paywall composition,
or proprietary structure.

### Runout strengths

- Commercial packaging: branded visual system, premium backgrounds, charts,
  paywall media, and serious product framing.
- Onboarding and paywall ceremony: authored start, calibration feel, premium
  upgrade surfaces, and subscription confidence.
- Subscription infrastructure: billing, trial/discount/paywall token families,
  analytics, notifications, and retention scaffolding.
- Motion and premium feel: video, navigation/bottom-sheet motion, polished
  backgrounds, and poker-specific visual assets.
- Analytics and progress theatre: reports, charts, skill mastery, profile,
  tracker, session history, and mistake/winner motifs.
- Feature breadth: trainer, skills, reference/library, hand tracker, history,
  reports, and broad improvement system framing.

### Runout weaknesses

- Real value proof before paywall can be weaker than the commercial promise.
- Personalization can feel black-box if calibration does not visibly explain
  how answers changed the route.
- Feedback can become generic if it is not tied to a concrete visible table
  signal.
- Hard paywall or trial pressure can create beginner trust risk.
- Analytics breadth can become dashboard proof before the learner has actually
  improved.
- Advanced/GTO-feeling packaging can be less beginner-safe than a table-first
  coach.

## 2A. Runout XAPK Static Benchmark Addendum

### Analysis boundary

This addendum comes from a static XAPK benchmark pass, not a live UX run. It
should inform product direction, but it does not override
`docs/plan/MASTER_PLAN_v3.0.md`, `docs/plan/MONETIZATION_SSOT_v1.md`, active
route truth, or the current next wave.

No Runout XAPK/APK binary, extracted asset, layout, chart, icon, text, paywall
structure, or proprietary structure belongs in this repo.

### What Runout appears to be

Static evidence from `Runout+Poker+Trainer+GTO+Coach_1.1.6_APKPure.xapk`
indicates:

- package identity appears to be `com.gramercy.runout`;
- version appears to be `1.1.6`;
- React Native / Hermes bundle evidence is present;
- billing, subscription, and paywall infrastructure evidence is present;
- notifications and retention infrastructure evidence is present;
- analytics, reliability, and tracking stack evidence is present;
- progress, report, chart, tracker, skills, reference, and glossary-like
  assets/strings are present;
- onboarding, calibration, and trainer-construction style evidence is present.

Runout therefore appears to be a complete commercial poker improvement
ecosystem, not only a quiz or trainer. It appears to combine
onboarding/calibration, drills, skills/mastery, reports/charts/progress,
tracker/history/reference surfaces, subscriptions/paywall,
notifications/retention, and analytics/reliability infrastructure.

This confirms Runout's strongest advantage is perceived completeness and
commercial packaging.

### What Sharky should learn

- Do not copy Runout artifacts.
- Do not chase breadth before first proof.
- Sharky should beat Runout through auditable learning causality:
  `choice -> table signal -> why -> repair -> proof`
- The immediate attack remains one-session repair proof, not dashboard breadth.

### Confirmed product implications

- Visible personalization: the next wave must show missed signal, selected
  repair hand, and repair reason.
- Progress theatre: do not build a dashboard now; first create compact proof
  through Repair Result Receipt and Session Repair Summary.
- Onboarding/calibration: future Welcome/Placement work should connect directly
  to first repair proof; do not add a long calibration loop now.
- Content/reference/glossary: future content-depth or glossary work is high-EV
  only after visible repair proof.
- Monetization: Runout's paywall/subscription maturity is a later packaging
  battle; Sharky must keep value before paywall.
- Retention: future habit and return reasons should come from real
  missed/repaired signals, not streak guilt or random notifications.
- Visual/premium packaging: later visual uplift should support repair feedback
  rhythm, result ceremony, or proof packet; do not reopen Modern Table
  micro-polish now.

### Route impact

- No immediate route change.
- No score inflation.
- Content depth remains important, but the post-copy bottleneck is taxonomy and
  claim safety before broad expansion.
- No monetization acceleration.
- No Modern Table reopening.
- Current next wave: `Achievement Taxonomy v1 - No Art`, followed by
  `Evidence-Based Skill/RPG Taxonomy Contract v1`.
- Commercial Screenshot / Renderer Acceptance and Content Depth / Term
  Introduction / Drill Coverage Audit move to later/optional slots unless fresh
  evidence makes them the active bottleneck.

### When to revisit Runout deeply again

Revisit Runout deeply only for:

- App Store / Premium Packaging Arc;
- Premium/paywall/trial design;
- Analytics / Leak Profile Lite;
- final commercial proof packet;
- live UX benchmark if screenshots, video, or user walkthrough evidence is
  available.

## 2B. Runout RPG / Analytics Benchmark Implications

Runout's visible advantage remains perceived completeness. The benchmark
screens show a product that packages poker improvement through categories,
rating, radar, session delta, difficulty, streak/flame, daily training, past
sessions, and concept mastery.

Observed benchmark structures include:

- Total / Cash Game / Tournament tabs.
- Type metrics: H-SCN, H-SEL, THEORY, PMATH.
- Street performance: Preflop, Flop, Turn, River.
- Format: Live, Online.
- Position: In position, Out of position.
- Preflop pot: SRP, 3-BET, 4-BET, LIMP.
- Pot participant type: HU, MW.
- Stack depth: Short, Standard, Deep.
- Concept Mastery: Preflop, Betting, Defense, Math, Hand Read, Positional,
  Tournament.
- Poker rating, session delta, streak/flame, difficulty, Recalibrate Trainer,
  skill radar, daily training, and past sessions.

Strategic interpretation:

- Sharky should use this as future taxonomy input only.
- Do not copy Runout layout, assets, category names as a system, copy, radar
  composition, or rating presentation.
- No Sharky rating, radar, level system, or broad analytics theatre should ship
  until an evidence-backed skill contract exists.
- Achievement readiness is currently taxonomy-only. Badge/icon art is later.

Future RPG path:

`Evidence stats -> Skill taxonomy -> Achievement taxonomy -> Skill levels/rating contract -> RPG profile / badges / visual system -> premium/commercial packaging`

## 3. Sharky Win Condition

Sharky wins by making learning causality visible:

`user choice -> visible table signal -> clear why -> repair or transfer`

`mistake -> error type -> repair decision -> next useful hand -> repair result -> session proof`

This is Sharky's answer to Runout's "AI finds leaks and fixes them"
perception. Sharky must beat that promise by making the cause visible and
auditable, not by claiming black-box AI or adaptivity.

The required advantages:

- honest value before paywall;
- deterministic table-signal feedback;
- repair loop from real mistakes;
- rule-based causal personalization;
- beginner-safe first-value path;
- premium depth that genuinely improves learning;
- trust-safe monetization.

The product should never imply "AI" or "adaptive" magic unless the app can show
the rule, signal, or route cause that created the recommendation.

## 4. Current Accepted State

### 4.1 Commercial / monetization accepted state

- First-week commercial proof is accepted around `9.0 / 10`.
- Premium Value Preview Surface v1 is implemented.
- Compact English Premium Preview Proof v1 is accepted around `9.2 / 10`.
- Premium preview appears after completed daily/session value.
- `Practice extra reps` remains the dominant learning/free action.
- `See what premium adds` remains secondary.
- Preview is boundary-neutral and commerce-safe.
- No public price, purchase, trial start, restore, Premium Hub, entitlement
  change, or route gating is exposed by the preview.

Current launch monetization and route truth:

- `W1-W4` are the free public foundation.
- `W5+` is the future paid-depth boundary.
- W4 is a future challenger / A-B candidate, not the launch-default gate.
- W3 is not a launch-default paid gate.
- Public commerce remains blocked until receipt, restore, entitlement, and
  subscription-copy safety are production-ready.
- Route truth is locked by `docs/plan/MONETIZATION_SSOT_v1.md`.

Active launch route labels for monetization and commercial planning:

| World | Launch-facing title |
| --- | --- |
| W1 | Poker from Zero |
| W2 | Hand Discipline |
| W3 | Position Thinking |
| W4 | Preflop Framework |
| W5 | Bet Purpose + Price |
| W6 | Board and Draws |

Older authored/content docs that describe W4/W5 differently are secondary for
monetization work until a dedicated route-normalization wave.

### 4.2 Technical / infrastructure accepted state

- Backup extraction is effectively complete for now.
- PR #1-#5 restored the clean foundation:
  - Act0 / repair / broad preview recovery;
  - monetization entitlement safety;
  - capture proof tooling source;
  - SSOT route / monetization docs;
  - CI workflow hygiene.
- `main` is green.
- Infrastructure cleanup is stopped unless a real blocker appears.
- TestSprite remains external/non-blocking unless repo policy changes.
- `external_competitors/` remains ignored/local and not part of product scope.

### 4.3 AI Personalization / Repair accepted state

- Decision contract: DONE via `Act0RuleBasedRepairDecisionV1`.
- Builder: DONE via `buildAct0RuleBasedRepairDecisionV1(...)`.
- Runtime consumption: DONE via the existing Act0 next-useful-hand / reason
  receipt seam.
- Telemetry truth: DONE for deterministic local `user_choice` before
  `task_result`.
- Required local payload now includes:
  - `schemaVersion`
  - `worldId`
  - `lessonId`
  - `taskId`
  - `choiceId`
  - `decisionTimeBucket`
  - `attemptOrdinal`
- Existing `task_result`, repair telemetry, and local sink ownership are
  preserved.
- No network telemetry, duplicate telemetry owner, UI copy, route, commerce,
  AI/ML, table geometry, workflow, or Modern Table changes were introduced by
  the foundation.

### 4.4 Current strategic score

Scores are product-strategy estimates from current local proof, not measured
cohort data.

Internal architecture / product logic:

- Architecture / Product Logic: `9.5-9.7`.
- Learning Loop: `9.1-9.3`.
- Trust: `9.6-9.8`.

External commercial / product packaging:

- First-week Product Feel: `8.8-9.1`.
- Commercial / Runout-level Packaging: `8.1-8.4`.
- Top-1 Readiness overall: `8.7-9.0`.

The remaining gap is not whether the repair loop exists. It does.

The remaining gap is whether Sharky can package that proof into truthful,
commercially legible systems without jumping to fake ratings, fake levels, badge
art, or broad analytics theatre before the evidence contracts are defined.

Current active bottleneck:

`evidence-safe repair proof -> achievement taxonomy -> skill/RPG taxonomy -> proof home -> explicit queue/review resolution contracts -> visual badge system -> commercial packaging`

## 5. Target Scorecard

Scores are directional product-strategy estimates from current proof and local
competitive reference evidence. They are not measured cohort data.

| Dimension | Sharky current | Runout benchmark | Sharky target | Delta needed |
| --- | ---: | ---: | ---: | --- |
| First promise | 9.1 | 9.2 | 9.7 | Keep the first personal mistake/repair moment visible without slipping back into plumbing copy. |
| First value before paywall | 9.3 | 7.4 | 9.8 | Preserve value-first route; do not introduce commerce before repair value is visible. |
| Beginner safety | 9.1 | 7.2 | 9.7 | Keep poker-native without GTO/solver pressure. |
| Visual premium feel | 8.5 | 9.3 | 9.5 | Maintain current table quality; future visual uplift must serve repair feedback rhythm, result ceremony, or first-week proof, not table micro-polish. |
| Runner/table learning UX | 9.2 | 8.5 | 9.7 | Keep repair reason and fix attempt proof visible at the existing table/feedback seam without adding UI bloat. |
| Onboarding/induction | 8.7 | 9.2 | 9.5 | Keep short, authored, and causally personal. |
| Personalization credibility | 9.2 | 7.8 | 9.6 | Preserve visible repair cause: missed signal -> selected repair hand -> reason -> outcome. |
| Feedback quality | 9.4 | 7.9 | 9.8 | Keep mistake -> repair -> fix attempt -> receipt copy clear and emotionally light. |
| Progress/skill map | 8.7 | 9.0 | 9.4 | Profile evidence is safer now; next gap is taxonomy before levels, ratings, or radar. |
| Retention loop | 9.0 | 8.8 | 9.5 | Use real repaired/missed signals for next useful rep, return reason, and session proof. |
| Monetization readiness | 8.7 | 9.2 | 9.4 | Keep premium/value packaging after visible learning proof; do not launch public commerce yet. |
| Trust | 9.7 | 7.6 | 9.8 | Protect value-first, free foundation, no fake claims, and evidence-safe Profile copy. |
| Motion/animation | 7.2 | 9.0 | 9.2 | Animate table causality later; avoid generic celebration. |
| Technical determinism | 9.6 | 7.0 | 9.8 | Keep every repair recommendation auditable through decision, receipt, and telemetry fields. |
| Feature breadth | 7.8 | 9.1 | 9.3 | Add breadth only after first-value and habit loops remain clear. |
| Product coherence | 9.1 | 8.8 | 9.7 | Align table feedback, repair reason, Review, Practice queue, Session Summary, and Profile around one causal rhythm. |

Do not raise commercial proof or external readiness from internal contract
success alone. Keep dual scoring: Architecture / Product Logic versus
Commercial Proof / External Readiness.

## 5A. 10/10 Operating Map By Product Block

| Product block | Where Sharky is now | What 10/10/top-1 looks like | Remaining gap | Next action | Acceptance signal | Not-now guardrail |
| --- | --- | --- | --- | --- | --- | --- |
| A. Foundation / deterministic app | Act0 route, repair foundation, monetization docs, capture tooling, and CI are stable enough for product work. | The app reliably turns one learner action into a clear table lesson without route or infra noise. | Foundation is not the bottleneck; visible EV is. | Stop foundation cleanup unless a real blocker appears. | Product waves can start from green `main` and pass R5 without scope repair. | No more backup mining or workflow cleanup as product work. |
| B. AI personalization / repair | Decision contract, runtime reason receipt, visible repair reason, repair result, session repair, Day 2 return proof, Practice queue launch, source handoff, outcome proof, receipt, and copy safety are done. | The learner sees the missed signal, why the next hand was chosen, whether the fix attempt worked, and why return starts there. | The loop now needs taxonomy/proof cohesion before RPG packaging. | Run Achievement Taxonomy v1 - No Art. | Sharky can name earned moments without fake mastery, fake levels, or badge-art commitments. | No AI/adaptive claims, no coach/chat, no new route. |
| C. Learning effect | Feedback and repair proof now show the complete mistake -> repair -> return loop in learner-safe copy. | In one session and on return the learner can say: I missed this clue, tried the fix, and know what to do next. | Skill and achievement language needs source-backed taxonomy before it can become RPG/progress packaging. | Run Evidence-Based Skill/RPG Taxonomy Contract v1 after achievement taxonomy. | Skill labels, earned moments, and future levels are tied to explicit evidence sources. | No fake mastery, unitless score, level, rating, or guaranteed improvement claims. |
| D. First-week commercial readiness | First-week, Day 2, and full-scroll packets exist; premium preview is safe and post-value. | First week plus first return contain a compact proof arc strong enough to support later premium packaging. | Commercial packaging is still behind Runout until proof is organized into truthful taxonomy and visual systems. | Treat any post-copy visual/Claude recheck as optional; do taxonomy first. | Screenshots/contact sheets can be reviewed without explaining internals, but they do not yet justify ratings/radar/paywall. | No paywall-first story, trial before repair proof, rating/radar, or badge art before taxonomy. |
| E. UX/UI sequencing | Home, table, Review, and Play are coherent, but repair causality is still partly internal. | The user always knows what to do, why it matters, and what improved. | Next useful hand needs visible causal context. | Use existing reason slots before adding surfaces. | No added route; current flow explains next useful hand. | No broad UI expansion or dashboard. |
| F. Activation / Welcome / Placement | Placement works and remains value-first; density risk exists but is not the active blocker. | Activation feels short, personal, and immediately connected to first repair value. | Welcome/placement simplification may help, but not before visible repair loop. | Defer until repair proof exists. | Later audit can show onboarding is blocking visible value. | Do not reopen placement before repair surface. |
| G. Review / Home / re-entry | Review and Home can route repairs and return reasons from real state. | Re-entry starts from the learner's real missed/repaired signal, not generic practice. | Return reason needs repair-outcome evidence. | Feed repaired/missed outcomes into summary and return copy later. | Home/Review can say why this rep matters without generic encouragement. | No streak pressure or random daily churn. |
| H. Visual / Modern Table / feedback rhythm | Modern Table quality is good enough; visual work is maintenance-only. | Visuals serve repair causality, result ceremony, and first-week proof. | Feedback rhythm may need visual support after reason/outcome exists. | Leave table visuals untouched unless feedback proof needs it. | Any visual change directly improves repair understanding or proof. | No table micro-polish, screenshot-driven design loops, or motion for its own sake. |
| I. Content density / curriculum depth | Current route has enough spine for first value; taxonomy now matters before broad content or RPG packaging. | Each key concept has enough examples, spaced repair, no unexplained jargon, and evidence-backed progress naming. | W5-W36 depth may still be structurally weak for a W5+ premium boundary, but it is not the immediate post-copy bottleneck. | Defer content-depth audit behind achievement/skill taxonomy unless fresh evidence says content is blocking proof. | Audit identifies exact concepts needing examples, term sequencing, or spaced reps. | No broad expansion before the audit names the gaps. |
| J. Telemetry / learning loop | Local `user_choice` and decision-time bucket are aligned; `task_result` and repair events remain owned by existing seams. | Telemetry supports auditable learning-loop truth and session proof without owning product state. | Repair outcomes are not yet linked into session proof. | Add outcome receipts before new telemetry contracts. | Session proof can be derived from stable local fields. | No network telemetry, vendor SDK, or telemetry-owned personalization state. |
| K. Monetization / premium value | Entitlement safety exists; public commerce remains blocked; premium preview is post-value. | Premium feels like deeper proven learning, not a hostage paywall. | Premium/value packaging needs visible learning proof first. | Keep premium/value packaging after proof packet. | Upgrade framing can point to real repair value already experienced. | No public price, purchase, trial, restore, Premium Hub, or route gate. |
| L. Retention / habit loop | Daily/review loops exist and can use real repair signals. | Return reason comes from real missed/repaired signals, not streak pressure. | The repaired-signal history is not yet summarized into habit copy. | Build session summary before habit expansion. | D2/D7 return can reference a real skill or clue. | No guilt, fake scarcity, or random retention prompts. |
| M. Proof packet / commercial evidence | Capture tooling source exists; generated outputs stay out by default. | Compact evidence shows first decision -> mistake -> repair -> success -> summary. | Proof packet awaits visible reason and result receipt. | Build proof packet after summary. | One compact flow can be captured without explaining internals. | No generated outputs committed by default; no copied Runout assets. |
| N. Product coherence / brand promise | Mission is clear: one real spot, one answer, one clear why. | Every major beat repeats the same causal rhythm: choice -> clue -> why -> repair -> proof. | Some state is auditable internally but not yet experienced as one story. | Align repair reason, Review, Home, and summary around the same language. | Learner-facing surfaces do not contradict or dilute the causal rhythm. | No new competing roadmap or broad brand rewrite. |
| O. Technical delivery / CI | R5, health, and verify are green; TestSprite is external/non-blocking unless policy changes. | Delivery stays boring: one homogeneous branch, local checks, PR checks, merge. | None unless a real blocker appears. | Continue clean-scope PR cycle. | Docs/product branches merge with repo-owned checks green. | No infrastructure cleanup unless a real blocker appears. |

The shortest path is not more foundation, not more CI, and not commerce-first.

The shortest path is:

1. Achievement Taxonomy v1 - No Art
2. Evidence-Based Skill/RPG Taxonomy Contract v1
3. Fixes You've Banked / Proof Home Contract v1
4. Queue Resolution Contract v1
5. Review Resolution Contract v1
6. Badge/Icon Visual System
7. Commercial Packaging / Premium Arc

Optional post-copy visual/Claude recheck is allowed after the latest packets are
ready, but it is not the active bottleneck.

## 5B. 10/10 Acceptance Gates

| Gate | Accepted when | Must prove | Must not do |
| --- | --- | --- | --- |
| 1. Visible Repair Reason Surface gate | CLOSED. The existing Act0 flow shows the missed table signal, selected repair hand, and deterministic reason in a safe current surface. | The learner can understand why this next hand is useful without seeing internal payloads. | No new route, no broad UI expansion, no AI/adaptive claim, no new telemetry owner. |
| 2. Repair Outcome / Receipt gate | CLOSED. A repair attempt produces compact local proof and Session Summary receipt copy. | The app can show whether the learner gave the fix a try, chose the better action, or still has one more attempt. | No fake mastery, no streak pressure, no dashboard, no unowned fixed/cleared/resolved semantics. |
| 3. Practice Queue Launch gate | CLOSED. Active repair rows can expose `Practice this` and launch the expected target through the existing Act0 path. | Practice can start the currently active repair rep without inventing a new route family. | No history-row launch, no queue removal, no progression mutation, no telemetry change. |
| 4. Profile Evidence / Earned Moment gate | CLOSED for projection/consumer/capture and copy safety. | Profile can show recent proof and earned moments without numeric skill or badge-count overclaim. | No fake skill levels, unitless +N skill scores, rating, radar, or badge art. |
| 5. Achievement Taxonomy gate | Active next. Define what Sharky may truthfully award and group before art. | Earned moments have names, categories, and evidence requirements that do not imply fake mastery. | No badge/icon visual system before taxonomy; no commercial packaging based on undefined awards. |
| 6. Evidence-Based Skill/RPG Taxonomy gate | Next contract. Define which evidence can support skill families, future levels, ratings, or RPG profile packaging. | Any future level/rating/progress copy has a cited source and threshold. | No abstract levels, radar, poker rating, or Runout-style analytics theatre before evidence contract. |
| 7. Queue / Review Resolution gates | Future explicit contracts. Decide when a queue item or Review note may be removed, cleared, or resolved. | Resolution semantics are source-owned and auditable. | No queue/Review resolution before explicit resolution contract. |
| 8. Premium/value packaging gate | Later. Premium copy can point to already experienced repair value and deeper learning. | Upgrade feels like more proven coaching, not basic usefulness being withheld. | No public price, purchase, trial, restore, Premium Hub, or hard gate until commerce safety and copy safety are admitted. |

### 5C. Full Surface 10/10 UX/UI Coherence Gate

After Compact First-Week Proof Packet v1, the next product blocker is
full-surface coherence across Home, Learn, Practice, Review, You,
result/feedback, repair receipt, session summary, premium/value, onboarding,
placement, and welcome.

This gate blocks top-1, 10/10 UX/UI, commercial publish readiness, and App Store
packaging claims until resolved.

Operating constraints:

- audit/spec first, implementation later;
- pills, chips, badges, and status tags are not final by default and must be
  researched against top-1 design quality;
- redesign/rethink is allowed when an existing surface cannot reach the job
  through polish;
- Modern Table remains maintenance mode;
- visual work is allowed later only when it improves repair proof, feedback
  rhythm, session proof, activation, or commercial trust.

## 6. Locked Arc Order

### Completed

1. Monetization / Route Truth SSOT Lock v1.
2. Infrastructure recovery and CI hygiene.
3. AI Personalization foundation:
   - deterministic repair decision contract;
   - runtime consumption in Act0 next-useful-hand / reason receipt seam;
   - Act0 telemetry truth alignment for local learning-loop fields.

### Landed on main

1. Visible Repair Reason Surface.
2. Repair Result Receipt.
3. Session Repair Summary.
4. Repair-based return reason.
5. Review pattern contract sync, with Review Pattern Coaching Lite already
   present.
6. Existing Profile progress mirror confirmed.
7. Day 2 open-repair persistence.
8. Day 2 proof acceptance and deterministic `day2_return` packet lane.
9. Review mistake history contract/projection/write/read-only consumer.
10. Profile evidence projection/consumer/capture.
11. Achievement seed contract/projection/consumer.
12. Profile Earned moments.
13. Session Summary Earned moment.
14. Practice repair queue projection/consumer.
15. Practice active-repair row CTA.
16. Practice queue target launch audit.
17. Practice queue repair source handoff.
18. Repair outcome projection.
19. Repair outcome local proof.
20. Session Summary repair outcome receipt.
21. Repair Loop Copy / Claim-Safety Pass v1.

### Next candidate

1. Achievement Taxonomy v1 - No Art.
   - Define award families, proof requirements, and safe naming.
   - Do not commit badge art, icon direction, ratings, levels, or commercial
     packaging.
2. Evidence-Based Skill/RPG Taxonomy Contract v1.
   - Define the evidence stats and thresholds that could later support skill
     families, levels, ratings, or RPG profile copy.
   - Treat Runout analytics/RPG structure as taxonomy input only.
3. Fixes You've Banked / Proof Home Contract v1.
   - Decide whether a compact proof-home concept is valid after taxonomy.
   - No new dashboard before the evidence and taxonomy contracts exist.
4. Queue Resolution Contract v1.
   - Define when a Practice queue item may be removed or marked done.
   - No resolution semantics before this contract.
5. Review Resolution Contract v1.
   - Define when Review history may be cleared, recovered, or archived.
   - No read/write behavior changes before this contract.
6. Badge/Icon Visual System.
   - Only after achievement taxonomy is accepted.
7. Commercial Packaging / Premium Arc.
   - Only after proof loop, taxonomy, visual system, and commerce safety are
     ready.

### Later

- Optional post-copy Claude/Gemini visual or UX recheck.
- Commercial Screenshot / Renderer Acceptance.
- Content Depth / Term Introduction / Drill Coverage Audit.
- Daily Trainer / Habit Loop Expansion.
- W4/W5 Product Truth Normalization.
- Paywall / Trial Design.
- App Store / Premium Packaging Arc.
- Analytics / Leak Profile Lite.

## 7. Arc EV Table

| Arc | EV | Why it matters | Runout impact | Dependencies | Not-now constraints |
| --- | ---: | --- | --- | --- | --- |
| AI Personalization / Rule-Based Repair Layer v1 | CLOSED | Converts Sharky's proof spine into a personal coach: mistake -> error type -> repair decision -> next useful hand -> repair result. | Beats black-box calibration with auditable table-signal personalization. | Repair decision contract, runtime reason receipt, telemetry truth, feedback surface. | No AI claims, no coach/chat, no broad analytics, no monetization gating, no visual polish. |
| Visible Repair Reason Surface v1 | CLOSED | Turns internal deterministic personalization into user-visible learning value: missed signal -> why this rep -> what to repair. | Attacks Runout's "AI finds leaks" perception with auditable table-signal causality. | `Act0RuleBasedRepairDecisionV1`, next-useful-hand reason receipt, telemetry truth. | No new route, no chat coach, no premium gating, no generic dashboard, no Modern Table polish. |
| Repair Outcome / Local Proof / Session Receipt stack | CLOSED | Makes fix attempts visible in learner-safe copy and carries the outcome into Session Summary. | Turns leak-fixing promise into observable learning causality without fake mastery. | Visible repair reason, Practice queue launch, source handoff, repair outcome projection. | No queue removal, no fixed/cleared/resolved semantics, no broad progress dashboard. |
| Profile Evidence / Earned Moment stack | CLOSED | Shows recent proof and earned moments while gating unsafe skill level and badge-count claims. | Gives Sharky a trust-safe alternative to Runout progress theatre. | Profile evidence projection/consumer/capture, achievement seeds, Session Summary earned moment. | No unitless +N skill scores, no `Lv N` capability claims, no rating/radar, no badge art. |
| Achievement Taxonomy v1 - No Art | 9.4 | Defines what Sharky can truthfully award, group, and name before visual badges exist. | Starts closing Runout's RPG packaging advantage without copying or overclaiming. | Current earned-moment and repair-proof stack. | No badge/icon art, no fake mastery, no level/rating/radar commitment. |
| Evidence-Based Skill/RPG Taxonomy Contract v1 | 9.3 | Defines which evidence can support future skill families, levels, ratings, and RPG profile language. | Lets Sharky learn from Runout's perceived completeness without adopting black-box analytics theatre. | Profile evidence, achievement taxonomy, repair outcomes, session proof. | No abstract levels/ratings, no radar, no AI/GTO/solver claims, no broad analytics dashboard. |
| Fixes You've Banked / Proof Home Contract v1 | 9.1 | Gives the learner one compact place to understand what the repair loop proved. | Competes with analytics through cited proof, not dashboard breadth. | Achievement taxonomy, skill/RPG taxonomy, repair receipts, Profile evidence. | No fake backlog, no unowned resolution, no new route family. |
| Queue Resolution Contract v1 | 8.8 | Defines when Practice queue rows can leave the queue or change state. | Prevents fake "fixed" theatre while enabling cleaner repair proof later. | Repair outcome source handoff and active queue contract. | No queue mutation before source-owned resolution semantics. |
| Review Resolution Contract v1 | 8.7 | Defines when Review history can become recovered, archived, or cleared. | Makes long-term proof more credible without inventing history. | Review history write/read model, repair outcomes, queue resolution contract. | No Review clearing or recovered claims before contract. |
| Commerce / Receipt / Entitlement Readiness | 8.8 | Enables safe future paywall/trial without mock purchase or restore risk. | Closes Runout's subscription-infrastructure advantage. | Entitlement ledger, receipt verification policy, restore truth, subscription copy. | No public paywall, pricing, trial start, Premium Hub exposure, or purchase UI until safety is proven. |
| Daily Trainer / Habit Loop Expansion and Learning Depth | 9.0 | Turns first proof into D2/D7 return value with one useful table read or repair. | Answers Runout daily-session strength with deterministic table learning. | First-week loop, same-signal reps, repair queue, skill receipts. | No streak guilt, no broad dashboard, no random daily churn. |
| W4/W5 Product Truth Normalization | 8.4 | Removes stale route-number ambiguity before paywall, trial, or store copy depends on W4/W5. | Prevents commercial confusion that Runout's packaging likely avoids. | Active route truth, authored content docs, monetization SSOT. | Do not combine with content expansion, paywall design, or route migration. |
| Paywall / Trial Design | 8.2 | Packages premium when commerce safety and value proof are ready. | Directly competes with Runout paywall ceremony. | Commerce safety, W5 boundary, trial policy, proof-first screenshots. | No early trial, no soft-preview purchase CTA, no world-unlock promises before normalization. |
| W4 vs W5 Boundary Experiment Planning | 7.8 | Lets the team evaluate W4 challenger without destabilizing launch default. | Helps balance Runout-like monetization confidence with Sharky trust. | W4 route clarity, telemetry, commerce readiness, experiment design. | No live A/B, no default W4 gate, no W3 paid gate. |
| App Store / Premium Packaging Arc | 8.7 | Turns accepted product proof into market-quality external packaging. | Attacks Runout's strongest public-facing advantage. | English proof packet, premium preview proof, route truth, no fake claims. | No copied assets/layouts, no overpromised screenshots, no paywall-first story. |
| Analytics / Leak Profile Lite | 8.0 | Makes progress visible over time without hiding learning behind charts. | Responds to Runout reports/analytics with deterministic signal history. | Reliable telemetry, skill atoms, repair outcomes, enough user data. | No heavy analytics dashboard, no fake leak fixing, no advanced stats before enough evidence. |

## 8. Operating Mode

### Product Attack Loop

Every strategic wave should use this loop:

1. Define the enemy benchmark.
2. Define the Sharky target that is better than the enemy for this user job.
3. Audit current Sharky against that target.
4. Pick one high-EV seam.
5. Implement a bounded wave.
6. Prove with tests, simulator, screenshots, or review artifact as appropriate.
7. Park or escalate based on evidence.

Use larger end-to-end clean-scope cycles. Do not run micro-prompts for each tiny
action. GitHub is used at the end of a clean scope for Actions/merge safety,
not as constant ping-pong.

For product work:

`branch -> bounded product wave -> local checks -> PR -> repo-owned checks -> merge if green -> sync main`

One branch = one homogeneous scope.

### Agent roles

- ChatGPT / orchestrator: product strategy, EV ranking, acceptance gates, and
  prompt design.
- Codex: implementation owner for Flutter, Dart, docs, tests, proof harnesses,
  and system layers.
- Claude: second-opinion/deep code audit and stuck-case investigation.
- Gemini: visual, text, and competitive audit only.
- CI/tests/proof: final authority over "done."

## 9. Non-Negotiable Guardrails

- No hard paywall before real value.
- No public commerce before receipt, restore, and entitlement safety.
- No fake AI, adaptive, GTO, solver, optimal-frequency, guaranteed-result, or
  win-rate claims.
- No fake mastery.
- No abstract levels, ratings, radar, or skill scores without an evidence
  source and threshold.
- No badge art before achievement taxonomy.
- No Sharky rating/radar/level system before the skill/RPG evidence contract.
- No queue or Review resolution before explicit resolution contracts.
- No visual-polish drift during Modern Table maintenance.
- No content expansion without direct learning or commercial EV.
- No copying Runout artifacts, text, layouts, assets, videos, charts, brand
  treatment, or proprietary structure.
- Copy the job-to-be-done, not the artifact.
- English is the commercial product-quality SSOT.
- Table readability and learning proof beat decorative polish.
- One active bottleneck family at a time.
- No more infrastructure cleanup unless a real blocker appears.
- Telemetry supports learning-loop truth but must not become the product state
  owner.
- Visible repair UX must be causal and table-signal grounded, not generic
  encouragement.
- Do not claim personalization is AI/adaptive unless the exact rule or cause is
  visible.
- Do not use screenshot pipeline as a design iteration excuse.
- Do not expand content breadth before the visible repair loop proves learning
  value.
- Do not move premium/value packaging ahead of first-session repair proof.
- Do not move premium/value packaging ahead of proof taxonomy, achievement
  taxonomy, and commerce safety.

## 10. Deferred Ideas

These ideas remain parked until their prerequisites are true:

- Full AI coach/chat.
- Full analytics dashboard.
- Public leak profile surface.
- AI/adaptive marketing language.
- Premium repair-depth upsell.
- App Store packaging.
- Visual/motion layer.
- Broad skill map.
- Welcome/placement simplification.
- Contextual glossary / tappable definitions.
- Concept depth audit / spaced examples.
- World/lesson completion reward layer.
- Runout live UX benchmark / competitive packaging review.
- W4 gate.
- Dynamic or high-intent gate.
- D2 or high-intent trial.
- One-time starter pack.
- Hand-history bridge.

Some of these are high-EV future items, not rejected. They are deferred until
the visible repair loop and session proof are done.

## 11. Source Links

Source-link rule:

- Keep only repo-present references as active links.
- If `docs/competitive/runout/**` files are not present in the repo, treat them
  as local competitive reference evidence, not active source links.
- Do not restore competitive research files in this PR.

Primary planning:

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/MONETIZATION_SSOT_v1.md`
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`
- `docs/plan/MONETIZATION_TIMING_GUARD_v1.md`
- `docs/plan/APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.md`
- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`

Accepted proof and strategy reviews:

- `docs/_reviews/final_first_week_commercial_proof_packet_v1.md`
- `docs/_reviews/compact_english_premium_preview_proof_v1.md`
- `docs/_reviews/monetization_route_truth_ssot_lock_v1.md`
- `docs/_reviews/w1_w3_free_foundation_gate_readiness_audit_v1.md`
- `docs/_reviews/ai_personalization_rule_based_repair_v1.md`
- `docs/_reviews/act0_rule_based_repair_runtime_consumption_v1.md`
- `docs/_reviews/act0_rule_based_repair_telemetry_truth_v1.md`
- `docs/_reviews/ci_workflow_rationalization_v1.md`
- `docs/_reviews/top1_runout_xapk_benchmark_addendum_v1.md`
- `docs/_reviews/blind_monetization_strategy_challenge_v1.md`
- `docs/_reviews/monetization_ev_scenario_analysis_v1.md`
- `docs/_reviews/premium_monetization_existing_plan_reconciliation_v1.md`
- `docs/_reviews/review_mistake_history_data_contract_v1.md`
- `docs/_reviews/review_mistake_history_unresolved_projection_v1.md`
- `docs/_reviews/review_mistake_history_write_integration_v1.md`
- `docs/_reviews/review_mistake_history_read_only_consumer_admission_v1.md`
- `docs/_reviews/profile_evidence_projection_v1.md`
- `docs/_reviews/profile_evidence_consumer_admission_v1.md`
- `docs/_reviews/profile_evidence_capture_achievement_seed_contract_v1.md`
- `docs/_reviews/achievement_seed_projection_v1.md`
- `docs/_reviews/achievement_seed_consumer_admission_v1.md`
- `docs/_reviews/session_summary_earned_moment_v1.md`
- `docs/_reviews/practice_queue_target_launch_audit_v1.md`
- `docs/_reviews/practice_queue_repair_source_handoff_contract_v1.md`
- `docs/_reviews/repair_outcome_projection_v1.md`
- `docs/_reviews/repair_outcome_consumer_local_proof_v1.md`
- `docs/_reviews/session_summary_repair_outcome_receipt_v1.md`
- `docs/_reviews/repair_loop_copy_claim_safety_pass_v1.md`

Local competitive reference evidence, not active source links:

- `docs/competitive/runout/RUNOUT_REFERENCE_SUMMARY.md` is not present in this
  repo.
- `docs/competitive/runout/RUNOUT_FEATURE_MATRIX.md` is not present in this
  repo.
- `docs/competitive/runout/RUNOUT_ONBOARDING_PAYWALL_NOTES.md` is not present
  in this repo.
- `docs/competitive/runout/RUNOUT_MOTION_VISUAL_PACKAGING_NOTES.md` is not
  present in this repo.
- `docs/competitive/runout/RUNOUT_PROGRESS_RETENTION_NOTES.md` is not present
  in this repo.
- `docs/competitive/runout/SHARKY_RESPONSE_OPPORTUNITIES.md` is not present in
  this repo.
