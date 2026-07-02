# Visual Proof Capsule v1

Status: ACTIVE visual/proof capsule.
Freshness date: 2026-07-03.
Verified product HEAD: pending commit (this task's own commit advances it).
Verified active route artifact: `docs/_reviews/w2_w6_completion_payoff_v1.md`.
Refresh trigger: every committed visual token, surface acceptance, screenshot
lane, proof/progression, motion, or design-system change.

## Accepted Visual System

- Shell: navy app frame and dense premium surfaces.
- Felt: deep teal-green material.
  - base `#146B56`
  - shadow `#0F5A47`
  - deep `#0B4A3B`
- Rail: `#14273A`
- Primary CTA: flat blue `#0A64D8`
- Pressed primary CTA: `#0858BE`
- CTA label: white
- Gold: earned/proof emphasis only; no gold button identity.
- Panels on felt: navy-glass, not bright cyan cards.
- Objective flag: neutral teal, not reward gold.

## Accepted / Frozen Surfaces

- Premium Visual Foundation is CLOSED; the static premium visual regression
  passed with no P0 or new P1 visual regression.
- Welcome: accepted.
- Review: accepted.
- Table felt: accepted.
- Home structure: frozen unless evidence reopens it.
- Practice structure: frozen unless evidence reopens it.
- Profile: frozen unless evidence reopens it.
- Bottom nav: frozen.
- Feedback structure: frozen.

Do not reopen a frozen surface for adjacent polish unless the active prompt
names that surface or new evidence shows a concrete defect.

## Current Proof State

Session Summary's existing gold-contained proof receipt consumes the structured
banked-fix projection when available and retains its repair-outcome fallback.
Cross-Session Proof Profile landed in the existing Profile `Progress proof`
card: it consumes lifetime and recent proof while preserving the navy-glass
hierarchy. Achievement Visual Language / Icons v1 landed a small shared
`Act0ProofIconV1` seam (`lib/ui_v2/act0_shell/act0_proof_icon_v1.dart`) with
three semantic roles (`repairCompleted`, `reinforced`, `milestone`). W1
Completion Payoff v1 gave `milestone` its first valid consumer via a shared
`_WorldMilestoneCardV1` layout inside `Act0BlockCompletionShellV1`. W2-W6
Completion Payoff v1 extended that same shared card to ordinary World 2-6
completions (`_WorldCompletionPayoffV1`, gate
`Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff`): one milestone seal,
one deterministic curriculum-true learning-takeaway line per world (sourced
from each world's real title/subtitle in `act0_shell_state_v1.dart`), a gated
`repairCompleted`/`reinforced` proof row sourced from the same banked-fix
receipt, a safe no-proof fallback, and a route-truth next-world preview. World
1 keeps its own dedicated wrapper/copy unchanged; World 4 intentionally
receives the same ordinary treatment as W2/W3/W5/W6 (no band-transition
copy, no larger seal) so the future W4->W5 PR can safely claim a stronger
variant. No gallery, grid, motion, XP, level, mastery, or RPG badge economy
was introduced. The active task is `W4->W5 Band Transition Milestone`.

## Remaining Visual Route

1. Achievement Visual Language / Icons - CLOSED
2. W1 Completion Payoff - CLOSED
3. W2-W6 Completion Payoff - CLOSED
4. W4->W5 Band Transition Milestone - ACTIVE

No motion or generalized completion-payoff framework exists yet; the shared
`_WorldMilestoneCardV1` is a bounded, world-ID-gated layout reused by two
thin wrappers (W1-specific, W2-6 ordinary), not a public/reusable component.
`milestone` proof-icon role is used only by true world-completion moments
(W1-W6 now) and must remain scoped that way — W7-W12 payoff and the
W4->W5 band transition are the next dedicated stages, not a green light to
treat `milestone` as a generic achievement badge. The seam for the next PR:
`Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff` currently admits
worldNumber 4 into the ordinary path; the W4->W5 PR should add a
higher-priority `hasBandTransitionPayoff` gate (worldNumber == 4 &&
nextWorldNumber == 5) with its own dedicated widget, mirroring how W1 has its
own dedicated wrapper today, so W4 renders the stronger transition instead of
falling through to the ordinary card. Do not reopen generic visual design
outside a dedicated stage or concrete new regression evidence.

## Proof / Progression Rules

- Proof before points.
- No fake progress.
- No XP, coins, rating, radar, or level capability claims.
- Achievements must name real evidence.
- Sharky growth must be proof-triggered.
- Do not imply mastery, fixed-forever, public readiness, or learning effect
  without the required evidence gate.

## Screenshot Lanes

- `core compact`
- `first_week compact`
- `day2_return compact`
- `full_scroll compact`
- `active_route_w7_w12 compact`

Use screenshot artifacts only when visual evidence is required. Do not inspect
old `output/**` folders by default.

## Local-Only Rule

`output/**` is local evidence and is never committed unless a future prompt
explicitly admits a specific output artifact.

## Visual Acceptance

- Screenshots are required for UI claims.
- Motion evidence is required for motion claims.
- Do not write "looks okay" as evidence.
- State the exact screen, lane, artifact, and acceptance issue.
- Capture-tool artifacts can be evidence limitations; do not convert them into
  product defects without source/runtime confirmation.

## Agent Guidance

- Fable: define target state and art direction; do not edit route truth.
- Sonnet: handle design-sensitive bounded implementation or copy hierarchy.
- Codex: implement deterministic tokens/layout/tests/evidence and preserve
  scope boundaries.

## Reference Artifacts

- `docs/_reviews/focused_pre_human_visual_ux_upgrade_wave_v2.md`
- `docs/_reviews/apply_owner_patch_sequence_a_b_c_d_v1.md`
- `docs/_reviews/cta_rhythm_learn_cleanup_pr_v1.md`
- `docs/_reviews/static_premium_visual_regression_check_v1.md`
- `docs/_reviews/fixes_banked_weekly_proof_v1.md`
- `docs/_reviews/cross_session_proof_profile_v1.md`
- `docs/_reviews/achievement_visual_language_icons_v1.md`
- `docs/_reviews/w1_completion_payoff_v1.md`
- `docs/_reviews/w2_w6_completion_payoff_v1.md`
