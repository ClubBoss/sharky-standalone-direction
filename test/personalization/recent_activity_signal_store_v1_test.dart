import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_signal_store_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await RecentActivitySignalStoreV1.instance.clearForTesting();
  });

  test(
    'stores supported recent-activity signals and ignores unrelated events',
    () async {
      await RecentActivitySignalStoreV1.instance.appendSignal(
        name: 'user_choice',
        payload: const <String, Object?>{
          'module_id': 'world1_spine_campaign_v1',
          'mode': 'campaign_spine',
          'step_index': 0,
          'choice': 'btn',
        },
      );
      await RecentActivitySignalStoreV1.instance.appendSignal(
        name: 'session_end',
        payload: const <String, Object?>{
          'module_id': 'world1_spine_campaign_v1',
        },
      );
      await RecentActivitySignalStoreV1.instance.appendSignals(
        const <RecentTelemetrySignalV1>[
          RecentTelemetrySignalV1(
            name: 'correct',
            payload: <String, Object?>{
              'surface': 'universal_intake_plan',
              'step_index': 1,
              'correct': false,
              'error_type': 'incorrect_seat',
            },
          ),
        ],
      );

      final signals = await RecentActivitySignalStoreV1.instance.loadSignals();
      expect(signals, hasLength(2));
      expect(signals.first.name, 'user_choice');
      expect(signals.last.name, 'correct');
    },
  );
}
