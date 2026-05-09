import 'package:flutter/foundation.dart';

class CanonicalLaunchBoundaryShellSignalV1 {
  const CanonicalLaunchBoundaryShellSignalV1({
    required this.generation,
    required this.sessionIdentity,
    required this.shouldResetOutcomeSurface,
  });

  final int generation;
  final String sessionIdentity;
  final bool shouldResetOutcomeSurface;
}

class CanonicalLaunchBoundaryShellControllerV1
    extends ValueNotifier<CanonicalLaunchBoundaryShellSignalV1> {
  CanonicalLaunchBoundaryShellControllerV1(super.value);
}

CanonicalLaunchBoundaryShellSignalV1
createCanonicalInitialLaunchBoundaryShellSignalV1({
  required String sessionIdentity,
}) {
  return CanonicalLaunchBoundaryShellSignalV1(
    generation: 0,
    sessionIdentity: sessionIdentity,
    shouldResetOutcomeSurface: false,
  );
}

CanonicalLaunchBoundaryShellSignalV1
createCanonicalResetLaunchBoundaryShellSignalV1({
  required CanonicalLaunchBoundaryShellSignalV1 current,
  required String sessionIdentity,
}) {
  return CanonicalLaunchBoundaryShellSignalV1(
    generation: current.generation + 1,
    sessionIdentity: sessionIdentity,
    shouldResetOutcomeSurface: true,
  );
}
