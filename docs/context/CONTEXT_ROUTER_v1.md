# Context Router v1

Status: ACTIVE first-read router for future Sharky Codex/Claude work.

Use this before broad-reading docs. Pick one lane. Read the capsule for that lane, exact touched files, and required validators. Do not preserve quality by reading everything.

## Global Rules
- Always start with `AGENTS.md` and `docs/context/CURRENT_STATE_CAPSULE_v1.md`.
- Search before reading: use `rg` to locate exact claims, files, validators, and seams.
- Prefer capsules and latest checkpoint artifacts over old wave history.
- Read ledgers with targeted grep unless the lane explicitly requires a table row.
- Do not inspect screenshots or `output/` folders unless the lane is visual regression.
- Do not open W7-W12 unless the lane is W7-W12 admission planning.
- If broader context would exceed the lane budget, stop with `needs_scope_split` and name the exact reason.

## Lane: repo_hygiene
Read first:
- `docs/context/REPO_HYGIENE_CAPSULE_v1.md`
- `docs/_reviews/repo_integration_mainline_sync_checkpoint_v1.md`

Read only if needed:
- `AGENTS.md` remote/root rules

Do not read:
- W1-W6 review history
- content fixtures
- product runtime files
- screenshots or `output/` contents

Allowed actions:
- inspect git status/log/branch/remote
- create compact checkpoint artifact
- merge or fast-forward only when clean and explicit
- push only by normal non-force push when checks pass

Forbidden actions:
- product edits
- output staging
- force push
- conflict resolution without reporting

Validation expectation:
- `git status --short --branch`; `git log --oneline --decorate -n 20`; `git diff --check`; `git diff --cached --check`; `graphify hook-check`.

Token budget target: 5k-15k.

## Lane: durable_repair
Read first:
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`

Read only if needed:
- exact files found by `rg "repair_focus_id|user_choice|error_type|time_to_decision|session summary|mistake tracking"`
- targeted `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` hits around repair proof
- relevant existing tests for touched seams

Do not read:
- old W1-W6 certification artifacts
- W7-W12 content
- screenshot folders

Allowed actions:
- plan or implement deterministic repair-memory slices if explicitly admitted
- add focused tests/validators for repair memory
- document claim limits

Forbidden actions:
- ML/AI chat/persona
- solver/GTO claims
- W1-W6 content rework
- W7-W12 opening
- UI redesign

Validation expectation:
- focused unit/guard tests for touched repair seams; `flutter analyze` if Dart changes; `graphify hook-check`; diff/ASCII/whitespace checks.

Token budget target: decision 10k-25k; implementation 30k-80k.

## Lane: human_qa
Read first:
- `docs/context/HUMAN_QA_CAPSULE_v1.md`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`

Read only if needed:
- W1 Human QA protocol artifact
- exact W1-W6 fixture/test evidence referenced by the QA plan
- current ledger rows for W1-W6 using targeted grep

Do not read:
- W7-W12 route files
- product UI unless the QA protocol executes against it
- old certification history beyond exact evidence references

Allowed actions:
- design or execute honest Human QA protocol when participants exist
- collect confusion, time-to-decision, and error-type evidence
- update readiness only from real evidence

Forbidden actions:
- fake Human QA
- synthetic participant claims
- 9.0 or launch claims before real evidence

Validation expectation:
- evidence log integrity; participant/session traceability; claim-safety review; docs diff checks.

Token budget target: planning 8k-20k; execution synthesis 20k-50k.

## Lane: w1_w6_regression_only
Read first:
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- latest failing test, validator, or bug report

Read only if needed:
- exact source/fixture/test named by the regression
- current W1-W6 ledger row via targeted grep
- latest accepted review artifact for the failing family

Do not read:
- broad W1-W6 history
- unrelated worlds
- W7-W12

Allowed actions:
- fix a concrete regression
- add or update focused regression tests
- document any claim impact

Forbidden actions:
- new W1-W6 content families
- score increases
- Human QA or launch claims
- broad migration

Validation expectation:
- reproduce failure when possible; focused test/validator proving fix; `flutter analyze` if source changed; graphify/diff checks.

Token budget target: 10k-40k.

## Lane: w7_w12_admission_planning
Read first:
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- targeted W7-W12 lock lines in `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`

Read only if needed:
- W7-W10 route-lock guard tests
- exact route files named by the planning prompt
- topology map sections on active route boundaries

Do not read:
- W1-W6 certification history except current freeze facts
- W13-W36
- output screenshots

Allowed actions:
- docs-only admission plan
- route-lock audit
- blocker map

Forbidden actions:
- route/runtime opening
- source authoring
- fixture creation unless a later implementation wave explicitly admits it

Validation expectation:
- graphify/diff checks; route-lock guard only if touched or explicitly required.

Token budget target: 10k-35k.

## Lane: market_competitor_review
Read first:
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- targeted `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` sections

Read only if needed:
- current public competitor evidence, with browsing if latest claims matter
- existing top-1 review artifacts named by the prompt

Do not read:
- fixture files
- validators
- W1-W6 artifacts unless the review names exact evidence

Allowed actions:
- compact strategic audit
- recommendation matrix
- claim-safety notes

Forbidden actions:
- product edits
- copied competitor assets/layouts
- monetization activation

Validation expectation:
- source links for current external claims; docs diff checks if artifact created.

Token budget target: Claude text audit 2k-6k; Codex strategy artifact 10k-25k.

## Lane: visual_regression_only
Read first:
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- exact visual bug report or screenshot packet named by prompt

Read only if needed:
- current Act0 route files touched by the visual issue
- screenshot manifest named by prompt
- focused Playwright/simulator scripts

Do not read:
- old screenshot folders
- W1-W6 review history
- content fixtures

Allowed actions:
- inspect targeted screenshots
- run focused screenshot/regression checks
- patch exact visual regression if admitted

Forbidden actions:
- design iteration from screenshots alone
- Modern Table redesign
- broad UI refresh

Validation expectation:
- targeted screenshot or UI test evidence; `flutter analyze` if Dart changed; diff checks.

Token budget target: audit 5k-20k; focused fix 20k-50k.

## Lane: emergency_bugfix
Read first:
- `AGENTS.md`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- failing command, stack trace, or exact bug report

Read only if needed:
- exact source files in stack trace
- nearest focused tests
- topology map only if route ownership is unclear

Do not read:
- planning ledgers unless claim/scope changes
- old review artifacts
- screenshot folders unless the bug is visual

Allowed actions:
- minimal fix for the concrete bug
- regression test
- concise repair artifact if the bug affects readiness claims

Forbidden actions:
- opportunistic refactors
- adjacent feature work
- score movement without explicit evidence

Validation expectation:
- reproduce or characterize bug; focused test/command proving fix; `flutter analyze` for Dart changes; graphify/diff checks.

Token budget target: 10k-40k.
