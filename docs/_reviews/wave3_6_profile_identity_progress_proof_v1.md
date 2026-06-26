# Wave 3.6 - Profile Identity & Progress Proof v1

## 1. Verdict

wave3_6_profile_identity_progress_proof_ready

The Profile / You surface is already a compact learner identity and progress proof surface, not just a receipt. One small claim-safety visual issue was found and fixed: the `Skills` proof tile used a radar icon, which conflicted with the no-rating/no-radar boundary for Profile proof.

## 2. TOP1 matrix row target

- Primary: Profile identity / progress proof.
- Secondary: Review/Profile trust, habit loop / return reason, rewards / achievements, first-week commercial proof, premium learning clarity.

## 3. Wave goal and scope

Goal: audit Profile / You against current screenshots and code seams, then implement only a small proof-backed Profile improvement if evidence supports it.

Scope stayed inside Profile / You and closely owned progress proof surfaces:

- Profile hero card.
- Recent route proof.
- Current focus.
- Progress proof card.
- Earned moments / small wins.
- Existing streak/task/progress proof labels.

The only product change is an icon replacement in Profile progress proof. No Profile layout redesign, analytics surface, new model, route change, or telemetry change was made.

## 4. Evidence inspected

Screenshot packets:

- `./tools/screen_review_fast_v1.sh day2_return compact` passed before implementation.
  - Contact sheet: `output/screen_review/current/day2_return_fast/contact_sheet.png`
  - Zip: `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `./tools/screen_review_fast_v1.sh first_week compact` passed before implementation.
  - Contact sheet: `output/screen_review/current/first_week_fast/contact_sheet.png`
  - Zip: `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

Profile surfaces:

- `Profile active repair proof` in Day 2 return packet.
- `Profile return` in first-week packet.
- Hero card: `You`, `Learning profile`, `Recent route proof`.
- Current focus card.
- Progress proof grid.
- Earned moments section.

Files:

- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart`
- `lib/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `test/ui_v2/act0_profile_claim_safety_v1_test.dart`
- `test/ui_v2/act0_achievement_seed_consumer_v1_test.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

Route / prior-wave artifacts:

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/public_premium_top1_v1_endgame_lock_v1.md`
- `docs/_reviews/wave3_5_premium_transition_replay_motion_v1.md`
- `docs/_reviews/wave3_4_achievement_visual_language_icons_v1.md`
- `docs/_reviews/wave3_3_runner_text_zone_feedback_clarity_final_pass_v1.md`
- `docs/_reviews/wave3_2_first_week_commercial_proof_gap_lock_v1.md`
- `docs/_reviews/wave3_1_street_replay_how_we_got_here_v1.md`
- `docs/_reviews/wave3_0_review_pattern_coaching_lite_v1.md`
- `docs/_reviews/wave2_9_earned_rewards_achievement_hooks_v1.md`
- `docs/_reviews/wave2_8_sharky_soul_compact_coach_layer_v1.md`

Tests:

