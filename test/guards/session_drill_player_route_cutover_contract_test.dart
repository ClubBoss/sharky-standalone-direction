import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'session drill player route enters through the canonical launcher API',
    () {
      final source = File(
        'lib/ui_v2/screens/session_drill_player_v1_screen.dart',
      ).readAsStringSync();

      expect(source.contains('return canonicalSessionDrillRouteV1('), isTrue);
      expect(source.contains('sessionId: sessionId,'), isTrue);
    },
  );
}
