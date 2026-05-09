import 'persona_activation_preflight_envelope_v4.dart';
import 'persona_activation_preflight_consistency_v4.dart';
import 'persona_activation_preflight_delta_v4.dart';

class PersonaActivationPreflightAggregatorV4 {
  const PersonaActivationPreflightAggregatorV4({
    this.envelope,
    this.consistency,
    this.delta,
  });

  final PersonaActivationPreflightEnvelopeV4? envelope;
  final PersonaActivationPreflightConsistencyV4? consistency;
  final PersonaActivationPreflightDeltaV4? delta;

  factory PersonaActivationPreflightAggregatorV4.fromComponents(
    PersonaActivationPreflightEnvelopeV4? envelope,
    PersonaActivationPreflightConsistencyV4? consistency,
    PersonaActivationPreflightDeltaV4? delta,
  ) {
    return PersonaActivationPreflightAggregatorV4(
      envelope: envelope,
      consistency: consistency,
      delta: delta,
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (envelope != null) map['envelope'] = envelope!.asReadOnlyMap();
    if (consistency != null) {
      map['consistency'] = consistency!.asReadOnlyMap();
    }
    if (delta != null) map['delta'] = delta!.asReadOnlyMap();
    return map;
  }
}
