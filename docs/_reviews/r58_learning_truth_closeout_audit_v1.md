# R58 Learning Truth Closeout Audit v1

## Milestone purpose/scope recap
- Milestone intent: close the highest-EV currently visible early-path cue-leak family after clean install evidence, using one bounded deterministic guard/cleanup pass.
- Primary fresh-run evidence input: prompts rendered as `"Choose the best action. Focus: raise."` in early action-choice UX.
- Scope held: one family only (`Focus: <action>` answer cue leakage), no broad prompt-family sweep, no runtime redesign, no personalization/schema work.

## Verified visible family inventory
- Dominant visible family (selected):
  - Surface: runtime prompt seam in `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart` (`_spineTaskLineV1`).
  - Rendered wording family: `"Choose the best action. Focus: <action>."`
  - Existing guard coverage at baseline: none on this exact runtime template.
  - User-visible footprint: high in early spine action-choice flow.
  - False-positive risk: low (exact template family).
- Non-selected nearby family:
  - Direct answer prompts (`"Choose fold/call/raise."`) in World1 content were already fenced/cleaned by R57.
  - Kept deferred as non-winning because clean-install visible issue was `Focus:` cue family.

## Why the selected family won
- It is the exact family confirmed as currently visible in fresh-run product evidence.
- It has highest immediate user-truth EV with one bounded insertion seam and low regression risk.
- It can be closed deterministically without expanding into multi-family prompt cleanup.

## Selected family and exact closure evidence
- Selected family: runtime cue template `Choose the best action. Focus: <action>.`
- Insertion point and closure:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - `_spineTaskLineV1` now always returns neutral prompt: `Choose the best action.`
  - Removed now-unused helper `_spineTaskExpectedActionLabelV1`.
- Guard/proof helper:
  - `tools/why_v1_ssot_v1.dart`
  - Added `hasActionFocusCueLeakV1(...)` with deterministic exact-family regex.
- Test contract updates:
  - `test/guards/world1_foundations_microtask_contract_test.dart` updated to assert no `Focus:` cue.
  - `test/tools/why_v1_ssot_v1_test.dart` added deterministic fail/pass cases for `hasActionFocusCueLeakV1`.

## Proof recap (gates + targeted test)
- Targeted proof runs:
  - `dart test test/tools/why_v1_ssot_v1_test.dart` PASS
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart --plain-name "world1 spine prompt is informative and varies across streets"` PASS
- Required gates:
  - `flutter analyze` PASS
  - `./tools/fast_loop_world1_v1.sh` PASS
  - `dart run tools/validate_world_content_v1.dart` PASS
  - `dart run tools/run_content_qa_r2_v1.dart` PASS

## Cleanup scope summary
- No broad content sweep required.
- Bounded cleanup stayed inside one runtime presentation seam plus minimal guard/test contract surfaces.

## Open-risk list
- Other prompt-leak families outside this exact `Focus:` template may remain and should be addressed only by separate evidence-backed bounded milestones.
- This milestone closes visibility leakage in selected seam; future UX wording consistency can be audited separately.

## Explicit defer list
- Generic all-world prompt cleanup.
- Multi-surface rollout of routing/prompt explanation UI.
- Any personalization/scoring/profile/dashboard expansion.

## Anti-drift note
- R58 closed exactly one visible cue-leak family and did not expand into generic prompt platform work.

## Ambiguous P0 status
- No ambiguous P0 remains for the selected `Focus: <action>` family in this milestone.

## Transition note (next focus only)
- Define `# Milestone R59` before execution work starts.
