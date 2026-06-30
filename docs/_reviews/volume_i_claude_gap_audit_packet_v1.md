# Volume I Claude Gap Audit Packet v1

## 1. Verdict

`volume_i_claude_gap_audit_packet_landed`

This packet prepares a bounded Claude red-team audit for W1-W12 Volume I.
It does not execute Claude, approve route admission, or authorize fixes.

## 2. Purpose

Give Claude enough certified source truth to critique Volume I learning, UX,
product quality, claim safety, beginner comprehension, and premium perception
without becoming a roadmap or architecture authority.

## 3. Source Of Truth Packet

Claude should use these as the audit packet:

- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/context/HUMAN_QA_CAPSULE_v1.md`
- `docs/plan/WORLD_FACTORY_CONTRACT_v1.md`
- `docs/_reviews/w1_w12_internal_source_checkpoint_v1.md`
- `docs/_reviews/volume_i_internal_source_certification_v1.md`
- `docs/_reviews/w7_internal_source_certification_world_factory_gate_v1.md`
- `docs/_reviews/w8_internal_world_source_template_v1.md`
- `docs/_reviews/w9_w10_internal_world_source_template_batch_v1.md`
- `docs/_reviews/w11_w12_internal_world_source_template_batch_v1.md`

Do not add screenshots, output folders, generated assets, W13+, store,
monetization, old visual docs, or Modern Table files to the audit packet.

## 4. Certified Baseline

Baseline: Volume I is certified as an internal source layer only.

Certified:
- W1-W6 stable/frozen routed foundation.
- W7-W12 hidden/internal source mini-worlds.
- World Factory Contract compliance for W7-W12.
- Evidence/projection compatibility for W7-W12.
- Route/Practice safety for W7-W12.

Not certified:
- W7-W12 route admission.
- Learner-facing public/playable W7-W12.
- Human QA pass.
- Launch readiness, 9.0, monetization, store readiness, or public
  learning-effect proof.

## 5. W7-W12 Audit Inventory

- W7: Range Thinking Lite; card-removal / combo-density intuition.
- W8: Draws / Improvement Potential; draw-recognition and transfer.
- W9: Pot Odds / Price Intuition; call-price recognition and comparison.
- W10: Value vs Fold-Pressure Purpose; bet-purpose intuition.
- W11: Board Texture Danger Awareness; texture and one-pair caution.
- W12: Integrated Decision Intuition; combined clue review.

W1-W6 are frozen/stable context. Claude may flag major W1-W6 risks, but must
not propose a broad W1-W6 rewrite.

## 6. Claude Audit Scope

Claude should evaluate:

1. W1-W12 learning progression.
2. W7-W12 hidden/internal world quality.
3. Whether each world has enough content depth.
4. Whether task arcs are understandable for beginners.
5. Whether transfer/check tasks are strong enough.
6. Whether the repair/proof loop feels meaningful.
7. Whether claims remain safe.
8. Whether the product reads as premium trainer or internal scaffolding.
9. Where learners may get confused.
10. Which gaps are P0/P1/P2.
11. What must be fixed before route admission.
12. What can wait for Human QA or later.

## 7. Claude Authority Limits

Claude is an external red-team reviewer only.

Claude may not:
- make architecture decisions;
- override the Master Plan, active route truth, or World Factory Contract;
- approve route admission, launch, monetization, or Human QA;
- request broad redesign;
- request Modern Table visual polish;
- request screenshot-driven iteration;
- request solver, GTO, ML, AI, or persona claims;
- convert internal source certification into public readiness.

## 8. Expected Claude Outputs

Claude must return:

1. Executive verdict.
2. Per-world learning gap table.
3. Per-world UX/comprehension risk table.
4. Repair/proof loop critique.
5. Claim-safety critique.
6. Premium/commercial perception critique.
7. P0/P1/P2 blocker list.
8. Do-not-fix / defer list.
9. Route admission readiness opinion.
10. Human QA readiness opinion.
11. Top 10 highest-EV fixes.
12. Explicit uncertainty notes.

## 9. Severity Definitions

P0: blocks any credible route admission planning or creates unsafe claims.

P1: should be fixed before W7-W12 route admission because it harms learning
clarity, source parity, or beginner comprehension.

P2: useful polish, sequencing, or product-quality improvement that can wait
until after route admission planning or Human QA design.

Defer: valid concern, but outside this wave, route admission, or Human QA.

## 10. Route Admission Boundary

Claude may express readiness opinion, but cannot admit routes. Any route work
requires a later Codex route-admission planning prompt that separately proves
route, stale-resume, mapper, Practice CTA, copy, progression, and guard safety.

## 11. Codex Follow-Up Policy

Claude findings are inputs, not decisions.

Codex may only implement P0/P1 fixes after separate scoped prompts. Codex must
not implement broad redesign, route admission, launch, monetization, Modern
Table work, public learning-effect claims, Practice CTA, mapper allowlists, or
W1-W6 rework from Claude output alone.

## 12. Deferred Items

- Claude execution.
- Route admission planning and implementation.
- Public learner-facing copy.
- Practice CTA and mapper allowlist admission.
- Stale-resume admission.
- Human QA protocol and execution.
- Monetization/store decisions.
- W13+.
- Modern Table work unless an actual regression is separately proven.

## 13. Validation

Packet validation is docs-only:
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- ASCII/trailing whitespace/CRLF/final-newline checks on new docs

Do not run Flutter tests, `flutter analyze`, or screenshot pipeline unless a
source/runtime file is unexpectedly touched.

## 14. Score Impact

No W1-W12 movement.
No readiness movement.
No Human QA pass, 9.0, monetization, launch, public/playable opening, route
admission, or public learning-effect claim becomes safe.

## 15. Prompt File

Use:

`docs/prompts/claude_volume_i_gap_audit_prompt_v1.md`

## 16. Next Recommendation

Send the prompt file and source packet to Claude as a separate review step.
After Claude returns findings, run a Codex triage wave before any fix wave.
