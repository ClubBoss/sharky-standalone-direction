import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_signal_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';

class CanonicalLaunchBoundaryResolvedHostLaunchV1 {
  const CanonicalLaunchBoundaryResolvedHostLaunchV1({
    required this.sessionIdentity,
    required this.hostShellControllerV1,
    required this.terminalResolvedHostLaunchV1,
  });

  final String sessionIdentity;
  final CanonicalLaunchBoundaryShellControllerV1 hostShellControllerV1;
  final CanonicalTerminalResolvedHostLaunchV1 terminalResolvedHostLaunchV1;

  CanonicalTerminalFamilyV1 get family => terminalResolvedHostLaunchV1.family;
}
