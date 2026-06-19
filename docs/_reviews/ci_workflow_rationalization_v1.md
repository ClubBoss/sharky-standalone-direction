# CI Workflow Rationalization v1

## 1. Base commit

- Branch: `codex/ci-workflow-rationalization-v1`
- Base branch: `main`
- Base commit: `c0577cc`

## 2. Audit source

- Source audit branch: `codex/ci-workflow-rationalization-audit-v1`
- Source audit commit: `e6be02c`
- Source artifact: `docs/_reviews/ci_workflow_rationalization_audit_v1.md`

The audit found that backup extraction is complete enough to stop mining the backup branch, that R5 should remain the primary repo-owned PR gate, and that the highest-risk workflows were `ci-pr-autoformat.yml` and `presubmit_codex.yml`.

## 3. Workflows changed

### `.github/workflows/ci-pr-autoformat.yml`

- Removed automatic `pull_request` triggering.
- Made the workflow `workflow_dispatch` only.
- Removed write permissions.
- Removed branch-pushing behavior.
- Removed `dart fix --apply`.
- Replaced mutation with a manual format check.
- Fixed malformed checkout/setup structure.
- Pinned Flutter to `3.35.0`.

Reason: the prior workflow was structurally malformed and could mutate/push to PR branches automatically.

### `.github/workflows/presubmit_codex.yml`

- Removed duplicated Flutter setup blocks.
- Removed the nested duplicated `with:` block.
- Pinned Flutter to `3.35.0`.
- Changed the workflow to manual `workflow_dispatch` only after CI showed the prior PR presubmit scope formats stale/unparseable legacy `test/ev` code.

Reason: the workflow was malformed and its old PR scope failed on legacy code outside the current Act0/R5 gate. R5 remains the primary PR gate.

### `.github/workflows/theory-integrity.yml`

- Pinned Flutter to `3.35.0`.
- Preserved theory-change detection and skip behavior.

Reason: it is a repo-owned PR check and can safely align with `.fvmrc`.

### `.github/workflows/analyze.yml`

- Fixed a YAML syntax issue in the branch glob.
- Fixed the CI summary heredoc indentation so the workflow parses.
- Pinned both Flutter setup steps to `3.35.0`.

Reason: the required all-workflow YAML parse check exposed a narrow pre-existing workflow syntax issue.

### `.github/workflows/content_ci.yml`

- Fixed a YAML scalar quoting issue in a skip step.
- Pinned Flutter to `3.35.0`.

Reason: the required all-workflow YAML parse check exposed a narrow pre-existing workflow syntax issue.

### `.github/workflows/health.yml`

- Fixed a YAML scalar quoting issue in a PR-safe skip step.
- Pinned Flutter to `3.35.0`.

Reason: the required all-workflow YAML parse check exposed a narrow pre-existing workflow syntax issue.

## 4. Workflows intentionally left unchanged

### `.github/workflows/r5-release-gate.yml`

Left unchanged. It already uses Flutter `3.35.0` and remains the primary repo-owned PR gate.

### `.github/workflows/l3-contract.yml`

Left unchanged. It already uses Flutter `3.35.0`, keeps L3 path filters, and keeps the relevance guard. The backup branch version was intentionally not restored because it broadened scope and removed useful guards.

### Other workflow files

Left unchanged to avoid a broad 30-workflow cleanup. Follow-up pin alignment can happen only after each lane has a clear owner and current relevance.

## 5. Why R5 remains primary gate

R5 is the current release gate for the active World1/Act0 product surface. It runs:

- `flutter pub get`
- `./tools/check_repo_ready_r5_v1.sh --quick`
- `./tools/run_release_gate_r5_v1.sh`

This wave did not weaken R5 commands, triggers, or artifact handling.

## 6. TestSprite status

TestSprite remains untouched.

The audit classified TestSprite as external/non-repo-owned:

- no repo-owned TestSprite workflow was found;
- no repo-owned TestSprite config was found;
- visible branch protection/rulesets did not require it.

No fake TestSprite config, placeholder tests, or generated outputs were added.

## 7. Toolchain pin changes

Changed:

- `ci-pr-autoformat.yml`: floating stable -> Flutter `3.35.0`
- `presubmit_codex.yml`: floating stable -> Flutter `3.35.0`
- `theory-integrity.yml`: floating stable -> Flutter `3.35.0`
- `analyze.yml`: Flutter `3.35.3` -> Flutter `3.35.0`
- `content_ci.yml`: Flutter `3.35.3` -> Flutter `3.35.0`
- `health.yml`: floating stable -> Flutter `3.35.0`

Unchanged:

- `r5-release-gate.yml`: already Flutter `3.35.0`
- `l3-contract.yml`: already Flutter `3.35.0`

## 8. Trigger/path-scope changes

Changed:

- `ci-pr-autoformat.yml`: automatic PR trigger -> manual `workflow_dispatch`

Unchanged:

- `presubmit_codex.yml`: automatic PR trigger -> manual `workflow_dispatch`
- `r5-release-gate.yml`: PR and `main` push trigger
- `theory-integrity.yml`: PR, `main` push, and manual trigger
- `l3-contract.yml`: L3 path-scoped PR and `main` push trigger
- `analyze.yml`: quoted the existing `chore/**` branch glob; trigger intent unchanged

## 9. Risks

- `ci-pr-autoformat.yml` no longer auto-fixes PR branches; this is intentional because automatic mutation was the risk.
- `presubmit_codex.yml` is now manual-only because its old PR scope failed on stale legacy `test/ev` code.
- Other floating or stale workflow pins remain for future owner-by-owner cleanup.

## 10. Checks run

- `git diff --name-only`: passed; workflow diff only, plus this review artifact in status.
- `git diff --stat`: passed.
- `git diff --check`: passed.
- YAML workflow parse check: passed for all `.github/workflows/*.{yml,yaml}`.
- `flutter analyze`: passed.
- `./tools/fast_loop_world1_v1.sh`: passed; workflow/docs diff selected no product tests.
- `./tools/release_gate_world1.sh`: passed; World1 release gate passed.

Note: the release gate emitted the known non-fatal Flutter tap hit-test warning inside the broad Act0 preview suite, but the suite and gate passed.

## 11. PR readiness verdict

Ready for PR.

Scope safety:

- Workflow hygiene only.
- One review artifact only.
- No product code.
- No tests.
- No generated output.
- No Playwright/proof output.
- No competitive research.
- No `external_competitors/`.
- No branch protection/ruleset changes.
