# R56 Actions Cost Reduction Closeout v1

## Workflow inventory summary
- Total workflows inspected: 24 (`.github/workflows/*`).
- Kept as-is (release/branch-safety aligned): `r5-release-gate.yml`, `r5-tier2-checkpoint.yml`, `public-demo-gate.yml`, `ci-trigger-all.yml`, `preview_only.yml`.
- Narrowed (high-minute / lower-EV automation): nightly schedules, feature-branch mirrors, and broad push triggers listed below.
- Disabled/deleted: none (bounded narrowing only).

## What was kept / narrowed / disabled
- Kept as-is:
  - `r5-release-gate.yml` (documented CI wiring in README; PR + main safety gate).
  - `r5-tier2-checkpoint.yml` (manual/tag checkpoint path).
- Narrowed to manual-only:
  - `ci_nightly.yml` (removed `schedule`).
  - `unit-tests-nightly.yml` (removed `schedule`, kept `workflow_dispatch`).
  - `phase4-nightly.yml` (removed `schedule`).
  - `precommit.yml` (removed feature/feat `push` trigger).
  - `live_fast_lane.yml` (removed feature/feat `push` trigger).
  - `content_fast_lane.yml` (removed feature/feat `push` trigger).
- Narrowed trigger scope:
  - `ci.yaml` (removed nightly `schedule`; preserved explicit PR-label/push-marker flow).
  - `pure_dart_smoke.yml` (push narrowed to `main` only; manual preserved).
  - `validate.yml` (push narrowed to `main` only; manual added).
- Disabled: none.

## Why
- Billing warning requires immediate minute burn reduction.
- Repo is local-first for validation (`flutter analyze`, `./tools/fast_loop_world1_v1.sh`, targeted tests).
- README documents R5 gate workflows as the release path; these were preserved unchanged.
- High-minute scheduled runs and feature-branch mirrors were additive/duplicative relative to local-first workflow and R5 release gates.

## Expected minute-burn reduction
- Material reduction from eliminating all daily cron automation in this pass:
  - `ci_nightly.yml` (daily),
  - `unit-tests-nightly.yml` (daily full test),
  - `phase4-nightly.yml` (daily regression).
- Additional reduction from removing automatic runs on feature-branch pushes for mirror fast-lane workflows.
- Additional reduction from narrowing broad push workflows (`pure_dart_smoke`, `validate`) to `main` + manual.

## Open risks
- Some diagnostics previously auto-produced by nightly jobs now require manual dispatch.
- If branch protection outside repo docs depends on a narrowed non-R5 workflow name, admin-side adjustment may be needed.

## Explicit defer list
- Any CI architecture redesign or workflow consolidation.
- Changes to product/runtime/content behavior.
- Branch protection reconfiguration (outside repo scope for this milestone).
