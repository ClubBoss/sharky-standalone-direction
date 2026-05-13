import 'persona_activation_synthesis_weighted_v4.dart';

class PersonaActivationSynthesisResolvedV4 {
  const PersonaActivationSynthesisResolvedV4({
    required this.synthesis0,
    required this.annotation,
    required this.weightScore,
    required this.resolved,
  });

  final Map<String, Object?> synthesis0;
  final String annotation;
  final double weightScore;
  final String resolved;

  factory PersonaActivationSynthesisResolvedV4.fromWeighted(
    PersonaActivationSynthesisWeightedV4 base,
  ) {
    final resolved = base.weightScore == 1.0
        ? 'resolved_strong'
        : 'resolved_soft';
    return PersonaActivationSynthesisResolvedV4(
      synthesis0: base.synthesis0,
      annotation: base.annotation,
      weightScore: base.weightScore,
      resolved: resolved,
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    return {
      'synthesis0': synthesis0,
      'annotation': annotation,
      'weightScore': weightScore,
      'resolved': resolved,
    };
  }
}
