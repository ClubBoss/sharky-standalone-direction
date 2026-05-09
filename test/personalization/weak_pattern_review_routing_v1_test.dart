import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/weak_pattern_review_routing_v1.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

void main() {
  test(
    'review routing upgrades explicit weak-patterns to specific targets',
    () {
      expect(
        WeakPatternReviewRoutingV1.resolveTargetEntryId(
          baseTargetEntryId: 'core_board_textures',
          focusId: 'board_texture',
          dominantErrorType: 'board_slot_confusion',
        ),
        'w2.s04',
      );
      expect(
        WeakPatternReviewRoutingV1.resolveTargetEntryId(
          baseTargetEntryId: 'core_positions_and_initiative',
          focusId: 'initiative',
          dominantErrorType: 'action_selection',
        ),
        'w2.s03',
      );
      expect(
        WeakPatternReviewRoutingV1.resolveTargetEntryId(
          baseTargetEntryId: 'core_positions_and_initiative',
          focusId: 'action_order',
          dominantErrorType: 'incorrect_seat',
        ),
        actionOrderBtnLastModuleId,
      );
      expect(
        WeakPatternReviewRoutingV1.resolveTargetEntryId(
          baseTargetEntryId: 'core_starting_hands',
          focusId: 'starting_hands',
          dominantErrorType: 'range_leak',
        ),
        'w3.s01',
      );
    },
  );

  test(
    'review routing preserves module fallback when signal is not precise',
    () {
      expect(
        WeakPatternReviewRoutingV1.resolveTargetEntryId(
          baseTargetEntryId: 'core_pot_odds_equity',
          focusId: 'pot_odds',
          dominantErrorType: 'pot_odds_error',
        ),
        'core_pot_odds_equity',
      );
      expect(
        WeakPatternReviewRoutingV1.resolveTargetEntryId(
          baseTargetEntryId: 'core_flop_fundamentals',
          focusId: 'flop',
          dominantErrorType: 'flop_decision_error',
        ),
        'core_flop_fundamentals',
      );
    },
  );
}
