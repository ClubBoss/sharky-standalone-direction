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

## Product Theses

The launch surfaces should also obey a few product-level truths:

1. **Trust the route faster than you explain it.**
   Entry and routing surfaces should create confidence quickly instead of
   stacking explanatory UI.
2. **Let progress be felt inside the learning loop.**
   The learner should feel forward movement in `Table` and `Result`, not only
   when opening `You`.
3. **Make the path feel like a world.**
   `Learn` should eventually deliver landmarks, journey identity, and forward
   pull, not only structure.
4. **Keep reward energy subordinate to learning clarity.**
   Streaks, Sharky, achievements, and celebrations should strengthen the route,
   not compete with it.
5. **Prefer premium coherence over isolated clever screens.**
   No single surface should invent its own visual dialect or reward grammar.

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
- resolve into one obvious first route, not a mini diagnostic report
- end with one compact trust/aha moment so the learner feels understood, not
  merely sorted

It should not:

- feel like a long test
- explain the whole system
- stack several explanatory panels before routing is obvious
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
- surface one clear current-chapter identity and one visible next-landmark cue

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
- make skill growth visible before the learner ever opens `You`
- reinforce the key lesson
- route the learner to the correct next place
- support the learner's sense of improvement, not only one-off task correction

It should not:

- stall the loop
- bury the next step
- turn into a noisy reward wall

### Review

`Review` is a repair lane.

It should:

- foreground one useful repair action
- explain why this repair matters
- keep the prominent mistake card to one diagnosis, one contrast, and one next step
- show recovery without shame
- mature toward grouped pattern coaching when repeated mistakes point to one
  learner habit, not only isolated task-by-task repair

It should not:

- present a taxonomy-first UI
- feel punitive
- repeat the same repair signal through duplicate badges, labels, and helper rows
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

- show who the player is becoming in one quick scan
- make skill growth more visible than generic profile stats
- keep streak and achievements as proof, not as the whole story
- translate progress into a personal story

It should not:

- lead with raw stats
- look like an admin profile
- create dashboard bloat

Canonical `You` structure:

1. one compact identity hero
2. one primary poker-skills board, preferably compact enough to scan as a short grid instead of a long dashboard list
3. one compact rhythm / streak block
4. one achievements preview with a compact grid and collection drill-down
5. route/focus notes only as a quiet secondary footer

## Design Consequences

The surface contract above implies the following product decisions:

1. `Home` owns urgency and next-step direction.
2. `Learn` owns the main path.
3. `Play` must stay visibly secondary to `Learn`.
4. `Review` must stay repair-first, not taxonomy-first.
5. `You` must stay identity-first, not data-first.
6. `Result` must always hand back into `Home`, `Learn`, or `Review`.
7. `Placement` should fade away after routing instead of acting like a persistent destination.
8. celebrations and habit signals must stay subordinate to learning clarity on
   every active surface

## Planning Rules

When planning a launch-surface wave:

1. Pick one primary surface family to improve.
2. Allow adjacent surfaces only when they are required to preserve role clarity.
3. Stop immediately if the wave starts reopening unrelated product lanes.
4. Prefer moving or deleting confusing UI over adding more explanatory UI.
5. If a surface needs two primary actions, simplify it until one action wins.

## Next Wave Guidance

Given the current launch-surface runway, the default next surface waves should
now be:

1. `Table / Result` felt-growth pass
   Landed direction: correct reps now surface compact skill-gain highlights in
   feedback and block summary instead of leaving all growth to XP and profile.
2. `Learn` world-feel refinement
3. shell-wide premium consistency pass
   Landed direction: active shell surfaces now share the same compact
   rectangular chip and CTA language instead of mixing pill and panel dialects.
4. `Sharky / rewards / habit` coherence pass
   Landed direction: active shell reward language now stays tied to repair,
   rhythm, clean reads, and real proof events without default `Sharky says`
   prefix spam.

Implementation note (2026-05-13):

- `Home / Learn / Play` role clarification is landed.
- `You` is now materially more identity-first and less dashboard-heavy.
- `Review` is materially more repair-first and less dense in the prominent
  mistake card.
- `Placement` now behaves more like fast trusted routing and less like a
  stacked multi-panel report.
- the strongest remaining product gap is no longer route ownership. It is the
  lack of strongly felt growth and payoff inside the `Table -> Result` loop.
- `Home` should stay compact: the course label is secondary, the primary CTA
  should not be followed by another duplicate CTA hint, and the extra-rep lane
  should read as one tight optional action rather than a second mini-screen.
- `Learn` first-open behavior should land on the active lesson itself, not the
  page top, and should preserve the existing scroll-first then open contract.

## Success Test

The surface mechanism is working when all of the following feel true:

1. The learner always knows the best next step.
2. The main path is obvious without explanation.
3. Optional practice feels useful but not distracting.
4. Mistakes feel repairable, not punitive.
5. Progress feels personal, not statistical.
6. No active surface feels like a duplicate of another.
