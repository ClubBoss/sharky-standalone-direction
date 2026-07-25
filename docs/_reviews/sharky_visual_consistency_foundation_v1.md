---
status: "sharky_visual_consistency_foundation_landed"
status_source: "derived"
doc_date: "2026-07-02"
baseline: "e37361a33bb6"
generated_by: "docs_frontmatter_v1"
---

# Sharky Visual Consistency Foundation v1

## 1. Verdict

`sharky_visual_consistency_foundation_landed`

## 2. Preflight

- `pwd`: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- `git status --short --branch`: `codex/apply-owner-patch-sequence-a-b-c-d-v1`, clean except untracked `output/**`.
- `git rev-parse HEAD` (before implementation): `e37361a33bb6f075dd5eb853396b00476e9807f7` — matches the expected HEAD.
- `git diff --name-only` / `git diff --cached --name-only`: empty before implementation.
- `git status --short output/`: only pre-existing untracked evidence packets from prior waves.
- `graphify hook-check`: clean.
- Generated macOS drift (`macos/Flutter/GeneratedPluginRegistrant.swift`) reappeared twice during test/analyze runs and was restored via `git checkout --` before commit each time.

No `blocked_by_dirty_scope` condition encountered.

## 3. Capsule/authority check

`ACTIVE_ROUTE_CAPSULE_v1.md` and `VISUAL_PROOF_CAPSULE_v1.md` (both freshness date 2026-07-02, verified HEAD `f9a1909f`, one lane behind current HEAD) both name `Sharky Visual Consistency Foundation` as the immediate next step after Session Summary Gold Containment — consistent with this task, not stale. `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` explicitly defers "Sharky Character expansion" and "Sharky Soul / Compact Coach Layer" to a future wave unless reopened by evidence — confirms this task's bounded "visual grammar only, no growth/emotional-state system" framing is correct and does not conflict with roadmap authority.

## 4. Active Sharky usage inventory

| Owner file | Screen/context | Asset source | Size | Container/shape (before) | Role | Changed? |
| --- | --- | --- | --- | --- | --- | --- |
| `act0_welcome_shell_v1.dart` (`_WelcomeSharkyPresenterTileV1`) | Welcome handoff | `assets/mascot/poker_shark_*.svg` | 64/80dp | Rounded-square (radius = size×0.28), navy fill, primary-tone border, shadow | companion | No — already rounded-square, accepted, left untouched |
| `act0_sharky_presence_v1.dart` (`Act0SharkyPresenceBubbleV1` → `_SharkyMascotFrameV1`) | Session Summary hero | `assets/images/mascot/sharky_*.png` (animated) | 64/68dp | Rounded-square (radius = size×0.34), shadow only (simpleFrame) | companion | Internal only — radius now reads from the shared `sharkyTileRadiusRatio` constant instead of an inline literal; zero visual change |
| `act0_lesson_runner_shell_v1.dart` (`Act0SharkyMascotV1`) | Correct / wrong / repair feedback card | same PNG family (animated) | 30/34/40dp (and a 16dp rail micro-icon) | **`BoxShape.circle`** — the stated "feedback circle" inconsistency | inline | **Yes** — shape changed to rounded-square, same radius formula as companion |
| `act0_home_shell_v1.dart` (`_HomeIdentityRowV1`) | Home header identity row | same PNG family (animated) | 38dp outer / 26dp mascot | **`BoxShape.circle`** with tone fill + border — the stated "header/avatar" inconsistency | identity | **Yes** — shape changed to rounded-square, same radius formula |
| `act0_placement_shell_v1.dart` (`act0_shell_placement_brand_sharky`) | Placement brand beat | PNG family (animated) | 70dp | Rounded-square (radius 22, ratio ≈0.31) | identity-like brand mark | No — not in the required inspection list (Welcome/Summary/feedback/Home), already rounded-square, no concrete defect |
| `act0_learn_path_shell_v1.dart` / `Act0SharkyGuideCardV1` | Learn guide card | PNG family (animated) | 72/92dp | Rounded-square (radius = size×0.34) via the shared companion frame | companion-family, Learn-owned | No — Learn is explicitly forbidden scope this PR; frame already shares the same radius logic |
| `act0_profile_shell_v1.dart` (`act0_shell_profile_sharky_identity`) | Profile identity | PNG family (animated) | — | Not inspected in detail | identity | No — Profile explicitly forbidden scope this PR |
| `act0_review_shell_v1.dart`, `act0_play_shell_v1.dart` | Review / Play coach lines | n/a | n/a | Text-only (`act0SharkyCoachLineForMomentV1`), no mascot image | n/a | No — no visual mascot present; matches "Review does not currently need Sharky" |
| `act0_lesson_runner_shell_v1.dart` (`_SharkyCuePillV1`) | (dead code) | n/a | n/a | Defined but zero instantiations anywhere in the repo | n/a | No — pre-existing dead code, not an active usage, out of scope to remove |

