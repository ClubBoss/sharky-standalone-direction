---
status: "pre_qa_layout_and_proof_repair_complete_human_qa_ready"
status_source: "derived"
doc_date: "2026-07-08"
baseline: "17f153902f48"
generated_by: "docs_frontmatter_v1"
---

# Final Pre-QA Layout and Proof Repair v1

Date: 2026-07-08
Branch: `codex/final-pre-qa-layout-and-proof-repair-v1`
Verdict: `pre_qa_layout_and_proof_repair_complete_human_qa_ready`

## 1. Objective

Close the bounded pre-QA blockers identified by the holistic W1-W12 synthesis:

- `FINAL-SYNTH-001`: `practice_repair` layout void across the proof viewport set.
- `FINAL-SYNTH-002`: tablet-only `placement` / `welcome` first-use layout void.
- `FINAL-SYNTH-003`: `w12_terminal` proof capture was byte-identical to `play`.

No route admission, content, repair logic, telemetry contract, or progression behavior was intentionally changed.

## 2. Integrated Synthesis Proof

Accepted synthesis source:

- Branch: `claude/final-w1-w12-holistic-synthesis-v1`
- Integrated HEAD: `17f153902f4863ee6b4e845111c76510dba80f48`
- File: `docs/_reviews/final_w1_w12_holistic_product_learning_visual_synthesis_v1.md`

The synthesis branch was fast-forward integrated before this repair branch was created.

## 3. Accepted Findings Repaired

- `FINAL-SYNTH-001`: repaired by giving direct repair-runner states a repair-specific task-cycle viewport envelope, detected from existing repair context fields.
- `FINAL-SYNTH-002`: repaired with tablet-only placement fill content and tablet-aware welcome recomposition.
- `FINAL-SYNTH-003`: repaired by adding a dedicated W12 terminal debug capture surface, semantic terminal assertions, and terminal-vs-play byte comparison checks.

## 4. Findings Excluded or Deferred

- `FINAL-SYNTH-004`: stale `ACTIVE_ROUTE_CAPSULE_v1.md` residue was explicitly excluded by mission scope and was not edited.
- Local screenshots under `output/screen_review/` remain evidence-only and are not part of the staged artifact set.

## 5. practice_repair Before and After

Before: `tablet.practice_repair.png` showed a large empty band between the scaled table and lower repair prompt/action area.

After: the repair runner uses a repair-specific fixed lower slot, preserving a continuous table-to-dock composition. Guard coverage asserts:

- repair envelope key `act0_shell_runner_envelope_repairFill`
- tablet table height above 430 px
- table-to-dock gap no greater than 96 px
- dock starts within the lower active viewport rather than falling into a detached footer void

## 6. Placement and Welcome Tablet Before and After

Before: tablet `placement` and `welcome` used phone-style capped content, leaving roughly half the viewport visually empty before the CTA.

After:

- `placement` adds tablet-only support fill below the intro card, using the existing placement promise and no scoring/pressure framing.
- `welcome` uses a wider tablet frame, tablet minimum content height, bounded CTA gap, and a tablet row composition for the existing preview plus Sharky guide card.
- Compact phone welcome remains bounded to the existing narrow frame.

## 7. W12 Terminal Proof-Fidelity Repair

The proof tool now captures `w12_terminal` through `Act0ControlledDemoCaptureSurfaceV1.w12Terminal`, not the generic play runner surface.

The generated test asserts semantic terminal evidence:

- text containing `Volume I terminal review`
- text containing `future world`
- absence of `World 13`
- absence of `W13`

The tool also fails if any viewport's `w12_terminal` PNG is byte-identical to its `play` PNG.

## 8. Multi-Viewport Proof Rerun

Command:

```bash
dart run tools/act0_product_100_proof_capture_v1.dart
```

Result: passed.

Evidence root:

`output/screen_review/current/act0_product_100_proof/`

Manifest:

`output/screen_review/current/act0_product_100_proof/manifest.json`

Counts:

- Viewports: 4
- Surfaces: 13
- PNG entries: 52
- Zero-byte PNG entries: 0
- Terminal/play byte comparison: all differ

Terminal byte comparisons:

- `compact_phone`: play 188943 bytes, terminal 40998 bytes, byte-identical false
- `tall_phone`: play 208109 bytes, terminal 41730 bytes, byte-identical false
- `large_phone`: play 225492 bytes, terminal 65900 bytes, byte-identical false
- `tablet`: play 290390 bytes, terminal 91335 bytes, byte-identical false

