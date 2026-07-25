---
status: "context_capsules_refreshed_and_ready"
status_source: "derived"
baseline: "f9a1909f70ae"
generated_by: "docs_frontmatter_v1"
---

# Context Capsule Bounded Refresh v1

## 1. Verdict

`context_capsules_refreshed_and_ready`

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `f9a1909f70ae3ad51ac731e3782c34c861d627f5`
- Dirty scope: no tracked or staged files at preflight; only local untracked `output/**`.
- `graphify hook-check`: passed.

## 3. Previous Capsule State

The repo already had a useful capsule workflow: router, current-state capsule,
durable repair capsule, Human QA capsule, repo hygiene capsule, token protocol,
and prompt templates. The stale part was active route truth: the old current
capsule still pointed at older W1-W12 and W7-W12 assumptions and did not encode
the pre-Human TOP1 completion route.

## 4. New Capsule Architecture

Active architecture now uses four current capsules:

1. `ACTIVE_ROUTE_CAPSULE_v1.md`
2. `VISUAL_PROOF_CAPSULE_v1.md`
3. `LEARNING_REPAIR_CAPSULE_v1.md`
4. `WORKTREE_EVIDENCE_CAPSULE_v1.md`

Kept as supporting active workflow:

- `REPO_HYGIENE_CAPSULE_v1.md`
- `HUMAN_QA_CAPSULE_v1.md`
- `TOKEN_BUDGET_PROTOCOL_v1.md`
- prompt templates library

## 5. Router Changes

`docs/context/CONTEXT_ROUTER_v1.md` now routes by the four-capsule model,
names agent mappings for Codex, Sonnet, and Fable/Claude Design, defines the
default read order, adds freshness/conflict rules, and introduces the
`stale_capsule_scope` stop condition.

## 6. Active Route Capsule

`docs/context/ACTIVE_ROUTE_CAPSULE_v1.md` now owns compact route truth:

- pre-Human TOP1 completion route
- immediate next task: `Session Summary Gold Containment PR`
- concise recently closed gates
- next 2-3 steps only
- full phase map in compact form
- forbidden scope and Human QA boundary

## 7. Visual/Proof Capsule

`docs/context/VISUAL_PROOF_CAPSULE_v1.md` captures accepted visual tokens,
frozen surfaces, current visual task, remaining visual route, proof/progression
rules, screenshot lanes, local-only output rule, and visual evidence standards.

## 8. Learning/Repair Capsule

`docs/context/LEARNING_REPAIR_CAPSULE_v1.md` carries forward the useful durable
repair workflow into the broader learning loop: deterministic repair, visible
reason, repair outcome, Session Summary receipt, Review/Profile proof, local
telemetry truth, claim limits, and future learning phases.

## 9. Worktree/Evidence Capsule

`docs/context/WORKTREE_EVIDENCE_CAPSULE_v1.md` records the isolated worktree
pattern, branch, HEAD freshness rule, preflight, generated macOS registrant
drift rule, `output/**` local-only rule, checks by wave type, and stage/commit
boundaries.

## 10. Human QA Capsule Handling

`docs/context/HUMAN_QA_CAPSULE_v1.md` remains active for human-specific protocol
and claim safety. It now points to the active route capsule for route truth and
states Human QA is the final external gate after static, motion, E2E, final
audit, and regression closeout.

## 11. Token Budget Integration

`docs/context/TOKEN_BUDGET_PROTOCOL_v1.md` now explicitly says to read one
route capsule plus one lane capsule, not all capsules. It also names source/test
override, capsule freshness requirements, tiny-task capsule skips, screenshot
artifact limits, and no historical artifact pasting.

## 12. Prompt Integration

`docs/_agent_context/prompt_templates_library_v1.md` now includes a compact
capsule header template with freshness hash/date, conflict rule,
`stale_capsule_scope`, and no broad-read rule.

## 13. Stale-Content Checks

Targeted stale searches checked for:

- old current-state HEAD marker
- stale W7-W12 closed/locked route wording
- old route-wave routing assumptions
- active-truth duplication in `CURRENT_STATE_CAPSULE_v1.md`
- active-truth duplication in `DURABLE_REPAIR_CAPSULE_v1.md`

Remaining hits are expected pointer headings or generic "old wave history"
navigation language, not stale route truth.

## 14. Validation

Required validation:

- `graphify hook-check`: passed.
- `git diff --check`: passed.
- `git diff --cached --check`: passed.
- targeted stale wording searches: passed with expected pointer-only hits.
- line budgets: active route 81, visual/proof 101, learning/repair 121,
  worktree/evidence 80.

No product tests were run because this PR changes docs/workflow only.

## 15. Scope Safety

No product code, tests, routes, screenshot tooling, product sequence, closed
product work, or `output/**` artifacts were modified. No push was performed.

## 16. Next Recommendation

`Session Summary Gold Containment PR`
