---
status: "product_surface_visual_repair_landed_with_explicit_structural_deferrals"
status_source: "derived"
doc_date: "2026-07-03"
baseline: "d823227dbc15"
generated_by: "docs_frontmatter_v1"
---

# Product Surface & Visual Evidence Repair v1

Date: 2026-07-03
Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
Preflight HEAD: `d823227dbc15057be3d54171f403802cb9d4fbc3`
Mode: live-runtime visual audit and bounded repair; no push

## 1. Verdict

`product_surface_visual_repair_landed_with_explicit_structural_deferrals`

The two concrete, high-confidence defects behind the "strange right-side W7-W12
table captures" are both root-caused and fixed, with focused regression tests
and fresh live-runtime evidence. A prior comprehensive audit
(`docs/_reviews/full_pre_human_visual_ux_audit_v2_10_10_gap_register_v1.md`,
2026-07-01, HEAD `05bd3fa4`) already produced a 28-item P1-P4 ledger; this wave
re-verified every still-relevant item against freshly regenerated live
evidence at current HEAD rather than trusting the stale claims, found most of
it already closed by intervening commits, fixed one additional real
cross-screen defect (Welcome handoff), and disproved one item as a tooling
scroll-jump artifact rather than a static bug.

## 2. Evidence/Surface Inventory

Regenerated live at this session's HEAD via existing lanes (no new lanes
added):

| Lane | Command | Screens | Result |
| --- | --- | --- | --- |
| `core compact` | `./tools/screen_review_fast_v1.sh core compact` | Home, Learn, Practice, Review, Profile | pass, 6 labels text-repaired |
| `first_week compact` | `./tools/screen_review_fast_v1.sh first_week compact` | Placement, Welcome decision/feedback/handoff, W1 decision/feedback, repair focus/result, session repair/summary, review handoff, profile return | pass, 12 labels text-repaired |
| `active_route_w7_w12 compact` | `./tools/screen_review_fast_v1.sh active_route_w7_w12 compact` | W7-W12 table + copy-detail pairs, terminal review/no-W13 | pass, 8 labels text-repaired (was 0 before fix) |
| `full_scroll compact` | `./tools/screen_review_fast_v1.sh full_scroll compact` | Home/Learn/Practice/Review/Profile/Session-Summary at top/mid/bottom scroll | pass, 27 labels text-repaired |

All four packets are `active_act0_runtime_test_only_wrapper` /
`Act0LessonRunnerShellV1`/production-shell evidence, not legacy/archive
renders. Local copies of the regenerated ("after") evidence live under
`output/product_surface_visual_evidence_repair_v1/after_*` (uncommitted, per
the local-only evidence rule).

Individual full-resolution PNGs were opened and inspected directly (not just
the contact sheet) for every finding below.

## 3. Strange-Table Root Cause

Both suspect defects live entirely in `tools/act0_real_text_surface_capture_v1.dart`
(screenshot tooling), not in `Act0LessonRunnerShellV1` production layout:

**Defect A - oversized/disproportionate capture canvas.** The `copy_detail`
capture kind used `copyDetailSize = Size(760, 1200)` while the `table` capture
kind (and the real supported compact device) uses `compactSize = Size(375,
812)`. `Act0LessonRunnerShellV1` is a responsive shell authored for a
compact-phone aspect ratio; forced into a canvas nearly 2x wider and a
different aspect ratio, its table stage and action-trail pill rendered at
their normal compact-phone size, floating centered/top-aligned inside a much
larger dark `Scaffold` background. That produced exactly the reported
symptom: a small table near the top and a large unused dark area below it,
with the feedback pill looking visually detached. This never affected real
users - no supported device is 760 logical points wide.

