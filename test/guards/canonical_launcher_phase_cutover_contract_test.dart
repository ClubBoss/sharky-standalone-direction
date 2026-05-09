import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('active phase launch sites target the canonical launcher API', () {
    final personalization = File(
      'lib/ui_v2/home/personalization_next_action_hint.dart',
    ).readAsStringSync();
    final home = File('lib/ui_v2/legacy/home_screen.dart').readAsStringSync();
    final launcher = File(
      'lib/ui_v2/runner/canonical_launcher_api_v1.dart',
    ).readAsStringSync();

    expect(launcher.contains('class CanonicalLauncherV1'), isTrue);
    expect(
      launcher.contains('CanonicalLaunchBoundaryRunnerSurfaceV1('),
      isTrue,
    );
    expect(
      personalization.contains('const CanonicalLauncherV1.phase1()'),
      isTrue,
    );
    expect(
      personalization.contains('const CanonicalLauncherV1.phase2()'),
      isTrue,
    );
    expect(
      personalization.contains('const CanonicalLauncherV1.phase3()'),
      isTrue,
    );
    expect(home.contains('const CanonicalLauncherV1.phase1()'), isTrue);
  });
}
