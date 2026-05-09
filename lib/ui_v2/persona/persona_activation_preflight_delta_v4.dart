import 'persona_activation_preflight_envelope_v4.dart';
import 'persona_activation_preflight_consistency_v4.dart';

class PersonaActivationPreflightDeltaV4 {
  const PersonaActivationPreflightDeltaV4({
    this.envelope,
    this.consistency,
    this.deltaSurface,
    this.deltaCohesion,
    this.deltaMesh,
    this.deltaActivation,
  });

  final PersonaActivationPreflightEnvelopeV4? envelope;
  final PersonaActivationPreflightConsistencyV4? consistency;
  final bool? deltaSurface;
  final bool? deltaCohesion;
  final bool? deltaMesh;
  final bool? deltaActivation;

  factory PersonaActivationPreflightDeltaV4.fromEnvelopeAndConsistency(
    PersonaActivationPreflightEnvelopeV4 envelope,
    PersonaActivationPreflightConsistencyV4 consistency,
  ) {
    return PersonaActivationPreflightDeltaV4(
      envelope: envelope,
      consistency: consistency,
      deltaSurface: consistency.isSurfaceConsistent,
      deltaCohesion: consistency.isCohesionConsistent,
      deltaMesh: consistency.isMeshConsistent,
      deltaActivation: consistency.isActivationConsistent,
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (envelope != null) map['envelope'] = envelope!.asReadOnlyMap();
    if (consistency != null) map['consistency'] = consistency!.asReadOnlyMap();
    if (deltaSurface != null) map['deltaSurface'] = deltaSurface;
    if (deltaCohesion != null) map['deltaCohesion'] = deltaCohesion;
    if (deltaMesh != null) map['deltaMesh'] = deltaMesh;
    if (deltaActivation != null) map['deltaActivation'] = deltaActivation;
    return map;
  }
}
