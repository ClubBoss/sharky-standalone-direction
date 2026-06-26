# Wave 3.9.1 - 36-World TOP1 Product Vision & Excellence Route Lock v1

## 1. Verdict

wave3_9_1_36_world_top1_product_vision_route_lock_ready

## 2. Executive Decision

- Sharky is not beginner-only.
- Sharky is a 36-world table-first poker skill-building system.
- Public v1 is W1-W4 Foundation, polished to 10/10 within that band.
- The full ambition is zero-to-shark across 36 worlds.
- Store/Public Readiness is delayed.
- Excellence route E1-E6 is inserted before Store/Public.

External challenger finding supplied in conversation:

`current_format_can_anchor_a_36_world_zero_to_shark_journey_with_defined_architecture_contracts`

The external challenger report was not present as a repo file during this wave.
The findings above are preserved as supplied external review input.

## 3. Product Positioning

Public v1 positioning:

`The table coach. Learn to read the table from your first hand.`

Supporting v1 framing:

`Sharky shows you what to look for at the table - one spot at a time, from your first decision.`

Full product positioning:

`Zero to shark. Table-first poker training across 36 worlds.`

Supporting full-product framing:

`Every world is a skill upgrade. Every rep is a better read.`

Forbidden positioning:

- beginner-only app;
- GTO trainer;
- AI poker coach;
- complete poker curriculum before W1-W36 are built and validated;
- Runout alternative;
- Duolingo for poker;
- best beginner X as permanent product identity.

The prior "best beginner table-clue poker decision trainer" frame is accepted
only as a v1 beachhead description, not as the product identity.

## 4. 36-World Progression Spine

The 36-world arc is the product spine, not a loose content backlog.

### W1-W4 - Foundation

- learning promise: first reliable table signals and simple correct decisions;
- user emotional state: cautious curiosity -> "I can actually see that";
- Sharky tone: warm, direct, short;
- current v1 beachhead;
- proof: local, per-session, specific table clue.

### W5-W12 - Developing Player

- learning promise: more complex patterns, pot odds, position, bet-sizing
  signals, multi-street basics;
- Sharky tone: more precise, vocabulary-confident;
- systems needed later: cross-session mistake tracking, simple concept
  resurfacing, richer Review coaching.

### W13-W24 - Intermediate Decision-Maker

- learning promise: range-level thinking, multi-way dynamics, bluff-catch
  frequencies, deeper structural reasoning;
- Sharky tone: peer-level and proof-aware;
- systems needed later: hand import, multi-street decision trees, persistent
  leak profile, practice generator.

### W25-W36 - High-Level / Pro-Style Thinking

- learning promise: strong-reg style thinking, solver-consistent conceptual
  validation, ICM/tournament pressure, advanced analytics;
- Sharky tone: minimal, precise, respectful;
- systems needed later: solver validation floor, advanced hand import, custom
  drills, advanced analytics.

## 5. Core Path vs Future Expansion

- 36 worlds are the canonical Core Shark Path.
- 36 worlds are not an artificial ceiling for the company/product.
- Post-core growth may continue through mastery tracks, labs, specialized
  formats, imported-hand review, solver-backed validation, seasonal/mastery
  challenges, and advanced practice systems.
- Public v1 must not claim post-core features or full W1-W36 availability.

## 6. Sharky Grows With The Player

Sharky's method stays constant:

`table clue -> decision -> clear why -> targeted rep -> local proof`

Sharky's register evolves by world band:

- Foundation tier: W1-W4, warm/direct/simple.
- Developing tier: W5-W12, precise/vocabulary-confident.
- Sharp tier: W13-W36, minimal/peer-level/tactical.

Mechanism:

- curated phrase sets indexed by world band;
- phrase sets per moment type;
- deterministic selection by world band.

Not AI, not chat, not dynamic generation, not mascot bloat.

## 7. Guard vs Excellence Protocol

Formal rule:

- Guard waves may pass by proving no P0/P1 blockers.
- Excellence waves may not pass by no P0/P1 alone.

An excellence wave must either:

- ship learner-visible value; or
- return `blocked_missing_prerequisite` with exact prerequisite and next route.

A docs-only wave can only be an excellence wave if its purpose is route/SSOT
lock, not product-score movement.

## 8. Revised Excellence Route

Insert before Store/Public Readiness:

### Wave 3.10 - Premium Motion Moments v1

- target: decision -> feedback, fix landed, Session Summary hero, Street Replay
  reveal if safe;
- required proof: before/after evidence, screenshot proof, device recording or
  frame sequence for motion;
- required contract before scope: Replay Source Boundary.

### Wave 3.11 - Personalized Return Reason v1

