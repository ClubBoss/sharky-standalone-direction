import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'table first navigation prefers surfaced session drills before theory host fallback',
    () {
      final source = File(
        'lib/ui_v2/runner/canonical_module_theory_host_v1.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('DrillRuntimeAdapterV1().hasSessionDrills(moduleId)'),
      );
      expect(
        source,
        contains(
          'return CanonicalLauncherV1.sessionDrill(sessionId: moduleId);',
        ),
      );
      expect(
        source,
        contains(
          'return TheorySessionScreen(moduleId: moduleId, moduleTitle: moduleTitle);',
        ),
      );
    },
  );
}
