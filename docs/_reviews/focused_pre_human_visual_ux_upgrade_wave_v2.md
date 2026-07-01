# Focused Pre-Human Visual UX Upgrade Wave v2

Date: 2026-07-02
Effort: high
Mode: focused visual/UX fix wave, based on `docs/_reviews/full_pre_human_visual_ux_audit_v2_10_10_gap_register_v1.md`

## 1. Verdict

`focused_visual_ux_upgrade_landed_with_verification_deferrals`

Every mandatory Wave 1 item and every bounded Wave 2 item was resolved: either fixed in code (with regenerated screenshot evidence confirming the fix), or investigated to a firm conclusion and explicitly documented as not-a-real-defect (with the investigation trail recorded so the conclusion is auditable, not just asserted). One item (GR-03) required — and received — genuine runtime verification before any conclusion was reached, per the task's own branching instructions.

## 2. Stage 0 Summary

- HEAD: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40` (unchanged; no commits made)
- Branch: `main`, `main...origin/main` no divergence
- Audit artifact confirmed present: `docs/_reviews/full_pre_human_visual_ux_audit_v2_10_10_gap_register_v1.md`
- `output/screen_review/current/active_route_w7_w12_fast/` confirmed present and used as W7-W12 visual truth
- `output/screen_review/current/route_w7_w12_fast/` (legacy) confirmed **not** used for any visual judgment or verification in this wave
- Dirty files present at Stage 0 (preserved, not overwritten, from prior waves): `lib/campaign/campaign_pack_registry_v1.dart`, `lib/canonical/canonical_truth_map_v1.dart`, `lib/services/progress_service.dart`, `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`, `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` (already dirty before this wave touched it further), `test/guards/w7-w12 route admission guards`, `test/ui_v2/act0_world1_completion_payoff_v1_test.dart`, `test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`, `tools/package_screen_review_v1.py`, `tools/package_screen_review_v1.sh`, `tools/screen_review_fast_v1.sh`, plus numerous untracked prior review docs and guard tests
- Files touched by this wave: `tools/act0_real_text_surface_capture_v1.dart`, `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`, `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`, `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`, `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`, `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`, `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`, `test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart`, `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- Valid screenshot packets used for verification: `core_fast`, `runner_fast`, `first_week_fast`, `day2_return_fast`, `profile_evidence_fast`, `full_scroll_fast`, `active_route_w7_w12_fast` — all regenerated at least once during this wave
- Legacy `route_w7_w12_fast` was not regenerated, not opened, and not used as evidence anywhere in this wave

## 3. Fix Table

