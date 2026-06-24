import 'package:poker_analyzer/campaign/w11_route_admission_contract_v1.dart';

const String kW11SourceRouteProofIdV1 = 'w11_source_route_proof_v1';

/// Non-learner-visible W11 route-backed proof descriptor.
///
/// This descriptor is intentionally source-owned and separate from the legacy
/// campaign-pack registry. It gives W11 a stable route proof identity while
/// preserving the lossless admission beats for a later launch/runtime decision.
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
    learnerVisible: false,
    w10HandoffEnabled: false,
  );
}