- target: Day 2/Home return copy tied to last proof/current repair;
- embedded contract: Cross-Session Learner State Fields.

### Wave 3.12 - World 1 Completion Payoff v1

- target: milestone surface after W1 completion with W2 preview;
- embedded prerequisite: confirm unlocked/completed progression separation.

### Wave 3.13 - Sharky Growth / Companion Tone v1

- target: phrase tier contract and Foundation tier phrase sets;
- required: curated tiered phrase system, no AI/chat;
- includes: proof-specific fix-landed phrase variations and within-session
  repair streak acknowledgment if safe.

### Wave 3.14 - Competitive Wedge Pass v1

- target: make Sharky's method felt in first session;
- required: 2-3 small copy/framing improvements;
- no competitor comparison, no superiority claim;
- confirm Premium Entitlement Source of Truth before premium-adjacent copy
  changes.

### Wave 3.15 - W2-W4 Launch Quality Packet v1

- target: validate W2-W4 first-session quality;
- required: W2/W3/W4 screenshot/evidence packets;
- embedded contracts: Mistake Family Taxonomy and Canonical Telemetry Event
  Names;
- also confirm Practice Session Concept ID seam if practical.

Then:

- refresh day2_return, first_week, and full_scroll packets;
- run fresh TOP1 challenger;
- proceed to Wave 4.0 Store/Public Readiness only if excellence score band is
  strong enough.

## 9. Required Architecture Contracts

### A. Replay Source Boundary

- timing: before Wave 3.10;
- motion/presentation consumes `Act0StreetReplayStepV1` or equivalent
  structured replay steps;
- no authored-content assumption;
- no hand-import parser implementation.

### B. Cross-Session Learner State Fields

- timing: during Wave 3.11;
- fields: `last_session_repair_focus_id`, `last_session_proof_result`,
  `last_session_date`, `last_session_world_id`;
- owner: session close seam;
- readers: Day 2 return, future resurfacing.

### C. World Progression Schema

- timing: during Wave 3.12;
- `unlocked` and `completed` must be separate concepts;
- payoff gates on `completed`, not `unlocked`.

### D. Sharky Phrase Tier Contract

- timing: during Wave 3.13;
- Foundation / Developing / Sharp tiers;
- phrase sets per moment type;
- deterministic selection by world band.

### E. Premium Entitlement Source of Truth

- timing: before or during Wave 3.14;
- W1-W4 free / W5-W36 premium boundary must be canonical;
- no payment implementation.

### F. Mistake Family Taxonomy

- timing: during Wave 3.15;
- W1-W4 family names and mapping mechanism;
- no W5-W36 taxonomy overbuild before those worlds are authored.

### G. Canonical Telemetry Event Names

- timing: during Wave 3.15;
- event names: `session_start`, `decision_made`, `repair_attempted`,
  `fix_landed`, `session_complete`, `day2_return`, `world_complete`,
  `upgrade_viewed`.

### H. Practice Session Concept ID Seam

- timing: confirm during Wave 3.11 or Wave 3.15 if practical;
- no generative rep engine implementation.

## 10. Post-v1 / Later-Band Deferrals

Out of current implementation scope:

- solver validation layer;
- hand import implementation;
- advanced analytics dashboard;
- W13-W36 content authoring;
- advanced practice generator;
- full cross-session leak profile;
- server-side analytics sink;
- opponent tendency overlay;
- full commerce implementation;
- RU rollout beyond English-first boundary.

## 11. Updated Docs

Updated surgically:

- `docs/_reviews/wave3_9_1_36_world_top1_product_vision_route_lock_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/public_premium_top1_v1_endgame_lock_v1.md`
- `docs/_reviews/wave3_9_english_first_ru_localization_boundary_v1.md`

`docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` did not require edits because
it points to the SSOT and lock artifacts rather than owning the active wave
sequence.

## 12. Boundary Proof

This was docs-only route lock work.

Not changed:

- product code;
- motion;
- personalization;
- milestones;
- runtime route;
- localization;
- monetization;
- content;
- W5-W36 content authoring;
- architecture contract implementations.

No generated output files were staged.

## 13. Store/Public Readiness Delay Status

Store/Public Readiness is delayed.

It should resume only after:

1. Waves 3.10-3.15 are complete or explicitly blocked with accepted
   prerequisites.
2. Fresh day2_return, first_week, and full_scroll packets are available.
3. A fresh TOP1 challenger pass confirms the excellence score band is strong
   enough.

## 14. Validation

Validation passed:

- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- `git status --short`

No Flutter tests were required because no product code changed.

## 15. Next Recommendation

Proceed to Wave 3.10 - Premium Motion Moments v1.
