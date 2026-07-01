# Active Runtime Route-Pack Capture Lane v1

## Verdict

`active_runtime_route_pack_visual_packet_generated`

This wave built and validated an active-runtime screenshot capture lane for W7-W12 route-pack visual coverage.

The generated packet is final visual-audit eligible as active runtime evidence, with this narrow meaning only:

- active surface: `Act0LessonRunnerShellV1`
- capture source policy: `active_act0_runtime_test_only_wrapper`
- generated command: `./tools/screen_review_fast_v1.sh active_route_w7_w12 compact`
- generated packet: `output/screen_review/current/active_route_w7_w12_fast/`
- zip: `output/screen_review/current/active_route_w7_w12_fast/screen_review_active_route_w7_w12_fast.zip`
- contact sheet: `output/screen_review/current/active_route_w7_w12_fast/contact_sheet.png`

This is not a Human-QA-ready, public-readiness, learning-effect, top-1, 10/10, monetization, Practice, Modern Table, mapper, route-logic, W13+, or product-UX change.

## Stage 0 Repo Hygiene

- `HEAD`: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40`
- `origin/main`: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40`
- `main...origin/main`: `0 0`
- Worktree state at entry was dirty from prior admitted waves.
- Generated `output/` artifacts remain local-only and unstaged.
- No staging, commit, push, merge, reset, or checkout was performed.

## Active Capture Design

The new lane captures active W7-W12 route visuals through a test-only wrapper around the active Act0 lesson runner shell.

It does not import or render:

- `lib/archive/legacy_runners/**`
- `World1FoundationsMicroTaskRunnerScreen`

The wrapper imports the active hidden runtime session owners:

- `act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart`
- `act0_w8_draws_hidden_runtime_session_owner_v1.dart`
- `act0_w9_price_hidden_runtime_session_owner_v1.dart`
- `act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart`
- `act0_w11_board_texture_hidden_runtime_session_owner_v1.dart`
- `act0_w12_review_decision_hidden_runtime_session_owner_v1.dart`

Terminal/no-W13 coverage is rendered through the same `Act0LessonRunnerShellV1` wrapper using the existing terminal review pack data. This is evidence for the current terminal-state visual packet only; it does not open W13 or change route logic.

## Tooling Changes

- `tools/screen_review_fast_v1.sh`
  - Added `active_route_w7_w12` as an accepted fast screenshot group.
- `tools/act0_real_text_surface_capture_v1.dart`
  - Added active W7-W12 capture surfaces.
  - Added `_activeRouteFlutterTestSource`.
  - Emits `active_route_w7_w12_meta.json`.
  - Marks active packet metadata as:
    - `visual_audit_validity: active_runtime_visual_evidence`
    - `final_visual_audit_eligible: true`
    - `invalid_for_final_visual_ux_judgment: false`
    - `capture_source_policy: active_act0_runtime_test_only_wrapper`
    - `active_surface: Act0LessonRunnerShellV1`
    - `legacy_archive_runner_used: false`
- `tools/package_screen_review_v1.py`
  - Added `active_route_w7_w12_fast` packaging.
  - Added active audit-policy metadata.
  - Includes `active_route_w7_w12_meta.json` in the zip.
- `tools/package_screen_review_v1.sh`
  - Usage updated for `active_route_w7_w12_fast`.
- `tools/screen_review_active_surface_allowlist_v1.json`
  - Added an explicit allowlist entry for `active_route_w7_w12_fast`.
- `test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart`
  - Added a guard that proves lane registration, active owner imports, active metadata, and archive-runner exclusion.

## Active Route Packet Generated

Command:

```bash
./tools/screen_review_fast_v1.sh active_route_w7_w12 compact
```

Result:

- Passed.
- Output directory: `output/screen_review/current/active_route_w7_w12_fast/`
- Screenshot count: 16 compact screenshots.
- Contact sheet: `contact_sheet.png`.
- Zip: `screen_review_active_route_w7_w12_fast.zip`.
- Text repair: `repaired 0 labels`.

Metadata confirms:

- `visual_audit_validity: active_runtime_visual_evidence`
- `final_visual_audit_eligible: true`
- `invalid_for_final_visual_ux_judgment: false`
- `allowed_use: final_pre_human_visual_ux_audit`
- `capture_source_policy: active_act0_runtime_test_only_wrapper`
- `active_surface: Act0LessonRunnerShellV1`
- `legacy_archive_runner_used: false`
- `content_reflects_latest_post_idealization_copy: true`

## Visual Coverage Matrix Summary

