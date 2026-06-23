# Prompt Templates Library v1

Date: 2026-06-23

Origin main: `12fe60ef7ecd2fad6642c07d840ee5da6f02f60e`

Status: advisory prompt templates, not SSOT.

## Usage rules

- Use a template as a starting point; active SSOT, user instructions, source,
  and tests always win.
- Fill in the current `origin/main`, branch, exact files, and acceptance facts
  before sending a task.
- Never widen scope because a template mentions an adjacent capability.
- Product-code work needs stronger evidence than docs-only work.
- A docs/process push gate may be followed by the next local docs task after a
  successful push. Keep product or high-risk code waves as separate gates.
- State generated-output policy explicitly in every template.

## 1. Docs/process local-only

```text
Goal: <name> — Local Only
Mode: docs/process only. Do not change app code, UI, routes, telemetry,
content, Modern Table, or generated outputs. Do not push.
Repo/branch/origin: <root>, <branch>, <commit>.
Read: <active SSOT + directly relevant review/context files>.
Allowed: <exact docs paths>. Forbidden: all other files.
Deliverable: <compact sections and evidence required>.
Validate: graphify hook-check; flutter analyze; git diff --check; git status.
Commit: <message>. Final: changed files, scope truth, checks, commit, next step.
```

Use for context packs, baseline ledgers, prompt libraries, change-type matrices,
and architecture-question notes.

## 2. Gated push plus next docs task

```text
Step A: validate and push <existing docs-only commit>.
Confirm origin diff contains only <files>; generated outputs remain untracked.
Run graphify hook-check, flutter analyze, diff check, and status. Push without
force. If rejected or dirty state is unsafe, stop.

Step B: only after Step A succeeds, create <next docs-only artifact> locally.
Do not push Step B. Re-state allowed files, validation, and commit message.
```

Do not use this combined flow for product behavior, route, telemetry, content,
or other high-risk code changes.

## 3. Product/service local-only implementation

```text
Goal: <bounded behavior> — Local Only
Scope: <one deterministic seam and exact allowed files>.
Do not: <UI/routes/telemetry/content/Modern Table/etc. exclusions>.
PIEC: inspect current source/test owners and active SSOT; state whether an
existing contract can safely support the change.
Implement: minimal deterministic behavior only; ignore malformed/unsupported
input safely; preserve existing ownership/progress semantics.
Validate: focused regression tests; relevant dependent contracts; analyzer;
graphify hook-check; format; diff/status. Commit/no push: <message>.
Final: behavior, non-changes, blast radius, checks, known baseline residue.
```

For a failing regression, establish the baseline before changing code.

## 4. Unsafe-seam documentation

```text
Goal: assess <seam> — Local Only
Do not force an implementation or broad refactor.
Inspect: current producer, consumer, route/runtime contract, and focused tests.
If unsafe: document the exact missing contract, rejected partial alternatives,
smallest prerequisite, and unchanged behavior. Commit the review note only.
If safe: stop and request/use a separate implementation scope when behavior
would cross product, route, or UI ownership.
```

Examples: cross-family targets, task-id versus session/drill identity, and
route parameters that do not yet reach the runtime owner.

## 5. Claude advisory review

```text
Role: advisory critique only. Read <SSOT/source/evidence>.
Assess: <visual, product, or architecture question>.
Return: concrete observations, evidence, risks, and questions; distinguish
source-verified facts from inference. Do not claim implementation is complete,
override SSOT, widen scope, or make product changes unless explicitly assigned.
```

Use for visual perception, architecture maps, product judgment, and focused
implementation suggestions—not roadmap ownership.

## 6. Graphify targeted query

```text
Question: <one seam relationship>.
If graph data exists: run 1-3 targeted `graphify query`, `path`, or `explain`
commands. Confirm conclusions in active source/tests/SSOT.
Run `graphify hook-check`; do not run a full refresh unless freshness is
material to the task. Never stage graphify-out or generated graph output.
```

Avoid broad natural-language queries that pull legacy, editor, analytics, or
framework noise into active-route decisions.

## 7. High-risk file change

Use this extra gate for Act0 shell state, lesson runner shell, ProgressService,
canonical/session runner, route contracts, telemetry, or localization hubs.

```text
Before edit: name owner, callers/dependents, invariants, and exact user-visible
or persisted behavior at risk. No opportunistic cleanup.
Required: explicit scope approval, focused owner + dependent tests, analyzer,
Graphify targeted dependency check, and a summary naming blast-radius checks.
If the seam crosses two owners, stop unless the task explicitly authorizes both.
```

## 8. New-chat handover request

```text
Summarize this Sharky checkout for the next task.
- Current origin/main and branch:
- Active route and authoritative SSOT:
- Completed work relevant to the next task:
- Current blocker or known baseline failure:
- Exact files/services/tests to attach or inspect:
- Allowed scope and forbidden scope:
- Smallest recommended next step and required validation:
Do not infer missing facts; mark them unknown.
```

## Template selection quick rule

| Need | Start with |
| --- | --- |
| Durable orientation or process aid | Docs/process local-only |
| Existing docs-only commit plus another docs task | Gated push plus next docs task |
| Bounded deterministic code seam | Product/service local-only |
| Missing prerequisite or unsafe ownership boundary | Unsafe-seam documentation |
| Architecture/visual judgment without implementation | Claude advisory review |
| Dependency discovery | Graphify targeted query |
| Central runtime/state/telemetry file | High-risk file change |

## Current reminders

- Act0 is the active learner route; preserve the canonical entry.
- Modern Table is protected maintenance scope.
- W6 repair provenance stops at the session-drill launch descriptor until a
  separate cross-family target and validated `initialDrillId` contract exists.
- The baseline ledger is not a skip list. Reproduce and report any new failure.
- Generated screenshots, manifests, archives, and graph outputs stay local.