- `test/ui_v2/act0_profile_claim_safety_v1_test.dart`
- `test/ui_v2/act0_achievement_seed_consumer_v1_test.dart`
- focused Profile subset in `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

## 5. Profile audit

### Profile / You hero card

- Observed state: hero shows `You`, `Learning profile`, Sharky avatar, route/world line, recent route proof, progress bar, proof chips, and a streak chip when source-owned.
- Issue/no issue: no issue.
- Severity: not an issue.
- Decision: no action.

The hero already answers what Sharky has seen recently without rating, radar, XP, or level copy.

### Learning profile / progress proof card

- Observed state: progress proof includes Lessons, Rhythm, Skills, and Earned tiles. Copy is compact and evidence-safe.
- Issue/no issue: one visual claim-safety issue.
- Severity: P2.
- Decision: fixed.

The `Skills` tile used `Icons.radar_rounded`. Even without unsafe text, a radar visual conflicts with this wave's explicit no-rating/no-radar boundary. It now uses `Icons.fact_check_rounded`, which reads as practiced/proof evidence rather than analytics.

### Earned moments / small wins area

- Observed state: earned moments render only when `Act0AchievementSeedConsumerV1.hasMoments` is true. The section copy is `Small wins Sharky can prove.`
- Issue/no issue: no issue.
- Severity: not an issue.
- Decision: no action.

The area is visible in the compact Profile packet and is not placeholder-like. It is source-backed and non-clickable.

### Current focus

- Observed state: current focus card appears above progress proof, ties the learner back to the active route, and can link back with `View path`.
- Issue/no issue: no issue.
- Severity: not an issue.
- Decision: no action.

The card gives a reason to return without broad diagnosis or fake persona labels.

### Streak/tasks/progress numbers

- Observed state: Profile shows local task completion, `3 day streak`, and proof tiles. Existing guards suppress unsafe `Level`, `XP`, rating, radar text, and unitless skill gains.
- Issue/no issue: no issue after icon fix.
- Severity: not an issue.
- Decision: no action.

The numbers are local route/proof numbers rather than all-time analytics.

### Empty or placeholder-looking areas

- Observed state: the first viewport is populated with hero, current focus, progress proof, and earned moments beginning below. Empty earned moments do not render.
- Issue/no issue: no issue.
- Severity: not an issue.
- Decision: no action.

### What the learner is becoming

- Observed state: Profile uses proof language such as `Table sense is becoming more familiar.` and compact current focus/progress proof instead of persona labels.
- Issue/no issue: no issue.
- Severity: not an issue.
- Decision: no action.

## 6. Implementation summary if code changed

Product code changed in one place:

- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
  - Profile `Skills` proof tile icon changed from `Icons.radar_rounded` to `Icons.fact_check_rounded`.

Test changed in one place:

- `test/ui_v2/act0_profile_claim_safety_v1_test.dart`
  - Added a focused assertion that Profile progress proof does not render `Icons.radar_rounded`.

Review artifact added:

- `docs/_reviews/wave3_6_profile_identity_progress_proof_v1.md`

## 7. Identity/progress changes if any

Old surface/copy:

- `Progress proof` -> `Skills` tile used a radar icon.
- Copy stayed `Skills` / `2 growing` or tracked/growing equivalent.

New surface/copy:

- `Progress proof` -> `Skills` tile uses `Icons.fact_check_rounded`.
- Copy unchanged.

Evidence source:

- screenshot packets showed the Profile progress proof grid in the first viewport;
- code inspection found the radar icon in `_ProfileProgressProofCardV1`;
- the prompt explicitly forbids rating/radar/level implications.

Why source-safe:

- the tile is still shown only from existing `recentSkillGains` or `profile.skillStats`;
- no new skill state, score, rating, or model was introduced;
- the new icon supports proof/practice rather than analytics.

Why it is not fake identity/analytics:

- it does not add a player type;
- it does not add levels, ranks, ratings, radar, or charts;
- it does not expose all-time progress;
- it preserves the existing compact Profile hierarchy.

## 8. Earned moments / current focus proof

Evidence sources:

- earned moments: `Act0AchievementSeedProjectionV1` -> `Act0AchievementSeedConsumerV1`;
- current focus: `Act0ProfileStateV1.recommendedFocusTitle` and existing route/profile state;
- progress proof: `Act0ProfileStateV1.lessonsLine`, `streakLine` / `streakDays`, `recentSkillGains`, `skillStats`, and `achievements`.

Why this is local proof, not status inflation:

- Profile does not infer all-time tendencies;
- it does not convert local proof into ranks or levels;
- it does not show a radar chart or rating;
- it does not claim permanent capability;
- earned moments are hidden when no earned seed exists.

## 9. Empty/placeholder area proof if relevant

No empty placeholder area required a fix.

The compact Profile screenshots show:

- hero card;
- recent route proof;
- current focus;
- progress proof grid;
- earned moments section entering the viewport.

Code inspection confirms `Earned moments` is omitted when the consumer has no moments, so empty proof inventory is not displayed.

## 10. Claim-safety proof

No visible copy was added.

The fixed Profile visual avoids the radar implication by replacing `Icons.radar_rounded` with `Icons.fact_check_rounded`.

Existing and updated tests guard against:

- Level / Lv proof copy;
- XP;
- Rating;
- Radar text;
- Skill score;
- strongest/weakest skill claims;
- unitless skill gains;
- mastered;
- leak;
- AI;
- GTO;
- solver;
- badge-count copy.

This wave introduced no language or visual implying:

- mastery;
- permanent leak fix;
- fixed forever;
- cleared;
- resolved;
- recovered;
- all-time analytics;
- rank;
- premium/paywall value;
- guaranteed improvement;
- win-rate improvement;
- complete hand-history tracking;
- unsupported player tendency reads.

## 11. Boundary proof

This wave did not add:

- all-time analytics;
- rating, radar, levels, rank, XP, or persona labels;
- Profile redesign;
- route, progression, model, or telemetry changes;
- value, paywall, store, or localization work;
- new durable storage;
- queue resolution;
- Review clearing;
- badge inventory or gallery;
- broad achievement taxonomy;
- content expansion;
- Street Replay animation;
- Modern Table redesign;
- new dependencies.

## 12. Tests and validation run

RED check:

- `flutter test test/ui_v2/act0_profile_claim_safety_v1_test.dart`
  - failed as expected because `Icons.radar_rounded` rendered inside `act0_shell_profile_progress_proof`.

Focused GREEN checks:

- `flutter test test/ui_v2/act0_profile_claim_safety_v1_test.dart` passed.
- `flutter test test/ui_v2/act0_achievement_seed_consumer_v1_test.dart` passed.

Adjacent preview subset:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Profile shows compact progress header and encouraging completion line|Profile compact progress stack avoids repeated mood-copy sections|Profile ties identity, current focus, and progress into one compressed story|Profile keeps identity above current focus and compact progress|Profile keeps identity first, then current focus and compact progress proof"`
  - failed in `Profile shows compact progress header and encouraging completion line`.
  - Root cause: existing test expects exactly one `Learning profile`, while current Profile renders that text in both the header and hero. This is unrelated to the icon change and was not repaired in this bounded wave.
  - The remaining selected tests in that subset passed before the command exited.

