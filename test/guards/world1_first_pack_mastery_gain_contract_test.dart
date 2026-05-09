import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart';

void main() {
  test(
    'first-pack completion copy expresses concrete competence gain without duplicating payoff or authority chrome',
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
        tableContract!.completionBodyText,
        'You can now find Button, small blind, and big blind without guessing.',
      );
      expect(
        actionContract!.completionBodyText,
        'You can now choose fold, call, and raise from the right seat without action order feeling random.',
      );
      expect(
        streetContract!.completionBodyText,
        'You can now keep the action-order anchor while reading flop, turn, and river changes.',
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

      expect(tableContract.completionBodyText, isNot(contains('Unlocked next:')));
      expect(
        actionContract.completionBodyText,
        isNot(contains('Unlocked next:')),
      );
      expect(
        streetContract.completionBodyText,
        isNot(contains('Unlocked next:')),
      );

      expect(
        tableContract.completionBodyText,
        isNot(contains(tablePayoff!.nextSessionProgressLabel)),
      );
      expect(
        tableContract.completionBodyText,
        isNot(contains(tablePayoff.nextUpHeadlineText)),
      );
      expect(
        tableContract.completionBodyText,
        isNot(contains(tableContract.statusText)),
      );

      expect(
        actionContract.completionBodyText,
        isNot(contains(actionPayoff!.nextSessionProgressLabel)),
      );
      expect(
        actionContract.completionBodyText,
        isNot(contains(actionPayoff.nextUpHeadlineText)),
      );
      expect(
        actionContract.completionBodyText,
        isNot(contains(actionContract.statusText)),
      );

      expect(
        streetContract.completionBodyText,
        isNot(contains(streetPayoff!.nextSessionProgressLabel)),
      );
      expect(
        streetContract.completionBodyText,
        isNot(contains(streetPayoff.nextUpHeadlineText)),
      );
      expect(
        streetContract.completionBodyText,
        isNot(contains(streetContract.statusText)),
      );
    },
  );
}
