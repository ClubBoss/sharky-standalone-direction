import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_learning_sequence_v1.dart';

void main() {
  test(
    'Action sequence is explicit and keeps the truthful context relation',
    () {
      final sequence = act0ActionLearningSequenceForTaskV1('actions_theory');
      expect(sequence, same(act0ActionLearningSequenceV1));
      expect(sequence!.practiceTaskId, 'actions_check_drill');
      expect(sequence.repairTaskId, 'actions_check_drill');
      expect(sequence.recheckTaskId, 'actions_check_drill');
      expect(sequence.repairErrorType, 'misread_action_legality');
      expect(
        sequence.repairTargetForErrorType('misread_action_legality'),
        'actions_check_drill',
      );
      expect(sequence.repairTargetForErrorType('unknown'), isNull);
      expect(sequence.tableContextRelation, 'related_read');
      expect(sequence.geometryPolicyId, 'w1_action_sequence_compact_v1');
      expect(act0ActionLearningSequenceForTaskV1('actions_fold_drill'), isNull);
    },
  );
}
