import 'persona_activation_synthesis_final_v4.dart';

class PersonaActivationSynthesisEnvelopeV4 {
  const PersonaActivationSynthesisEnvelopeV4({
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

  factory PersonaActivationSynthesisEnvelopeV4.fromFinal(
    PersonaActivationSynthesisFinalV4 finalLayer,
  ) {
    return PersonaActivationSynthesisEnvelopeV4(
      synthesis0: finalLayer.synthesis0,
      annotation: finalLayer.annotation,
      weightScore: finalLayer.weightScore,
      resolved: finalLayer.resolved,
      finalState: finalLayer.finalState,
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    return {
      'synthesis0': synthesis0,
      'annotation': annotation,
      'weightScore': weightScore,
      'resolved': resolved,
      'finalState': finalState,
    };
  }
}
