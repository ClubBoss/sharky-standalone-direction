# CI Workflow Rationalization Audit v1

## 1. Current main commit

- Base branch audited: `main`
- Main commit at audit start: `c0577cc`
- Backup branch confirmed: `origin/codex/backup-full-project-worktree-2026-06-19`
- Local tracked worktree state before this artifact: clean
- Ignored local state remains present, including `external_competitors/`; it was not touched.

## 2. Backup extraction final status

Backup extraction is effectively complete for the clean PR sequence that followed the full preservation branch.

PRs already merged into `main`:

- PR #1: Act0 broad preview gate recovery
- PR #2: Monetization entitlement safety contracts
- PR #3: Capture proof tooling source
- PR #4: SSOT route and monetization lock docs

No remaining backup-only runtime source, test source, or plan/SSOT document should be restored automatically in the current route. The remaining backup-only diff is either generated proof output, competitive research, stale duplicates from already-merged work, telemetry audit drift, or workflow remnants that need a deliberate CI cleanup PR rather than a blind restore.

## 3. Remaining backup-only inventory

Compared `main..origin/codex/backup-full-project-worktree-2026-06-19`.

Total remaining diff:

- `308 files changed`
- `10245 insertions(+)`
- `787 deletions(-)`

| Bucket | Count | Files / patterns | Purpose | PR recommendation | Risk |
|---|---:|---|---|---|---|
| `generated_outputs_or_playwright` | 263 | `output/playwright/**`, PNG, JSON, YML, `.capture_surface.js`, manifest outputs | Captured proof artifacts and generated Playwright output | Keep backup-only unless a curated proof artifact PR is explicitly requested | Medium if committed accidentally; generated and noisy |
| `competitive_or_external_research` | 6 | `docs/competitive/runout/**` | Runout competitive notes and opportunity docs | Keep backup-only unless repo-worthy competitive research is explicitly approved | Medium; external research can age quickly |
| `ci_workflow_backup_remnants` | 2 | `.github/workflows/l3-contract.yml`, `.github/workflows/r5-release-gate.yml` | Old workflow edits preserved in backup | Do not restore blindly; use as evidence for CI cleanup | High; backup diff removes useful pins/guards |
| `telemetry_audit_drift` | 2 | `tools/audit_worlds_0_4_telemetry_v1.dart`, `test/tools/worlds_0_4_telemetry_audit_contract_test.dart` | Telemetry audit tweaks from older route state | Keep backup-only until a telemetry wave reopens it | Medium; can conflict with current Act0 truth |
| `docs_or_proof_packets_remaining` | 27 | Proof, screenshot QA, commercial proof lane, first-week, premium planning, and W3 backlog review docs under `docs/_reviews/` | Historical proof packets or planning notes not part of current SSOT extraction | Keep backup-only for now | Low to medium; docs can create authority confusion if restored casually |
| `already_merged_or_stale_duplicates` | 8 | PR #1/#2/#3/#4 clean-PR docs, R5 PR #1 fix docs, stale `test/guards/world_campaign_*` versions | Already merged or superseded material | Do not restore | High for stale guard tests |
| `external_local_ignored` | local-only | `external_competitors/` plus other ignored local/build outputs | Local ignored material, not backup scope | Do not touch | High if accidentally committed |
| `unknown_needs_human_decision` | 0 | None found | N/A | N/A | N/A |

## 4. Workflow inventory table

Current `main` has 30 workflow files.

