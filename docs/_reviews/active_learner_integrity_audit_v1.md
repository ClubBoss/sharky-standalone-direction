# Active Learner Integrity Audit v1

- Status: admitted — native Act0 static audit cycle closed with non-blocking dormant-code debt (Revision 4)
- Audited HEAD (original audit base): be887aefd81ffd9e5ffdb5b45901b6809fde1660
- Published HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f (confirmed matching `origin/main`)
- Audit date: 2026-07-14
- Scope: Active W1–W6 learner journey — `content/worlds/world1..world6/v1/`, `content/world1_act0_action_literacy|table_literacy|street_flow/v1/`, rendered through `lib/ui_v2/act0_shell/` (lesson runner, placement, profile, review, welcome), plus personalization/repair/recheck/payoff contracts and route-order canon (`lib/canonical/canonical_truth_map_v1.dart`, `lib/canonical/progression_route_story_v1.dart`) and planning SSOTs (`docs/plan/MASTER_PLAN_v3.0.md`, `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`, `docs/plan/CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md`, `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`). Revision 2 additionally traced the canonical runtime load chain (`AGENTS.md` "Runtime Surface Canonical (Act0)", `act0_canonical_path_root_v1.dart`, `act0_shell_preview_screen_v1.dart`, `act0_shell_state_v1.dart`, `drill_runtime_adapter_v1.dart`) and adjudicated two owner-supplied Simulator screenshots. Revision 4 inventoried the native `Act0RunnerStateV1` content system (~250 W1-W6 runners across `_act0PreviewWorlds`) as a distinct first-class owner.
- Exclusions: Modern Table visuals; `assets/content/{intro_*,core_*,placement_test}` (confirmed dormant — not referenced by `act0_placement_shell_v1.dart` or any active shell file); `lib/archive/legacy_runners/*`; W7–W12 native runners (confirmed reachable by the same registry pattern but out of this pass's bounded scope); monetization/paywall; `.claude/worktrees/*` stale agent worktrees.
- Model: Claude Sonnet 5
- Reasoning: High / Adaptive
- Final verdict: `active_learner_integrity_admitted_with_non_blocking_debt`
- Active learner-facing P0/P1/P2 open findings: 0
- Fixed pending live validation: 1 (`ALI-SHARED-003`)
- Dormant P3 deferred: 1 (`ALI-NATIVE-SHARED-001`)

This document is a review snapshot and issue ledger only. It is not a new
SSOT and does not override the Master Plan, the Active Route Capsule,
Project Rules, AGENTS, or canonical runtime source
(`lib/canonical/canonical_truth_map_v1.dart`). Where this ledger's findings
touch canonical world identity, the canonical runtime source remains
authoritative until a maintainer accepts a specific correction here.

---

## Revision / Change Log

- **Revision 1** (2026-07-14, this audit's initial pass): established ALI-SHARED-001, ALI-W2-001, ALI-W3-002, ALI-SHARED-002 as confirmed findings.
- **Revision 2** (2026-07-14, narrow adjudication pass, same HEAD): traced the actual canonical runtime load chain for World 3 and downgraded **ALI-SHARED-001 from confirmed P1 to `deferred`** — runtime evidence (a confirmed, canonically-routed `position_checkpoint` lesson tagged `worldId: 'world_3'`) contradicts the strongest form of the original claim; see `output/active_learner_integrity_audit_v1/runtime_route_adjudication.md`. Reclassified **ALI-W3-002 from confirmed P3 to candidate** (`ALI-CAND-005`) — no exact numeric anti-thinness threshold exists in `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md` (it is a qualitative 1-5 rating, not a file-count rule), so a raw file-count observation cannot be asserted as a confirmed learner-facing defect. Moved **ALI-SHARED-002** into a new "Documentation / Agent-Truth Findings" section, excluded from learner-facing severity counts. Added two new confirmed findings from owner-supplied Simulator screenshots: **ALI-SHARED-003** (compact option-list visibility) and **ALI-W1-001** (invisible stack-size distractor). No finding was marked `accepted` or `fixed`; no product files were edited.
- **Revision 3** (2026-07-14, bounded repair/admission): synchronized **ALI-W1-001** and **ALI-SHARED-003** with `1580d52ad75b64313e644834fa0927e14bce32cc`; ALI-W1-001 is `validated_closed` and ALI-SHARED-003 remains `fixed_pending_validation` until the required installed-Simulator proof exists. Corrected every chained occurrence of w2.s14's third board card from `4h` to `4c` in `347517dcac30eb691cae0e0d5fb27c731a919a9f`, preserving the two-tone label, gutshot = 4 outs, actions, feedback, intent, telemetry, repair, and progression contracts; **ALI-W2-001** is `validated_closed`. Marked `CONTENT_PLAN_PER_WORLD_v2.1.md` as a historical MVP planning reference and removed its current-world-identity authority from `ACTIVE_CONTENT_SSOT_INDEX_v1.md`; **ALI-SHARED-002** is `validated_closed`. **ALI-SHARED-001** remains deferred and all candidates remain unchanged. Remaining live-validation debt is only ALI-SHARED-003.

**Lifecycle summary after Revision 3:** 4 confirmed records total — 2 learner-facing `validated_closed` (ALI-W1-001, ALI-W2-001), 1 learner-facing `fixed_pending_validation` (ALI-SHARED-003), and 1 documentation-only `validated_closed` (ALI-SHARED-002). No confirmed finding remains `open`; ALI-SHARED-001 remains deferred; five candidate records remain unpromoted.

- **Revision 4 — Native Act0 inventory and static audit-cycle closure** (2026-07-14, incremental extension at published HEAD `8592746e9f851f35f066f04edcd191683cce8f2f`): audited the native `Act0RunnerStateV1` content system (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart`, `act0_shell_preview_screen_v1.dart`) as a distinct first-class learner-content owner, not previously inventoried in Revisions 1-3. Discovered the canonical registry `_act0PreviewWorlds` (355 total native runners; ~253 in W1-W6 scope) mapping `worldId: 'world_1'`..`'world_6'` to titles matching `canonical_truth_map_v1.dart` verbatim ("Poker from Zero", "Hand Discipline", "Position Thinking", "Bet Purpose / Price", "Board Awareness", "Range Thinking"), confirmed reachable as the default fallback state (`Act0ShellStateV1.sample`) throughout the canonical `Act0ShellPreviewScreenV1` surface. **This directly resolves `ALI-SHARED-001`**: World 3's canonical native lesson list (`_positionThinkingLessons`) is a full, reachable, poker-correct "Position Thinking" curriculum, disproving the original claim that no W1-W6 world delivers this identity. `ALI-SHARED-001` is updated below with this evidence; its narrower residual question (the exact status of `content/worlds/world3/v1/`) is preserved as a lower-stakes candidate. Also found `_preflopFrameworkLessons` (a native lesson list) has zero consumers anywhere in `lib/` or `test/` — recorded as new confirmed finding `ALI-NATIVE-SHARED-001` (dormant, P3, no learner impact, `deferred` for a future bounded dead-code/ownership wave). No other new confirmed defects were found across a representative sample of 12+ fully-read native runners spanning all six worlds; `ALI-SHARED-003` remains `fixed_pending_validation` pending installed-Simulator proof (unchanged by this pass — no new Lens E evidence was available). Full detail in `output/active_learner_integrity_audit_v1/native_runner_inventory.md` and `native_runner_route_map.md`. No product files were edited.

**Lifecycle summary after Revision 4:** 5 confirmed records total — 2 learner-facing `validated_closed` (ALI-W1-001, ALI-W2-001), 1 learner-facing `fixed_pending_validation` (ALI-SHARED-003), 1 documentation-only `validated_closed` (ALI-SHARED-002), and 1 native-runner `deferred` (ALI-NATIVE-SHARED-001, P3, dormant code, no learner impact). Active learner-facing P0/P1/P2 open findings: 0. `ALI-SHARED-001` is resolved by direct new runtime evidence and moved out of active-defect status (see its updated entry); six candidate records remain unpromoted (five prior + one new: `ALI-CAND-006`).

---

## Confirmed Learner-Facing Findings

### ALI-W2-001 — w2.s14 board texture mislabeled "two-tone" on an actual monotone flop

- Status: validated_closed
- Severity: P2
- Category: poker_truth_error
- World / lesson / task: World 2, session w2.s14, drill `chain_texture_outs_fold_v1`, chain steps 1 and 3
- Owner: `content/worlds/world2/v1/sessions/w2.s14/drills/d.chain_texture_outs_fold_v1.json`
- Current text/state: repaired to `board_cards_v1: ["Jh","Th","4c"]` in all three chain steps; the two tone is retained and the existing feedback text remains unchanged.
- Evidence: A flop where all three cards share one suit is a monotone board, not two-tone — confirmed against the app's own teaching example `content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_coordinated_jack_ten_nine_two_tone.json`, which correctly defines two-tone as exactly two suited cards among three (`Jh, Ts, 9h`). w2.s14 is a twin of `w2.s13/drills/d.chain_texture_outs_continue_v1.json` (board `Jh,Th,9c`, genuinely two-tone); w2.s14 changed the hero's hole cards from hearts to diamonds but left the board's third card as a heart instead of changing it to a non-heart, producing an internally inconsistent monotone board still labeled two-tone. A full programmatic scan of all 493 W1–W6 drill/chain JSON files for `board_cards_v1` vs. `board_texture_v1` suit-count consistency found exactly 2 mismatched fields, both in this one file (chain steps 1 and 3; step 2 has no texture field).
- Learner impact: The outs-counting math itself remains correct (gutshot = 4 outs is right independent of texture label), so the task is still completable correctly. However the board-texture vocabulary shown contradicts the category the app teaches elsewhere and plants an incorrect "two-tone" precedent ahead of World 5's formal board-texture teaching.
- Fairly answerable: Yes
- Minimal correction: Change the third board card in chain steps 1 and 3 from a heart to a non-heart rank (e.g. `4c` instead of `4h`), preserving the existing gutshot-outs math and all other copy unchanged.
- Proposed copy: Board `["Jh","Th","4c"]` (no other field needs to change).
- Code/layout dependency: None — single content JSON file.
- Confidence: High — confirmed by full (non-sampled) programmatic scan across all W1–W6 content.
- Discovered at HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660
- Fixed by commit: 347517dcac30eb691cae0e0d5fb27c731a919a9f
- Validated at HEAD: 347517dcac30eb691cae0e0d5fb27c731a919a9f
- Validation: focused source-contract regression passed; all three steps now use exactly two suits with no duplicate physical card; the gutshot remains 4 outs, expected actions remain raise / 4 / fold, and the existing content schema/World 2 validators passed.
- Notes: See root-cause group ALI-GROUP-02.

### ALI-SHARED-003 — Compact answer-list shows only 3 of 4 options with no scroll affordance in the initial render

- Status: fixed_pending_validation
- Severity: P1
- Category: compact_interaction_risk
- World / lesson / task: World 1 / "Poker from Zero" table-read orientation family (hero AK, flop A♥7♣2♦, pot 6 BB, "Step 1/3", prompt "What should you read first?"). Exact task ID not conclusively traceable at this HEAD — see attribution note below and `output/active_learner_integrity_audit_v1/runtime_route_adjudication.md`.
- Owner (shared layout owner): `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` — the compact-answer-list / viewport-pressure system (`compactAnswerListDecision`, `_compactAnswerListUsableHeightBudgetV1`, `_compactAnswerListPhoneMaxShortestSideV1`). Content-family owner (best match, not exact-line-confirmed): the native `Act0RunnerStateV1` "table read" lesson family in `act0_shell_state_v1.dart` / `act0_shell_preview_screen_v1.dart` (`_w1TableReadTransferRunner`, `_placementDiagnosticOptionsV1('table_read')`), rendered via `Act0LessonRunnerShellV1` (imported and instantiated inside `act0_shell_preview_screen_v1.dart`).
- Visible evidence: Owner-supplied iPhone 17 Pro Max Simulator screenshot 1 shows exactly 3 lettered options (A: "Hero hand, board, and pot", B: "Only Hero's cards", C: "The biggest stack first") with no visible scroll indicator, partial-option peek, or "more below" affordance — the list reads as complete. Screenshot 2, in a scrolled state, reveals a 4th option (D: "Not sure yet") that was entirely absent from screenshot 1's viewport, with option A now clipped at the top edge instead.
- Learner impact: A learner viewing the initial (unscrolled) render has no visual cue that a 4th option exists below the fold. This is a discoverability/reachability-signaling risk: in this specific instance the hidden option is a low-stakes "Not sure yet" escape hatch, but the same rendering pattern would be materially worse if a scoring-relevant option (including the correct answer) were the one pushed below the fold without a scroll cue.
- Fairly answerable: Partially — reachable via manual scroll (proven by screenshot 2), but not evidently discoverable from the initial render alone.
- Minimal correction: Add a visible scroll affordance (partial next-option peek, scrollbar, or "more options" indicator) to the compact answer-list dock when `compactAnswerListDecision` is true and the option count exceeds what fits in `_compactAnswerListUsableHeightBudgetV1`, rather than rendering a flush cut with no cue.
- Required regression coverage: A golden/widget test on the `_compactAnswerListPhoneMaxShortestSideV1` (600pt) profile with a 4-option task, asserting a visible scroll affordance is present when not all options fit; repeat at a "tall" and "large" viewport profile to confirm the affordance disappears when it is not needed (functional layout integrity, not general Modern Table visual polish).
- Code/layout dependency: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` (compact answer-list rendering path only).
- Confidence: High — based on owner-observed real-Simulator screenshots (not claimed from static code reading alone).
- Discovered at HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660
- Fixed by commit: 1580d52ad75b64313e644834fa0927e14bce32cc
- Validated at HEAD:
- Deterministic evidence: at 375×812, the final option stays inside the available layout region with a 44 px target, no test-time overflow, and the eligible compact lower-slot path remains bounded.
- Remaining proof: real installed Simulator render; final-option tap; resulting feedback transition; bottom safe-area visibility.
- Notes: Shares the same task instance as ALI-W1-001 (same two screenshots). See root-cause group ALI-GROUP-03. Do not claim the option list is unreachable — screenshot 2 proves scrolling works; the defect is the missing affordance, not hard unreachability.

### ALI-W1-001 — Distractor option "The biggest stack first" references stack sizes that are not visible anywhere on the table

- Status: validated_closed
- Severity: P1
- Category: missing_visible_evidence
- World / lesson / task: World 1 / "Poker from Zero" table-read orientation family — same task instance as ALI-SHARED-003 (see attribution note there and in `output/active_learner_integrity_audit_v1/runtime_route_adjudication.md`; exact task ID not conclusively traceable to one current-HEAD file/line).
- Owner: Same as ALI-SHARED-003's content-family attribution (native `Act0RunnerStateV1` "table read" lesson/diagnostic family); exact literal source line not found via string search at this HEAD.
- Current text/state: Commit `1580d52a` replaced the invisible-stack distractor with four visible-fact choices: `2 private · 3 board · Pot 6 BB`, `2 private · 5 board · Pot 6 BB`, `2 private · 3 board · Pot 4 BB`, and `Not sure yet`. The first remains the canonical correct `two_three_six` answer.
- Evidence: This is a direct match to the audit brief's own worked example of an invalid distractor ("'The biggest stack first' is defective when no stack sizes are visible"). By contrast, other native runners in the same content system (e.g. `act0_shell_state_v1.dart`'s `_matchedChipsTransferRunner`, an unrelated all-in/side-pot lesson) do render explicit `stackLabel` values ('0 BB', '80 BB') on seats when stack-reading is the actual teaching target — confirming the engine is capable of showing stacks when the lesson calls for it, and that their absence here is not a rendering limitation but a content/task-design gap for this specific task.
- Learner impact: The distractor is not merely wrong, it is contextually incoherent — it asks the learner to evaluate an answer against information the screen never provides. A learner who correctly reasons "I can't see any stacks, so this can't be what I should read first" is using stronger judgment than the option was designed to test.
- Fairly answerable: Yes, partially — the correct answer ("Hero hand, board, and pot") remains identifiable and credited without needing to resolve the stack option, so the task is still completable; the distractor itself is contextually invalid rather than the task being unanswerable.
- Minimal correction: Replace "The biggest stack first" with a distractor grounded in visible information (e.g. an option naming a seat label, the dealer button, or another element actually rendered on this table), preserving the existing correct answer and scoring. Do not add stack-size UI to this table — stack-reading is not this task's canonical objective (contrast `_matchedChipsTransferRunner`, where it is).
- Code/layout dependency: Content/copy-only once the exact source line is located; no rendering change implied.
- Confidence: High — direct screenshot evidence, and the missing-evidence pattern is unambiguous regardless of which exact file defines this option.
- Discovered at HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660
- Fixed by commit: 1580d52ad75b64313e644834fa0927e14bce32cc
- Validated at HEAD: 1580d52ad75b64313e644834fa0927e14bce32cc
- Validation: all scored choices now reference visible 2/3/6 table facts; no hidden-stack reference remains; the focused deterministic compact-decision test passed.
- Notes: Shares the same task instance and source owner as ALI-SHARED-003. See root-cause group ALI-GROUP-03.

---

## Deferred / Ambiguous-Route Findings

### ALI-SHARED-001 — World 3 content-ownership vs. canonical identity (RESOLVED BY NEW RUNTIME EVIDENCE, Revision 4 — see below)

- Status: **rejected_false_positive** for the core Revision 1 claim (updated in Revision 4); the narrower residual question about `content/worlds/world3/v1/`'s exact purpose is preserved as candidate `ALI-CAND-005`'s sibling note and does not require its own open finding
- Severity: was P1 in Revision 1; not carried into learner-facing counts as of Revision 2; no severity applies now that the core claim is disproven
- Category: progression_context_mismatch (the original claim; disproven — see Revision 4 evidence)
- World / lesson / task: World 3
- Owner: `content/worlds/world3/v1/world.md` and 14 w3 sessions vs. `lib/canonical/canonical_truth_map_v1.dart` vs. (Revision 4) `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`'s `_positionThinkingLessons` / `_act0PreviewWorlds`
- Current text/state: Unchanged from Revision 1 — see full original text preserved below under "Revision 1 original text (historical)."
- Evidence update (Revision 2): Traced the actual canonical runtime chain (`AGENTS.md` "Runtime Surface Canonical (Act0)" → `Act0ShellPreviewScreenV1` → repair/recheck routing table in `act0_shell_preview_screen_v1.dart` lines 425-435). Found a confirmed, canonically-routed lesson tagged `worldId: 'world_3'`, `lessonId: 'position_checkpoint'`, keyed to `skillAtomId: 'table_position_read'` and `sourceSignalId: 'hero_button'` — a native BTN/position-recognition task, topically consistent with "Position Thinking." This directly contradicted the Revision 1 claim. Full trace: `output/active_learner_integrity_audit_v1/runtime_route_adjudication.md`.
- **Evidence update (Revision 4 — resolves this finding):** Full native-runner inventory found the canonical registry `_act0PreviewWorlds` (`act0_shell_state_v1.dart` line 6951) — confirmed the default `worlds:` value of `Act0ShellStateV1.sample`, which is the fallback state used pervasively (`widget.state ?? Act0ShellStateV1.sample`) throughout the canonical `Act0ShellPreviewScreenV1` surface. Its `world_3` entry (`title: 'Position Thinking'`, matching `canonical_truth_map_v1.dart` verbatim) has `lessons: _positionThinkingLessons`, a full 7-lesson native curriculum (`position_six_seats`, `button_advantage`, `early_vs_late`, `same_hand_different_seat`, `position_apply`, `position_checkpoint`, plus repair variants) that was spot-checked in Revision 4 and confirmed poker-correct and on-topic. **This directly disproves the original Revision 1 claim** ("no W1-W6 world currently delivers Position Thinking as its own dedicated unit"). No caller was found anywhere in `lib/ui_v2/act0_shell/*` constructing `w3.s01`..`w3.s14` session IDs from this registry — `content/worlds/world3/v1/` and the native `_positionThinkingLessons` registry are separate content systems, and only the latter is proven to be the one the canonical entry point actually serves for World 3. Full detail: `output/active_learner_integrity_audit_v1/native_runner_route_map.md` ("Resolution of ALI-SHARED-001" section).
- What remains unresolved (downgraded from "residual open question" to low-stakes candidate): The exact purpose of `content/worlds/world3/v1/sessions/w3.s01-14` (asset-bundled per `pubspec.yaml`, has a generic loader in `drill_runtime_adapter_v1.dart`, but no confirmed consumer in the active route). This no longer implies any learner-facing contradiction, since the live route's actual World 3 content (`_positionThinkingLessons`) is confirmed coherent with canon independent of whatever `content/worlds/world3/v1/` turns out to be for.
- Learner impact: None found. The confirmed reachable World-3 curriculum (native, `_positionThinkingLessons`) is coherent with canon; no learner-facing contradiction was found in either revision.
- Fairly answerable: Yes (unchanged)
- Minimal correction: None — no defect confirmed. Do not move or rewrite either `content/worlds/world3/v1/` or `_positionThinkingLessons` on the basis of this finding.
- Proposed copy: N/A
- Code/layout dependency: `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`, `act0_shell_state_v1.dart`, `lib/services/drill_runtime_adapter_v1.dart`, `content/worlds/world3/v1/*`
- Confidence: High — the resolution is based on a direct, confirmed registry read (`_act0PreviewWorlds`), not inference.
- Discovered at HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660
- Fixed by commit: N/A — no product defect existed; nothing to fix
- Validated at HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f (Revision 4 evidence read at this HEAD; the underlying registry code is unchanged since the audit base)
- Notes: See `output/active_learner_integrity_audit_v1/runtime_route_adjudication.md` (Revision 2 trace) and `native_runner_route_map.md` (Revision 4 resolution) for full evidence. This ID is preserved and not reused per the incremental audit protocol, even though the core claim is now disproven — the historical record and the resolution evidence both remain visible here.

<details>
<summary>Revision 1 original text (historical — preserved for audit trail, superseded by the deferred entry above)</summary>

Original Owner: `content/worlds/world3/v1/world.md` (and by extension all 14 w3 sessions) vs. `lib/canonical/canonical_truth_map_v1.dart` (`world_3` / `world_4` entries)

Original Current text/state: `content/worlds/world3/v1/world.md`: "World 3 is the preflop framework bridge... hand categories: premium, strong, medium, and trash... open / call / fold." All 14 w3 sessions (verified via `w3.s01/drills/d.chain_preflop_framework_intro_v1.json` and the sessions index) teach this hand-category/open-call-fold framework, not position vocabulary.

Original Evidence: `lib/canonical/canonical_truth_map_v1.dart` declares `worldId: 'world_3', learnerMeaning: 'Position Thinking'` and separately declares `worldId: 'world_4', ... retiredMeanings: ['Preflop Framework']`. Three independent planning docs agreed with the runtime canon, not with the shipped W3 content: `docs/plan/MASTER_PLAN_v3.0.md`, `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`, `docs/plan/CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md`. This evidence set never traced whether `content/worlds/world3/v1/` is the content the live app actually loads for "World 3" — that gap is what Revision 2 closed partially (see deferred entry above).

</details>

---

## Documentation / Agent-Truth Findings

These are documentation/process debt items, not learner-facing content defects. They are tracked here for completeness but are **excluded from the learner-facing P0/P1/P2/P3 counts** below.

### ALI-SHARED-002 — `CONTENT_PLAN_PER_WORLD_v2.1.md` is off-by-one against the current world-topic canon and is still listed as an active SSOT document

- Status: validated_closed
- Severity: P3 (documentation/process — not counted in learner-facing severity totals)
- Category: duplicate_or_contradictory_copy
- World / lesson / task: Documentation only — not a learner-facing task
- Owner: `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`
- Current text/state: `CONTENT_PLAN_PER_WORLD_v2.1.md` now carries a prominent historical-MVP-numbering / non-authority banner; `ACTIVE_CONTENT_SSOT_INDEX_v1.md` now directs current world identity and topic-home decisions to the Master Plan and coverage matrix.
- Evidence: Current canon (`lib/canonical/canonical_truth_map_v1.dart`, `docs/plan/MASTER_PLAN_v3.0.md`) assigns W1 = Poker from Zero, W2 = Hand Discipline, W3 = Position Thinking — one slot earlier than this doc's headers. `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md` currently lists this file as an active-stack document with no historical/stale marker. Note (Revision 2): `AGENTS.md` line 108 already instructs agents "Do NOT ... Use docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md as authority for W5+ — it is MVP-first skeleton only," so this doc's limited authority is partially known/documented already; the residual gap is that `ACTIVE_CONTENT_SSOT_INDEX_v1.md` does not carry the same caveat.
- Learner impact: Doc-only; not directly learner-facing.
- Fairly answerable: N/A (not a task)
- Minimal correction: Renumber the doc's world headers to match current canon, or mark the doc explicitly historical/superseded in `ACTIVE_CONTENT_SSOT_INDEX_v1.md` (aligning it with the caveat `AGENTS.md` already states).
- Proposed copy: N/A
- Code/layout dependency: `docs/content/` ownership only
- Confidence: High — direct text comparison, unambiguous off-by-one.
- Discovered at HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660
- Fixed by commit: this documentation-admission commit (Commit 2; hash recorded in final handoff)
- Validated at HEAD: this documentation-admission commit (Commit 2; hash recorded in final handoff)
- Notes: Root-cause sibling of the deferred ALI-SHARED-001; see ALI-GROUP-01.

---

## Systemic Root-Cause Groups

## Group ALI-GROUP-01 — World-topic canon/documentation drift (documentation layer; ALI-SHARED-001 resolved in Revision 4)

- Findings: ALI-SHARED-002 (validated_closed, doc-only); ALI-SHARED-001 (resolved/rejected_false_positive as of Revision 4 — see updated entry and `native_runner_route_map.md`)
- Shared owner: whoever last executed a world-content/canon update in `lib/canonical/canonical_truth_map_v1.dart` (its own `retiredMeanings` history shows World 4 shed "Preflop Framework" as an identity) without a lockstep update to `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`'s world-number headers.
- Repair boundary: ALI-SHARED-002 (doc renumber/retire) is mechanical and bounded — already applied (`validated_closed`). ALI-SHARED-001 required no repair — Revision 4 evidence shows the canon and the actual reachable native-runner content already agree; no action needed.
- Required tests: None. ALI-SHARED-002 is closed; ALI-SHARED-001 needed no fix.
- Scope risk: None remaining in this group.

## Group ALI-GROUP-04 — Native lesson lists authored but never wired into the active registry (new in Revision 4)

- Findings: ALI-NATIVE-SHARED-001 (`_preflopFrameworkLessons`)
- Shared owner: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`, the same file that defines `_act0PreviewWorlds` and its consumed lesson lists.
- Repair boundary: Not a learner-facing repair — this is dead code with zero consumers, so there is no learner-facing risk to bound. A maintainer decision (wire it in, delete it, or leave it as authored-but-unused scaffolding) is needed before any code change; this audit does not recommend which.
- Required tests: None required for the current (dormant) state. If a maintainer wires `_preflopFrameworkLessons` into `_act0PreviewWorlds` in the future, apply the same Lens A-D checks used elsewhere in this audit before shipping it.
- Scope risk: None at present (unreachable code). Would need reassessment if wired into the active route.

## Group ALI-GROUP-02 — Copy-paste drift across hand-chain twins

- Findings: ALI-W2-001 (validated_closed)
- Shared owner: content-authoring pass that generated "continue" (w2.s13) / "fold" (w2.s14) twin chains from a shared template.
- Repair boundary: Single-file, card-only correction applied consistently across the three same-flop chain steps. Fully bounded.
- Required tests: Extend the suit-vs-texture-label consistency check used in this audit (board_cards_v1 suit distribution vs. board_texture_v1 label) into a permanent content lint run in CI across all `content/worlds/**/*.json` files.
- Scope risk: Low.

## Group ALI-GROUP-03 — Compact option-list reachability and evidence-grounding (new in Revision 2)

- Findings: ALI-SHARED-003 (layout/affordance), ALI-W1-001 (content/distractor) — same task instance, same two owner-supplied screenshots.
- Shared owner: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` (compact answer-list rendering, shared owner for ALI-SHARED-003) and the native "table read" task-family content (owner for ALI-W1-001, exact file not yet located — see `runtime_route_adjudication.md`).
- Repair boundary: ALI-SHARED-003 is a layout/affordance fix bounded to the compact answer-list dock. ALI-W1-001 is a content/copy fix bounded to one distractor string, once the exact source file is located (recommend a runtime/debug trace or maintainer pointer rather than further static grep, since literal-string search at this HEAD did not find it).
- Required tests: See ALI-SHARED-003's "Required regression coverage" above (compact/tall/large viewport golden tests). For ALI-W1-001: a content-lint rule flagging any answer-option text referencing "stack" when no stack-size field is present in the same task's visible-state fields, once the exact task owner is confirmed.
- Scope risk: Low for both once the exact source file is confirmed; currently blocked only on locating that file.

---

## Coverage Matrix

| World | Active tasks inspected | Fully coherent | Confirmed findings | Candidate findings | Coverage confidence |
| --- | ---: | ---: | ---: | ---: | --- |
| W1 | Sampled (session index + w1.s01, w1.s06 full read; 99 files scanned programmatically) + native Act0Runner "table read"/"what poker is" family traced in Revision 2 | Pending live validation for compact reachability | 1 `fixed_pending_validation` (ALI-SHARED-003); 1 `validated_closed` (ALI-W1-001) | 1 (ALI-CAND-002) | High (full programmatic scan of JSON content) / Medium (manual sample) / the native Act0Runner layer is only partially inventoried — see note below |
| W2 | Sampled (session index + w2.s04, w2.s13, w2.s14 full read; 111 files scanned programmatically) | Yes after bounded card correction | 1 `validated_closed` (ALI-W2-001) | 1 (ALI-CAND-004) | High (full programmatic scan) / Medium (manual sample) |
| W3 | Sampled (session index + w3.s01 full read; 22 files scanned programmatically); canonical runtime route traced in Revision 2; native `_positionThinkingLessons` registry confirmed and spot-checked in Revision 4 | Yes — world-identity resolved in Revision 4 (native registry confirmed coherent with canon) | 0 confirmed defects (ALI-SHARED-001 resolved as `rejected_false_positive`, not a defect) | 1 (ALI-CAND-005, was ALI-W3-002) | High (full programmatic scan of JSON + confirmed native registry reachability) / Medium (manual sample); JSON tree's exact purpose remains an unresolved but low-stakes candidate |
| W4 | Sampled (session index + w4.s01, w4.s02 full read; 124 files scanned programmatically) | Yes | 0 | 1 (ALI-CAND-001) | High (full programmatic scan) / Medium (manual sample) |
| W5 | Sampled (session index + w5.s02, w5.s08 full read; 44 files scanned programmatically) | Yes | 0 | 1 (ALI-CAND-004, shared with W2) | High (full programmatic scan) / Medium (manual sample) |
| W6 | Sampled (session index + w6.s03, w6.s05 full read; 93 files scanned programmatically) | Yes | 0 | 0 | High (full programmatic scan) / Medium (manual sample) |

**Important scope note added in Revision 2:** the original audit's W1–W6 coverage was scoped to `content/worlds/worldN/v1/` JSON content. Revision 2 discovered that the canonical runtime entry point (`Act0ShellPreviewScreenV1`, per `AGENTS.md`) also serves a separate, large, native-Dart `Act0RunnerStateV1` content system (`act0_shell_state_v1.dart`, `act0_shell_preview_screen_v1.dart`) that delivers at least the "Poker from Zero" (World 1) and "position_checkpoint" (World 3) lessons, and possibly more. This native-runner content system was **not inventoried in Revision 1** and is only partially traced in Revision 2 (enough to adjudicate ALI-SHARED-001 and attribute the two screenshot findings). A future audit pass should treat this native-runner system as a distinct, first-class owner requiring its own inventory pass, not assume `content/worlds/worldN/v1/` is the complete picture for any world.

Active owners inspected (exact paths):

- `content/worlds/world{1..6}/v1/world.md`, `sessions/index.md`, and a manual sample of `sessions/*/drills/*.json` per world (see per-world notes above).
- `content/world1_act0_action_literacy/v1/`, `content/world1_act0_table_literacy/v1/`, `content/world1_act0_street_flow/v1/` (manifests fully read).
- `content/_schemas/drills.schema.json`
- `lib/services/drill_contract_v1.dart`, `lib/services/session_drill_repair_receipt_adapter_v1.dart`, `lib/services/world2_action_choice_policy_validator_v1.dart`, `lib/services/drill_runtime_adapter_v1.dart` (Revision 2)
- `lib/ui_v2/act0_shell/act0_learning_run_payoff_v1.dart`, `act0_lesson_runner_shell_v1.dart` (viewport/compact-layout sections), `act0_placement_shell_v1.dart`, `act0_shell_preview_screen_v1.dart` (Revision 2, partial), `act0_shell_state_v1.dart` (Revision 2, partial), `act0_canonical_path_root_v1.dart` (Revision 2), `act0_position_personalization_ids_v1.dart` / `act0_position_personalization_v1.dart` (Revision 2)
- `lib/canonical/canonical_truth_map_v1.dart`, `lib/canonical/progression_route_story_v1.dart`, `lib/canonical/world1_canonical_module_order_v1.dart` (Revision 2)
- `lib/campaign/campaign_pack_registry_v1.dart`, `lib/services/progress_service.dart` (Revision 2, partial — spine/followup pack IDs only)
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` (Revision 4 — full-file structural scan of all 355 runner declarations plus ~15 targeted full reads across all 6 worlds), `act0_shell_preview_screen_v1.dart` (Revision 4 — targeted reads of `_act0PreviewWorlds`, `Act0ShellStateV1.sample` consumption sites, repair/recheck routing table)
- `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md`, `docs/plan/MASTER_PLAN_v3.0.md`, `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`, `docs/plan/CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md`, `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`, `AGENTS.md` (Revision 2), `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md` (Revision 2, targeted check only)

Two checks ran with full (non-sampled) coverage across all 493 W1–W6 drill/chain JSON files: (1) `board_cards_v1` suit-distribution vs. `board_texture_v1` label consistency; (2) `expected_action` presence within `available_actions_v1`; (3) identical `feedback_correct_v1`/`feedback_incorrect_v1` text. All other coverage above is representative sampling, not exhaustive line-by-line reading. The native `Act0RunnerStateV1` content system was not exhaustively or programmatically scanned in either revision — only specific lessons reached via targeted trace were read.

---

## Native Act0 Runner Coverage Matrix (Revision 4)

| World | Native lesson list | Reachability | Lessons | Tasks spot-checked (full read) | Confirmed findings | Candidate findings | Coverage confidence |
| --- | --- | --- | --- | ---: | --- | --- | --- |
| World 1 — Poker from Zero | `_pokerFromZeroLessons` | Confirmed active/reachable (`_act0PreviewWorlds` → `Act0ShellStateV1.sample.worlds`) | 9 lessons incl. `what_poker_is`, `pot_stack`, `all_in_meaning`, `matched_chips_transfer`, `side_pot_intro`, `win_ways`, hand-ranking cluster, showdown cluster, `world_one_checkpoint` | 4 (`what_poker_is_table_read_transfer` — already fixed; `_potStackRunner`; `_winWaysRunner`; `_matchedChipsTransferRunner`) | 0 new (1 already fixed pre-pass: ALI-W1-001) | 1 (`ALI-CAND-006`, shared) | Medium — structural inventory complete (355-runner full-file scan), targeted spot-check only |
| World 2 — Hand Discipline | `_handDisciplineLessons` (+ donor pools `_handValuePositionLessons`, `_preflopBasicsLessons`) | Confirmed active/reachable | 6 lessons incl. `hand_discipline_buckets`, `fold_discipline`, `weak_ace_warning`, `continue_or_let_go`, `hand_discipline_apply`, `discipline_checkpoint` | 1 (`_world2KqoContrastRunner` / `weak_ace_kicker_compare`) | 0 | 0 | Medium |
| World 3 — Position Thinking | `_positionThinkingLessons` | Confirmed active/reachable — **this is the ALI-SHARED-001 resolution evidence** | 7 lessons incl. `position_six_seats`, `button_advantage`, `early_vs_late`, `same_hand_different_seat`, `position_apply`, `position_checkpoint` | 1 (`_w3TablePositionNoticeRunner` / `position_checkpoint_table_notice`) | 0 | 0 | Medium |
| World 4 — Bet Purpose / Price | `_betPurposePriceLessons` | Confirmed active/reachable | 7 lessons incl. `why_bets_happen`, `value_bets`, `bluff_pressure`, `protection_and_denial`, `call_price`, `small_half_pot`, `price_checkpoint` | 1 (`_world4PurposePriceTableTransferRunner` / `w4_checkpoint_table_purpose_price`) | 0 | 0 | Medium |
| World 5 — Board Awareness | `_boardDrawsLessons` | Confirmed active/reachable | 6 lessons incl. `board_texture_basics`, `connected_boards`, `flush_draws`, `straight_draws`, `outs_improvement`, `turn_river_changes` | 2 (`_world5GutshotDrawRunner` + twin `_world5GutshotContrastTransferRunner`) | 0 | 0 | Medium |
| World 6 — Range Thinking | `_rangeThinkingFoundationLessons` (spliced from `_rangeThinkingLiteLessons[0..4]`) | Confirmed active/reachable | 5 lessons incl. `range_bucket_basics`, `range_board_fit`, `range_pressure_lines`, `range_combo_counts`, `range_thinking_checkpoint` | 2 (`_w6KickerShowdownCompareRunner`, `_w6BoardPairStrengthCompareRunner`) | 0 | 0 | Medium |
| N/A (dormant) | `_preflopFrameworkLessons` | **Confirmed dormant** — zero consumers in `lib/` or `test/` | 5 lesson entries defined, none reachable | 1 (definition read; no runner-level content read since unreachable) | 1 (`ALI-NATIVE-SHARED-001`) | 0 | High — dormancy confirmed by full repo-wide grep |

**Native structural facts:** `act0_shell_state_v1.dart` is 22,569 lines defining 355 top-level `Act0RunnerStateV1` objects (253 within W1-W6 naming scope); a full-file scan confirmed zero runners have more than one `isCorrect: true` option (no multi-defensible-answer bug exists anywhere in this system). Full detail: `output/active_learner_integrity_audit_v1/native_runner_inventory.md` and `native_runner_route_map.md`.

---

## Confirmed Native-Runner Findings (Revision 4)

### ALI-NATIVE-SHARED-001 — `_preflopFrameworkLessons` is a native lesson list with zero consumers (dormant)

- Status: deferred
- Severity: P3
- Category: dormant_or_unproven_runtime_owner
- World / lesson / task: Not assigned to any active world — a standalone, unconsumed `<Act0LessonCardV1>[]` list
- Owner: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` line 4047
- Current text/state: A 5-entry list built via `_lessonFromTasksV1(sourceTasks: _preflopBasicsLessons[N].taskList, ...)` for `lessonId`s including `preflop_first_in_open`, re-packaging tasks that are *also* independently consumed elsewhere (by `_handDisciplineLessons` and `_positionThinkingLessons`, both of which are reachable).
- Evidence: Repo-wide grep across all of `lib/` and `test/` found exactly one occurrence of the identifier `_preflopFrameworkLessons` — its own definition. It is never assigned to any `Act0WorldCardV1.lessons` field in `_act0PreviewWorlds`, never passed to `lessonById`/`runnerFor`, and has no test coverage.
- Learner impact: None — this code is never reached by any learner, since nothing in the active route ever evaluates it.
- Fairly answerable: N/A (not a learner-facing task)
- Minimal correction: None recommended by this read-only audit. A maintainer should decide whether to wire it into a world (if it represents intended-but-unshipped content), delete it (if superseded by `_handDisciplineLessons`/`_positionThinkingLessons`, which already consume the same underlying tasks), or leave it as intentional scaffolding.
- Proposed copy: N/A
- Code/layout dependency: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` only
- Confidence: High — dormancy is a direct code fact (zero consumers), not an inference.
- Discovered at HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f
- Fixed by commit:
- Validated at HEAD:
- Notes: See root-cause group ALI-GROUP-04.

- **`available_actions_v1` / `expected_action` consistency, all W1–W6 JSON content** — Evidence reviewed: full programmatic scan of 493 drill/chain JSON files, 0 violations. Reason not to change: no defect exists. Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **Identical correct/incorrect feedback strings, all W1–W6 JSON content** — Evidence reviewed: full programmatic scan, 0 instances found. Reason not to change: no defect exists. Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **`lib/services/session_drill_repair_receipt_adapter_v1.dart`** — Evidence reviewed: full read of the reviewed-tuple allowlist (`_reviewedRepairTargetBySourceV1`) and the W6.s01 range-bucket path; fails closed on unknown source/drill pairs. Reason not to change: correctly scoped, no misrouting evidence within its actual scope (W4↔W6 pairs only). Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **`lib/ui_v2/act0_shell/act0_learning_run_payoff_v1.dart` (`Act0LearningRunPayoffPolicyV1`)** — Evidence reviewed: full read of outcome-priority logic and skill-descriptor map. Reason not to change: three-tier outcome language (mastered/repaired-recovered/still-needs-practice) is never conflated; unmapped skills get an explicit safe generic fallback instead of a false named claim; intentionally scoped to W1's three core skills only (`action_read`, `table_position_read`, `price_read`) by design, confirmed via `skillAtomId` usage sites in `act0_lesson_runner_shell_v1.dart` and `act0_shell_preview_screen_v1.dart`. Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **w1.s01 treatment of "range" vocabulary** (`content/worlds/world1/v1/sessions/w1.s01/session.md`) — Evidence reviewed: full read. Reason not to change: names the word without teaching the concept, explicitly deferring definition to later worlds — correct avoidance of "terminology before teaching." Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **W1 bet-sizing preview reps** (`bet_sizing_choice_v1` kind, w1.s01) — Evidence reviewed: full read of drill files and session.md. Reason not to change: session's own copy explicitly frames these as a "size-label preview," not a full decision task; absence of board/pot context is by design, not a missing-decision-input defect. Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **`act0_shell_state_v1.dart`'s `_matchedChipsTransferRunner` (all-in/matched-chips lesson)** — Evidence reviewed (Revision 2): full read of options and feedback. Reason not to change: correctly renders explicit `stackLabel` values ('0 BB', '80 BB') on seats because stack-reading is this lesson's actual teaching target — a valid contrast case showing the engine renders stacks when the task calls for it. Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **`_act0PreviewWorlds` registry titles (all 6 worlds)** — Evidence reviewed (Revision 4): full read of `Act0WorldCardV1` entries for `world_1`..`world_6`. Reason not to change: titles match `lib/canonical/canonical_truth_map_v1.dart` verbatim for every world; no silent canon/registry disagreement exists. Audited HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f.
- **`_potStackRunner` / `_winWaysRunner` "stack" distractors (World 1)** — Evidence reviewed (Revision 4): full read. Reason not to change: both are conceptual/rules-knowledge distractors ("Stack" as a UI-label contrast; "Largest stack" as a common beginner rules misconception), neither requires visible stack-size evidence to evaluate — not the same defect class as the already-fixed ALI-W1-001. Audited HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f.
- **`_world2KqoContrastRunner` (`weak_ace_kicker_compare`, World 2)** — Evidence reviewed (Revision 4): full read. Reason not to change: KQo-vs-A7o domination-risk comparison is poker-correct and well-differentiated (correct/wrong feedback both cite the actual reason, not a generic template). Audited HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f.
- **`_w3TablePositionNoticeRunner` (`position_checkpoint_table_notice`, World 3)** — Evidence reviewed (Revision 4): full read. Reason not to change: correctly teaches counting players still to act (BTN/SB/BB) rather than assuming "late position = comfortable"; three-tier feedback (correct/close-call-wrong/plausible-but-incomplete) is comprehension-positive. Audited HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f.
- **`_world4PurposePriceTableTransferRunner` (`w4_checkpoint_table_purpose_price`, World 4)** — Evidence reviewed (Revision 4): full read. Reason not to change: value-bet-size-and-price reasoning is internally consistent with the visible table state (pot 6 BB, 2 BB bet, top pair on dry flop). Audited HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f.
- **`_world5GutshotDrawRunner` / `_world5GutshotContrastTransferRunner` twin pair (World 5)** — Evidence reviewed (Revision 4): full read of both. Reason not to change: unlike the JSON w2.s14 copy-paste defect, this twin construction only varies an irrelevant high card (K→Q) between variants, leaving the gutshot-defining cards (7,5, needing a 6) identical in both — a safer twin-authoring pattern worth citing as a positive example. Audited HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f.
- **`_w6KickerShowdownCompareRunner` / `_w6BoardPairStrengthCompareRunner` (World 6 showdown comparisons)** — Evidence reviewed (Revision 4): full read, both independently re-verified card-by-card. Reason not to change: both are mathematically correct, including a subtle double-paired-board (J-8-8-2-2) trips-vs-two-pair case in the second runner. Audited HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f.
- **Structural absence of multi-`isCorrect: true` bugs across all 253 W1-W6 native runners** — Evidence reviewed (Revision 4): full-file programmatic scan. Reason not to change: no defect exists. Audited HEAD: 8592746e9f851f35f066f04edcd191683cce8f2f.

---

## Candidate Appendix (Unconfirmed — Do Not Promote Without Further Evidence)

### ALI-CAND-001 — W4 "simplified rep" action_choice tasks name the taught purpose directly in the prompt

- Reason confidence is limited: The explicit "in this simplified rep" framing in the task copy itself (`choose_raise_value/protection/bluff/denial`, w4.s01–s02) plausibly signals intentional low-fidelity scaffolding rather than an accidental giveaway; the session goal is to teach the purpose→size mapping before adding table complexity.
- Missing evidence required for confirmation: Confirmation from a maintainer on whether these reps are intended purely as concept-labeling drills, and whether a later W4 checkpoint requires the learner to identify purpose from table state without it being named — if such a checkpoint exists and works correctly, this candidate should be closed as by-design.

### ALI-CAND-002 — `intent_v1` field inconsistency in most World 1 drills

- Reason confidence is limited: Verified this field does not feed any active repair/personalization pathway for World 1 content — only `world2_action_choice_policy_validator_v1.dart`'s W2-specific enum and the explicit W4/W6 allowlist in `session_drill_repair_receipt_adapter_v1.dart` consume `intentV1`, and neither includes World 1. This downgrades the issue from a learner-impacting defect to a content-hygiene note.
- Missing evidence required for confirmation: None expected — this is unlikely to be promoted unless `intentV1` consumption is later extended to World 1.

### ALI-CAND-003 — Text density on final `hand_chain_v1` steps (prompt + why_v1 + recap_v1 stacking)

- Reason confidence is limited: The original Revision 1 audit had no screenshots and inferred this from copy length alone. Revision 2 obtained screenshot evidence, but only for the unrelated native-runner "table read" task (ALI-SHARED-003/ALI-W1-001), not for a `content/worlds/` JSON hand-chain final step. This candidate remains unconfirmed.
- Missing evidence required for confirmation: A rendered screenshot or golden test of a final chain step (e.g. w2.s13/w2.s14 step 3) on a compact/short-viewport device profile.

### ALI-CAND-004 — Overlapping board-texture/outs/price content between World 2 and World 5

- Reason confidence is limited: World 2 explicitly self-describes as a "bridge" that reinforces board-texture ideas ahead of World 5's fuller treatment, which may be intentional spiral-curriculum design rather than a duplication defect.
- Missing evidence required for confirmation: Maintainer confirmation that the W2 bridge scope was deliberately designed to overlap with W5's canonical "Board Awareness" identity, ideally cross-referenced against the deferred ALI-SHARED-001's world-identity review.

### ALI-CAND-005 — World 3 per-session content density is markedly thinner than sibling worlds (demoted from confirmed ALI-W3-002 in Revision 2)

- Reason confidence is limited: `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md` uses a qualitative 1-5 rating scale ("1 = thin," "does not feel like a teaser, shell, or thin sketch") rather than a numeric per-session file-count threshold. Raw file counts (World 3 ≈1.6 files/session vs. 4.0-12.4 for sibling worlds) are exact, but no canonical rule directly ties file count to a defect determination, so this cannot be asserted as a confirmed learner-facing P3 finding.
- Update (Revision 4): The original entanglement with ALI-SHARED-001's route-ownership question is now largely moot — ALI-SHARED-001 is resolved, and the *actual* live World 3 curriculum is the native `_positionThinkingLessons` (7 lessons, not thin). This candidate's file-count observation applies only to `content/worlds/world3/v1/`, a JSON tree of unconfirmed purpose relative to the live route (see `ALI-SHARED-001`'s updated entry) — so even if promoted, its learner impact would need to be reassessed once that JSON tree's purpose is known.
- Missing evidence required for confirmation: A maintainer-applied scorecard rating for World 3 under the existing qualitative rubric, and/or clarification of `content/worlds/world3/v1/`'s purpose relative to the live native-runner route.
- Historical note: this candidate was originally recorded as confirmed finding `ALI-W3-002` (Severity P3, category `truncation_or_visibility_risk`) in Revision 1. The ID `ALI-W3-002` is retired from confirmed status but preserved here as a cross-reference; do not reuse `ALI-W3-002` for a new finding.

### ALI-CAND-006 — `Act0ShellStateV1.sample` may be the live production state rather than a placeholder fallback (new in Revision 4)

- Reason confidence is limited: `act0_shell_preview_screen_v1.dart` uses the pattern `widget.state ?? Act0ShellStateV1.sample` at dozens of call sites, proving `.sample` is at minimum the default fallback. A source comment near line 13647 ("into Act0RunnerStateV1, then replace Act0ShellStateV1.sample at the preview...") indicates maintainers intend to eventually replace it with dynamic per-user state. Whether `widget.state` is ever actually populated with different live data anywhere in the current build (making `.sample` a true fallback) or whether the shipped app currently runs entirely on this static fixture (meaning all learners currently see the same seeded progress, e.g. "4 of 9 lessons complete" for World 1) was not traced in this bounded pass.
- Missing evidence required for confirmation: Trace of every call site that constructs a non-null `Act0ShellStateV1` and passes it as `widget.state` (e.g. from `lib/services/progress_service.dart` or another persistence layer), and confirmation of whether that path is wired into the shipped app or is itself unproven/dormant.

---

## Future Incremental Audit Protocol

1. Read this ledger first before re-auditing any W1–W6 content.
2. Record the previous audited HEAD (see header of this document: `be887aefd81ffd9e5ffdb5b45901b6809fde1660`).
3. Inspect `git log <previous_head>..HEAD` for changes under `content/worlds/`, `content/world1_act0_*`, `lib/ui_v2/act0_shell/`, `lib/canonical/`, `lib/services/*drill*`, `lib/campaign/campaign_pack_registry_v1.dart`, and `docs/plan|content/*` SSOTs.
4. Reopen only changed owners, plus any finding in this ledger still marked `open`, `deferred`, or `fixed_pending_validation` that touches the current route.
5. Do not re-audit clean, unchanged tasks listed in the Clean / Do-Not-Change Register.
6. Preserve all stable finding IDs (`ALI-*`) exactly as written — never renumber or reuse an ID, including retired ones like `ALI-W3-002` (see ALI-CAND-005).
7. Update lifecycle status in place (`open` → `accepted`/`rejected_false_positive`/`fixed_pending_validation`/`validated_closed`/`deferred`/`superseded`) rather than deleting historical findings.
8. Add new findings using the next available stable ID per world (e.g. next World 2 finding is `ALI-W2-002`) or `ALI-SHARED-00N` for cross-world/shared-component root causes.
9. Record the repair commit hash in `Fixed by commit:` and the HEAD at which the fix was verified in `Validated at HEAD:` for each finding as it moves through its lifecycle.
10. Run a full audit (not an incremental one) only after a broad curriculum restructure or learner-runner architecture change — e.g. a world renumbering, a change to the drill/session schema, or a rewrite of the repair/personalization/payoff contracts.
11. **(Added Revision 2)** Before asserting any world-identity or curriculum-ownership finding, trace the actual canonical runtime load chain first (`AGENTS.md` "Runtime Surface Canonical (Act0)" → `Act0ShellPreviewScreenV1` → the relevant registry/loader) rather than comparing a content folder's self-description directly against planning docs. A folder sharing a world's number is not proof it is the content that world's live route actually serves.
12. **(Added Revision 2)** Treat the native `Act0RunnerStateV1` content system (`act0_shell_state_v1.dart`, `act0_shell_preview_screen_v1.dart`) as a distinct active owner requiring its own inventory pass — it was not covered by Revision 1 and was only partially traced in Revision 2.
13. **(Added Revision 4)** The native `Act0RunnerStateV1` system's canonical registry is `_act0PreviewWorlds` (`act0_shell_state_v1.dart` line ~6951) — start any future native-runner audit there rather than re-discovering it. It defines exactly 6 active worlds (`world_1`..`world_6`) whose `lessons:` fields are the ground truth for what each world actually teaches; do not assume `content/worlds/worldN/v1/` JSON content is the primary or only owner for any world without checking this registry first.
14. **(Added Revision 4)** Revision 4 read a representative sample (~15 of ~253 W1-W6 native runners); treat all unsampled native runners as "inventoried but not lens-verified" (see `native_runner_inventory.md`), not as confirmed clean. A future pass should expand the sample, particularly in World 2 and World 4 clusters which received the lightest spot-checking in Revision 4.
15. **(Added Revision 4)** Before citing `content/worlds/world3/v1/` (or any `content/worlds/worldN/v1/` folder) as authoritative for a world's identity, confirm via `_act0PreviewWorlds` whether that world's `lessons:` field actually points to JSON-session-loading code or to a native lesson list — they are two separate content systems that happen to share world numbers.
