import 'package:poker_analyzer/training/lesson_module_ids.dart';

class WeakPatternReviewRoutingV1 {
  WeakPatternReviewRoutingV1._();

  static String resolveTargetEntryId({
    required String baseTargetEntryId,
    required String focusId,
    required String? dominantErrorType,
  }) {
    final baseTarget = baseTargetEntryId.trim();
    if (baseTarget.isEmpty) return baseTarget;
    final normalizedFocus = focusId.trim().toLowerCase();
    final normalizedError = (dominantErrorType ?? '').trim().toLowerCase();

    if (normalizedError == 'board_slot_confusion' ||
        normalizedFocus == 'board_texture') {
      return 'w2.s04';
    }
    if (normalizedError == 'action_selection' ||
        normalizedFocus == 'initiative') {
      return 'w2.s03';
    }
    if (normalizedFocus == 'action_order' &&
        (normalizedError == 'incorrect_seat' ||
            normalizedError == 'seat_role_confusion')) {
      return actionOrderBtnLastModuleId;
    }
    if (normalizedFocus == 'position' ||
        normalizedError.contains('position_thinking')) {
      return 'w2.s02';
    }
    if (normalizedFocus == 'starting_hands' || normalizedFocus == 'range') {
      return 'w3.s01';
    }
    return baseTarget;
  }
}
