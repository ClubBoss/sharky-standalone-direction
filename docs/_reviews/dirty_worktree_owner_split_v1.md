---
status: "owner_split_plan_ready_with_c_assertion_fix"
status_source: "derived"
doc_date: "2026-07-02"
baseline: "05bd3fa4da73"
generated_by: "docs_frontmatter_v1"
---

# Dirty Worktree Owner Split v1

Date: 2026-07-02
Branch: `main`
Mode: repo hygiene / patch ownership / bounded validation only

## 1. Verdict

`owner_split_plan_ready_with_c_assertion_fix`

All dirty product, test, tool, review, and generated-output paths have an owner bucket. The three stale C-owned screen-review usage assertions were mechanically aligned to the accepted route-group list and now pass. No product behavior changed.

The ownership plan is actionable, but the worktree is not physically split: four tracked files require sequential manual patches because later D hunks depend on B/C context, and the mixed untracked active-route guard needs a constructed C base before its D test is added. No safe automatic owner patch was written under the current no-staging/no-checkout/no-reset contract.

## 2. Stage 0 Status

- HEAD: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40`
- `origin/main`: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40`
- Branch: `main`
- Divergence `main...origin/main`: `0 0`
- Dirty tracked files at entry: 23
- Untracked files at entry: 209 total: 190 under `output/`, 13 review docs, 5 tests, and 1 tool allowlist
- Relevant non-generated untracked files at entry: 19
- Staged files: 0
- Output status: `output/claude_review/`, `output/motion_evidence/`, `output/motion_media/`, and `output/screen_review/` are untracked
- Generated output remains local-only and unstaged. No packet was opened one screenshot at a time, regenerated, deleted, or modified.
- Stop gates: none. Branch/remote truth is clean, the prior audit exists, no staged files exist, and no unknown owner appeared.

## 3. Hunk Ownership Map

### `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`

| Current anchor | Bucket | Reason | Dependency | Validation | Separability |
| --- | --- | --- | --- | --- | --- |
| `Act0BlockCompletionSummaryV1.worldOneCompletionPathLabel`, near line 431 | B | Replaces the 36-world completion claim with bounded Volume I copy | World-1 completion payoff test | `act0_world1_completion_payoff_v1_test.dart` | clean |
| `Act0BlockCompletionSummaryV1.unlockLabel`, near line 601 | B | Removes threshold/next-lesson anxiety copy | Known-P1 guard and block-summary lock test | exact block-summary test | clean |
| `Act0BlockCompletionShellV1.build` scroll padding, near lines 5821-5827 | D | GR-08 reserves bottom-nav clearance | Existing shell tokens; independent of B text | Session Summary suite and visual/full-scroll verification | clean |
| Summary accuracy text pluralization, near line 6255 | B | Singular-safe `error`/`errors` text | B test expectation near `Block summary exposes mastery...` | block-summary focused tests | clean |

### `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`

| Current anchor | Bucket | Reason | Dependency | Validation | Separability |
| --- | --- | --- | --- | --- | --- |
| `_Act0WelcomeShellV1State` handoff detail and CTA, near lines 128-147 | B | Known-P1 first-lesson copy correction | Matching Welcome test copy assertions | exact Welcome handoff test | clean |
| `_WelcomeTextBeatV1.build`: `centerContent`, extracted `beatFrame`, and conditional `Flexible`/scroll layout, near lines 187-246 excluding outer-column alignment | B | Known-P1 loose layout removes forced empty zone while preserving scroll | Must land before D because D consumes `centerContent` | exact Welcome handoff test | manual patch needed |
| Outer `Column.mainAxisAlignment`, near lines 224-226 | D | GR-06 centers only the final handoff composition | Requires B-owned `centerContent` | Welcome handoff geometry assertion | manual patch needed; apply after B |

### `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

