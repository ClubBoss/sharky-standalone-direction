import 'package:test/test.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

void main() {
  group('Telemetry Smoke', () {
    test('FirebaseLiteTelemetryService instance is available', () {
      final service = FirebaseLiteTelemetryService.instance;
      expect(service, isNotNull);
    });

    test('FirebaseLiteTelemetryService logEvent completes', () async {
      final service = FirebaseLiteTelemetryService.instance;
      await service.logEvent('test_smoke_event', params: {'key': 'value'});
      expect(true, true);
    });
  });
}
