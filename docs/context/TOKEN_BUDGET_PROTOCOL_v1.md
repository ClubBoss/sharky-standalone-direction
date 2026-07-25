---
status: "ACTIVE token discipline protocol for Sharky agents"
status_source: "derived"
generated_by: "docs_frontmatter_v1"
---

# Token Budget Protocol v1

Status: ACTIVE token discipline protocol for Sharky agents.

## Core Rule

Do not preserve quality by reading everything.

Preserve quality by reading the right current capsule, exact touched files, and required validators.

If more context is needed, explain why and split the task.

Read one route capsule plus one lane capsule, not all capsules. Direct source,
tests, runtime truth, and active task evidence override capsule summaries.
Implementation prompts should name capsule freshness: date, verified HEAD, and
active route artifact.

## Budget Targets

- Repo hygiene / sync checkpoint: 5k-15k tokens.
- Claude compact text audit: 2k-6k tokens.
- Codex focused decision or docs audit: 10k-40k tokens.
- Codex implementation wave: 30k-80k tokens unless inherently larger.
- Emergency bugfix: 10k-40k tokens.
- Visual regression audit: 5k-20k tokens.
- Broad architecture or route rebaseline: split unless explicitly admitted.

## First-Read Protocol

1. Read `AGENTS.md`.
2. Read `docs/context/CONTEXT_ROUTER_v1.md`.
3. Read `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`.
4. Pick exactly one lane.
5. Read exactly one relevant lane capsule.
6. Search before reading touched files.

Tiny single-file or single-command tasks may skip capsules when route context
cannot affect the answer.

## Broad-Read Prohibition

- Do not broad-read repo history to feel safe.
- Do not open old W1-W6 review artifacts unless verifying one exact fact.
- Do not scan screenshots or `output/` folders unless the lane requires visual evidence.
- Visual tasks may read screenshot artifacts only when visual evidence is needed.
- Do not read W7-W12 files unless the lane is W7-W12 admission planning or a bug report names them.
- Do not read archive docs unless the user explicitly asks for historical retrieval.
- Do not paste whole historical artifacts into new artifacts; link or name the
  source instead.

## Search-Before-Read Rule

- Use `rg` before opening files.
- Search for exact identifiers: route id, world id, fixture name, validator name, field name, failing assertion, or claim phrase.
- Open the smallest useful slice with `sed -n`.
- Prefer focused files over aggregate ledgers.

## Ledger Grep-Only Rule

- Read ledgers by targeted `rg` first.
- Open the full ledger only when the task is ledger editing or score-policy work.
- For active route truth, prefer `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`.
- For top-1 current route, grep the latest active section before reading the whole plan.

## Artifact Size Guidelines

- Repo hygiene artifact: max 80 lines unless conflicts require more.
- Decision artifact: 80-180 lines.
- Implementation review artifact: 120-260 lines.
- Capsule file: follow its own target.
- Avoid copying old artifacts or ledgers into new artifacts.
- Use pointers to source-of-truth docs instead of restating history.

## Stop And Split

Return `needs_scope_split` when:

- Required context would exceed the lane budget by more than 50%.
- The task tries to combine W1-W6 repair, W7-W12 opening, UI redesign, monetization, and Human QA.
- Evidence conflicts between current capsules and active SSOT docs.
- A product change requires both source authoring and route/runtime changes in one wave.
- Validation would need broad tests plus screenshots plus Human QA.

The split response must say:

- exact blocker;
- smallest safe next wave;
- files already checked;
- files intentionally not read.

## Focused Vs Full Validation

Run focused validation when:

- docs-only changes affect one artifact family;
- a single validator/test covers the touched seam;
- repo hygiene is the task;
- no product/source files changed.

Run full or broader validation only when:

- route/runtime code changed;
- shared content factory/validator changed;
- a regression could affect many worlds;
- release/readiness gate explicitly requires it.

If product/source files changed unexpectedly, run `flutter analyze` and explain why.

## Final Summary Limits

- Keep final summaries under 50-70 lines.
- Lead with identity, files changed, verdict, validation, and route/score impact.
- Do not paste long command logs.
- Mention skipped validations explicitly.
- Mention forbidden scope proof for bounded waves.

## Claude Compact Audit Mode

- Use when the prompt asks for external-style text review or strategic critique.
- Read current capsule, lane capsule, and exact artifact under review.
- Produce findings first.
- Avoid repo recon unless a claim cannot be assessed from provided evidence.
- Target 2k-6k tokens.

## Codex Focused Implementation Mode

- Use when the prompt admits file edits.
- Read current capsule, lane capsule, touched files, and focused tests/validators.
- Implement the smallest durable change.
- Validate with exact commands from the lane.
- Commit or push only when the prompt asks or the branch contract requires it.
- Target 30k-80k tokens unless the work is inherently larger.

## Rolling Capsule Advance

For every accepted product PR, capsule metadata is part of Definition of Done:

1. Update `ACTIVE_ROUTE_CAPSULE_v1.md` in the product commit with the accepted
   product HEAD, the closed task, and the next active task.
2. Update exactly the relevant lane capsule when durable facts changed.
3. Do not update unrelated capsules.

Use a separate capsule-refresh PR only when the phase changes materially,
authority documents conflict, multiple capsules need structural rewriting, or
the prior agent cannot safely identify the next route.

This is completion metadata, not a new product layer. Capsules remain compact
summaries and never outrank SSOT, active evidence, or live source and runtime
truth. A missing metadata update does not justify changing product direction.
The next agent must still stop with `stale_capsule_scope` when a capsule names
an active phase or task that conflicts with the accepted route.
