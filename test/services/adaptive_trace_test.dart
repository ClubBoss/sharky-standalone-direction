import 'package:test/test.dart';
import 'package:poker_analyzer/services/adaptive_progression_service.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';

void main() {
  test('duplicate session ID only emits telemetry once', () {
    final service = AdaptiveProgressionService.instance;
    service.clearForTest();
    final events = <String>[];
    service.setTelemetryOverride((name, _) => events.add(name));

    final piOne = service.recordSession(
      accuracy: 0.7,
      evDelta: 1.2,
      timeSpentSeconds: 10,
      sessionId: 'session-123',
    );
    final piTwo = service.recordSession(
      accuracy: 0.9,
      evDelta: 1.5,
      timeSpentSeconds: 15,
      sessionId: 'session-123',
    );

    expect(piOne, isNotNull);
    expect(piTwo, isNull);
    expect(service.history.length, 1);
    expect(
      events.where((name) => name == TelemetryEvents.adaptiveDifficultyUpdated),
      hasLength(1),
    );

    service.setTelemetryOverride(null);
    service.clearForTest();
  });
}