| Current anchor | Bucket | Reason | Dependency | Validation | Separability |
| --- | --- | --- | --- | --- | --- |
| Three `Fast screen review command exposes ...` usage expectations, near lines 2975, 3025, 3076 | C | Assertions own the accepted screenshot command group list | C-owned `screen_review_fast_v1.sh` | exact three tests | clean; corrected in this wave |
| `Review-phase feedback panel renders a non-empty CTA label`, near line 5623 | D | GR-03 proves live CTA text is non-empty | Active runner shell; no capture-tool fix | exact GR-03 test | clean |
| `Welcome completes one local micro win...`: first-lesson copy assertions, near lines 11566-11578 | B | Matches B handoff copy | B Welcome source | exact Welcome handoff test | manual patch needed within shared test hunk |
| Same Welcome test: frame-to-CTA geometry assertion, near lines 11579-11585 | D | Verifies bounded GR-06 layout | B Welcome layout must exist first | exact Welcome handoff test | manual patch needed; apply after B |
| `Block summary locks continue...`, near lines 16137-16169 | B | Known-P1 threshold/claim-safety expectation | B summary copy | exact block-summary lock test | clean |
| `Block summary exposes mastery...`: no-unlock copy and singular error assertions, near lines 30187 and 30210 | B | Matches B claim-safety/pluralization hunks | B summary source and stable test state | targeted expectation follow-up remains | clean as an owner slice |
| Existing `Home keeps the global top bar visible` | D validation only | Validates GR-09, but has no new dirty hunk | D top-bar source | exact test | n/a |

### `tools/act0_real_text_surface_capture_v1.dart`

| Current anchor | Bucket | Reason | Dependency | Validation | Separability |
| --- | --- | --- | --- | --- | --- |
| Legacy validity constants and route capture model/surfaces, lines 6-210 | C | Legacy route packet and invalidity ownership | Truth-lock guard | route tooling guards | clean conceptually |
| Active capture surfaces and `main` routing/manifest branches, lines 211-420 | C | Registers active route packet and metadata | A route packs/owners | active-route guard | clean conceptually |
| `_activeRouteFlutterTestSource`, lines 788-1316 excluding the two D anchors below | C | Builds active Act0 wrapper, capture entries, and metadata | A route source and active shell | active-route guard and future packet smoke | manual patch needed |
| `humanRepairFocusLabelForConceptFamily`, lines 893-913 | D | GR-01/02 curated learner-facing label mapping | C active wrapper | active label guard | manual patch needed; apply after C |
| `repairFocusLabels` call through the human label mapper, lines 936-939 | D | Stops raw internal concept-family IDs entering copy-detail evidence | D mapping function and C wrapper | active label guard | manual patch needed; apply after C |
| `_routeFlutterTestSource` and `_printUsageV1`, lines 1317-1625 | C | Legacy smoke lane and accepted group list | C scripts/packager | route tooling guards and syntax checks | clean conceptually |

### `test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart`

| Current anchor | Bucket | Reason | Dependency | Validation | Separability |
| --- | --- | --- | --- | --- | --- |
| Tests at lines 7-78, metadata test at 140-175, and `_activeRouteSection` helper at 178-187 | C | Active lane registration, archive exclusion, metadata, and shared section extraction | C capture/packaging/allowlist | full guard file | manual patch needed because file is untracked |
| `active W7-W12 copy-detail feedback never renders raw internal concept-family ids`, lines 80-138 | D | GR-01/02 mapping and raw-ID rejection | C base file/helper and D capture mapper | full guard file | manual patch needed; append after C base |

All five mixed files have explicit owner anchors. None is intrinsically inseparable, but four need sequential B/C then D patch construction; the lesson-runner hunks are independently clean.

## 4. Grouping Plan

Commit dependency order: A, then B, then C, then D. C depends on A route owners. D depends on B layout/copy context and C active capture context. E is never committed.

### A. `prior_accepted_route_or_content_wave`

Files:

