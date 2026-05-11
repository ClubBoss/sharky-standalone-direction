import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';

void main() {
  test(
    'showable World 1 spine labels stay coherent across the shared seam',
    () {
      final tablePayoff = resolveWorld1FoundationsEarlyEntryPayoffV1(
        'world1_act0_table_literacy',
      );
      final actionPayoff = resolveWorld1FoundationsEarlyEntryPayoffV1(
        'world1_act0_action_literacy',
      );
      final streetPayoff = resolveWorld1FoundationsEarlyEntryPayoffV1(
        'world1_act0_street_flow',
      );

      expect(tablePayoff, isNotNull);
      expect(actionPayoff, isNotNull);
      expect(streetPayoff, isNotNull);

      expect(tablePayoff!.nextUpHeadlineText, 'First action choices');
      expect(actionPayoff!.nextUpHeadlineText, 'Street flow reads');
      expect(streetPayoff!.nextUpHeadlineText, 'Campaign spine');
      expect(
        recommendedModuleTitleForId('world1_spine_campaign_v1'),
        'Campaign spine',
      );
      expect(
        recommendedModuleTitleForId('world1_spine_campaign_v1'),
        isNot('Campaign Spine v1'),
      );
    },
  );
}
