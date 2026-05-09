import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'module theory host family ownership lives in the canonical runner host, not table-first navigation',
    () {
      final canonicalHost = File(
        'lib/ui_v2/runner/canonical_module_theory_host_v1.dart',
      ).readAsStringSync();
      final tableFirst = File(
        'lib/ui_v2/screens/table_first_navigation.dart',
      ).readAsStringSync();

      expect(
        canonicalHost.contains(
          'Widget buildCanonicalModuleTheoryHostScreenV1(',
        ),
        isTrue,
      );
      expect(
        canonicalHost.contains('Route<void> canonicalModuleTheoryHostRouteV1('),
        isTrue,
      );
      expect(
        canonicalHost.contains(
          'Future<void> pushReplacementCanonicalModuleTheoryHostV1(',
        ),
        isTrue,
      );
      expect(
        tableFirst.contains('return canonicalModuleTheoryHostRouteV1('),
        isTrue,
      );
      expect(
        tableFirst.contains(
          'await pushReplacementCanonicalModuleTheoryHostV1(',
        ),
        isTrue,
      );
      expect(
        tableFirst.contains(
          'DrillRuntimeAdapterV1().hasSessionDrills(moduleId)',
        ),
        isFalse,
      );
      expect(
        tableFirst.contains(
          'return TheorySessionScreen(moduleId: moduleId, moduleTitle: moduleTitle);',
        ),
        isFalse,
      );
    },
  );
}
