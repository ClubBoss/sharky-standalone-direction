import 'persona_activation_preflight_delta_v4.dart';
import 'persona_activation_preflight_consistency_v4.dart';
import 'persona_activation_preflight_envelope_v4.dart';

class PersonaActivationPreflightMergedV4 {
  const PersonaActivationPreflightMergedV4({
    this.envelope,
    this.consistency,
    this.delta,
  });

  final Map<String, Object?>? envelope;
  final Map<String, Object?>? consistency;
  final Map<String, Object?>? delta;

  factory PersonaActivationPreflightMergedV4.fromParts(
    PersonaActivationPreflightEnvelopeV4 envelope,
    PersonaActivationPreflightConsistencyV4 consistency,
    PersonaActivationPreflightDeltaV4 delta,
  ) {
    return PersonaActivationPreflightMergedV4(
      envelope: envelope.asReadOnlyMap(),
      consistency: consistency.asReadOnlyMap(),
      delta: delta.asReadOnlyMap(),
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (envelope != null) map['envelope'] = envelope;
    if (consistency != null) map['consistency'] = consistency;
    if (delta != null) map['delta'] = delta;
    return map;
  }
}
