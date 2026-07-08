# Fixed-Build Human QA Baseline Packet v1

Date: 2026-07-09

Terminal verdict: `fixed_build_human_qa_baseline_ready`

## 1. Executive verdict

The admitted screenshot/evidence pipeline repair has been merged to `main`, the final full pre-Human-QA sweep artifact has been integrated as a docs-only artifact, and the fixed-build baseline is ready for a future real Human QA wave.

Human QA was not run. This packet does not claim public readiness, launch readiness, 9.0 readiness, 10/10 quality, durable learning effect, beginner mastery, premium commercial readiness, or Human QA approval.

## 2. Main merge summary

- Reconciled `main` before integration: `4ac0c279678ad5f9a334f2471a751616926851cd`
- Merged implementation branch: `codex/pre-human-qa-screenshot-evidence-pipeline-repair-v2`
- Implementation branch HEAD: `4b7712623c00677373f52c4da7415cb65b08f543`
- Merge commit on `main`: `6b45df05`
- Integrated final sweep artifact commit: `ddffa3e7b84a1ed710caf5f3dd769f0f6c740017`
- Post-sweep docs commit on `main`: `7a769351`

The final sweep branch was not merged wholesale. Only the accepted docs-only final sweep artifact was cherry-picked after confirming it added exactly `docs/_reviews/final_full_pre_human_qa_visual_product_learning_sweep_v1.md`.

## 3. Final fixed-build commit

The final fixed-build commit is the required baseline packet commit on `main` with message `chore: prepare fixed-build Human QA baseline`.

This packet is authored inside that commit; the immutable pushed hash is recorded in the terminal report after commit creation and push.

## 4. Accepted artifact inventory

Accepted artifacts present on merged `main`:

- `docs/_reviews/pre_human_qa_hard_consistency_verification_v1.md`
- `docs/_reviews/pre_human_qa_full_depth_perfection_ledger_v1.md`
- `docs/_reviews/final_pre_human_qa_adversarial_omission_hunt_v1.md`
- `docs/_reviews/pre_human_qa_screenshot_evidence_pipeline_repair_v2.md`
- `docs/_reviews/final_full_pre_human_qa_visual_product_learning_sweep_v1.md`

## 5. Evidence lane status

The repaired evidence lane is present on merged `main`.

- Masked layout lane remains layout-contract-only and records allowed/disallowed claim metadata.
- Real-text lanes support compact and tablet packets.
- Live play decision/table evidence is captured.
- Manifest metadata includes allowed claims, freshness state, current-head matching, and duplicate-hash policy.
- Duplicate screenshot hashes are guarded by explicit duplicate policy instead of being silently accepted.

## 6. Screenshot regeneration status

Post-merge regeneration was executed on merged `main`.

Commands completed:

- `dart run tools/act0_product_100_proof_capture_v1.dart`
- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh core tablet`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh first_week tablet`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh day2_return tablet`
- `./tools/screen_review_fast_v1.sh active_route_w7_w12 compact`
- `./tools/screen_review_fast_v1.sh active_route_w7_w12 tablet`

The real-text regenerated manifests report `matches_current_head: true`, `git_status: clean_or_output_only`, and `git_commit: 7a769351ada68876770e8d3eea403dfd89877ddd`.

Generated files remain local under `output/screen_review/` and are not part of this commit.

## 7. Validation status

Focused validation passed on merged `main`.

- `flutter test test/guards/act0_product_100_proof_capture_tooling_contract_test.dart test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart test/guards/pre_human_qa_screenshot_evidence_pipeline_contract_test.dart test/guards/final_pre_qa_layout_and_proof_repair_contract_test.dart test/guards/w10_w12_grouped_content_repair_contract_test.dart test/guards/w1_w12_poker_correctness_review_contract_test.dart test/guards/w1_w12_answer_position_distribution_contract_test.dart --reporter expanded`: 30 tests passed.
- `flutter analyze`: no issues found.
- `git diff --check`: passed.
- `git diff --cached --check`: passed.
- `graphify hook-check`: passed.

## 8. Human QA capsule status

`docs/context/HUMAN_QA_CAPSULE_v1.md` scopes the current future Human QA candidate chain to W1-W12.

The capsule continues to forbid:

- fake Human QA;
- synthetic participant claims;
- public readiness claims;
- 9.0 or learning-effect claims before real evidence;
- W13+ opening as part of W1-W12 Human QA.

## 9. Claim-safety boundaries

The fixed-build baseline supports only technical readiness for a future Human QA run. It does not support learner-outcome claims.

Allowed claim shape:

- fixed build prepared for Human QA;
- W1-W12 candidate chain technically present;
- screenshot/evidence pipeline repaired and regenerated;
- focused guards and analysis passed.

Disallowed claim shape:

- Human QA passed;
- launch or public readiness;
- 9.0 readiness;
- 10/10 quality;
- durable learning effect;
- beginner mastery;
- premium commercial readiness;
- W13+ activation.

## 10. What Human QA may test

Human QA may test the W1-W12 fixed-build learner chain for:

- first-session comprehension;
- table-signal recognition;
- decision clarity;
- explanation usefulness;
- repair-loop understandability;
- fatigue or pacing issues;
- recall after delay;
- confusion clusters by world, task family, and copy surface.

## 11. What Human QA may not claim

Human QA may not claim:

- broad public readiness from internal technical evidence alone;
- launch readiness without the separate release-side gate;
- durable learning from single-session observation;
- beginner mastery without appropriate longitudinal evidence;
- 10/10 product quality from this packet;
- premium commercial readiness from screenshot or internal guard evidence;
- W13+ readiness or route opening.

## 12. Required Human QA evidence fields

Each real Human QA record should include:

- participant or session id;
- task or concept family;
- user choice;
- expected answer;
- correct or incorrect result;
- error type;
- time to decision;
- confusion note;
- repair or explanation reaction;
- recall result when applicable;
- severity;
- environment and device class;
- tested commit hash.

## 13. Remaining Human-QA-only questions

These questions remain Human-QA-only:

- whether first-time learners understand the fixed-build table signals without prompting;
- whether repair explanations change the next decision;
- whether tablet density feels focused rather than sparse or cramped;
- whether W10-W12 payoff language lands as review and closure instead of mastery;
- whether delayed recall survives beyond immediate correction.

## 14. Remaining future-stage items

Future-stage items remain outside this baseline:

- W13+ route admission;
- broader real-text viewport expansion beyond the regenerated compact/tablet packets;
- store or launch readiness;
- premium commercial readiness;
- longitudinal learning-effect proof;
- Modern Table expansion unless separately admitted;
- release-side regression and public-readiness gates.

## 15. Exact next action

Run a real Human QA wave from the pushed fixed-build `main` baseline. Use real participant/session evidence only. Do not backfill or synthesize Human QA.

## 16. Explicit non-claims

This packet explicitly does not claim:

- Human QA was run;
- Human QA approval;
- public readiness;
- launch readiness;
- 9.0 readiness;
- 10/10 product quality;
- durable learning effect;
- beginner mastery;
- premium commercial readiness;
- W13+ activation.

## 17. Token Efficiency Report

- Reused the accepted repair branch and final sweep artifact instead of reopening prior audit work.
- Verified exact refs before integration.
- Merged only the admitted implementation branch and cherry-picked only the accepted docs-only final sweep artifact.
- Ran focused validation aligned to the mission guard list.
- Kept generated screenshot outputs local and unstaged.
