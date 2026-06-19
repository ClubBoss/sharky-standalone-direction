# Product Surface Premium QA v1

Date: 2026-06-18
Mode: Audit-only
Scope: Active Act0 product surfaces after first-value, daily-loop, repair-proof, and first-value return-carry persistence work.

## 1. Purpose

Evaluate the current Act0 learner-facing surfaces against a premium mobile poker trainer standard without making code, copy, route, telemetry, screenshot, Playwright, table-geometry, dashboard, content, or monetization changes.

Primary question:

Where does the app still feel less premium, less clear, or less trainer-like than a top mobile poker trainer now that the core proof loop works?

Audit verdict:

The core product spine is now strong enough to stop local first-value micro-polish. Sharky's biggest remaining premium perception gap is not missing proof. It is uneven surface hierarchy: the first-session path has strong learning receipts, but Home checklist, Review repair/repaired proof, and Profile still sometimes read as dense operational surfaces rather than one calm premium trainer voice.

## 2. Method / Evidence Used

Evidence inspected:

- Active app boundary docs:
  - `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
  - `docs/plan/MASTER_PLAN_v3.0.md`
- Prior accepted review artifacts:
  - `docs/_reviews/act0_first_value_daily_loop_closeout_v1.md`
  - `docs/_reviews/first_return_day2_persistence_contract_audit_v1.md`
- Active owners:
  - `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- Focused tests:
  - placement direct handoff and route proof
  - first-value feedback and Home carry
  - first-value carry relaunch persistence
  - daily done state
  - Review repaired proof
  - Profile progress/habit surfaces
- Existing screenshot artifacts only:
  - `output/playwright/first_session_manual_screenshot_qa_v1/large_phone.placement.png`
  - `output/playwright/first_session_manual_screenshot_qa_v1/compact_phone.home.png`
  - `output/playwright/first_correct_feedback_capture_harness_v1/compact_phone.runner_first_correct_feedback.png`
  - `output/playwright/first_session_manual_screenshot_qa_v1/compact_phone.review.png`
  - `output/playwright/first_session_manual_screenshot_qa_v1/compact_phone.profile.png`

No new screenshots were generated. No full capture lane was run. The compact placement screenshot in the existing manual QA folder was blank, so placement visual scoring uses the existing large-phone screenshot and code/test evidence.

## 3. Screen-by-Screen Audit Table

