# W3 Source Ownership Remap v1

Status: Accepted.
Date: 2026-06-29.
Verdict: `w3_source_ownership_remap_recommends_bounded_8_review`.

## 1. Verdict

W3 source ownership is now mapped well enough to stop PR4 fixture churn and move
to a bounded W3 8.0 Certification Review gate.

The review scope must stay limited to the two existing canonical W3 families:

- `position_sensitive_preflop_decision`;
- `hand_bucket_action_frame_discipline`.

No metadata-only third family is safe from the remaining W3 source. The remaining
source either already belongs to the two canonical families, belongs to the
bridge/legacy negative-control layer, duplicates existing coverage, or is too
small to count as a new canonical concept family without new authoring.

## 2. Source truth

Inspected authority and evidence:

- `AGENTS.md`: active repo boundary, SSOT order, Act0 route truth, and graphify
  validation policy.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active document hierarchy.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: W1-W4 free foundation
  boundary and W3 launch-facing title.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active route pointer,
  score ledger, and blocker register.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W3 score, blocker state,
  and next action.
- `docs/_reviews/w3_source_title_realignment_plan_v1.md`: accepted W3 title
  decision and source-remap recommendation.
- `docs/_reviews/w3_canonical_coverage_expansion_pr3_source_truth_decision_v1.md`:
  prior PR3 stop decision.
- `docs/_reviews/w3_canonical_coverage_expansion_pr2_v1.md`: second canonical
  W3 family evidence.
- `docs/_reviews/w3_canonical_certification_pilot_v1.md`: first canonical W3
  family evidence.
- `docs/_reviews/w2_8_0_certification_closure_v1.md`: precedent for bounded
  8.0 closure after correctness and payoff/progression proof.
- W3 source files under `content/worlds/world3/v1`.
- W3 fixtures under `test/fixtures/content_factory_mvp`.

## 3. Current W3 state

W3 currently has:

- one accepted bridge/legacy negative-control fixture:
  `w3_bridge_or_legacy_schema_migration_pilot_v1.json`;
- one accepted canonical pilot family:
  `w3_canonical_certification_pilot_v1.json`;
- one accepted canonical PR2 family:
  `w3_hand_bucket_action_frame_canonical_pr2_v1.json`;
- W3 score `5.8`;
- route title `Position Thinking`;
- mixed source ownership: Position Thinking-safe source, preflop-framework
  bridge source, and duplicate three-step source clusters.

W3 does not have:

- a safe third canonical fixture candidate;
- fixture-level 8.0 correctness review;
- W3-specific payoff/progression proof;
- Human QA execution;
- launch-grade or 9.0 evidence.

## 4. Existing canonical ownership

Canonical-owned source:

| Canonical family | Source files | Ownership |
| --- | --- | --- |
| `position_sensitive_preflop_decision` | `w3.s11` through `w3.s14` position chains | `w3_canonical_owned`; these tasks explicitly start from position before preflop action. |
| `hand_bucket_action_frame_discipline` | selected chain steps from `w3.s01`, `w3.s02`, `w3.s08`, and `w3.s10` | `w3_canonical_owned`; this is the bounded hand-bucket/action-frame support slice already accepted in PR2. |

These two families are eligible for a bounded W3 8.0 review, but only as
fixture-scoped canonical evidence. They do not make the whole W3 source tree
canonical.

## 5. Bridge/source ownership

Bridge/legacy-owned source:

| Source group | Ownership |
| --- | --- |
| `w3_bridge_or_legacy_schema_migration_pilot_v1.json` | `bridge_or_legacy_only`; it remains the negative control. |
| `choose_call_preflop_checkpoint_v1` | `bridge_or_legacy_only`; checkpoint action-choice leaf used by bridge evidence. |
| `choose_raise_mixed_context_checkpoint_v1` | `bridge_or_legacy_only`; checkpoint action-choice leaf used by bridge evidence. |
| `choose_fold_final_preflop_checkpoint_v1` | `bridge_or_legacy_only`; checkpoint action-choice leaf used by bridge evidence. |

The bridge layer must remain excluded from canonical W3 coverage claims.

## 6. Remaining W3 source ownership map

