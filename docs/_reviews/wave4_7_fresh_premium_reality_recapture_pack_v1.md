# Wave 4.7 - Fresh Premium Reality Recapture Pack v1

## 1. Verdict

fresh_premium_reality_recapture_pack_ready

## 2. HEAD hash

- Capture base HEAD: `fa7d7b4ab6f7879bd680e10da0753ca08590f1b7`
- Latest accepted wave before recapture: Wave 4.6 - Practice Review Active-State & Public Screenshot Curation v1
- Latest accepted verdict before recapture: `wave4_6_practice_review_screenshot_curation_ready`

## 3. Packets run

- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh runner compact`
- `./tools/screen_review_fast_v1.sh profile_evidence compact`

All packet commands completed successfully.

## 4. Output paths

- `output/screen_review/current/day2_return_fast/`
  - `contact_sheet.png`
  - `screen_review_day2_return_fast.zip`
  - `screen_review_index.json`
- `output/screen_review/current/first_week_fast/`
  - `contact_sheet.png`
  - `screen_review_first_week_fast.zip`
  - `screen_review_index.json`
- `output/screen_review/current/full_scroll_fast/`
  - `contact_sheet.png`
  - `screen_review_full_scroll_fast.zip`
  - `screen_review_index.json`
  - `full_scroll_meta.json`
- `output/screen_review/current/core_fast/`
  - `contact_sheet.png`
  - `screen_review_core_fast.zip`
  - `screen_review_index.json`
- `output/screen_review/current/runner_fast/`
  - `contact_sheet.png`
  - `screen_review_runner_fast.zip`
  - `screen_review_index.json`
- `output/screen_review/current/profile_evidence_fast/`
  - `contact_sheet.png`
  - `screen_review_profile_evidence_fast.zip`
  - `screen_review_index.json`

## 5. Motion evidence paths

Command run:

- `dart run tools/act0_motion_evidence_capture_v1.dart`

Output root:

- `output/motion_evidence/current/`

Frames:

- `decision_feedback_reveal_frame_000ms.png`
- `decision_feedback_reveal_frame_080ms.png`
- `decision_feedback_reveal_frame_180ms.png`
- `decision_feedback_reveal_frame_320ms.png`
- `repair_result_fix_landed_frame_000ms.png`
- `repair_result_fix_landed_frame_080ms.png`
- `repair_result_fix_landed_frame_180ms.png`
- `repair_result_fix_landed_frame_320ms.png`
- `session_summary_proof_hero_frame_000ms.png`
- `session_summary_proof_hero_frame_080ms.png`
- `session_summary_proof_hero_frame_180ms.png`
- `session_summary_proof_hero_frame_320ms.png`
- `manifest.json`

## 6. Local-only generated outputs confirmation

- Generated screen packets remain local-only under `output/screen_review/current/`.
- Generated motion evidence remains local-only under `output/motion_evidence/current/`.
- Generated outputs were not staged for commit.

## 7. Product code changed

No.

## 8. Store/Public asset drafting changed

No.

## 9. Suggested external review inputs

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/core_fast/contact_sheet.png`
- `output/screen_review/current/profile_evidence_fast/contact_sheet.png`
- `output/screen_review/current/runner_fast/compact.decision.png`
- `output/screen_review/current/runner_fast/compact.correct_feedback.png`
- `output/screen_review/current/runner_fast/compact.wrong_feedback.png`
- `output/motion_evidence/current/manifest.json`
- `docs/_reviews/wave4_6_practice_review_screenshot_curation_v1.md`

## 10. Remaining known caveats, if any

- This pack is evidence-only. It does not draft store assets or public packaging copy.
- Contact sheets are review artifacts, not final public screenshots.
- Runner individual PNGs are stronger public-review inputs than the runner contact sheet.
- Store/Public Readiness should still wait for the fresh Claude Design / TOP1 Premium Reality Challenger review.
