# Wave 4.8 - Final Pre-Store Micro-Fix: Motion Media & Sharky Consistency v1

## 1. Verdict

wave4_8_final_pre_store_micro_fix_ready

## 2. Source audit

- Source: Premium Re-Audit Wave 4.7.
- Fresh re-audit verdict: `needs_bounded_p1_fix_before_store_assets`.
- P1-A motion media: internal motion proof existed as static PNG frame sequences, but public/store review needs a GIF or short clip.
- P1-B Sharky consistency: public hero surfaces needed one explicit visual identity rule for the side-profile logo mark versus the round in-product Sharky character.

## 3. Implementation summary

Files changed:

- `tools/act0_motion_media_export_v1.dart`
- `test/tools/act0_motion_media_export_v1_test.dart`
- `lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart`
- `test/ui_v2/act0_sharky_identity_contract_v1_test.dart`
- `docs/_reviews/wave4_8_final_pre_store_motion_sharky_consistency_v1.md`

Surfaces touched:

- Shared Sharky presence asset contract only.
- No per-screen layout redesign.
- No Modern Table changes.

## 4. Motion media

Input frames used:

- `output/motion_evidence/current/decision_feedback_reveal_frame_000ms.png`
- `output/motion_evidence/current/decision_feedback_reveal_frame_080ms.png`
- `output/motion_evidence/current/decision_feedback_reveal_frame_180ms.png`
- `output/motion_evidence/current/decision_feedback_reveal_frame_320ms.png`
- `output/motion_evidence/current/repair_result_fix_landed_frame_000ms.png`
- `output/motion_evidence/current/repair_result_fix_landed_frame_080ms.png`
- `output/motion_evidence/current/repair_result_fix_landed_frame_180ms.png`
- `output/motion_evidence/current/repair_result_fix_landed_frame_320ms.png`
- `output/motion_evidence/current/session_summary_proof_hero_frame_000ms.png`
- `output/motion_evidence/current/session_summary_proof_hero_frame_080ms.png`
- `output/motion_evidence/current/session_summary_proof_hero_frame_180ms.png`
- `output/motion_evidence/current/session_summary_proof_hero_frame_320ms.png`

Output media generated:

- `output/motion_media/current/decision_feedback_reveal.gif`
- `output/motion_media/current/repair_result_fix_landed.gif`
- `output/motion_media/current/session_summary_proof_hero.gif`
- `output/motion_media/current/manifest.json`

Format:

- Looping GIF.
- Four frames per moment.
- Generated from already-validated motion frames.

Local-only status:

- Generated motion media remains local-only.
- Generated GIFs were not staged for commit.

Product motion changed:

- No.

## 5. Sharky consistency decision

Chosen rule:

- The round `assets/images/mascot/sharky_*.png` family is the in-product companion character for Home, Profile, feedback, Practice proof, and Session Summary character moments.
- `assets/brand/logo.svg` remains the app/logo identity mark.
- Older SVG mascot assets remain fallback assets only when PNG loading fails.

Why this is public-safe:

- It preserves the current strongest character moments without a new persona, chat layer, expression system, or redesign.
- It makes the logo/companion split explicit in code through `act0SharkyLogoMarkAssetV1` and `act0SharkyCompanionAssetForMoodV1`.

## 6. Sharky surfaces touched

- Home / Day2: companion character remains the round PNG mascot through `Act0SharkyPresenceMascotV1`.
- Profile: companion character remains the round PNG mascot in the proof identity card.
- Feedback: runner feedback continues to render `Act0SharkyMascotV1`, backed by the shared companion PNG family.
- Practice: proof/repair moments continue to use the shared Sharky presence and coach phrase seams; no redesign.
- Session Summary: payoff Sharky bubble continues to use the shared companion PNG family.

## 7. Claim/copy safety

- No AI/chat/persona copy introduced.
- No GTO/solver copy introduced.
- No monetization/paywall/trial/purchase/restore copy introduced.
- No mastery/pro/radar/rating/XP copy introduced.
- No new reward economy or achievement system introduced.

## 8. Learner-visible/public-visible improvement

- Public review now has real motion media artifacts instead of only static frame sequences.
- Sharky identity now has a clear asset-role contract: companion character for in-product character moments, logo mark for app identity.
- The improvement is store/public-readiness oriented without changing learner progression, routes, or content.

## 9. Anti-drift proof

- No broad redesign.
- No Modern Table redesign.
- No W5-W36 expansion.
- No AI/chat/persona.
- No GTO/solver.
- No monetization.
- No new reward economy.
- No new motion system.
- No screenshot pipeline design loop.

## 10. Tests/checks

- `dart test test/tools/act0_motion_media_export_v1_test.dart`
- `flutter test test/ui_v2/act0_sharky_presence_v1_test.dart test/ui_v2/act0_sharky_identity_contract_v1_test.dart`
- `flutter test test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart test/ui_v2/wave4_5_motion_evidence_repair_feel_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Home Sharky identity avoids duplicate status chips and footer cue|Home inline Sharky coach is readable mission support|Profile shows Sharky proof identity and encouraging completion line|Review keeps repeated pending evidence as one active note'`
- `dart run tools/act0_motion_evidence_capture_v1.dart`
- `dart run tools/act0_motion_media_export_v1.dart`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh runner compact`
- `./tools/screen_review_fast_v1.sh profile_evidence compact`

Final validation is recorded in the closing report.

## 11. Evidence

Motion media output paths:

- `output/motion_media/current/decision_feedback_reveal.gif`
- `output/motion_media/current/repair_result_fix_landed.gif`
- `output/motion_media/current/session_summary_proof_hero.gif`
- `output/motion_media/current/manifest.json`

Refreshed screenshot packet paths:

- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`
- `output/screen_review/current/core_fast/contact_sheet.png`
- `output/screen_review/current/core_fast/screen_review_core_fast.zip`
- `output/screen_review/current/runner_fast/contact_sheet.png`
- `output/screen_review/current/runner_fast/screen_review_runner_fast.zip`
- `output/screen_review/current/profile_evidence_fast/contact_sheet.png`
- `output/screen_review/current/profile_evidence_fast/screen_review_profile_evidence_fast.zip`

Updated contact sheets:

- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/core_fast/contact_sheet.png`
- `output/screen_review/current/runner_fast/contact_sheet.png`
- `output/screen_review/current/profile_evidence_fast/contact_sheet.png`