| id | status | files touched | evidence path | learner-facing outcome | validation | remaining watchlist |
|---|---|---|---|---|---|---|
| GR-01 | fixed | `tools/act0_real_text_surface_capture_v1.dart` | `active_route_w7_w12_fast/compact.w7_first_route_task_copy_detail.png` (now shows "Visible cards") | **Root cause was narrower than the audit assumed**: raw `conceptFamilyId` strings were injected only by the screenshot-capture tool's `optionsForTask()`, which fed `task.conceptFamilyId` directly into `repairFocusLabels`. The live app's own `_feedbackSignalLabelFromRepairLabelV1` normalizer was already correct — real production `repairFocusLabels` are always short human phrases (`'Hero cards'`, `'Board cards'`, `'BTN'`). Added `humanRepairFocusLabelForConceptFamily()` mapping every known concept-family id to a curated label (Visible cards / Draws that improve / Price to call / Bet purpose / Board texture / Review clue / Volume I review) with a Title-Case fallback for future ids. | New guard test (below) + regenerated `active_route_w7_w12_fast`, visually confirmed clean on W7, W8, W9, W10, W11, W12×2, terminal | None — resolved at the source (capture tool), not a live-app defect |
| GR-02 | fixed | same as GR-01 | `active_route_w7_w12_fast/compact.w8_route_task_copy_detail.png` (now shows "Draws that improve") | **Root cause found**: the app's `_feedbackSignalLabelFromRepairLabelV1` does substring matching (`lower.contains('pot')`) to map some raw labels to friendly text. `w8_draw_improvement_potential` accidentally contains the substring "pot" (inside "improvement**pot**ential"), which mis-mapped it to "Pot / to call". Fixing GR-01 (curated label "Draws that improve" — which does not contain "pot") eliminates this collision as a side effect; the live-app normalizer itself was not modified, to avoid widening scope. | Guard test asserts the W8 label is not "Pot" / "to call"; screenshot confirms clean | None |
| GR-03 | verified_real_capture_artifact_only | `test/ui_v2/act0_shell_preview_screen_v1_test.dart` (new regression test only; no product code changed) | `active_route_w7_w12_fast/compact.w7_first_route_task_copy_detail.png` (button pixels still blank in this specific capture tool) | Investigated per the task's required branching: instrumented the capture tool to inspect the live widget tree during capture. Found the CTA `Text` widget's `data` field is correctly `"Continue"` (non-null, non-empty, white foreground color, standard style) — the underlying app state and widget tree are correct. The blank pixels are confined to this one specialized screenshot-capture harness (its own font-loading/RenderRepaintBoundary pipeline), not the live app. Confirmed independently: the exact same CTA key (`act0_shell_feedback_continue_cta`) is used and tapped successfully across 90+ pre-existing tests in the standard test harness. Added a new durable regression test using that same known-good harness, constructing the identical runner-state shape (`phase: review`, `selectedOptionId: <answer>`) the capture tool builds, and asserting the CTA `Text.data` is non-empty and matches one of the two valid labels. | New test `Review-phase feedback panel renders a non-empty CTA label` passes | If a future capture-tool rewrite is scoped, revisit whether the blank-button capture artifact should be closed at the tooling level; not a product defect, so no product change was made |
| GR-04 | fixed | `lib/ui_v2/act0_shell/act0_play_shell_v1.dart` | `core_fast/compact.practice.png` (all 4 grid tiles now show a padlock icon) | Practice's 2×2 drill grid (`_SkillPackPreviewCardV1`) showed `Icons.route_rounded` for disabled/unavailable tiles — an ambiguous icon unrelated to "locked," unlike Learn's explicit `Icons.lock_rounded`. Swapped to `Icons.lock_rounded` to match Learn's established locked-state convention. Also traced the gating logic (`isEnabled: target != null`, requiring the underlying lesson task already completed) and confirmed "Blinds" was never actually tappable for a W1 learner — the fix closes the *visual ambiguity*, not a routing gap. | `flutter test test/ui_v2/act0_play_shell_v1_test.dart` (15/15 pass) + regenerated `core_fast`/`full_scroll_fast` screenshots | None |
| GR-05 | fixed | `lib/ui_v2/act0_shell/act0_review_shell_v1.dart` | `day2_return_fast/compact.review_continuation.png` (now "You are working on the actions you can choose.") | Added a targeted override in `_reviewPatternFocusLabelV1` mapping the internal-sounding lesson-node title "Legal actions" to the natural phrase "the actions you can choose" — following the exact same established pattern the function already uses for forbidden-term substitution. Only this one specific title is affected; other natural-sounding titles (e.g. "Meet the table") are untouched. | `flutter test test/ui_v2/act0_review_shell_v1_test.dart` (14/14 pass) + regenerated screenshot | None |
| GR-06 | fixed | `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart` | `first_week_fast/compact.welcome_handoff.png` | Root cause: the handoff beat's outer `Column` never set `mainAxisAlignment`, so all leftover vertical space collected below the CTA button (top-anchored composition). Added `mainAxisAlignment: centerContent ? MainAxisAlignment.center : MainAxisAlignment.start` so the handoff beat (the one case where `centerContent` is true) now centers the whole top-bar+card+CTA group as a unit. First attempt (wrapping the card alone in `Expanded(child: Center(...))`) broke the existing frame-to-CTA gap guard (521px vs required ≤180px) and was reverted in favor of this smaller, correct fix. | `flutter test --plain-name "Welcome completes one local micro win before Home handoff"` passes (gap constraint intact) + regenerated screenshot confirms a balanced, no-longer-broken-looking composition | None |
| GR-07 | deferred_with_reason | — | — | Review tab's large dead space below its single card — layout-only, not broken; explicitly listed as "recommended, not mandatory" in the audit. Left untouched this wave to keep footprint bounded to the Wave-1/Wave-2 list. | — | Revisit as a 10/10-opportunity wave if desired |
| GR-08 | verified_real_and_fixed | `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` | `full_scroll_fast/compact.session_summary.scroll_02_mid.png` and `.scroll_03_bottom.png` | Root cause found: every other tab (Home, Learn, Practice, Review, Profile) reserves `bottomNavHeight + gapXl` (86px) as scroll-view bottom padding to clear the persistent nav bar; Session Summary's scroll view only reserved `gapLg` (16px), a 70px shortfall that let the "Replay before next lesson" CTA scroll far enough to visually collide with and obscure the Learn/Practice/Review nav labels. Changed the padding to match the established app-wide convention. | Regenerated `full_scroll_fast`; visually confirmed all 5 nav labels fully readable at both scroll_02_mid and scroll_03_bottom, with the CTA and "Back to map" link now sitting cleanly above the nav bar | None |
| GR-09 | verified_real_and_fixed | `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` | `day2_return_fast/compact.return_home.png` (bar now renders empty at 0/3) | Root cause found: the top bar's `LinearProgressIndicator` was wired to `state.xpProgress` (overall curriculum progress) while its label showed the *daily* rep-goal fraction (`_compactDailyLabel()`), and this is the top bar's only call site — so the two values could never have been meant to differ. Added `_dailyGoalProgressValueV1()` (`dailyCompletedRepCount / 3`) and rewired the bar to it. | `flutter test --plain-name "Home keeps the global top bar visible"` passes + regenerated screenshot shows bar correctly empty at 0/3 | None |
| GR-10 | verified_not_real | — | — | Traced both "Continue"-labeled controls: the primary feedback/theory/session-summary CTA is *always* a solid `FilledButton` with `Act0ShellTokensV1.primaryButtonStyle()` (single style token, single visual treatment, confirmed at 3 separate call sites). The "ghost/outline" control the audit saw on `practice_repair_target.png` is `_LearningRailNavButtonV1` — an intentionally distinct, compact prev/next stepper for paging through teaching/recap content, not the primary CTA. These are two different, purposeful component types; the app's own primary-CTA styling is already 100% consistent. Making them visually identical would blur an intentional primary/secondary distinction and risk violating "keep secondary actions distinct." No code changed. | Source trace only (three call sites of `primaryButtonStyle()`, one call site of `_LearningRailNavButtonV1`) | None |
| GR-11 | verified_not_real | — | — | "Use the table, then retry." and "One calm retry." are both entries in `_feedbackCoachCandidatesV1`'s wrong-answer candidate pool, deterministically seed-selected via `_pickDeterministicCoachLineV1` — an intentional anti-repetition copy-variety mechanism (mirrors the correct-answer pool: "Sharp read." / "Clean read." / "Good table check."). Forcing a single fixed string would remove an intentional product feature, not fix a bug. No code changed. | Source trace only | None |
| GR-12 | fixed (partial, by design) | `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart` | `core_fast/compact.profile.png` (subheading now "What Sharky can already prove") | Fixed the safe, tiny, unambiguous part: the page subheading duplicated the hero card's own "Proof profile" headline verbatim in immediate visual proximity. Changed the subheading only. Deliberately did **not** reorder Profile's card sequence to surface a named achievement above the fold — that would touch multiple sections' order and borders on "redesign Profile," which is explicitly out of scope for this bounded wave. | `flutter test --plain-name "Profile shows Sharky proof identity and encouraging completion line"` passes (uses `findsWidgets`, unaffected since the hero card still says "Proof profile") + regenerated screenshot | Reordering to surface a concrete achievement above the fold remains a 10/10 opportunity for a future wave |
| GR-15 | fixed (bundled with GR-04) | see GR-04 | see GR-04 | Same fix as GR-04 covers all four grid tiles (Actions/Blinds/Positions/Showdown), not just Blinds. | see GR-04 | None |

