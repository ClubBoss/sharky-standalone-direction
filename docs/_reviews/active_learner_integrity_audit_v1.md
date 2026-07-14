# Active Learner Integrity Audit v1

- Status: admitted — lifecycle synchronized through bounded repair commits
- Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660
- Audit date: 2026-07-14
- Scope: Active W1–W6 learner journey — `content/worlds/world1..world6/v1/`, `content/world1_act0_action_literacy|table_literacy|street_flow/v1/`, rendered through `lib/ui_v2/act0_shell/` (lesson runner, placement, profile, review, welcome), plus personalization/repair/recheck/payoff contracts and route-order canon (`lib/canonical/canonical_truth_map_v1.dart`, `lib/canonical/progression_route_story_v1.dart`) and planning SSOTs (`docs/plan/MASTER_PLAN_v3.0.md`, `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`, `docs/plan/CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md`, `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`). Revision 2 additionally traced the canonical runtime load chain (`AGENTS.md` "Runtime Surface Canonical (Act0)", `act0_canonical_path_root_v1.dart`, `act0_shell_preview_screen_v1.dart`, `act0_shell_state_v1.dart`, `drill_runtime_adapter_v1.dart`) and adjudicated two owner-supplied Simulator screenshots.
- Exclusions: Modern Table visuals; `assets/content/{intro_*,core_*,placement_test}` (confirmed dormant — not referenced by `act0_placement_shell_v1.dart` or any active shell file); `lib/archive/legacy_runners/*`; W7–W12 and beyond; monetization/paywall; `.claude/worktrees/*` stale agent worktrees.
- Model: Claude Sonnet 5
- Reasoning: Medium
- Final verdict: `learner_integrity_bounded_repairs_committed_not_pushed`

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

### ALI-SHARED-001 — World 3 content-ownership vs. canonical identity (DEFERRED — see runtime adjudication)

- Status: **deferred** (downgraded from `open`/confirmed P1 in Revision 1)
- Severity: was P1 in Revision 1; not carried into learner-facing counts while deferred
- Category: progression_context_mismatch (content-ownership drift, not proven learner-facing)
- World / lesson / task: World 3
- Owner: `content/worlds/world3/v1/world.md` and 14 w3 sessions vs. `lib/canonical/canonical_truth_map_v1.dart`
- Current text/state: Unchanged from Revision 1 — see full original text preserved below under "Revision 1 original text (historical)."
- Evidence update (Revision 2): Traced the actual canonical runtime chain (`AGENTS.md` "Runtime Surface Canonical (Act0)" → `Act0ShellPreviewScreenV1` → repair/recheck routing table in `act0_shell_preview_screen_v1.dart` lines 425-435). Found a confirmed, canonically-routed lesson tagged `worldId: 'world_3'`, `lessonId: 'position_checkpoint'`, keyed to `skillAtomId: 'table_position_read'` and `sourceSignalId: 'hero_button'` — a native BTN/position-recognition task, topically consistent with "Position Thinking." This directly contradicts the Revision 1 claim that "no W1–W6 world currently delivers Position Thinking." Full trace: `output/active_learner_integrity_audit_v1/runtime_route_adjudication.md`.
- What remains unresolved: Whether `content/worlds/world3/v1/sessions/w3.s01-14` (the preflop-framework JSON content originally read) is also loaded as part of the main World-3 progression reached from the Learn Path map, is a later-stage continuation after `position_checkpoint`, or is unwired/staged content — could not be confirmed or ruled out from static reading within this adjudication's bounded scope.
- Learner impact: Not proven. The one confirmed reachable World-3-tagged lesson is coherent with canon; no learner-facing contradiction was directly observed.
- Fairly answerable: Yes (unchanged)
- Minimal correction: None recommended while route ownership is ambiguous. Do not move or rewrite the 14 `content/worlds/world3/v1/` sessions on the basis of this finding alone.
- Proposed copy: N/A
- Code/layout dependency: `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`, `act0_shell_state_v1.dart`, `lib/services/drill_runtime_adapter_v1.dart`, `content/worlds/world3/v1/*`
- Confidence: Medium — the downgrade itself is high-confidence (runtime evidence is direct), but the residual open question (is `content/worlds/world3/v1/` reached at all?) is unresolved, not merely low-confidence.
- Discovered at HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660
- Fixed by commit:
- Validated at HEAD:
- Notes: See `output/active_learner_integrity_audit_v1/runtime_route_adjudication.md` for the full trace table and answers to all 8 required adjudication questions. Do not re-confirm this finding without either a maintainer statement of intent or a runtime trace of actual session IDs requested by the Learn Path map for World 3.

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

## Group ALI-GROUP-01 — World-topic canon/documentation drift (documentation layer only after Revision 2)

