# MONETIZATION_TIMING_GUARD_v1

## Purpose

Define the first canonical monetization timing guard for the learning product so future monetization decisions are governed by an explicit value-first / habit-first contract instead of local intuition or short-term pressure.

This layer governs when monetization friction is allowed to increase.
It does not define pricing, offer design, ad systems, or entitlement implementation details.

## Governs Now

This SSOT governs:
- the core rule that value and habit must precede stronger monetization friction
- what must already be true before stronger monetization surfaces are allowed
- what kinds of monetization surfaces are acceptable earlier vs later at a principle level
- what kinds of monetization are explicitly disallowed too early

This SSOT does not yet govern:
- exact pricing
- subscription tier design
- ad implementation
- paywall UI design
- runtime entitlement logic
- experiment policy or conversion optimization

## Core Rule

Value and habit before monetization friction.

Operational meaning:
- the learner must first feel real product value
- the learner must first experience a believable repeat-return loop
- stronger monetization pressure must not arrive before trust, usefulness, and habit have been earned

## Current Launch Timing Lock (2026-06-18)

Current launch-facing timing decisions:

- soft premium preview is allowed after completed daily/session learning value;
- the soft preview is not a paywall, trial start, purchase CTA, restore surface,
  or Premium Hub route;
- no trial before placement, first hand, first feedback, first completion, or
  the soft preview;
- no trial inside the soft preview;
- contextual 7-day trial is deferred to a future W5 locked-depth/paywall
  attempt, or later high-intent proof, after commerce safety is
  production-ready;
- public hard paywall, pricing, purchase, restore, and Premium Hub exposure are
  deferred until commerce safety is closed.

Current route-boundary default:

- `W1-W4` free public foundation;
- `W5+` future paid-depth boundary;
- W4 is a future challenger / A-B candidate, not launch-default;
- W3 is not a launch-default paid gate.

Premium preview copy must remain boundary-neutral until W4/W5 route/content
truth is normalized. Do not encode `Unlock W4`, `Unlock W5`, `W5 is premium`,
`Bet Purpose is premium`, or any world-number unlock promise into preview,
paywall, or trial copy.

## Primary Principle

Monetization may amplify a product that is already useful.
It must not be used to compensate for weak learning value, weak trust, or weak return motivation.

If monetization creates pressure before the learner has felt real progress, it is too early.

## Preconditions For Stronger Monetization Pressure

Before stronger monetization pressure is allowed, all of these should already be true:

- the learning core is real and visibly useful
- the learner can complete a meaningful free value loop
- the product has a believable return habit, not just one-off curiosity
- progress feels real, not fabricated
- the surfaced path is status-honest and not hiding major structural immaturity

Practical interpretation:
- “reachable” is not enough
- “interesting on first open” is not enough
- “technically monetizable” is not enough

## Minimum Value-First Conditions

At a principle level, these conditions should exist before stronger friction:

### 1. Real Free Value Exists

The learner can get meaningful instructional value without immediate commercial pressure.

Examples:
- usable free core worlds
- a real Today loop or equivalent repeatable value path
- at least one coherent bounded path that teaches something tangible

### 2. Repeat Return Logic Exists

The learner has a reason to come back because the product remains useful, not because friction is forcing a decision.

Examples:
- a daily ritual loop
- visible progress
- recap/review/return value

### 3. Trust Is Preserved

The learner should not feel tricked into pressure before they understand the product’s value.

Examples of preserved trust:
- no misleading blocked promises
- no fake scarcity
- no disguised core-value withholding

## Monetization Surface Timing Bands

Use these timing bands as principle-level guidance:

### Early-Allowed

Allowed early only if low-friction and non-disruptive:
- passive premium hooks existing in architecture
- non-dominant premium labeling
- low-pressure mention that a deeper layer may exist later
- entitlement-ready plumbing with no aggressive exposure

These are acceptable because they do not interrupt the value-first path.

### Mid-Later Allowed

Allowed only after value and return habit are already believable:
- clearer premium surface explanation
- upgrade prompts tied to already-felt value
- premium depth framing for stronger or returning learners
- optional expansion offers after trust is established

These may exist only when the learner can already say:
- “this product helps me”
- “I know why I would come back”

### Late / Strictly Deferred

Only acceptable after the product clearly has durable value and habit strength:
- stronger paywall frequency
- deeper premium progression systems
- economy-heavy upsell loops
- more assertive monetization entry points

These are late because they carry higher friction and greater trust risk.

## Explicitly Disallowed Too Early

The following are disallowed before value / trust / habit are established:

- aggressive paywalls on first meaningful use
- friction that interrupts the first believable learning loop
- monetization pressure before felt value
- fake urgency or guilt framing
- ad-heavy interruption of early learning flow
- monetization that blocks the learner before the product has proved usefulness
- economy or offer pressure used as a substitute for weak retention

## Anti-Pattern Rule

Monetization is too early if any of these are true:
- the learner has not yet completed a meaningful free success loop
- the learner has not yet seen real progress or improvement
- the product still depends on future fill to feel coherent
- the monetization surface is louder than the learning value
- conversion pressure would arrive before habit credibility

## Relationship To Other SSOTs

This layer depends on earlier truth layers:

- `WORLD_PROGRESSION_PACING_SSOT_v1`
  - value must come through healthy pacing, not rushed concept delivery
- `PREREQUISITE_DIFFICULTY_MATRIX_v1`
  - monetization should not hide dependency holes or weak foundations
- `CONTENT_FACTORY_RELEASE_GATE_v1`
  - content must be honestly ready before monetization pressure leans on it
- `RETENTION_RHYTHM_ANTI_BOREDOM_v1`
  - habit should come from meaningful return rhythm, not pressure tricks
- `SESSION_ENERGY_BUDGET_v1`
  - a tiring session loop should not be monetized as if it were already healthy
- `LONG_HORIZON_MASTERY_MAP_v1`
  - stronger monetization can only be justified when long-horizon value is believable

This SSOT does not replace those layers.
It only defines when monetization may safely sit on top of them.

## “Ready For Stronger Monetization” Meaning

At this stage, “ready for stronger monetization” means:

- the product already delivers real learner value
- the free path is credible enough to build trust
- repeat use is supported by real usefulness and progression
- the product has enough depth that monetization feels like expansion, not rescue

It does not mean:
- pricing is finalized
- paywall placement is finalized
- entitlement rules are fully implemented
- all business questions are solved

## Decision Table

| Situation | Required decision |
| --- | --- |
| learning core is still structurally immature | do not increase monetization pressure |
| free path gives real value but return habit is weak | improve retention/value loop before stronger monetization |
| learner trust is not yet established | avoid stronger monetization surfaces |
| durable value and repeat-return are already credible | optional mid-later monetization surfaces may be considered |
| monetization would interrupt the first believable success loop | disallow it |

## Governing Use Rule

Before approving a future monetization proposal, ask:

1. Has the learner already felt real value?
2. Is there already a believable repeat-return habit?
3. Would this surface preserve trust?
4. Is this monetization amplifying value, or trying to compensate for missing value?
5. Is the proposed pressure level appropriate for the current maturity of the product?

If those answers are unclear, the monetization timing is not justified yet.

## Out Of Scope

This SSOT does not yet define:
- pricing models
- offer ladders
- ad placement specifics
- subscription packaging
- paywall copy/design
- runtime entitlement enforcement
- experiment cadence
- commercial forecasting

Those belong to later business/product layers if still justified.
