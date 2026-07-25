---
status: "w1_w6_repair_wave4_structured_context_actionability_closed"
status_source: "derived"
baseline: "1105620f91cc"
generated_by: "docs_frontmatter_v1"
---

# W1-W6 Repair Wave 4: Structured Table Context + Mobile Actionability v1

Verdict: `w1_w6_repair_wave4_structured_context_actionability_closed`

Branch: `codex/w1-w6-repair-wave4-structured-context-actionability-v1`

Base HEAD: `1105620f91cc183bda90bead10a539f5e8a5b6b6`

Implementation commits:

- `058ccec9` - `fix: surface structured table context in active drills`
- `4af55086` - `fix: preserve compact decision actionability`

## Scope

This wave closed the two admitted learner-truth findings only:

- W1W6-LT-008: active W5 board-texture drills must carry authored visible table context instead of relying on prompt text or runtime inference.
- W1W6-LT-006: compact mobile actionability must be proven against the current Act0 learner route, not retired map keys.

No W7+ route expansion, new content family, visual/mascot/motion work, monetization work, telemetry work, or broad full-suite repair was started.

## Structured table context

Active W5 `board_texture_classifier_v1` rows in `w5.s01` through `w5.s10` now author:

- `scenario_core_v1.street_v1`
- `scenario_core_v1.board_cards_v1`

The runtime parser accepts board-card count by street:

- flop: 3 visible cards
- turn: 4 visible cards
- river: 5 visible cards

The previous W5 fallback derivation from session id, prompt words, or texture name was removed. W5 board-texture scenario state now fails closed without authored table context.

The active runner now exposes W5 texture source meta through the existing source-meta lane for embedded W5 board-texture rows. This reused the existing texture source-meta builder rather than adding a new learner-facing concept.

## Mobile actionability

The W4 compact actionability guard was updated from retired map controls to the current canonical Act0 route:

Home -> bottom navigation Learn tab -> current mission card -> current mission CTA.

The guard proves the bottom navigation and mission CTA remain reachable on 360 x 640 compact portrait. A second guard proves the CTA clears a bottom safe-area chin and remains enabled.

## Validation

Focused structured-context validation:

- `flutter test -r compact test/ui_v2/runner/session_drill_canonical_board_texture_scenario_state_v1_test.dart test/guards/world5_early_runtime_truth_contract_test.dart test/ui_v2/runner/session_drill_canonical_source_meta_entries_v1_test.dart test/ui_v2/session_drill_player_world5_structured_context_contract_test.dart` - PASS (`14/14`)

Focused compact-actionability validation:

- `flutter test -r compact test/guards/world4_campaign_routing_contract_test.dart --plain-name 'world4'` - PASS (`6/6`)

Identity, admission, feedback, terminology, and parity validation:

- `flutter test -r compact test/guards/canonical_truth_map_v1_contract_test.dart --plain-name 'canonical truth map v1 locks learner-facing world identity'` - PASS
- Seven-file Tier0 admission set - PASS (`37/37`)
- `flutter test -r compact test/tools/w1_w6_feedback_completeness_guard_v1_test.dart test/tools/term_introduction_glossary_safety_v1_test.dart test/guards/world3_early_arc_runtime_truth_contract_test.dart test/guards/world5_early_runtime_truth_contract_test.dart` - PASS (`14/14`)
- `dart run tools/term_coverage_scanner.dart --help` - PASS

Policy-gated validation:

- `./tools/fast_loop_world1_v1.sh` - PASS
- `./tools/release_gate_world1.sh` - PASS
- `flutter analyze` - PASS
- `git diff --check` - PASS
- `git diff --cached --check` - PASS
- `graphify hook-check` - PASS

Checkpoint:

- `./tools/checkpoint_world1_v1.sh` reached the full-suite phase after the checkpoint Tier0/release-gate sections passed.
- The full-suite phase surfaced known unrelated global debt and was stopped after repeated non-Wave-4 failures appeared.
- Examples observed: missing `lib/audit_hub_v1/*` imports, stale `stack_range_filter_test.dart` function-call syntax, stale smoke tests (`yaml_spot_parser_smoke_test.dart`, `win_overlays_smoke_test.dart`, `weekly_summary_card_smoke_test.dart`, and others), and unrelated personalization/legacy expectation failures.
- No Wave 4 focused validator failed after the fixes above.

## Deferred / not opened

- Runtime-bundle parity debt remains outside this wave: `test/services/drill_runtime_adapter_v1_asset_bundle_test.dart --plain-name 'repaired world3 and world5 manifest truth stays in parity across source, test bundle, and runtime bundle'` still observes stale runtime-bundle W3 checkpoint drift.
- Broad full-suite legacy compile/test debt remains outside this wave.
- No generated output was admitted or committed.

## Final state

Wave 4 is closed for the admitted W1-W6 repair program scope.

Exact next owner action:

Integrate the Wave 4 branch into `main` if the owner accepts the focused green validation with known global full-suite debt excluded.
