# S01 Truth Recovery PASS (bounded D0) -> S02 Screen Audit ACTIVE

Status: evidence-constrained acceptance receipt, 2026-10-09 Asia/Baku.
Principal: `docs/plan/MASTER_PLAN_v5.0_TOP1_BULLDOZER_SSOT.md` §10A.
Current branch base: `main dd1f25759d037331d473ab1683df76d7023342e6`; tree `57c1670afa165f8fc6f8dd15000c5c5cbe35ec02`.
No Flutter/product, Modern Table, #224, P02 or Human changes authorized by this receipt.

## S01 acceptance

**S01 verdict: PASS for current product truth recovery only** (source/route ownership, historic finding reconciliation, versioned visual evidence, explicit missing-evidence ledger). **It is NOT a PASS on whole-product visual quality or post-#250 installed-native usability**. S02 owns actual present-day full-screen evaluation.

- Original V3 native GUI audit: source `6a26a16e162ef5cf5e70c65602af48fca9cd79d6`, native iPhone 16e iOS 26.2 English, 2026-10-09, 57 indexed state frames, 62 PNG and seven MP4. Source report `PROGRESS_REPORT_RU.md`: `REAL_GUI_VISUAL_AUDIT=NOT_COMPLETE`. Indexed manifest generated `2026-10-09T10:18:37+00:00`. Original local root `/Users/elmarsalimzade/Sharky_GUI_Audit_20261009T092100Z/`; do not republish its visual grades as current.
- Compared current `dd1f2575` to post-PR250 merge `e962a6ec`; GitHub compare reports **only** two Markdown files changed. Product code is equivalent. The current source clone is local-only `/Users/elmarsalimzade/Sharky_Design_Truth_S01_20261009/readonly/live_main`, exact HEAD and tree verified.
- Current-code-equivalent W1 machine raster re-run on `284ed085b583df854b43084460be84a9056cd741`, 375x812 at 1.0 text scale, 2026-10-09 23:19-23:20 +04: **PASS** on existing `action_sequence_canonical_raster_capture_v1_test.dart`, including W1 landing/theory, real semantic option controls, correct/wrong feedback, targeted repair and recheck. Output `/Users/elmarsalimzade/Sharky_Design_Truth_S01_20261009/CURRENT_CODE_EQUIVALENT_W1_COMPACT/`; compact capture log next to it. The harness uses controlled direct state: MACHINE_RENDER not unassisted native or Human proof.
- Original native assisted Quick Hint/Full Theory Recall actual restart -> independent matched recheck PASS at earlier source tree `2eacfa500396f1d253c4cc8c270a2a39cf38c489`; neither Human proof nor current full GUI PASS.
- All F01-F12 have a current source/evidence/classification row below. Later native world unlocks, due Review, 1.4x text and whole-product native post-#250 captures remain explicitly UNKNOWN, not failed or silently accepted.

## Current Act0 full surface map

| User-facing job | Current source owner under lib/ui_v2/act0_shell | V3 native state IDs | Current status |
|---|---|---|---|
| Placement / fresh entry | `act0_shell_preview_screen_v1.dart` boot gate, `act0_placement_shell_v1.dart` | S01-S02/S28-S29 | source current; GUI current unknown |
| Welcome demo/handoff | `act0_welcome_shell_v1.dart` | S03-S06/S28-S29 | source current; F04 source divergence |
| Home | `act0_home_shell_v1.dart`, preview progression | S07/S09/S16/S56; R01-R03 | source current; F02 earned-machine repaired |
| Learn/Worlds | `act0_learn_path_shell_v1.dart`, preview world routing | S30-S34/S48 | source current; W3+ native unlocked unknown |
| Theory/choice/feedback/table | `act0_lesson_runner_shell_v1.dart`, `act0_learning_scene_v3.dart` | S34-S39/S43-S47 | source current + scoped W1 machine raster |
| Practice | `act0_play_shell_v1.dart` | S08/S49-S51 | source current; current native unknown |
| Review / exact repair | `act0_review_shell_v1.dart` and repair queue owner | S17-S22/S52-S55 | source current; F09 slug copy source |
| You / Profile / Settings | `act0_profile_shell_v1.dart`, `act0_profile_evidence_projection_v1.dart` | S23-S27 | source current; F11 settings mismatch |
| Completion / summary | `act0_lesson_runner_shell_v1.dart`, `act0_learning_run_payoff_v1.dart` | S40-S42/S47 | source current; F08 native copy unverified |
| Return / durability | preview persistence, `act0_durable_learning_time_contract_v1.dart` | S57/video07 | source current; genuine day-2 native unknown |

Current mount switch in `act0_shell_preview_screen_v1.dart` approximately lines 5350-6530 retains one canonical route and mounts Welcome, Home, Learn, Play, Review, Profile; no dormant/legacy route silently replaces Act0.

## Finding disposition ledger: old V3 vs current main

