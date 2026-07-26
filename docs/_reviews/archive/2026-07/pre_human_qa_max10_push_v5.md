---
status: "undeclared"
status_source: "absent"
baseline: "5d2b8583ca4c"
generated_by: "docs_frontmatter_v1"
---

# Pre-Human-QA Max-10 Push v5

## 1. Executive verdict

Terminal verdict: `pre_human_qa_max10_push_complete_with_known_limitations_ready_for_claude_final_rereview`

This branch applies a bounded phone-first polish pass for the four accepted Claude v4 P2 design blockers. It does not run Human QA and does not claim release, public, launch, 10/10, durable learning, or beginner mastery status.

## 2. Baseline

- Baseline branch: `codex/phone-first-premium-polish-v4`
- Baseline commit: `5d2b8583ca4c87b0bf39c22f0a3553528bb852a4`
- Working branch: `codex/pre-human-qa-max10-push-v5`
- Baseline verified before implementation: local branch started from the required v4 commit.

## 3. Claude v4 findings accepted

Accepted P2 findings:

1. Review empty still had too much dead canvas.
2. Wrong feedback did not visually read enough as a miss.
3. First decision/play still read as a seat-tap orientation quiz rather than a stronger first milestone.
4. Sharky companion presence was weak in frequent feedback screens.

## 4. Scope implemented

Implemented only the four bounded visual/product lifts:

- Review empty now previews the truthful miss -> repair -> proof loop without fake queue data.
- Wrong feedback now has a distinct missed-cue treatment and icon.
- First play/seat-tap orientation now has a deliberate table-read milestone band.
- Feedback states now expose stable Sharky slots for wrong, repair, and proof states.

## 5. Scope rejected/deferred

No route ownership, progression, telemetry, W13+, answer semantics, content-engine architecture, Modern Table, or broad redesign work was performed.

No Human QA was run. No fake miss, proof, stat, queue, or activity data was added.

## 6. Review empty max-10 push

Changed file: `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`

Review empty keeps the existing honest empty-state contract and adds a denser real-text learning-loop preview:

- Existing empty copy and `Open Learn` route remain intact.
- The preview uses the old `HOW REVIEW WORKS` label for compatibility.
- The new preview adds `MISS`, `REPAIR`, and `PROOF` rows plus compact truthful tags.
- Sharky appears in a coach panel with the real claim-safe line: `After a lesson, Sharky brings back the exact cue you missed.`

## 7. Wrong feedback missed-cue treatment

Changed file: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`

Wrong feedback now uses a distinct missed-cue tone, a `search_off` missed-cue icon, and a subtle wrong-state gradient. The content still uses the real selected/better action and authored explanation lines.

Guard key added: `act0_shell_feedback_missed_cue_treatment`.

## 8. First play milestone treatment

Changed file: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`

The first seat-read prompt now renders as a table-read milestone:

- `First table read`
- `Step 1 · Locate your seat`
- `Read the table from your seat before any action.`

The prompt question and answer semantics remain unchanged.

## 9. Sharky feedback companion slots

Changed file: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`

Feedback now exposes stable Sharky slot keys:

- `act0_shell_feedback_sharky_slot_wrong`
- `act0_shell_feedback_sharky_slot_repair`
- `act0_shell_feedback_sharky_slot_proof`

The mascot is larger in the feedback card, while the feedback copy and repair/proof flow remain route-neutral.

## 10. Evidence pack v5

Generated local-only evidence directory:

`output/design_review/real_text_visual_pack_v5/`

Generated files include:

- `manifest.json`
- `coverage.md`
- `claude_design_final_max10_rereview_prompt.md`
- `contact_sheets/compact_visible_contact_sheet.png`
- `contact_sheets/compact_full_scroll_contact_sheet.png`
- `contact_sheets/tablet_visible_contact_sheet.png`
- `contact_sheets/tablet_full_scroll_contact_sheet.png`
- `compact/visible/`
- `compact/full_scroll/`
- `tablet/visible/`
- `tablet/full_scroll/`

The pack uses real-text screenshots from regenerated local capture lanes. Output remains local-only and untracked.

## 11. Tablet smoke

Tablet visible smoke evidence was regenerated for all 19 required screens. Tablet full-scroll/segment evidence was also generated where the existing capture tooling supports it.

Tablet evidence is for clipping, overflow, CTA access, and broken-layout smoke only. Compact phone remains the primary review target.

## 12. Route/content/telemetry/W13 invariance

The v5 push does not change:

- route ownership;
- progression rules;
- telemetry;
- W13+ admission;
- answer correctness;
- content-engine architecture;
- Modern Table behavior;
- W12 terminal/no-W13 contract.

W12 route admission and no-W13 guard coverage passed in validation.

## 13. Validation

Validation run on this branch:

- `dart run tools/act0_product_100_proof_capture_v1.dart` passed.
- Compact captures passed: `core`, `first_week`, `day2_return`, `active_route_w7_w12`, `full_scroll`.
- Tablet captures passed: `core`, `first_week`, `day2_return`, `active_route_w7_w12`, `full_scroll`.
- `python3 tools/build_real_text_visual_pack_v5.py` built the pack.
- `flutter test` focused guard/UI set passed: 139/139.
- `flutter analyze` passed with no issues.
- `git diff --check` passed.
- `graphify hook-check` passed.

## 14. Remaining not-10/10 items

Remaining limitations:

- Claude final max-quality re-review has not been run in this branch.
- Human QA has not been run.
- Static screenshots cannot prove interaction comprehension, long-term retention, or learner outcomes.
- Tablet is smoke evidence, not the primary quality target.
- The evidence pack is local-only and should be regenerated after any further UI-affecting commit.

## 15. Whether larger redesign is needed

No larger redesign was required to address the four accepted v4 P2 blockers. A broader redesign should only be considered if Claude final re-review identifies new cross-screen visual-system blockers that cannot be resolved with bounded surface work.

## 16. Claude final max-10 re-review instructions

Use:

`output/design_review/real_text_visual_pack_v5/claude_design_final_max10_rereview_prompt.md`

Review compact phone first, then tablet smoke for blocker regressions only. Use screenshot paths from `manifest.json` and `coverage.md`. Do not infer Human QA approval, launch readiness, public readiness, durable learning effect, beginner mastery, or 10/10 proof from static evidence.

## 17. Human QA baseline recommendation

If Claude final re-review accepts the v5 visual pack as the preferred pre-Human-QA surface, refresh the Human QA baseline to the accepted v5 commit before starting Human QA. Do not use stale v4 evidence as the active Human QA visual baseline after accepting v5.

## 18. Explicit non-claims

This branch does not claim:

- Human QA approval;
- public readiness;
- launch readiness;
- 10/10 proof;
- durable learning effect;
- beginner mastery;
- premium commercial readiness.
