# Claude UX/UI v2 Wave 2 Scope Selection v1

## 1. Verdict

wave2_scope_selected_ready

## 2. Input evidence

This is an audit/spec artifact only. It uses the latest deterministic local
screen-review packets after Claude UX/UI v2 Wave 1 closure.

Verified baseline:

- `origin/main`: `b786210ac8b0db83d3405d26ca80940211bb1e79`
- Wave 1 closure commit is present on local `main` and `origin/main`.

Evidence commands:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Local evidence artifacts:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/full_scroll_meta.json`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

Generated artifacts are local-only evidence and are not intended for commit.

## 3. Wave 2 candidate family comparison

### 1. Practice lockwall -> drill gym clarity

- Current issue: Practice has a strong daily-drill hero, but the lower section
  still reads heavily as locked `Skill packs`. The screen can feel like a
  lockwall after the useful daily drill instead of a compact drill gym with
  future topic reps.
- Expected UX benefit: high. Practice can better explain its job:
  quick reps now, topic reps as route-backed growth later.
- Risk: medium-low if scoped to display/copy hierarchy only.
- Likely files/surfaces touched:
  - `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
  - focused Practice shell tests if existing contracts assert the old wording.
- Requires new data: no.
- Fake-claim risk: low if copy stays neutral and does not imply unlocked packs,
  recommendations, personalized drills, or hidden review history.
- Small PR fit: yes.

### 2. Learn numbering / 12-world arc clarity

- Current issue: Learn shows `World 1`, current mission progress, `Step 1 of 7`,
  and journey preview numbering. It is truthful, but the relationship between
  current lesson, visible week/world route, and long-horizon 12-world arc can
  still be clearer.
- Expected UX benefit: high. Learn is the route-truth surface and can reduce
  perceived curriculum ambiguity.
- Risk: medium. Learn numbering touches route perception and can easily create
  implied W11/W12/W13 activation or a false completion horizon if copy is not
  tightly bounded.
- Likely files/surfaces touched:
  - `lib/ui_v2/act0_shell/act0_learn_shell_v1.dart` or current Learn owner
  - focused Learn shell tests.
- Requires new data: no, if limited to existing W1/current-route display.
- Fake-claim risk: medium. Must not claim W11/W12 active entry, W13+ access,
  Volume I completion, or paid-depth availability.
- Small PR fit: yes, but only after a precise route-truth prompt.

### 3. Review compact honest shell

- Current issue: Review is now honest and compact: it says the active repair is
  waiting on Home and provides repair context without inventing a backlog. It is
  intentionally passive because there is no admitted mistake-history action.
- Expected UX benefit: medium-low. There may be small polish available, but the
  major honesty problem is already closed.
