import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'phase1 canonical launcher targets the canonical terminal surface instead of the phase1 runner screen',
    () {
      final launcherSource = File(
        'lib/ui_v2/runner/canonical_launcher_api_v1.dart',
      ).readAsStringSync();
      final surfaceSource = File(
        'lib/ui_v2/runner/canonical_terminal_runner_surface_v1.dart',
      ).readAsStringSync();

      expect(
        launcherSource.contains('const CanonicalLauncherV1.phase1('),
        isTrue,
      );
      expect(
        launcherSource.contains(
          'CanonicalTerminalResolvedHostLaunchV1.phase1(',
        ),
        isTrue,
      );
      expect(launcherSource.contains('return Phase1RunnerScreen('), isFalse);
      expect(
        surfaceSource.contains('CanonicalTerminalPhase1RunnerV1('),
        isTrue,
      );
    },
  );

  test('phase1 terminal runner uses shared learner top-level shell path', () {
    final source = File(
      'lib/ui_v2/runner/canonical_terminal_phase1_runner_v1.dart',
    ).readAsStringSync();

    expect(source.contains('SharedLearnerCanonicalConsumerPathV1('), isTrue);
    expect(source.contains('SharedLearnerTopLevelShellContractV1('), isTrue);
    expect(source.contains('return Scaffold('), isFalse);
  });
}
