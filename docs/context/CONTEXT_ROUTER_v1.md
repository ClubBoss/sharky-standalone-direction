# Context Router v1

Status: ACTIVE first-read router for Sharky Codex, Sonnet, and Fable work.

Purpose: route agents to the smallest current capsule set. Do not broad-read
repo history to feel safe.

## Authority And Conflict Rule

Capsules summarize and route context only. They never outrank:

1. `docs/plan/MASTER_PLAN_v3.0.md`
2. Current Execution Context, when supplied by the task
3. Project Rules / repo instructions, including `AGENTS.md`
4. Workflow Protocol / active prompt contract
5. active task evidence
6. live source, tests, and runtime truth

If a capsule conflicts with a higher authority, use the higher authority and
report the conflict. Do not silently reconcile stale capsule truth.

## Default Read Order

1. `AGENTS.md`
2. `docs/context/CONTEXT_ROUTER_v1.md`
3. `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`
4. exactly one relevant lane capsule
5. task-specific SSOT sections
6. owner files / active evidence found by search

Tiny single-file or single-command tasks may skip capsules when route context
cannot affect the answer.

## Active Capsule Architecture

| Capsule | Use for | Agents |
| --- | --- | --- |
| `ACTIVE_ROUTE_CAPSULE_v1.md` | current pre-Human TOP1 route, immediate task, next 2-3 steps, forbidden scope | all |
| `VISUAL_PROOF_CAPSULE_v1.md` | visual system, proof/progression display, screenshot lanes, design acceptance | Fable, Sonnet, Codex |
| `LEARNING_REPAIR_CAPSULE_v1.md` | learning loop, repair contracts, proof claims, telemetry ownership | Codex, Sonnet |
| `WORKTREE_EVIDENCE_CAPSULE_v1.md` | branch/HEAD checks, output rules, validation, generated drift | Codex |
| `REPO_HYGIENE_CAPSULE_v1.md` | mainline sync, branch hygiene, checkpoint tasks | Codex |
| `HUMAN_QA_CAPSULE_v1.md` | human evidence protocol and claim safety | Codex, Sonnet |

`TOKEN_BUDGET_PROTOCOL_v1.md` remains the workflow budget rule. The prompt
templates library remains supporting reference only.

## Agent Mapping

- Codex: read route capsule + one lane capsule + worktree/evidence capsule.
- Sonnet: read route capsule + relevant lane capsule.
- Fable / Claude Design: read route capsule + visual/proof capsule.

Do not ask any agent to read all capsules by default.

## Task To Capsule Mapping

| Task shape | Required capsule |
| --- | --- |
| route choice, next wave, scope boundary | `ACTIVE_ROUTE_CAPSULE_v1.md` |
| Proof Progression, Cross-Session Proof Profile, achievement/payoff proof | `ACTIVE_ROUTE_CAPSULE_v1.md` + `VISUAL_PROOF_CAPSULE_v1.md`; add `LEARNING_REPAIR_CAPSULE_v1.md` only when proof source contracts are relevant |
| UI polish, visual audit, design packet, screenshot review | `VISUAL_PROOF_CAPSULE_v1.md` |
| Session Summary proof, Review repair, Practice repair, learning claims | `LEARNING_REPAIR_CAPSULE_v1.md` |
| commit, preflight, validation, generated drift, output handling | `WORKTREE_EVIDENCE_CAPSULE_v1.md` |
| mainline merge, push, repo integration checkpoint | `REPO_HYGIENE_CAPSULE_v1.md` |
| novice evidence, launch/9.0/learning-effect claims | `HUMAN_QA_CAPSULE_v1.md` |
| content/correctness wave | route capsule + exact content SSOT/owner files |
| motion wave | visual/proof capsule + exact motion owner/evidence files |
| telemetry wave | learning/repair capsule + exact telemetry owner files |

## Freshness Rule

Every implementation prompt should name capsule freshness: date, verified HEAD,
and active route artifact. A capsule is stale when its verified HEAD, route
artifact, or immediate task is older than the active prompt evidence.

Stop with `stale_capsule_scope` when route-critical facts are stale and the
task depends on them. For narrow implementation tasks, continue from live source
and note the stale capsule as a non-blocking context risk.

## Search Before Reading

Use `rg` before opening files. Search for exact route ids, widget keys,
validator names, fixture ids, copy strings, field names, or artifact titles.
Open the smallest useful file slice. Prefer exact owner files over broad
ledgers or historical review chains.

## Do Not Read By Default

- `output/**`, unless visual evidence is the task
- archive docs, unless historical retrieval is requested
- old wave histories, unless one exact fact must be verified
- W13-W36, unless the prompt explicitly opens that scope
- Modern Table files, unless a concrete dependency is proven
- all capsules, all ledgers, or all reviews

## Validation Routing

- Docs/workflow: graphify hook, diff checks, status.
- Product code: focused tests, analyzer, graphify hook, diff checks.
- UI: focused tests plus screenshot evidence when making visual claims.
- Motion: motion evidence, screenshot/video packet, focused checks.
- Content: content validators and claim-safety checks.
- Telemetry: owner tests plus claim-safety review.

If required context exceeds the lane budget, stop with `needs_scope_split` and
name the exact missing evidence or authority.