| Surface | Route area | Task index | Kind | Active surface | Legacy runner used |
|---|---|---:|---|---|---|
| `compact.w7_first_route_task_table.png` | 7 | 0 | table | `Act0LessonRunnerShellV1` | false |
| `compact.w7_first_route_task_copy_detail.png` | 7 | 0 | copy detail | `Act0LessonRunnerShellV1` | false |
| `compact.w8_route_task_table.png` | 8 | 0 | table | `Act0LessonRunnerShellV1` | false |
| `compact.w8_route_task_copy_detail.png` | 8 | 0 | copy detail | `Act0LessonRunnerShellV1` | false |
| `compact.w9_first_route_task_table.png` | 9 | 0 | table | `Act0LessonRunnerShellV1` | false |
| `compact.w9_first_route_task_copy_detail.png` | 9 | 0 | copy detail | `Act0LessonRunnerShellV1` | false |
| `compact.w10_route_task_table.png` | 10 | 0 | table | `Act0LessonRunnerShellV1` | false |
| `compact.w10_route_task_copy_detail.png` | 10 | 0 | copy detail | `Act0LessonRunnerShellV1` | false |
| `compact.w11_danger_texture_task_table.png` | 11 | 1 | table | `Act0LessonRunnerShellV1` | false |
| `compact.w11_danger_texture_task_copy_detail.png` | 11 | 1 | copy detail | `Act0LessonRunnerShellV1` | false |
| `compact.w12_first_review_task_table.png` | 12 | 0 | table | `Act0LessonRunnerShellV1` | false |
| `compact.w12_first_review_task_copy_detail.png` | 12 | 0 | copy detail | `Act0LessonRunnerShellV1` | false |
| `compact.w12_payoff_completion_table.png` | 12 | 3 | table | `Act0LessonRunnerShellV1` | false |
| `compact.w12_payoff_completion_copy_detail.png` | 12 | 3 | copy detail | `Act0LessonRunnerShellV1` | false |
| `compact.volume_i_terminal_review_table.png` | terminal | 0 | table | `Act0LessonRunnerShellV1` | false |
| `compact.terminal_no_w13_copy_detail.png` | terminal | 3 | copy detail | `Act0LessonRunnerShellV1` | false |

Pixel sanity:

- 16 active screenshots found.
- Table captures: `750x1624`.
- Copy-detail captures: `1520x2400`.
- All captures have variation in all RGB channels.

## Invalid Evidence Carry-Forward

The prior `route_w7_w12_fast` packet remains invalid for final visual UX judgment.

Carry-forward status:

- `route_w7_w12_fast` is still `legacy_reference_not_for_audit`.
- It remains useful only as route-state smoke/reference evidence.
- It is not replaced by rewriting history or relabeling old artifacts.
- The replacement evidence is the new `active_route_w7_w12_fast` packet generated in this wave.

## Validation Results

Passed:

```bash
flutter test test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart
flutter test test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart test/guards/route_w7_w12_screen_review_tooling_contract_test.dart test/guards/active_route_visual_screenshot_truth_lock_guard_test.dart
flutter test test/guards/w7_route_depth_followup_quality_contract_test.dart test/guards/w8_route_admission_depth_gate_contract_test.dart test/guards/w9_route_admission_depth_gate_contract_test.dart test/guards/w10_route_admission_depth_gate_contract_test.dart test/guards/w11_route_admission_transfer_depth_gate_contract_test.dart test/guards/w12_route_admission_review_payoff_gate_contract_test.dart test/guards/w7_w12_first_use_jargon_contract_test.dart
./tools/screen_review_fast_v1.sh active_route_w7_w12 compact
./tools/screen_review_fast_v1.sh core compact
bash -n tools/screen_review_fast_v1.sh tools/package_screen_review_v1.sh
python3 -m py_compile tools/package_screen_review_v1.py
flutter analyze
git diff --check
git diff --cached --check
graphify hook-check
```

Focused artifact checks:

- `active_route_w7_w12_meta.json`: 16 entries.
- `screen_review_index.json`: 16 files.
- `screen_review_active_route_w7_w12_fast.zip`: includes active metadata, manifest, contact sheet, README, index, and screenshots.

## Forbidden Scope Proof

No changes were made to:

- product UX behavior
- product route logic
- W13+ unlock logic
- mapper/Practice routing
- Modern Table visual system
- monetization or pricing
- public readiness claims
- top-1 or 10/10 claims
- learning-effect claims

The active wrapper is screenshot tooling only. It uses active runtime owners and `Act0LessonRunnerShellV1` for visual evidence generation.

## Deferred Scope Register

- Human QA is not authorized by this artifact.
- Public/store readiness is not authorized by this artifact.
- Top-1 or 10/10 product claims are not authorized by this artifact.
- Visual UX scoring is not performed here; this only creates the active runtime evidence packet for a downstream audit.

## Token/Time Report

- Context route: screenshot/evidence tooling lane.
- Broad repo read avoided.
- Primary command runtime: active packet capture completed in about 8 seconds of Flutter test time.
- Secondary smoke: core packet capture completed in about 2 seconds of Flutter test time.
- Analyzer runtime: about 14 seconds.

## Next Chat Handover

Use the new active packet for downstream visual audit:

```bash
output/screen_review/current/active_route_w7_w12_fast/
```

Recommended next prompt:

`Run Full Pre-Human Visual UX Audit on active_route_w7_w12_fast v1`

Hard carry-forward:

- Treat `route_w7_w12_fast` as invalid for final visual UX judgment.
- Use `active_route_w7_w12_fast` as the active-runtime route-pack visual evidence source.
- Do not claim Human-QA-ready, public readiness, learning effect, top-1, or 10/10 status from this capture lane alone.
