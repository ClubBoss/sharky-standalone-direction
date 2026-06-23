# Change-Type Matrix and Evidence Budget v1

Date: 2026-06-23

Origin main: `e5c9bd0ab64e532dbfb32c41878460b5c150a259`

Status: advisory change-type and evidence guide, not SSOT.

## Core rules

- User scope, active SSOT, source ownership, and tests override this matrix.
- Do not widen a task because the matrix lists an adjacent change type.
- If evidence exposes an unsafe seam, document the missing contract and stop;
  do not force code or a broad refactor.
- Docs/process work may combine a gated push with the next local docs task.
  Product, route, UI, and telemetry work should use a separate push gate.
- Generated outputs are local evidence unless a task explicitly authorizes a
  tracked artifact.

## Change-type matrix

| Change type | Allowed scope | Forbidden by default | Required evidence | Optional evidence | Push rule | Stop condition |
| --- | --- | --- | --- | --- | --- | --- |
| Docs/process | Exact docs/process files | Product code, SSOT rewrite, generated output | Graphify hook check, analyzer, diff/status | Targeted source read | May chain to next docs task after push | Authority/path is unclear |
| Tooling/config | Narrow tool/config owner and tests | Product behavior, broad tooling platform | Syntax/config validation, focused tooling test, analyzer, diff/status | Graphify query | Separate gate if hooks/CI change | Requires new platform or workflow redesign |
| Graphify/navigation | Local query/path/explain and review docs | Graph output commit, graph as authority | Hook check; source/SSOT confirmation | 1-3 targeted queries | Docs-only rule | Graph stale or graph conflicts with source |
| Content/glossary | Authored sessions, scanner, validators | UI/route/telemetry changes | Content validator, term scanner, focused inventory/runtime test | Fast review if visible copy changes | Separate gate for authored content | Term safety or ownership fails |
| Service/engine | One deterministic service seam | UI/route/schema expansion | Focused new and dependent tests, analyzer, format, Graphify hook, diff/status | Term scanner when session content is involved | Separate gate | Input/target ownership crosses an unapproved seam |
| Route/launch contract | Explicit route, payload, runner owners | UI redesign, silent progress/telemetry changes | Entrypoint/dependent tests, invalid-input behavior, analyzer, Graphify query | Screenshot only if UI changes | Separate gate required | Parameter cannot reach runtime owner safely |
| Telemetry/schema | Existing owned event/payload seam | New vendor/schema or unrelated event changes | Schema/owner tests, producer/consumer checks, analyzer, diff/status | Release gate if policy requires | Separate gate required | No explicit field owner or backward compatibility proof |
| UI/visual/capture | Scoped surface and presentation tests | Route/logic changes without authorization | Focused widget tests, analyzer, diff/status | Deterministic screen review and Claude advisory critique | Separate gate required | UI needs unapproved product/route behavior |
| Modern Table | Explicit verified blocker only | Generic polish or donor refactor | Owner/dependent/guard tests, explicit blast-radius summary | Visual evidence if UI changes | Separate gate required | Act0-compatible ownership is not proven |
| Monetization/paywall | Explicit commercial wave and monetization SSOT | Early-pressure or entitlement inference | Entitlement/route tests, timing-policy review, analyzer | Product/commercial evidence | Separate gate required | Value/timing truth is incomplete |
| AI/persona/dashboard/XP/economy | Explicitly opened bounded wave only | Implicit scope expansion | Owner/dependent tests and SSOT review | Claude advisory architecture critique | Separate gate required | The work competes with active route or lacks ownership |
| Cleanup/refactor/archive removal | Proven unused, owner-approved scope | Opportunistic modernization or active compatibility removal | Dependents/import/guard tests, analyzer, diff/status | Graphify path/query | Separate gate if runtime files change | Graph/source shows active or uncertain dependency |

## Evidence budget rules

### Minimum checks

- `flutter analyze` plus `git diff --check` and `git status --short` are the
  universal local floor for tracked work.
- Docs-only work normally adds `graphify hook-check`; no product tests unless
  code was accidentally touched.
- Focused tests are required for every behavior, service, persistence, route,
  telemetry, or runtime change. Include the changed owner and its nearest
  dependent contract.
- Run content validators and `dart run tools/term_coverage_scanner.dart` when
  active session content, manifest, or learner-facing term safety changes.
- Run deterministic screen/review packets only when UI, visual hierarchy, or
  capture tooling changes. They are not a substitute for behavior tests.

### Navigation and review tools

- Use `graphify hook-check` by default. Use 1-3 targeted Graphify queries for
  risky seam discovery, then confirm the result in source and tests.
- Do not run `graphify update .` unless graph freshness materially changes the
  decision; never commit `graphify-out/`.
- Claude advisory review is useful for visual perception, UX/product critique,
  and architecture questions. It is not implementation truth and is usually
  unnecessary for routine docs-only or small deterministic service work.

## High-risk file policy

The following require explicit scope, owner/dependent inspection, targeted
tests, no opportunistic cleanup, and a final blast-radius statement:

- `act0_shell_state_v1` and `act0_lesson_runner_shell_v1`;
- `ProgressService` and persistence owners;
- canonical/session-drill runner and launch contracts;
- route and canonical-entry owners;
- telemetry schema/catalog owners;
- localization hubs;
- Modern Table and its compatibility boundaries.

If a proposed edit crosses two owners, stop unless the task explicitly opens
both. Summaries must name the owner tests and entrypoint/dependent checks run.

## Baseline failure handling

Use `baseline_failure_ledger_v1.md` as evidence, not a bypass. A baseline
classification requires the exact command, observed output, and clean-main
proof. New failures and failures in touched areas are suspicious by default.
When reporting a baseline, state whether it blocks the current wave; never
claim its full suite is green.

## Stop or continue gate

| Status | Meaning |
| --- | --- |
| Push | Scope, evidence, and dirty state are clean; use the appropriate gate. |
| Refine once | A direct scoped regression has one clear minimal correction. Re-run the same evidence budget. |
| Document unsafe | Required contract is missing; record exact blocker and prerequisite without code. |
| Defer | The work is valid but not current-route priority or lacks required evidence. |
| Block and ask | A decision, authority, or cross-owner scope is missing; do not assume it. |

## Current Sharky-specific stop examples

- W6 visible recheck continuation stops until an explicit cross-family
  Act0/session target and validated `initialDrillId` route-to-runner contract
  exist.
- Modern Table visual polish is forbidden without an explicit proven blocker.
- Raw Graphify output is local generated evidence and never committed.
- The lifecycle visible-copy failure is baseline only as recorded in the
  ledger; it is not green and must be revisited for affected/release-gate work.

## How to use this guide

Choose the narrowest applicable row, state the evidence budget before editing,
and stop when the row's stop condition is reached. This guide does not select
product priorities or authorize cross-scope changes.
