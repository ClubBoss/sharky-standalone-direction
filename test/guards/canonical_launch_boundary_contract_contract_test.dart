import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'canonical launch boundary contract defines session identity and shell lifecycle above terminal launch',
    () {
      final source = File(
        'lib/ui_v2/runner/canonical_launch_boundary_contract_v1.dart',
      ).readAsStringSync();
      final signalSource = File(
        'lib/ui_v2/runner/canonical_launch_boundary_signal_contract_v1.dart',
      ).readAsStringSync();

      expect(
        source.contains('class CanonicalLaunchBoundaryResolvedHostLaunchV1'),
        isTrue,
      );
      expect(source.contains('final String sessionIdentity;'), isTrue);
      expect(
        source.contains(
          'final CanonicalLaunchBoundaryShellControllerV1 hostShellControllerV1;',
        ),
        isTrue,
      );
      expect(
        source.contains(
          'final CanonicalTerminalResolvedHostLaunchV1 terminalResolvedHostLaunchV1;',
        ),
        isTrue,
      );
      expect(
        signalSource.contains('class CanonicalLaunchBoundaryShellSignalV1'),
        isTrue,
      );
      expect(
        signalSource.contains(
          'createCanonicalResetLaunchBoundaryShellSignalV1',
        ),
        isTrue,
      );
    },
  );
}
