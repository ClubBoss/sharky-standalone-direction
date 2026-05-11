import 'package:flutter_test/flutter_test.dart';

import '../../tools/validate_training_content.dart' as validator;

void main() {
  test(
    'progression anti-jump validator blocks early world2 pot-odds drift but allows later outs-then-price content',
    () {
      final earlyErrors = validator.validateProgressionAntiJumpTextV1(
        filePath: 'content/worlds/world2/v1/sessions/w2.s04/notes.md',
        content:
            'Compare pot odds before committing chips, even though outs counting is not established yet.',
      );
      expect(earlyErrors, isNotEmpty);
      expect(
        earlyErrors.join('\n'),
        contains(
          'must not introduce "pot odds" before the outs bridge is established',
        ),
      );

      final laterErrors = validator.validateProgressionAntiJumpTextV1(
        filePath: 'content/worlds/world2/v1/sessions/w2.s13/session.md',
        content:
            'After counting clean outs, compare that draw strength to the price of continuing.',
      );
      expect(laterErrors, isEmpty);
    },
  );
}
