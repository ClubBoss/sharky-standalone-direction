# TOP1 Product Attack Plan Refresh v2

## 1. Verdict

top1_refresh_ready_post_repair_loop_copy

## 2. Why refresh was needed

`TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` still treated Day 2 proof and screenshot
acceptance as the current frontier. That was stale after the repair-loop stack
closed through Repair Loop Copy / Claim-Safety Pass v1 at `a92bbdd7`.

The strategy doc needed to distinguish the now-strong internal repair loop from
the still-weaker external commercial/RPG packaging layer.

## 3. Current repair-loop state added

The refreshed plan records the current loop:

`mistake -> repair intent -> Review history -> Practice repair queue -> Practice this -> repair target -> source handoff -> repair outcome -> local proof -> Session Summary repair receipt -> Profile evidence / earned moments`

## 4. Family A closure

Family A from the repair-loop UX audit is now closed:

- repair-loop copy moved from plumbing vocabulary to learner-safe fix language;
- Profile skill snapshot, `Lv N`, and unitless `+N` claims are gated away;
- exact badge count copy was removed from Profile proof.

## 5. Score refresh

The plan now uses dual scoring:

- internal architecture/product logic remains high because the repair loop is
  contract-backed and visible;
- external commercial/product packaging remains lower because taxonomy, RPG
  structure, visual badges, and premium packaging are not yet evidence-backed.

Scores are explicitly marked as product-strategy estimates, not cohort data.

## 6. Claude audit integration

The refresh incorporates the repair-loop audit finding that the loop was real
but pre-copy language still read too much like plumbing.

It records that Family A was the highest-EV fix and that the remaining audit
implications are proof cohesion, taxonomy before art, evidence contracts before
levels/ratings, and later Runout-style analytics breadth.

## 7. Runout RPG benchmark integration

The plan now treats Runout's ratings, radar, session delta, difficulty, concept
mastery, and category breadth as future taxonomy input only.

It explicitly forbids copying Runout layout/assets/copy and blocks Sharky
rating/radar/level systems until an evidence-backed skill contract exists.

## 8. Updated next-action order

The active next order is now:

1. Achievement Taxonomy v1 - No Art
2. Evidence-Based Skill/RPG Taxonomy Contract v1
3. Fixes You've Banked / Proof Home Contract v1
4. Queue Resolution Contract v1
5. Review Resolution Contract v1
6. Badge/Icon Visual System
7. Commercial Packaging / Premium Arc

Optional post-copy Claude/Gemini visual recheck is documented as optional, not
the active bottleneck.

## 9. Guardrails preserved

Preserved or tightened:

- no fake mastery;
- no abstract levels/ratings without evidence source;
- no badge art before taxonomy;
- no Runout copying;
- no Modern Table reopening;
- no public paywall before proof loop/commercial safety;
- no queue/Review resolution before explicit resolution contracts;
- no AI/leak/mastery/GTO/solver overclaim.

## 10. Files changed

- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/top1_product_attack_plan_refresh_v2.md`

## 11. Validation

Required docs-only validation:

- `git diff --check` - passed.
- `graphify hook-check` - passed.
- `git status --short` - only admitted docs plus pre-existing generated output
  directories.

No product tests or screenshot generation were required for this docs-only
refresh.
