# Proof Progression Capsule Advance + Workflow Fix v1

## 1. Verdict

`proof_progression_capsules_advanced_workflow_fixed`

## 2. Preflight

- Worktree and branch matched the prompt.
- Starting product HEAD was `99783a3da9fce8a5f9f067be8b8503aa68de3098`.
- No tracked or staged changes existed; only untracked `output/**` was present.
- Initial `graphify hook-check` passed.

## 3. Stale facts found

The route, visual, learning/repair, and worktree/evidence capsules still named
the pre-Profile product state at `2472b68c`. The route and worktree capsules
also still named Cross-Session Proof Profile as active.

## 4. Capsules updated

- `ACTIVE_ROUTE_CAPSULE_v1.md`
- `VISUAL_PROOF_CAPSULE_v1.md`
- `LEARNING_REPAIR_CAPSULE_v1.md`
- `WORKTREE_EVIDENCE_CAPSULE_v1.md`

`CONTEXT_ROUTER_v1.md` was audited and remained accurate, so it was not edited.

## 5. New active task

`Achievement Visual Language / Icons v1`

Cross-Session Proof Profile is closed. The remaining Phase 4 sequence is W1
Completion Payoff, W2-W6 Completion Payoff, then the W4->W5 Band Transition
Milestone.

## 6. Rolling Capsule Advance rule

Every accepted product PR now advances the active route capsule to the accepted
product HEAD, closed task, and next active task, and updates exactly one relevant
lane capsule when durable facts changed. Those updates stay in the product
commit; unrelated capsules do not move.

A separate refresh is reserved for material phase changes, authority conflicts,
structural multi-capsule rewrites, or cases where the next route is unsafe to
identify.

## 7. Workflow/template changes

`TOKEN_BUDGET_PROTOCOL_v1.md` now owns the rolling rule and classifies capsule
metadata as Definition-of-Done completion metadata. The advisory prompt library
now requires route-critical capsule advancement before commit when the route is
unambiguous.

## 8. Guardrail preservation

Capsules remain summaries below SSOT, active evidence, and live source/runtime
truth. Missing metadata cannot redirect product work. Conflicting phase/task
metadata still requires `stale_capsule_scope`. Deferred scope, the W13+ block,
Human QA last, and the prohibition on generic visual polish remain intact.

## 9. Context-efficiency impact

Future agents receive accepted route closure and the next task in the same
product commit, reducing corrective metadata waves without requiring broad
reads or unrelated capsule churn.

## 10. Validation

Targeted route-fact checks passed: no route-critical capsule names Cross-Session
Proof Profile as active; Achievement Visual Language is active; product HEAD,
phase closure, W13+ blocking, workflow rule, and template requirement are
present. `graphify hook-check`, `git diff --check`, and the pre-stage
`git diff --cached --check` passed. No Flutter tests were required for this
docs/workflow-only change.

## 11. Scope safety

Only stale context capsules, the capsule workflow protocol, the advisory prompt
template, and this review artifact changed. Product code, tests, UI, routes,
roadmap authority, generated graph files, and `output/**` remain untouched.

## 12. Next recommendation

`Achievement Visual Language / Icons v1`