## 5. Shared seam decision

Chose the lighter-weight **shared token/style helper** over a new widget/component, per Stage 2's explicit fallback guidance. Added one constant, `Act0ShellTokensV1.sharkyTileRadiusRatio = 0.34`, matching the ratio the companion frame (`_SharkyMascotFrameV1`) already used inline. This single ratio now drives the corner-radius logic for all three role families (companion, inline, identity) without introducing a new mascot widget, enum-based variant system, or animation API.

Why not a full `SharkyPresenceV1` component: the only real defect was two call sites hard-coding `shape: BoxShape.circle` instead of a rounded rectangle — a one-property fix at each site. Wrapping that in a new shared widget would have meant threading a new component through `Act0FeedbackShellV1` and `_HomeIdentityRowV1` (changing their internal structure) for no behavioral gain over just fixing the decoration in place and sharing the radius constant. This keeps the diff to 4 files and avoids "building a large mascot framework" or "future-proof abstraction without current consumers," both explicitly disallowed.

## 6. Companion role

No changes. Welcome's presenter tile (`_WelcomeSharkyPresenterTileV1`, radius ratio 0.28) and Session Summary's hero bubble (`_SharkyMascotFrameV1`, radius ratio 0.34, now reading from the shared constant) were left exactly as they render today — both already rounded-square, both already accepted. The residual radius-ratio delta between them (0.28 vs 0.34) is visually imperceptible and touching it would have meant reopening two explicitly-protected, already-accepted screens for a change with no visible payoff, so it was left alone by design.

## 7. Inline role

`Act0SharkyMascotV1` (`lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`), used inside `Act0FeedbackShellV1` for correct/wrong/repair feedback (and a small 16dp rail glyph), had its `DecoratedBox` changed from `shape: BoxShape.circle` to `borderRadius: BorderRadius.circular(size * Act0ShellTokensV1.sharkyTileRadiusRatio)`. Size, animation (existing scale/tilt `TweenAnimationBuilder`), position, and all feedback layout/copy are untouched — only the silhouette shape changed, from a plain circle to the same rounded-square family used everywhere else. Confirmed visually on both correct and repair feedback screenshots (mascot now reads as a small rounded-square tile, still clearly secondary to the verdict/reason text).

## 8. Identity role

`_HomeIdentityRowV1` (`lib/ui_v2/act0_shell/act0_home_shell_v1.dart`), the 38dp Sharky avatar next to the "Sharky · Poker from Zero" header label on Home, had its `BoxDecoration` changed from `shape: BoxShape.circle` to `borderRadius: BorderRadius.circular(38 * Act0ShellTokensV1.sharkyTileRadiusRatio)`. Fill color, border color, size, and position are unchanged — only the silhouette shape changed. Confirmed visually: the Home header avatar now reads as a small rounded-square tile instead of a plain tone-tinted circle.

## 9. Screens changed

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` — inline feedback mascot shape.
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart` — Home identity avatar shape.
- `lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart` — companion frame now reads the shared radius constant (zero visual change).
- `lib/ui_v2/act0_shell/act0_shell_tokens_v1.dart` — added `sharkyTileRadiusRatio` constant.

