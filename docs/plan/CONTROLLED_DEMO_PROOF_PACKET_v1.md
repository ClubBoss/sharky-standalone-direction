# CONTROLLED_DEMO_PROOF_PACKET_v1

Status: ACTIVE CONTROLLED-DEMO PACKET
Purpose: define the minimum internal demo packet so Act0 can be shown fairly,
without rediscovering already-known deferred lanes or mis-scoring the product.
Last updated: 2026-05-21

## Authority

Use this file beneath:

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/EXECUTION_POLICY_SSOT_v1.md`
- `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`
- `docs/plan/ACT0_TELEMETRY_TRUTH_MAP_v1.md`
- `docs/l10n/TRANSLATION_SSOT_v1.md`

This file owns the current controlled internal demo packet for Act0.

Use it for:

- the canonical internal demo route
- pre-demo proof floor
- observer framing
- known visible gaps that should be acknowledged, not rediscovered
- pass/fail admission rules for internal demo use

Do not use it for:

- Human Novice QA
- public beta / store release
- broad visual/theme migration
- broad telemetry implementation
- reopening closed-watch Home

## Demo Purpose

The controlled internal demo is not a launch claim.

Its purpose is to verify that the current Act0 route can be shown end to end to
trusted internal observers without:

- obvious known gaps dominating the walkthrough
- deferred lanes being mistaken for active blockers
- the observer spending the session rediscovering issues that are already
  documented

This packet exists so internal demo feedback measures the current product
surface, not noise from known deferred work.

## Canonical Demo Path

Use one deterministic route only.

### Start state

- English / default route
- current active Act0 shell
- no broad RU expectation
- no dev-only detours unless the session is specifically a proof review

### Canonical path

1. Placement
2. Welcome
3. Home
4. Learn
5. First Table Guide or current lesson handoff
6. Runner / Table:
   - one theory step
   - one drill step
   - one review / feedback step
7. Review
8. Practice
9. Profile
10. World Completion, if the demo setup already reaches that seam safely

### Route intent

- show the first-run handoff
- show one active learning loop
- show one repair / keep-sharp ownership surface
- show one learner-evidence surface
- show one completion / payoff surface if available

Do not expand into side systems, older surfaces, or dormant map families.

## Pre-Demo Proof Floor

Required before the demo is considered admissible:

- `flutter analyze` clean
- `./tools/fast_loop_world1_v1.sh` pass
- `./tools/release_gate_world1.sh` recent pass when release-gate relevance is
  part of the session context
- deterministic canonical entry remains Act0 shell
- known deferred lanes are labeled in advance
- no known red route-order or shell-mechanics blocker

Preferred but not required:

- fresh compact visual packet
- current known-gap list reviewed before the walkthrough

## Screens / Surfaces To Inspect

Primary:

- Placement
- Welcome
- Home
- Learn
- Runner / Table
- Review
- Practice
- Profile
- World Completion when reachable
- Bottom Nav / Shell stability during the route

Screenshot packet note:

- manifest and harness pass status help prove packet completeness, but they are
  not visual proof by themselves when live or user screenshots contradict the
  captured artifact
- if a screenshot-driven wave depends on one exact visual fix, use
  `docs/plan/EXECUTION_POLICY_SSOT_v1.md` screenshot acceptance contract rules
  before claiming closure

Secondary:

- demo observer should note visual/theme concerns only when they clearly affect
  readability, hierarchy, or trust

Do not spend the session judging dormant, deferred, or store-release-only
surfaces.

## In Scope For Controlled Demo

- route clarity
- first-run handoff
- one active learn-to-drill-to-feedback loop
- practice/review/profile/completion ownership boundaries
- compact readability and hierarchy problems that are immediately visible
- whether the learner value proposition is understandable without explanation
- whether known recent improvements actually read well in one coherent flow

## Out Of Scope For Controlled Demo

- Human Novice QA
- broad RU localization quality
- W13-W24 expansion readiness
- monetization / paywall behavior
- public store / legal / release package readiness
- broad telemetry implementation beyond current local proof
- Deep Ocean full token migration
- `ModernTableScreenV1`
- hidden dormant subsystems

## Known Visible Gaps

These should be acknowledged before the walkthrough. They are not new findings
if they appear during the demo.

### Active visible risks

- some surfaces may still read as competent utility rather than fully premium
  product
- runner/table polish is strong functionally but still short of final
  device-class visual proof
- Profile evidence is materially better, but learner identity is still compact
  rather than fully developed
- World Completion payoff is stronger, but may still feel lighter than the full
  learning effort it summarizes
- Review is mechanically strong, but active repair/backlog states may still
  feel more system-shaped than coach-shaped under accumulation pressure

### Deferred lanes that must not dominate the session

- Human Novice QA
- broad RU localization
- W13-W24 expansion
- monetization / paywall
- broad store / legal / public release
- broad telemetry implementation
- Deep Ocean full migration
- `ModernTableScreenV1`

## What Not To Judge Yet

Observers should not use this demo to conclude:

- the app is public-beta ready
- the app is release-commercial ready
- RU support is complete
- broader world-factory scale is closed
- telemetry/privacy/release posture is settled
- the final visual identity system is locked

## Controlled-Demo-Ready Gate Definition

Act0 is controlled-demo-ready only when all of the following are true:

- route/proof gate is green
- the canonical demo path is deterministic
- obvious compact readability failures are not dominant
- the observer can understand what each major surface owns
- known deferred lanes are disclosed before the demo
- there is a clear rule for what counts as a fail vs a known deferred gap

This gate is narrower than external Human QA and much narrower than public
release.

## Pass / Fail Admission Rules

### Proceed to internal controlled demo

Use when:

- pre-demo proof floor is green
- no known blocker makes the route look broken in the first 5 to 10 minutes
- known visible gaps are judged tolerable for a trusted internal audience

### One more product-hardening wave

Use when:

- one dominant product seam still distracts from the route
- the seam is owner-clear and can be improved locally
- the issue is user-facing, not just a paperwork gap

### Return to gate audit

Use when:

- the route itself is not the problem, but the demo packet or proof discipline
  is incomplete
- observers are likely to over-read deferred lanes as active failures

### Defer external / human QA

Use when:

- controlled-demo floor is not honestly met
- visible known gaps would dominate novice feedback
- payoff / visual / route stability are not yet strong enough

## Fail Conditions

Treat the controlled demo as failed if any of the following occur:

- canonical route breaks or becomes non-deterministic
- route-order or shell-entry truth is unclear
- one visible gap dominates the session enough that the product cannot be
  evaluated fairly
- observers cannot tell what Learn, Review, Practice, Profile, or World
  Completion each own
- the session drifts into judging deferred lanes instead of the active route

## Observer Notes Template

Use this exact note shape:

- `Surface:`
- `Observed behavior:`
- `Why it matters:`
- `Issue class:`
  - route logic
  - readability / hierarchy
  - payoff / motivation
  - proof / trust
  - deferred lane, not active blocker
- `Owner seam:`
- `Severity:`
  - tolerable for controlled demo
  - needs one more product-hardening wave
  - blocks controlled demo
- `Recommended next action:`

## Post-Demo Decision Outcomes

- `Proceed to internal controlled demo`
- `One more product-hardening wave`
- `Return to gate audit`
- `Defer external / human QA`

The default next step after a successful internal demo is not automatic Human
Novice QA. That still requires the separate gate in
`docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`.

## Highest Remaining Product Seam After Packetization

Current highest-EV product seam after this packet is:

- `Review active repair/backlog coach-feel`

Reason:

- Review already owns repair / recheck / prove correctly
- empty-state hierarchy improved
- the most likely remaining internal-demo distraction is that active repair
  states may still feel like a system backlog instead of a calm coaching lane

This is a smaller and safer next wave than broad telemetry, broad Deep Ocean,
or another multi-surface polish pass.