- Findings: ALI-SHARED-002 (validated_closed, doc-only); ALI-SHARED-001 (deferred, not confirmed as of Revision 2)
- Shared owner: whoever last executed a world-content/canon update in `lib/canonical/canonical_truth_map_v1.dart` (its own `retiredMeanings` history shows World 4 shed "Preflop Framework" as an identity) without a lockstep update to `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`'s world-number headers.
- Repair boundary: ALI-SHARED-002 (doc renumber/retire) is mechanical and bounded. ALI-SHARED-001 is not actionable until route ownership is resolved (see deferred entry) — no repair should be scoped from it yet.
- Required tests: None until ALI-SHARED-001 is resolved one way or the other. For ALI-SHARED-002 alone: no test needed, it is a documentation edit.
- Scope risk: Low for ALI-SHARED-002 alone. Unknown for ALI-SHARED-001 until route ownership is confirmed.

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
| W3 | Sampled (session index + w3.s01 full read; 22 files scanned programmatically); canonical runtime route traced in Revision 2 | Task-level yes; world-identity ownership unresolved (deferred) | 0 confirmed (1 deferred: ALI-SHARED-001) | 1 (ALI-CAND-005, was ALI-W3-002) | High (full programmatic scan) / Medium (manual sample) / route ownership for the JSON tree specifically remains unresolved |
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
- `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md`, `docs/plan/MASTER_PLAN_v3.0.md`, `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`, `docs/plan/CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md`, `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`, `AGENTS.md` (Revision 2), `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md` (Revision 2, targeted check only)

Two checks ran with full (non-sampled) coverage across all 493 W1–W6 drill/chain JSON files: (1) `board_cards_v1` suit-distribution vs. `board_texture_v1` label consistency; (2) `expected_action` presence within `available_actions_v1`; (3) identical `feedback_correct_v1`/`feedback_incorrect_v1` text. All other coverage above is representative sampling, not exhaustive line-by-line reading. The native `Act0RunnerStateV1` content system was not exhaustively or programmatically scanned in either revision — only specific lessons reached via targeted trace were read.

---

## Clean / Do-Not-Change Register

- **`available_actions_v1` / `expected_action` consistency, all W1–W6 JSON content** — Evidence reviewed: full programmatic scan of 493 drill/chain JSON files, 0 violations. Reason not to change: no defect exists. Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **Identical correct/incorrect feedback strings, all W1–W6 JSON content** — Evidence reviewed: full programmatic scan, 0 instances found. Reason not to change: no defect exists. Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **`lib/services/session_drill_repair_receipt_adapter_v1.dart`** — Evidence reviewed: full read of the reviewed-tuple allowlist (`_reviewedRepairTargetBySourceV1`) and the W6.s01 range-bucket path; fails closed on unknown source/drill pairs. Reason not to change: correctly scoped, no misrouting evidence within its actual scope (W4↔W6 pairs only). Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **`lib/ui_v2/act0_shell/act0_learning_run_payoff_v1.dart` (`Act0LearningRunPayoffPolicyV1`)** — Evidence reviewed: full read of outcome-priority logic and skill-descriptor map. Reason not to change: three-tier outcome language (mastered/repaired-recovered/still-needs-practice) is never conflated; unmapped skills get an explicit safe generic fallback instead of a false named claim; intentionally scoped to W1's three core skills only (`action_read`, `table_position_read`, `price_read`) by design, confirmed via `skillAtomId` usage sites in `act0_lesson_runner_shell_v1.dart` and `act0_shell_preview_screen_v1.dart`. Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **w1.s01 treatment of "range" vocabulary** (`content/worlds/world1/v1/sessions/w1.s01/session.md`) — Evidence reviewed: full read. Reason not to change: names the word without teaching the concept, explicitly deferring definition to later worlds — correct avoidance of "terminology before teaching." Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **W1 bet-sizing preview reps** (`bet_sizing_choice_v1` kind, w1.s01) — Evidence reviewed: full read of drill files and session.md. Reason not to change: session's own copy explicitly frames these as a "size-label preview," not a full decision task; absence of board/pot context is by design, not a missing-decision-input defect. Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.
- **`act0_shell_state_v1.dart`'s `_matchedChipsTransferRunner` (all-in/matched-chips lesson)** — Evidence reviewed (Revision 2): full read of options and feedback. Reason not to change: correctly renders explicit `stackLabel` values ('0 BB', '80 BB') on seats because stack-reading is this lesson's actual teaching target — a valid contrast case showing the engine renders stacks when the task calls for it. Audited HEAD: be887aefd81ffd9e5ffdb5b45901b6809fde1660.

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

- Reason confidence is limited: `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md` uses a qualitative 1-5 rating scale ("1 = thin," "does not feel like a teaser, shell, or thin sketch") rather than a numeric per-session file-count threshold. Raw file counts (World 3 ≈1.6 files/session vs. 4.0-12.4 for sibling worlds) are exact, but no canonical rule directly ties file count to a defect determination, so this cannot be asserted as a confirmed learner-facing P3 finding. It is also entangled with the still-unresolved ALI-SHARED-001 route-ownership question — if `content/worlds/world3/v1/` turns out not to be the primary reached content for World 3, its file-count density may be immaterial.
- Missing evidence required for confirmation: Either a maintainer-applied scorecard rating for World 3 under the existing qualitative rubric, or resolution of ALI-SHARED-001's route-ownership question first.
- Historical note: this candidate was originally recorded as confirmed finding `ALI-W3-002` (Severity P3, category `truncation_or_visibility_risk`) in Revision 1. The ID `ALI-W3-002` is retired from confirmed status but preserved here as a cross-reference; do not reuse `ALI-W3-002` for a new finding.

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
