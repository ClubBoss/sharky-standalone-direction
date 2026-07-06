# Worktree Evidence Capsule v1

Status: ACTIVE worktree/evidence capsule.
Freshness date: 2026-07-07.
Verified product HEAD: `1d7a76215ac008eb3066c5030e514c5fa80029c7` (frozen Wave 4 HEAD on `origin/main`;
repository hygiene, dead-system decommission, and repository-truth
stabilization/integration are closed).
Verified active task: none active; parked at the frozen HEAD above.
Refresh trigger: every isolated worktree sequence, branch switch, commit, or
validation policy change.

## Current Worktree Pattern

Use isolated worktrees for bounded Sharky waves when the active checkout may
contain unrelated local state. The current integration runs in the canonical
standalone checkout because preflight proved it clean and non-diverged.

Current active worktree:

`/Users/elmarsalimzade/Sharky_1.0`

Current active branch:
`main`

## Current Integration Evidence

- Pre-integration `origin/main`:
  `17d3d3a68da72ba09fb9cee6e0a2166f4c3c00c1`.
- Source branch: `codex/stage-1b-wave-d-minimum-same-signal-repair-v1` at
  `e467090960d41e2f128655c417f56ff33fe19d70`.
- Ancestry: source is 15 commits ahead and zero behind `origin/main`; the
  integration used `git merge --ff-only` with no merge commit.
- Focused Stage 1B suite: `84/84` passed on source and integrated `main`.
- Checkpoint lint and `flutter analyze`: passed.
- Checkpoint selected tests: `+559 -164` on both integrated `main` and detached
  pre-integration `origin/main`; this is a baseline-identical stale-checkpoint
  limitation, not an observed Stage 1B regression. The checkpoint stopped
  before its full-suite phase.
- Final diff, graph, analyzer, clean-state, and push proofs are recorded in
  `docs/_reviews/stage_1b_integration_and_capsule_refresh_v1.md` and the
  post-push report.

## HEAD Freshness Rule

Use the current verified HEAD from preflight, not a permanent hardcoded hash.
Every implementation prompt should name expected HEAD and every final artifact
should report the committed result.

## Required Preflight

- `pwd`
- `git status --short --branch`
- `git rev-parse HEAD`
- `git log --oneline --decorate -n 10`
- `git diff --name-only`
- `git diff --cached --name-only`
- `graphify hook-check`

Stop on tracked dirty scope unless the prompt admits it. If the only tracked
dirty file is generated macOS registrant drift, inspect and restore only that
file before continuing.

## Generated Drift Rule

Flutter commands can regenerate:

- `macos/Flutter/GeneratedPluginRegistrant.swift`

Do not commit that drift unless the active prompt explicitly asks for plugin
registration changes.

## Output Rule

`output/**` is local evidence. Do not stage, delete, or commit it unless a
future prompt explicitly admits a specific output artifact.

## Checks By Wave Type

- Docs/workflow: `graphify hook-check`, `git diff --check`,
  `git diff --cached --check`, status.
- Product code: focused tests, `flutter analyze`, graphify hook, diff checks.
- UI: focused widget/guard tests plus screenshot evidence when making visual
  claims.
- Motion: motion evidence capture plus focused tests/guards.
- Telemetry: owner tests, privacy/claim-safety review, analyzer.
- Content: relevant content validators, copy/claim guards, analyzer if Dart.

## Stage / Commit / Push Rule

Do not stage, commit, or push unless the active task allows it. When allowed,
stage only admitted files. Do not push unless explicitly requested.

## Dirty-Scope Stop Rule

Stop with `blocked_by_dirty_scope` when tracked dirty files are outside the
admitted scope and are not generated drift.

## Evidence Artifact Naming

Use one compact review artifact under `docs/_reviews/` for committed proof.
Use `output/<task_slug>/` only for local screenshots, packets, and generated
evidence.
