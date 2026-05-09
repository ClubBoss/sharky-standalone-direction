import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/decay_tag_retention_tracker_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores and retrieves theory review', () async {
    final tracker = DecayTagRetentionTrackerService();
    expect(await tracker.getLastTheoryReview('push'), isNull);
    await tracker.markTheoryReviewed('push');
    final ts = await tracker.getLastTheoryReview('push');
    expect(ts, isNotNull);
  });

  test('stores and retrieves booster completion', () async {
    final tracker = DecayTagRetentionTrackerService();
    expect(await tracker.getLastBoosterCompletion('call'), isNull);
    await tracker.markBoosterCompleted('call');
    final ts = await tracker.getLastBoosterCompletion('call');
    expect(ts, isNotNull);
  });

  test('returns most decayed tags', () async {
    final tracker = DecayTagRetentionTrackerService();
    final now = DateTime.now();
    await tracker.markBoosterCompleted(
      'a',
      time: now.subtract(Duration(days: 30)),
    );
    await tracker.markBoosterCompleted(
      'b',
      time: now.subtract(Duration(days: 10)),
    );
    final result = await tracker.getMostDecayedTags(2, now: now);
    expect(result.length, 2);
    expect(result.first.key, 'a');
    expect(result.first.value, greaterThan(result.last.value));
  });
}
