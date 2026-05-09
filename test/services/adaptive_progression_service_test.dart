import 'package:test/test.dart';
import 'package:poker_analyzer/services/adaptive_progression_service.dart';

void main() {
  test('recordSession stores computed performance index', () {
    final service = AdaptiveProgressionService.instance;
    service.clearForTest();
    const accuracy = 0.75;
    const evDelta = 1.5;
    const timeSpentSeconds = 12.0;

    final pi = service.recordSession(
      accuracy: accuracy,
      evDelta: evDelta,
      timeSpentSeconds: timeSpentSeconds,
      sessionId: 'test-session',
    );

    final expectedPi = (accuracy * evDelta) / timeSpentSeconds;
    expect(service.history.isNotEmpty, isTrue);
    expect(service.history.last, closeTo(expectedPi, 1e-6));
    expect(pi, closeTo(expectedPi, 1e-6));
    service.clearForTest();
  });
}
