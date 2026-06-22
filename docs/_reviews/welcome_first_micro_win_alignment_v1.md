# Welcome First Micro-Win Alignment v1

## Scope

One bounded first-use activation change. No placement questionnaire, diagnostic,
curriculum map, World 0, Modern Table visuals, commerce, or screenshot tooling
changed.

## Reused seams

- `Act0WelcomeShellV1` remains the one-time, replayable Welcome owner.
- The micro-win reuses the existing W1 `actions_check_drill` runner state:
  `No bet yet -> Check`.
- The interaction is hosted with local Welcome selection state only; it does
  not record task completion, XP, repair data, telemetry, or curriculum
  progress.
- Existing placement result routing retains its selected recommended W1 task.

## User-visible behavior

Welcome now has three compact beats:

1. a short route explanation;
2. one real table-adjacent action choice with immediate existing runner
   feedback;
3. a clear route handoff.

The interaction is a guided success, not another diagnostic. Wrong choices
remain local to the Welcome screen and create no repair obligation.

## Route and completion truth

- First-time standard Welcome completion persists only
  `act0_welcome_completed_v1`, then lands on Home with W1 focused.
- A placement-recommended learner now enters Welcome before the existing
  recommended W1 hand. After completing the micro-win, that hand opens through
  the existing first-value path.
- Welcome replay still returns to Profile and does not reset world, lesson, or
  task progress.
- No World 0, map node, lesson, task completion, or curriculum mutation is
  created by the micro-win itself.

## Checks

- targeted Welcome micro-win, placement routing, first-value receipt,
  completed-Welcome boot, replay, and W1 handoff tests;
- `dart format` on touched Dart files;
- `flutter analyze`;
- `git diff --check`;
- fast core screen-review command.

## Intentional limits

This prepares the activation contract for a later visual / UX redesign. It
does not attempt that redesign, add animation, change the table renderer, or
extend onboarding into a course.
