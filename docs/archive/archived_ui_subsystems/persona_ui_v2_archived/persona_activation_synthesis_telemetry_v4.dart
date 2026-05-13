import 'persona_activation_synthesis_envelope_v4.dart';

class PersonaActivationSynthesisTelemetryV4 {
  const PersonaActivationSynthesisTelemetryV4({
    required this.synthesis0,
    required this.annotation,
    required this.weightScore,
    required this.resolved,
    required this.finalState,
  });

  final Map<String, Object?> synthesis0;
  final String annotation;
  final double weightScore;
  final String resolved;
  final String finalState;

  factory PersonaActivationSynthesisTelemetryV4.fromEnvelope(
    PersonaActivationSynthesisEnvelopeV4 envelope,
  ) {
    return PersonaActivationSynthesisTelemetryV4(
      synthesis0: envelope.synthesis0,
      annotation: envelope.annotation,
      weightScore: envelope.weightScore,
      resolved: envelope.resolved,
      finalState: envelope.finalState,
    );
  }

  Map<String, Object?> asTelemetryMap() {
    return {
      'synthesis_v4': synthesis0,
      'annotation_v4': annotation,
      'weight_score_v4': weightScore,
      'resolved_v4': resolved,
      'final_state_v4': finalState,
    };
  }
}
