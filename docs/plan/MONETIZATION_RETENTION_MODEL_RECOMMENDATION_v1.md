# MONETIZATION_RETENTION_MODEL_RECOMMENDATION_v1

Status: ACTIVE
Last updated: 2026-05-14

## Purpose

Define the recommended monetization and retention model for the current Sharky
product, based on:

1. current product shape
2. current implementation reality
3. current release risks
4. external subscription-app best practices

This document is a strategy recommendation.
It does not replace:

- `docs/plan/MONETIZATION_SSOT_v1.md`
- `docs/plan/MONETIZATION_TIMING_GUARD_v1.md`
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`
- `docs/plan/APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.md`

## Current Reality

As of 2026-05-14:

1. the active Act0 learner route is strong and internally stable
2. premium/trial preview surfaces exist in the active route
3. deterministic release-grade entitlement truth is not closed yet
4. the strongest current product value comes from:
   - trust
   - first improvement signal
   - repair usefulness
   - return usefulness
5. the biggest remaining release monetization risk is not paywall design
   quality, but truth mismatch between:
   - premium preview language
   - actual entitlement / purchase / restore / trial behavior

This means the main monetization question is no longer:

- "should Sharky monetize at all?"

It is now:

- "what monetization model best fits the product shape and can be shipped
  truthfully?"

## Strategic Evaluation

### Model A. Hard early paywall

Definition:

- strong paywall on first session or before the first useful loop

Pros:

- can increase short-term trial starts
- can lift monetization quickly in high-PMF subscription apps

Cons:

- highest trust risk
- highest novice drop risk
- wrong fit for a product still proving first-user aha and pedagogy externally
- conflicts with current Sharky SSOTs

Verdict:

- not recommended for current Sharky

### Model B. Weak teaser free path

Definition:

- free user sees the shape of the product but gets too little value to trust it

Pros:

- preserves more paid depth

Cons:

- damages retention
- lowers organic recommendation potential
- makes trial feel like rescue, not expansion
- conflicts with the current launch-boundary policy

Verdict:

- not recommended

### Model C. Value-first depth subscription

Definition:

- free route gives real trust-building value
- subscription unlocks deeper sharpening, longer retention value, and broader
  route depth

Pros:

- best fit with current product shape
- strongest alignment with long-horizon learning behavior
- best balance between retention, LTV, and learner trust
- compatible with current Sharky route docs

Cons:

- requires discipline on free/premium boundary
- requires truthful entitlement implementation
- requires patience before stronger monetization pressure

Verdict:

- recommended core model

### Model D. Economy-heavy or gamification-led monetization

Definition:

- lives, currencies, pressure loops, or upsell-heavy retention systems become a
  core revenue driver

Pros:

- can raise surface activity in some products

Cons:

- poor fit for Sharky's current product identity
- high noise risk
- easy to fake retention without real learning value
- conflicts with current product principles

Verdict:

- not recommended for current route

### Model E. No-paywall core plus paid companion services

Definition:

- the learning route stays broadly free
- revenue comes later from deep analytics, advanced review, exported reports,
  or specialist services around the core product

Pros:

- strongest first-touch trust
- lowest early-friction risk
- easiest model for organic recommendation

Cons:

- weak fit for the current beginner-heavy Sharky audience
- monetizes too late for the average user
- pushes revenue onto a minority of advanced users instead of the main learning path
- weakens the economic meaning of later worlds and specialization depth

Verdict:

- not recommended as the primary public model
- acceptable only as a secondary expansion layer later

## Recommended Core Model

Sharky should monetize as a:

**value-first, freemium-to-subscription, depth-and-sharpening learning product**

That means:

1. free must prove the app is genuinely useful
2. premium must feel deeper, sharper, and more personally useful
3. retention must come primarily from learning progress and return usefulness
4. monetization should amplify the habit loop, not interrupt it

## Best Long-Term Business Model

### Free layer

Free should include:

1. product understanding
2. placement / first-start trust
3. the first useful hand and result loop
4. a bounded but meaningful part of Volume I
5. basic repair / review usefulness
6. at least one believable daily-return reason

Free should prove:

1. "this app improves my poker decisions"
2. "this app is worth returning to"
3. "there is more useful depth beyond the free slice"

### Premium layer

Premium should own:

1. deeper route access
2. stronger replay and mastery value
3. richer weak-spot resurfacing
4. denser later-world value
5. later-volume and specialization depth
6. stronger long-term reasons to keep subscribing

Premium should feel like:

1. deeper sharpening
2. more precise next actions
3. more durable long-horizon growth

Premium should not feel like:

1. the first moment the app becomes useful
2. a tax on basic trust
3. a rescue path for a weak free product

## Recommended Packaging

### Subscription structure

Recommended:

1. one subscription group
2. annual plan as the default anchor
3. monthly plan as the lower-friction option
4. no weekly plan
5. no aggressive short-term urgency traps

Reason:

1. Sharky is a long-horizon learning product
2. annual aligns with retention, mastery, and later specialization
3. monthly reduces commitment friction without redefining the product around
   short-term novelty

### Trial policy

Recommended:

1. no trial on first touch
2. no trial before visible value
3. 7-day trial remains the best current fit
4. trial should be attached to a meaningful value moment

Best current fit:

1. soft premium preview after placement/result only as a low-pressure signal
2. stronger trial offer after:
   - first completed useful loop, and/or
   - first locked deeper route moment, and/or
   - second-session return proof

Reason:

1. the user needs enough time to integrate the app into a routine
2. very short trials optimize dashboard spikes more than durable learning
3. the app teaches a compounding skill, not a one-day utility

## Recommended Paywall Timing

### Early allowed

Allowed early:

1. low-pressure premium preview
2. clear "deeper route exists" messaging
3. non-blocking premium labels on later locked content

### Best main paywall moments

Best contextual moments:

1. after the user understands their route and first hand
2. when the user hits a meaningful deeper-route gate
3. after a clean repair or first obvious improvement signal
4. on a second-session return when deeper value is now believable

### Disallowed

Do not use:

1. app-open hard paywall
2. pre-value trial pressure
3. first-fail monetization pressure
4. fake scarcity or guilt framing

## Recommended Retention Engine

Sharky's primary retention engine should remain:

learn -> improve -> notice it -> repair -> return

Retention should be led by:

1. clearer next action
2. visible earned progress
3. useful repair
4. growing identity as a better player
5. compact Sharky warmth and encouragement
6. later specialization and mastery depth

Retention should not be led by:

1. streak fear alone
2. noisy mascot chatter
3. economy pressure
4. blocked basics

## Recommended Sharky Role

Sharky should support retention as:

1. a compact coach
2. a recognizable emotional layer
3. a reinforcement of useful next actions

Sharky should not become:

1. a chat system
2. a toy-like distraction
3. a substitute for real product value

Current recommendation:

1. keep Sharky compact
2. increase phrase distinctiveness and situational voice
3. improve memorability before adding any deeper mascot system

## Best Next Release Model

The best long-term model and the best next release posture are not currently the
same.

### Long-term best model

The best long-term model is:

- free trust-building route
- premium depth subscription
- annual default
- monthly secondary
- trial after value proof

### Best next release posture

There are only two truthful release options:

#### Option 1. Free-only release candidate

Best if:

- the goal is fastest truthful launch
- monetization wiring is not ready
- the team wants to prove retention and novice proof before commercial pressure

What to do:

1. hide or remove premium/trial prompts from the shipped route
2. ship the free learner route cleanly
3. validate retention and proof on a truthful free build

Best for:

- lower execution risk
- clean trust
- simpler release

#### Option 2. Premium-enabled release candidate

Best if:

- monetization must be active in v1
- the team is willing to finish entitlement truth before release

What to do:

1. unify entitlement truth
2. prove purchase / restore / trial start / expiry deterministically
3. ensure every premium surface is truthful

Best for:

- earlier revenue capture
- earlier price discovery

Risk:

- much higher release complexity
- greater trust risk if implementation truth lags copy

## Recommendation

### Best model overall

The best overall model for Sharky is:

**value-first free core + premium depth subscription**

This is the best combination for:

1. retention
2. LTV
3. learner trust
4. long-horizon route expansion

## Canonical Choice

To avoid rebuilding the monetization model later, Sharky should commit now to
one enduring model:

**premium-enabled, value-first, depth subscription from day one**

This does not mean:

- hard paywall from day one
- aggressive trial pressure from day one
- monetization louder than usefulness

It means:

1. the public product shape already matches the long-term business model
2. free and premium boundaries are real from the first public release
3. later worlds expand the same model instead of replacing it
4. retention and LTV scale because the route deepens, not because the business
   model flips

If commerce truth is not ready, the release should be delayed rather than
changing the long-term model to a different public product shape.

### Best immediate release choice

For the actual public release:

**keep the value-first premium model, but do not ship until entitlement truth is
closed**

## Required Next Decisions

1. keep the public premium-enabled model fixed and use free-only builds only as
   internal validation tools when needed
2. freeze supported release locales
3. define the exact free slice and premium slice for launch
4. decide whether trial appears:
   - after placement only as preview
   - after first useful loop
   - after first locked deeper route moment

## Required Next Metrics

If monetization is activated, the team should optimize for:

1. placement completion rate
2. first useful loop completion rate
3. D1 return
4. D7 return
5. trial start rate after the first value moment
6. trial-to-paid conversion
7. month-1 to month-2 subscriber retention
8. annual share versus monthly share
9. refund / early cancel signal

Do not optimize only for:

1. first-session trial starts
2. raw paywall taps
3. short-term conversion spikes that weaken trust or retention

## Recommended Launch Boundary That Scales

The launch boundary should already match the long-term 36-world model.

## Hypothetical User Simulation

This section is not an empirical A/B result.

It is a model-based simulation built from:

1. current Sharky route shape
2. current retention and monetization SSOTs
3. typical subscription-learning behavior patterns
4. long-horizon route expansion through `W36`

Its job is to choose the best **working model** before live monetization
experiments exist.

### Simulated user archetypes

Use these launch-default cohort weights:

| Archetype | Share | Description |
| --- | ---: | --- |
| Cautious beginner | 28% | New to poker learning, low trust, high sensitivity to early pressure. |
| Motivated improver | 22% | Wants to get better quickly and will pay after visible progress. |
| Curious casual | 18% | Interested, but easy to lose if value is delayed or pressure is early. |
| Competitive climber | 14% | Wants depth, structure, and longer-horizon growth. |
| Returning rusty player | 10% | Has prior exposure, wants fast usefulness and sharpening. |
| Price-sensitive optimizer | 8% | Will convert only if value is clear and commitment feels justified. |

### Simulated success metrics

Each model candidate is scored against six weighted outcomes:

| Outcome | Weight | What it means |
| --- | ---: | --- |
| First-touch trust and first useful loop | 20% | How likely the user is to understand the app and reach the first real learning win. |
| D7 return and early habit | 20% | How likely the user is to return enough to form a believable rhythm. |
| Trial or offer quality | 15% | How likely monetization starts for the right reason, not from pressure or confusion. |
| Month-1 paid quality | 15% | How healthy early paid starts are once billing begins. |
| 90-day retention and LTV shape | 20% | How well the model scales once deeper worlds and specialization exist. |
| Total revenue potential | 10% | How much revenue the model can plausibly unlock on a broad public cohort. |

Scores use a 10-point scale and are judged for long-term product truth, not only
short-term revenue spikes.

### Public model candidates

Simulated public monetization models:

1. `Hard paywall before value`
2. `Placement trial first`
3. `No-paywall route plus paid services`
4. `Value-first route subscription with contextual trial`

### Public model simulation results

| Model | First touch | D7 habit | Offer quality | Paid quality | 90-day / LTV | Revenue potential | Weighted result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Hard paywall before value | 4.9 | 4.3 | 6.6 | 8.5 | 6.5 | 8.6 | **6.0 / 10** |
| Placement trial first | 6.6 | 5.9 | 6.2 | 6.7 | 6.5 | 7.0 | **6.4 / 10** |
| No-paywall route plus paid services | 8.9 | 7.7 | 4.0 | 4.5 | 5.2 | 4.8 | **6.3 / 10** |
| Value-first route subscription with contextual trial | 8.6 | 8.2 | 8.0 | 7.9 | 8.6 | 7.8 | **8.2 / 10** |

### Why the other public models lose

#### Hard paywall before value

This wins on short-term conversion efficiency, but loses badly on first-touch
trust, habit formation, and the ability to prove that Sharky is effective
before asking for money. For this product shape, it over-optimizes revenue too
early.

#### Placement trial first

This is better than a hard paywall, but still too early. The user has seen the
route shape, not the learning proof. That creates weak trial starts, higher
early cancellation risk, and lower confidence that paid starts represent real
fit.

#### No-paywall route plus paid services

This wins on trust, but monetizes the wrong audience. Most users in the launch
cohort are beginners or improvers, not advanced users shopping for analytics
tooling. Revenue arrives too late and too narrowly, while the core curriculum
loses economic meaning.

#### Value-first route subscription with contextual trial

This is the only model that stays strong across all six outcomes:

1. first useful loop still feels free and trustworthy
2. habit has room to form before money enters the relationship
3. premium can own real depth instead of basic usefulness
4. later worlds preserve subscription reasons over months, not only days
5. total revenue remains strong because the model monetizes the main route, not
   only a niche advanced layer

## Hybrid Model Simulation

Pure models are not the full decision surface.

For Sharky, the higher-EV candidates are hybrid models that combine:

1. structural free/premium boundaries
2. different trial trigger points
3. optional secondary paid layers such as analytics or specialist tools
4. pacing controls that slow bingeing without using coercive locks

### Hybrid candidates

1. `H1`: `W1-W4` free, `W5+` premium, contextual 7-day trial after first useful loop or locked deeper route
2. `H2`: `W1-W4` free, `W5+` premium, 7-day trial shown immediately after placement
3. `H3`: `W1-W4` free, `W5+` premium, no trial, paid start only at the premium boundary
4. `H4`: broad free route, premium only for advanced analytics / deep review / specialist tools
5. `H5`: `W1-W4` free, `W5+` premium, contextual trial plus secondary paid analytics layer later

### Hybrid scoring dimensions

These candidates are scored against the same six weighted outcomes, but two
additional qualitative checks are applied after scoring:

1. model simplicity at release
2. long-term compatibility with `W13-W36`

### Hybrid simulation results

| Hybrid | First touch | D7 habit | Offer quality | Paid quality | 90-day / LTV | Revenue potential | Weighted result | Complexity | Long-term fit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- |
| `H1` contextual trial after value | 8.6 | 8.3 | 8.4 | 8.0 | 8.7 | 7.9 | **8.4 / 10** | medium | excellent |
| `H2` placement trial first | 7.0 | 6.2 | 6.4 | 6.8 | 6.7 | 7.2 | **6.7 / 10** | medium | good |
| `H3` no trial at launch | 8.4 | 8.0 | 6.8 | 7.4 | 8.1 | 7.0 | **7.7 / 10** | low | excellent |
| `H4` service-only premium | 8.9 | 7.8 | 4.2 | 4.7 | 5.4 | 5.0 | **6.4 / 10** | medium | weak |
| `H5` contextual trial plus later analytics upsell | 8.5 | 8.3 | 8.2 | 8.1 | 8.9 | 8.3 | **8.5 / 10** | high | excellent |

### What the hybrid results actually mean

#### `H2` loses

Showing a 7-day trial right after placement still monetizes too early. It is
better than a hard paywall, but it spends trust before the product has earned
it. This creates weaker trial starts and more buyer's-remorse behavior.

#### `H4` loses

Service-only premium keeps trust high but under-monetizes the main beginner and
improver cohort. It also makes the later-world structure economically weaker,
because the curriculum itself stops being the thing the user is paying to keep
unlocking.

#### `H3` is viable but not optimal

No trial at launch keeps the model simple and trust-preserving, but lowers paid
start quality compared with a well-timed contextual trial. It is a safe backup
if commerce truth is late, but it is not the best long-term value-capture
shape.

#### `H5` scores highest in theory, but not as the launch-default shape

`H5` is the highest-scoring hybrid in pure LTV theory because it stacks:

1. a strong route subscription
2. value-timed trial entry
3. a future secondary paid layer for power users

But this should not become the launch-default implementation target. At launch,
it adds too much surface complexity and too many commerce states for a product
that is still closing novice proof and commerce truth.

Verdict:

- `H5` is the best long-horizon expansion path
- `H1` is the best launch-default model

### Canonical hybrid recommendation

Use this as the public working model:

1. `W1-W4` free
2. `W5-W36` premium
3. contextual 7-day trial only after value proof
4. no main trial offer immediately after placement
5. no hard paywall before the first useful loop
6. optional advanced analytics / specialist-tool upsell only later, after the
   route subscription is already stable

This gives Sharky the strongest combined result across:

1. first-touch trust
2. D7 habit formation
3. healthy trial starts
4. month-1 paid quality
5. long-term retention and LTV
6. total revenue without early trust collapse

### Boundary candidates

Simulated structural boundaries:

1. `After W2`
2. `After W3`
3. `After W4`
4. `After W6`
5. `After W12`

### Cohort simulation results

| Boundary | Trust / First Win | D7 Habit | Trial Quality | Paid Quality | 90-day / LTV | Weighted result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| After `W2` | 5.5 | 5.4 | 6.3 | 6.1 | 6.0 | **5.8 / 10** |
| After `W3` | 8.1 | 7.7 | 7.9 | 7.5 | 7.9 | **7.9 / 10** |
| After `W4` | 8.6 | 8.2 | 8.0 | 7.9 | 8.6 | **8.3 / 10** |
| After `W6` | 8.9 | 8.4 | 7.2 | 7.1 | 7.8 | **8.0 / 10** |
| After `W12` | 9.4 | 8.8 | 5.7 | 5.4 | 6.6 | **7.6 / 10** |

### Why `After W2` loses

It wins only on earlier monetization opportunity.

It loses because:

1. cautious beginners and curious casuals see pressure before enough trust
2. trial starts become less healthy and more rescue-shaped
3. paid conversion quality improves less than it appears because early churn
   rises
4. premium starts to feel like permission to continue, not deeper sharpening

### Why `After W3` is strong but still loses to `W4`

`After W3` is much healthier than `W2`.

It still loses to `W4` because:

1. `W3` finishes position thinking, but not the first full preflop decision
   framework
2. the learner understands more, but still has not completed the first
   structured "what do I actually do with this hand?" layer
3. a pay boundary after `W3` risks making premium feel like the moment the app
   finally teaches practical action structure
4. `W4` materially improves paid-quality and long-horizon subscription logic by
   letting the learner finish the first real action grammar before premium
   continuation begins

In short:

- `After W3` is defensible
- `After W4` is stronger

### Why `After W12` loses

It wins on trust.

It loses because:

1. premium role becomes too late and too weak
2. the business model under-monetizes the strongest beginner-to-foundation arc
3. later LTV depends too heavily on future worlds instead of using `W5-W12` as
   already-believable paid depth
4. the free slice becomes so broad that premium feels optional rather than
   necessary for serious continued growth

### Why `After W6` is close but not best

It is stronger than `W2` and healthier than `W12`.

It still loses to `W4` because:

1. it gives away too much of the practical foundation before premium starts to
   matter
2. it delays monetization beyond the point where the learner already has enough
   evidence to understand paid depth
3. it weakens launch-period LTV without adding enough extra trust to justify
   the delay

### Why `After W4` wins

`After W4` is the best weighted point because it is the first place where all
of these can be true together:

1. the learner understands what the app is
2. the learner has felt a real useful loop
3. the learner has enough trust to interpret premium as deeper sharpening
4. the free slice is strong but not over-generous
5. the premium slice can still scale naturally through `W12`, `W24`, and `W36`

## Working Boundary Decision

Based on the simulation above, the working monetization model should fix:

1. **Structural free boundary:** `W1-W4`
2. **Structural premium boundary:** `W5-W36`
3. **Primary launch paid-depth promise:** `W5-W12`
4. **Long-LTV depth promise:** `W13-W24`
5. **Major anti-churn specialization promise:** `W25-W36`

## Operational Timing Decision

The boundary and the paywall moment are not the same thing.

### Structural access boundary

Keep:

- `W1-W4` free
- `W5+` premium

### Primary offer timing

Show stronger premium conversion moments only after one of these:

1. route understanding and first useful hand are complete
2. the user attempts to open `W5`
3. the user returns for a second useful session
4. the user finishes a meaningful repair / result loop that proves value

### Early surfaces that remain allowed

Allowed before the main conversion moment:

1. soft premium preview after placement/result
2. low-pressure premium labels on locked later content
3. truthful explanation that a deeper route exists

## Anti-Rush / Anti-Burnout Policy

The product should not let users sprint through the route in a way that harms:

1. learning quality
2. retention durability
3. subscription longevity

But it also should not use fake friction to create artificial subscription
length.

### Core rule

Slow **progression pressure**, not **basic access**.

Meaning:

1. do not block users with arbitrary timers, lives, or guilt loops
2. do make deeper progression depend on evidence that the current layer is
   landing
3. do make session rhythm humane enough that users stop satisfied, not drained

### Recommended anti-rush levers

Use these in order:

1. bounded session energy
2. stronger repair surfacing after weak performance
3. clean session closure signals
4. spaced resurfacing / daily return cues
5. quality-aware progression

### Recommended anti-rush mechanics

1. keep the current daily usefulness loop visible and strong
2. let a user continue when performance is solid
3. redirect to repair/review when performance shows instability
4. prevent deep route sprinting through weak understanding
5. bias the app toward "one more clean rep tomorrow" instead of "finish
   everything tonight"

### Disallowed anti-rush mechanics

Do not rely on:

1. hard time locks between beginner worlds
2. forced waiting as the primary retention tool
3. energy depletion that blocks the first useful loop
4. fake scarcity or burnout-by-design pacing

### Current Sharky fit

The current product already points in the right direction:

1. `SESSION_ENERGY_BUDGET_v1` limits heavy-step stacking
2. `RETENTION_RHYTHM_ANTI_BOREDOM_v1` limits endless same-shape repetition
3. the Act0 route already has:
   - daily goal closure
   - streak-lite rhythm
   - repair-first return paths
   - done-for-today signals
   - review resurfacing

What is still not fully closed:

1. stronger quality-aware route gating
2. explicit anti-binge progression policy
3. a final decision on how much weak performance should slow access to deeper
   route layers

### Recommended practical rule

For the current model:

1. `W1-W4` remain free
2. `W5+` are premium
3. progression inside the route should slow through:
   - repair burden
   - mastery thresholds
   - session closure rhythm
4. progression should not slow through:
   - arbitrary wait timers
   - fake energy pain
   - coercive pressure

## Final Fixed Working Model

To remove future drift, the working model is:

1. `W1-W4` free and polished
2. `W5-W12` premium continuation of Volume I
3. `W13-W24` premium strategic deepening
4. `W25-W36` premium specialization and long-LTV retention layer
5. annual default, monthly secondary
6. 7-day trial only after value proof
7. no hard paywall before the first useful loop

### Free launch slice

Recommended:

1. `W1-W4` fully free and polished
2. enough Review / repair / Play usefulness to make return believable
3. one stable daily usefulness loop

Reason:

1. this is enough to prove the app teaches something real
2. this is enough to build trust and habit credibility
3. it preserves a meaningful premium role without turning free into a teaser

### Premium launch slice

Recommended:

1. `W5-W12` as premium route continuation and sharpening
2. stronger resurfacing / repair depth
3. stronger mastery / replay value
4. better premium-target daily next-action depth

Reason:

1. Volume I remains marketable as a strong beginner-to-foundation route
2. premium owns deeper practical competence, not basic trust
3. later worlds then extend the same paid logic naturally

### Launch-default versus later expansion

Canonical launch-default:

- `H1`

Canonical later expansion path:

- `H5`

Operational meaning:

1. launch should ship the simpler `H1` surface
2. entitlement, package naming, and premium-surface copy should stay compatible
   with a later `H5` expansion
3. analytics, specialist tools, and deep-review upsells must not appear as a
   launch-default second commerce layer
4. later upsells may be added only after the route subscription itself proves
   stable retention and healthy paid quality

This preserves the highest-EV launch shape without forcing a future public
model rewrite.

### Later expansion

Recommended:

1. `W13-W24` deepen the same subscription promise
2. `W25-W36` become the major long-LTV specialization layer
3. later-only analytics / deep-review / specialist-tool upsell may be layered
   on top if the core route subscription is already healthy

This keeps one stable meaning:

- free proves usefulness
- premium keeps sharpening over months

## Retention Ladder Across 36 Worlds

### 0-30 days

Primary job:

1. first-win trust
2. second-session return
3. first premium depth curiosity

Drivers:

1. cleaner next action
2. repair usefulness
3. visible earned progress
4. compact Sharky warmth

### 1-3 months

Primary job:

1. complete Volume I
2. strengthen decision confidence
3. establish return rhythm

Drivers:

1. premium route depth through `W5-W12`
2. better resurfacing
3. mastery and replay value

### 3-6 months

Primary job:

1. deepen strategic thinking
2. prevent boredom through genuine new variables
3. keep subscription feeling worth it

Drivers:

1. Volume II depth
2. stronger pattern repair
3. richer mixed transfer and pressure contexts

### 6-12 months

Primary job:

1. convert subscribers into durable specialists
2. reduce churn through meaningful identity and depth

Drivers:

1. specialization gateway after Volume I
2. Volume III specialization
3. format-specific mastery
4. deeper recommended-track sharpening

## Anti-Churn Model For Subscribers

Long-term churn should be reduced by:

1. deeper route depth arriving over time
2. stronger personal weak-spot resurfacing
3. visible mastery, not only completion
4. later specialization identity
5. calmer, more useful Sharky voice

It should not rely on:

1. weekly discount traps
2. guilt-driven streak pressure
3. endless beginner repetition
4. fake "new" content that does not open a new mastery layer

## Bottom Line

The optimal Sharky model is not:

- hard early paywall
- teaser-only free
- economy-heavy pressure

The optimal Sharky model is:

- real free value
- premium as deeper sharpening
- contextual value-first conversion
- annual-default subscription packaging
- retention driven by mastery, repair, and visible progress
- one stable boundary that can scale through all 36 worlds
- `H1` as launch-default with `H5` compatibility later

## Experiment Policy

Default production policy:

1. keep `H1` as the default public model
2. keep post-placement premium messaging as soft preview only
3. keep the main 7-day trial trigger after value proof

Allowed later experiment variants:

1. Variant B: post-placement trial offer
2. Variant C: no-trial paid boundary at `W5`
3. Variant D: annual-first versus balanced monthly/annual emphasis
4. Variant E: second-session trial versus first locked-route trial

Primary success metrics:

1. first useful loop completion
2. D1 return
3. D7 return
4. trial start rate after value proof
5. trial-to-paid conversion
6. month-1 to month-2 subscriber retention
7. annual share versus monthly share
8. `W5` start rate
9. `W8` and `W12` survival among paid users

Stop metrics:

1. placement completion drops
2. first useful loop completion drops
3. D1 or D7 drops materially
4. early cancellation or refund signal rises
5. users start trial but do not reach `W5` / `W6`
6. premium surfaces create confusion in human review

World-truth note:

- keep launch premium gate wording aligned with the master plan:
  `W5` is `Bet Purpose And Price`, not `Board Awareness`

For the public release, the best truthful choice is:

- premium-enabled only if entitlement truth is fully proven

For internal validation builds, a free-only candidate is still allowed as a
temporary proof tool, but it should not become the public long-term model.