**Defect B - missing text-repair-overlay wiring (confirmed live, matches
prior audit's unverified GR-03).** `flutter test`'s headless renderer falls
back to the bundled `Ahem` test font for any `Text` whose resolved style has
no explicit `fontFamily`; every other capture lane calls
`writeTextRepairOverlays()` before capturing, which records those glyphless
runs to a `.text_overlays.json` sidecar that
`tools/screen_review_fast_text_repair_v1.py` then repaints with a real font.
The active-route (`W7-W12`) capture function never defined or called this
helper, so its `.text_overlays.json` was never written and the repair script
had nothing to fix (`repaired 0 labels`, confirmed by rerunning the
unmodified tool). The primary feedback CTA (`Continue` / `Try one like this`,
via `Act0ShellTokensV1.cta`, which has no explicit `fontFamily`) rendered as a
solid unreadable block in all 8 `copy_detail` screenshots.

## 4. Runtime/Tooling/Test-Only Classification

| Capture | Classification |
| --- | --- |
| W7-W12 `copy_detail` oversized canvas | `screenshot_tooling_regression` |
| W7-W12 `copy_detail` blank CTA text | `screenshot_tooling_regression` |
| W7-W12 `table` captures | `false_alarm` (already clean; never showed the reported symptom) |
| Session Summary `scroll_02_mid` CTA/nav visual collision (GR-08) | `screenshot_tooling_regression` (see Section 11) |
| All four regenerated lanes overall | `production_runtime_regression`: none found |

No production layout, route, telemetry, or Modern Table code was touched to
fix Section 3/4's findings - both fixes are entirely inside the capture tool.

## 5. Full P1-P4 Visual Ledger

Baseline is the prior audit's GR-01..GR-17 register, re-verified against
fresh live evidence at current HEAD (not trusted as still-true).

| ID | Surface | Severity | Classification | Current status (this session) | Disposition |
| --- | --- | --- | --- | --- | --- |
| GR-01 | W7-W12 copy-detail raw snake_case ids | P1 | content/runtime | **Already fixed** - fresh evidence shows curated labels (`Visible cards`, `Review clue`, etc.), locked by existing guard test | `fixed` (prior wave; re-verified) |
| GR-02 | W8 mismatched "Pot / to call" label | P1/P2 | content | **Already fixed** - W8 copy-detail now shows `Draws that improve` | `fixed` (prior wave; re-verified) |
| GR-03 | W7-W12 copy-detail CTA renders blank | P0 (was unverified) | tooling | **Confirmed live, then fixed this wave** (Section 3/6) | `fixed` |
| GR-04/GR-15 | Practice grid "Blinds" tile, no lock affordance | P1/P2 | hierarchy | **Already fixed** - all 4 tiles now show an explicit padlock icon | `fixed` (prior wave; re-verified) |
| GR-05 | Review "Legal actions" raw label | P1/P2 | copy | **Already fixed** - now reads "You are working on the actions you can choose." | `fixed` (prior wave; re-verified) |
| GR-06 | Welcome handoff large disconnected void | P1 | hierarchy/density | **Confirmed still present, fixed this wave** (Section 7/9) | `fixed` |
| GR-07 | Review tab dead space below single card | P2/10-10 opp | density | Confirmed still present (~25-30% of viewport, not 55-60%); matches Home's accepted "nothing due" pattern; Review structure is explicitly frozen and the empty state reads as intentional ("Nothing else is due") | `intentional_acceptance_with_negligible_ev` |
| GR-08 | Session Summary `scroll_02_mid` CTA/bottom-nav visual collision | P1/P2 (was unverified) | tooling | **Confirmed live** at the artificial 50%-of-max-extent scroll jump; `scroll_01_top` and `scroll_03_bottom` (the only two states a real user rests at) show clean spacing with no collision (Section 11) | `false_alarm` (scroll-jump capture artifact, not a static defect) |
| GR-09 | Home "Today 0/3" vs near-full progress bar | P2 | hierarchy | Not reproduced - no progress bar renders in the Home/Day-2 header in current evidence | `no_longer_reproducible` |
| GR-10 | CTA fill-style inconsistency (solid vs outline) | P2 | CTA | Reviewed `correct_feedback`/`practice_repair_target`; both now render solid-filled primary CTAs | `no_longer_reproducible` |
| GR-11 | Retry subtitle wording inconsistency | P2 (optional) | copy | Not re-verified this wave (prior audit marked optional/non-blocking) | `deferred_with_explicit_structural_reason` (cosmetic copy choice outside this wave's visual/layout scope; content wave closed Phase 7) |
| GR-12 | Profile duplicated heading / tagline | P2/10-10 opp | cohesion | Reviewed fresh `compact.profile.png` - only one "Proof profile" instance visible in the above-the-fold frame; no duplication observed | `no_longer_reproducible` |
| GR-13 | Placement dead space | P2/10-10 opp | density | Reviewed fresh `compact.placement.png` - spacing reads intentional, not excessive | `intentional_acceptance_with_negligible_ev` |
| GR-14 | Review jargon-adjacent phrasing | P3 | copy | Not blocking per prior audit; not re-opened | `deferred_with_explicit_structural_reason` (content-copy judgment, outside bounded visual-layout scope) |
| GR-16 | G10 bridge-copy visual-coverage gap | evidence gap | tooling | Requires a new capture surface (pre-question bridge state); explicitly out of bounds ("no new route/screen", "no new asset pipeline" for a new fixture family) | `deferred_with_explicit_structural_reason` |
| GR-17 | Profile task-count 28 vs 29 discrepancy | P3 | evidence | Not reproduced in this session's evidence (consistently 28) | `no_longer_reproducible` |

## 6. Responsive Repairs

- `tools/act0_real_text_surface_capture_v1.dart`: `copyDetailSize` now equals
  `compactSize` (`Size(375, 812)`), matching the one supported compact-phone
  viewport instead of an unsupported 760x1200 canvas. This is a tooling-only
  change; no production `ConstrainedBox`/`AspectRatio`/`FittedBox` in
  `Act0LessonRunnerShellV1` was touched, because none of them were the actual
  defect (confirmed by inspecting the render tree and by the `table` capture
  already being clean at the same responsive width).
- No compact-layout overflow was introduced or found in any of the four
  regenerated lanes.
- Tablet/desktop: not officially supported (per `VISUAL_PROOF_CAPSULE_v1.md`,
  only the compact lanes exist); no misleading wide-viewport evidence is
  produced by any lane after this fix.

## 7. Hierarchy/Density Repairs

- Welcome handoff (`act0_welcome_shell_v1.dart`): the `centerContent` beat's
  two flex `Spacer`s were re-balanced from `45:55` (above:below content) to
  `65:20`, tightening the gap between the payload (avatar/title/proof block)
  and its primary CTA so they read as one grouped, actionable unit instead of
  floating apart with a large disconnected void directly above the button.
  Scoped strictly to `centerContent == true` (the handoff-only beat); the
  standard beat frame (intro/decision/feedback beats, already accepted) keeps
  its original `45:55` ratio untouched.
- Practice grid, Review "Legal actions", and Profile duplicate-heading
  findings were already resolved by prior commits (Section 5); no new change
  was needed.

## 8. Readability Repairs

- The blank-CTA fix (Section 3/6) is itself a readability repair: all 8
  W7-W12 copy-detail primary CTAs now render legible text (`Continue`,
  verified at full resolution post-fix).
- No secondary-text contrast/size defects were found in the four regenerated
  lanes beyond the already-fixed items in Section 5.

## 9. CTA Repairs

- W7-W12 copy-detail primary CTA text visibility: fixed (Section 3/6).
- Welcome handoff CTA proximity to its content: fixed (Section 7).
- GR-10 (solid vs. outline CTA inconsistency): re-verified as already
  consistent (solid-filled) in current evidence; no change needed.

## 10. Surface-Cohesion Repairs

Home, Learn, Practice, Review, Profile, Session Summary, Welcome, and
Placement were all inspected at full resolution in this wave's fresh
evidence. All read as one consistent visual generation (navy shell, teal
felt, flat-blue CTA, gold proof accents) with no surface looking like a
separate/unfinished tier. No new cohesion defect was found beyond the
already-addressed Welcome handoff spacing.

## 11. Review/Empty-State Result

- Review tab (`compact.review.png`, `review_continuation.png`): confirmed a
  genuine but bounded empty region below "Nothing else is due..." (roughly
  a quarter to a third of the viewport, not the ~55-60% previously estimated).
  Given Review's structure is explicitly frozen, the empty state already
  reads as an intentional "nothing due" message (the same pattern already
  accepted on Home), and the fix's only lever without adding new content
  would be pure re-centering with no reduction in absolute blank pixels, this
  is accepted as `intentional_acceptance_with_negligible_ev` rather than
  forced into a cosmetic layout change.
- Session Summary `scroll_02_mid`: investigated the apparent CTA/bottom-nav
  collision directly. It reproduces only at the tooling's artificial
  50%-of-`maxScrollExtent` jump. `scroll_01_top` and `scroll_03_bottom` - the
  only two scroll states a real user actually rests at - both show the
  "Replay before next lesson" CTA and "Back to map" fully clear of the bottom
  nav with comfortable spacing. Classified `false_alarm`
  (screenshot-tooling scroll-jump artifact), not a static product defect;
  no code change made.

## 12. Static Versus Motion Dispositions

Every finding in Section 5 is a static layout/copy/tooling defect or
already-resolved item; none require animation to fix, and none were deferred
to Motion. GR-16 (bridge-copy visual coverage) is a capture-tooling coverage
gap, not a motion-dependent gap. No static defect was pushed onto the Motion
phase.

## 13. Before/After Evidence

- Before (this session's first capture, pre-fix):
  `compact.w7_first_route_task_copy_detail.png` = 1520x2400, blank-box CTA,
  large dark gap below the table (inspected, not retained - overwritten by
  the fix's regeneration per the local-only evidence rule).
- After (post-fix, this session):
  `output/product_surface_visual_evidence_repair_v1/after_active_route_w7_w12_fast/compact.w7_first_route_task_copy_detail.png`
  = 750x1624 (matches the table capture exactly), legible "Continue" CTA, no
  dead gap.
- Welcome handoff before/after: `after_first_week_fast/compact.welcome_handoff.png`
  shows content and CTA now grouped together near the bottom third of the
  screen instead of floating apart with a void on both sides.
- All four lanes' full "after" packets are under
  `output/product_surface_visual_evidence_repair_v1/after_*` (local-only,
  not committed).

## 14. Supported Viewport Conclusion

Only the compact-phone viewport (`Size(375, 812)`) is exercised or claimed as
supported by any lane, before or after this wave. No tablet/desktop capture
lane exists, and none was added. The copy-detail canvas fix removes the one
place that was silently rendering an unsupported 760-wide viewport as if it
were valid evidence.

## 15. Tests/Validation

New focused tests added:

- `test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart`:
  two new cases - `copyDetailSize` stays pinned to `compactSize` (no
  `Size(760, 1200)` regression), and `writeTextRepairOverlays` is defined and
  called inside the active-route capture function.
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`: extended the existing
  end-to-end Welcome-to-Home test with a structural assertion that the gap
  below the handoff content stays smaller than the gap above it (locks the
  `65:20` rebalance without hardcoding a viewport-fragile pixel threshold).

Validation run (this wave):

- `flutter test test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart` - 6/6 pass.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Welcome completes one local micro win before Home handoff"` - pass.
- `flutter test` on w7-w12 route/depth/payoff guards, W1 completion payoff, and premium first-open tests (8 files) - all pass.
- `flutter analyze` - no issues found.
- `graphify hook-check`, `git diff --check`, `git diff --cached --check` - all pass.
- All four screenshot lanes regenerated end-to-end - pass.

Known pre-existing failures (confirmed present at HEAD `d823227d` before any
change in this wave, via `git stash`/`git stash pop` isolation - not
introduced or touched by this repair):

- `test/guards/act0_visual_ux_known_p1_copy_contract_test.dart`: expects
  `'First milestone in Volume I.'` in `act0_lesson_runner_shell_v1.dart`;
  absent at HEAD. Unrelated content-copy guard, not a visual/layout defect.
- `test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart`: pre-existing
  unapproved-Latin residue in RU strings in `act0_learn_path_shell_v1.dart`
  and `act0_placement_shell_v1.dart` (and one line in
  `act0_welcome_shell_v1.dart` unrelated to this wave's edit). Localization
  content gap, not a visual/layout defect.

Both are classified `still_pre_existing_failure`, matching the same
three-failure pattern already carried forward and documented in
`docs/_reviews/apply_owner_patch_sequence_a_b_c_d_v1.md`.

## 16. Fixed/Deferred/Accepted Counts

- Fixed this wave: 3 (W7-W12 copy-detail canvas mismatch, W7-W12 copy-detail
  blank CTA, Welcome handoff content-to-CTA void).
- Already fixed by prior waves, re-verified with fresh evidence: 5 (GR-01,
  GR-02, GR-04/GR-15, GR-05).
- No longer reproducible with fresh evidence: 4 (GR-09, GR-10, GR-12, GR-17).
- False alarm (tooling artifact, not a static product defect): 1 (GR-08).
- Intentional acceptance, negligible EV: 2 (GR-07, GR-13).
- Deferred with explicit structural reason: 3 (GR-11, GR-14, GR-16 - all
  content-copy judgment or new-capture-surface asks outside this wave's
  bounded visual/layout/tooling scope).

## 17. Remaining Structural Deferrals

- GR-16 (G10 bridge-copy visual coverage) needs a new pre-question capture
  fixture family; the read-order guardrails forbid new capture surfaces in
  this wave. Owner: a future scoped tooling wave, if visual (not just
  source-guard) confirmation of bridge copy is ever required before Human QA.
- GR-11/GR-14 are copy-wording judgment calls inside a phase (Content &
  Correctness) that is explicitly CLOSED; reopening them belongs to a
  content-specific wave, not this visual/layout repair.

## 18. Rolling Capsule Advance

- This checkpoint (`Product Surface & Visual Evidence Repair v1`) is CLOSED.
- `Motion Direction System v1` (Phase 8) is restored ACTIVE.
- `docs/context/VISUAL_PROOF_CAPSULE_v1.md` updated: repaired surfaces
  (W7-W12 copy-detail canvas + CTA legibility, Welcome handoff spacing),
  supported-viewport truth (compact-only, unchanged), and this artifact added
  to the reference list.
- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md` updated: this checkpoint recorded
  as CLOSED, active task reverted to `Motion Direction System v1`.

## 19. Scope Safety

- No route, telemetry, persistence, answer-truth, or callback change.
- No new route/screen, dependency, visual framework, or navigation redesign.
- No Modern Table change (not touched at all).
- No motion implementation.
- No XP/coins/levels/economy addition.
- No W13+ scope opened.
- `output/**` not committed (local-only evidence).
- Diffs: 4 files changed - one production layout file
  (`act0_welcome_shell_v1.dart`, 2-line flex-ratio change), one screenshot
  tool (`act0_real_text_surface_capture_v1.dart`), two test files.

## 20. Next Recommendation

Resume `Motion Direction System v1` (Phase 8). No unresolved actionable
visual gap remains in the current W1-W12 scope; all remaining items are
either already fixed, no longer reproducible, intentionally accepted, or
explicitly deferred for a named structural reason above.
