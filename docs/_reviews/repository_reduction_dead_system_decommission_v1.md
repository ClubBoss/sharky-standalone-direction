# Repository Reduction + Dead-System Decommission v1

## 1. Verdict

`repository_reduction_dead_system_decommission_closed_push_ready`

## 2. Base HEAD

- Parent branch: `claude/repo-hygiene-context-cost-reduction-v1`
- Required base HEAD: `0c922689cf41f3c31d22ce046bf16455d6fa66f7` (resolved and confirmed as the exact worktree HEAD before branching)
- Branch: `claude/repository-reduction-dead-system-decommission-v1`

## 3. Repository families evaluated

`lib/` (dormant-system candidates named in `PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: persona, ai_coach, personalization, ui_v3, legacy drill/table screens, legacy runners, map v2, TrainingPackPlayScreen/TrainingSessionScreen bridge, plus `UiV2BetaShell` discovered during investigation), root scripts, `tools/` (831 files), `docs/_reviews/` (636 files) and `docs/archive/` (472 files) supersession candidates, and tracked `output/` (1,006 files). Full detail and evidence per family is in `docs/_reviews/repository_reduction_decommission_ledger_v1.md`.

Method: family-level reachability/reference proof via targeted `git grep`/scripted reference counts, not full-file reads at scale; four parallel Explore-agent passes gathered first-pass evidence, which I then independently re-verified (production-only import checks, test-context reads, stash-based pre-existing-failure confirmation) before acting.

## 4. Code removed

**None.** Every named dormant `lib/` family turned out, on verification, to be either:
- non-existent (`lib/ui_v2/persona/*` — a topology-doc/reality mismatch, nothing to remove),
- already relocated outside `lib/` (`ui_v2_progress_map_screen_v2.dart`),
- genuinely still active (`ai_coach`, `personalization`, `ui_v3` stub, `table_surface.dart`, `lib/archive/legacy_runners/*`, the training-compatibility bridge — all have live non-Act0 production consumers and/or direct test imports), or
- genuinely dead in production but too entangled with broad release-gate/E2E test contracts to safely disentangle in one bounded pass (`drill_runner_screen.dart`, 14 referencing test files, several of which are multi-screen readiness gates with conditional legacy/canonical branches).

One additional dead-code candidate was discovered during investigation (`lib/ui_v2/ui_v2_beta_shell.dart` / `UiV2BetaShell`, 451 lines, zero real references) but is flagged `uncertain_do_not_touch` rather than removed, because an open investigation doc (`docs/audit/investigations/topology_entry_seam_audit_v1.md`) treats its internals as a live subject for centralizing logic into canonical services — a near-term-planned ambiguity this bounded pass did not resolve.

This is an honest `no safe code decommission this wave` outcome for `lib/`, not an unexamined one — see the ledger for full per-family evidence.

## 5. Tests removed

None. No test file was deleted or edited for behavior (one docs cross-reference was corrected, not a test).

## 6. Assets removed

None inspected/removed this wave (no orphaned-asset evidence was gathered; out of the bounded budget after the `tools/`/`output/`/docs work below).

## 7. Tools/scripts removed

- 4 root scripts: `fix_expected_paren.sh`, `test-analyze.sh` (zero references anywhere), `diagnose_tests.sh`, `verify_and_log.sh` (referenced only by a closed-out historical phase doc, `docs/canonical/PHASE_R_CLOSEOUT_AND_HANDOFF.md`, whose own text confirms the current canonical loop — `tools/fast_loop_world1_v1.sh`/`release_gate_world1.sh`/`checkpoint_world1_v1.sh` — superseded it).
- 478 files under `tools/` (`.dart`/`.sh`/`.py`), confirmed via a scripted whole-repo reference check (basename search, self-excluded) to have zero references anywhere — no docs, no tests, no other tool, no CI workflow, no `pubspec.yaml`. `tools/**` is excluded from `analysis_options.yaml`'s analyzer scope, and the two files that dynamically walk the `tools/` directory (`documentation_ci_audit_pass.dart`, `ultimate_repo_audit.dart`) are themselves in the zero-reference set, ruling out a live meta-invoker.

Total: 482 files, ~3.6 MB.

## 8. Docs archived/deleted

Archived (moved `docs/_reviews/` → `docs/archive/historical_audits/`, one cross-reference corrected):
- `wave2_1_fix_landed_session_close_payoff_v1.md`, `wave2_2_premium_surface_hierarchy_v1.md`, `wave2_3_practice_confidence_first_week_content_v1.md` — explicitly named "closed" in `wave2_4_beta_handoff_packet_v1.md`'s own text.
- `claude_ux_v2_wave1_safe_now_cleanup_plan.md`, `claude_ux_v2_wave2_scope_selection_v1.md` — superseded by their respective self-contained closure docs (`claude_ux_v2_wave1_closure_proof.md`, `claude_ux_v2_wave2_closure_recheck.md`).
- `top1_product_attack_plan_refresh_v1.md` — `top1_product_attack_plan_refresh_v2.md`'s own text states v1 "was stale after the repair-loop stack closed"; the one file citing it by path was updated to the new archive path.

Deleted: none (archived, not deleted, per the mission's stated preference — each had unique-enough historical value to keep rather than discard).

Explicitly evaluated and **not** archived despite superseded-looking names: `w11_route_proof_goal_pack_v1.md` (documents a *distinct blocked approach*, not a draft of v2 — kept for its reopen-prevention value), the certification-closure ladder (different W-scopes, not duplicates), `ROUTE_TO_B_EXECUTION_RESET_v1.md`/`ROUTE_TO_B_ACTION_LADDER_v1.md` (still asserted-on by two active tests despite AGENTS.md calling them "archived"), `MASTER_PLAN_v2.2.md` (working-as-designed redirect stub).

No bulk action was taken across the remaining ~1,100 `docs/_reviews/`+`docs/archive/` files — the prior hygiene pass's md5 scan found zero exact duplicates, and this pass only acted where explicit textual supersession evidence was found, per "content uniqueness is not the same as ongoing project value" but also per "do not retain merely because checksums differ" — both cut against a blind bulk sweep without evidence.

## 9. Tracked output evidence reduced

385 files removed across 6 confirmed-superseded Playwright capture-iteration families, each with a retained canonical/latest replacement and zero test-path coupling (confirmed repo-wide):

| Family | Removed | Kept (canonical) |
|---|---|---|
| `act0_learn_v2`-`v6` mission-hub probes | 39 files across 11 dirs | `act0_learn_final_premium_closeout_manual` (3 files) |
| `controlled_demo` iterations | 86 files across 5 dirs | `controlled_demo_canonical_refresh_v1` (17 files) |
| `act0_capture_smoke` red/base/green1 | 96 files across 3 dirs | `act0_capture_smoke_green2` (73 files) |
| `act0_learn_hierarchy_green1` | 73 files | `act0_learn_hierarchy_green2` (73 files) |
| `act0_learn_ux_repair_green1` | 73 files | `act0_learn_ux_repair_green2` (47 files); `direct1` (39 files, ambiguous alternate-approach probe) deliberately left untouched |
| `placement_welcome_wave1` (original) | 18 files | `placement_welcome_wave1_fresh` (18 files) |

Untracked local-only `output/screen_review/` and `output/claude_review/` (84 MB combined) were confirmed to have **zero git-tracked files** (pure `.zip`/`.DS_Store`, already gitignored) — outside this task's scope entirely.

## 10. Families retained and why

See the ledger's "Evaluated, not touched" table for full detail. Headline reasons: genuine live production reachability (`personalization/*`, `ui_v3` stub, `table_surface.dart`, `legacy_runners/*`, training-compatibility bridge), entangled test surface too risky to disentangle in one pass (`drill_runner_screen.dart`), open/ambiguous near-term investigation (`UiV2BetaShell`, `lib/tools/*` self-referential stub family), and insufficient supersession evidence for bulk docs action.

## 11. Uncertain families (left untouched, missing proof documented)

- `lib/ui_v2/ui_v2_beta_shell.dart` (`UiV2BetaShell`) — zero real references found, but an open investigation doc treats its internals as active subject matter. Missing proof: whether that investigation still needs this exact file, or has already moved the relevant logic elsewhere.
- `lib/tools/v4_persona_mat_consistency_qa.dart`, `v4_visual_polish_final.dart`, `visual_cohesion_v4_qa.dart`, `visual_tokens_v4_verifier.dart` — self-referential no-op stubs discovered incidentally; not investigated to the same depth as the root `tools/` sweep.
- `lib/ui_v2/screens/drill_runner_screen.dart` and its 14 referencing test files — genuinely dead in production, but per-test disentanglement (which tests are narrowly-dead-only vs. broad release gates needing a rewritten assertion) needs a dedicated task.
- `w1_w6_*` side-audit cluster (6 files) — not read this pass; no supersession evidence gathered either way.
- Bulk of `docs/_reviews/` (630 remaining) and `docs/archive/` (478) — evidence-gated, not bulk-classified.

## 12. Before/after counts and bytes

| Metric | Before | After |
|---|---|---|
| Total tracked files | 13,027 | 12,160 |
| `docs/_reviews/` | 636 | 630 |
| `docs/archive/` | 472 | 478 |
| `tools/` | 831 | 353 |
| Tracked `output/` | 1,006 | 621 |
| Root shell scripts | 7 | 3 |
| Total bytes removed from active tree | — | 37,909,331 bytes (~36.2 MB) |

## 13. Context-cost reduction estimate

- Removing 478 zero-reference `tools/` scripts eliminates a large, previously-unfiltered search surface (`tools/` is analyzer-excluded but not search-excluded) that a future agent doing `find`/`grep`-based tool discovery would otherwise wade through — roughly 58% reduction in `tools/` file count (831 → 353).
- Removing 385 superseded `output/playwright/` capture directories removes ambiguous "which one is current" navigation cost for any future visual-evidence task; the router already tells agents not to read `output/**` by default, so the main saving is disk/diff-noise, not per-turn read cost.
- 6 docs archived out of 636 is a modest, evidence-gated reduction, intentionally conservative given the "do not mass-move" guidance.
- Estimated aggregate: a future full-repo `find`/`grep` sweep (e.g. an Explore agent doing broad discovery) now touches ~6.7% fewer tracked files (13,027 → 12,160) and ~36 MB less tree content; the highest-value single change is the `tools/` reduction since that directory is exactly the kind of place a "what tooling exists for X" search would previously return dozens of dead false leads.

## 14. Validation

- `git diff --check`: exit 0.
- `git diff --cached --check`: exit 0.
- `flutter analyze`: `No issues found!` (13.3s) — unaffected, since `tools/**`/`lib/tools/**` are analyzer-excluded and zero `lib/`/`test/` files were touched.
- `graphify hook-check`: exit 0.
- Broken-reference scan: zero remaining references to any of the 867 removed paths or the 6 old doc paths (one genuine stale cross-reference found and fixed); two apparent hits (a `lib/tools/` self-referential stub family, and self-citations inside the archived docs' own historical "files changed" lists) were investigated and confirmed benign/pre-existing, not caused by this task.
- Focused canonical/test spot-checks: several pre-existing (not newly broken) test failures were discovered and confirmed unrelated by stashing all changes back to base HEAD `0c922689` and reproducing the identical failures — see Section 15 and the ledger's "Pre-existing issues" table.

## 15. Regressions

**None introduced by this task.** Zero `lib/` or `test/` files were changed. Six pre-existing test failures were discovered during validation spot-checks (stale hardcoded paths from prior, unrelated reorganizations, and undefined-symbol references) — all independently confirmed to fail identically on the unmodified base branch. They are documented in the ledger for the owner's attention but were not fixed here (out of this task's scope: dead-system decommission, not test repair).

## 16. Next route

Repository reduction is closed for this bounded wave. Recommended next steps, in order:
1. Owner review of this branch; integration/push when ready (not done automatically per policy).
2. A dedicated follow-up task to resolve the `drill_runner_screen.dart` / 14-test entanglement (would need per-test rewriting, not blind deletion).
3. A dedicated follow-up task to investigate `UiV2BetaShell` and the `lib/tools/` self-referential stub family found incidentally here.
4. Reconcile the topology doc's stale claims (`lib/ui_v2/persona/*` doesn't exist; `lib/archive/legacy_runners/*` is not actually inactive) — owner decision, not touched in this pass.
5. Fix the 6 pre-existing broken tests listed in the ledger (stale hardcoded paths / undefined symbols), independent of this decommission task.
6. Do not begin W1-W6 Wave 4 (out of scope here, as instructed).

## 17. Token Efficiency Report

- exact_usage: `token_usage_unavailable`
- estimated_total_tokens: `~250k-320k` (four parallel Explore-agent investigations plus substantial independent re-verification: production-only import greps, per-test-file context reads for 8+ test files, a background scripted reference-count pass over 811 tools files, stash-based baseline confirmation for 6 pre-existing failures, and authoring two lengthy ledger/closure documents)
- estimate_confidence: medium
- estimated_input_context: majority of cost — the four Explore-agent reports returned substantial detail that needed independent re-verification (one agent's claim about `UiV2BetaShell` owning `buildCanonicalPathRootV1` was factually wrong and had to be caught by direct grep)
- estimated_reasoning_and_output: moderate — extensive judgment calls on ambiguous families (drill_runner_screen, UiV2BetaShell, w11_route_proof_goal_pack_v1) required weighing evidence rather than mechanical classification
- estimate_basis: session tool-call count and file/line volumes touched, not an exact token meter
- largest_token_sinks: (1) the four parallel Explore-agent investigations, (2) manually re-verifying the `drill_runner_screen.dart` test-entanglement claim across 8 test files' import/context lines, (3) the background scripted `tools/` reference-count pass and its output file, (4) two full closure/ledger documents
- avoidable_token_cost: one Explore-agent's incorrect claim (that `UiV2BetaShell` owns `buildCanonicalPathRootV1`) cost an extra verification round; unavoidable in the sense that first-pass agent claims always need independent confirmation before acting on deletions, but the specific error added one extra grep-and-reconcile cycle
- efficiency_verdict: acceptable — this is an inherently expensive task class (repo-wide dead-code proof requires per-family evidence, not a single query), and no repeated/wasted broad passes occurred beyond the one agent-claim correction
- largest_broad_searches: 4 (one per parallel Explore agent); 1 scripted whole-`tools/`-directory reference sweep (811 files)
- targeted_searches: ~25+ (per-family reachability greps, per-test-file context reads, per-doc supersession-text checks, stash-based baseline reproductions)
- files/families inspected: ~15 named `lib/` families, 831 `tools/` files (via script), 7 root scripts, ~15 docs supersession candidates, 6 `output/` capture families (~20 subdirectories)
- commands/tests run: `git status`/`log`/`diff`/`stash`/`rev-parse`, `flutter analyze` (x2), `flutter test` (targeted, ~10 files across 3 invocations), `graphify hook-check` (x2), a background `xargs`-parallelized reference-count script
- repeated_investigation: one (the `UiV2BetaShell`/`buildCanonicalPathRootV1` correction)
- another discovery pass required: no for this wave's scope; yes for the four explicitly flagged follow-up items in Section 16
