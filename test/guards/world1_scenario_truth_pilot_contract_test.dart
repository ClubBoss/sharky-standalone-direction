import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/campaign/world1_scenario_truth_pilot_v1.dart';

void main() {
  const pilotPackIds = <String>[
    'world1_spine_campaign_v1',
    'world1_spine_followup_v1_b0',
    'world1_spine_followup_v1_b1',
    'world1_spine_followup_v1_b2',
  ];

  test('world1 pilot families compile deterministic scenario truth', () {
    for (final packId in pilotPackIds) {
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: 'missing pack=$packId');
      final steps = pack12(pack!);
      var actionableCount = 0;
      for (var i = 0; i < steps.length; i++) {
        final step = steps[i];
        if ((step.allowedActions ?? const <String>[]).isEmpty) {
          continue;
        }
        actionableCount += 1;
        for (final family in World1ScenarioTruthFamilyV1.values) {
          final truth = world1ScenarioTruthPilotForStepV1(
            step: step,
            family: family,
          );
          expect(
            truth,
            isNotNull,
            reason: 'pack=$packId step=$i family=${family.name}',
          );
          expect(
            truth!.requiredFocusLabelV1.trim().isNotEmpty,
            isTrue,
            reason: 'pack=$packId step=$i family=${family.name} missing focus',
          );
          expect(
            truth.whyV1.startsWith('Why:'),
            isTrue,
            reason: 'pack=$packId step=$i family=${family.name} invalid why',
          );
          expect(
            truth.acceptableActionsV1.contains(''),
            isFalse,
            reason:
                'pack=$packId step=$i family=${family.name} has empty acceptable action',
          );
        }
      }
      expect(actionableCount, greaterThan(0), reason: 'pack=$packId');
    }
  });

  test('world1 pilot scenario-truth validator is clean for pilot packs', () {
    for (final packId in pilotPackIds) {
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: 'missing pack=$packId');
      final steps = pack12(pack!);
      for (var i = 0; i < steps.length; i++) {
        final step = steps[i];
        for (final family in World1ScenarioTruthFamilyV1.values) {
          final errors = validateWorld1ScenarioTruthPilotStepV1(
            packId: packId,
            stepIndex: i,
            step: step,
            family: family,
          );
          expect(
            errors,
            isEmpty,
            reason:
                'pack=$packId step=$i family=${family.name} validation errors=$errors',
          );
        }
      }
    }
  });
}
