# Capture Proof Tooling Clean PR v1

## 1. Branch and Base Commit

- Branch: `codex/capture-proof-tooling`
- Base branch: `main`
- Base commit: `0663bf4`
- Backup source: `origin/codex/backup-full-project-worktree-2026-06-19`

## 2. Scope Restored From Backup

This branch restores only source files needed for compact first-week proof capture tooling:

- generated-output ignore rules
- capture-only URL parsing for proof surfaces
- an English-only capture locale override
- a more reliable controlled demo capture wait loop
- a focused first-week compact capture command
- targeted contract tests for those capture hooks

## 3. Files Included

- `.gitignore`
- `lib/ui_v2/app_root.dart`
- `tools/act0_controlled_demo_capture_v1.sh`
- `tools/act0_first_week_compact_capture_v1.sh`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/capture_proof_tooling_clean_pr_v1.md`

## 4. Files Explicitly Excluded

Excluded from this branch:

- `.github/workflows/*`
- `output/playwright/**`
- `docs/competitive/runout/**`
- unrelated `docs/plan/**`
- unrelated `docs/_reviews/**`
- `test/guards/world_campaign_*`
- generated PNG/JSON/YML proof artifacts
- `external_competitors/`
- monetization files already merged in PR #2
- old PR #1 / PR #2 duplicate docs

## 5. Capture Tooling Purpose

The restored tooling supports deterministic compact proof capture for first-week surfaces and specific feedback states. It keeps capture concerns in debug/test hooks and scripts instead of changing normal learner routes.

## 6. Generated Outputs Policy

Generated captures remain out of this PR. The new script writes captures under `output/playwright/...`, but no generated output files are restored or committed here.

## 7. Product Route Truth Impact

No product route truth is changed. The `app_root.dart` additions only parse explicit `act0_capture` query values and apply an English locale override when a valid capture entry is present and the app is not in release mode.

## 8. Tests and Checks Run

Completed before commit:

- `dart format lib/ui_v2/app_root.dart test/ui_v2/act0_shell_preview_screen_v1_test.dart`: passed, 0 changed
- `bash -n tools/act0_controlled_demo_capture_v1.sh`: passed
- `bash -n tools/act0_first_week_compact_capture_v1.sh`: passed
- `flutter analyze`: passed
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`: passed, +656
- `git diff --check`: passed
- `./tools/fast_loop_world1_v1.sh`: passed, FAST LOOP PASS, +656
- `./tools/release_gate_world1.sh`: passed, World1 release gate passed, +682 selected tests

## 9. Known Non-Goals

This wave does not run capture tooling, add screenshots, add Playwright output, change workflows, change monetization, change competitive research docs, alter Modern Table visuals, or create a PR.

## 10. PR Readiness Verdict

Ready for PR after commit and push. Scope is source-only capture tooling; no generated outputs are restored.
