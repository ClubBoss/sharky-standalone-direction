# SHARKY — EN V1 Selected Screen Audit Index
Date: 2026-10-28 (Asia/Baku)
Status: AUDIT HANDOFF ONLY / NOT AN ACCEPTANCE GATE
Reference: iPhone 14 Pro, English, 393x852 logical / nominal 1179x2556 physical
Repo baseline main: b0a6b4a692b6feb0f9e0cae39035a153045e99c5 (docs-only)
Authority: docs/plan/MASTER_PLAN_v5.0_TOP1_BULLDOZER_SSOT.md, live AGENTS.md, docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md, live Issue #287, owner EN_V1_UI_ROUTE Sheet.


> UPDATE 2026-10-29: [Curated original screenshots have been published](../evidence/EN_V1_AUDIT_20261029/README.md). Any NOT_UPLOADED rows below describe the *historical 2026-10-28 snapshot*. Latest final Home and one-binary integrated native screenshot pass are still pending.

## PURPOSE

One stable GitHub entry point for a separate visual/product auditor of the **existing** opt-in Sharky Academy screen candidates. It cross-references the selected/provisional Draft PRs at their exact authoring HEADs. It does NOT recapture, regenerate, or assert the final native screenshots. Production code and PRs #308-#315 are untouched; protected #224 is untouched. For dynamic states, written PR assertions are claims to validate, not substitute for original captured pixels.

## Screen index — actual source and evidence

| Surface | Candidate | Exact PR authoring HEAD | Actual render/source path | Original native PNGs publicly committed? | Additional evidence location / caveat |
| --- | --- | --- | --- | --- | --- |
| Home | #308 Cinematic teal | a3727d3e6b5c4fa3673d08976aceab3c3e5b7702 | `lib/ui_v2/act0_shell/act0_home_north_star_preview_v1.dart` | **EARLIER FIXTURE PNGs ONLY**, see below; FINAL native PNG NOT_UPLOADED | local `output/home_reference_fidelity_20261026/native_owner_correction/raw/home_14pro_progressed.png`, latest final PNG hash 418772b1...; flagged ON via SHARKY_HOME_NORTH_STAR_PREVIEW |
| Learn | #309 Cinematic Path A | b8d7fffaf64ebda9e9e1a5b437d3838c14679cb0 | `lib/ui_v2/act0_shell/act0_learn_cinematic_path_a_v1.dart` | **NOT_UPLOADED** | local `output/learn_cinematic_path_a_20261026/scroll_proof`, native 4+scroll images; persisted fixture, not genuine earning |
| Worlds | #310 Cinematic B | dc4892dde53c442f98664de22c9b02ee7b910913 | `lib/ui_v2/act0_shell/act0_worlds_b_v1.dart` | **NOT_UPLOADED** | local `output/worlds_b_v1_20261026`; native overview/locked/back/catalog/W12 scroll, source-valid fixture |
| Practice | #311 Cinematic hybrid | 394974c6d6802bba7fc35d37ca1e26794bc78f53 | `lib/ui_v2/act0_shell/act0_practice_hybrid_v1.dart` | **NOT_UPLOADED** | local `output/practice_hybrid_v1_20261027`; ten native PNGs with source-valid injected saved states |
| Review | #312 V4 gateway | f835e90565678386cd4ce78cca11c811a0897ac0 | `lib/ui_v2/act0_shell/act0_review_v4.dart` | **NOT_UPLOADED** | local `output/review_v4_20261027`; 15 native PNGs, source-backed fixtures not natural due |
| Motivation/Return | #313 docs overlay | 363ac56903d783a43d10e1d2a42c008a27cdf750 | `docs/strategy/SHARKY_MEANINGFUL_RETURN_PRODUCT_CONTRACT_20261027.md` | N/A: documentation, **not screen implementation** | No new reward economy; do not score as visual production |
| You / Profile | #314 v2.3 | ea04197dd4ceffe807d757e25fc8b774216fd5a9 | `lib/ui_v2/act0_shell/act0_you_v23.dart` | **NOT_UPLOADED** | local final `native/you_progressed_both.png`, `you_details_middle.png`, `you_details_scroll*.png` under author evidence; injected profile fixture and separate true task/restart receipts |
| Settings | #315 Quiet Control | 03ef96979ec37a37f10144e3bf6dfdbe0a7a0850 | `lib/ui_v2/act0_shell/act0_settings_quiet_control_v1.dart` | **NOT_UPLOADED** | local `/Users/elmarsalimzade/.codex/worktrees/settings-a-quiet-control/Sharky_1.0/output/settings_a_20261028/native/`; 14 original PNGs. Audible sound BLOCKED by inherited backend; legal production signoff OPEN |

