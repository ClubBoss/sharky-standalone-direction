# Poker Analyzer Agent Instructions

## Scope
These instructions apply to the entire repository.

## Readiness SSOT
- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` is the canonical readiness authority for reporting, prioritization, and the meaning of final `100/100`.
- Future progress reporting should use its Core / Ship / Final layered model plus block and epic state movement rather than floating seam-only percentages.
- `docs/plan/TRUE_RELEASE_READINESS_SSOT_v1.md` is historical only and must not be used as the active readiness authority.
- Closed seams should not be reopened without concrete new evidence.

## Execution Mode
- `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md` is the active execution-mode and Route-to-B truth for the current publish-ready push.
- Prefer the largest safe bounded wave that closes one active bottleneck family.
- One active bottleneck block at a time; use one mission prompt per active block.
- Reassess after 1-2 waves or when the active readiness bottleneck block changes.
- Class-of-issues fixes beat local symptom fixes.
- Use micro-steps only when the larger bounded wave is unsafe or evidence-incomplete.

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
