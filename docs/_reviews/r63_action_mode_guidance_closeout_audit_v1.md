# R63 Action-Mode Guidance Closeout Audit v1

## Milestone purpose/scope recap
- Milestone: R63 — Early-Path Coherence Recovery v5 (Action-Mode Guidance Clarity).
- Purpose: close one highest-EV bounded action-mode guidance clarity mismatch family after R62.
- Scope held: one deterministic repetitive low-meaning action-mode prompt family in early World1 spine action steps.
- Out of scope held: broad copy rewrite, onboarding redesign, result/progression redesign, personalization/scoring, schema/dependency changes.

## Verified action-mode guidance inventory summary
- Confirmed family A (selected): repetitive low-meaning generic action prompt copy (`Choose the best action.`) in World1 spine action-mode task seam.
  - Surface:
    - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
    - `_spineTaskLineV1(_CampaignActionUiState? state)`.
  - Failing behavior: mechanically correct but too thin to explain what the learner is practicing.
  - Type: runtime copy/presentation.
  - User-visible impact: first action-decision minutes feel command-following instead of skill-oriented practice.
  - Boundedness: one deterministic wording family in one runner seam.
- Non-selected residuals:
  - result/progression coherence seams remained deferred,
  - broader multi-surface teaching/UX copy refresh remained deferred by stop rules.

## Why the selected family won
- Highest-confidence remaining action-mode clarity mismatch in first-user visible flow.
- Deterministic and bounded to one runtime seam with low regression risk.
- Largest safe slice without reopening multi-family UX work.

## Deterministic contract
- For World1 spine action-mode steps under prompt-quality target, the task line must include:
  - short purpose framing (`Practice: <Street> decision.`), and
  - non-leaking instruction (`Choose the best action.`).
- Contract is deterministic under identical state via existing street label resolver.
- Behavior outside selected family remains unchanged.

## Exact closure evidence
- Runtime implementation:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - `_spineTaskLineV1` now emits:
    - `Practice: <Street> decision. Choose the best action.`
  - Uses existing `_streetLabelForPromptV1(_step.street)` helper.
- Contract tests:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - Updated `world1 spine prompt is informative and varies across streets` to assert deterministic street-specific practice framing for flop/river while retaining non-leaking action instruction.
  - Updated `world1 followup action-state shows polished line without duplicate instruction` to assert selected prompt family now starts with `Practice:` and retains `Choose the best action.`.

## Proof recap (gates + targeted tests)
- Targeted proofs (PASS):
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart --plain-name "world1 spine prompt is informative and varies across streets"`
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart --plain-name "world1 followup action-state shows polished line without duplicate instruction"`
- Required gates (PASS):
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Content validators: not required (no content/tooling surfaces touched).

## Open-risk list
- Additional early teaching/UX clarity seams may remain (for example deeper narrative framing), but must be isolated as separate bounded families.

## Explicit defer list
- Broad all-world guidance copy rewrite.
- Multi-surface coach/UX redesign.
- Result/progression framing overhaul.
- Personalization/routing/scoring expansion.

## Anti-drift note
- R63 changed one bounded action-mode guidance family only.
- No action-contract logic redesign and no multi-family cleanup drift.

## Ambiguous P0 status
- No ambiguous P0 remains inside the selected R63 family.

## Transition note for next focus only
- Define `# Milestone R64` before any R64 execution work and select the next bounded post-R63 recovery layer by evidence.
