import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'canonical direct-session launch owners use the shared surfaced route helper',
    () {
      const launchOwners = <String>[
        'lib/services/training_session_launcher.dart',
        'lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart',
        'lib/ui_v2/screens/module_launcher_screen.dart',
        'lib/ui_v2/screens/session_result_screen.dart',
        'lib/ui_v2/screens/theory_session_screen.dart',
        'lib/ui_v2/screens/universal_intake_plan_screen.dart',
      ];

      for (final path in launchOwners) {
        final source = File(path).readAsStringSync();
        expect(
          source.contains('canonicalSessionDrillRouteV1('),
          isTrue,
          reason:
              '$path should launch direct sessions through the shared route helper.',
        );
        expect(
          source.contains('SessionDrillPlayerV1Screen.route('),
          isFalse,
          reason:
              '$path should not depend on the legacy screen-specific route wrapper.',
        );
      }
    },
  );
}
