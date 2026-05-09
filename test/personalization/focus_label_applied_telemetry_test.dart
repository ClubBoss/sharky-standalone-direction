import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/personalization/personalization_adapter_v1.dart';

void main() {
  test('emits focus_label_applied once with deterministic payload', () async {
    final events = <Map<String, Object?>>[];
    final phase1ReportJson = <String, Object?>{
      'ok': false,
      'runs': [
        {
          'attempts': [
            {'result': 'incorrect', 'error_type': 'wrong_action'},
          ],
        },
      ],
    };

    final recommendation = recommendFromReports(
      phase1ReportJson: phase1ReportJson,
      logEvent: (name, payload) async {
        events.add({'name': name, 'payload': payload});
      },
    );

    expect(recommendation.reason, contains('focus_label=range'));
    expect(events, hasLength(1));
    expect(events.single['name'], TelemetryEvents.focusLabelApplied);
    final payload = events.single['payload'] as Map<String, dynamic>;
    expect(payload['source'], 'phase1');
    expect(payload['focus_label'], 'range');
    expect(payload['next_action'], 'repeat_phase1');
  });
}
