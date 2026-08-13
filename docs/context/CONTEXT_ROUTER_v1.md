# Context Router v1

Status: ACTIVE NAVIGATION COMPANION ONLY.

Purpose: route agents to the smallest task-specific source set. It does not own
product direction, next-wave selection, evidence admission, or closure.

While `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md` is active, that one-screen
state is the first-read dispatch overlay. `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md`
is the principal day-to-day product-working authority after merge.

## Authority And Conflict Rule

This router and all capsules summarize/navigation context only. They never
outrank:

1. repository `AGENTS.md`;
2. active campaign state, while one exists, for exact current dispatch;
3. `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md` for product route,
   North Star, evidence hierarchy, protected boundaries, and Gauntlet order;
4. task-specific independent protocol/SSOT for its owned procedure/contract;
5. active task evidence and live source/tests/runtime truth within their valid
   claim boundary.

`docs/plan/MASTER_PLAN_v3.0.md` is superseded/historical and cannot select
current work. `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md` is a stale/superseded
route snapshot and future archive candidate.

If a navigation companion conflicts with higher authority, use the higher
authority and report the conflict. Do not silently reconcile stale capsule
truth.

## Derived Metadata Boundary

Derived frontmatter, `status_source: derived`, and generated docs indexes are
routing hints only. They do not establish authority, closure, severity,
supersession, packet order, packet authorization, or product truth. Document
body, explicit owner declarations, repository hierarchy, live source/tests,
and exact task evidence remain authoritative.

## Default Read Order

When an active campaign state exists:

1. repository `AGENTS.md` / automatically loaded repo instructions
2. active campaign state file
3. `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md`
4. exactly one task-specific protocol/SSOT when required
5. this router only if source discovery is still needed

When no campaign state applies:

1. `AGENTS.md`
2. `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md`
3. exactly one task-specific protocol/SSOT when required
4. this router only if source discovery is still needed

Tiny single-file or single-command tasks may skip navigation companions when
route context cannot affect the answer.

## Capsule Architecture

| Capsule | Use for | Agents |
| --- | --- | --- |
| `ACTIVE_ROUTE_CAPSULE_v1.md` | historical route trace only; never next-work authority | all |
| `VISUAL_PROOF_CAPSULE_v1.md` | visual system, proof/progression display, screenshot lanes, design acceptance | Fable, Sonnet, Codex |
| `LEARNING_REPAIR_CAPSULE_v1.md` | learning loop, repair contracts, proof claims, telemetry ownership | Codex, Sonnet |
| `WORKTREE_EVIDENCE_CAPSULE_v1.md` | branch/HEAD checks, output rules, validation, generated drift | Codex |
| `REPO_HYGIENE_CAPSULE_v1.md` | mainline sync, branch hygiene, checkpoint tasks | Codex |
| `HUMAN_QA_CAPSULE_v1.md` | human evidence support context; HNP procedure is owned by the HNP protocol | Codex, Sonnet |

`TOKEN_BUDGET_PROTOCOL_v1.md` remains the workflow budget rule. The prompt
templates library remains supporting reference only.

## Agent Mapping

- Codex: use v4 + one task-specific owner; add one lane capsule only when it
  materially reduces owner tracing.
- Sonnet: use v4 + relevant task-specific source; add a lane capsule only when
  needed.
- Fable / Claude Design: use v4 + visual/proof capsule only when a visual task is
  explicitly admitted.

Do not ask any agent to read all capsules by default.

## Task To Source Mapping

| Task shape | Required source |
| --- | --- |
| route choice, next Gauntlet, scope boundary | `MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md`; active campaign state first while active |
| Human Novice Proof | `docs/_reviews/human_novice_proof_protocol_v1.md` |
| transfer/retention | `docs/plan/DURABLE_RETENTION_TRANSFER_CONTRACT_v1.md` |
| telemetry | `docs/plan/ACT0_TELEMETRY_TRUTH_MAP_v1.md` + exact source owner |
| UI/visual evidence after explicit admission | `VISUAL_PROOF_CAPSULE_v1.md` + exact visual owner |
| Session Summary / Review / repair claims | `LEARNING_REPAIR_CAPSULE_v1.md` + exact owner |
| commit, preflight, validation, generated drift | `WORKTREE_EVIDENCE_CAPSULE_v1.md` |
| mainline merge, push, repo integration checkpoint | `REPO_HYGIENE_CAPSULE_v1.md` |
| content/correctness | exact content SSOT/owner files under v4 scope |
| monetization | `docs/plan/MONETIZATION_SSOT_v1.md` |
| release/readiness | `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` |

## Freshness Rule

Every implementation prompt should name verified HEAD and the active claim/gate.
A capsule is stale when its verified HEAD, route artifact, or immediate task is
older than the active campaign/v4/task evidence.

For narrow tasks, continue from higher authority plus live source and note stale
capsule text as non-blocking context. Never promote a stale capsule to route
authority merely because it is easier to read.

## Search Before Reading

Use `rg` before opening files. Search for exact route ids, widget keys,
validator names, fixture ids, copy strings, field names, or artifact titles.
Open the smallest useful file slice. Prefer exact owner files over broad
ledgers or historical review chains.

## Do Not Read By Default

- `output/**`, unless evidence is the task
- archive docs, unless historical retrieval is requested
- old wave histories, unless one exact fact must be verified
- W13-W36, unless v4 and evidence explicitly open that scope
- Modern Table files, unless a concrete dependency/regression is proven
- all capsules, all ledgers, or all reviews

## Validation Routing

- Docs/workflow: path/reference checks, diff-scope checks, markdown integrity,
  and graphify hook when locally available and useful.
- Product code: focused tests, analyzer, graphify hook, diff checks.
- UI: focused tests plus screenshot/native evidence only when the admitted
  claim requires it.
- Motion: motion evidence, screenshot/video packet, focused checks.
- Content: content validators and claim-safety checks.
- Telemetry: owner tests plus claim-safety review.

If required context exceeds the lane budget, split the task around the exact
missing evidence/owner instead of broad-reading repository history.
