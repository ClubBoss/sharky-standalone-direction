import 'package:poker_analyzer/ui_v2/act0_shell/act0_price_personalization_ids_v1.dart';

const String act0PositionPersonalizationSequenceIdV1 =
    'w3_btn_position_read_v1';
const String act0PositionPersonalizationWorldIdV1 = 'world_3';
const String act0PositionPersonalizationLessonIdV1 = 'position_six_seats';
const String act0PositionPersonalizationSourceTaskIdV1 =
    'position_six_seats_positions_button';
const String act0PositionPersonalizationRepairTaskIdV1 =
    'position_six_seats_position_repair_seat_id_btn';
const String act0PositionPersonalizationErrorTypeV1 =
    'missed_table_position_read';
const String act0PositionPersonalizationSignalIdV1 = 'hero_button';
const String act0PositionPersonalizationSkillIdV1 = 'table_position_read';

String act0CanonicalErrorTypeForDecisionV1({
  required String result,
  required String skillAtomId,
  required String sourceTaskId,
}) {
  if (result == 'incorrect' &&
      sourceTaskId == act0PositionPersonalizationSourceTaskIdV1) {
    return act0PositionPersonalizationErrorTypeV1;
  }
  if (result == 'incorrect' &&
      sourceTaskId == act0PricePersonalizationSourceTaskIdV1 &&
      skillAtomId == act0PricePersonalizationSkillIdV1) {
    return act0PricePersonalizationErrorTypeV1;
  }
  return switch (result) {
    'incorrect' => 'missed_$skillAtomId',
    'suboptimal' => 'thin_$skillAtomId',
    _ => 'none',
  };
}
