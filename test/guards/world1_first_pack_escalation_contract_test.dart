import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart';

void main() {
  test(
    'first-pack authority framing climbs from table map to action choices to street flow without duplicating payoff chrome',
    () {
      final tableContract =
          resolveWorld1FoundationsRunnerProgressionChromeContractV1(
            moduleId: 'world1_act0_table_literacy',
            currentStepIndex: 0,
            totalSteps: 3,
          );
      final actionContract =
          resolveWorld1FoundationsRunnerProgressionChromeContractV1(
            moduleId: 'world1_act0_action_literacy',
            currentStepIndex: 0,
            totalSteps: 3,
          );
      final streetContract =
          resolveWorld1FoundationsRunnerProgressionChromeContractV1(
            moduleId: 'world1_act0_street_flow',
            currentStepIndex: 0,
            totalSteps: 3,
          );

      expect(tableContract, isNotNull);
      expect(actionContract, isNotNull);
      expect(streetContract, isNotNull);

      expect(
        tableContract!.statusText,
        'Table map · Pack 1 of 7 · Step 1 of 3',
      );
      expect(
        actionContract!.statusText,
        'First action choices · Pack 2 of 7 · Step 1 of 3',
      );
      expect(
        streetContract!.statusText,
        'Street flow reads · Pack 3 of 7 · Step 1 of 3',
      );

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

      expect(
        tableContract.statusText,
        isNot(contains(tablePayoff!.nextSessionProgressLabel)),
      );
      expect(
        tableContract.statusText,
        isNot(contains(tablePayoff.nextUpHeadlineText)),
      );
      expect(
        actionContract.statusText,
        isNot(contains(actionPayoff!.nextSessionProgressLabel)),
      );
      expect(
        actionContract.statusText,
        isNot(contains(actionPayoff.nextUpHeadlineText)),
      );
      expect(
        streetContract.statusText,
        isNot(contains(streetPayoff!.nextSessionProgressLabel)),
      );
      expect(
        streetContract.statusText,
        isNot(contains(streetPayoff.nextUpHeadlineText)),
      );
    },
  );
}
