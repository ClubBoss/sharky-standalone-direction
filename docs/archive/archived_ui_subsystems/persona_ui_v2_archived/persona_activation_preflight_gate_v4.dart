import 'persona_activation_preflight_aggregator_v4.dart';

class PersonaActivationPreflightGateV4 {
  const PersonaActivationPreflightGateV4({
    this.surfaceOk,
    this.cohesionOk,
    this.meshOk,
    this.activationOk,
  });

  final bool? surfaceOk;
  final bool? cohesionOk;
  final bool? meshOk;
  final bool? activationOk;

  factory PersonaActivationPreflightGateV4.fromAggregator(
    PersonaActivationPreflightAggregatorV4 aggregator,
  ) {
    return PersonaActivationPreflightGateV4(
      surfaceOk: aggregator.consistency?.isSurfaceConsistent,
      cohesionOk: aggregator.consistency?.isCohesionConsistent,
      meshOk: aggregator.consistency?.isMeshConsistent,
      activationOk: aggregator.consistency?.isActivationConsistent,
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (surfaceOk != null) map['surfaceOk'] = surfaceOk;
    if (cohesionOk != null) map['cohesionOk'] = cohesionOk;
    if (meshOk != null) map['meshOk'] = meshOk;
    if (activationOk != null) map['activationOk'] = activationOk;
    return map;
  }
}