Two screen owners touched (feedback surface inside the lesson runner, Home), plus the two shared token/component files — within the Stage 4 bound of 3 major screen owners + 1 shared component/token owner.

## 10. Screens intentionally unchanged

Welcome, Session Summary, Review, Practice, Profile, Learn, table felt/geometry, nav, W13+, monetization, motion timing, and the Placement brand tile (already rounded-square, not in the required inspection list). No new Sharky appearances were added anywhere Sharky is not already present.

## 11. Screenshot evidence

Regenerated via:
- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh first_week compact`

Local-only evidence written to `output/sharky_visual_consistency_foundation_v1/` (not committed):
- `sharky_usage_before_after.png` — feedback card and Home identity row, before (`cta_learn_cleanup_pr_v1/after/*`, the last capture prior to this wave) vs. after.
- `sharky_companion_surfaces.png` — Welcome presenter tile and Session Summary hero side by side, confirming both are unchanged.
- `sharky_inline_surfaces.png` — correct-feedback and repair-feedback mascot close-ups, confirming the rounded-square shape now reads consistently across both moods.

Visual confirmation: feedback and Home avatars now read as the same rounded-square family as the companion tiles; Welcome and Session Summary are pixel-identical to their prior accepted state; no layout shift, no copy change, no new Sharky appearance.

## 12. Tests/validation

- New: `test/ui_v2/sharky_visual_consistency_foundation_v1_test.dart` (4 tests) — asserts the shared radius ratio value, that the correct/repair feedback mascot resolves to a rounded rectangle (not a circle) at the expected radius, and that the Home identity avatar resolves to the same rounded-square formula.
- Regression, all green: `act0_result_feedback_rhythm_surface_v1_test.dart` (11), `wave4_2_premium_identity_claim_cleanup_v1_test.dart` (3), `wave4_5_motion_evidence_repair_feel_v1_test.dart` (4), `session_summary_gold_containment_v1_test.dart` (3), `wave4_3_premium_reward_session_summary_payoff_v1_test.dart` (3) — 28/28 total.
- `flutter analyze` (file-scoped and project-wide): no issues found.
- `graphify hook-check`: clean.
- `git diff --check` / `git diff --cached --check`: clean.
- Additional due-diligence check: `test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Home"` showed 11 pre-existing failures (checklist-row/daily-mix content assertions unrelated to mascot shape). Verified via `git stash` that the identical 11 failures occur on the unmodified baseline HEAD `e37361a3`, confirming these are pre-existing and not a regression introduced by this change.
- `macos/Flutter/GeneratedPluginRegistrant.swift` generated drift restored before commit.

## 13. Scope safety

Touched only the inline feedback mascot's decoration shape, the Home identity avatar's decoration shape, and a shared radius constant/its one existing consumer. No copy, route logic, CTA behavior, telemetry, progression, or motion timing changed. No new Sharky appearances. No generic shark, emoji, new illustration, or generated art — the existing PNG/SVG mascot assets and their existing mood mapping are unchanged. No emotional states, growth/evolution, or achievements added. Welcome and Session Summary compositions untouched. Review, Practice, Profile, Learn, table geometry, nav, and monetization untouched. Nothing pushed. No `output/**` staged or committed.

## 14. Remaining visual gaps

- The companion family still has two slightly different radius ratios in practice (Welcome's hand-rolled tile at 0.28 vs. the shared `_SharkyMascotFrameV1`/inline/identity family at 0.34). This was a deliberate risk-minimization choice (see §6) rather than an oversight — revisiting it would mean reopening the accepted Welcome screen for an imperceptible change.
- Welcome's presenter tile still renders a different underlying asset format (SVG mood icons) than Session Summary/feedback/Home (animated PNG mood illustrations). Unifying the asset format itself was out of scope for a "container treatment" PR and would risk visibly changing Welcome's accepted art, so it was left alone.
- Placement's brand tile (70dp, radius ratio ≈0.31) was not touched; it is already close to the shared family and wasn't in the required inspection list, but a future pass could align its exact ratio for full consistency.

## 15. Next recommendation

`Static Premium Visual Regression Check`
