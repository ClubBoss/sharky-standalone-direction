# PROJECT_READINESS_EPICS_SSOT_v1

Status: REFERENCE
Purpose: lean launch-readiness reference for real release preparation.
Last updated: 2026-05-13

## Authority

This document is not the active product-routing authority.

Use:

- `docs/plan/MASTER_PLAN_v3.0.md` for what to build next
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` for the current top-1
  product attack sequence and Sharky-vs-Runout strategy
- `docs/plan/MINI_ROUTE_TO_100_WAVES_v1.md` for the practical route to product
  `100 / 100`

Use this document only for:

- late-stage launch framing
- honest release blocking checks
- commerce/store/release proof before external launch

Do not use this file for:

- day-to-day wave selection
- product bottleneck routing
- expanding the app into heavy governance or overbuilt readiness systems

## Why This Was Simplified

The older version of this document carried too much machinery for the current
project shape:

- too many abstract blocks
- too much scoring ceremony
- too many dependency layers
- too much temptation to route agents into governance instead of product work

That model was useful as a caution against fake readiness, but it was too heavy
for the active `Sharky_1.0` route.

This simplified version keeps only what is useful for real release decisions.

## Definition Of Release-Ready

Release-ready means all of the following are true at the same time:

1. The active learner route is strong enough that a new user quickly sees real
   value.
2. The app feels coherent, trustworthy, and polished on real devices.
3. Premium/trial, if enabled, appears only after value is proven and works
   correctly.
4. Store assets, metadata, legal/support links, and submission materials are
   real rather than placeholder.
5. The team can run a repeatable release check and has enough confidence to
   ship without guesswork.

Release-ready does not mean:

- every future system is built
- deep AI/persona architecture is active
- full analytics and dashboard machinery exists
- the repo is academically "complete"

## Minimal Readiness Model

The only readiness groups that matter here are:

### 1. Product Core

Questions:

- Does the active route actually teach well?
- Does first start make sense?
- Does `Home -> Learn/Play -> Table -> Result -> Review/You` feel coherent?
- Does the product feel worth returning to?

This group is governed by:

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/MINI_ROUTE_TO_100_WAVES_v1.md`
- `docs/plan/LAUNCH_SURFACE_MECHANISM_v1.md`

### 2. Value And Commerce

Questions:

- Is premium/trial timed after proof of value?
- Is the free/premium boundary clear?
- Do entitlement, purchase, restore, and trial behavior work truthfully?

This group must stay downstream from Product Core.

### 3. Launch Package

Questions:

- Are the store visuals, copy, metadata, and legal/support surfaces real?
- Is there a real submission-ready package?
- Are there any embarrassing placeholders or fake-complete claims left?

### 4. Release Confidence

Questions:

- Can we run the app and the active route cleanly on real devices?
- Do the basic gates pass?
- Do we know what to test before shipping?
- If something breaks after release, do we know how to recover?

## Practical Launch Checklist

Treat these as the actual late-stage release gates.

### A. Active Product Route Is Strong

Must be true:

- `Placement` feels short, trustful, and routes cleanly
- `Home` gives one obvious next step
- `Learn` feels like a guided course, not a shelf
- `Play` offers fast useful practice without competing with `Learn`
- `Table -> Result` feels polished and rewarding
- `Review` repairs mistakes usefully and calmly
- `You` reflects identity and growth without dashboard bloat
- `Sharky` / streak / celebrations add life without noise

Primary proof:

- current product-wave closure in `MASTER_PLAN_v3.0`
- current route closure in `MINI_ROUTE_TO_100_WAVES_v1.md`
- bounded human walkthroughs of the active learner path

### B. Real-Device Product Proof Exists

Must be true:

- compact phone, large phone, and tablet classes were reviewed
- no obvious overflow, safe-area, spacing, or visual inconsistency remains
- critical screens were actually seen and checked by a human

Primary proof:

- screenshot sweep
- device walkthrough notes

### C. Premium/Trial Is Honest

Must be true:

- premium/trial does not appear before value proof
- premium messaging sounds additive, not desperate
- restore/purchase/trial state is truthful
- the free/premium boundary is understandable

Primary proof:

- manual purchase/restore/trial walkthrough
- active entitlement behavior check

### D. Store Package Is Real

Must be true:

- store icon, screenshots, description, subtitle, keywords, and support links
  are real
- privacy/legal/support fields are not placeholder
- no marketing claim overpromises beyond the shipped product

Primary proof:

- submission artifact checklist
- manual review of final store text and assets

### E. Release Gate Is Repeatable

Must be true:

- `flutter analyze` passes
- the active gate loop passes
- targeted tests for touched learner-facing seams pass
- a final pre-release walkthrough list exists and was run

Primary proof:

- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- additional targeted tests as required by the admitted release wave

## What We Explicitly Do Not Track Here

Do not reopen these as release prerequisites unless the active task proves they
are truly required:

- deep persona / AI-coach architecture
- heavy telemetry or dashboard systems
- broad multi-layer readiness scoring
- giant epic registries
- theoretical full-repo cleanup
- dormant-system normalization outside the active Act0 route
- speculative growth features, social systems, leaderboard layers, or solver
  theater

## Current Honest Position

As of 2026-05-13:

- practical product route is materially strong but not yet `100 / 100`
- the project is closer to "strong product route" than "ready for broad public
  launch"
- the remaining highest-EV path is still product work first, then launch
  package/commercial proof

In simple terms:

- do not stop product waves too early and switch into store/release theatre
- do not pretend launch readiness is blocked by huge governance machinery
- do not let this document compete with the master plan

## Default Use Rule

If the question is:

- "What should we build next?" -> use `MASTER_PLAN_v3.0.md`
- "What wave gets us closer to product 100?" -> use
  `MINI_ROUTE_TO_100_WAVES_v1.md`
- "Are we honestly ready to launch?" -> use this file

If there is ambiguity, default away from this file and back to the master plan.
