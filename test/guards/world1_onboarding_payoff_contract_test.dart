import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/canonical/first_session_trust_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart';

void main() {
  test(
    'early World 1 payoff framing escalates capability across the first packs',
    () {
      expect(kWorld1CanonicalModuleOrder.take(4).toList(), <String>[
        'world1_act0_table_literacy',
        'world1_act0_action_literacy',
        'world1_act0_street_flow',
        'world1_spine_campaign_v1',
      ]);

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
    },
  );

  test(
    'canonical first session promise stays aligned with the first seat concept',
    () {
      final trustContract = resolveFirstSessionTrustPlanContractV1(
        'world1_act0_table_literacy',
      );

      expect(trustContract, isNotNull);
      expect(trustContract!.titleLine, 'Sharky Poker');
      expect(
        trustContract.productPromiseLine,
        'Table-first training so every later poker decision starts from the right seat.',
      );
      expect(
        resolveConceptFirstSeatSetupLineV1('btn'),
        'Sharky Poker starts here: Button marks the dealer seat.',
      );
    },
  );
}
