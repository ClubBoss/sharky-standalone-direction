import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_runner_surface_v1.dart';

class CanonicalLaunchBoundaryRunnerSurfaceV1 extends StatelessWidget {
  const CanonicalLaunchBoundaryRunnerSurfaceV1({
    super.key,
    required this.resolvedHostLaunchV1,
  });

  final CanonicalLaunchBoundaryResolvedHostLaunchV1 resolvedHostLaunchV1;

  @override
  Widget build(BuildContext context) {
    return CanonicalTerminalRunnerSurfaceV1(
      resolvedHostLaunchV1: resolvedHostLaunchV1.terminalResolvedHostLaunchV1,
    );
  }
}
