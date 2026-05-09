import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'phase3 canonical launcher targets the canonical terminal surface instead of the phase3 runner screen',
    () {
      final launcherSource = File(
        'lib/ui_v2/runner/canonical_launcher_api_v1.dart',
      ).readAsStringSync();
      final surfaceSource = File(
        'lib/ui_v2/runner/canonical_terminal_runner_surface_v1.dart',
      ).readAsStringSync();

      expect(
        launcherSource.contains('const CanonicalLauncherV1.phase3('),
        isTrue,
      );
      expect(
        launcherSource.contains(
          'CanonicalTerminalResolvedHostLaunchV1.phase3(',
        ),
        isTrue,
      );
      expect(launcherSource.contains('return Phase3RunnerScreen('), isFalse);
      expect(
        surfaceSource.contains('CanonicalTerminalPhase3RunnerV1('),
        isTrue,
      );
    },
  );

  test('phase3 terminal runner uses shared learner top-level shell path', () {
    final source = File(
      'lib/ui_v2/runner/canonical_terminal_phase3_runner_v1.dart',
    ).readAsStringSync();

    expect(source.contains('SharedLearnerCanonicalConsumerPathV1('), isTrue);
    expect(source.contains('SharedLearnerTopLevelShellContractV1('), isTrue);
    expect(source.contains('return Scaffold('), isFalse);
  });
}
