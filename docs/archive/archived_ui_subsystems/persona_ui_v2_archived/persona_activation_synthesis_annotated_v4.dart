import 'persona_activation_synthesis_v4.dart';

class PersonaActivationSynthesisAnnotatedV4 {
  const PersonaActivationSynthesisAnnotatedV4({
    required this.synthesis0,
    required this.annotation,
  });

  final Map<String, Object?> synthesis0;
  final String annotation;

  factory PersonaActivationSynthesisAnnotatedV4.fromSynthesisTier0(
    PersonaActivationSynthesisV4 base,
  ) {
    final data = base.asReadOnlyMap();
    final merged = data['merged'];
    final gate = data['gate'];
    final gateConsistency = data['gateConsistency'];
    final consistency = data['consistency'];
    final delta = data['delta'];
    final allPresent =
        merged != null &&
        gate != null &&
        gateConsistency != null &&
        consistency != null &&
        delta != null;
    final annotation = allPresent ? 'tier0_ok' : 'tier0_warn';
    return PersonaActivationSynthesisAnnotatedV4(
      synthesis0: data,
      annotation: annotation,
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    return {'synthesis0': synthesis0, 'annotation': annotation};
  }
}