| Path | Name | Triggers | Jobs | Key commands / scripts | Toolchain behavior | Current relevance | Risk | Recommendation |
|---|---|---|---|---|---|---|---|---|
| `.github/workflows/analyze.yml` | Analyze | `push` to `main`, `fix/content-ci-structure`, `chore/**`; `workflow_dispatch` | `analyze`, manual `tier2-checkpoint` | `tools/run_table_first_tiers.sh 0/1/2` | Flutter `3.35.3`, while `.fvmrc` is `3.35.0` | Mainline tier verification | Medium | Keep, but align Flutter pin and decide if this overlaps with R5 gate |
| `.github/workflows/ci-pr-autoformat.yml` | Codex PR Autoformat (push-fix) | `pull_request` to `main`, codex branches only | `autoformat` | `scripts/normalize_ascii.py`, `dart format`, `dart fix --apply`, commits/pushes | Floating stable; malformed duplicate step keys near checkout | Auto-format bot | High | Disable or make manual-only before reuse; do not keep as required gate |
| `.github/workflows/ci-trigger-all.yml` | CI Trigger All | `workflow_dispatch` | `trigger` | Dispatch helper | No Flutter | Manual workflow orchestration | Low | Keep manual-only or remove if unused |
| `.github/workflows/ci.yaml` | L2 Tests (conditional) | `pull_request`, `push` to `main` | `l2` | `tool/dev/precommit_sanity.sh`, L2/L3 generators, validators, pack runs | Flutter `3.27.0`, stale versus `.fvmrc` | Label or commit-message gated heavy content/L2/L3 run | Medium | Keep optional only; align pin before relying on it |
| `.github/workflows/ci_nightly.yml` | ci-nightly | `workflow_dispatch` | `nightly` | `tooling/validate_research_outputs.dart`, `tooling/content_gap_report.dart` | Floating stable | Manual/nightly research output checks | Medium | Keep manual-only if scripts are current; otherwise archive |
| `.github/workflows/cli-dart.yml` | dart-cli (CLI-only) | `pull_request`, `push` with `bin/**` paths | `dart-cli` | Dart format/analyze for CLI paths | Floating stable plus Dart `3.9.0` setup | CLI-only path guard | Low | Keep path-scoped; align toolchain |
| `.github/workflows/codex-autofix.yml` | codex-autofix | `workflow_dispatch` | `trigger` | Manual autofix trigger | No Flutter | Manual automation | Medium | Keep manual-only only if actively used |
| `.github/workflows/content_ci.yml` | Content CI | `workflow_dispatch`, `push` to `main` | `content` | Content tooling and CI summary | Flutter `3.35.3` | Main/content verification | Medium | Keep optional/main-only; align pin |
| `.github/workflows/content_fast_lane.yml` | Content Fast Lane | `workflow_dispatch` | `fast-check` | `tooling/tool/fast_content_check.dart` | Uses `sdk: stable`, not a Flutter action pin | Manual content fast lane | Medium | Fix setup key/pin before relying on it |
| `.github/workflows/coverage-informational.yml` | Coverage Summary (informational) | `push` to `main` for Dart paths | `coverage` | Coverage summary | Floating stable | Informational only | Low | Keep non-blocking or manual-only |
| `.github/workflows/fix_packs.yml` | Fix Training Packs | `workflow_dispatch` | `fix_packs` | `validate_training_content.dart`, `fix_training_pack_errors.dart --apply`, creates PR | Flutter `3.35.1` | Manual mutating fixer | Medium | Keep manual-only; align pin and review generated PR behavior |
| `.github/workflows/full-tests-manual.yml` | Full Tests (Manual) | `workflow_dispatch` | `full-run` | Full test run | Floating stable | Manual full test | Low | Keep manual-only; align pin |
| `.github/workflows/health.yml` | Health | `push`, `pull_request` to `main` | `health` | PR-safe health skips heavy content checks | Floating stable | Lightweight health context | Low | Keep optional; confirm it adds value beyond R5 |
| `.github/workflows/l10n-drift.yml` | L10n Drift | `pull_request` for `lib/l10n/**` | `l10n-drift` | L10n drift check | Floating stable | Path-scoped localization guard | Low | Keep path-scoped; align pin |
| `.github/workflows/l3-contract.yml` | L3 Weights Contract | `pull_request`, `push` with L3 paths | `contract` | `tool/dev/precommit_sanity.sh`, L3 contract and smoke tests | Flutter `3.35.0` | Path-scoped L3 contract | Low | Keep current main version; reject backup broadening/removing relevance guard |
| `.github/workflows/live_fast_lane.yml` | Live Fast Lane | `workflow_dispatch` | `fast-live` | `tooling/tool/fast_live_check.dart` | Uses `sdk: stable` | Manual live fast lane | Medium | Fix setup key/pin before relying on it |
| `.github/workflows/phase4-nightly.yml` | Phase 4 Nightly Regression | `workflow_dispatch` | `phase4-nightly` | Phase 4 regression scripts | Flutter `3.27.0` | Legacy/manual regression | Medium | Manual-only; align or archive if Phase 4 is not active |
| `.github/workflows/precommit.yml` | Precommit Mirror | `workflow_dispatch` | `precommit` | `tooling/tool/precommit.dart` | Uses `sdk: stable` | Manual precommit mirror | Medium | Fix setup key/pin before relying on it |
| `.github/workflows/presubmit_codex.yml` | Codex Presubmit (format+analyze) | `pull_request`, codex branches only | `presubmit` | Format `bin lib/l3 tool/l3 test/ev`, limited analyze | Floating stable; duplicate setup blocks and duplicate `with:` | Codex branch presubmit | High | Fix structure or disable; overlaps with R5/analyze |
| `.github/workflows/preview_only.yml` | Preview (UI) | `workflow_dispatch` | `preview` | Derived allowlists, UI preview export | Uses `sdk: stable` | Manual preview generation | Medium | Keep manual-only; fix setup key/pin |
| `.github/workflows/public-demo-gate.yml` | Public Demo Gate | `push` to `release/**`/`demo/**`, `workflow_dispatch` | `demo-gate` | `public_demo_gate.sh`, stdout-clean smoke when seeded | Floating stable | Demo/release branch gate | Medium | Keep non-main/manual; align pin |
| `.github/workflows/pure_dart_smoke.yml` | pure-dart-smoke | `push`, `workflow_dispatch` | `smoke` | JSONL guard and smoke commands | Uses `sdk: stable` | Legacy/content smoke | Medium | Confirm scope or make manual-only; fix setup key/pin |
| `.github/workflows/r5-release-gate.yml` | R5 release gate | `pull_request`, `push` to `main` | `r5-release-gate` | `tools/check_repo_ready_r5_v1.sh --quick`, `tools/run_release_gate_r5_v1.sh` | Flutter `3.35.0`, matches `.fvmrc` | Current main release gate | Low | Keep as primary required repo-owned PR gate |
| `.github/workflows/r5-tier2-checkpoint.yml` | R5 Tier2 checkpoint | `workflow_dispatch`, `push` | `tier2-checkpoint` | `tools/run_table_first_tiers.sh 2` | Flutter `3.35.3` | Checkpoint/heavier tier 2 | Medium | Make manual-only or main-only; align pin |
| `.github/workflows/sanity-informational.yml` | Codex Sanity (analyze only) | `workflow_dispatch` | `sanity` | `flutter analyze` | Floating stable | Manual/informational sanity | Low | Keep manual-only or remove if redundant |
| `.github/workflows/theory-integrity.yml` | Theory Integrity | `pull_request`, `push`, `workflow_dispatch` | `verify` | `tool/theory_verify.sh` when theory changes | Floating stable | Repo-owned PR check that skips if irrelevant | Low | Keep, align pin |
| `.github/workflows/theory-manifest-generate.yml` | Theory Manifest - Generate baseline | `push` to `main`, `workflow_dispatch` | `generate-baseline` | `tooling/content_next.dart` | Flutter `3.35.3` | Main/manual content baseline | Medium | Keep optional/main-only; align pin |
| `.github/workflows/unit-tests-nightly.yml` | Unit Tests (Nightly Full) | `workflow_dispatch` | `full-run` | Full unit tests | Floating stable | Manual full test | Low | Keep manual-only; align pin |
| `.github/workflows/unit-tests.yml` | Unit Tests (compact, non-blocking) | `workflow_dispatch` | `unit-tests` | Compact unit tests | Floating stable | Optional unit check | Low | Keep optional or fold into R5 target model |
| `.github/workflows/validate.yml` | validate | `push` to `main`, `workflow_dispatch` | `allowlists` | `tools/allowlists_sync.py --check` when relevant | No Flutter | Content allowlist validation | Low | Keep optional/main-only if still current |

