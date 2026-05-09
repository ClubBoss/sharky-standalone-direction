# Phase 2 Step 5 - Game Feel Audit (Release Path)

## 1) Scope + Rules
- Audit only. No code changes.
- Release-path surfaces only.
- Inventory haptics + sound usage using existing wiring.
- Note presence/missing per surface and event type.

## 2) Current Haptics Inventory
- Progress map / campaign entry surface
  - Present: success haptic on completed section toggle.
  - File: lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart
  - Event types: success (toggle).
- Onboarding (all steps)
  - Missing: no haptic calls found in onboarding flow screens.
  - File: lib/onboarding/onboarding_flow_manager.dart
  - Event types: tap, success, error, completion.
- Module summary
  - Missing: no haptic calls found.
  - File: lib/ui_v2/screens/module_summary_screen.dart
  - Event types: tap, navigation, completion.
- Theory session (CTA to start)
  - Missing: no haptic calls found.
  - File: lib/ui_v2/screens/theory_session_screen.dart
  - Event types: tap, navigation.
- Drill runner
  - Missing: no haptic calls found.
  - File: lib/ui_v2/screens/drill_runner_screen.dart
  - Event types: option tap, correct, incorrect, next/continue.
- Session result / victory moment
  - Missing: no haptic calls found.
  - File: lib/ui_v2/session/ui_v2_session_result_screen.dart
  - Event types: completion, continue.

Supporting wiring:
- UiHapticsV1 (success/error) gated by AppSettingsService.
  - File: lib/ui_v2/visual/ui_haptics_v1.dart

## 3) Current Sound Inventory
- Progress map / campaign entry surface
  - Present: success sound on completed section toggle.
  - File: lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart
  - Event types: success (toggle).
- Onboarding (all steps)
  - Missing: no sound calls found in onboarding flow screens.
  - File: lib/onboarding/onboarding_flow_manager.dart
  - Event types: tap, success, error, completion.
- Module summary
  - Missing: no sound calls found.
  - File: lib/ui_v2/screens/module_summary_screen.dart
  - Event types: tap, navigation, completion.
- Theory session (CTA to start)
  - Missing: no sound calls found.
  - File: lib/ui_v2/screens/theory_session_screen.dart
  - Event types: tap, navigation.
- Drill runner
  - Missing: no sound calls found.
  - File: lib/ui_v2/screens/drill_runner_screen.dart
  - Event types: option tap, correct, incorrect, next/continue.
- Session result / victory moment
  - Missing: no sound calls found.
  - File: lib/ui_v2/session/ui_v2_session_result_screen.dart
  - Event types: completion, continue.

Supporting wiring:
- UiSoundV1 (tap/success/error) -> AudioService, gated by AppSettingsService.
  - File: lib/ui_v2/audio/ui_sound_v1.dart
  - File: lib/core/services/audio_service.dart

## 4) Gaps (Prioritized)
- P1: Drill runner lacks tap + correct/incorrect feedback.
  - Fix direction: use UiSoundV1.fire(UiSoundEventV1.tap/success/error) and UiHapticsV1.fire(UiHapticEventV1.success/error) at existing option tap and reveal points.
- P1: Session result has no completion cue.
  - Fix direction: use UiSoundV1.fire(UiSoundEventV1.success) and UiHapticsV1.fire(UiHapticEventV1.success) on screen entry or continue CTA.
- P2: Onboarding CTAs have no tap/complete feedback.
  - Fix direction: use UiSoundV1.fire(UiSoundEventV1.tap) and optionally UiHapticsV1.fire(UiHapticEventV1.success) on final completion.
- P2: Theory session CTA lacks tap cue.
  - Fix direction: use UiSoundV1.fire(UiSoundEventV1.tap).
- P2: Module summary entry actions lack tap/navigation cue.
  - Fix direction: use UiSoundV1.fire(UiSoundEventV1.tap).
- P2: Progress map primary actions (non-completed toggle) lack tap cue.
  - Fix direction: use UiSoundV1.fire(UiSoundEventV1.tap) on primary CTAs without altering navigation.

## 5) Verdict
Gaps exist. Minimal fixes can be implemented using existing UiHapticsV1/UiSoundV1 wiring with no new dependencies.