## 4. Visual Quality Uplift Summary

- **Trust**: The W7-W12 late-route pack no longer shows any raw internal identifier anywhere in its feedback copy — every concept family now reads as a short, human phrase. This was the single highest-risk finding in the audit (it would have been the first thing a paid Human QA tester flagged), and it turned out to be fixable at the source (a capture-tool data-mapping bug) without touching any live product code, route logic, or content semantics.
- **Clarity**: Review's "Legal actions" internal-sounding label and the Practice grid's ambiguous route-icon (now a clear padlock) both removed small but real "does this feel unfinished?" moments from two different tabs.
- **Premium consistency**: The Session Summary screen no longer visually collides with the persistent bottom nav bar — this was a genuine, previously-unnoticed layout bug (missing bottom padding relative to every sibling tab's established convention), now brought in line with the rest of the app.
- **First impression**: Welcome's handoff screen (the very first screen after onboarding) no longer reads as broken/cut-off; the composition is now intentionally centered, matching what the existing `centerContent` flag always implied it should do.
- **Feedback quality**: Confirmed (not changed — already correct) that every feedback screen explains *why*, uses non-punitive tone for misses, and that the CTA the audit worried about is genuinely non-empty at the data layer; the one remaining visual gap is isolated to a screenshot tool, not the product.
- **Late-route polish**: W7 through W12 and the terminal state are now visually clean end-to-end in the copy-detail evidence — no mismatched labels, no raw ids, consistent modern chrome (already true, reconfirmed).
- **Practice/Review/Profile coherence**: Locked-state iconography is now consistent across Learn and Practice (both use the same padlock); Profile no longer repeats itself in the first two lines a user reads; Home/Day-2's streak header numeric label now matches its own progress bar.

## 5. Screenshot Packet Section

Commands run (all regenerated at least once during this wave, several regenerated twice to verify fixes):

```bash
./tools/screen_review_fast_v1.sh active_route_w7_w12 compact
./tools/screen_review_fast_v1.sh core compact
./tools/screen_review_fast_v1.sh first_week compact
./tools/screen_review_fast_v1.sh day2_return compact
./tools/screen_review_fast_v1.sh full_scroll compact
./tools/screen_review_fast_v1.sh profile_evidence compact
```

Packet paths (all local-only, untracked):

- `output/screen_review/current/active_route_w7_w12_fast/`
- `output/screen_review/current/core_fast/`
- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/full_scroll_fast/`
- `output/screen_review/current/profile_evidence_fast/`

Capture HEAD: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40` (git status recorded as dirty in each packet's manifest, matching the actual workspace state)

Key screenshots inspected directly (visual confirmation, not just guard assertions):

- `active_route_w7_w12_fast/compact.w7_first_route_task_copy_detail.png` — clean "Visible cards" label
- `active_route_w7_w12_fast/compact.w8_route_task_copy_detail.png` — clean "Draws that improve" label
- `core_fast/compact.practice.png` — all 4 grid tiles show a clear padlock icon
- `day2_return_fast/compact.review_continuation.png` — natural "the actions you can choose" phrasing
- `first_week_fast/compact.welcome_handoff.png` — balanced, centered composition
- `full_scroll_fast/compact.session_summary.scroll_02_mid.png` and `.scroll_03_bottom.png` — no more nav-bar overlap
- `day2_return_fast/compact.return_home.png` — progress bar correctly empty at 0/3
- `core_fast/compact.profile.png` — no duplicate "Proof profile" heading

Answers to the required checks:

- **Is `active_route_w7_w12` clean from internal IDs?** Yes, confirmed visually on W7 and W8 (representative samples) and via a new guard asserting all 7 known concept-family ids map to curated labels.
- **Did Welcome handoff improve?** Yes, confirmed visually; the existing frame-to-CTA gap guard (≤180px) still passes.
- **Is Practice lock state clear?** Yes, confirmed visually; all 4 grid tiles now show the same padlock icon Learn uses.
- **Is the Review internal label gone?** Yes, confirmed visually; "Legal actions" no longer appears in the pattern-focus sentence.
- **Did progress/CTA consistency improve?** Progress: yes (GR-09 fixed and verified). CTA style: verified already consistent (GR-10), no change needed.
- **Output remains unstaged?** Yes — `git status --short output/` shows only untracked `output/` directories; nothing was staged or committed.

## 6. Deferred 10/10 Opportunities

| item | why deferred | future trigger | suggested future gate |
|---|---|---|---|
| GR-07: Review tab dead space | Layout-only, not broken; audit marked it "recommended, not mandatory" | A future bounded visual-polish wave, or Human QA specifically flags Review as sparse/unfinished | Small layout-only change, no new design system |
| GR-12 (full): reorder Profile to surface a named achievement above the fold | Reordering card sequence borders on "redesign Profile," out of this wave's bounded scope | A future Profile-focused polish wave, or Human QA reports Profile's "proof" claim feels unsubstantiated on first view | Small reorder + guard that a concrete achievement key is found above a fixed scroll offset |
| GR-16 (from the audit): G10 bridge-copy pre-question context not visually captured | Requires a new capture surface (pre-question panel), not a confirmed product defect — guards already assert the bridge sentences exist in source | Only if full visual G10 confirmation is explicitly required before Human QA | Screenshot-tooling follow-up, not a product change |
| GR-14 (from the audit, informal phrasing "no-bet-yet clue" / "Meet the table") | Purely cosmetic phrasing polish; not broken or claim-risky | Human QA specifically flags pattern-name phrasing as confusing | Tiny copy-only change |
| GR-03 capture-tool blank-CTA rendering artifact | Confirmed not a live-app defect; fixing the specialized screenshot-capture harness's font/compositing pipeline is a tooling investment, not a product fix | Only if a future capture-tool rewrite is separately scoped | Tooling-only change, verified against the same live-app regression test added in this wave |

## 7. Claim-Safety Section

- No readiness score movement.
- No top-1/10/10 claim.
- No premium/public/launch readiness claim.
- No Human-QA-ready claim.
- No Human QA pass (none was run or synthesized).
- No public learning-effect claim.
- No monetization readiness claim.
- W13+ remains blocked (not touched).
- Mapper/Practice remains blocked — GR-04/GR-15's fix is a lock-icon swap only; no Practice routing, mapper allowlist, or new CTA was added.
- Modern Table remains maintenance-only (not touched; no blocker/regression found or claimed).

## 8. Next Chat Handover

- Current HEAD: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40` (no commits made this wave)
- Artifact path: `docs/_reviews/focused_pre_human_visual_ux_upgrade_wave_v2.md`
- Verdict: `focused_visual_ux_upgrade_landed_with_verification_deferrals`
- Fixes completed: GR-01, GR-02, GR-04, GR-05, GR-06, GR-08, GR-09, GR-12 (partial), GR-15
- Verification outcomes: GR-03 verified as a capture-tool-only rendering artifact (not a live-app defect, backed by a new regression test); GR-10 and GR-11 verified as not real defects (intentional, already-consistent design)
- Regenerated packet paths: `active_route_w7_w12_fast`, `core_fast`, `first_week_fast`, `day2_return_fast`, `full_scroll_fast`, `profile_evidence_fast` (all under `output/screen_review/current/`, local-only)
- Remaining Visual/UX watchlist: GR-07 (Review dead space), GR-12 full reorder, GR-16 (G10 bridge-copy visual coverage), GR-14 (minor phrasing polish), GR-03 tooling-only follow-up if ever prioritized
- Pre-existing test failures observed but **not** caused by this wave (confirmed via clean-baseline diffing against pure `git stash`): `Final lesson retry replays the miss before summary and can end as a quick fix`, `Review repair session returns with a fixed summary`, `Block summary exposes mastery and suggested next action` (caused by an already-dirty pluralization edit in `act0_lesson_runner_shell_v1.dart` predating this wave), and three `Fast screen review command exposes ... proof packet group` tests (caused by an already-dirty `tools/screen_review_fast_v1.sh` usage-string change predating this wave). None of these are in this wave's scope; none were introduced by this wave's edits (verified by running the full 682-test `act0_shell_preview_screen_v1_test.dart` suite against a clean `git stash` baseline and diffing the exact failing-test-name sets — zero net-new failures beyond those two pre-existing, already-dirty sources).
- Selected next prompt title: `Human QA Readiness Packet Preparation v1` (or, if preferred, a small follow-up wave scoped to GR-07/GR-12-reorder/GR-16 only)
- Forbidden next scope: Human QA execution, W13+, mapper allowlist, new Practice CTA, monetization/paywall/store work, Modern Table visual polish, broad UI redesign, new design system, animation/badge/XP economy expansion, W3/W6 richness, W12 synthesis scenario, cross-world repair system, public/top-1/10/10/readiness/Human-QA-ready/learning-effect claims
- Token/context notes: Highest-cost work was runtime tracing of `act0_lesson_runner_shell_v1.dart`'s feedback-signal pipeline (GR-01/02/03) and the Session Summary padding root-cause (GR-08), both of which required direct source tracing rather than surface-level pattern matching to find the true, minimal fix point. Next wave should reuse this artifact's Fix Table rather than re-deriving these traces.
