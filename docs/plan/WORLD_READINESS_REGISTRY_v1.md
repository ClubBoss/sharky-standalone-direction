# WORLD_READINESS_REGISTRY_v1
Status: REFERENCE
Purpose: historical world-quality registry for broader release-readiness
framing. Keep for traceability and later-world reference, not for current
day-to-day product routing.
Last updated: 2026-04-02

## Purpose

This registry historically sat beneath
`docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`.

Current active route and active visible product priorities now live in:

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/LAUNCH_SURFACE_MECHANISM_v1.md`

Use it to answer the world-level questions the main readiness SSOT should not
carry directly:

- which worlds are structurally present
- which worlds are pedagogically stronger than others
- where feedback, learner-language, or consistency debt still sits per world
- which world or cluster is the strongest next bounded content-quality route

## Authority / non-authority

- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` remains the top
  launch/readiness scoring authority.
- This registry is a subordinate world-quality tracking layer for that broader
  readiness frame.
- It does not introduce a second readiness verdict, weighted percentage, or
  competing scoring formula.
- It is intentionally narrower than the main SSOT: it tracks world-level
  quality shape, open gaps, and release-grade blockers.

Do not use this file first when choosing current product-facing waves.

## Status meanings

- `done` = this lens is materially strong for the world under current repo truth
- `in_progress` = real progress exists, but the lens is still mixed or not yet
  strong enough to close honestly
- `blocked` = the lens cannot move honestly until a more basic prerequisite is
  fixed
- `proof_pending` = repo evidence is promising, but the lens is not yet proved
  strongly enough to treat as secure
- `human_proof_pending` = the lens needs reviewer or release-grade human proof,
  not just structural repo evidence

## World quality matrix

