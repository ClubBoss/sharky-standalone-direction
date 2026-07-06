import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';

void main() {
  test(
    'standalone world6 range-bucket drills preserve normalized bucket classification',
    () {
      final strongDrill = File(
        'content/worlds/world6/v1/sessions/w6.s01/drills/d.classify_strong_raise.json',
      ).readAsStringSync();
      final missedDrill = File(
        'content/worlds/world6/v1/sessions/w6.s01/drills/d.classify_missed_fold.json',
      ).readAsStringSync();
      final strongJson = jsonDecode(strongDrill) as Map<String, dynamic>;
      final missedJson = jsonDecode(missedDrill) as Map<String, dynamic>;

      expect(strongJson['kind'], 'range_bucket_board_fit_classifier_v1');
      expect(strongJson['expected_action'], 'strong');
      expect(missedJson['expected_action'], 'missed');
      expect(strongDrill, isNot(contains('"expected_action": "raise"')));
      expect(missedDrill, isNot(contains('"expected_action": "fold"')));

      final strongSpec = DrillSpecV1.fromJsonString(strongDrill);
      final missedSpec = DrillSpecV1.fromJsonString(missedDrill);
      expect(strongSpec.kind, DrillKindV1.actionChoice);
      expect(missedSpec.kind, DrillKindV1.actionChoice);
      expect(strongSpec.expected.actionId, 'strong');
      expect(missedSpec.expected.actionId, 'missed');
    },
  );
}
