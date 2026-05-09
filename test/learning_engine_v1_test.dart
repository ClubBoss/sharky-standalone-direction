import 'package:test/test.dart';

import 'package:poker_analyzer/learning/learning_engine_v1.dart';

void main() {
  test('LearningEngineV1 returns deterministic telemetry', () {
    final engine = LearningEngineV1();
    final start = DateTime.utc(2025, 1, 1, 0, 0, 0);
    final end = start.add(const Duration(milliseconds: 150));

    engine.startAttempt(start);
    final telemetry = engine.submitChoice(
      userChoice: 'push',
      now: end,
      expectedBestAction: 'push',
      errorClass: 'wrong_action',
    );

    expect(telemetry.userChoice, 'push');
    expect(telemetry.isCorrect, isTrue);
    expect(telemetry.errorClass, 'wrong_action');
    expect(telemetry.timeToDecisionMs, 150);
  });

  test('LearningEngineV1 marks incorrect choices', () {
    final engine = LearningEngineV1();
    final start = DateTime.utc(2025, 1, 1, 0, 0, 0);
    final end = start.add(const Duration(milliseconds: 90));

    engine.startAttempt(start);
    final telemetry = engine.submitChoice(
      userChoice: 'fold',
      now: end,
      expectedBestAction: 'push',
      errorClass: 'wrong_action',
    );

    expect(telemetry.isCorrect, isFalse);
    expect(telemetry.timeToDecisionMs, 90);
    expect(telemetry.errorClass, 'wrong_action');
  });
}