- Risk: low for copy-only tightening, higher if trying to add action.
- Likely files/surfaces touched:
  - `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
  - focused Review shell tests.
- Requires new data: no for copy tightening; yes for real history/backlog,
  which is out of scope.
- Fake-claim risk: medium if it implies review history, leak detection, or
  personalized mistake analysis.
- Small PR fit: only as a compact copy pass, not as a feature.

### 4. Onboarding handoff simplification

- Current issue: Welcome handoff is functional and compact, but still has a
  dense visual explanation of answer/check/first-hand progress before the
  `Open your start` CTA.
- Expected UX benefit: medium. A small handoff simplification could reduce
  first-start cognitive load.
- Risk: medium because onboarding is early-route critical and already accepted.
- Likely files/surfaces touched:
  - `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`
  - first-start / placement handoff tests.
- Requires new data: no.
- Fake-claim risk: low if copy remains about the existing micro-win and Home
  handoff only.
- Small PR fit: yes, but not the first Wave 2 target unless Practice/Learn
  evidence changes.

### 5. Bottom-tab job clarity

- Current issue: bottom tabs are readable after Wave 1. Any remaining ambiguity
  appears downstream of Practice/Learn/Review role clarity, not as a standalone
  navigation blocker.
- Expected UX benefit: low as an independent PR.
- Risk: medium because tab copy/icon changes affect all surfaces.
- Likely files/surfaces touched:
  - Act0 shell navigation owner.
- Requires new data: no.
- Fake-claim risk: low, but global navigation churn is not justified yet.
- Small PR fit: defer unless a prior Wave 2 change proves tab labels are the
  cause of confusion.

## 4. Product EV ranking

1. Practice lockwall -> drill gym clarity
2. Learn numbering / 12-world arc clarity
3. Onboarding handoff simplification
4. Review compact honest shell
5. Bottom-tab job clarity

Rationale:

- Practice has the clearest current premium-perception drag after Wave 1: a
  useful daily-drill hero followed by a visually heavy locked-pack area.
- Learn clarity is important but more route-truth sensitive.
- Review is already compact and honest.
- Onboarding is already accepted and should not be reopened before the larger
  Practice/Learn surfaces are clearer.
- Bottom tabs should remain a dependent follow-up, not a primary wave.

## 5. Risk ranking

Lowest to highest implementation risk:

1. Review compact honest shell
2. Practice lockwall -> drill gym clarity
3. Onboarding handoff simplification
4. Bottom-tab job clarity
5. Learn numbering / 12-world arc clarity

Risk rationale:

- Review can be copy-only, but has lower EV.
- Practice can be display-only if it avoids unlocking, recommendations, or new
  route state.
- Onboarding is early funnel and should not churn without a sharper blocker.
- Bottom tabs are global.
- Learn numbering is route-truth sensitive because it can accidentally imply
  activation or completion states not currently owned.

## 6. Recommended first Wave 2 PR

Recommended first implementation prompt:

`Practice Drill Gym Clarity v1`

Scope:

- Practice surface only.
- Keep daily drill as the hero.
- Reframe the below-hero locked `Skill packs` area into a clearer drill-gym
  / topic-reps preview using existing state only.
- Make locked packs feel like future route-backed practice areas, not a
  paywall-like or dead lockwall.
- Preserve `Nothing to repair right now` when truthful.
- Preserve all existing routing, availability, daily drill behavior, repair
  behavior, telemetry, content, progression, and Modern Table boundaries.

Non-goal inside this first PR:

- Do not unlock packs.
- Do not add a recommendation engine.
- Do not add Review history.
- Do not add personalized practice claims.
- Do not change Learn numbering in the same PR.

## 7. Deferred Wave 2 items

1. `Learn Route Numbering / Arc Clarity v1`
   - Defer until Practice clarity is closed.
   - Must explicitly preserve W1-W10 active truth, W11/W12 planned-only truth,
     W13+ frontier-only truth, and no Volume I completion claim.
2. `Onboarding Handoff Simplification v1`
   - Defer unless the next proof packet shows handoff confusion remains after
     Practice/Learn clarity.
3. `Review Compact Honest Shell v1`
   - Defer because Review already avoids fake backlog and routes active repair
     context back to Home.
4. `Bottom Tab Job Clarity v1`
   - Defer unless Practice/Learn/Review role changes expose a tab-label blocker.

## 8. Explicit non-goals

- No Modern Table changes.
- No route/progression changes.
- No W11/W12/W13 activation.
- No Review mistake-history implementation.
- No Practice recommendation engine.
- No durable evidence model changes.
- No Profile evidence claims.
- No premium/paywall/trial work.
- No onboarding implementation beyond a separately scoped handoff cleanup.
- No AI/chat/persona expansion.
- No content expansion.
- No generated screenshot/output commits.
- No broad redesign.
- No repo-wide formatter.

## 9. Screenshot/evidence plan

For the first Wave 2 implementation PR, use:

- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Acceptance evidence should confirm:

- Practice daily drill remains the hero.
- Below-hero Practice content reads as route-backed drill gym / future topic
  reps, not a dead lockwall.
- No fake unlocked pack, personalized recommendation, or premium/paywall signal
  appears.
- Home/Learn/Review/Profile remain materially unchanged unless explicitly
  touched by the implementation prompt.

Generated packets remain local-only and uncommitted.

## 10. Validation plan

For this docs-only selection artifact:

- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short`

For the recommended Practice implementation PR:

- focused Practice shell tests
- affected Act0 shell preview tests
- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
- `graphify hook-check`
- `flutter analyze`
- touched-file format check only
- `git diff --check`
- `git status --short`

## 11. Recommended next implementation prompt

Task title:

`Practice Drill Gym Clarity v1`

Workflow mode:

Small Practice-only UI hierarchy/copy cleanup. No route/progression/data-model
changes.

Goal:

Make Practice read as a useful drill gym: daily drill now, topic reps later as
the route grows. Keep daily drill as the hero, keep repair truth intact, and
soften the locked-pack wall without unlocking anything or adding new
recommendations.

Boundaries:

- Practice surface only.
- No Learn/Home/Review/Profile changes.
- No route/progression changes.
- No telemetry changes.
- No content/glossary changes.
- No Modern Table changes.
- No premium/paywall/trial copy.
- No AI/leak/mastery/GTO/solver claims.
- No generated screenshot/output commits.

Required artifact:

`docs/_reviews/practice_drill_gym_clarity_v1.md`