- `lib/campaign/campaign_pack_registry_v1.dart`
- `lib/canonical/canonical_truth_map_v1.dart`
- `lib/services/progress_service.dart`
- `test/guards/w7_route_depth_followup_quality_contract_test.dart`
- `test/guards/w8_route_admission_depth_gate_contract_test.dart`
- `test/guards/w9_route_admission_depth_gate_contract_test.dart`
- `test/guards/w10_route_admission_depth_gate_contract_test.dart`
- `test/guards/w11_route_admission_transfer_depth_gate_contract_test.dart`
- `test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`
- `test/guards/w7_w12_first_use_jargon_contract_test.dart`
- `docs/_reviews/full_w1_w12_e2e_curriculum_product_quality_gate_v1.md`
- `docs/_reviews/volume_i_10_10_gap_register_pre_human_idealization_plan_v1.md`
- `docs/_reviews/volume_i_e2e_curriculum_product_quality_gate_planning_v1.md`
- `docs/_reviews/volume_i_pre_human_qa_actionable_gap_repair_p2_adjudication_pack_v1.md`
- `docs/_reviews/volume_i_small_pre_human_copy_bridge_idealization_wave_v1.md`
- `docs/_reviews/volume_i_w7_w12_first_use_jargon_audit_v1.md`

Source artifacts: the six A review docs above. Risk: route/content semantics must move atomically. Safe for a future commit after independent route validation.

Validation:

```bash
flutter test test/guards/w7_route_depth_followup_quality_contract_test.dart test/guards/w8_route_admission_depth_gate_contract_test.dart test/guards/w9_route_admission_depth_gate_contract_test.dart test/guards/w10_route_admission_depth_gate_contract_test.dart test/guards/w11_route_admission_transfer_depth_gate_contract_test.dart test/guards/w12_route_admission_review_payoff_gate_contract_test.dart test/guards/w7_w12_first_use_jargon_contract_test.dart test/guards/world_campaign_routing_matrix_contract_test.dart
flutter analyze
graphify hook-check
```

### B. `visual_ux_known_p1_fix_wave`

Whole files:

- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `test/ui_v2/act0_world1_completion_payoff_v1_test.dart`
- `test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`
- `test/guards/act0_visual_ux_known_p1_copy_contract_test.dart`
- `docs/_reviews/full_pre_human_visual_ux_evidence_coverage_known_p1_fix_wave_v1.md`

Mixed hunks: the B anchors in lesson runner, Welcome, and shell-preview test listed in section 3. Source artifact: known-P1 fix artifact. Risk: Welcome and shell-test patches must be constructed before D overlays. Safe for a future commit after manual split and focused validation.

Validation:

```bash
flutter test test/guards/act0_visual_ux_known_p1_copy_contract_test.dart test/ui_v2/act0_world1_completion_payoff_v1_test.dart test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Welcome completes one local micro win before Home handoff|Block summary locks continue below accuracy threshold'
flutter analyze
```

### C. `route_screenshot_tooling_wave`

Whole files:

- `tools/package_screen_review_v1.py`
- `tools/package_screen_review_v1.sh`
- `tools/screen_review_fast_v1.sh`
- `tools/screen_review_active_surface_allowlist_v1.json`
- `test/guards/route_w7_w12_screen_review_tooling_contract_test.dart`
- `test/guards/active_route_visual_screenshot_truth_lock_guard_test.dart`
- `docs/_reviews/route_w7_w12_screenshot_tooling_coverage_v1.md`
- `docs/_reviews/active_route_visual_screenshot_truth_lock_w7_w12_capture_repair_v1.md`
- `docs/_reviews/active_runtime_route_pack_capture_lane_v1.md`
- `docs/_reviews/full_pre_human_visual_ux_audit_v2_10_10_gap_register_v1.md`

Mixed hunks: the C anchors in shell-preview test, capture tool, and active-route guard. Source artifacts: route tooling, truth lock, and active capture lane artifacts. Risk: active capture depends on A route owners; the active guard is untracked and must first be materialized without its D label test. Safe for a future commit after manual split.

Validation:

```bash
flutter test test/guards/route_w7_w12_screen_review_tooling_contract_test.dart test/guards/active_route_visual_screenshot_truth_lock_guard_test.dart test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Fast screen review command exposes'
bash -n tools/screen_review_fast_v1.sh tools/package_screen_review_v1.sh
PYTHONPYCACHEPREFIX=/tmp/sharky-c-pycache python3 -m py_compile tools/package_screen_review_v1.py
graphify hook-check
```

