# Poker Analyzer Agent Instructions

## Quick Orientation

**State file first.** Read `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md` before
anything else while a campaign is active. It is the single first-read dispatch
authority: it carries canonical HEAD, umbrella stage, active packet, exact next
authorized packet, finding statuses, forbidden scope, and terminal conditions.
It is one screen.
Escalate to the documents below **only** when the task needs authority the state
file does not carry, or when its facts conflict with live source/tests - then
report the conflict. Do not read the full authority stack "for context".

For token-efficient reading recipes, evidence-run patterns, and per-packet model
routing, invoke the `sharky-context-economy` skill.

For project navigation and SSOT authority:
- `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md` is the principal
  day-to-day product-working authority after its merge.
- Use `docs/context/CONTEXT_ROUTER_v1.md` only as a navigation companion when
  the campaign state and v4 do not identify the needed task-specific source.
- Use `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` only for
  architecture/navigation context.
- For top-1 / 10/10 / Runout / competitive-product analysis, use
  `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` as a strategy/reference
  companion; it cannot override v4.
- `docs/plan/MASTER_PLAN_v3.0.md` is superseded/historical and must not select
  current work.

This file preserves critical project constraints and canonical entry points.

## Scope
These instructions apply to the entire repository.

## Canonical Root
- This repository is the standalone active product root.
- Canonical local root: this repository checkout.
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
- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` is the canonical launch/readiness authority for final release/store-prep framing and release-side reporting.
- Future launch/readiness reporting should use its Core / Ship / Final layered model plus block and epic state movement rather than floating seam-only percentages.
- It must not override `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md` for day-to-day product prioritization, evidence claims, or Gauntlet selection.
- `docs/plan/TRUE_RELEASE_READINESS_SSOT_v1.md` is historical only and must not be used as the active readiness authority.
- Closed seams should not be reopened without concrete new evidence.

## Top-1 Product Attack Map
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` is the strategy/reference companion for the top-1 / 10/10 commercial-product path.
- Use it when the task asks about:
  - top-1 app ambition;
  - 10/10 product standard;
  - Runout benchmark;
  - first-week commercial proof;
  - visible repair proof;
  - best-in-class learning effect;
  - premium/value packaging sequence.
- It does not override `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md` for day-to-day product priority or evidence class.
- It does not override monetization SSOT or active campaign truth.
- Review artifacts under `docs/_reviews/top1_*.md` are evidence logs, not new roadmap authority.

## Execution Mode
- `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md` is the principal
  execution-mode and product-route authority after merge.
- While `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md` is active, that state is
  the first-read current dispatch overlay; HNP remains the first execution
  Gauntlet until valid Human evidence changes the route.
- `docs/plan/MASTER_PLAN_v3.0.md`,
  `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md`, and
  `docs/plan/ROUTE_TO_B_ACTION_LADDER_v1.md` are historical/reference only.
- Use the v4 Gauntlet model: evidence before implementation, exactly one active
  bottleneck family, smallest sufficient intervention, and `DO_NOTHING` as a
  valid outcome.
- Reassess after a Gauntlet disposition or when real evidence changes the
  bottleneck family.
- Class-of-issues fixes beat local symptom fixes.
- Use micro-steps only when the larger bounded wave is unsafe or evidence-incomplete.

## Active App Boundary
- The active learner-facing product is the Act0 shell route plus its direct support seams.
- Treat these as active app truth first:
  - `lib/ui_v2/act0_shell/*`
  - `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md`
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

Use v4 first for active scope and evidence boundaries, then use this
curriculum-specific priority order:
1. `docs/plan/LONG_HORIZON_MASTERY_MAP_v1.md` - long-term player growth and mastery strata
2. `docs/plan/VOLUME_STRUCTURE_AND_SPECIALIZATION_POLICY_v1.md` - Volume I/II/III structure and specialization rules
3. `docs/reference/LONG_TERM_WORLD_VISION_REFERENCE_v1.md` - W1-W36 full world definitions with competitive coverage
4. `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md` - 47 concept families mapped to worlds

`MASTER_PLAN_v3.0.md` may be consulted only for historical curriculum traceability;
it cannot reopen content or select current work.

**Do NOT:**
- Start with drill inventory (assets/packs/, assets/scenarios/) - that shows CURRENT production, not PLANNED architecture
- Use docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md as authority for W5+ - it is MVP-first skeleton only
- Assume SKILL_COVERAGE_MATRIX_v1.md is authority - it is marked "historical support only"

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

## Agentic Capability Factory v1

Use one complete product capability as the default unit of work, not a chain of
unrelated micro-prompts. A bounded capability mission may include internal
gates, small coherent commits, tests, QA, evidence, and final publication.
Continue through bounded details without seeking approval after every minor
step. Stop only for an SSOT conflict, a genuine product decision, expansion
beyond the admitted stage, an unpreservable shared contract, or proof that the
goal is not safely achievable.

### Default Macro Workflow

1. Goal and explicit admission criteria.
2. SSOT and owner map.
3. Bounded vertical implementation.
4. Deterministic tests.
5. Computer-use black-box E2E QA when supported.
6. Independent fresh-context review when it is genuinely independent.
7. Real-text evidence and telemetry proof.
8. Bounded repair loop.
9. Admission decision.
10. Publish and freeze.

