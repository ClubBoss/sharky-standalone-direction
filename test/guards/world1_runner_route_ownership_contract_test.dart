import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'world1 runner route ownership lives in the canonical launcher API, not table-first navigation',
    () {
      final launcher = File(
        'lib/ui_v2/runner/canonical_launcher_api_v1.dart',
      ).readAsStringSync();
      final tableFirst = File(
        'lib/ui_v2/screens/table_first_navigation.dart',
      ).readAsStringSync();

      expect(
        launcher.contains('Route<T> canonicalWorld1RunnerRouteV1<T>('),
        isTrue,
      );
      expect(
        launcher.contains('Future<T?> pushCanonicalWorld1RunnerV1<T>('),
        isTrue,
      );
      expect(
        launcher.contains(
          'Future<T?> pushReplacementCanonicalWorld1RunnerV1<T, TO>(',
        ),
        isTrue,
      );
      expect(
        tableFirst.contains('return canonicalWorld1RunnerRouteV1<T>('),
        isTrue,
      );
      expect(
        tableFirst.contains('return pushCanonicalWorld1RunnerV1<T>('),
        isTrue,
      );
      expect(
        tableFirst.contains(
          'return pushReplacementCanonicalWorld1RunnerV1<T, TO>(',
        ),
        isTrue,
      );
      expect(
        tableFirst.contains(
          'builder: (_) => CanonicalLauncherV1.sessionDrill(',
        ),
        isFalse,
      );
      expect(tableFirst.contains('Navigator.of(context).push<T>('), isFalse);
      expect(
        tableFirst.contains('Navigator.of(context).pushReplacement<T, TO>('),
        isFalse,
      );
    },
  );
}