Independent `cmp` checks returned exit code 1 for all four terminal/play pairs, confirming byte differences.

## 9. Product Behavior Invariance

Changed product behavior is limited to the admitted layout surfaces:

- direct repair-runner viewport envelope sizing
- tablet placement visual fill
- tablet welcome recomposition

The W12 terminal addition is a controlled debug/proof capture surface used by the screenshot tool. It does not admit W13, change route order, change content packs, change repair resolution, or change progression rules.

## 10. W12 Terminal / No-W13 Proof

Focused route guards passed:

```bash
flutter test test/guards/w12_route_admission_review_payoff_gate_contract_test.dart test/guards/w10_w12_canonical_structural_closure_contract_test.dart test/guards/w10_w12_grouped_content_repair_contract_test.dart
```

Result: 14 tests passed.

Key covered assertions include:

- W12 completion does not open W13.
- W12 terminal pack explains Volume I terminal state.
- W12 terminal safety remains unchanged.
- W10-W12 canonical route, payoff, repair, and terminal contracts stay fixed.

## 11. Validation Commands and Counts

Direct repair/proof guards:

```bash
flutter test test/guards/final_pre_qa_layout_and_proof_repair_contract_test.dart test/guards/act0_product_100_proof_capture_tooling_contract_test.dart
```

Result: 8 tests passed.

Route/no-W13/content guards:

```bash
flutter test test/guards/w12_route_admission_review_payoff_gate_contract_test.dart test/guards/w10_w12_canonical_structural_closure_contract_test.dart test/guards/w10_w12_grouped_content_repair_contract_test.dart
```

Result: 14 tests passed.

Affected Act0 repair/play guards:

```bash
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart
```

Result: 39 tests passed.

Affected first-use/startup/companion guards:

```bash
flutter test test/guards/world1_placement_flow_contract_test.dart test/guards/world1_app_root_startup_contract_test.dart test/guards/world1_intake_plan_flow_contract_test.dart test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart test/ui_v2/act0_sharky_growth_stage_consumer_v1_test.dart test/ui_v2/act0_sharky_companion_states_consumer_v1_test.dart
```

Result: 33 tests passed.

Static and hygiene checks:

```bash
flutter analyze
git diff --check
graphify hook-check
```

Results:

- `flutter analyze`: no issues found
- `git diff --check`: passed
- `graphify hook-check`: passed

## 12. Screenshot Evidence Index

Local evidence, not staged:

- `output/screen_review/current/act0_product_100_proof/tablet.practice_repair.png`
- `output/screen_review/current/act0_product_100_proof/tablet.placement.png`
- `output/screen_review/current/act0_product_100_proof/tablet.welcome.png`
- `output/screen_review/current/act0_product_100_proof/{compact_phone,tall_phone,large_phone,tablet}.w12_terminal.png`
- `output/screen_review/current/act0_product_100_proof/manifest.json`

## 13. Remaining Nonblocking Residue

- Human QA remains the next step for felt pacing and premium-readiness judgment.
- The local `output/screen_review/` directory is intentionally untracked.
- `ACTIVE_ROUTE_CAPSULE_v1.md` stale residue remains excluded by scope.

## 14. Human-QA Readiness Decision

Decision: `pre_qa_layout_and_proof_repair_complete_human_qa_ready`

Rationale:

- The three admitted P2 findings have code repairs, focused guards, regenerated evidence, and route/no-W13 validation.
- Proof tooling now prevents the prior false-positive terminal capture condition.
- No admitted blocker remains open inside this wave.

## 15. Explicit Non-Claims

- This is not a full release readiness claim.
- This is not a claim that Human QA has approved the final product feel.
- This is not a route/content expansion.
- This is not a W13 admission.
- This is not a stale-capsule cleanup.

## 16. Token Efficiency Report

- Narrow context route used: proof tooling, Act0 placement/welcome layout, direct repair runner layout, W12 terminal guard.
- Broad archive and donor roots were not read.
- Full-suite reruns were avoided; validation used focused affected guard sets plus `flutter analyze`, screenshot proof capture, `git diff --check`, and `graphify hook-check`.
- Screenshot artifacts were regenerated once after the final welcome recomposition and left local-only.