## 5. Required/optional status findings

GitHub branch/ruleset API findings:

- `gh api repos/:owner/:repo/branches/main/protection`: `Branch not protected` / HTTP 404
- `gh api repos/:owner/:repo/rulesets`: `[]`

Observed conclusion:

- There is no API-visible required status check list for `main`.
- Repo-owned checks are currently enforced by PR convention and merge discipline, not by branch protection.
- External failed checks such as TestSprite have not blocked previous merges when repo-owned checks were green.

## 6. Toolchain pinning findings

Project pin:

- `.fvmrc`: Flutter `3.35.0`
- `pubspec.yaml`: Dart SDK `>=3.9.0 <4.0.0`

Findings:

- Current primary R5 gate uses Flutter `3.35.0`, matching `.fvmrc`.
- Several workflows use Flutter `3.35.3` or `3.35.1`.
- Older workflows still use Flutter `3.27.0`.
- Many workflows use floating `channel: stable`.
- Several workflows appear to use `sdk: stable` or `sdk: "stable"` in setup blocks, which is not the normal `subosito/flutter-action` pin shape.

Recommendation:

- Standardize repo-owned Flutter workflows on `.fvmrc` / Flutter `3.35.0` unless a workflow has a documented reason to diverge.
- Avoid floating `stable` for gates that can block or guide merges.