Candidate PR links:
- Home: https://github.com/ClubBoss/sharky-standalone-direction/pull/308
- Learn: https://github.com/ClubBoss/sharky-standalone-direction/pull/309
- Worlds: https://github.com/ClubBoss/sharky-standalone-direction/pull/310
- Practice: https://github.com/ClubBoss/sharky-standalone-direction/pull/311
- Review: https://github.com/ClubBoss/sharky-standalone-direction/pull/312
- Motivation: https://github.com/ClubBoss/sharky-standalone-direction/pull/313
- You: https://github.com/ClubBoss/sharky-standalone-direction/pull/314
- Settings: https://github.com/ClubBoss/sharky-standalone-direction/pull/315
- Protected table/cast — not for auto merge or incidental visual editing: https://github.com/ClubBoss/sharky-standalone-direction/pull/224

## Existing GitHub screenshots — Home only, prior fixture revision

Stored on **PR #308**, NOT current final HEAD-native capture:
- https://github.com/ClubBoss/sharky-standalone-direction/blob/a3727d3e6b5c4fa3673d08976aceab3c3e5b7702/docs/design/evidence/S12V_HOME_B1_NATIVE_14PRO_20261025/fixture_home_sample.png
- https://github.com/ClubBoss/sharky-standalone-direction/blob/a3727d3e6b5c4fa3673d08976aceab3c3e5b7702/docs/design/evidence/S12V_HOME_B1_NATIVE_14PRO_20261025/fixture_home_return_sample.png
- https://github.com/ClubBoss/sharky-standalone-direction/blob/a3727d3e6b5c4fa3673d08976aceab3c3e5b7702/docs/design/evidence/S12V_HOME_B1_NATIVE_14PRO_20261025/README.md

**Do NOT promote these earlier images to final-head 14Pro native acceptance.** The original Home final capture is known in PR description but not available as repository file.

## Screenshot integrity and acquisition requirement

At this handoff, the user's Mac / Desktop Commander device is offline. The ChatGPT GitHub connector can access text/code/PR metadata; it cannot read the Mac's ignored `output/` folders. No screenshot files were invented or re-rendered from the Dart source.

Before cross-screen screenshot beauty scoring:
1. On user-authorized Mac, acquire original PNGs for each of the seven actual screen surfaces from the noted final-head local evidence directories, including meaningful alternate states/scrolls.
2. Copy original files, **no recompression, upscaling, visual regeneration, synthetic contents or inferred SHA**. Collect SHA256/size, actual captured resolution, source HEAD, app/kernel hash, device/iOS and fixture-vs-genuine state. Screenshots with older revisions remain labeled historical.
3. Commit on a **separate read-only evidence branch** under `docs/design/evidence/EN_V1_AUDIT_20261028/<screen>/` with a manifest and original artifacts. Never modify canonical product branches. No merge needed for review.
4. Compare against actual source and distinguish source-true fixtures, naturally earned action, real persistence, naturally due behavior and Human evidence. Never declare S12.V, P02/Human or production PASS from visuals alone.

## Auditor scope and decisions

- **MODEL:** GPT-6, REASONING: High, MODE: independent read-only product/visual audit, QUOTA: one bounded visual pass; no repeated generic code scan.
- Inspect shared system coherence, premium materials/lighting/photography reuse, contrast, typographic hierarchy, exact native safe areas, SVG optical weights, 44pt targets, page/scroll overflow, and handoff continuity.
- Screen-specific truthful copy/interaction: Home next justified action; Learn current/previous/next and authentic availability; Worlds locks; Practice source-matched daily and optional extras; Review real open/repair/due-only; You earned proof; Settings saved controls, true audio unavailable and legal scope.
- Distinguish P0/P1 from P2 cosmetic. Report reproducible issues with exact **screenshot + source SHA** and lowest-scope remedy. `DO_NOTHING` allowed.
- Do not start a Flutter writer, edit player/table art, re-theme production, change XP/due/reward engines, merge Draft PRs, touch #224, or admit Human. Existing source/UI claims on Draft branches are not automatically present in default-off production.
- If the screenshots are still absent, return `SOURCE_ONLY_AUDIT / SCREENSHOT_EVIDENCE_BLOCKED` rather than inventing a visual score.

## Dependency chain and review safety

The visual candidates are sequential stacked Drafts, rather than a merged main: Home #308 -> Learn #309 -> Worlds #310 -> Practice #311 -> Review #312 -> You #314 -> Settings #315. Docs-only #313 is separate. For whole-app visuals compare consistent HEAD/integration lineage; DO NOT stitch PNGs as though from one integrated installed binary without provenance.

S12.V visual trust remains separate; original S12 P02 entry and Human still require owner gate. This index is purely for a second agent to locate work and identify absent evidence.

## Reference design boundaries for Placement + Welcome

This work is now in **pre-code design**. Use source-owned `Act0PlacementShellV1` and `Act0WelcomeShellV1` from main, reuse actual Runner/table and canonical future Sharky identity; allow room/table placeholders only clearly marked. Do not fabricate separate trophy/progress/recommendation features or a second graded Welcome drill. Current read-only design tasks may continue independently, but no production writer admitted. 
