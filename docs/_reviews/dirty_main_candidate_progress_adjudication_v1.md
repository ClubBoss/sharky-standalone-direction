---
status: "dirty_main_candidates_fully_adjudicated_safe_to_release"
status_source: "derived"
doc_date: "2026-07-03"
baseline: "4d424a8b6215"
generated_by: "docs_frontmatter_v1"
---

# Dirty Main Candidate Progress Adjudication v1

Date: 2026-07-03
Mode: analysis-only dirty-main candidate adjudication
Accepted branch HEAD reviewed: `4d424a8b6215a9872dd8cfc91fd467271e6e810a`
Dirty-main HEAD reviewed: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40`
Preservation package:
`/Users/elmarsalimzade/.config/superpowers/preservation/Sharky_1.0/dirty-main-05bd3fa4-v1/`

## 1. Verdict

`dirty_main_candidates_fully_adjudicated_safe_to_release`

The preserved dirty-main candidate set contains no product, test, tooling, or
documentation hunk that must be recovered before the accepted branch is
integrated. The useful route/content/tooling work represented by the dirty-main
patch split is already present in stronger, later, committed form on the
accepted branch, and the remaining differences are either stale experiments,
local preservation artifacts, or generated evidence that is already archived.

No dirty-main cleanup, stash, reset, restore, branch switch, merge, rebase,
cherry-pick, push, or patch application was performed during this adjudication.

## 2. Inputs Reviewed

- `preservation_manifest.md`
- `comparison_to_accepted_branch.md`
- `tracked_change_classification.tsv`
- `untracked_manifest.txt`
- `tracked_changes.patch`
- Dirty-main versions of the 11 divergent tracked files
- Accepted-branch versions of the 11 divergent tracked files
- Commit history touching the candidate families on the accepted branch
- Six unique untracked review docs
- Six `output/patch_split/dirty_worktree_manual_patch_split_v1/` files

The 190 generated/evidence files outside the patch-split set were not
semantically reviewed; they were confirmed preserved and classified as
regenerable evidence/output.

## 3. Candidate Inventory

Tracked divergent files reviewed:

1. `lib/campaign/campaign_pack_registry_v1.dart`
2. `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
3. `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
4. `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
5. `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
6. `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
7. `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`
8. `test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`
9. `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
10. `test/ui_v2/act0_world1_completion_payoff_v1_test.dart`
11. `tools/act0_real_text_surface_capture_v1.dart`

Unique untracked candidate files reviewed:

1. `docs/_reviews/dirty_worktree_manual_patch_split_v1.md`
2. `docs/_reviews/pre_human_10_10_redesign_decision_addendum_v1.md`
3. `docs/_reviews/senior_ux_ui_motion_excellence_audit_v1.md`
4. `docs/_reviews/visual_ux_fix_verification_v1.md`
5. `docs/_reviews/welcome_review_bounded_pre_human_layout_direction_v1.md`
6. `docs/_reviews/whole_product_ux_ui_coherence_redesign_ev_audit_v1.md`
7. `output/patch_split/dirty_worktree_manual_patch_split_v1/00_README.md`
8. `output/patch_split/dirty_worktree_manual_patch_split_v1/A_prior_route_content_wave.patch`
9. `output/patch_split/dirty_worktree_manual_patch_split_v1/B_visual_ux_known_p1_fix_wave.patch`
10. `output/patch_split/dirty_worktree_manual_patch_split_v1/C_route_screenshot_tooling_wave.patch`
11. `output/patch_split/dirty_worktree_manual_patch_split_v1/D_focused_visual_ux_upgrade_wave_v2.patch`
12. `output/patch_split/dirty_worktree_manual_patch_split_v1/PATCH_SPLIT_MANIFEST.json`

## 4. Per-File Semantic Findings

| File | Intent of dirty-main changes | Semantic finding | Decision |
| --- | --- | --- | --- |
| `lib/campaign/campaign_pack_registry_v1.dart` | Refine W7-W12 bridge copy, claim-safety wording, and terminal Volume I copy. | The accepted branch already carries the current W7-W12 route/content wave and later validation repair. Dirty-main still has older terminal wording (`Tap Button for a keep-sharp review`) that the accepted branch deliberately replaced with less seat-label mechanical copy. | `superseded_safe_to_leave_unapplied` |
| `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart` | Visual polish for the Learn current-mission card and compact route-board label. | The luminous CTA/card treatment is a pre-accepted visual experiment. It is not needed for current route truth and risks broad UI churn before mainline integration. | `incomplete_experiment_do_not_apply` |
| `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` | Older removal of proof/payoff systems plus street replay presentation changes. | The accepted branch contains stronger later proof, Sharky, W1/W2-W6 payoff, band-transition, street-replay, and mascot work. Dirty-main removes accepted proof surfaces and contradicts current Sharky/proof direction. | `contradicts_current_ssot_do_not_apply` |
| `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart` | Focused visual polish for profile evidence ordering/copy. | The accepted branch contains later profile/Sharky/proof work. Dirty-main hunk is only a partial visual experiment and has no pre-integration recovery requirement. | `superseded_safe_to_leave_unapplied` |
| `lib/ui_v2/act0_shell/act0_review_shell_v1.dart` | Fill/center sparse Review surface. | The layout concern is documented in review artifacts, but the dirty-main hunk is not part of the accepted 63-commit branch and is not required to preserve route correctness. Recovering it now would reopen visual scope. | `incomplete_experiment_do_not_apply` |
| `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` | Daily-goal progress bar fix and visual/debug support updates. | The daily-goal progress calculation is already present in the accepted branch. Remaining dirty-main differences are older visual/support drift. | `superseded_safe_to_leave_unapplied` |
| `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart` | Welcome CTA/copy and centered content frame. | The accepted branch already contains the CTA/copy fix. The remaining dirty-main layout centering is a visual experiment, not a route/truth blocker. | `incomplete_experiment_do_not_apply` |
| `test/guards/w12_route_admission_review_payoff_gate_contract_test.dart` | Guard W12 terminal copy and Volume I review claim-safety. | Accepted branch contains the active route/content guard family plus later capsule-validation repair. Dirty-main includes older exact-copy expectations that conflict with accepted terminal wording. | `superseded_safe_to_leave_unapplied` |
| `test/ui_v2/act0_shell_preview_screen_v1_test.dart` | Add assertions for capture groups, welcome layout, CTA visibility, and summary copy. | Useful intent is already represented by accepted route tooling guards and current focused validation. Remaining broad shell-preview expectations are part of known legacy harness debt. | `superseded_safe_to_leave_unapplied` |
| `test/ui_v2/act0_world1_completion_payoff_v1_test.dart` | Collapse W1 payoff proof tests to older minimal Volume I milestone wording. | The accepted branch retains broader proof-icon, repair-proof, next-route, and claim-safety coverage. Dirty-main deletes valuable accepted coverage. | `contradicts_current_ssot_do_not_apply` |
| `tools/act0_real_text_surface_capture_v1.dart` | Route/active-route capture tooling with larger copy-detail viewport and no text-overlay sidecars. | Accepted branch already includes route and active-route capture lanes, metadata validity flags, allowlist packaging, and overlay sidecars. Dirty-main's `copyDetailSize = Size(760, 1200)` may be useful as a future capture-quality idea, but it is not required before integration and removing overlays would weaken accepted evidence tooling. | `archive_only` |

## 5. Unique Recoverable Progress

No candidate is marked `recover_into_accepted_branch`.

The only plausible future idea is the capture-tool viewport change from compact
copy-detail captures to a larger `760x1200` copy-detail surface. It is archived
as a future tooling note, not a recovery requirement, because:

- accepted branch already has active-route capture and metadata truth;
- accepted branch keeps text-overlay sidecars used by the current evidence
  workflow;
- recovering only the viewport hunk now would reopen visual evidence scope; and
- no current validation blocker depends on the larger viewport.

Minimal recovery patch: none.
Required tests before main integration: none beyond existing integration
validation.
Regression risk if recovered now: medium tooling/evidence churn.
Before-mainline requirement: no.

## 6. Superseded Work

The following dirty-main work is already represented by accepted branch commits
or stronger later equivalents:

- W7-W12 route/content copy and admission guards.
- Terminal Volume I/W13-not-open route truth.
- Active-route screenshot tooling and final-audit eligibility metadata.
- Daily-goal progress wiring.
- Welcome CTA/copy fix.
- W1 payoff and Sharky/proof coverage.
- Route screenshot tooling guard coverage.

The accepted branch history includes later product work such as premium
milestone motion, product-surface visual gap closure, street replay context,
Sharky visual growth, companion states, later-improvement recognition, and
phrase-tier contracts. Those later commits supersede the dirty-main experiments
where they overlap.

## 7. Contradictory Or Stale Work

Do not apply dirty-main hunks that:

- remove `act0_proof_icon_v1` import/use or collapse proof-icon tests;
- remove W2-W6 and W4-W5 payoff/band-transition structures;
- downgrade the accepted terminal Volume I copy back to seat-label wording;
- remove accepted text-overlay sidecars from route capture tooling; or
- reopen broad shell-preview expectations as a mainline blocker.

These changes conflict with current accepted branch state or current validation
classification.

## 8. Unique Docs Disposition

| File | Purpose | Disposition | Decision |
| --- | --- | --- | --- |
| `docs/_reviews/dirty_worktree_manual_patch_split_v1.md` | Documents the old A/B/C/D patch split and detached validation. | Preservation/reference only. Accepted branch is now the source of truth for the integrated branch. | `archive_only` |
| `docs/_reviews/pre_human_10_10_redesign_decision_addendum_v1.md` | Reclassifies some pre-human visual decisions. | Useful historical design reasoning, but not a current SSOT and not needed before mainline integration. | `archive_only` |
| `docs/_reviews/senior_ux_ui_motion_excellence_audit_v1.md` | Visual/motion audit notes. | Historical local audit; Phase 8 Motion and Sharky Micro-Animations remain separately tracked. | `archive_only` |
| `docs/_reviews/visual_ux_fix_verification_v1.md` | Verification notes for prior visual fixes. | Historical evidence; superseded by accepted branch validation and current preservation/adjudication artifacts. | `archive_only` |
| `docs/_reviews/welcome_review_bounded_pre_human_layout_direction_v1.md` | Welcome/Review layout direction. | Useful future visual follow-up input, but not required before mainline integration. | `archive_only` |
| `docs/_reviews/whole_product_ux_ui_coherence_redesign_ev_audit_v1.md` | Whole-product UI coherence audit and table-felt EV note. | Useful future design reference, not a current integration blocker. | `archive_only` |

## 9. Patch-Split Disposition

| File | Source represented | Finding | Decision |
| --- | --- | --- | --- |
| `00_README.md` | Local patch-split instructions. | Tooling output for a prior manual patch split. | `archive_only` |
| `A_prior_route_content_wave.patch` | W7-W12 route/content/quality wave. | The accepted branch already contains the route/content work in committed form. | `superseded_safe_to_leave_unapplied` |
| `B_visual_ux_known_p1_fix_wave.patch` | Known pre-human visual/copy fixes. | Accepted branch carries the accepted subset; remaining dirty differences are not pre-integration blockers. | `superseded_safe_to_leave_unapplied` |
| `C_route_screenshot_tooling_wave.patch` | Route screenshot tooling and truth-lock guards. | Accepted branch carries active-route tooling/metadata/guards. | `superseded_safe_to_leave_unapplied` |
| `D_focused_visual_ux_upgrade_wave_v2.patch` | Focused visual UX upgrade experiments. | Contains visual experiments and broad shell-preview expectations not admitted for recovery. | `incomplete_experiment_do_not_apply` |
| `PATCH_SPLIT_MANIFEST.json` | Machine-readable patch split manifest. | Local-only preservation metadata. | `archive_only` |

## 10. Recovery Plan

No recovery is required before mainline integration.

Do not apply any dirty-main patch to the accepted branch as part of this lane.
If the owner later reopens visual evidence tooling, consider a fresh, separate
tooling task to evaluate whether active-route copy-detail screenshots should
use a larger viewport while preserving current metadata and overlay guarantees.

## 11. Dirty-Main Release Recommendation

Dirty main can be released after preservation and this adjudication, subject to
the owner approving cleanup mechanics in a separate task.

Recommended next action: proceed to a cleanup/stash/release-main-worktree task
that operates from the preservation package and this adjudication artifact.
Do not recover candidate hunks first.

## 12. Preservation Proof

The zero-loss preservation package records:

- tracked patch: `tracked_changes.patch`;
- staged patch: `staged_changes.patch` (empty, matching zero staged changes);
- tracked classification: `tracked_change_classification.tsv`;
- untracked archive: `untracked_all_paths.tar.gz`;
- untracked manifest: `untracked_manifest.txt`;
- checksum manifest: `checksum_manifest_sha256.txt`;
- archive integrity: previously verified with `gzip -t` and tar readback;
- untracked archive regular files: 222.

The dirty-main worktree remained at
`05bd3fa4da7360d45e6cbf6f72e5804c3a840e40` during this analysis. The accepted
branch started at `4d424a8b6215a9872dd8cfc91fd467271e6e810a`; this artifact is
the only intended accepted-branch change in this task.

## 13. Scope Safety

- No dirty-main file was modified.
- No accepted production code, tests, tools, assets, runtime files, or
  `output/**` files were modified.
- No patch was applied.
- No stash, clean, reset, restore, branch switch, merge, rebase, cherry-pick, or
  push was performed.
- No generated evidence or binary artifact was added to the commit.
- The artifact intentionally avoids secret contents and uses filenames,
  classifications, and semantic summaries only.