| World | Title / progression role | Quality summary | Primary readiness links | Content clarity | Pedagogy / learning effect | Feedback / explanation quality | Learner-language naturalness | Content-runtime alignment | Cross-world consistency fit | Top open gaps | Evidence references | Release-grade blocker note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `W0` | Foundations / first table orientation | Structurally real, playable, and now release-grade complete as the first-user opener under current world-quality truth. | `D`, `E`, `F`, `J` | `done` | `done` | `done` | `done` | `done` | `done` | none explicit under current world-quality truth | `content/worlds/world0/v1/world.md`; `content/worlds/world0/v1/sessions/index.md`; `WORLD_NODE_MODE_MATRIX_v1`; `SKILL_COVERAGE_MATRIX_v1`; `ROADMAP_FINAL_100_SSOT` | none explicit under current world-quality truth |
| `W1` | Foundations / strongest live learner path | Strongest live early-world route and strongest production-grade learner path today, but still not fully release-grade across all quality lenses. | `D`, `E`, `F`, `J` | `in_progress` | `in_progress` | `in_progress` | `human_proof_pending` | `done` | `in_progress` | learner-language cleanup; world-scale maturity proof; release-grade human review | `content/worlds/world1/v1/world.md`; `WORLD_NODE_MODE_MATRIX_v1`; `SKILL_COVERAGE_MATRIX_v1`; `PROJECT_READINESS_EPICS_SSOT_v1` | Strongest live world, but still needs stronger language, proof, and world-level finish to count as release-grade. |
| `W2` | Position Basics / bridge and gold-like reference world | Strongest gold-like reference world after `W1`; bounded truth and rollout work are real, but the world is still thinner than a dense release-grade world. | `D`, `E`, `F`, `G` | `in_progress` | `in_progress` | `in_progress` | `human_proof_pending` | `done` | `in_progress` | denser world shape; recap/checkpoint identity; release-grade proof | `content/worlds/world2/v1/world.md`; `world2_dense_shape_audit_v1`; `world2_truth_family_registry_v1`; `ROADMAP_FINAL_100_SSOT` | Valid reference world, but not yet dense, fully proved, or release-grade complete. |
| `W3` | Pot Odds Intro / numeric call-threshold bridge | Structurally present, but still coarser than its intended world role and not yet strongly proved as a stable learning world. | `D`, `E`, `F`, `G` | `proof_pending` | `proof_pending` | `proof_pending` | `proof_pending` | `in_progress` | `in_progress` | world-shape proof; pedagogy density; feedback quality proof | `world_spine_v1`; `WORLD_NODE_MODE_MATRIX_v1`; `SKILL_COVERAGE_MATRIX_v1`; `content/worlds/world3/v1/world.md` | The world exists, but its teaching shape is still too coarse to call release-grade. |
| `W4` | Bet Sizing Basics / sizing-discipline bridge | Structurally present and partially de-risked by visible sizing work, but not yet a fully proved mainline world. | `D`, `E`, `F`, `G` | `in_progress` | `in_progress` | `in_progress` | `proof_pending` | `in_progress` | `in_progress` | mainline world proof; learner-language cleanup; cross-world sizing consistency | `world_spine_v1`; `WORLD_NODE_MODE_MATRIX_v1`; `PROJECT_READINESS_EPICS_SSOT_v1`; `content/worlds/world4/v1/world.md` | Sizing truth is visible, but the full world is not yet proved as a release-grade learner block. |
| `W5` | Board Texture / board-awareness transition world | Real world with meaningful content presence, but still mixed in pedagogy, explanations, and release-grade shape. | `D`, `E`, `F`, `G` | `in_progress` | `in_progress` | `in_progress` | `proof_pending` | `in_progress` | `proof_pending` | board-awareness coherence; feedback consistency; world-level proof | `world_spine_v1`; `SKILL_COVERAGE_MATRIX_v1`; `PROJECT_READINESS_EPICS_SSOT_v1`; `content/worlds/world5/v1/world.md` | World presence is real, but board-teaching and consistency are not yet strong enough for release-grade honesty. |
| `W6` | Turn Pressure / multi-street pressure world | Materially present and improved by bounded quality waves, but still mixed across pedagogy, feedback quality, and language. | `D`, `F`, `G` | `in_progress` | `in_progress` | `in_progress` | `in_progress` | `proof_pending` | `in_progress` | explanation quality; learner-language cleanup; cross-session consistency | `world_spine_v1`; `PROJECT_READINESS_EPICS_SSOT_v1`; `tools/feedback_quality_audit_v2.dart`; `content/worlds/world6/v1/world.md` | Later-world content is real, but the world is still too mixed to call release-grade. |
| `W7` | River Decisions / final-street clarity world | Materially present, with strong recent bounded quality movement, but still mixed beyond the recently hardened clusters. | `D`, `F`, `G` | `in_progress` | `in_progress` | `in_progress` | `in_progress` | `proof_pending` | `in_progress` | remaining family debt; learner-language cleanup; world-scale consistency | `world_spine_v1`; `PROJECT_READINESS_EPICS_SSOT_v1`; `tools/feedback_quality_audit_v2.dart`; `content/worlds/world7/v1/world.md` | Recent gains are real, but the world still has unresolved feedback and language debt outside the cleared families. |
| `W8` | Exploit Adjustments / controlled deviation world | Materially present, with major owner-like template work landed, but still mixed in explanation quality and release-grade finish. | `D`, `F`, `G` | `in_progress` | `in_progress` | `in_progress` | `proof_pending` | `proof_pending` | `in_progress` | explanation naturalness; exploit-teaching consistency; release-grade proof | `world_spine_v1`; `PROJECT_READINESS_EPICS_SSOT_v1`; `tools/feedback_quality_audit_v2.dart`; `content/worlds/world8/v1/world.md` | Stronger than a placeholder, but still too mixed to present as a finished release-grade later world. |
| `W9` | High Leverage Spots / costly-pressure world | Materially present, with multiple bounded family waves landed, but still mixed and not yet language-clean enough to count as release-grade. | `D`, `F`, `G` | `in_progress` | `in_progress` | `in_progress` | `in_progress` | `proof_pending` | `in_progress` | remaining audit debt; learner-language cleanup; cluster-level consistency | `world_spine_v1`; `PROJECT_READINESS_EPICS_SSOT_v1`; `tools/feedback_quality_audit_v2.dart`; `content/worlds/world9/v1/world.md` | High-pressure content exists, but world-level pedagogy and language are still not release-grade. |
| `W10` | Mastery Integration / all-constraints integration world | Materially present and heavily templated, but still mixed in explanation quality, natural language, and release-grade integration proof. | `D`, `F`, `G` | `in_progress` | `in_progress` | `in_progress` | `proof_pending` | `proof_pending` | `in_progress` | explanation quality; full-loop integration proof; release-grade finish | `world_spine_v1`; `PROJECT_READINESS_EPICS_SSOT_v1`; `tools/feedback_quality_audit_v2.dart`; `content/worlds/world10/v1/world.md` | The world is materially real, but still needs stronger quality proof before it can stand as a release-grade mastery capstone. |

## Usage notes

- Use this registry for route selection, world-level gap visibility, and
  release-grade honesty per world.
- Use `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` for readiness scoring,
  bottleneck ownership, closure claims, and block-level reporting.
- A world can be structurally present without being pedagogically strong,
  language-clean, or release-grade.
- World rows should stay compact. If a world needs deeper proof, link the
  bounded audit or family registry instead of expanding this registry into a
  second planning system.
