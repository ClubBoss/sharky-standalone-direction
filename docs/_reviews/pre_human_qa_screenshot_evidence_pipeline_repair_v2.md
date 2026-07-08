# Pre-Human-QA Screenshot Evidence Pipeline Repair v2

## 1. Executive verdict

Terminal verdict: `screenshot_pipeline_repair_complete_ready_for_final_full_sweep`

The screenshot/evidence pipeline is repaired for the next final full pre-Human-QA visual/product/copy/learning-readiness sweep. Human QA was not run. This artifact does not claim public readiness, launch readiness, 10/10 product quality, durable learning effect, beginner mastery, or Human QA approval.

## 2. Repository and branch/main reconciliation

- Repository: `/Users/elmarsalimzade/Sharky_1.0`
- Starting main HEAD: `7e9e783a255c2a421bea7a307519f1d5a02285c4`
- Reconciled main HEAD: `4ac0c279678ad5f9a334f2471a751616926851cd`
- Implementation branch: `codex/pre-human-qa-screenshot-evidence-pipeline-repair-v2`
- Main reconciliation: docs-only accepted artifacts were cherry-picked onto `main`, validated with `git diff --check` and `graphify hook-check`, then pushed.
- Implementation branch base: reconciled `main` at `4ac0c279678ad5f9a334f2471a751616926851cd`

## 3. Accepted review artifacts available on main

Present from implementation context:

- `docs/_reviews/pre_human_qa_hard_consistency_verification_v1.md`
- `docs/_reviews/pre_human_qa_full_depth_perfection_ledger_v1.md`
- `docs/_reviews/final_pre_human_qa_adversarial_omission_hunt_v1.md`

## 4. Evidence baseline before repair

- `act0_product_100_proof` existed as a masked four-viewport layout packet but did not clearly prevent copy/content/product-readiness use.
- `play` proof could be confused with non-runner proof because live runner semantics were not asserted.
- Real-text fast packets were compact-only for the active final-sweep use case.
- Real-text manifests did not carry enough lane authority, allowed-claims, freshness, duplicate-hash, or unsupported-viewport metadata.
- `HUMAN_QA_CAPSULE_v1.md` still framed Human QA around W1-W6 instead of the current W1-W12 pre-Human-QA candidate scope.

## 5. Screenshot pipeline repairs performed

- Preserved the masked 4 viewport x 13 surface product-100 packet.
- Marked masked product-100 as `layout_contract` and `nonliteral_preview_contract`.
- Added per-entry and manifest allowed/disallowed claim metadata.
- Repaired `play` capture to use a live `runnerDrill` decision/table state.
- Added product-proof byte guards for `play` vs `home` and W12 terminal vs `play`.
- Added compact and tablet real-text packet support.
- Added `learn_detail` to the real-text core packet.
- Added per-entry source/debug metadata, current commit metadata, semantic assertions, and duplicate-hash policy.
- Updated packaging to read the manifest device and package tablet packets correctly.
- Updated text repair to support compact and tablet overlay repair.
- Updated Human QA capsule authority to W1-W12 current candidate scope while preserving no-fake-QA and no-public-readiness boundaries.

## 6. Masked layout-contract lane proof

Generated:

- Command: `dart run tools/act0_product_100_proof_capture_v1.dart`
- Output: `output/screen_review/current/act0_product_100_proof/`
- Manifest lane: `layout_contract`
- Render kind: `nonliteral_preview_contract`
- `is_real_text`: `false`
- Entries: `52`
- Duplicate policy: `disallow_unlisted_duplicates`
- `play_home_byte_comparison.all_play_images_differ_from_home`: `true`
- `terminal_play_byte_comparison.all_terminal_images_differ_from_play`: `true`

Allowed claims are limited to layout, geometry, safe area, CTA placement, spacing, and surface identity.

## 7. Real-text product-proof lane proof

Generated local-only packets:

- `core_fast` / `core_tablet_fast`
- `first_week_fast` / `first_week_tablet_fast`
- `day2_return_fast` / `day2_return_tablet_fast`
- `active_route_w7_w12_fast` / `active_route_w7_w12_tablet_fast`

Each manifest marks:

- `lane_type`: `real_text_product_proof`
- `render_kind`: `flutter_widget_test_real_text`
- `is_real_text`: `true`
- `matches_current_head`: `true` at generation time
- `allowed_claims`: copy, content clarity, tone, readability, feedback quality, payoff quality, product-readiness evidence, surface identity

Screenshot outputs remain local-only under `output/screen_review/` and were not staged.

## 8. `play` live decision/table proof

The product-100 `play` capture now targets `Act0ControlledDemoCaptureSurfaceV1.runnerDrill` with a live W1 runner task. The generated test asserts:

- `act0_shell_runner_screen`
- `act0_shell_runner_prompt_panel_compact_*`
- `act0_shell_runner_action_dock`
- `act0_shell_table`
- no bottom nav during runner capture

`play` is also byte-checked against `home` and must differ.

## 9. W12 terminal/no-W13 preservation

The masked lane keeps W12 terminal proof distinct from `play`. Active W7-W12 real-text packets include:

- `w12_payoff_completion_table`
- `w12_payoff_completion_copy_detail`
- `volume_i_terminal_review_table`
- `terminal_no_w13_copy_detail`

W13 activation was not added.

## 10. Manifest/allowed-claims metadata

Manifest/entry metadata now includes lane type, render kind, real-text flag, viewport/device, surface identity, path, bytes, SHA-256, git commit, git status, current-head match flag, allowed claims, unsupported/disallowed claims, semantic assertions, debug/source route, and capture-source policy.

Masked-lane disallowed claims explicitly include copy, content, tone, product readiness, premium readiness, learning depth, payoff quality, and repair personalization.

## 11. Freshness/current-HEAD enforcement

Real-text manifests record `git_commit`, `git_status`, and `matches_current_head`.

Generation in this implementation wave reported `git_status: dirty` because the screenshots were generated from uncommitted in-wave tooling changes while output artifacts remained untracked. This is intentionally not Human QA proof. Reports may cite these outputs only as local pipeline validation evidence unless regenerated after the implementation commit with `clean_or_output_only`.

## 12. Duplicate-hash policy

Duplicate hash policy is present for masked and real-text lanes.

- Masked lane: unlisted duplicates fail.
- Real-text lane: unlisted duplicates fail.
- Intentional allowlist: `repair_focus|session_repair`, because both labels currently render the same wrong-outcome repair proof state until a future product-specific session-repair fixture is admitted.

Observed real-text duplicate counts:

- `first_week_fast`: 1 allowlisted duplicate
- `first_week_tablet_fast`: 1 allowlisted duplicate
- All other generated real-text packets: 0 duplicates

## 13. Real-text coverage map

Compact and tablet real-text coverage exists for:

- placement: `first_week_*`
- welcome: `first_week_*`
- Home: `core_*`
- Learn: `core_*`
- lesson detail: `core_*`
- decision/play: `first_week_*`
- correct feedback: `first_week_*`
- wrong feedback: `first_week_*`
- practice repair: `day2_return_*`
- completion payoff/session summary: `first_week_*`, `active_route_w7_w12_*`
- review/profile: `core_*`, `first_week_*`
- W11 transfer: `active_route_w7_w12_*`
- W12 payoff: `active_route_w7_w12_*`
- W12 terminal/no-W13: `active_route_w7_w12_*`

Generated entry counts:

- `core_fast`: 6
- `core_tablet_fast`: 6
- `first_week_fast`: 13
- `first_week_tablet_fast`: 13
- `day2_return_fast`: 5
- `day2_return_tablet_fast`: 5
- `active_route_w7_w12_fast`: 16
- `active_route_w7_w12_tablet_fast`: 16

## 14. Unsupported claims map

Real-text manifests explicitly mark unsupported claims for missing viewports:

- compact packets do not support tablet real-text claims.
- tablet packets do not support compact-phone real-text claims.
- both packet types mark tall-phone and large-phone real-text claims unsupported in this wave.
- no packet supports Human QA approval, public readiness, launch readiness, 10/10 claims, durable learning effect, or beginner mastery.

## 15. Tablet welcome status

No new product-layout code was required in this wave. Existing `final_pre_qa_layout_and_proof_repair_contract_test.dart` passed, including:

- tablet welcome uses a wide content frame while compact stays bounded.

Status: no remaining tablet-welcome pipeline blocker found by focused guard evidence.

## 16. Practice repair density status

