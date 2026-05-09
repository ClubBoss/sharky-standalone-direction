import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'theory practice launch is delegated to the canonical shared launcher boundary',
    () {
      final source = File(
        'lib/ui_v2/screens/theory_session_screen.dart',
      ).readAsStringSync();

      expect(source, contains('await pushCanonicalPracticeLaunchV1('));
      expect(
        source,
        isNot(contains('DrillRuntimeAdapterV1().hasSessionDrills(')),
      );
      expect(source, isNot(contains('LegacyDrillCanonicalHostAdapterV1(')));
      expect(source, isNot(contains('canonicalSessionDrillRouteV1(')));
      expect(source, isNot(contains('pushWorld1FoundationsRunnerV1<void>(')));
    },
  );
}
