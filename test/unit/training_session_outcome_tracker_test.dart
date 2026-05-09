import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/screens/training_session_outcome_tracker.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:poker_analyzer/services/training_session_outcome.dart';
import 'package:poker_analyzer/ui/telemetry_test_harness.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';

void main() {
  late TelemetryTestHarness harness;

  setUp(() async {
    harness = TelemetryTestHarness();
    Telemetry.overrideLogHandler(harness.logEvent);
    SharedPreferences.setMockInitialValues({
      'settings_sound_enabled': true,
      'haptics_enabled': true,
    });
    await AppSettingsService.instance.load();
    UiHapticsV1.resetHandlers();
    UiSoundV1.resetHandler();
  });

  tearDown(() {
    Telemetry.overrideLogHandler(null);
    UiHapticsV1.resetHandlers();
    UiSoundV1.resetHandler();
  });

  testWidgets('session_abort logs and callback once', (
    WidgetTester tester,
  ) async {
    final reasons = <TrainingSessionEndReasonV1>[];
    final tracker = TrainingSessionOutcomeTracker(
      sessionId: 'session-abort',
      onSessionEnd: reasons.add,
    );
    final haptics = <UiHapticEventV1>[];
    UiHapticsV1.setHandler(UiHapticEventV1.error, () async {
      haptics.add(UiHapticEventV1.error);
    });
    final sounds = <UiSoundEventV1>[];
    UiSoundV1.overrideHandler(sounds.add);

    tracker.signalEnd(TrainingSessionEndReasonV1.aborted);
    await tester.pump();
    tracker.signalEnd(TrainingSessionEndReasonV1.completed);
    tracker.dispose();
    await tester.pump();

    expect(reasons, equals([TrainingSessionEndReasonV1.aborted]));
    expect(harness.eventsByName(TelemetryEvents.sessionAbort), hasLength(1));
    expect(harness.eventsByName(TelemetryEvents.sessionEnd), isEmpty);
    expect(haptics, equals([UiHapticEventV1.error]));
    expect(sounds, equals([UiSoundEventV1.error]));
  });

  testWidgets('session_end logs once after completion', (
    WidgetTester tester,
  ) async {
    final reasons = <TrainingSessionEndReasonV1>[];
    final tracker = TrainingSessionOutcomeTracker(
      sessionId: 'session-complete',
      onSessionEnd: reasons.add,
    );
    final haptics = <UiHapticEventV1>[];
    UiHapticsV1.setHandler(UiHapticEventV1.success, () async {
      haptics.add(UiHapticEventV1.success);
    });
    final sounds = <UiSoundEventV1>[];
    UiSoundV1.overrideHandler(sounds.add);

    tracker.signalEnd(TrainingSessionEndReasonV1.completed);
    await tester.pump();
    tracker.signalEnd(TrainingSessionEndReasonV1.completed);
    tracker.dispose();
    await tester.pump();
    tracker.dispose();

    expect(reasons, equals([TrainingSessionEndReasonV1.completed]));
    expect(harness.eventsByName(TelemetryEvents.sessionEnd), hasLength(1));
    expect(harness.eventsByName(TelemetryEvents.sessionAbort), isEmpty);
    expect(haptics, equals([UiHapticEventV1.success]));
    expect(sounds, equals([UiSoundEventV1.success]));
  });
}
