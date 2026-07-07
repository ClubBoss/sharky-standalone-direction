# Worktree Evidence Capsule v1

Status: ACTIVE worktree/evidence capsule.
Freshness date: 2026-07-07.
Verified product HEAD: `38c7de59303a93206b28829e899874124e270e07` (W1-W6
Repair Wave 5 telemetry/repair proof integration HEAD on `main`; repository
hygiene, dead-system decommission, and repository-truth stabilization/
integration are closed).
Verified active task: W1-W6 Repair Wave 5 telemetry/repair proof and runtime
integrity gate are integrated; Global Baseline Debt recovery is not started.
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

- Wave 4 base HEAD: `1105620f91cc183bda90bead10a539f5e8a5b6b6`.
- Wave 4 source integration HEAD:
  `970a1276cb4dcd2092ba7bd98b0076958a0f51f6`.
- Runtime integrity gate integration HEAD:
  `c7ac518401a3851fcb9a07a1348e1497710d5cfc`.
- Wave 5 telemetry/repair proof integration HEAD:
  `38c7de59303a93206b28829e899874124e270e07`.
- Structured context commit: `058ccec9` passed focused W5 parser/source/render
  validation.
- Compact actionability commit: `4af55086` passed W4 compact portrait and
  safe-area actionability validation.
- Closure commit: `970a1276` recorded the Wave 4 closure artifact and pre-
  integration capsule state.
- Focused identity, Tier0 admission, feedback completeness, terminology, W3/W5
  manifest/index parity, `fast_loop_world1_v1.sh`, `release_gate_world1.sh`,
  standalone `flutter analyze`, diff checks, and `graphify hook-check` passed.
- `checkpoint_world1_v1.sh` reached full-suite after checkpoint Tier0/release
  sections passed; full-suite surfaced known unrelated global debt and was
  stopped after repeated non-Wave-4 failures.
- Final closure proof is recorded in
  `docs/_reviews/w1_w6_repair_wave4_structured_context_actionability_v1.md`.
- Runtime integrity closure proof is recorded in
  `docs/_reviews/w1_w6_runtime_bundle_build_integrity_v1.md`.
- Wave 5 closure proof is recorded in
  `docs/_reviews/w1_w6_repair_wave5_telemetry_repair_proof_v1.md`.

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
