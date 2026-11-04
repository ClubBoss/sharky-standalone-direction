# SHARKY_F7_INTEGRATION_PREPARATION_V1

Runner C: isolated Cloud preparation, no native writer or runtime activation.
Baseline: accepted main `2a79ecf5daa3c0774ea639c61aea734229ed33b5`, tree
`bc6925c0ea60612ea82165ebd1a0740c787f88f0` (merged #374). The candidate HEAD/TREE
are the final Draft PR identifiers; this manifest does not embed its own hash.

Authority: live AGENTS / Master Plan v5; [owner decision on #341](https://github.com/ClubBoss/sharky-standalone-direction/pull/341#issuecomment-6615889205);
merged TABLE.TRUTH #369 and ASM-04 #374. Historical #341 is a donor, never a
merge/cherry-pick source for shared runtime. Its independent assessment and
native receipts retain their historical source/binary identities.

## Asset and leased files

Exact original `assets/design/sharky/pw_c3/owner_clean_table_candidate_965x1629.png`:
2,688,679 bytes, 965×1629, Git blob `bf55b94e3e186f7ec8c7c355d8d746484136a1fa`,
SHA-256 `a34b9cec6cdb64743fc5ad5047223bf62a75b5a8f118da0b63332ff469efcd03`.
Retrieved from verified #341 donor head
`fcc53675ea9217fc30ca996ccce8dc515fe9c080`. Five baked opponents, room/table and
Hero POV hands; no independent state-specific/empty-seat artwork. No art edits.

All files were absent on baseline before leasing:

- `lib/ui_v2/act0_shell/act0_scene_profile_v1.dart`: exact donor profile,
  registration and geometry; `owner_clean_six_seated_p1_runtime_v1`.
- `act0_f7_scene_source_v1.dart` in that directory: read-only task/runtime
  inventory using current Runner teaching/feedback/choreography owners.
- `act0_f7_scene_compatibility_v1.dart`: three deterministic dispositions with
  exact variant/seat reasons. Scenery suitability never certifies poker truth.
- `act0_f7_scene_gate_v1.dart`: exclusive scene builders, existing decode store,
  dimension check, generation fencing and task/attempt-scoped fallback latch.
- `test/ui_v2/act0_f7_preparation{,_gate}_v1_test.dart`: F7-only tests.
- This manifest and the exact PNG above.

No existing tracked file is changed. Core A owns shared integration, grading,
evidence, XP, repair and persistence. Academy #375 owns `academy_leaves/`, its
tests/manifest and `assets/design/sharky/home/`; no changed path intersects its
verified head `f19f84f5cc0dfb4db9251d51ad5a1b0876c135ea`.

## Current compatibility

Recomputed from baseline's 367 authored tasks across 2,738 inventory variants:
**337 PNG suitable / 30 existing procedural fallback / 0 insufficient scene
context**. Inventory includes authored, raw/projected teaching, every option's
feedback, review and supported choreography frames. This is a scenery preflight,
not the full TABLE.TRUTH variant census or a complete economic-history proof.
Missing pot/history/to-call facts remain unknown under existing source owners.
Every decision has `certifiesPokerTruth == false`, including suitable scenes.

All 30 exclusions contain a genuinely empty UTG; the last three also contain
empty SB, BB and HJ. No empty seat was converted to occupied/folded. Exact IDs:

| Source task ID | Incompatible source seats |
| --- | --- |
| first_table_guide_one_clear_choice | utg |
| first_table_guide_route_roles | utg |
| actions_theory | utg |
| actions_raise_drill | utg |
| actions_review | utg |
| hand_discipline_buckets_intro | utg |
| hand_discipline_buckets_premium | utg |
| hand_discipline_buckets_strong | utg |
| hand_discipline_buckets_medium | utg |
| hand_discipline_buckets_borderline | utg |
| hand_discipline_buckets_recap | utg |
| weak_ace_warning_w3_dominated_intro | utg |
| continue_or_let_go_continue_intro | utg |
| continue_or_let_go_premium_continue | utg |
| continue_or_let_go_medium_open | utg |
| apply_intro | utg |
| apply_btn_open | utg |
| discipline_checkpoint_checkpoint_intro | utg |
| discipline_checkpoint_checkpoint_premium | utg |
| button_advantage_button_open | utg |
| same_hand_different_seat_same_hand_late_open | utg |
| position_apply_btn_open | utg |
| position_apply_late_open | utg |
| position_apply_recap | utg |
| position_checkpoint_position_checkpoint_late_open | utg |
| position_checkpoint_position_checkpoint_table_notice | utg |
| position_checkpoint_position_checkpoint_review | utg |
| w6_kicker_showdown_compare | sb, bb, utg, hj |
| w6_board_pair_strength_compare | sb, bb, utg, hj |
| w6_checkpoint_table_best_five | sb, bb, utg, hj |

The unit test exports exact per-variant reasons and inventory to ignored local
`output/f7_preparation/compatibility.json`. Rerun on changed source; do not use
historical counts as an eligibility oracle. Room changes between tasks remain
possible, including five W1 exclusions. Within a complete task/attempt the
fallback is latched. Unexpected incompatible same-key updates fail closed and
invalidate pending decoding rather than retaining a misleading baked person.

## Exact future activation patch specification (Core A only; unapplied)

1. Add exactly this entry under the existing `flutter.assets` in `pubspec.yaml`:
   `- assets/design/sharky/pw_c3/owner_clean_table_candidate_965x1629.png`.
   The PNG is deliberately unbundled in this preparation PR.
2. Import the profile/source/gate helpers into the existing Lesson Runner.
   Preserve the default-OFF `bool.fromEnvironment('SHARKY_F7_TABLE_SCENE_PREVIEW')`.
   No define in `lib/main.dart`, boot promotion or owner-default change.
3. In `_Act0LessonRunnerShellV1State.build`, inventory the **actual** immutable
   task/attempt input with `Act0F7SceneSourceV1.fromRunner(runner: widget.runner,
   taskFamily: widget.selectedTaskFamily, scenarioKey: scenarioKey)`. The key
   includes selected task identity plus the existing attempt/replay generation;
   generated Placement questions sharing a task ID require their actual signal/
   question generation too. Never use a sample-catalog lookup or feedback phase
   as the runtime identity. A new task/attempt remount resets the gate; ordinary
   feedback, assistance and animation retain it. Include all external theory-
   recall/replay source variants in `tables` before preflight if they are not
   already in that runtime runner. Missing complete inventory means fallback.
4. At the existing `act0_shell_canonical_scene_box` LayoutBuilder (baseline
   around line 4380), keep `runnerScreen` outside `Act0F7SceneGateV1`. The original
   builder retains the exact current environment + `buildPhysicalTableV1` path.
   The registered builder paints `Act0F7RegisteredScenePainterV1` in the full
   scene box and reuses the current live object widgets. No loading path may
   unmount learning controls. Keep existing noncanonical callers procedural.
5. Thread one optional registration through `buildPhysicalTableV1` →
   `_RunnerTableStageV1` → `_Act0TableSceneRunnerInput` → `_Act0TableV1`. Reuse
   `_visualSeatOrder` (canonical order rotated around actual Hero). Map each
   slot to profile seat/hole-card/bet/dealer anchors through **one**
   `profile.register(sceneBox)`; remove the camera stage offset for that branch.
   Map Hero/board/pot/street/clue similarly. Use donor card widths/tilt and fixed
   five-slot board; render only source-owned revealed cards. Do not place a
   second full scene engine beside the Runner.
6. In registered mode suppress existing room/hybrid-shell, grounding/felt/rail,
   both tiered opponent planes, fallback body avatars and Hero foreground/hands
   (`_Act0TableV1` and `_SeatNodeV1` decorative branches). Retain `_SeatPlacementV1`,
   `_BetChipPlacementV1`, seat labels/buttons, cards, Folded badges and current
   source interaction/feedback logic. Seated folded people remain baked; their
   cards/commitments obey the existing source renderer. Do not suppress live
   objects together with decorative layers. Unsupported/failed decode restores
   the complete original scene exclusively.
7. Preserve the accepted `presentationTable` assessment projection near line
   3100 (especially #374 quads neutralization), choreography/readiness, current
   cue/center-label suppression and literal actor/dealer/blind ownership. The
   source inventory is **never** a replacement displayed table. Keep pot/bet
   overrides from their current callsites; visible commitments are not the pot.
8. Use the profile `controlShelfTop` / `headerScrimBottom` for registered-only
   shelf clearance/scrim. Retain the current question/answer/feedback owners,
   not donor learning surfaces. Prove actual option exposure/scroll/44pt targets;
   this PR's external 48pt button fixture is not integrated shelf acceptance.

Accepted callback owners remain `onChooseOption`, `onChooseSeat`,
`onSelectSizingPreset`, `onConfirmSizingPreset`, `onCompletedDecision`,
`onChoiceAssistance`, `onContinueTheory`, `onPreviousTheory`, `onUndoInteraction`,
`onContinueReview` and `onBack`, with current telemetry/evidence owners. No new
grading, assistance, completion, persistence or navigation path is introduced.
Use #341 only to compare measured registration/overlay mechanics; never import
its historical runner, shell state, grading, content or entire shelf wholesale.

## Validation and native acceptance

Local evidence is kept under `output/context-economy/`. New tests cover exact
bytes/registration, full task compatibility, genuine empty/folded seats, real
first-hand streets, source-owned cards/board/actor/dealer/pot/bets, unknown source,
runtime-input adapter, exclusive builder selection, 48pt external control and
callback, missing/corrupt/wrong-size assets, cold loading, late completion and
fallback latching. Existing targeted TABLE.TRUTH/first-hand/assistance/ASM-04
tests protect current owners; no new local global poker census is performed.

The Draft PR/final packet records actual test counts, format/analyze, canonical
Tier A/terminal B, exact-head hosted CI and independent source review. Hosted
standard workflows do not automatically run these two newly leased F7 test
files: their focused local result is reported separately, without CI credit.

Frozen source validation: 13 F7 tests and 35 existing focused regression cases
PASS; format and full `flutter analyze` PASS (Flutter 3.35.0 / Dart 3.9.0).
Canonical authority: Tier A 14/14 commands and terminal Tier B 16/16 files PASS,
zero failures/errors/timeouts/skips; these are lane units, not test-case counts.
Initial F7 run retained 8 PASS / 4 FAIL: the helper had mistaken source-owned
empty-string actor IDs for missing actors. Correcting that interpretation gave
12/12 PASS. A second bounded adapter addition preserves generated runtime
inputs and adds the thirteenth case. No source truth or accepted test changed.
Independent non-author read-only review: `PASS_SCOPED_PREPARATION`, no blocking
defect, no reviewer edits/tests/native actions; six reviewed Dart SHA-256 hashes
are retained in local `output/f7_preparation/INDEPENDENT_SOURCE_REVIEW.md` and
verified against the frozen candidate. Integrated visual claims remain pending.

Native acceptance is **not performed or claimed** in this Cloud branch. After
Core A integration, the designated Mac owner must pin final HEAD/TREE, Flutter/
Dart/Xcode, locks, exact product defines, device/OS/scale, App/kernel/installed
asset hashes and original PNG+AX/screenshot hashes, including real F7 ON/OFF.
Use only EN iPhone 14 Pro 393×852; no second native writer or other-device wave.

| Required actual native scenario | Acceptance |
| --- | --- |
| First-use Actions teaching and decision | True source prompt/options; all answers readable/reachable; ≥44pt targets |
| Five opponents and Hero POV | No duplicate bodies, hands, rail/table or room layers |
| Folded seated players | Correct Folded labels; source visibility/chips; no false active actor |
| Genuine empty seats and adjacent task transition | Entire incompatible scenario uses procedural scene; record room change |
| Preflop/flop/turn/river/showdown | Exact source cards/board, actor/dealer/blinds, pot and current-street bets |
| Wrong/correct/Quick Hint/Theory Recall/assisted feedback | Existing callbacks, neutral assessment, honest assistance and repair |
| Restart and cold/missing asset | Durable learner payload retained; truthful stable fallback; controls remain usable |
| TT-REVIEW-P2-01 | Recheck showdown comparison truncation against actual new scene |
| TT-REVIEW-P2-02 | Recheck stale folded-CO feedback outline; do not change poker state |

Risks: static seated poses; 30 task fallbacks and inter-task visual switches;
historical Coach/face and last-answer occlusion; HJ label/forearm contact;
unverified integrated duplicate-layer suppression/overlay geometry/44pt targets;
incomplete economic histories remain unverified. Source gate tests and donor
native receipts cannot promote F7 default ON, TEMP_TABLE_FROZEN, S12.V, Human,
P02, release or original DoD points.

## Rollback and readiness

Before integration: leave/close the Draft; main/runtime stay untouched. Later
runtime rollback: omit/disable F7 define and select the existing procedural
builder, retaining source state and learner history. Asset/decode/compatibility
failure already selects that original builder. Never revert #369/#374 to make
an old donor work. No merge, native execution or decorative freeze is authorized
by this preparation receipt. Final preparation verdict requires passing focused
checks and independent read-only source review; runtime/native acceptance stays
pending with the integration owner.
