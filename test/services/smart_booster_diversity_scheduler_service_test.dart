import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/smart_booster_diversity_scheduler_service.dart';
import 'package:poker_analyzer/services/smart_pinned_block_booster_provider.dart';
import 'package:poker_analyzer/services/smart_booster_exclusion_tracker_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('prioritizes old or unseen boosters and logs filtered items', () async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    // Tag B shown yesterday
    await prefs.setInt(
      'booster_opened_b',
      now.subtract(Duration(days: 1)).millisecondsSinceEpoch,
    );
    // Tag A shown 10 days ago
    await prefs.setInt(
      'booster_opened_a',
      now.subtract(Duration(days: 10)).millisecondsSinceEpoch,
    );

    final scheduler = SmartBoosterDiversitySchedulerService();
    final suggestions = [
      PinnedBlockBoosterSuggestion(
        blockId: '1',
        blockTitle: 'b1',
        tag: 'a',
        action: 'reviewTheory',
      ),
      PinnedBlockBoosterSuggestion(
        blockId: '2',
        blockTitle: 'b2',
        tag: 'a',
        action: 'reviewTheory',
      ),
      PinnedBlockBoosterSuggestion(
        blockId: '3',
        blockTitle: 'b3',
        tag: 'b',
        action: 'reviewTheory',
      ),
    ];

    final scheduled = await scheduler.schedule(suggestions);
    expect(scheduled.map((s) => s.tag).toList(), ['a', 'b']);

    final log = await SmartBoosterExclusionTrackerService().exportLog();
    expect(log.length, 1);
    expect(log.first['tag'], 'a');
    expect(log.first['reason'], 'filteredByType');
  });
}
