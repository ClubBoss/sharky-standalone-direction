# R45 Onboarding/Binding Closeout Audit v1

## Milestone purpose/scope recap
- Milestone intent: verify-first and close one bounded onboarding/binding trust mismatch around duplicate/conflicting first-run completion binding.
- Scope held: one deterministic key-bridge rule only; no broad onboarding redesign, no map redesign, no multi-family cleanup, no schema/dependency changes.

## Verification inventory summary
- First-run completion signals observed in active code:
  1) `onboardingCompleted` (used by `AppRoot` entry gating and broad runtime/test harness).
  2) `onboarding_complete` (used by `OnboardingPreferencesService` in UI-v2 onboarding package).
- Existing mismatch class:
  - onboarding completion persistence paths were split across two keys, so completion written through one surface was not guaranteed to be recognized by the other.
- Existing distinguishing contracts/signals:
  - runtime entry uses canonical `onboardingCompleted` + `intake_completed_v1`.
  - onboarding package completion API is the bounded bridge point.

## Selected dedup/binding rule and why it won
- Selected rule: unify onboarding completion binding in `OnboardingPreferencesService`.
  - Read completion from canonical key first, then legacy key.
  - Write completion to both keys.
  - Reset both keys.
- Why selected:
  - deterministic under identical state,
  - single bounded surface,
  - highest EV for first-run dedup/binding trust with minimal runtime diff,
  - no route redesign required.

## Exact closure evidence
- Runtime/service update:
  - `lib/ui_v2/onboarding/onboarding_preferences_service.dart`
  - canonical/legacy key bridge added.
- Deterministic contract proof:
  - `test/ui_v2/onboarding_preferences_service_contract_test.dart`
    - legacy-only state is treated as completed,
    - set-complete writes both keys.

## Proof recap (gates + targeted test)
- `flutter analyze` -> PASS
- `./tools/fast_loop_world1_v1.sh` -> PASS
- `flutter test test/ui_v2/onboarding_preferences_service_contract_test.dart` -> PASS

## Open-risk list
- Route-level onboarding UX harmonization remains out of scope and deferred.
- Additional first-run path simplification (if needed) requires separate verify-first milestone.

## Explicit defer list
- Broad onboarding UX redesign.
- Multi-surface map/home/start CTA consolidation.
- Personalization expansion and unrelated learning-truth families.

## Anti-drift note
- R45 closes exactly one onboarding/binding mismatch class via completion-key binding.
- Do not expand this closeout into multi-surface onboarding redesign.

## Ambiguous P0 status
- No ambiguous P0 remains for the selected R45 onboarding/binding key-mismatch class.

## Transition note (next focus only)
- R46 must be defined before execution starts; do not begin R46 implementation without a bounded SSOT definition.