| ID | Current D0 disposition | Current exact-source witness / scope boundary | Missing falsifier (S02) |
|---|---|---|---|
| F01 infinite first-entry height | **RESOLVED_WITH_MACHINE_EVIDENCE** | PR #246 BEFORE-red/AFTER-green focused 4-option layout; native after #250 unknown | current compact native cold first start |
| F02 unearned fresh 3d/4d streak and XP | **RESOLVED_WITH_MACHINE_EVIDENCE** | PR #245 fresh earned/persisted projection + focused tests; does not close F03 | current fresh Home/Profile only if material concern |
| F03 sample skill scores/Practiced | **UNKNOWN_CURRENT_VISUAL** | profile-evidence owner filters assisted and has sample threshold; placement baseline distinct | current fresh and low-evidence Profile |
| F04 Welcome Try same clue skips correction | **CURRENT_SOURCE_CONFIRMED / VISUAL_UNVERIFIED** | `act0_welcome_shell_v1.dart` demo `onContinueReview` around 128-132 goes straight to handoff; generic wrong `Try same clue` label in runner around 7644-7656 | current wrong-Welcome render and actual onTap |
| F05 truncated cause | **UNKNOWN_CURRENT_VISUAL** | `act0_learning_scene_v3.dart` line ~311 has 2-3 maxLines and ellipsis; not proof of lost meaning | current critical long-copy wrong and repair |
| F06 card/CTA occlusion | **UNKNOWN_CURRENT_VISUAL** | shared runner dock/layout changed in #246; old S36 not current evidence | current compact decision with cards/CTA |
| F07 theory 5/4 | **UNKNOWN_CURRENT_VISUAL** | theory beat/teaching index owned by runner | current exact phase step sequence |
| F08 summary run count drift | **UNKNOWN_CURRENT_VISUAL** | run and evidence history have separate owners; old S40-47 ambiguous | two actual consecutive runs/history |
| F09 raw/slug Review labels | **CURRENT_SOURCE_CONFIRMED / VISUAL_UNVERIFIED** | `act0_review_shell_v1.dart` ~1282-1315 slugifies title and returns hyphenated `clue` | real current Review mistake card |
| F10 awkward Profile skill word wrap | **UNKNOWN_CURRENT_VISUAL** | `act0_profile_shell_v1.dart` compact card / sheet owner | current compact open skill sheet |
| F11 Account/settings copy vs first start tools | **CURRENT_SOURCE_CONFIRMED** | `act0_profile_shell_v1.dart` ~350-420 promises language/notification/support; tap opens sheet at ~3262 with replay Welcome/retake Placement only | on-device card and sheet severity |
| F12 seat/rail silhouette | **DEFERRED_PROTECTED_VISUAL_UNKNOWN** | Modern Table frozen and #224 separate | only if actual gameplay/learner occlusion proven |

Independent semantic fixes beyond F-row numbering: PR #248 corrected not-sure/suboptimal announced as correct, PR #250 corrected BB/HJ mapping and invalid abstract option seat-tap proxies. Source/machine proof, not blanket Human or native acceptance.

## Missing evidence (carried deliberately, not S01 failure hidden as PASS)

Highest priority actual-screen targets for **S02**: F04 Welcome wrong-CTA/handoff; F09 Review readable mistake clue; F11 Profile settings promise; F05/F06 truly lost explanation/card context; F03 fresh skill-provenance; F07 counter; F08 run vs history; F10 compact sheet. Additional coverage: late W3/W6/W8/W11/W12 only when legitimately earned/unlocked; large phones; 1.4x stress; real elapsed due Review/Day-2. No full repeat of 57 native frames. No fake progression/answer leakage.

A D0 map can state current code and unknown pixels without awarding a contemporary visual score. S02's DoD expressly requires full current rendered route/surface scorecard and learner-effect hypotheses; absence of those does **not** become S01 machine falsehood or an S02 PASS.

## Task transition

`S01 = PASS_D0_TRUTH_RECOVERY_ONLY`
`ACTIVE_TASK_ID = S02` (`D1_HOLISTIC_SCREEN_AUDIT`).
`NEXT_TASK_ID = S03`, CONDITIONAL on evidenced S02 PASS.
`CURRENT_IMPLEMENTATION_FAMILY = NONE`.
`P02 = HOLD / NOT_ADMITTED`.
`S03_12_APP_RESEARCH = ACCEPTED_INPUT_PENDING_SEQUENCE`.
`MODERN_TABLE = MAINTENANCE_MODE`; `PR_224 = SEPARATE_NOT_ADMITTED`.

Full local evidence artifacts are `CURRENT_PRODUCT_VISUAL_TRUTH_MAP_v1.md`, `S01_FINDINGS_STATUS_v1.csv`, `S01_MISSING_EVIDENCE_LEDGER_v1.md`, `S01_RECEIPT_v1.md`, and `S02_ACTIVE_SCREEN_AUDIT_v1.md` under `/Users/elmarsalimzade/Sharky_Design_Truth_S01_20261009/`.

No Human, P02 owner approval, design direction, product-code wave, commercial claim or release gate is implied.