| surface/state | owner/file | user job | primary CTA | learning proof visible | trainer/return value visible | premium readiness score 1-10 | issue class | severity | implementation risk | recommended action | rationale |
| --- | --- | --- | --- | --- | --- | ---: | --- | --- | --- | --- | --- |
| Placement entry | `act0_placement_shell_v1.dart` | Understand this is a fast route check, not setup work. | `Find my start` | Promise: two answers + one short check opens first useful hand. | Beginner-safe, fast handoff, no exam. | 8.4 | copy/hierarchy, premium rhythm | low | low | Keep; no immediate implementation. | Existing large-phone screenshot reads polished and calm. It is not table-native yet, but it does the first five-second job well. |
| Placement result / handoff | `act0_placement_shell_v1.dart`, `act0_shell_preview_screen_v1.dart` | Trust that Sharky found a useful start and begin the first hand. | `Start with the useful hand` | Route proof, focus chips, useful first hand ready, one table clue. | Clear deterministic route and no paywall pressure. | 8.5 | proof visibility, CTA clarity | low | low | Keep; defer only placement-result resume persistence if later proven user-facing. | Strong product truth. The remaining gap is visual proof on compact placement screenshot reliability, not runtime product copy. |
| First hand / runner intro | `act0_lesson_runner_shell_v1.dart`, `act0_shell_state_v1.dart` | See a real table and answer one useful poker action spot. | Runner `Continue` or action buttons. | Table remains dominant; prompt/answers tie to visible state. | First hand is a useful table-clue hand, not generic quiz. | 8.6 | visual hierarchy, table signal clarity | medium | medium | Recommend one targeted manual proof later, not now. | Table is the product hero and compact runner guards are green. A premium QA gap remains around proving the exact first-hand intro state visually after all recent changes. |
| First correct feedback | `act0_lesson_runner_shell_v1.dart` | Understand what improved and what table clue mattered. | `Continue` | `Table read improved`; `You noticed No bet yet before choosing an action.`; signal proof row; table visible. | `Next: practice the same table clue once more.` | 9.0 | proof visibility | low | low | Keep. | This is Sharky's strongest competitive surface: deterministic, beginner-safe, table-bound proof. Existing first-correct screenshot confirms table dominance and compact feedback. |
| Home first-value carry | `act0_home_shell_v1.dart`, `act0_shell_preview_screen_v1.dart` | Know the exact next useful action after first value or relaunch. | `Continue` | `You started with No bet yet. One more rep makes it stick.` | Persisted carry now survives relaunch until same-signal rep launch. | 8.8 | retention signal, proof continuity | low | low | Keep; no further local copy churn. | The recent persistence MVP closes the biggest trust gap. Existing Home visual is polished enough, though not yet as premium-packaged as Runout. |
| Home daily checklist | `act0_home_shell_v1.dart` | See today's useful steps without dashboard weight. | Active row / main CTA. | Learn/Practice/Review/Fix rows show route state and daily reps. | Practical short daily loop. | 7.4 | density, visual hierarchy, premium feel | medium | medium | Next implementation candidate: calm trainer-plan hierarchy pass. | Useful but operational. The `0 / n`, numbered rows, small labels, and multiple statuses make it feel more like a task tracker than a premium coach plan. |
| Home done-for-today | `act0_home_shell_v1.dart`, `act0_shell_preview_screen_v1.dart` | Feel closure and know returning matters. | `Continue if you want` or no-pressure continuation. | `Today complete`; table clue complete; optional streak. | `Come back for the next useful hand.` | 8.3 | retention signal, copy density | low-medium | low | Keep; fold into trainer-plan hierarchy only if touching Home. | Good closeout language. It is clear and honest; premium gap is mostly visual rhythm relative to the mission card. |
| Review open repair | `act0_review_shell_v1.dart`, `act0_shell_preview_screen_v1.dart` | Fix the most important weak spot without shame. | `Start repair rep` / `Review repair cue`. | Shows chosen vs better, reason, context chips, repair target. | `What to fix next`; one calm repair rep. | 7.1 | density, raw labels, premium rhythm | high | medium | Highest-EV candidate with Home checklist: coach-plan/repair hierarchy pass. | Existing screenshot is useful but heavy: `You chose`, `Better`, `Bottom seat`, chips, repair cue, and recovery plan stack up. Some of this may already be improved in code/tests, but perceived premium risk remains highest here. |
| Review repaired proof | `act0_review_shell_v1.dart`, `act0_shell_preview_screen_v1.dart` | See that a miss was repaired and optionally replay for perfect. | `Replay for perfect` | `Recovered lately`; `Repaired`; detail line. | Skill can be stabilized, not just corrected. | 7.8 | proof hierarchy, CTA clarity | medium | low-medium | Include in same repair hierarchy pass; do not redesign Review. | The proof is stable and valuable, but the row can still feel like a log item. The CTA is clear; hierarchy should make the earned proof feel more premium. |
| Profile / return-value surface | `act0_profile_shell_v1.dart`, `act0_shell_preview_screen_v1.dart` | See identity, progress, rhythm, and next focus simply. | `View path`, `View week`, utility actions. | XP, tasks complete, rhythm, skills, badges. | Streak-lite and progress identity. | 8.0 | density, deferred visual polish | low-medium | low-medium | Defer. | Existing screenshot is polished and credible. Profile is denser than first-session surfaces, but not a blocker for first-session premium perception. |

## 4. Premium Readiness Score Per Surface

Scored dimensions: user-job clarity, CTA clarity, learning proof, trainer value, beginner safety, copy density, visual hierarchy, premium feel, retention signal, implementation risk.

