# Poker Analyzer Agent Instructions

## Quick Orientation

For project navigation and SSOT authority:
- Read `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` first (defines doc hierarchy)
- Then `docs/plan/MASTER_PLAN_v3.0.md` (active product-working master plan)

This file preserves critical project constraints and canonical entry points.

## Scope
These instructions apply to the entire repository.

## Canonical Root
- This repository is the standalone active product root.
- Canonical local root: `/Users/elmarsalimzade/Sharky_1.0`
- Canonical GitHub remote for active product work: `https://github.com/ClubBoss/sharky-standalone-direction.git`.
- Future pushes must target `origin/main` in this standalone repository.
- Older neighboring roots such as `Poker_Analyzer`, `Sharky`, and `Sharky_main` are legacy/donor/archive workspaces, not the default place for new product edits.
- Do not route active product fixes into neighboring roots unless the user explicitly asks for archive/reference retrieval.
- Do not spend tokens reading `docs/archive/`, `docs/_archive/`, archive buckets, or donor roots unless the user explicitly asks for historical/reference retrieval.
- Default document path is the active SSOT chain only; archive docs are opt-in.
- Do not treat `intro_*`, `core_*`, `tier_1_checkpoint`, or older table-first
  compatibility IDs as active content truth just because code still imports
  them; use `docs/content/LEGACY_COMPATIBILITY_OWNERS_v1.md` first.

## Readiness SSOT
- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` is the canonical launch/readiness authority for final `100/100`, store-prep framing, and release-side reporting.
- Future launch/readiness reporting should use its Core / Ship / Final layered model plus block and epic state movement rather than floating seam-only percentages.
- It must not override `docs/plan/MASTER_PLAN_v3.0.md` for day-to-day product prioritization or next-wave selection.
- `docs/plan/TRUE_RELEASE_READINESS_SSOT_v1.md` is historical only and must not be used as the active readiness authority.
- Closed seams should not be reopened without concrete new evidence.

## Execution Mode
- `docs/plan/MASTER_PLAN_v3.0.md` is the active execution-mode and route-order authority for current product work.
- `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md` and `docs/plan/ROUTE_TO_B_ACTION_LADDER_v1.md` are historical/reference execution docs only.
- Prefer the largest safe bounded wave that closes one active bottleneck family.
- One active bottleneck block at a time; use one mission prompt per active block.
- Reassess after 1-2 waves or when the active product bottleneck block changes.
- Class-of-issues fixes beat local symptom fixes.
- Use micro-steps only when the larger bounded wave is unsafe or evidence-incomplete.

## Active App Boundary
- The active learner-facing product is the Act0 shell route plus its direct support seams.
- Treat these as active app truth first:
  - `lib/ui_v2/act0_shell/*`
  - `docs/plan/MASTER_PLAN_v3.0.md`
  - `docs/plan/LAUNCH_SURFACE_MECHANISM_v1.md`
  - `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- Do not route new active-app work into dormant systems unless the user explicitly asks or a proven dependency seam requires it.
- Dormant / non-route families include, unless reopened by the task:
  - `lib/ui_v2/persona/*`
  - `lib/ui_v2/ai_coach/*`
  - `lib/personalization/*`
  - `lib/ui_v3/*`
  - legacy non-Act0 screen families under `lib/ui_v2/screens/*` that are not the current Act0 entry path

## Code
- Keep diffs proportional to the active block; do not force 1-2 file slices when the chosen bounded wave requires a larger but still controlled change set.
- Treat enums as append-only; avoid reordering or renaming existing entries.
- Maintain a single canonical guard site for `SpotKind`.

## Runtime Surface Canonical (Act0)
- Act0 preview shell is the current canonical runtime surface for boot/path entry.
- Canonical entry points must continue to route to `Act0ShellPreviewScreenV1`:
	- `lib/ui_v2/app_root.dart` (`_EntryGate.build`)
	- `lib/ui_v2/ui_v2_beta_shell.dart` (`buildCanonicalPathRootV1`)
- Do not switch canonical entry to `UiV2ProgressMapScreenV2` unless explicitly requested by the user in the active task.
- Legacy/alternative map surfaces may exist for secondary flows, but must not replace Act0 as default runtime entry.
- Treat `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart` as archived reference-only UI for now (ideas and donor patterns), not active default runtime surface.

## Curriculum Questions (Complete 36-World Vision)

When asked about:
- "What will the complete curriculum teach?"
- "Can a player do X after the full course?"
- "How does the 36-world architecture work?"
- "Which world covers concept Y?"

**Read MASTER_PLAN_v3.0 section "Content planning references" FIRST.**

Then use this priority order:
1. `docs/plan/LONG_HORIZON_MASTERY_MAP_v1.md` — long-term player growth and mastery strata
2. `docs/plan/VOLUME_STRUCTURE_AND_SPECIALIZATION_POLICY_v1.md` — Volume I/II/III structure and specialization rules
3. `docs/reference/LONG_TERM_WORLD_VISION_REFERENCE_v1.md` — W1–W36 full world definitions with competitive coverage
4. `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md` — 47 concept families mapped to worlds

**Do NOT:**
- Start with drill inventory (assets/packs/, assets/scenarios/) — that shows CURRENT production, not PLANNED architecture
- Use docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md as authority for W5+ — it is MVP-first skeleton only
- Assume SKILL_COVERAGE_MATRIX_v1.md is authority — it is marked "historical support only"

## Testing
Use the policy-gated loop by default:

```bash
./tools/fast_loop_world1_v1.sh
```

Before PR (default, full-suite OFF unless checkpoint policy enables it):

```bash
./tools/release_gate_world1.sh
```

Checkpoint run (every 3-4 PRs / before merge):

```bash
./tools/checkpoint_world1_v1.sh
```

If a command cannot run due to missing dependencies, note the issue in the PR description.
