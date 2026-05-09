import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'legacy drill canonical host adapter targets the canonical terminal surface with no DrillRunnerScreen dependency',
    () {
      final adapterSource = File(
        'lib/ui_v2/runner/legacy_drill_canonical_host_adapter_v1.dart',
      ).readAsStringSync();
      final surfaceSource = File(
        'lib/ui_v2/runner/canonical_terminal_runner_surface_v1.dart',
      ).readAsStringSync();

      expect(
        adapterSource.contains('CanonicalTerminalRunnerSurfaceV1('),
        isTrue,
      );
      expect(adapterSource.contains('.legacyDrill('), isTrue);
      expect(
        adapterSource.contains(
          'runtimeConfigV1: CanonicalTerminalLegacyDrillRuntimeConfigV1(',
        ),
        isTrue,
      );
      expect(adapterSource.contains('DrillRunnerScreen'), isFalse);
      expect(
        surfaceSource.contains('CanonicalTerminalLegacyDrillRunnerV1('),
        isTrue,
      );
      expect(
        surfaceSource.contains('runtimeConfigV1: payload.runtimeConfigV1'),
        isTrue,
      );
    },
  );

  test(
    'legacy drill terminal runner uses shared learner top-level shell path',
    () {
      final source = File(
        'lib/ui_v2/runner/canonical_terminal_legacy_drill_runner_v1.dart',
      ).readAsStringSync();

      expect(source.contains('SharedLearnerTopLevelShellV1('), isTrue);
      expect(source.contains('return Scaffold('), isFalse);
    },
  );
}
