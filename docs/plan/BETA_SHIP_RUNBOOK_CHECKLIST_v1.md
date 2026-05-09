# Beta Ship Runbook / Checklist v1
Status: ACTIVE
Purpose: preserve one explicit bounded beta ship-now slice inside the broader
final-readiness model.
Last updated: 2026-04-01

## Authority

Use this document for:

- the exact bounded beta ship-now slice
- the must-pass smoke path before shipping that slice
- the explicit go / hold criteria for the current beta-ready claim
- the bounded classification of acceptable beta debt versus deferred post-beta
  growth

This document operationalizes, but does not replace:

- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`
- `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md`
- `docs/plan/ROUTE_TO_B_ACTION_LADDER_v1.md`

Important:

- this is a bounded beta artifact
- it is not the final-product launch authority
- final `100%` readiness is governed only by
  `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`

## Canonical Beta Ship Scope

The current ship-now claim is bounded to the canonical early learner path on
current `main`:

- World 1 opener and immediate continuation
- active World 2 learner path
- early World 3 continuation where it directly extends the same canonical path
- the learner-facing entry, map, runner, result, review, and continuation
  surfaces that support that path

Inside this ship-now claim:

- learner-facing progression truth is coherent enough for beta
- graded feedback is live on the bounded high-EV World 2 families already
  proven on main
- early-arc cohesion and finish/unification work is strong enough for a
  trustworthy beta learner journey
- compact canonical early-path correctness coverage is fully clean on current
  `main`

Outside this ship-now claim:

- final-product readiness
- identity / onboarding / trust closure for mass distribution
- broader monetization, packaging, store, release, and operational confidence
- later-world feedback quality scale-out and broader cross-world normalization

## Must-Pass Smoke Path

Before beta ship, the following bounded smoke path must remain true:

1. cold boot reaches the canonical learner path without route contradiction
2. World 1 opener progresses into its intended continuation surfaces
3. World 2 active learner path remains reachable and behaviorally coherent
4. early World 3 continuation still reads as a continuation of the same learner
   arc
5. runner to result to continuation/review handoff stays coherent across the
   canonical path
6. compact canonical early-path correctness audit stays fully clean

## Must-Not-Regress Expectations

Do not ship the bounded beta slice if current `main` loses any of these:

- poker-truth correctness on the canonical early learner path
- route/progression correctness across entry, map, runner, result, review, and
  continuation
- current graded feedback behavior on the bounded active families already proven
  on main
- early-arc progression rhythm gains
- finish/unification gains across the canonical learner journey
- compact correctness confidence on the canonical early learner path

## Launch Go / Hold Criteria

### Go

Ship the bounded beta slice when all of the following are true:

- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` still treats the canonical
  early learner path as a strong bounded core-product slice even though final
  readiness remains materially below `100`
- the canonical beta path is still publish-ready as a bounded beta artifact
- `dart run tools/canonical_early_path_correctness_audit_v1.dart` remains fully
  clean
- no new publish-critical learner-facing blocker is proven on the canonical
  Worlds 1-3 path

### Hold

Hold the bounded beta ship if any of the following become true:

- the compact canonical early-path correctness audit shows residue or issues
- a learner-facing contradiction reappears on the canonical
  entry/map/runner/result/review/continuation path
- a new publish-critical blocker is proven on the canonical Worlds 1-3 beta
  slice
- this runbook drifts away from current `main` evidence or from
  `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`

## Acceptable Beta Debt

These are acceptable to carry into the bounded beta slice unless they
contaminate the canonical ship-now path:

- later-world feedback quality scale-out
- broader final-product hardening outside the canonical beta-ready path
- residual World 2 / World 3 cohort normalization outside the canonical ship
  claim
- downstream ship/distribution closure work that belongs to `K`, `L`, `M`, and
  `N`

## Non-Blocking Tooling / Process Debt

- tooling-only release-confidence audit friction where some audit scripts are
  not runnable via plain `dart run` because of Flutter `dart:ui` dependency
  context
- process ergonomics that do not reduce current learner-facing trust on the
  canonical beta path

## Deferred Post-Beta Growth Queue

After bounded beta ship, or when resuming the broader route to final readiness:

- close `I` and `J` so identity and first-session trust are strong enough for
  mass distribution
- close `K` so monetization/value packaging truth becomes honest and unified
- close `L` so store/distribution packaging is real and placeholder-free
- close `M` and `N` so final launch confidence is whole-product rather than
  beta-slice-only
