const String kAiPersonalizationCompletedSchemaV1 =
    'ai_personalization_completed_v1';
const String kPersonalizationNextActionSchemaV1 =
    'personalization_next_action_v1';

const String kPersonalizationNextActionKeySchema = 'schema';
const String kPersonalizationNextActionKeyNextAction = 'next_action';
const String kPersonalizationNextActionKeyReason = 'reason';

const String kAiPersonalizationCompletedKeyEvent = 'event';
const String kAiPersonalizationCompletedKeyTimestamp = 'timestamp';
const String kAiPersonalizationCompletedKeyWeights = 'weights';
const String kAiPersonalizationCompletedKeyDurationMs = 'duration_ms';
const String kAiPersonalizationCompletedKeyLastUpdate = 'last_update';

const String kTelemetryEventHintShown = 'hint_shown';
const String kTelemetryEventHintCtaTapped = 'hint_cta_tapped';
const String kTelemetryEventHintRoutedToPhase = 'hint_routed_to_phase';
const String kTelemetryEventPersonalizationFallbackUsed =
    'personalization_fallback_used';

Map<String, Object?> buildPersonalizationNextActionPayloadV1({
  required String nextAction,
  required String reason,
}) {
  return {
    kPersonalizationNextActionKeySchema: kPersonalizationNextActionSchemaV1,
    kPersonalizationNextActionKeyNextAction: nextAction,
    kPersonalizationNextActionKeyReason: reason,
  };
}

Map<String, Object?> buildAiPersonalizationCompletedEventV1({
  required String timestamp,
  required Map<String, Object?> weights,
  required int durationMs,
  String? lastUpdate,
}) {
  return {
    kAiPersonalizationCompletedKeyEvent: kAiPersonalizationCompletedSchemaV1,
    kAiPersonalizationCompletedKeyTimestamp: timestamp,
    kAiPersonalizationCompletedKeyWeights: weights,
    kAiPersonalizationCompletedKeyDurationMs: durationMs,
    if (lastUpdate != null)
      kAiPersonalizationCompletedKeyLastUpdate: lastUpdate,
  };
}
