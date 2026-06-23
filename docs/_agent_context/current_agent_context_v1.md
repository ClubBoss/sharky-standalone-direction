# Current Agent Context Pack v1

Date: 2026-06-23

Origin main: `1ec2a194b3b3e00f74b4d6c2a36707604d556ba7`
Status: advisory navigation and process context, not SSOT.

## Authority first

If this pack conflicts with current source, tests, user scope, or an active
SSOT, those sources win. Use this order:

1. `docs/plan/MASTER_PLAN_v3.0.md` for day-to-day product route and priority.
2. The active source-of-truth hierarchy in
   `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`.
3. Task-specific active SSOTs, including readiness, monetization, content, and
   top-1 strategy docs when the task requires them.
4. Repository instructions: `AGENTS.md`, `CLAUDE.md`, and
   `.github/copilot-instructions.md`.
5. Current source code and focused tests.
6. This context pack and review notes.

The requested `Current Execution Context`, `PROJECT_RULES_VFINAL.md`, and
workflow-protocol files were not found in this checkout. Do not invent their
paths. `docs/reference/history/Current Execution Context.md`, if encountered,
is historical only per the topology truth map.

## Current route and completed state

Sharky's product goal remains a top-tier poker trainer that makes deterministic
learning value visible: `user choice -> table signal -> clear why -> repair or
transfer`.

This user-scoped process lane is **Project Intelligence Layer v1** before any
larger product-route decision. It does not replace the Master Plan's product
priority.

- Act0 is the active learner-facing route.
- Modern Table is maintenance-only unless an explicitly scoped blocker opens it.
- Graphify setup and a repo-safe graph distillation are complete.
- The W6 range-bucket repair chain is complete through a deterministic launch
  descriptor.
- The Act0 session-drill queue consumer is documented unsafe; no visible
  Home, Review, or Practice behavior was changed.

## W6 repair-loop boundary

```
W6 range-bucket miss
  -> receipt adapter
  -> durable persisted receipt
  -> internal recheck candidate
  -> SessionDrillRecheckLaunchQueueItemV1
  -> STOP
```

The stop is intentional. Existing Act0 repair routing owns Act0
world/lesson/task identity, while session-drill items own session/drill
identity. The canonical session-drill route and surfaced runner accept a
session id but have no validated `initialDrillId` contract.

Do not fabricate an `Act0RepairIntentV1`, launch only the target session while
discarding target drill identity, or infer recovered proof. A future wave would
need both a validated target-drill route-to-runner contract and an explicit
user-initiated cross-family Act0 launch target.

## Current allowed work

- Agent Context Pack and related source-verified process documentation.
- Baseline Failure Ledger.
- Prompt Templates Library.
- Change-Type Matrix and Evidence Budget Rules.
- Obsidian skeleton only when explicitly requested.
- Narrow docs, process, and tooling work with no product behavior change.

## Current forbidden work

- Modern Table visual work or generic UI micro-polish.
- Product UI, route, telemetry, or repair-behavior changes without explicit
  scope.
- Monetization/paywall, AI/chat/persona, dashboards, XP, or economy work.
- Content expansion, glossary changes, and broad refactors.
- Generated screenshot, manifest, archive, or graph-output commits.

## Navigation hints

| Need | Start here | Guard |
| --- | --- | --- |
| Active app | `lib/ui_v2/act0_shell/`, `app_root.dart`, `ui_v2_beta_shell.dart` | Preserve `Act0ShellPreviewScreenV1` as canonical entry. |
| Act0 repair | preview shell, repair-intent contract, repair personalization tests | Act0 repair intents require task identity. |
| Session-drill W6 receipt chain | `session_drill_repair_receipt_adapter_v1.dart`, persistence, consumer, launch queue | Keep W6 range-bucket scope and preserve source/target identity. |
| Canonical session launch | `lib/ui_v2/runner/canonical_launcher_api_v1.dart` | Runner ownership under `archive/legacy_runners` is an open compatibility question, not a refactor instruction. |
| Graph navigation | `graphify query`, `path`, or `explain` when local graph data exists | Graphify is advisory; confirm in source and tests. |

## Validation defaults

- Docs-only: `graphify hook-check`, `flutter analyze`, `git diff --check`, and
  `git status --short`.
- Product or service seam: focused tests, analyzer, Graphify hook check, and
  diff/status checks; use the policy-gated loop when the changed-file policy
  requires it.
- Content: applicable content validators plus `dart run tools/term_coverage_scanner.dart`.
- UI: run screenshot/review evidence only when UI changes are in scope.
- Do not run `graphify update .` unless graph freshness is materially needed.
- Never commit `graphify-out/`, `output/graphify-out/`, or other generated
  review artifacts.

## Open questions

1. What validated cross-family target contract can represent both Act0 task
   repairs and session-drill rechecks?
2. Can canonical session-drill launch safely support `initialDrillId` without
   changing completion, telemetry, or progress semantics?
3. Which archive-located runner files remain canonical compatibility runtime
   dependencies versus truly dormant code?
4. What known baseline failures should be recorded in the future failure ledger?

## How to use this pack

Read this at the start of a Sharky task, verify named paths against the repo,
then read only the SSOT and source seams required by the task. Never use this
file to widen scope, select a product wave over the Master Plan, or override
current source/tests.

## Evidence consulted

- `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/_reviews/project_dependency_graph_distillation_v1.md`
- W6 receipt, consumer, persistence, and launch-queue review notes
- `docs/_reviews/act0_session_drill_recheck_queue_consumer_v1.md`
