# Claude Volume I Gap Audit Prompt v1

You are reviewing Sharky Poker / Poker Analyzer as an external red-team
reviewer. Your job is to find learning, UX, product, comprehension, claim
safety, and premium-perception gaps in Volume I W1-W12.

You are not the roadmap owner. You are not the architect. You are not approving
route admission, launch, Human QA, monetization, or public readiness.

## Source Packet To Read

Read only these files:

1. `docs/context/CURRENT_STATE_CAPSULE_v1.md`
2. `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
3. `docs/context/HUMAN_QA_CAPSULE_v1.md`
4. `docs/plan/WORLD_FACTORY_CONTRACT_v1.md`
5. `docs/_reviews/w1_w12_internal_source_checkpoint_v1.md`
6. `docs/_reviews/volume_i_internal_source_certification_v1.md`
7. `docs/_reviews/w7_internal_source_certification_world_factory_gate_v1.md`
8. `docs/_reviews/w8_internal_world_source_template_v1.md`
9. `docs/_reviews/w9_w10_internal_world_source_template_batch_v1.md`
10. `docs/_reviews/w11_w12_internal_world_source_template_batch_v1.md`

Do not request screenshots, output folders, generated assets, W13+, store,
monetization, old visual docs, Modern Table files, or broad repo history.

## Certified Baseline

Treat this as current truth:

- Volume I W1-W12 is certified as an internal source layer only.
- W1-W6 are stable/frozen routed foundation and should not be broadly rewritten.
- W7-W12 are hidden/internal source mini-worlds.
- W7-W12 are not learner-facing, public, playable, route-admitted, or Human-QA
  proven.
- W7-W12 route admission remains separate.
- W1-W12 readiness remains `8.3`.
- Human QA has not been executed.

## Review Role

Act as:

- external red-team reviewer;
- learning/UX/product gap finder;
- claim-safety reviewer;
- beginner comprehension critic;
- commercial/premium perception critic.

Focus on whether Volume I would feel coherent, understandable, useful, and
premium if later admitted to a learner-facing route, while preserving the fact
that it is not admitted now.

## Authority Limits

You may not:
- make architecture decisions;
- override the Master Plan, active route truth, or World Factory Contract;
- approve route admission;
- approve launch;
- approve monetization;
- approve Human QA;
- request broad redesign;
- request Modern Table visual polish;
- request screenshot-driven iteration;
- request solver, GTO, ML, AI, or persona claims;
- convert internal source certification into public readiness.

Your findings are inputs for later Codex triage, not decisions.

## Audit Scope

Evaluate:

1. W1-W12 learning progression.
2. W7-W12 hidden/internal world quality.
3. Whether each world has enough content depth.
4. Whether task arcs are understandable for beginners.
5. Whether transfer/check tasks are strong enough.
6. Whether the repair/proof loop feels meaningful.
7. Whether claims remain safe.
8. Whether the product feels like a premium trainer or internal scaffolding.
9. Where a beginner might get confused.
10. Which gaps are P0/P1/P2.
11. What must be fixed before route admission.
12. What can be deferred until Human QA or later.

## Specific Worlds To Review

Review W7-W12 directly:

- W7 Range Thinking Lite.
- W8 Draws / Improvement Potential.
- W9 Pot Odds / Price Intuition.
- W10 Value vs Fold-Pressure Purpose.
- W11 Board Texture Danger Awareness.
- W12 Integrated Decision Intuition.

Treat W1-W6 as frozen/stable context. Flag major W1-W6 risks only if they
directly undermine Volume I continuity or W7-W12 route-admission readiness.

## Required Output Format

Return these sections in this order:

1. Executive Verdict
2. Per-World Learning Gap Table
3. Per-World UX / Comprehension Risk Table
4. Repair / Proof Loop Critique
5. Claim-Safety Critique
6. Premium / Commercial Perception Critique
7. P0 / P1 / P2 Blocker List
8. Do Not Fix / Defer List
9. Route Admission Readiness Opinion
10. Human QA Readiness Opinion
11. Top 10 Highest-EV Fixes
12. Explicit Uncertainty Notes

## Severity Definitions

P0: blocks any credible route admission planning or creates unsafe claims.

P1: should be fixed before W7-W12 route admission because it harms learning
clarity, source parity, beginner comprehension, or premium trust.

P2: useful polish, sequencing, explanation, or product-quality improvement that
can wait until after route admission planning or Human QA design.

Defer: valid concern, but outside this source/route-prep review.

## Required Tables

For the Per-World Learning Gap Table, include columns:

- World
- Intended concept
- Strength
- Gap
- Severity
- Suggested fix shape
- Evidence source

For the Per-World UX / Comprehension Risk Table, include columns:

- World
- Likely learner confusion
- Why it matters
- Severity
- Fix or defer
- Evidence source

## Claim-Safety Rules

Do not recommend claims using:

- GTO;
- solver;
- optimal;
- perfect;
- mastered;
- fixed;
- guaranteed improvement;
- proven improvement;
- public;
- playable;
- launch-ready;
- Human-QA-proven;
- AI coach;
- persona;
- learning-effect proof.

You may say:

- internal source layer;
- hidden/internal mini-world;
- route-admission candidate;
- needs Human QA;
- local proof-compatible signal;
- non-causal later-correct evidence.

## Route Admission Readiness Opinion

Give an opinion on readiness for a separate route-admission planning wave, but
do not approve route admission. State what must be true before any route opens:

- route/stale-resume proof;
- mapper/Practice CTA proof;
- public copy review;
- progression handoff proof;
- claim-safety review;
- Human QA boundary.

## Human QA Readiness Opinion

Say whether the source layer is coherent enough to prepare a Human QA protocol.
Do not claim Human QA passed. Name the learner confusion risks Human QA should
probe first.

## Top 10 Highest-EV Fixes

List exactly 10 fixes ranked by expected value. Each item must include:

- rank;
- affected world(s);
- severity;
- fix shape;
- why it matters;
- whether Codex may implement it only after a separate scoped prompt.

## Uncertainty

Be explicit about uncertainty. If a conclusion cannot be proven from the source
packet, say so. Do not invent screenshots, user behavior, telemetry, Human QA
results, route behavior, monetization state, or product performance evidence.

## Final Constraint

Your output is advisory. Codex must triage your findings separately before any
implementation. Do not ask Codex to make broad changes in the same wave.