Formatting / static validation:

- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_profile_shell_v1.dart test/ui_v2/act0_profile_claim_safety_v1_test.dart` passed.
- `flutter analyze` passed.
- `git diff --check` passed.
- `git diff --cached --check` passed.
- `graphify hook-check` passed.
- `git status --short` checked.

## 13. Screenshot proof run and result

Required audit-first screenshot proof passed before implementation:

- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh first_week compact`

Post-implementation screenshot proof passed after the icon fix:

- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh first_week compact`

The Day 2 Profile packet shows the Skills tile with a checklist/proof-style icon rather than a radar icon.

## 14. Generated/untracked artifact status

Generated screenshot and Claude review outputs remain local-only and untracked:

- `output/screen_review/`
- `output/claude_review/`

They must not be committed.

## 15. Anti-theater proof

User-visible thing changed:

- Profile `Skills` proof tile now uses a fact-check/proof icon instead of a radar icon.

Why this was correct:

- the prompt explicitly forbids radar/rating/level implications;
- the screenshots showed Profile progress proof is a first-viewport trust surface;
- code inspection proved the Skills tile used a radar icon;
- the fix removes that implication without changing layout or data.

Final target requirement moved:

- Profile identity / progress proof is now visually safer and better aligned with evidence-backed proof.

Evidence:

- failing RED test before production change;
- passing focused claim-safety test after the icon swap;
- passing earned-moment consumer tests;
- passing post-change screenshot packets.

Explicitly not built:

- Profile redesign;
- analytics dashboard;
- radar chart;
- rating;
- level/rank/XP system;
- persona labels;
- all-time history;
- new progress model.

This is not fake progress because it removes a real claim-safety visual mismatch from a visible Profile proof tile.

## 16. Expected TOP1 matrix movement

- Profile identity / progress proof: small lift from removing radar visual implication.
- Review/Profile trust: small lift because Profile proof is more claim-safe.
- Habit loop / return reason: preserved through current focus and streak proof.
- Rewards / achievements: preserved through earned moments and `Small wins Sharky can prove.`
- First-week commercial proof: small trust lift in the Profile packet.
- Premium learning clarity: small lift because proof visuals better match honest learning state.

## 17. Caveats

- This wave did not redesign Profile or add new identity content.
- One adjacent preview test remains red due to a pre-existing brittle `Learning profile` exact-count assertion; it is unrelated to this icon change.
- Profile still has broader future room for polish, but not without a concrete P1/P2 target and proof source.

## 18. Next recommendation

Proceed to Wave 3.7 - Release-Visible Content Depth Gate v1.

Do not start a broad Profile redesign or analytics wave from this change.
