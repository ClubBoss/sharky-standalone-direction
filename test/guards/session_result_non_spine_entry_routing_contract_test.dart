import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'non-spine next-module result routing goes through canonical theory entry instead of summary hop',
    () {
      final source = File(
        'lib/ui_v2/screens/session_result_screen.dart',
      ).readAsStringSync();

      expect(source, contains('await navigateToTheorySession('));
      expect(
        source,
        isNot(
          contains(
            'builder: (_) => ModuleSummaryScreen(moduleData: moduleData)',
          ),
        ),
      );
    },
  );
}
