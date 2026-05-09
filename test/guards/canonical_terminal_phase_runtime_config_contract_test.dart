import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'phase terminal families share one runtime-config seam at the terminal boundary',
    () {
      final hostContract = File(
        'lib/ui_v2/runner/canonical_terminal_host_contract_v1.dart',
      ).readAsStringSync();
      final launcher = File(
        'lib/ui_v2/runner/canonical_launcher_api_v1.dart',
      ).readAsStringSync();
      final surface = File(
        'lib/ui_v2/runner/canonical_terminal_runner_surface_v1.dart',
      ).readAsStringSync();

      expect(
        hostContract.contains('class CanonicalTerminalPhaseRuntimeConfigV1'),
        isTrue,
      );
      expect(
        hostContract.contains('class CanonicalTerminalPhasePayloadV1'),
        isTrue,
      );
      expect(
        hostContract.contains('Phase1CanonicalResolvedHostLaunchV1'),
        isFalse,
      );
      expect(
        hostContract.contains('Phase2CanonicalResolvedHostLaunchV1'),
        isFalse,
      );
      expect(
        hostContract.contains('Phase3CanonicalResolvedHostLaunchV1'),
        isFalse,
      );

      expect(
        launcher.contains(
          'runtimeConfigV1: CanonicalTerminalPhaseRuntimeConfigV1(',
        ),
        isTrue,
      );
      expect(
        surface.contains(
          'final payload = resolvedHostLaunchV1.phasePayloadV1;',
        ),
        isTrue,
      );
    },
  );
}