| Source group / chain | Observed job | Best ownership bucket | W3 Position Thinking alignment | Canonical eligibility | Risk | Required action |
| --- | --- | --- | --- | --- | --- | --- |
| `w3.s01 d.chain_preflop_framework_intro_v1` | Introduces compact open/call/fold from hand strength, position, and facing-open context. | `w3_canonical_owned` for the selected PR2 step; remainder is already consumed support source. | Medium. Supports action framing, not a pure position-first chain. | Already counted only through PR2. | Duplicate PR2 evidence if reused. | Do not export again. Keep under PR2 ownership. |
| `w3.s02 d.chain_preflop_category_reuse_v1` | Reuses hand category across unopened and facing-open decisions. | `w3_canonical_owned` for the selected PR2 step; remainder is already consumed support source. | Medium. Supports hand-bucket/action-frame discipline. | Already counted only through PR2. | Duplicate PR2 evidence if reused. | Do not export again. Keep under PR2 ownership. |
| `w3.s03 d.chain_preflop_checkpoint_v1` | Checkpoint across raise/call/fold preflop framework defaults. | `bridge_or_legacy_only`. | Low-medium. It is preflop-framework checkpoint evidence, not a clean Position Thinking family. | Not eligible for W3 PR4. | Overlaps PR2 and bridge negative control. | Keep bridge/legacy. |
| `w3.s03 d.choose_call_preflop_checkpoint_v1` | Single action-choice leaf for calling in position versus cutoff open. | `bridge_or_legacy_only`. | Medium as a single spot, too narrow as a family. | Not eligible alone. | Would erase bridge negative-control separation. | Keep bridge/legacy. |
| `w3.s04 d.chain_preflop_premium_strong_reps_v1` | Three reps around premium/strong hand action defaults. | `unsafe_or_deferred`. | Low-medium. Mostly hand-strength/action-frame repetition. | Not eligible now. | Three tasks only and duplicative of PR2. | Defer unless new authored family expands it with source-owned transfer. |
| `w3.s05 d.chain_preflop_medium_weak_discipline_v1` | Three reps around medium/weak continue-or-release discipline. | `unsafe_or_deferred`. | Low-medium. Mostly hand-strength/action-frame repetition. | Not eligible now. | Three tasks only and duplicative of PR2. | Defer unless new authored family expands it with source-owned transfer. |
| `w3.s06 d.chain_preflop_mixed_context_checkpoint_v1` | Mixed checkpoint across unopened, facing-open, and blind-defense-like release. | `bridge_or_legacy_only`. | Low-medium. It is checkpoint synthesis, not a distinct Position Thinking family. | Not eligible for W3 PR4. | Overlaps PR2 and bridge negative control. | Keep bridge/legacy. |
| `w3.s06 d.choose_raise_mixed_context_checkpoint_v1` | Single action-choice leaf for opening ATo on the button. | `bridge_or_legacy_only`. | Medium as a spot, too narrow as a family. | Not eligible alone. | Would erase bridge negative-control separation. | Keep bridge/legacy. |
| `w3.s07 d.chain_preflop_open_fold_position_v1` | Three unopened open/fold decisions with position pressure. | `w3_canonical_candidate_after_remap`. | Medium-high. Position matters, but the chain duplicates the accepted pilot family. | Not eligible now. | Three tasks only; duplicate of existing position-sensitive pilot. | Candidate only if a future authoring wave expands it into distinct source-owned transfer. |
| `w3.s08 d.chain_preflop_continue_fold_discipline_v1` | Continue/fold discipline after opens. | `w3_canonical_owned` for the selected PR2 step; remainder is already consumed support source. | Medium. Supports hand-bucket/action-frame discipline. | Already counted only through PR2. | Duplicate PR2 evidence if reused. | Do not export again. Keep under PR2 ownership. |
| `w3.s09 d.chain_preflop_same_hand_different_action_v1` | Same hand changes action by position/facing-open frame. | `w3_canonical_candidate_after_remap`. | High concept alignment, but source is too small and overlaps existing pilot. | Not eligible now. | Three tasks only and duplicate position/action shift evidence. | Candidate only if expanded by a future source-authorship wave. |
| `w3.s10 d.chain_preflop_final_checkpoint_v1` | Final checkpoint across open/call/fold defaults. | `w3_canonical_owned` for the selected PR2 step; bridge sibling remains `bridge_or_legacy_only`. | Medium. PR2-selected step supports action-frame discipline. | Already counted only through PR2. | Duplicate PR2 or bridge evidence if reused broadly. | Keep split ownership: PR2-selected chain step canonical, action-choice leaf bridge. |
| `w3.s10 d.choose_fold_final_preflop_checkpoint_v1` | Single action-choice leaf for folding weak cutoff open. | `bridge_or_legacy_only`. | Medium as a spot, too narrow as a family. | Not eligible alone. | Would erase bridge negative-control separation. | Keep bridge/legacy. |
| `w3.s11 d.chain_position_open_call_v1` | Position first, then open or call decision. | `w3_canonical_owned`. | High. | Already counted in canonical pilot. | Duplicate pilot evidence if reused. | Do not export again. |
| `w3.s12 d.chain_position_continue_fold_v1` | Position first, then continue or fold after facing an open. | `w3_canonical_owned`. | High. | Already counted in canonical pilot. | Duplicate pilot evidence if reused. | Do not export again. |
| `w3.s13 d.chain_position_open_fold_v1` | Position first, then open/fold in unopened pot. | `w3_canonical_owned`. | High. | Already counted in canonical pilot. | Duplicate pilot evidence if reused. | Do not export again. |
| `w3.s14 d.chain_position_sensitive_open_fold_v1` | Position first, then same hand changes decision by seat. | `w3_canonical_owned`. | High. | Already counted in canonical pilot. | Duplicate pilot evidence if reused. | Do not export again. |
| `w3.s14 d.choose_raise_late_position_leverage_v1` | Single action-choice leaf for late-position KJo open. | `unsafe_or_deferred`. | High as a spot, too narrow as a family. | Not eligible alone. | Single-task evidence and overlaps pilot. | Defer unless expanded by a future authored family. |
| `spatial_projection_defaults_v1.json` | Support metadata for session projection. | `unsafe_or_deferred`. | Not a concept-family source chain. | Not eligible. | Counting support metadata as content would be theater. | Do not count as coverage. |