| surface/state | user-job clarity | CTA clarity | learning proof | trainer value | beginner safety | copy density | visual hierarchy | premium feel | retention signal | implementation risk | weighted read |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Placement entry | 9 | 9 | 7 | 8 | 9 | 8 | 8 | 8 | 7 | 9 | 8.4 |
| Placement result / handoff | 9 | 9 | 8 | 9 | 9 | 8 | 8 | 8 | 8 | 9 | 8.5 |
| First hand / runner intro | 8 | 8 | 9 | 9 | 8 | 8 | 9 | 8 | 7 | 7 | 8.6 |
| First correct feedback | 9 | 9 | 10 | 10 | 9 | 8 | 9 | 8 | 9 | 9 | 9.0 |
| Home first-value carry | 9 | 9 | 9 | 9 | 9 | 8 | 8 | 8 | 10 | 9 | 8.8 |
| Home daily checklist | 8 | 8 | 7 | 8 | 8 | 6 | 7 | 7 | 8 | 7 | 7.4 |
| Home done-for-today | 9 | 8 | 8 | 8 | 9 | 8 | 8 | 8 | 9 | 9 | 8.3 |
| Review open repair | 8 | 8 | 8 | 9 | 8 | 5 | 6 | 6 | 8 | 6 | 7.1 |
| Review repaired proof | 8 | 8 | 8 | 8 | 9 | 7 | 7 | 7 | 8 | 7 | 7.8 |
| Profile / return value | 8 | 7 | 8 | 8 | 9 | 7 | 8 | 8 | 8 | 8 | 8.0 |

## 5. Top Cross-Surface Patterns

1. Proof is now stronger than packaging.

The app can now prove learning value with table-signal feedback, same-signal Home carry, persistence, daily completion, and repaired proof. The gap is no longer "does Sharky teach?" It is "does every surface feel like one premium trainer?"

2. Home and Review carry the most operational weight.

Placement and first feedback are focused. Home checklist and Review repair surfaces contain the most row labels, badges, chips, statuses, and helper text. They are useful but risk reading as internal workflow.

3. The strongest premium principle is already present in first feedback.

The best pattern is:

`outcome -> table clue -> why -> next action`

Home and Review should borrow that hierarchy, not add more panels.

4. Screenshot evidence exists but is uneven.

Existing Home, first-correct feedback, Review, Profile, and large-phone placement screenshots were useful. Compact placement screenshot from manual QA was blank. This is not a product blocker, but launch proof should not rely on that blank artifact.

5. Profile is not the next bottleneck.

Profile is polished enough for this phase. It is a little dense, but it is not on the highest-EV first-session or first-return path.

## 6. Highest-EV Implementation Arcs

### 1. Home + Review Calm Trainer Hierarchy Pass v1

Priority: highest.

Goal:

Make Home checklist and Review repair/repaired proof read like a calm trainer plan instead of an operational queue, without changing routes, state, telemetry, content, table geometry, or broad layout.

Bounded scope:

- Home daily checklist visible hierarchy.
- Review open repair board/card hierarchy.
- Review repaired proof row hierarchy.
- Copy labels only where they feel like metadata or raw internals.
- Keep existing repair resolver, proof, and CTAs.

Expected improvements:

- Home plan becomes "what to do next and why" rather than `0 / n` task tracking.
- Review open repair leads with the missed table clue and next repair action, then details.
- Repaired proof feels earned: "recovered lately" is visually subordinate to the repaired spot and replay action.

Why this wins:

- One bounded wave improves multiple lower-scoring surfaces.
- It raises perceived premium trainer quality materially.
- It avoids dashboards, route changes, new state, and visual micro-polish.

### 2. Targeted First-Session Visual Proof Packet v1

Priority: second, audit/proof only.

Goal:

Create or refresh one compact proof packet after the hierarchy pass, not now:

- placement entry/result
- first hand intro
- first correct feedback
- Home first-value carry after relaunch
- Review repaired proof

Guard:

Run at most one targeted compact screenshot pass. Do not touch Playwright tooling unless capture is blocked.

Why:

Current screenshot evidence is useful but uneven. The compact placement blank artifact should not be used in launch-facing proof.

### 3. Trust / Monetization Readiness Audit v1

Priority: third.

Goal:

Audit whether value-before-monetization is now credible enough to introduce trust/trial/paywall planning.

Guard:

Audit only. No paywall implementation. Do not add monetization pressure before the trainer loop feels premium.

Why:

Runout remains stronger in packaging and monetization infrastructure, but Sharky should not monetize until Home/Review trainer perception is cleaner.

## 7. Deferred List

- Dashboard, Skill Map, Leak Profile, or heavy analytics.
- Broad Home redesign.
- Review redesign.
- Table/ModernTable geometry changes.
- Answer dock geometry changes.
- More W3 repair micro-reps.
- Daily task identity persistence unless it becomes visibly user-facing.
- Paywall or subscription work.
- Fake AI/adaptive claims.
- GTO/solver/optimal/frequency wording.
- Screenshot tooling changes.
- Local visual polish that does not improve learner trust, repair clarity, or return intent.
- Profile polish unless a concrete first-return blocker appears.

## 8. Stop Rules To Avoid Visual Micro-Polish

Stop a future implementation wave if:

1. It changes table geometry, answer dock geometry, or ModernTable visuals.
2. It adds a new dashboard, Skill Map, Leak Profile, modal, or broad surface.
3. It rewrites Home or Review instead of tightening hierarchy in the existing cards.
4. It changes route order, scoring, repair resolver, task order, telemetry, or persistence.
5. It removes deterministic proof in favor of vague polish.
6. It changes first-correct feedback, which is already one of the strongest surfaces.
7. It spends screenshot quota before a concrete blocker needs visual proof.
8. It introduces AI, GTO, solver, optimal, frequency, or monetization copy.

## 9. Direction Score

Current direction score: 8.6 / 10.

Why this is strong:

- First-value proof is concrete and table-bound.
- The first-value Home carry now survives relaunch.
- Daily completion has an honest return reason.
- Repair/repaired proof is stable and learner-safe.
- The app avoids fake AI and solver framing.

Why it is not yet 9+:

- Home checklist and Review repair surfaces still feel more operational than premium.
- Existing screenshot proof is uneven, especially placement compact capture.
- Runout still likely wins on perceived packaging polish, even though Sharky's deterministic learning proof is stronger.

## 10. Runout / Benchmark-Stack Comparison

Based only on proven current behavior and accepted reference direction:

| benchmark | stronger than Sharky | Sharky's proven edge | practical implication |
| --- | --- | --- | --- |
| Runout | Premium packaging, onboarding polish, perceived trainer maturity, visual presentation. | Deterministic table-signal proof: user choice -> visible clue -> why -> same-signal rep -> repaired proof. | Sharky should not copy Runout layout/paywall. It should make its proof spine feel premium across Home and Review. |
| GTO Wizard-style products | Advanced credibility, solver study depth. | Beginner-safe table-first explanation without solver pressure. | Do not add GTO/optimal/frequency language to look premium. |
| Beginner poker apps | Simple low-friction flow. | Stronger causal proof and repair loop. | Keep surfaces simple; do not let checklist/Review density erase this advantage. |
| Coaching/habit apps | Polished return packaging and identity. | Honest daily proof and repaired proof. | Improve trainer hierarchy before monetization/trust work. |

## 11. Recommended Next Arc

Run `Home + Review Calm Trainer Hierarchy Pass v1`.

This is the single best bounded implementation wave because it raises perceived premium quality across the two weakest active product surfaces without changing the accepted learning loop.

Implementation target:

- Home daily checklist: reduce task-tracker feel and make next action + reason more dominant.
- Review open repair: lead with missed table clue and repair CTA, demote raw chosen/better comparison.
- Review repaired proof: make repaired proof feel earned, keep `Replay for perfect`.

Do not touch placement, first correct feedback, table geometry, route logic, persistence, telemetry, dashboard, Profile, screenshot tooling, or monetization in that wave.
