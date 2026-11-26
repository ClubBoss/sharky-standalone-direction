# App Store text — English (U.S.)

Draft for owner approval, not submitted metadata. Copy only the field contents;
the evidence below is for the owner. Based on the active Act0 route at
`origin/main` a85177b9c2e79ede5d879e74f6db17e4c449c0a7 (2026-11-26).

## Name

Sharky Poker

## Subtitle

Practice poker decisions

## Promotional text

Learn micro-stakes Texas Hold'em decisions. Study a lesson, choose an answer,
see the explanation and practise the decisions you missed.

## Description

Sharky Poker is a learning app for Texas Hold'em players who want to practise
micro-stakes decisions.

Work through twelve learning worlds (W1–W12), from table position and hand
strength to betting decisions. Read the situation, choose an answer and see
why it works.

When you make a mistake, try the decision again or return to it in Review.
Use Practice to work on decisions outside the lesson. Your learning progress
is saved on your device so you can continue later.

The lessons use simulated hands and training chips with no cash value. There
is no real-money play, betting for money or cash prize. No account is needed.

## Keywords

holdem,microstakes,positions,hand rankings,pot odds,bet sizing,lessons,review,practice

## What's new

First release: Twelve learning worlds with poker lessons, decision practice,
answer explanations and mistake review.

For an initial App Store release, use this as the release summary; enter
What's New only if the field is available. For an update, replace it with
changes verified in that specific build.

## Claim-to-feature check (not store copy)

Paths below are relative to `lib/ui_v2/act0_shell/` unless stated otherwise.

| Claim / field | Feature and source |
|---|---|
| Name, poker education, micro-stakes Hold'em (all fields) | Act0 learner catalogue and simulated decision tasks in `act0_shell_state_v1.dart`; established name in `docs/RELEASE.md`. |
| Twelve worlds, positions, hand strength, bets; related keywords | W1–W12 catalogue in `act0_shell_state_v1.dart`; extended W13+ pilot is debug gated in `act0_curriculum_pilot_v1.dart`. Progression applies; not a promise that every world is open on first launch. |
| Lessons, choices, explanation, pot odds and sizing | Lesson tasks in `act0_shell_state_v1.dart`, rendered and graded in `act0_lesson_runner_shell_v1.dart` and its parts. |
| Retry, Review and Practice | `act0_shell_preview_screen_v1.dart` and its learning-run parts; repair and review queues recorded in the persisted progress. |
| Saved progress and continuing later | `act0_shell_preview_persistence_v1.dart`, `act0_progress_store_v1.dart`. |
| Simulated hands/chips, no cash stakes or prize, no account | Active entry `lib/main.dart` → `lib/ui_v2/app_root.dart` → Act0; catalogue and lesson runner use educational hand states. No real-money transaction or account flow on this route. |

Owner before submission: [[OWNER: approve name and rights, final screenshots,
age questionnaire and exact signed RC]]. Do not promote debug pilots, cloud
sync, AI coaching, or outcomes at real poker tables. Check fields against
[Apple's product page guidance](https://developer.apple.com/app-store/product-page/).
