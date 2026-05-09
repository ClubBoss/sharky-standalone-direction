import 'persona_activation_synthesis_envelope_v4.dart';
import 'persona_activation_synthesis_telemetry_v4.dart';

class PersonaActivationSynthesisTelemetryEnvelopeV4 {
  const PersonaActivationSynthesisTelemetryEnvelopeV4({
    required this.synthesis,
    required this.telemetryAligned,
  });

  final Map<String, Object?> synthesis;
  final Map<String, Object?> telemetryAligned;

  factory PersonaActivationSynthesisTelemetryEnvelopeV4.fromSources({
    required PersonaActivationSynthesisEnvelopeV4 synthesisEnvelope,
    required PersonaActivationSynthesisTelemetryV4 telemetrySnapshot,
  }) {
    return PersonaActivationSynthesisTelemetryEnvelopeV4(
      synthesis: synthesisEnvelope.asReadOnlyMap(),
      telemetryAligned: telemetrySnapshot.asTelemetryMap(),
    );
  }

  Map<String, Object?> asUnifiedTelemetry() {
    return {
      'persona_v4_synthesis': synthesis,
      'persona_v4_synthesis_telemetry': telemetryAligned,
    };
  }
}