Packet smoke commands belong to future C preparation and were intentionally not run here because this wave forbids packet regeneration:

```bash
./tools/screen_review_fast_v1.sh active_route_w7_w12 compact
./tools/screen_review_fast_v1.sh core compact
```

### D. `focused_visual_ux_upgrade_wave_v2`

Whole files:

- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `docs/_reviews/focused_pre_human_visual_ux_upgrade_wave_v2.md`
- `docs/_reviews/post_visual_ux_upgrade_repo_hygiene_readiness_diff_audit_v1.md`
- `docs/_reviews/dirty_worktree_owner_split_v1.md`

Mixed hunks: the D anchors in lesson runner, Welcome, shell-preview test, capture tool, and active-route guard. Source artifact: focused Visual/UX upgrade artifact plus the two post-wave hygiene/control artifacts. Risk: D must be based on completed B and C groups. Safe for a future commit only after manual split and Visual UX Fix Verification.

Validation:

```bash
flutter test test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_review_shell_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Review-phase feedback panel renders a non-empty CTA label|Welcome completes one local micro win before Home handoff|Profile shows Sharky proof identity and encouraging completion line|Home keeps the global top bar visible|Block summary locks continue below accuracy threshold'
flutter test test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart
flutter analyze
graphify hook-check
```

Relevant packet regeneration remains optional and must be explicitly admitted later; it was not performed in this owner-split wave.

### E. `generated_local_output`

- `output/claude_review/**`
- `output/motion_evidence/**`
- `output/motion_media/**`
- `output/screen_review/**`

These paths remain untracked/local-only and must never be staged or committed.

### Manual Patch Construction Handoff

Automatic physical extraction is unsafe under the current constraints because normal interactive hunk selection uses the index and the later D patches require sequential B/C bases. The next wave may create review snapshots without altering the worktree:

```bash
git diff --binary -- lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart test/ui_v2/act0_shell_preview_screen_v1_test.dart tools/act0_real_text_surface_capture_v1.dart > /tmp/sharky_mixed_tracked_full.patch
git diff --unified=80 -- lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart test/ui_v2/act0_shell_preview_screen_v1_test.dart tools/act0_real_text_surface_capture_v1.dart > /tmp/sharky_mixed_tracked_review.patch
git diff --no-index --binary /dev/null test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart > /tmp/sharky_active_guard_full.patch || test $? -eq 1
```

Those snapshots still require manual curation using the anchors in section 3. No owner-specific patch should be applied until `git apply --check` succeeds against its intended sequential base.

## 5. Optional Corrections Performed

Changed only `test/ui_v2/act0_shell_preview_screen_v1_test.dart` at three C-owned assertions.

Old expectation:

```text
<core|runner|first_week|day2_return|profile_evidence|full_scroll> compact
```

New accepted expectation:

```text
<core|runner|first_week|day2_return|profile_evidence|full_scroll|route_w7_w12|active_route_w7_w12> compact
```

This is mechanical and C-owned because it changes only test literals to match the already-accepted script usage string. Screenshot behavior, packaging behavior, product code, and generated output did not change. The exact three tests failed before the edit and passed after it.

## 6. Known Failure Status

| Failure | Prior classification | Owner bucket | Current classification | Recommended next action |
| --- | --- | --- | --- | --- |
| `Fast screen review command exposes first-week proof packet group` | pre-existing dirty-worktree failure | C | `resolved_by_C_assertion_update` | Include correction in C patch |
| `Fast screen review command exposes Day 2 return proof packet group` | pre-existing dirty-worktree failure | C | `resolved_by_C_assertion_update` | Include correction in C patch |
| `Fast screen review command exposes full-scroll evidence group` | pre-existing dirty-worktree failure | C | `resolved_by_C_assertion_update` | Include correction in C patch |
| `Final lesson retry replays the miss before summary and can end as a quick fix` | pre-existing dirty-worktree failure | A/B accepted baseline, not D | `still_pre_existing_A_or_B_or_C_failure` | Classify in manual split; do not fix here |
| `Review repair session returns with a fixed summary` | pre-existing dirty-worktree failure | A/B accepted baseline, not D | `still_pre_existing_A_or_B_or_C_failure` | Classify in manual split; do not fix here |
| `Block summary exposes mastery and suggested next action` | pre-existing dirty-worktree failure | B test/source seam | `still_pre_existing_A_or_B_or_C_failure` | Targeted expectation/state follow-up after B isolation |

