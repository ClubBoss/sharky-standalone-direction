import 'persona_activation_preflight_envelope_v4.dart';

class PersonaActivationPreflightConsistencyV4 {
  const PersonaActivationPreflightConsistencyV4({
    this.envelope,
    this.isSurfaceConsistent,
    this.isCohesionConsistent,
    this.isMeshConsistent,
    this.isActivationConsistent,
  });

  final PersonaActivationPreflightEnvelopeV4? envelope;
  final bool? isSurfaceConsistent;
  final bool? isCohesionConsistent;
  final bool? isMeshConsistent;
  final bool? isActivationConsistent;

  factory PersonaActivationPreflightConsistencyV4.fromEnvelope(
    PersonaActivationPreflightEnvelopeV4 envelope,
  ) {
    final diagConsistency = envelope.diagnosticConsistency;
    return PersonaActivationPreflightConsistencyV4(
      envelope: envelope,
      isSurfaceConsistent: diagConsistency?.isSurfaceConsistent,
      isCohesionConsistent: diagConsistency?.isCohesionConsistent,
      isMeshConsistent: diagConsistency?.isMeshConsistent,
      isActivationConsistent: diagConsistency?.isActivationConsistent,
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (envelope != null) map['envelope'] = envelope!.asReadOnlyMap();
    if (isSurfaceConsistent != null) {
      map['isSurfaceConsistent'] = isSurfaceConsistent;
    }
    if (isCohesionConsistent != null) {
      map['isCohesionConsistent'] = isCohesionConsistent;
    }
    if (isMeshConsistent != null) map['isMeshConsistent'] = isMeshConsistent;
    if (isActivationConsistent != null) {
      map['isActivationConsistent'] = isActivationConsistent;
    }
    return map;
  }
}
