import 'package:test/test.dart';

import '../../lib/ui_v2/act0_shell/act0_learner_reflection_input_v1.dart';

void main() {
  test('missing and blank input is optional', () {
    expect(Act0LearnerReflectionInputV1.fromPayload(null), isNull);
    final input = Act0LearnerReflectionInputV1(mistakeReason: '  ');
    expect(input.isEmpty, isTrue);
    expect(input.toPayload(), isEmpty);
    expect(Act0LearnerReflectionInputV1.fromPayload(input.toPayload()), isNull);
  });

  test('confidence and reason can be saved independently', () {
    final confidence = Act0LearnerReflectionInputV1.fromPayload({
      'confidence': 'unsure',
      'mistakeReason': false,
    })!;
    expect(confidence.toPayload(), {'confidence': 'unsure'});
    final reason = Act0LearnerReflectionInputV1.fromPayload({
      'confidence': 'unknown',
      'mistakeReason': ' My read was too fast.  ',
    })!;
    expect(reason.toPayload(), {'mistakeReason': 'My read was too fast.'});
  });
}
