import 'persona_activation_preflight_gate_v4.dart';
import 'persona_activation_preflight_delta_v4.dart';

class PersonaActivationPreflightGateConsistencyV4 {
  const PersonaActivationPreflightGateConsistencyV4({
    this.surfaceConsistent,
    this.cohesionConsistent,
    this.meshConsistent,
    this.activationConsistent,
  });

  final bool? surfaceConsistent;
  final bool? cohesionConsistent;
  final bool? meshConsistent;
  final bool? activationConsistent;

  factory PersonaActivationPreflightGateConsistencyV4.fromGateAndDelta(
    PersonaActivationPreflightGateV4 gate,
    PersonaActivationPreflightDeltaV4 delta,
  ) {
    return PersonaActivationPreflightGateConsistencyV4(
      surfaceConsistent: gate.surfaceOk == delta.deltaSurface,
      cohesionConsistent: gate.cohesionOk == delta.deltaCohesion,
      meshConsistent: gate.meshOk == delta.deltaMesh,
      activationConsistent: gate.activationOk == delta.deltaActivation,
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (surfaceConsistent != null) {
      map['surfaceConsistent'] = surfaceConsistent;
    }
    if (cohesionConsistent != null) {
      map['cohesionConsistent'] = cohesionConsistent;
    }
    if (meshConsistent != null) map['meshConsistent'] = meshConsistent;
    if (activationConsistent != null) {
      map['activationConsistent'] = activationConsistent;
    }
    return map;
  }
}
