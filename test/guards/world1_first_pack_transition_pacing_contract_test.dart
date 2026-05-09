import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart';

void main() {
  test(
    'first-pack transition pacing keeps pack 1 blocking but removes duplicate continuity overlays for packs 2 and 3',
    () {
      final tableLiteracy = resolveWorld1FirstPackTransitionPacingContractV1(
        'world1_act0_table_literacy',
      );
      final actionLiteracy = resolveWorld1FirstPackTransitionPacingContractV1(
        'world1_act0_action_literacy',
      );
      final streetFlow = resolveWorld1FirstPackTransitionPacingContractV1(
        'world1_act0_street_flow',
      );

      expect(tableLiteracy, isNotNull);
      expect(tableLiteracy!.usesBlockingIntroOverlay, isTrue);
      expect(
        tableLiteracy.embeddedPreludeCardKey,
        'concept_first_seat_prelude_card_v1',
      );

      expect(actionLiteracy, isNotNull);
      expect(actionLiteracy!.usesBlockingIntroOverlay, isFalse);
      expect(
        actionLiteracy.embeddedPreludeCardKey,
        'action_literacy_prelude_card_v1',
      );

      expect(streetFlow, isNotNull);
      expect(streetFlow!.usesBlockingIntroOverlay, isFalse);
      expect(
        streetFlow.embeddedPreludeCardKey,
        'street_flow_prelude_card_v1',
      );
    },
  );
}
