# Owner Cycle D Structural Closure and V2 Production Admission v1

Status: OWNER-LEVEL ROADMAP AUTHORITY / DOCS-ONLY
Date: 2026-09-10
Repository: `ClubBoss/sharky-standalone-direction`

## Purpose

Provenance record for the owner decision that closes structural visual
exploration and admits the Cycle C V2 spatial arrangement as the production
learning-scene spatial baseline, with one bounded evidence-backed camera
exception.

This record supersedes only the blanket "no camera change at all" reading of the
PR #203 / `CAMERA_RETUNE_AGAIN` freeze, and only to the exact extent stated
below. It does not reopen B1-B7, does not weaken the evidence hierarchy, does not
admit final character art, does not implement V2, and does not run P02.

It sits beside — and does not modify — the prior owner authority
`docs/_reviews/owner_pre_p02_north_star_convergence_rebaseline_v1.md`, which
remains historical provenance.

## Exact baseline

- live `origin/main` at authoring:
  `cc91e0421393aa94a29ab88fa2f75776dd17af8f`
  (merge of PR #211, `fix/far-seat-character-embodiment-clearance-v1`) — matches
  the dispatch's expected historical head exactly.
- original PR #203 production camera on `origin/main`
  (`lib/ui_v2/act0_shell/act0_scene_depth_v1.dart`):
  `outerTableWidthFraction 0.810`, `projectedTableHeightFraction 0.500`,
  `farRailFraction 0.225`.
- PR #212: `OPEN / DRAFT`, head
  `e0617ae814a89749e38361980cee7d0c3226ce93`
  (`mission/cycle-b-seated-embodiment-pilot-v3`) — untouched by this record.
- protected checkout `/Users/elmarsalimzade/Sharky_1.0` — untouched.

Cycle C and Cycle D ran on isolated experiment branches taken from the PR #212
head. Neither is on `origin/main`; nothing from either experiment is merged.

## Owner decision

1. The Cycle D structural adjudication is accepted.
2. `STRUCTURAL_VISUAL_EXPLORATION = CLOSED`.
3. Cycle C V2 is selected as the production spatial baseline.
4. One bounded V2 camera exception is authorized:
   - `farRailFraction` `0.225 -> 0.27`;
   - `projectedTableHeightFraction` `0.50 -> 0.47`.
5. This is a bounded, evidence-backed exception to the prior PR #203 /
   `CAMERA_RETUNE_AGAIN` freeze language. The prior freeze was valid; Cycle C and
   Cycle D were a specifically admitted bounded falsification; the owner now
   admits the winning bounded exception.
6. It does not reopen table/camera exploration generally.
7. No further camera, taper, perspective, table-width or structural-challenger
   work is admitted. After this admission the spatial family `REFREEZES` at V2.
8. The V2 spatial principles selected by the evidence are preserved:
   - opponent world wider than the felt/table stage;
   - far-centre / upper-flank / near-flank depth tiers;
   - front/back opponent planes;
   - deterministic geometry across learning states;
   - Hero POV;
   - poker-information dominance;
   - explicit Coach Surface reservation;
   - transparent authored-character asset seam.
9. The Cycle D challenger is rejected / reference only.
10. 9-max fan-out is deferred. 9-max is not currently admitted product scope.
11. PR #212 must not merge standalone. Its reusable asset pipeline should be
    selectively extracted into the production character wave, and PR #212 then
    superseded/closed after verified extraction.
12. Approved visual references are direction/evidence targets, not authority over
    runtime truth:
    - `C2` = 6-max spatial visual North Star;
    - `R2.3` = Coach Surface visual North Star;
    - `CAST V4` = Character Identity North Star;
    - `C2-9` = deferred future 9-max concept reference.
13. The biggest remaining production risk is not another camera hypothesis. It is
    that production assets may technically fit their envelopes while still
    failing to visibly read as convincing seated players at phone scale,
    especially far-centre.

## Cycle C finding (experimental, not merged)

`docs/_reviews` reference: Cycle C — North Star -> Runtime Spatial Proof v1.

- `6MAX = LIMITED-PASS` with the V2 camera nudge; `LIMITED` without any camera
  change (far-centre opponent vs coach-budget deficit).
- Bounded spatial rebalance alone (wide opponent world, three depth tiers,
  front/back planes, diagnostic seated proxies) moved the flank opponents from
  ~16 px slivers to 55-73% on-screen seated figures, but left a ~40 px top
  vertical-budget deficit for the R2.3 coach surface + far-centre relief.
- `STRUCTURAL_REBALANCE_V2` added the bounded camera nudge
  (`farRailFraction 0.225 -> 0.27`, `projectedTableHeightFraction 0.50 -> 0.47`;
  width and taper unchanged). With V2, all five opponents read as seated, poker
  information stays dominant, Hero POV preserved, coach surface coexists with a
  clean gap in every state, and the frozen geometry invariant test stays green.
- `CAMERA_STATUS = MODIFY_JUSTIFIED` for the small far-rail drop only.
- `9MAX_HEADROOM = LIMITED` — the tier skeleton is reusable but needs bounded
  intra-tier fan-out.

## Cycle D winner (experimental, not merged)

`docs/_reviews` reference: CYCLE_D_FINAL_STRUCTURAL_CHALLENGER_V1.

- Control = V2 exactly as Cycle C shipped it.
- Challenger = a more aggressive camera + tier push (far rail lower, felt
  narrower, flanks wider and larger), no perspective/taper change.
- 6-max runtime A/B + 9-max fair stress, real Flutter goldens, full regression.
- `MATERIAL_LIFT = NO`. `WINNER = V2`. The challenger produced a broad *minor*
  improvement (clearer realistic-coach headroom; marginally better embodiment,
  depth ratio, lateral room) while marginally regressing flank on-screen body
  and adding implementation surface. It did not move camera angle / perceived
  perspective (the two things `C2` is actually about) and did not improve poker
  readability, Hero POV, 375 usability or determinism. Per the D6 gate, a close
  result means the control wins.
- The generic 9-max intra-tier fan-out is family-agnostic and shared; it is the
  9-max win, not the family, and it is deferred until 9-max is admitted.

## Astra reconciliation

`docs/_reviews` reference: ASTRA_POST_CYCLE_D_RECONCILIATION_V1.

- `CYCLE_D_CONTROL_CAMERA_OBSERVED` = `farRailFraction 0.27`,
  `projectedTableHeightFraction 0.47`, `outerTableWidthFraction 0.81`,
  taper/perspective unchanged.
- The Cycle D wording "keep frozen PR203" accurately describes the *authority
  boundary* but is inconsistent if read as the camera used by the winning
  captures. Corrected interpretation: retain Cycle C V2 as the winning
  production candidate at `0.27 / 0.47`, width `0.81`, unchanged taper; obtain
  explicit owner admission for those two camera changes; until admission,
  production retains original PR #203.
- This record is that owner admission.
- `STRUCTURAL_EXPLORATION = CLOSED` as the supplied experimental adjudication;
  final visual acceptance of production art remains open.
- Biggest remaining production risk: mistaking envelope clearance for visible
  production quality. The inspected 375 V2 coach capture shows placeholder text
  blocks, a placeholder coach portrait, and only a small fragment of the
  far-centre character above the rail. Positive bounding-box clearance does not
  establish readable production coach content or sufficient visible character
  area. Resolve through art fitting and real runtime acceptance within V2; do
  not silently certify it and do not reopen structural exploration.

## Exact selected V2 values

Production spatial baseline camera (to be implemented in the V2 skeleton wave,
in `lib/ui_v2/act0_shell/act0_scene_depth_v1.dart`):

| constant | original PR #203 | admitted V2 | status |
| --- | --- | --- | --- |
| `farRailFraction` | `0.225` | `0.27` | bounded exception, admitted |
| `projectedTableHeightFraction` | `0.50` | `0.47` | bounded exception, admitted |
| `outerTableWidthFraction` | `0.810` | `0.810` | frozen, unchanged |
| taper / perspective near-far width factors | unchanged | unchanged | frozen, unchanged |
| all other scene-depth / table constants | unchanged | unchanged | frozen under PR #203 |

Derived (height 874): far rail moves down ~39 px, near rail moves down ~13 px;
near-rail fraction `0.725 -> 0.74`.

Tiered seating grammar (wide opponent world, far-centre / upper-flank /
near-flank tiers, front/back planes, per-tier world anchor + scale + inward
facing) is admitted in principle; its exact production constants are set during
the V2 skeleton wave, not frozen by this record. The Cycle D challenger's
`cycleDChallenger` camera and `challengerV1` seating constants are discarded.

## Explicit bounded exception

`V2_CAMERA_EXCEPTION = ADMITTED / REFROZEN`

- scope: exactly the two constants above;
- justification: causally required for the R2.3 coach budget + far-centre relief
  (Cycle C), confirmed net-best against a bounded structural challenger
  (Cycle D);
- everything else in PR #203 canonical table geometry remains `FROZEN` and under
  PR #203 ownership;
- the exception does not license any further camera/taper/perspective/width or
  structural iteration. The family is refrozen at V2.

## What remains frozen

- PR #203 canonical table geometry for all constants outside the two-value
  exception;
- PR #205 commitment ownership;
- `PR205_COMMITMENT_OWNERSHIP = FROZEN`;
- Modern Table `MAINTENANCE_MODE` outside admitted North Star convergence work;
- `TEXT_SCALE_POLICY_V1 = SINGLE_CANONICAL_PRODUCT_SCALE`;
- `ACCESSIBILITY_TEXT_SCALING = DEFERRED_NOT_CURRENT_ACCEPTANCE`;
- `B1-B6 = CLOSED_PASS`, `B7 = CLOSED_PASS`,
  `SHARKY_COACH_SURFACE_V1 = CLOSED_PASS` (historical implementation evidence);
- `HUMAN_PROOF = FALSE`; `B8 = NOT_ADMITTED`; `P02 = DEFERRED / NOT_CURRENT_GATE`.

## What is deferred

- Cycle D challenger constants, any further camera/taper exploration, exact `C2`
  perspective matching;
- `C2-9` / 9-max implementation, intra-tier fan-out, additional cast density,
  until 9-max is explicitly admitted (`9MAX_FANOUT = DEFERRED / NOT_ADMITTED`);
- speculative asset architecture, diagnostic family switches, and environment
  polish without a demonstrated production defect;
- real R2.3 Coach Surface visual implementation until the character wave;
- final opponent art for the flank seats.

## PR #212 disposition

`Extract reusable pipeline into the production character wave; supersede/close
after verified extraction. Do not merge standalone.`

- PR #212 remains `OPEN / DRAFT`, head
  `e0617ae814a89749e38361980cee7d0c3226ce93`; no PR action taken by this record.
- reusable pieces to carry selectively: asset registration, asynchronous image
  loading with procedural fallback, deterministic destination painting,
  room-tone / folded treatment.
- the far-centre-only selector and the pilot art are not automatically the final
  cast contract.
- this record must not be read as authorization to merge or close PR #212;
  closure happens only after verified extraction into the character wave.

## Visual reference identities

| reference | role | authority |
| --- | --- | --- |
| `C2` | 6-max spatial visual North Star | direction/evidence target, not runtime authority |
| `R2.3` | Coach Surface visual North Star | direction/evidence target, not runtime authority |
| `CAST V4` | Character Identity North Star | direction/evidence target, not runtime authority |
| `C2-9` | deferred future 9-max concept reference | not admitted scope |

Runtime truth (frozen geometry, deterministic layout, poker-information
dominance, evidence hierarchy) outranks all four.

## Biggest remaining production risk

Mistaking envelope clearance for visible production quality — particularly
far-centre embodiment and real-font Coach content at actual phone scale.
Visible opaque character embodiment at real phone scale, and non-clipped
essential Coach feedback at 375 first, are hard acceptance gates for the later
character and Coach waves. This risk is resolved by art fitting and real runtime
acceptance within V2, not by reopening structural exploration.

## Next implementation wave

`EXACT_NEXT_ACTION = IMPLEMENT_V2_PRODUCTION_SPATIAL_SKELETON_V1`

Inside the current `PRE_P02_VISUAL_ART_COMPLETION_GAUNTLET_V1` family. Narrowly:

- productionize the winning V2 skeleton (bounded camera exception + wide
  opponent world + three depth tiers + front/back planes);
- remove diagnostic family / challenger machinery from the production path;
- no final opponent art yet;
- no R2.3 visual implementation yet;
- no 9-max fan-out;
- no environment polish;
- no further camera / taper search.

Then, in order: character system + 6-max cast (with PR #212 extraction) ->
R2.3 Coach Surface with real typography and Sharky art -> conditional
environment correction -> final runtime acceptance on the real learning route
across decide / correct / wrong / repair / continuation.

## Authority reconciliation

- `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md` remains principal
  day-to-day authority and records the bounded exception + structural closure.
- `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md` carries the exact updated
  dispatch and next sub-wave.
- `docs/context/CURRENT_EXECUTION_HANDOFF_v1.md` remains a non-authority
  continuation aid.
- This record is the owner-level provenance for the decision.
- Historical provenance is preserved: the old PR #203 freeze was valid; Cycle C
  and Cycle D were an admitted bounded falsification; the owner now admits the
  winning bounded exception; the family then refreezes at V2.

## Preserved product state

`B1-B6 = CLOSED_PASS`
`B7 = CLOSED_PASS`
`SHARKY_COACH_SURFACE_V1 = CLOSED_PASS` (historical implementation evidence)
`P02 = DEFERRED / NOT_CURRENT_GATE`
`HUMAN_PROOF = FALSE`
`B8 = NOT_ADMITTED`
`PR205_COMMITMENT_OWNERSHIP = FROZEN`
`STRUCTURAL_VISUAL_EXPLORATION = CLOSED`
`V2_PRODUCTION_SPATIAL_BASELINE = ADMITTED`
`V2_CAMERA_EXCEPTION = ADMITTED / REFROZEN`
`9MAX_FANOUT = DEFERRED / NOT_ADMITTED`
`EXACT_NEXT_ACTION = IMPLEMENT_V2_PRODUCTION_SPATIAL_SKELETON_V1`

No product/runtime/test code or assets are changed by this record.