No new product-layout code was required in this wave. Existing `final_pre_qa_layout_and_proof_repair_contract_test.dart` passed, including:

- practice repair runner fills the tablet gap between table and dock.

Status: no remaining practice-repair pipeline blocker found by focused guard evidence.

## 17. Human QA capsule status

`docs/context/HUMAN_QA_CAPSULE_v1.md` now scopes the current Human QA candidate chain to W1-W12. It preserves:

- no fake QA
- no synthetic participants
- no public/launch-readiness claim
- no W13+ opening as part of W1-W12 Human QA

## 18. DCA-004/DCA-007/DCA-008 arbitration status

Conflict preserved:

- Claude ledger classified DCA-004/DCA-007/DCA-008 as verify-before-Human-QA provenance gaps.
- Codex omission hunt classified them as already covered/repaired.

This wave did not broadly rewrite content. Bounded source verification was run through W10-W12 grouped repair and W1-W12 poker correctness guards. Current status: `reject_with_evidence_for_current_guarded_source_contracts`, while the historical ledger conflict remains documented for the final full sweep.

## 19. Validation commands and results

Branch/status:

- `git status --short --branch`: implementation branch with tracked implementation changes and local-only `output/screen_review/`.
- `git log --oneline --decorate -10`: reconciled main and branch at `4ac0c279` before implementation commit.

Screenshot/proof generation:

- `dart run tools/act0_product_100_proof_capture_v1.dart`: passed.
- `./tools/screen_review_fast_v1.sh core compact`: passed.
- `./tools/screen_review_fast_v1.sh core tablet`: passed.
- `./tools/screen_review_fast_v1.sh first_week compact`: passed.
- `./tools/screen_review_fast_v1.sh first_week tablet`: passed.
- `./tools/screen_review_fast_v1.sh day2_return compact`: passed.
- `./tools/screen_review_fast_v1.sh day2_return tablet`: passed.
- `./tools/screen_review_fast_v1.sh active_route_w7_w12 compact`: passed.
- `./tools/screen_review_fast_v1.sh active_route_w7_w12 tablet`: passed.

Focused tests:

- `flutter test test/guards/act0_product_100_proof_capture_tooling_contract_test.dart test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart test/guards/pre_human_qa_screenshot_evidence_pipeline_contract_test.dart test/guards/final_pre_qa_layout_and_proof_repair_contract_test.dart test/guards/w10_w12_grouped_content_repair_contract_test.dart test/guards/w1_w12_poker_correctness_review_contract_test.dart --reporter expanded`: `+28`, all tests passed.

Static/hygiene:

- `flutter analyze`: no issues found.
- `git diff --check`: passed.
- `graphify hook-check`: passed.

## 20. Remaining fix-before-Human-QA ledger

No new screenshot-pipeline fix-before-Human-QA item remains from this wave.

Product readiness is still not claimed. Human QA remains not run.

## 21. Remaining verify-before-Human-QA ledger

Remaining verification before Human QA:

- final full pre-Human-QA visual/product/copy/learning-readiness sweep using the repaired evidence lanes.
- optional post-commit regeneration of local screenshot outputs so real-text manifests report `clean_or_output_only` instead of dirty in-wave generation.
- carry the DCA arbitration note into the final sweep record.

## 22. Whether final full sweep can now run

Yes. The final full sweep can now run with the repaired screenshot/evidence pipeline.

Limitations:

- real-text viewport proof is compact + tablet only.
- tall-phone and large-phone real-text product claims remain unsupported unless generated in a later packet.
- masked screenshots remain layout-contract only.

## 23. Exact next action

Run the final full pre-Human-QA visual/product/copy/learning-readiness sweep against the repaired pipeline. Do not run Human QA until that sweep explicitly admits it.

## 24. Explicit non-claims

This artifact does not claim:

- Human QA approval
- public readiness
- launch readiness
- 10/10 product quality
- durable learning effect
- beginner mastery
- W13+ activation
- broad W1-W12 content rewrite

## 25. Token Efficiency Report

- Used accepted review artifacts as the controlling scope instead of reopening a broad audit.
- Preserved masked product-100 and repaired its authority metadata instead of replacing it.
- Added compact + tablet real-text coverage rather than attempting all four viewports in one wave.
- Used focused guards and generated packet manifests for proof.
- Kept screenshot outputs local-only and unstaged.
