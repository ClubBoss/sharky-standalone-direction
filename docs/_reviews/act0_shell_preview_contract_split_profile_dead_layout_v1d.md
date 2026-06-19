# Act0 Shell Preview Contract Split v1d - Profile Dead Layout Contract Rewrite

Date: 2026-06-18
Mode: bounded Profile test-contract rewrite
Scope: stale Profile assertions in `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

## 1. Wave Admission

This wave only rewrote Profile-facing test assertions that targeted dead or
unmounted Profile layout widgets. Product code, routes, content, localization,
telemetry, commerce, premium/trial/paywall surfaces, screenshots, table
geometry, Home, Learn, and Review behavior were not changed.

## 2. PIEC Result

`Act0ProfileShellV1.build` currently mounts:

- `act0_shell_profile_hero_card`
- `act0_shell_profile_identity_summary`
- `act0_shell_profile_next_milestone`
- `act0_shell_profile_streak_nudge`
- `act0_shell_profile_progress_proof`
- `act0_shell_profile_skill_stats` when `skillStats` is present

The old Profile support family remains in source but is not mounted:

- `_ProfileStorySupportBandV1`
- `_ProfileCurrentFocusCardV1`
- `_ProfileRecentGainsCardV1`

Tests asserting `act0_shell_profile_story_support_band`,
`act0_shell_profile_recommended_focus`, or
`act0_shell_profile_recent_skill_gains` were stale relative to the current
mounted Profile contract.

## 3. Dead-Layout Profile Test Inventory

Rewritten against mounted Profile surfaces:

- `Correct answer adds a recent skill gain to Profile`
- `Skill gains and profile skill stats survive a fresh dev shell mount`
- `Profile compact recent-progress stack keeps one light summary above payoff rows`
- `Profile ties progress, identity, focus, and strengths into one story`
- `Profile keeps next milestone above rhythm support`
- `Profile groups next milestone and progress proof in the mounted story stack`
- `Profile keeps identity summary above rhythm so the first story stays focused`
- `Profile progress proof shows skill gain and rhythm without scar language`
- `Profile shows stronger learner-progress payoff without turning into a dashboard`
- `Profile recent progress keeps one dominant proof before support detail`
- `Profile recommended focus returns the user to Home`

Blocked/deferred:

- `Second wrong answer becomes a deeper Review leak` still fails before it
  reaches Profile, because the Review assertion for `Deep leak` is stale.
- `Representative Play packs feed matching skill families into Profile` still
  fails before Profile, in Practice group setup.

## 4. Mapping Applied

- Old recommended focus card -> current `act0_shell_profile_next_milestone`.
- Old recent gains card -> current `act0_shell_profile_progress_proof` and
  `act0_shell_profile_skill_stats`.
- Old story support band -> current mounted ordering between next milestone,
  rhythm, progress proof, and skill stats.
- Old identity support card -> current `act0_shell_profile_identity_summary`.
- Old combined skill-gain text in some places -> current label plus gain chip
  or current compact `Recent progress` skill-stats line.

## 5. Verification Snapshot

Before this wave:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
  measured `+555 -70`.

After this wave:

- Changed pure Profile tests pass in isolation.
- The broad preview file measured `+597 -59`.

## 6. Deferred Groups

Remaining broad preview failures are outside this wave: Home retention rows,
Placement/Welcome, Review harness, compact runner/table geometry, Learn
scroll/chronology, Practice pack setup, and content chronology.

## 7. Recommended Next Wave

`Act0 Shell Preview Contract Split v1e - Review Repair Harness`

Bounded scope:

1. Rewrite only stale Review repair/deep-leak/replay assertions.
2. Do not touch Profile, Home, Learn, Placement, Welcome, content chronology,
   localization, screenshots, table geometry, commerce, premium/trial/paywall,
   or repair-intent feature behavior.
