import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('active session drill launch sites target the canonical launcher API', () {
    final launcher = File(
      'lib/ui_v2/runner/canonical_launcher_api_v1.dart',
    ).readAsStringSync();
    final sessionRoute = File(
      'lib/ui_v2/screens/session_drill_player_v1_screen.dart',
    ).readAsStringSync();
    final tableFirst = File(
      'lib/ui_v2/screens/table_first_navigation.dart',
    ).readAsStringSync();
    final surfacedRunner = File(
      'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
    ).readAsStringSync();

    expect(
      launcher.contains('const CanonicalLauncherV1.sessionDrill('),
      isTrue,
    );
    expect(launcher.contains('CanonicalLauncherFamilyV1.sessionDrill'), isTrue);
    expect(
      launcher.contains('Route<T> canonicalWorld1RunnerRouteV1<T>('),
      isTrue,
    );
    expect(
      sessionRoute.contains('return canonicalSessionDrillRouteV1('),
      isTrue,
    );
    expect(
      sessionRoute.contains(
        'return CanonicalTerminalSessionDrillSurfacedRunnerV1(',
      ),
      isTrue,
    );
    expect(
      tableFirst.contains('return canonicalWorld1RunnerRouteV1<T>('),
      isTrue,
    );
    expect(
      surfacedRunner.contains('CanonicalLauncherV1.sessionDrill('),
      isTrue,
    );
  });
}