## 7. Remap decision

No safe metadata-only third W3 canonical family exists.

Decision:

- keep W3 title as `Position Thinking`;
- keep the two accepted canonical families as the only W3 canonical review
  scope;
- preserve the bridge/legacy fixture and action-choice leaves as negative
  controls;
- do not create PR4 fixture output from the remaining source;
- do not author new W3 content in this wave;
- move to W3 8.0 Certification Review with a two-family bounded scope.

## 8. Recommended next wave

`W3 8.0 Certification Review with Two-Family Bounded Scope`

The review must answer:

- whether the two canonical families have any P0/P1/P2 poker correctness issue;
- whether W3 has enough technical payoff/progression proof to pass bounded 8.0;
- whether bridge-plus-canonical evidence remains excluded from route-ready
  canonical claims;
- whether W3 stays below 8.0 until payoff/progression proof is repaired.

## 9. W3 certification impact

This remap does not certify W3.

It makes W3 eligible for a bounded 8.0 review gate because the review scope is
now explicit and limited. The likely certification boundary is:

- canonical-only W3 evidence: two families, 12 tasks, reviewable;
- bridge-plus-canonical W3 evidence: still bridge-limited, not certifiable;
- remaining source: not countable until future authored/remapped work.

## 10. Ledger impact

No score movement.

Recommended ledger updates:

- keep W3 at `5.8`;
- keep W1-W12 Volume I Premium Product Readiness at `7.0`;
- keep Content depth at `5.6`;
- keep Overall top-1 readiness at `6.3`;
- update active next action from `W3 Source Ownership Remap` to
  `W3 8.0 Certification Review with Two-Family Bounded Scope`;
- add this artifact as evidence.

## 11. Route impact

No route change.

- W3 remains `Position Thinking`.
- W4 remains unopened by this wave.
- W4-W6 remain bridge-limited.
- W7-W12 remain closed/non-routed.
- W13-W36 remain post-launch/deferred.
- W1-W4 monetization boundary remains free foundation; no paywall or pricing
  change occurs here.

## 12. Active repair queue update

Closed:

- W3 Source Ownership Remap.

Active next:

- W3 8.0 Certification Review with Two-Family Bounded Scope.

Must not skip:

- Keep bridge evidence excluded from canonical claims.
- Review only the two accepted W3 canonical families.
- Run correctness before any 8.0 claim.
- Require W3-specific payoff/progression proof before a clean 8.0 closure.

Deferred:

- W3 PR4 fixture output.
- New W3 source authorship.
- W4 Canonical Certification Pilot.
- W2-W6 batch canonicalization.
- W7-W12 opening.
- Human QA execution.
- Monetization, UI, telemetry, screenshots, and launch claims.

## 13. Evidence DoD status

Satisfied:

- source ownership map created;
- existing canonical family ownership preserved;
- bridge/legacy negative-control ownership preserved;
- no fixture output added;
- no product code changed;
- no score inflation recommended;
- next wave selected.

Required validation for this docs-only wave:

- `graphify hook-check`;
- `git diff --check`;
- `git diff --cached --check`;
- direct ASCII check;
- direct trailing-whitespace, CRLF, and final-newline checks.

## 14. Anti-theater check

This remap does not pretend source classification is product progress.

It reduces certification risk by naming what W3 can honestly review next:
two canonical families and no bridge evidence. It also names what W3 cannot
claim: a third metadata-only family, broad W3 migration, W3 8.0, W3 9.0,
launch readiness, Human QA, or durable learning proof.
