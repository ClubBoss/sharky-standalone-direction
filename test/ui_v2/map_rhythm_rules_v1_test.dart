import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  group('decideNextActionV1', () {
    test('completed=3, queue=true -> Review required', () {
      final result = decideNextActionV1(
        completedPacksCount: 3,
        hasReviewQueueForNextPack: true,
      );
      expect(result.kind, MapNextActionKindV1.start_review_queue);
      expect(result.reason, 'Review required');
    });

    test('completed=6, queue=true -> Review required', () {
      final result = decideNextActionV1(
        completedPacksCount: 6,
        hasReviewQueueForNextPack: true,
      );
      expect(result.kind, MapNextActionKindV1.start_review_queue);
      expect(result.reason, 'Review required');
    });

    test('completed=2, queue=true -> Missed spots ready', () {
      final result = decideNextActionV1(
        completedPacksCount: 2,
        hasReviewQueueForNextPack: true,
      );
      expect(result.kind, MapNextActionKindV1.start_review_queue);
      expect(result.reason, 'Missed spots ready');
    });

    test('completed=0, queue=true -> Missed spots ready', () {
      final result = decideNextActionV1(
        completedPacksCount: 0,
        hasReviewQueueForNextPack: true,
      );
      expect(result.kind, MapNextActionKindV1.start_review_queue);
      expect(result.reason, 'Missed spots ready');
    });

    test('completed=3, queue=false -> Continue', () {
      final result = decideNextActionV1(
        completedPacksCount: 3,
        hasReviewQueueForNextPack: false,
      );
      expect(result.kind, MapNextActionKindV1.start_next_pack);
      expect(result.reason, 'Continue');
    });

    test('completed=5, queue=false -> Continue', () {
      final result = decideNextActionV1(
        completedPacksCount: 5,
        hasReviewQueueForNextPack: false,
      );
      expect(result.kind, MapNextActionKindV1.start_next_pack);
      expect(result.reason, 'Continue');
    });

    test('same inputs are deterministic', () {
      final a = decideNextActionV1(
        completedPacksCount: 3,
        hasReviewQueueForNextPack: true,
      );
      final b = decideNextActionV1(
        completedPacksCount: 3,
        hasReviewQueueForNextPack: true,
      );
      expect(a.kind, b.kind);
      expect(a.reason, b.reason);
    });
  });
}
