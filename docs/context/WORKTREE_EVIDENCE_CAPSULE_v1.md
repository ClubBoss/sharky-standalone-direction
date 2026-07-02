# Worktree Evidence Capsule v1

Status: ACTIVE worktree/evidence capsule.
Freshness date: 2026-07-02.
Verified HEAD: `f9a1909f70ae3ad51ac731e3782c34c861d627f5`.
Refresh trigger: every isolated worktree sequence, branch switch, commit, or
validation policy change.

## Current Worktree Pattern

Use isolated worktrees for bounded Sharky waves when the active checkout may
contain unrelated local state.

Current active worktree:

`/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`

Current active branch:
`codex/apply-owner-patch-sequence-a-b-c-d-v1`

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
