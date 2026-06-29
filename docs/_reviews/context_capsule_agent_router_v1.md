# Context Capsule Agent Router v1

## Verdict

Verdict: `context_capsule_agent_router_created`

This wave created a lightweight first-read context capsule system for future Codex/Claude work. It is docs/context infrastructure only and does not change product behavior.

## Files Created / Updated

Created:

- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/context/HUMAN_QA_CAPSULE_v1.md`
- `docs/context/REPO_HYGIENE_CAPSULE_v1.md`
- `docs/_reviews/context_capsule_agent_router_v1.md`

Updated:

- `AGENTS.md` with a tiny pointer to `docs/context/CONTEXT_ROUTER_v1.md`.

## Why This Reduces Token Usage

- Future agents can start from one router and one current-state capsule instead of broad-reading W1-W6 history.
- Lane-specific instructions say what to read first, what to read only if needed, and what not to read.
- Ledger use is constrained to targeted grep unless score-policy work requires more.
- Output and screenshot folders remain opt-in evidence sources, not default context.
- Token budgets are explicit by task type, with `needs_scope_split` as the escape hatch.

## What This Does Not Change

- No product code changed.
- No content, fixtures, validators, runtime routes, UI, telemetry, monetization, or output artifacts changed.
- No readiness score changed.
- No W1-W6 freeze changed.
- No W7-W12 route status changed.
- No Human QA, launch, 9.0, or durable learner-proof claim was made.

## Lane Coverage

The router covers:

- `repo_hygiene`
- `durable_repair`
- `human_qa`
- `w1_w6_regression_only`
- `w7_w12_admission_planning`
- `market_competitor_review`
- `visual_regression_only`
- `emergency_bugfix`

## Validation

Required validation for this docs-only wave:

- `git status --short --branch`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- direct ASCII check on changed docs
- trailing whitespace / CRLF / final-newline checks

`flutter analyze` is not required unless product/source files change unexpectedly.

## Remaining Risks

- Capsules can become stale if future waves update scores or route truth without updating `CURRENT_STATE_CAPSULE_v1.md`.
- The router reduces broad-reading risk but does not replace active SSOT docs when a lane needs exact authority.
- Human QA and durable repair memory remain future gates.

## Next Recommended Product Wave

No immediate W1-W6 product wave. Preserve W1-W6 freeze. If participants are available, run Human QA. If not, the next admissible product layer is a bounded Concept Family Repair Memory v1 wave.
