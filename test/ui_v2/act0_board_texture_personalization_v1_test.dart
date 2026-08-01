import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_board_texture_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';

void main() {
  test('W5 adapter admits only its exact board-texture tuple', () {
    final family = Act0BoardTexturePersonalizationV1.fromRepairIntent(
      _intent(),
    );
    expect(family, isNotNull);
    expect(family!.feedbackMappingId, 'w5_board_texture_feedback_v1');
    expect(family.repairStrategyId, 'compare_board_connection_v1');
    expect(family.recheckMappingId, 'same_board_texture_signal_v1');
    for (final altered in <Act0RepairIntentV1>[
      _intent(sourceTaskId: 'w5_wet_board'),
      _intent(targetTaskId: 'w5_dry_board'),
      _intent(errorType: 'misread_draw_outs'),
      _intent(skillAtomId: 'draw_read'),
      _intent(missedSignalId: 'draw_cards'),
      _intent(mappingType: 'exact'),
      _intent(reasonCode: 'same_signal_board_read_other'),
    ])
      expect(
        Act0BoardTexturePersonalizationV1.fromRepairIntent(altered),
        isNull,
      );
  });
}

Act0RepairIntentV1 _intent({
  String? sourceTaskId,
  String? targetTaskId,
  String? errorType,
  String? skillAtomId,
  String? missedSignalId,
  String? mappingType,
  String? reasonCode,
}) => Act0RepairIntentV1(
  sourceWorldId: 'world_5',
  sourceLessonId: 'board_texture_basics',
  sourceTaskId: sourceTaskId ?? 'w5_dry_board',
  choiceId: 'wet',
  result: 'incorrect',
  errorType: errorType ?? 'misread_board_texture',
  missedSignalId: missedSignalId ?? 'board_cards',
  missedSignalLabel: 'Board cards',
  skillAtomId: skillAtomId ?? 'board_read',
  skillLabel: 'Board read',
  targetWorldId: 'world_5',
  targetLessonId: 'board_texture_basics',
  targetTaskId: targetTaskId ?? 'w5_wet_board',
  mappingType: mappingType ?? 'repair',
  reasonCode: reasonCode ?? 'same_signal_board_read_board_cards',
);
