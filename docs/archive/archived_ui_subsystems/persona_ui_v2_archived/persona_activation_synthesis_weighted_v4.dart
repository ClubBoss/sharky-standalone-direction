import 'persona_activation_synthesis_annotated_v4.dart';

class PersonaActivationSynthesisWeightedV4 {
  const PersonaActivationSynthesisWeightedV4({
    required this.synthesis0,
    required this.annotation,
    required this.weightScore,
  });

  final Map<String, Object?> synthesis0;
  final String annotation;
  final double weightScore;

  factory PersonaActivationSynthesisWeightedV4.fromAnnotated(
    PersonaActivationSynthesisAnnotatedV4 base,
  ) {
    final weightScore = base.annotation == 'tier0_ok' ? 1.0 : 0.5;
    return PersonaActivationSynthesisWeightedV4(
      synthesis0: base.synthesis0,
      annotation: base.annotation,
      weightScore: weightScore,
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    return {
      'synthesis0': synthesis0,
      'annotation': annotation,
      'weightScore': weightScore,
    };
  }
}