The remaining failures were reproduced after the C correction and were not modified. None was introduced by this owner-split wave.

## 7. Validation Results

| Command | Result | Classification |
| --- | --- | --- |
| Three exact stale C tests before correction | failed 3/3 on old six-group literal | expected RED; root cause confirmed |
| Same three exact tests after correction | passed 3/3 | `resolved_by_C_assertion_update` |
| Three exact non-tooling known failures | failed with the same three names | `still_pre_existing_A_or_B_or_C_failure` |
| `flutter analyze` | pass; no issues, 14.2s | owner-split edit analyzable |
| Route/active/truth-lock guard set | pass; 7 tests | C tooling contract intact |
| Known-P1 + Practice + Review + Session Summary suites | pass; 51 tests | B/D bounded seams intact |
| C assertions plus five latest UX shell checks | pass; 8 tests | C correction and D checks pass |
| Shell syntax and Python compile checks | pass | C tooling syntax intact |
| `git diff --check` | pass | no whitespace error |
| `git diff --cached --check` | pass | staged set remains empty |
| `graphify hook-check` | pass | graph hook state acceptable |

No full suite was run. This owner-split introduced no net-new failure. No screenshot packet was regenerated.

## 8. Recommended Next Step

`Dirty Worktree Manual Patch Split v1`

Ownership is clear, but Visual UX Fix Verification should operate on an isolated D patch rather than the current aggregate worktree. Construct and `git apply --check` sequential A/B/C/D patches without staging or applying them unless separately authorized. After that split is reviewable, run `Visual UX Fix Verification v1`.

## 9. Agent Recommendation

Use Codex for the next manual patch-split wave. It is a mechanical diff-construction and validation task. Use Claude Sonnet for the later short visual verification once D is isolated. Use Fable only if that clean verification leaves a systemic coherence question.

## 10. Claim Safety

- No readiness score movement.
- No top-1/10/10 claim.
- No premium/public/launch readiness claim.
- No Human-QA-ready claim.
- No Human QA pass.
- No public learning-effect claim.
- No monetization readiness claim.
- W13+ remains blocked.
- Mapper/Practice remains blocked.
- Modern Table remains maintenance-only.
- No product UX fix, route change, staging, commit, push, reset, checkout, stash, history rewrite, or output mutation occurred.

## 11. Next Chat Handover

- Verdict: `owner_split_plan_ready_with_c_assertion_fix`
- Artifact: `docs/_reviews/dirty_worktree_owner_split_v1.md`
- HEAD: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40`
- Validation: analyzer, 66 bounded tests, syntax checks, diff checks, and graph hook pass
- Hunk split: all five mixed files mapped; lesson runner is cleanly separable; Welcome, shell test, capture tool, and untracked active guard need sequential manual patches
- Optional correction: three C-owned stale usage assertions updated and passing
- Known failures: three C failures resolved; three pre-existing non-tooling failures remain classified and untouched
- Recommended prompt: `Dirty Worktree Manual Patch Split v1`
- Recommended agent: Codex
- Forbidden next scope: product UX fixes, Human QA, W13+, mapper/Practice expansion, monetization, Modern Table polish, broad redesign, new design system, animation/badge/XP economy, W3/W6 richness, W12 synthesis, cross-world repair, or readiness/public claims
- Context note: repo-hygiene and exact mixed-file lane only; generated screenshots were not inspected individually or regenerated
- Time note: analyzer 14.2s; C RED reproduction 6.8s; remaining known-failure reproduction 8.7s; bounded validation approximately 27s; token telemetry unavailable
