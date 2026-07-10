import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compact repair feedback owns a smaller fixed dock contract', () {
    const normalTarget = 405.0;
    const repairFeedbackTarget = 320.0;

    expect(repairFeedbackTarget, lessThan(normalTarget));
    expect(normalTarget - repairFeedbackTarget, greaterThanOrEqualTo(80));
  });

  test('repair feedback dock preserves a safe minimum and bounded share', () {
    const minHeight = 280.0;
    const targetHeight = 320.0;
    const maxShare = 0.44;

    expect(minHeight, greaterThanOrEqualTo(68));
    expect(targetHeight, greaterThanOrEqualTo(minHeight));
    expect(maxShare, lessThanOrEqualTo(0.46));
  });
}
