# Top-1 Route Recalibration After Day 2 Proof v1

## Scope

Docs / SSOT alignment only. No product code, UI, copy, tests, routes,
telemetry, screenshot tooling, Modern Table, commerce, entitlement, stamina,
energy economy, AI/persona, or monetization behavior changed.

This note preserves the current top-1 route after the Day 2 return proof packet
became deterministic and reviewable.

## Evidence basis

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/plan/MONETIZATION_SSOT_v1.md`
- `docs/_reviews/first_return_day2_proof_acceptance_v1.md`
- `docs/_reviews/first_return_day2_proof_packet_capture_lane_v1.md`

Current pushed evidence:

- `741b8cba92174a5e98eaf713bdeec6e3aa18547e` accepted the Day 2 proof
  contract.
- `35e0362b95a64a56e16b9300bf828067b4818073` added the deterministic
  `day2_return` fast proof packet lane.

## Adopted decisions

### Dual-score model

Future top-1 reporting must keep two scores separate:

1. **Architecture / Product Logic score** - whether the route, state,
   deterministic repair logic, return priority, and owned seams work.
2. **Commercial Proof / External Readiness score** - whether actual evidence
   packets, screenshots, content depth, commercial packaging, and release
   support are strong enough for outside users, reviewers, and buyers.

Do not inflate commercial readiness because internal contracts are green.
Day 2 behavior is contract-proven and packet-capturable, but commercial proof
must still be judged from actual packet quality.

### Target segment

The target learner is a casual-to-serious / micro-stakes player who already
plays poker, makes mistakes, and wants to quickly understand what to fix.

Sharky is not trying to replace GTO Wizard, become solver-pro tooling, or lead
with black-box AI/adaptive claims.

### Current top-1 route

The route is:

1. **Proof of repair** - wrong/suboptimal choice becomes missed signal,
   selected repair hand, reason, and repair outcome.
2. **Proof of return** - the same open repair survives relaunch and owns the
   next useful action.
3. **Proof of content depth** - the free and premium route has enough examples,
   term introduction, spaced reps, and drill coverage to justify trust.
4. **Proof of personalization** - recommendations remain deterministic,
   explainable, and specific to the learner's missed signal.
5. **Proof of monetization** - premium expands proven value after content,
   habit, commercial proof, and commerce safety are stronger.

### Day 2 green criterion

Day 2 is green when:

- open repair survives relaunch;
- Home prioritizes it;
- Practice launches the same repair target;
- Review shows active continuation;
- Profile does not falsely report a clear state;
- the dedicated Day 2 proof packet makes the chain reviewable.

Current lane:

```bash
./tools/screen_review_fast_v1.sh day2_return compact
```

Current output:

```text
output/screen_review/current/day2_return_fast/
```

## Rejected stale assumptions

- Do not use a single "product score" that mixes internal architecture with
  external commercial readiness.
- Do not treat contract-green Day 2 behavior as final commercial proof without
  reviewing the packet quality.
- Do not treat Sharky as solver-pro, GTO Wizard replacement, or advanced study
  tooling first.
- Do not revive W4 paywall assumptions as launch default.
- Do not start commerce because Day 2 proof is green.
- Do not add stamina, lives, energy, fake scarcity, or pressure mechanics
  before learning value is proven.
- Do not reopen Modern Table visuals unless concrete proof shows a table
  blocker.
- Do not treat broad content expansion as optional polish; content depth is P0
  after Day 2 evidence.

## Immediate next steps

1. **Commercial Screenshot / Renderer Acceptance** - inspect whether current
   packets are usable for external product/design/commercial review, including
   remaining renderer issues such as white bars or CTA-copy proof gaps.
2. **Content Depth / Term Introduction / Drill Coverage Audit** - audit whether
   the current W1-W36 route has enough real teaching depth and safe terminology
   to support the free-to-premium promise.

These may run in parallel if resources allow because renderer proof and content
audit use different workstreams.

## Content depth truth

Content depth is P0 after Day 2 evidence.

Current honest estimate: around `6.8-7.4 / 10`.

Reason: `W1-W4` free and `W5+` premium only works if W5-W36 contain credible
depth. Weak W5-W36 content would make premium structurally empty even if the
early Act0 route is strong.

## Monetization / commerce timing truth

Current monetization truth remains:

- `W1-W4` free public foundation.
- `W5+` future paid-depth boundary.
- Soft premium preview only after completed learning value.
- No public price, purchase, trial, restore, Premium Hub exposure, or hard
  route gate until commerce safety is deliberately scoped.

Commerce / entitlement / restore / receipt work is a launch hard blocker, but
it is not the current product bottleneck. Do not start a commerce sprint until
value, habit, and content proof are stronger.

## Deferred items

- stamina / energy economy;
- fake scarcity or pressure loops;
- public paywall / trial / restore / receipt implementation;
- Modern Table visual work;
- solver-pro/GTO positioning;
- AI/chat/ML behavior;
- dashboard/charts/XP/economy expansion.

## Exact recommended next prompt title

`Commercial Screenshot / Renderer Acceptance v1 — Local Only`

Parallel-safe companion if capacity allows:

`Content Depth / Term Introduction / Drill Coverage Audit v1 — Local Only`

## Validation

- `git diff --check`
- `git status --short`
