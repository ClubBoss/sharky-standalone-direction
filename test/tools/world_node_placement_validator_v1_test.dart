import 'package:flutter_test/flutter_test.dart';

import '../../tools/validate_training_content.dart' as validator;

void main() {
  test(
    'world/node placement validator blocks early range-thinking placement but allows World 6 range content',
    () {
      final earlyErrors = validator.validateWorldNodePlacementTextV1(
        filePath:
            'content/worlds/world4/v1/sessions/w4.s03/drills/d.bad_range.json',
        content:
            '{"id":"bad_range","intent_v1":"think_in_ranges","prompt":"Range-first proxy: choose action."}',
      );
      expect(earlyErrors, isNotEmpty);
      expect(
        earlyErrors.join('\n'),
        contains(
          'explicit range-thinking content must not be placed before World 6',
        ),
      );

      final laterErrors = validator.validateWorldNodePlacementTextV1(
        filePath:
            'content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_raise_range.json',
        content:
            '{"id":"choose_raise_range","intent_v1":"think_in_ranges","prompt":"Range-first proxy: choose the best action."}',
      );
      expect(laterErrors, isEmpty);
    },
  );

  test(
    'world/node placement validator blocks tournament pressure placement before World 8 but allows World 8 content',
    () {
      final earlyErrors = validator.validateWorldNodePlacementTextV1(
        filePath: 'content/worlds/world7/v1/sessions/w7.s02/notes.md',
        content:
            'Tournament pressure changes survival tradeoffs before ICM ladders become explicit.',
      );
      expect(earlyErrors, isNotEmpty);
      expect(
        earlyErrors.join('\n'),
        contains(
          'tournament pressure / ICM intuition must not be placed before World 8',
        ),
      );

      final laterErrors = validator.validateWorldNodePlacementTextV1(
        filePath: 'content/worlds/world8/v1/sessions/w8.s01/session.md',
        content:
            'Tournament pressure and ICM intuition now guide survival-aware action choices.',
      );
      expect(laterErrors, isEmpty);
    },
  );
}
