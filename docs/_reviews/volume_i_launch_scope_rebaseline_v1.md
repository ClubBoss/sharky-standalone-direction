# Volume I Launch Scope Rebaseline v1

## 1. Verdict

`volume_i_launch_scope_rebaseline_ready`

The active launch target is now Perfect W1-W12 Volume I Premium Product.

W13-W36 remain the long-horizon top-1 expansion roadmap, but they are
post-launch / live expansion / advanced curriculum, not pre-launch blockers
and not launch-available claims.

## 2. Source Truth

Files inspected and why:

- `AGENTS.md`: active repo boundary, readiness SSOT note, and no-archive
  default.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  launch/readiness routing note.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: active top-1 strategy SSOT
  and route-scope language.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active long-horizon
  ledger and current score/queue authority.
- `docs/_reviews/wave6_3_content_factory_mvp_l1_migrated_sample_v1.md`:
  accepted Wave 6.3 L1 migrated sample proof and next-step recommendation.
- `docs/_reviews/wave6_2_content_validation_rules_v1.md`: accepted L0
  validation proof and L1 handoff context.
- `docs/_reviews/wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md`:
  W1-W6 content-depth/schema risk and W7-W12 route constraints.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`: schema and route/content truth
  foundation.
- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`: validation ladder and
  Wave 6.3 handoff.

## 3. Decision

New launch target:

- Perfect W1-W12 Volume I Premium Product.

Deferred expansion:

- W13-W36 are post-launch / live expansion / advanced roadmap.
- W13-W36 are not cancelled.
- W13-W36 are not pre-launch blockers.
- W13-W36 must not be claimed as available in store, onboarding, paywall, or
  marketing until built and validated.

## 4. What Changes

Before this rebaseline, the long-horizon ledger could be read as if full
W1-W36 readiness was the launch completion target.

After this rebaseline:

- W1-W12 Volume I is the launch product.
- W1-W12 must be complete enough to stand as a premium product.
- W13-W36 shift to post-launch/live expansion.
- The score ledger separates W1-W12 Volume I Premium Product Readiness from
  Full W1-W36 Long-Horizon Readiness.

## 5. What Does Not Change

- The full W1-W36 top-1 ambition remains.
- Sharky remains a 36-world table-first poker skill-building system over the
  long horizon.
- The quality bar does not drop.
- W1-W12 must be 10/10 before public launch or monetization scale.
- W13-W36 are not cancelled; they are sequenced after Volume I proof.

## 6. Volume I Launch-Grade Bar

W1-W12 launch-grade requires:

- schema-backed content;
- validator-backed migration/factory path;
- route/content truth alignment;
- enough same-signal and transfer coverage;
- repair paths;
- progression and payoff;
- telemetry and measurement;
- poker correctness review for W1-W12 claims;
- human novice QA;
- privacy posture;
- monetization, IAP, restore, and entitlement proof;
- store, brand, onboarding, paywall, and copy readiness.

## 7. Active Repair Queue

Closed:

- W7-W10 route leak.
- W1-W6 content-depth audit classification.
- Content Schema Foundation.
- L0 Content Validation Rules.
- L1 Migrated Sample Pilot.

Active next candidates:

- L2 World Coverage Report for W1-W12.
- L2 World Coverage Report for W1-W6 first if W1-W12 is too broad.
- Tiny Content Factory Import/Export MVP.
- W2-W6 Route/Content Normalization.
- W7-W12 Admission/Content Lock.
- Human QA Protocol.

Must not skip:

- validator-backed migration proof before content production;
- route/content normalization before broad authoring;
- W1-W12 correctness and human QA before premium claims;
- no W13-W36 pre-launch dependency;
- no W13-W36 launch-availability claims.

Deferred:

- W13-W36 content production;
- W7-W12 opening until route-admission/content lock;
- monetization/store until Volume I proof gates are strong enough.

## 8. Score Ledger Update

Current accepted rough scores:

- W1-W4 beachhead: `8.3`
- W1-W12 Volume I Premium Product Readiness: `5.3`
- Full W1-W36 Long-Horizon Readiness: `3.0`
- Learning effect: `6.0`
- Personalization / repair: `5.0`
- Progression / dopamine: `6.0`
- Visual / premium feel: `8.3`
- Content depth: `4.5`
- Telemetry / measurement: `4.3`
- Monetization readiness: `2.0`
- Architecture scalability: `7.3`
- Competitive moat: `5.5`
- Store / brand readiness: `5.0`
- Overall Top-1 Readiness: `5.1`

This rebaseline mostly reduces control-plane drift. It does not move product
proof by itself beyond clearer launch scope and KPI separation.

## 9. Route / Claim Safety

- Do not market W13-W36 as available.
- Do not imply 36 worlds at launch.
- Frame W1-W12 as complete Volume I only after its gates are met.
- Frame W13-W36 as future expansion until built and validated.
- W7-W10 remain `locked_not_learner_playable`.
- W11-W12 remain `authored_but_not_routed`.
- Quick public/store beta remains paused unless explicitly reactivated.

## 10. Next-Step Recommendation

Recommended next highest-EV wave:

- L2 World Coverage Report for W1-W12, report-only and non-blocking.

Why:

- The new launch target is W1-W12, so the next highest-value question is what
  Volume I actually covers by concept family, same-signal group, transfer
  surface, repair focus, route gate, and validation status.
- It should not open W7-W12 or author content.
- It should expose whether W1-W12 is safe to audit in one pass.

Fallback:

- If W1-W12 is too broad or route-conflicted for one safe wave, run L2 World
  Coverage Report for W1-W6 first, then extend to W7-W12 after the admission /
  content lock.

## 11. Wave DoD Status

- [x] TOP1 SSOT updated.
- [x] Long-horizon ledger updated.
- [x] Volume I KPI added.
- [x] W13-W36 deferred clearly.
- [x] W1-W12 quality bar defined.
- [x] Active repair queue updated.
- [x] No product/code/content scope touched.

## 12. Evidence DoD Status

Commands and results:

- `graphify hook-check`
  - Passed with no output.
- `git diff --check`
  - Passed with no output.
- Direct ASCII check on changed markdown files.
  - Passed. `LC_ALL=C grep -n '[^ -~]' ...` returned no matches.
- Direct trailing-whitespace and CRLF check on changed markdown files.
  - Passed with no output.
- Stale wording scan for W13-W36 pre-launch or launch-available claims.
  - Passed. Matches were limited to explicit negation / forbidden-claim
    guardrails, not positive availability claims.

Dart, Flutter, and screenshots were not run because this was a docs-only
control-plane rebaseline.

## 13. Anti-Drift Note

Future agents must not revert to a 36-world pre-launch assumption.

The correct route is:

1. Make W1-W12 Volume I launch-grade.
2. Do not claim W13-W36 at launch.
3. Use W13-W36 as post-launch/live expansion after Volume I proof or first
   real users.
4. Keep full W1-W36 top-1 ambition alive without letting it block Volume I
   launch discipline.