## 7. Duplicate/overlap findings

Primary overlaps:

- `r5-release-gate.yml` and `analyze.yml` both represent repo readiness tiers, but R5 is the current PR gate.
- `theory-integrity.yml`, `content_ci.yml`, `validate.yml`, `pure_dart_smoke.yml`, and `content_fast_lane.yml` overlap around content/theory safety.
- `ci.yaml`, `l3-contract.yml`, `phase4-nightly.yml`, and L2/L3 tooling workflows overlap older L2/L3 generation and validation surfaces.
- `presubmit_codex.yml`, `ci-pr-autoformat.yml`, and `sanity-informational.yml` overlap format/analyze concerns.

Highest-risk overlap:

- `ci-pr-autoformat.yml` can write to PR branches and apply `dart fix --apply`.
- `presubmit_codex.yml` has duplicated setup blocks and limited-scope analyze that can produce false confidence.

## 8. Stale/legacy workflow findings

Likely stale or legacy-heavy:

- `ci.yaml`: useful as optional full L2/L3 content lane, but pinned to old Flutter `3.27.0` and depends on broad legacy generation.
- `phase4-nightly.yml`: old Flutter `3.27.0` and Phase 4 naming appears outside current Act0-first route focus.
- `public-demo-gate.yml`: tied to seeded Phase 1 logs and demo branches, not current Act0 release gate.
- `pure_dart_smoke.yml`, `content_fast_lane.yml`, `live_fast_lane.yml`, `preview_only.yml`: may still be useful manually but need setup key/pin review before trusted gate use.

Backup workflow remnants:

- Backup version of `l3-contract.yml` broadens path triggers to `lib/**` and `tool/**`, removes the L3 relevance guard, adds duplicate Flutter setup blocks, and changes the Flutter pin.
- Backup version of `r5-release-gate.yml` removes the explicit Flutter `3.35.0` pin.
- These backup changes should not be restored.

## 9. TestSprite classification

Search findings:

- No `.github/workflows/**` TestSprite workflow was found.
- No repo-owned TestSprite config was found.
- TestSprite references in the repo are review artifacts documenting prior external PR status behavior.

Classification:

- TestSprite is an external GitHub App/status, not repo-owned workflow configuration.
- It is not required by visible branch protection or rulesets.
- It should not be faked with placeholder tests or generated outputs.

Admin decision if it becomes blocking:

- Remove `TestSprite Pre-Check` from required checks, configure TestSprite properly, or explicitly allow maintainers to bypass it by repository policy.

## 10. Recommended target CI model

Use a smaller explicit model:

1. Required PR gate: `r5-release-gate.yml`
   - Runs `flutter pub get`
   - Runs `./tools/check_repo_ready_r5_v1.sh --quick`
   - Runs `./tools/run_release_gate_r5_v1.sh`
   - Uses `.fvmrc` pin / Flutter `3.35.0`

2. Required or conventionally expected PR check: `theory-integrity.yml`
   - Keep path/content detection
   - Pin Flutter to `.fvmrc`
   - Skip cleanly when theory paths are not touched

3. Optional path-scoped guard: `l3-contract.yml`
   - Keep current path scope and relevance guard
   - Do not broaden to all `lib/**`

4. Optional/manual checkpoint:
   - `r5-tier2-checkpoint.yml` or `analyze.yml` manual tier 2 only
   - Avoid duplicating the primary R5 gate on every PR

5. Manual content/demo/capture lanes:
   - Keep only if explicitly owned
   - Pin toolchains before trusting results

## 11. Safe immediate cleanup candidates

Next CI cleanup PR can safely be scoped to workflow hygiene only:

- Fix or disable `ci-pr-autoformat.yml` because it is mutating, branch-writing, and structurally suspicious.
- Fix or disable `presubmit_codex.yml` because it has duplicate setup blocks and overlaps other gates.
- Standardize Flutter pins in current repo-owned gate workflows to `.fvmrc` / `3.35.0`.
- Keep `r5-release-gate.yml` as the primary PR gate.
- Keep current `l3-contract.yml`; do not restore backup changes.
- Keep TestSprite out of repo-owned CI unless a real config is intentionally added.

## 12. Changes requiring human/admin decision

- Whether to add branch protection/rulesets that require only repo-owned checks.
- Whether TestSprite should be removed, configured, or accepted as optional.
- Whether autoformat bots are allowed to push to PR branches.
- Whether competitive research under `docs/competitive/runout/**` belongs in the repo.
- Whether generated proof outputs should ever be curated into a separate proof artifact PR.

## 13. Delete/manual-only/path-scope candidates

Recommended decisions for the next cleanup plan:

- Delete or manual-only: `ci-pr-autoformat.yml` unless branch-writing autoformat is explicitly wanted.
- Fix or manual-only: `presubmit_codex.yml`.
- Manual-only: `full-tests-manual.yml`, `unit-tests-nightly.yml`, `precommit.yml`, `preview_only.yml`, `public-demo-gate.yml`.
- Keep path-scoped: `l3-contract.yml`, `l10n-drift.yml`, `cli-dart.yml`.
- Keep main/manual-only content checks only after pin alignment: `content_ci.yml`, `validate.yml`, `theory-manifest-generate.yml`, `pure_dart_smoke.yml`.

## 14. Proposed next PR plan

Recommended branch:

- `codex/ci-workflow-rationalization-v1`

Proposed scope:

- Workflow files only.
- No product code.
- No tests.
- No generated outputs.
- No competitive research.
- No backup proof artifacts.

Likely file candidates:

- `.github/workflows/ci-pr-autoformat.yml`
- `.github/workflows/presubmit_codex.yml`
- `.github/workflows/r5-release-gate.yml`
- `.github/workflows/theory-integrity.yml`
- `.github/workflows/l3-contract.yml`
- Optional pin-only updates in manual workflows after explicit approval

Required checks for the cleanup PR:

- `git diff --check`
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- `./tools/release_gate_world1.sh`
- GitHub PR checks for repo-owned workflows
- No TestSprite workaround unless repo config is intentionally added

## 15. Final recommendation: continue CI cleanup or return to product EV

Continue with one small CI cleanup PR before returning to product EV.

Reason:

- Product scopes are now preserved and merged cleanly through PR #4.
- Remaining backup extraction is complete enough to stop mining the backup branch.
- CI debt is meaningful: malformed/duplicated workflow blocks, mixed Flutter pins, optional legacy lanes, and no branch protection/ruleset clarity can slow every future PR.
- The next PR should not restore backup workflow diffs; it should rationalize current `main` workflows directly.

PR readiness for this audit artifact:

- Docs-only.
- No runtime impact.
- No workflow changes.
- No generated output restored.
- No `external_competitors/` interaction.
