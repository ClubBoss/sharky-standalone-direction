import 'persona_activation_synthesis_telemetry_envelope_v4.dart';

class PersonaActivationTelemetryUnifiedBridgeV4 {
  const PersonaActivationTelemetryUnifiedBridgeV4({
    required this.synthesisEnvelope,
    required this.telemetryEnvelope,
    required this.unifiedPayload,
  });

  final Map<String, Object?> synthesisEnvelope;
  final Map<String, Object?> telemetryEnvelope;
  final Map<String, Object?> unifiedPayload;

  factory PersonaActivationTelemetryUnifiedBridgeV4.fromEnvelopes({
    required PersonaActivationSynthesisTelemetryEnvelopeV4
    synthesisTelemetryEnvelope,
    required Map<String, Object?> unifiedOutbound,
  }) {
    final synthesisEnvelope = synthesisTelemetryEnvelope.asUnifiedTelemetry();
    final payload = <String, Object?>{
      'persona_v4_synthesis_full': synthesisEnvelope,
      'persona_v4_outbound': unifiedOutbound,
    };
    return PersonaActivationTelemetryUnifiedBridgeV4(
      synthesisEnvelope: synthesisEnvelope,
      telemetryEnvelope: unifiedOutbound,
      unifiedPayload: payload,
    );
  }

  Map<String, Object?> asUnified() => unifiedPayload;
}
