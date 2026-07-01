import 'package:poker_analyzer/campaign/w11_route_admission_contract_v1.dart';

const String kW11SourceRouteProofIdV1 = 'w11_source_route_proof_v1';

/// W11 route-backed proof descriptor.
///
/// This descriptor remains source-owned and preserves the lossless admission
/// beats used by the learner route. It does not imply W12, Volume I
/// completion, commercial readiness, or public learning-effect readiness.
class W11RouteBackedProofV1 {
  const W11RouteBackedProofV1({
    required this.routeId,
    required this.worldId,
    required this.sessionId,
    required this.beats,
    required this.learnerVisible,
    required this.w10HandoffEnabled,
  });

  final String routeId;
  final String worldId;
  final String sessionId;
  final List<W11RouteAdmissionBeatV1> beats;
  final bool learnerVisible;
  final bool w10HandoffEnabled;
}

W11RouteBackedProofV1 buildW11RouteBackedProofV1(
  Iterable<W11RouteAdmissionBeatV1> beats,
) {
  final materializedBeats = List<W11RouteAdmissionBeatV1>.unmodifiable(beats);
  return W11RouteBackedProofV1(
    routeId: kW11SourceRouteProofIdV1,
    worldId: 'world11',
    sessionId: 'w11.s01',
    beats: materializedBeats,
    learnerVisible: true,
    w10HandoffEnabled: true,
  );
}