The required feedback engine is implementation -> deterministic tests ->
runtime/product evidence -> telemetry trace -> SSOT comparison -> bounded fix.
Repeat only inside the declared repair domain until the explicit gate passes.
Self-review is useful but never replaces tests, real-text screenshots, exact
runtime measurements, telemetry, route proof, or product-owner criteria.
Every mission declares success criteria, scope, maximum repair domain, terminal
verdicts, and stop conditions; no open-ended "improve until 10/10" loops.

### Computer-Use and Evidence

For user-facing capabilities, prefer a final black-box computer-use pass when
the environment supports it. Operate the actual app as a learner and check
entry, navigation, decisions, feedback, scrolling, CTA reachability, repair,
recheck, payoff, exit/resume, and obvious edge cases. It complements - not
replaces - deterministic tests. Prioritize compact, tall, and large phones;
tablet is optional unless the Master Plan explicitly activates it.

### Fresh Context, Threads, and Replay

Each major Codex thread begins with a compact capsule: repository root, branch
and HEAD, active goal/stage, accepted or frozen contracts, exact owners, known
debt, allowed/forbidden scope, required validation/evidence, terminal verdict,
and push policy. Use minimum sufficient context rather than replaying project
history.

Fresh threads may independently review code, telemetry, content/copy,
computer-use QA, evidence packaging, or final admission. Parallel work is only
for truly independent tasks. One thread owns one mutable layer at a time; do
not parallelize overlapping shared owners, state machines, layout allocation,
or adjacent unfrozen interfaces.

Record/replay of the stable canonical Alpha journey (Home/Learn -> theory ->
decision -> wrong feedback -> repair -> recheck -> payoff -> completion/exit)
is an operational-tooling candidate only when separately admitted. A future
skill must replay the real route, verify visible outcomes, avoid direct state
mutation, and be versioned to a route contract. Scheduled PR, debt, and
security automation remain deferred until repository or team activity justifies
them.

### Model and Documentation Efficiency

Use High reasoning only for SSOT, architecture, shared-owner redesign, major
vertical integration, and high-risk admission; Medium for bounded
implementation/owner tracing/focused repair; Low or Minimal for deterministic
packaging, formatting, simple tests, and publication.

Packet-class routing (a precise DoD is what makes a cheaper model safe - route
on decision content, never on packet size): **adjudication, contract verdicts,
severity, and admission** stay on the top model; **bounded owner repair with a
named owner** takes the mid model; **mechanical batch work** (file-by-file
disposition, formatting, lane wiring, publication) takes the cheapest model that
can follow the DoD. If a packet still needs a judgement call, it is not
mechanical - do not route it down. Avoid broad reads, repeated evidence
matrices before final gates, unnecessary tablet work, speculative refactors,
dependencies without direct EV, duplicate documents, tests-for-tests, and
reports that do not change a decision.

Update documentation only when it is SSOT, records an admission/decision,
prevents a known regression, enables the next agent, improves repeatable QA,
or reduces context waste. Local evidence stays under `output/` and is not
committed unless an existing repository rule explicitly requires it.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

When the user types `/graphify`, invoke the `skill` tool with `skill: "graphify"` before doing anything else.

**Verify the graph before relying on it.** Two independent failure modes have
both produced silently useless results here:

- **Freshness.** `graphify-out/graph.json` carries `built_at_commit`; compare it
  to HEAD. On 2026-07-25 it was **750 commits stale**. Run `graphify update .`
  when the task depends on graph truth, or skip the graph and say which reason
  applied.
- **Coverage.** Census `source_file` prefixes before trusting a result. Vendored
  trees are indexed too (a rebuild pulled in ~90K `ios/Pods` nodes, larger than
  `lib/`), and they surface for unrelated questions.

Stable limitations that a rebuild does **not** fix:

- **No string-literal or widget-key edges** - so "which test guards which
  contract/key" is not answerable from the graph. Grep directly.
- **Queries are keyword-based, not natural language** - phrase them as
  identifiers, not sentences.

Use it for what it is good at: `lib/` symbol ownership, consumers, and
relationships, where `graphify affected "<symbol>"` often beats a grep sweep.
The `sharky-context-economy` skill carries the verification snippets.

Rules:
- Graphify is navigation and dependency-safety tooling only. It is advisory and never overrides the active SSOT docs, roadmap, product scope, or user instructions.
- For `lib/` codebase questions, prefer `graphify query "<question>"`, `graphify affected "<symbol>"`, `graphify path "<A>" "<B>"`, or `graphify explain "<concept>"` when the graph is fresh. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates; dirty graph files are not a reason to skip graphify. Never commit generated graph output.
- Use `graphify hook-check` as the lightweight validation check. Run a full `graphify update .` only when explicitly needed for graph freshness or when a task requires it; do not run expensive graph generation every turn.
- Skip graphify when the graph is stale, when the task is about test/contract ownership or doc authority, when the task is about stale or incorrect graph output, or when the user says not to use it. Say which reason applied.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
