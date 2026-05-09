# M3 Emotion Layer Done V1

Status
- M3.1 and M3.2 are DONE as service-only skeleton work.
- No UI, routing, economy, content, or tools changes are required for this layer.

Public Entrypoints
- `EmotionTagV1 deriveEmotionTagV1({ required MasteryReadBundleV1 mastery, required GauntletPlanV1 plan })`
  - Path: `lib/services/progress_service.dart`
- `static Future<EmotionReadBundleV1> ProgressService.getEmotionReadBundleV1()`
  - Path: `lib/services/progress_service.dart`

Deterministic Rule Table
- `urgent`: any recommended in-progress world has completion ratio `< 0.34`.
- `cautious`: otherwise, at least one recommended world is in-progress.
- `confident`: otherwise, at least one world badge is `highTier`.
- `neutral`: otherwise.

Reason Codes
- `low_completion_ratio`
- `in_progress`
- `high_tier_ready`
- `neutral_baseline`

Telemetry Contract
- Event: `emotion_tag_v1`
- Emission point: `ProgressService.markModuleCompleted(...)` on first completion only.
- Emitted from helper: `_emitEmotionTagTelemetryV1()` in `lib/services/progress_service.dart`.
- Payload fields:
  - `schemaVersion`
  - `tag`
  - `reasons`
  - `recommendedWorldIds`
  - `masteryBadges` (sorted worldId to badge map)

Locked Test Surface
- `test/services/mastery_progress_v1_surface_test.dart`
- Key assertions locked:
  - deterministic bundle and telemetry payload encoding across repeated reads/runs
  - idempotency: second completion of same module does not emit duplicate mastery or emotion completion telemetry
  - fixture expectations: stable `tag`, `reasons`, `recommendedWorldIds`, and sorted badge keys

Deferred
- Session-end emission of emotion payload.
- UI surfacing and coach copy integration.
