import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/recent_top_mistake_utility_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecentTopMistakeUtilityV1', () {
    test('derives recent top mistake bucket from existing error signals', () {
      final summary = RecentTopMistakeUtilityV1.deriveTopMistake(
        const <RecentTelemetrySignalV1>[
          RecentTelemetrySignalV1(
            name: 'correct',
            payload: <String, Object?>{
              'correct': false,
              'error_type': 'incorrect_seat',
            },
          ),
          RecentTelemetrySignalV1(
            name: 'correct',
            payload: <String, Object?>{
              'correct': false,
              'error_type': 'seat_role_confusion',
            },
          ),
          RecentTelemetrySignalV1(
            name: 'correct',
            payload: <String, Object?>{
              'correct': false,
              'error_type': 'wrong_action',
            },
          ),
        ],
      );

      expect(summary, isNotNull);
      expect(summary!.focusLabel, 'action_order');
      expect(summary.bucketLabel, 'Positions and Initiative');
      expect(summary.count, 2);
      expect(summary.dominantErrorType, 'seat_role_confusion');
    });

    test('merges recent buckets ahead of fallback review buckets', () {
      final merged = RecentTopMistakeUtilityV1.mergeTopBuckets(
        recentBuckets: const <MapEntry<String, int>>[
          MapEntry<String, int>('Positions and Initiative', 2),
        ],
        fallbackBuckets: const <MapEntry<String, int>>[
          MapEntry<String, int>('Timing', 3),
          MapEntry<String, int>('Logic', 1),
        ],
      );

      expect(merged, hasLength(2));
      expect(merged.first.key, 'Positions and Initiative');
      expect(merged.first.value, 2);
      expect(merged.last.key, 'Timing');
      expect(merged.last.value, 3);
    });
  });
}
