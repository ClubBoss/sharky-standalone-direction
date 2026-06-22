# Welcome / Placement Micro-Aha Alignment v1

## Scope

Audit / PIEC only on `main` at `86512b2b0b4cc3f58860bd31cdf421a5d1ddf17a`.
No product code, UI, copy, tests, assets, or generated artifacts changed.

## Inspected files

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

## Current first-start flow map

```
App boot
  -> intake incomplete: Placement intro
       -> experience question
          -> explicit new player: Start from zero
             -> one-time Welcome (two text/preview beats)
             -> Home, with W1 / Poker from Zero seeded as the route focus
          -> other starting point: confidence question
             -> three placement quick checks
             -> placement result
             -> Start with useful hand: direct runner
             -> Start from beginning: Welcome -> Home
  -> intake complete + Welcome incomplete: Welcome -> Home
  -> intake complete + Welcome complete: Home
```

## Placement verdict

Placement is purposeful and value-aware, not generic setup: it asks only
experience and confidence, offers a clear beginner bypass, and gives
non-beginners a table-adjacent three-check route result. It also stays clear of
premium/trial pressure before the first hand.

The non-beginner route is nevertheless heavy for an activation layer: intro,
two questions, a diagnostic-ready screen, three assessment-only checks, and a
result choice occur before the ordinary learning route. The quick checks are
useful routing evidence, but their code intentionally suppresses lesson
teaching copy; they are not the promised guided success loop.

Verdict: retain the short two-question placement contract and its beginner
bypass. Do not expand its report, profile signals, or diagnostic inventory.

## Welcome verdict

Welcome exists, is post-placement, one-time persisted, and replayable from
Profile without changing route progress. It correctly sits outside the Learn
map and returns a first-time learner to Home with `Poker from Zero` focused.

The current renderer intentionally compresses the layer to two beats:
`Find your start` and `Your path is ready`. Its visual launch path and loop
strip explain the product shape, but they are previews rather than product use.

Verdict: the Welcome layer is short and route-safe, but it is an explanation
and handoff layer, not yet a micro-aha layer.

## Micro-aha verdict

No first micro-win exists before normal routing:

- the Welcome test explicitly asserts that `act0_shell_welcome_demo_spot` is
  absent;
- the Welcome shell contains no table interaction or feedback state;
- Placement's quick checks are diagnostic / assessment-only and do not provide
  the guided success and calm feedback required by the Master Plan.

This is a real product gap, not a copy or visual-polish problem. It also does
not yet connect the activation moment to the landed visible repair/proof loop.

## Handoff verdict

The zero-start path is coherent: Welcome completes, persists its flag, and
lands on Home with the W1 route focus. The diagnostic result's `Start with the
useful hand` path intentionally starts the runner directly and bypasses
Welcome. That makes the first-use story branch by placement outcome instead of
having one consistent activation proof path.

Verdict: handoff is functional but not fully aligned. A later micro-aha slice
must preserve direct usefulness while normalizing the proof/handoff story.

## Highest-EV next slice

Implementation is justified, but only as a narrow separate wave:

1. preserve the existing two-question placement and explicit beginner bypass;
2. preserve the current one-time Welcome persistence and Profile replay seam;
3. add one standalone table-adjacent, guided-success interaction inside the
   existing Welcome family, using an existing beginner-safe deterministic task
   seam rather than a World 0, new curriculum node, or new diagnostic;
4. show one calm feedback moment, then hand off to Home with `Poker from Zero`
   as the dominant next action;
5. route the existing recommended-start outcome through the same first-use
   proof contract, or document a strictly equivalent direct handoff.

This work needs a separate approval and must define the exact existing task
seam before implementation. It should not create repair debt, fake failure,
new runner business state, or another explanation wall.

## Not now

- no World 0 or Learn-map node;
- no longer placement questionnaire, diagnostic, score/report, or Profile
  analytics expansion;
- no multi-beat onboarding course or product brochure;
- no Sharky-character expansion;
- no navigation redesign, monetization, AI/chat, or Modern Table visual work;
- no screenshot tooling work as a substitute for the missing interaction.

## Recommendation

Recommended next prompt title:

`Welcome First Micro-Win Alignment v1 — Local Only`

The wave should be implementation, not another capture pass or a no-op. Its
acceptance evidence should later show one guided correct interaction, calm
feedback, persisted one-time completion, and a clean `Poker from Zero` handoff.
