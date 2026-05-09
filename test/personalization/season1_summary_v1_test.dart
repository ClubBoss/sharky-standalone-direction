import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/season1_summary_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'aggregates best mastery, stable top skills, and chips snapshot',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'world_mastery_v1::world1_spine_campaign_v1': 'bronze',
        'world_mastery_v1::world4_spine_campaign_v1': 'silver',
        'world_mastery_v1::world9_spine_campaign_v1': 'gold',
        'skill_tags_v1::world1_spine_campaign_v1':
            '["Seat order","Blinds","Ranges"]',
        'skill_tags_v1::world4_spine_campaign_v1':
            '["Blinds","Timing","Sizing"]',
        'skill_tags_v1::world10_spine_campaign_v1': '["ICM","Ranges"]',
        'chips_balance_v1': 11,
        'chips_earned_total_v1': 40,
        'chips_spent_total_v1': 29,
      });
      final prefs = await SharedPreferences.getInstance();

      final summary = computeSeason1SummaryFromPrefsV1(prefs: prefs);

      expect(summary.badge, SeasonBadgeV1.gold);
      expect(summary.topSkills, <String>[
        'Blinds',
        'ICM',
        'Ranges',
        'Seat order',
      ]);
      expect(summary.chipsBalance, 11);
      expect(summary.chipsEarnedTotal, 40);
      expect(summary.chipsSpentTotal, 29);
      expect(summary.line, 'Season 1 complete');
    },
  );

  test('returns progress state when no mastery exists', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'skill_tags_v1::world2_spine_campaign_v1': '["Seat order"]',
    });
    final prefs = await SharedPreferences.getInstance();

    final summary = computeSeason1SummaryFromPrefsV1(prefs: prefs);

    expect(summary.badge, SeasonBadgeV1.none);
    expect(summary.topSkills, <String>['Seat order']);
    expect(summary.chipsBalance, 0);
    expect(summary.chipsEarnedTotal, 0);
    expect(summary.chipsSpentTotal, 0);
    expect(summary.line, 'Season 1 progress');
  });
}
