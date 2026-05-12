# LAUNCH_SURFACE_MECHANISM_v1

Status: ACTIVE
Purpose: define how the active learner-facing surfaces work together as one
product mechanism for current planning and wave design.
Last updated: 2026-05-10

## Authority

Use this document as the working surface contract beneath
`docs/plan/MASTER_PLAN_v3.0.md`.

It does not replace the master plan.

Use `MASTER_PLAN_v3.0.md` for:

- next-lane selection
- priority order
- bounded-wave execution policy
- current calibrated runway

Use this document for:

- role clarity across Placement, Home, Learn, Play, Review, You, Table, and Result
- deciding what belongs on each active surface
- deciding what should be removed, compressed, or moved to another surface
- planning launch-surface coherence waves without reopening broad system design

## Product Mechanism

The product should behave like one guided learning machine, not like a group of
loosely related screens.

Canonical loop:

1. `Placement` establishes trust and picks the right starting depth.
2. `Home` gives the best next action right now.
3. `Learn` shows the canonical forward path.
4. `Table` delivers one high-quality teaching rep.
5. `Result` closes the rep and hands the learner to the right next place.
6. `Review` repairs weak spots when needed.
7. `Play` gives optional extra practice without competing with the main path.
8. `You` turns progress into identity and visible growth.

Primary route:

`Placement -> Home -> Learn -> Table -> Result -> Home`

Secondary branches:

- `Home -> Play`
- `Result -> Review`
- `Home -> You`

This means the app should always have one dominant forward route.
All other surfaces support that route instead of competing with it.

## Surface Contract

Each surface must answer one unique learner question.

| Surface | Learner question | Core job | Must not become |
| --- | --- | --- | --- |
| `Placement` | "Am I in the right place, and where do I start?" | trustful routing | setup work, long onboarding, or a lesson |
| `Home` | "What should I do right now?" | command center and re-entry dispatch | dashboard, catalog, or system chooser |
| `Learn` | "Where am I on the course path?" | canonical sequential route | encyclopedia, freeform content browser, or duplicate of Play |
| `Table` | "What is the one thing I need to do in this rep?" | premium teaching core | crowded training console or explanation wall |
| `Result` | "What just happened, and what do I do next?" | closure and handoff | stat dump or celebration noise |
| `Review` | "What should I fix next?" | repair lane | punishment zone, taxonomy browser, or second Learn |
| `Play` | "How can I practice extra without pressure?" | optional accelerator | mode showroom or second world map |
| `You` | "What kind of player am I becoming?" | identity and growth mirror | data warehouse or admin profile |

If two surfaces answer the same question, one of them is underdefined or
duplicating product work.

## Surface Vision

### Placement

`Placement` is a routing and trust layer, not a core destination.

It should:

- feel short
- feel confident
- remove fear of starting
- hand the learner into the product cleanly

It should not:

- feel like a long test
- explain the whole system
- ask the learner to choose a product model

### Home

`Home` is the command center.

It should contain:

- one dominant next-step CTA
- one short state line
- one compact secondary branch
- one compact repair cue when needed

It should not contain:

- multiple equal-priority action blocks
- several competing paths above the fold
- system-state clutter

### Learn

`Learn` is the canonical forward path.

It should:

- feel sequential
- show where the learner is now
- show what is next
- show what is locked and why

It should not:

- feel like a content shelf
- compete with Play for the same job
- overload the learner with too many equal starting points

### Table

`Table` is the premium core experience.

It should:

- teach one concept at a time
- keep one clear decision moment visible
- keep the learning task dominant
- avoid competing information blocks

It should not:

- explain the whole course
- feel like a poker simulator console
- carry unrelated product chrome

### Result

`Result` is the loop handoff.

It should:

- explain the immediate outcome clearly
- reinforce the key lesson
- route the learner to the correct next place

It should not:

- stall the loop
- bury the next step
- turn into a noisy reward wall

### Review

`Review` is a repair lane.

It should:

- foreground one useful repair action
- explain why this repair matters
- show recovery without shame

It should not:

- present a taxonomy-first UI
- feel punitive
- become a second curriculum browser

### Play

`Play` is the optional practice branch.

It should:

- be obviously secondary to Learn
- be understandable in a few seconds
- offer quick, useful extra reps

It should not:

- compete with Learn as another main route
- become a mode catalog
- recreate a second map of the product

### You

`You` is the identity mirror.

It should:

- show current strengths
- show one visible growth edge
- translate progress into a personal story

It should not:

- lead with raw stats
- look like an admin profile
- create dashboard bloat

## Design Consequences

The surface contract above implies the following product decisions:

1. `Home` owns urgency and next-step direction.
2. `Learn` owns the main path.
3. `Play` must stay visibly secondary to `Learn`.
4. `Review` must stay repair-first, not taxonomy-first.
5. `You` must stay identity-first, not data-first.
6. `Result` must always hand back into `Home`, `Learn`, or `Review`.
7. `Placement` should fade away after routing instead of acting like a persistent destination.

## Planning Rules

When planning a launch-surface wave:

1. Pick one primary surface family to improve.
2. Allow adjacent surfaces only when they are required to preserve role clarity.
3. Stop immediately if the wave starts reopening unrelated product lanes.
4. Prefer moving or deleting confusing UI over adding more explanatory UI.
5. If a surface needs two primary actions, simplify it until one action wins.

## Next Wave Guidance

Given the current `MASTER_PLAN_v3.0` priority order and launch-surface runway,
the default next surface wave should be:

`Home / Learn / Play role clarification`

Why:

- `Home` owns re-entry and next-step clarity
- `Learn` owns the canonical path
- `Play` is the most likely duplicate/confusion source if left underdefined

Only after that wave is materially clearer should the next default work move to:

1. `Review` as repair lane refinement
2. `You` as identity/progress mirror refinement

Implementation note (2026-05-12):

- The first `Home / Learn / Play` clarification wave is now the active landed
  contract in code.
- `Home` keeps one dominant next-step block while extra reps are explicitly
  framed as optional.
- `Learn` now states that it owns the main route and that `Play` only adds
  extra reps.
- `Play` now leads with one featured recommended rep before the secondary
  practice sections.

## Success Test

The surface mechanism is working when all of the following feel true:

1. The learner always knows the best next step.
2. The main path is obvious without explanation.
3. Optional practice feels useful but not distracting.
4. Mistakes feel repairable, not punitive.
5. Progress feels personal, not statistical.
6. No active surface feels like a duplicate of another.
