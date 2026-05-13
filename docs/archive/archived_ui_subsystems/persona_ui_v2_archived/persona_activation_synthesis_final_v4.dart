import 'persona_activation_synthesis_resolved_v4.dart';

class PersonaActivationSynthesisFinalV4 {
  const PersonaActivationSynthesisFinalV4({
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

  factory PersonaActivationSynthesisFinalV4.fromResolved(
    PersonaActivationSynthesisResolvedV4 base,
  ) {
    final finalState = base.resolved == 'resolved_strong'
        ? 'final_strong'
        : 'final_soft';
    return PersonaActivationSynthesisFinalV4(
      synthesis0: base.synthesis0,
      annotation: base.annotation,
      weightScore: base.weightScore,
      resolved: base.resolved,
      finalState: finalState,
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
