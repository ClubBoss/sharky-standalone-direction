---
status: "known_p1_fixes_landed_needs_screenshot_tooling_expansion"
status_source: "derived"
doc_date: "2026-07-01"
baseline: "05bd3fa4da73"
generated_by: "docs_frontmatter_v1"
---

# Full Pre-Human Visual UX Evidence Coverage + Known P1 Fix Wave v1

Date: 2026-07-01
Branch: `main`
HEAD: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40`
Mode: pre-human visual evidence and known P1 fix wave only

## Verdict

`known_p1_fixes_landed_needs_screenshot_tooling_expansion`

Known P1 Visual/UX fixes landed in the admitted Act0 seams and are covered by focused widget/source guards. A fresh local screen-review packet was generated across every existing fast capture group. The packet is not a complete late-route visual packet because the current screenshot tooling does not expose direct visual capture for W7-W12 route admission packs, the W12 terminal pack, or terminal/no-W13 state. Those remain tooling gaps, not product-readiness claims.

No Human QA was run or synthesized.

## Stage 0

- Root: `/Users/elmarsalimzade/Sharky_1.0`
- Remote: `origin` points to `https://github.com/ClubBoss/sharky-standalone-direction.git`
- Branch state: `main...origin/main`
- HEAD and `origin/main`: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40`
- Starting tree: dirty from prior accepted W7-W12 route-admission files and untracked prior review/output artifacts.
- This wave did not revert, stage, commit, or push existing unrelated work.
- Screenshot output policy: regenerated under `output/screen_review/current/*_fast`; local-only and unstaged.

## Known P1 Fix Table

| ID | Issue | Resolution | Evidence |
| --- | --- | --- | --- |
| FIX-VUX-01 | Learn tab claimed "36-world path" before the visible product can support that claim. | Replaced with bounded Volume I copy: "Start Volume I: one clear table read at a time." | `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`; `test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`; `test/guards/act0_visual_ux_known_p1_copy_contract_test.dart` |
| FIX-VUX-02 | Welcome handoff had a broken/empty-feel gap before CTA. | Final handoff beat now uses loose flexible scroll sizing instead of forcing a large expanded empty zone; targeted test checks CTA/frame spacing. | `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`; `test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Welcome completes one local micro win before Home handoff"` |
| FIX-VUX-03 | Welcome handoff copy said "Open the start", which was ambiguous. | Replaced with first-lesson copy and CTA: "Your first lesson is ready..." / "Open first lesson". | `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`; focused welcome test; guard test |
| FIX-VUX-04 | Wrong feedback label "One table retry" sounded like a mode label. | Current source already uses "Use the table, then retry."; guard locks the safe label and rejects "One table retry". | `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart`; `test/guards/act0_visual_ux_known_p1_copy_contract_test.dart`; `output/screen_review/current/first_week_fast/compact.wrong_feedback.png` |
| FIX-VUX-05 | Session Summary "Need 80% accuracy" and next-world label created gate anxiety; singular error copy could read "1 errors". | Below-threshold copy now says "Keep replaying this clue to deepen the read before moving on."; next-world name is not shown in that state; error pluralization is singular-safe. | `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`; focused summary test; `output/screen_review/current/first_week_fast/compact.session_summary.png` |
| Same seam | W1 completion payoff overclaimed a 36-world Core Shark Path. | Replaced with "First milestone in Volume I." | `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`; `test/ui_v2/act0_world1_completion_payoff_v1_test.dart` |

## Full Screenshot Packet

Fresh local-only packets generated with existing tooling:

| Packet | Command | Surfaces | Local packet |
| --- | --- | ---: | --- |
| Core tabs | `./tools/screen_review_fast_v1.sh core compact` | 5 | `output/screen_review/current/core_fast/screen_review_core_fast.zip` |
| Runner | `./tools/screen_review_fast_v1.sh runner compact` | 3 | `output/screen_review/current/runner_fast/screen_review_runner_fast.zip` |
| First week | `./tools/screen_review_fast_v1.sh first_week compact` | 13 | `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip` |
| Day 2 return | `./tools/screen_review_fast_v1.sh day2_return compact` | 5 | `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip` |
| Profile evidence | `./tools/screen_review_fast_v1.sh profile_evidence compact` | 1 | `output/screen_review/current/profile_evidence_fast/screen_review_profile_evidence_fast.zip` |
| Full scroll | `./tools/screen_review_fast_v1.sh full_scroll compact` | 18 | `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip` |

Packet metadata:

- Total captured surfaces: 45
- All regenerated packet indexes record HEAD `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40`
- All packet indexes record `git_status: dirty`, matching the in-flight workspace state.
- Contact sheets exist for every generated packet.
- Generated files are local-only and should not be staged as part of this wave.

## Visual Coverage Matrix

| Surface family | Coverage state | Evidence |
| --- | --- | --- |
| First-open placement | Captured | `first_week_fast/compact.placement.png` |
| Welcome decision, feedback, handoff | Captured | `first_week_fast/compact.welcome_decision.png`; `compact.welcome_feedback.png`; `compact.welcome_handoff.png` |
| Home tab | Captured | `core_fast/compact.home.png`; `full_scroll_fast/compact.home.scroll_*.png` |
| Learn tab visible path | Captured | `core_fast/compact.learn.png`; `full_scroll_fast/compact.learn.scroll_*.png` |
| Practice tab | Captured | `core_fast/compact.practice.png`; `full_scroll_fast/compact.practice.scroll_*.png`; `day2_return_fast/compact.practice_repair_target.png` |
| Review tab | Captured | `core_fast/compact.review.png`; `full_scroll_fast/compact.review.scroll_*.png`; `day2_return_fast/compact.review_continuation.png` |
| Profile tab and return evidence | Captured | `core_fast/compact.profile.png`; `profile_evidence_fast/compact.profile_evidence.png`; `day2_return_fast/compact.profile_not_clear.png` |
| Runner decision, correct, wrong feedback | Captured | `runner_fast/compact.decision.png`; `compact.correct_feedback.png`; `compact.wrong_feedback.png`; also first-week equivalents |
| Repair focus/result/session repair | Captured | `first_week_fast/compact.repair_focus.png`; `compact.repair_result.png`; `compact.session_repair.png` |
| Session summary | Captured | `first_week_fast/compact.session_summary.png`; `full_scroll_fast/compact.session_summary.scroll_*.png` |
| Review handoff | Captured | `first_week_fast/compact.review_handoff.png` |
| Day 2 return source | Captured | `day2_return_fast/compact.open_repair_source.png`; `compact.return_home.png` |
| W7 route depth packs | Not visually captured | Contract guards passed; screenshot harness does not expose this route pack directly. |
| W8 route admission depth gate | Not visually captured | Contract guards passed; screenshot harness does not expose this route pack directly. |
| W9-W10 route admission packs | Not visually captured | Contract guards passed; screenshot harness does not expose these route packs directly. |
| W11 transfer-depth route pack | Not visually captured | Contract guards passed; screenshot harness does not expose this route pack directly. |
| W12 review/payoff route pack and terminal state | Not visually captured | Contract guards passed; screenshot harness does not expose this route pack or terminal state directly. |
| W13 absence / terminal no-route state | Not visually captured | Guard coverage exists; no visual capture hook in current fast packet tooling. |

## Missing Coverage Register

| Gap | Severity | Reason | Required next action |
| --- | --- | --- | --- |
| Late-route W7-W12 campaign pack visual capture | Tooling gap | Existing `screen_review_fast_v1.sh` groups cover Act0 shell, first-week runner, return, profile, and full-scroll states, but not direct campaign-pack rendering for W7-W12. | Add a bounded screenshot harness that can seed and capture each admitted route pack without changing product flow. |
| W12 terminal / no-W13 visual capture | Tooling gap | Guard tests prove W13 absence and terminal copy, but current visual packet cannot render the exact terminal pack state. | Extend screenshot tooling with terminal-state fixture capture. |
| Small-device landscape | Deferred coverage | Current compact packets are portrait compact captures. | Add landscape viewport mode only if pre-human visual review requires it. |
| Human perception review | Not run | This wave is explicitly pre-human and cannot synthesize Human QA. | Hand packet to Claude/human reviewer after tooling gap is accepted or closed. |

## Deferred Visual/UX Fix Register

- No new redesign, design-system change, XP/badge expansion, monetization, W13+, mapper, public readiness, or route-opening work was admitted.
- Late-route visual capture tooling is deferred because creating a campaign-pack screenshot renderer inside this wave would exceed the known-P1-fix contract.
- Any W3/W6 richness, W12 scenario expansion, Modern Table polish, or cross-world repair work remains out of scope.

## Claim-Safety

- No Human QA claim.
- No Human-QA-ready claim.
- No public/store readiness claim.
- No top-1, 10/10, or learning-effect claim.
- No W13+ activation claim.
- No monetization or premium conversion claim.
- No claim that the screenshot packet is visually complete for W7-W12 route packs.
- The accurate claim is: known P1 fixes landed, existing fast visual packets regenerated, and late-route visual capture requires screenshot tooling expansion.

## Claude Handoff Packet

Provide Claude/human reviewer with:

- This artifact: `docs/_reviews/full_pre_human_visual_ux_evidence_coverage_known_p1_fix_wave_v1.md`
- Local contact sheets:
  - `output/screen_review/current/core_fast/contact_sheet.png`
  - `output/screen_review/current/runner_fast/contact_sheet.png`
  - `output/screen_review/current/first_week_fast/contact_sheet.png`
  - `output/screen_review/current/day2_return_fast/contact_sheet.png`
  - `output/screen_review/current/profile_evidence_fast/contact_sheet.png`
  - `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- Local packet zips:
  - `output/screen_review/current/core_fast/screen_review_core_fast.zip`
  - `output/screen_review/current/runner_fast/screen_review_runner_fast.zip`
  - `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
  - `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
  - `output/screen_review/current/profile_evidence_fast/screen_review_profile_evidence_fast.zip`
  - `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

Reviewer instructions:

- Review known P1 fixes first against the generated first-week/core/runner/session-summary screenshots.
- Treat W7-W12 visual route coverage as missing until a dedicated route-pack screenshot harness exists.
- Do not infer Human QA, public readiness, or product-complete status from this packet.

## Next Chat Handover

Next recommended bounded wave:

`Build route-pack screenshot tooling for W7-W12 visual coverage, then regenerate a late-route visual packet.`

Start with:

1. Keep product code frozen unless a screenshot-only harness requires a test/debug seam.
2. Add capture states for W7, W8, W9, W10, W11, W12, W12 terminal/no-W13.
3. Generate local-only packet under `output/screen_review/current/route_w7_w12_fast`.
4. Update this artifact or create a follow-up coverage artifact with the late-route visual matrix.

Validation completed for this wave:

- `dart format ...`
- `flutter test test/guards/act0_visual_ux_known_p1_copy_contract_test.dart test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart test/ui_v2/act0_world1_completion_payoff_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Welcome completes one local micro win before Home handoff"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Block summary locks continue below accuracy threshold"`
- `flutter test test/guards/w7_route_depth_followup_quality_contract_test.dart test/guards/w8_route_admission_depth_gate_contract_test.dart test/guards/w9_route_admission_depth_gate_contract_test.dart test/guards/w10_route_admission_depth_gate_contract_test.dart test/guards/w11_route_admission_transfer_depth_gate_contract_test.dart test/guards/w12_route_admission_review_payoff_gate_contract_test.dart test/guards/w7_w12_first_use_jargon_contract_test.dart`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh runner compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh profile_evidence compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
