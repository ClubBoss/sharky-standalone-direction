import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'canonical terminal runner surface dispatches the full session-drill cluster to a canonical runner-layer widget',
    () {
      final surfaceSource = File(
        'lib/ui_v2/runner/canonical_terminal_runner_surface_v1.dart',
      ).readAsStringSync();
      final runnerSource = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();

      expect(
        surfaceSource.contains(
          'CanonicalTerminalSessionDrillSurfacedRunnerV1(',
        ),
        isTrue,
      );
      expect(surfaceSource.contains('UnimplementedError'), isFalse);
      expect(
        runnerSource.contains(
          'class CanonicalTerminalSessionDrillSurfacedRunnerV1 extends StatefulWidget',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains('_buildWorld10TrackClusterSurfaceContractV1'),
        isTrue,
      );
      expect(
        runnerSource.contains('SharedLearnerTopLevelShellContractV1('),
        isTrue,
      );
      expect(runnerSource.contains('return Scaffold('), isFalse);
    },
  );
}
