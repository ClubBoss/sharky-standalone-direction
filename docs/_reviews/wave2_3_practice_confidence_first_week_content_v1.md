# Wave 2.3 - Practice Confidence & First-Week Content Review

Date: 2026-06-26
Base: `origin/main` at `102f2c694206202311f719915f31816160cdb5ef`
Verdict: `wave2_3_practice_confidence_first_week_content_ready`

## Wave Goal And Scope

Make the first-week proof loop feel more confidence-building and beginner-safe without expanding content breadth or adding a new drill engine.

The wave stayed inside active Act0 presentation/copy seams:

- Practice short-rep copy and current-fix support.
- Home/first-week repair recommendation support copy.
- Focused widget tests for Practice and first-week visible repair support.

Out of scope stayed closed: route/progression changes, telemetry, model semantics, repair queue clearing, Review resolution, durable all-time history, broad drill catalog, W5-W36 expansion, AI/persona, premium/paywall, Modern Table, badge art, rating/radar/level proof, and Runout/Duolingo copying.

## Files Changed

- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `test/ui_v2/act0_play_shell_v1_test.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/wave2_3_practice_confidence_first_week_content_v1.md`

## Practice Confidence Changes

- Practice header support now says `Build the read one spot at a time.`
- Daily Practice hero support now says `One short rep keeps this table clue fresh.`
- Launchable current repair support now says `Repeat the clue, not the whole lesson.`
- Active repair row support now says `This rep uses the same table clue you missed.`
- No-active-fix fallback now says `First-week goal: understand the spot, not rush the map.`
- Topic/short-rep support now says `A good rep is one clearer table decision.`

These changes keep Practice narrow: one short rep, one clue, one table decision. They do not present Practice as a broad drill gym.

## First-Week Content/Copy Changes

- The first-week weak-spot recommendation now uses visible support copy:
  `Repeat the table clue before it becomes a habit.`

This ties Home repair intent to the same table-clue rationale used by Practice without adding new lessons, route nodes, packs, worlds, or content systems.

## Continuity With Wave 2.1 And Wave 2.2

- Wave 2.1 `Fix landed` / Session Summary payoff copy and behavior were not changed.
- Wave 2.2 launchable current repair ordering remains covered: current repair stays above the daily hero.
- Passive saved repairs remain secondary.
- Session Summary ordering was not touched; `What next` remains owned by Wave 2.2.
- `Practice this` launch behavior and repair queue target routing were not changed.

## Claim-Safety Proof

The new visible copy avoids these forbidden claim families:

- AI
- GTO
- solver
- leak fixed / fixed forever
- mastered
- cleared / resolved / recovered
- all-time
- rating / radar
- Level / Lv as proof
- badge art
- premium/paywall pressure
- broad drill catalog claims

The copy says what the user is repeating and why it matters; it does not claim permanent resolution, mastery, durable history, or solver-grade correctness.

## Boundary Proof

No route, progression, telemetry, data model, repair projection, repair consumer, achievement, Review history, queue resolution, durable proof, premium, or Modern Table logic changed.

The touched files are presentation/copy surfaces and their focused widget tests only.

`docs/_reviews/current_agent_context_v1.md` was requested by the prompt but is not present in this checkout; this did not block the wave.

## Tests And Validation

Focused red checks first failed for the intended missing copy:

- `flutter test test/ui_v2/act0_play_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Debug Day 2 proof surfaces expose open repair return story"`

Focused green checks passed:

- `flutter test test/ui_v2/act0_play_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Debug Day 2 proof surfaces expose open repair return story|Practice keeps unseen daily and topic reps locked until the route clears them|Home shows done-for-today state after daily goal is reached"`

Final validation is recorded in the commit/final report for:

- touched-file format check
- `flutter analyze`
- `git diff --check`
- `graphify hook-check`
- `git status --short`

## Screenshot Proof

Not run.

Reason: this wave changed narrow copy in already-covered widget-tested Practice and first-week Home/Practice support surfaces. It did not change layout structure, shared shell geometry, route navigation, runner behavior, table geometry, or broad visual density. The prompt says screenshots should not run by default and should only run when visible layout/copy changes are broad enough that visual proof is useful.

Existing generated screenshot output under `output/screen_review/` remains untracked.

## Caveats

- Some preview test fixtures still contain older sample strings such as `Practice this spot before it becomes a habit.` as inert manually supplied data. They are not the active recommendation source changed in this wave.
- The TOP1 plan still has older active-wave wording in its header; this implementation prompt and the Wave 2.2 artifact supersede that for this wave.

## Next Recommended Step

Proceed to Wave 2.4 - Beta Handoff Packet if no new beta-user or screenshot evidence shows a concrete Practice/first-week regression.
