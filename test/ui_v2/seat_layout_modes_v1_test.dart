import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  group('seat layout selector v1', () {
    test('returns 9 for tournament and cash tokens', () {
      expect(debugSeatLayoutRuleForPackIdV1('season_cash_demo_v1'), 9);
      expect(debugSeatLayoutRuleForPackIdV1('mtt_spot_pack_v1'), 9);
      expect(debugSeatLayoutRuleForPackIdV1('tournament_table_ladder_v1'), 9);
    });

    test('returns 10 for 10max token and prefers it over cash token', () {
      expect(debugSeatLayoutRuleForPackIdV1('cash_10max_demo_v1'), 10);
    });

    test('returns null for current world1-world3 spine pack ids', () {
      expect(
        debugSeatLayoutRuleForPackIdV1('world1_spine_campaign_v1'),
        isNull,
      );
      expect(
        debugSeatLayoutRuleForPackIdV1('world2_spine_followup_v1_b1'),
        isNull,
      );
      expect(
        debugSeatLayoutRuleForPackIdV1('world3_spine_campaign_v1'),
        isNull,
      );
    });
  });
}
