import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/why_v1_ssot_v1.dart';

void main() {
  test(
    'graded feedback policy rejects generic acceptable and incorrect copy across landed corridors',
    () {
      final repoRoot = Directory.current.path;
      const gradedCorridorFiles = <String>[
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_call_facing_open_price_ok.json',
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_call_facing_turn_bet.json',
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_raise_facing_open_isolation.json',
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_raise_facing_turn_pressure.json',
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_raise_flop_sequence_start.json',
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_raise_turn_sequence_continue.json',
        'content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_raise_river_sequence_value.json',
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_call_bridge_tocall_price_ok.json',
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_raise_bridge_pressure_counter.json',
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_raise_bridge_value.json',
      ];

      for (final relativePath in gradedCorridorFiles) {
        final file = File('$repoRoot/$relativePath');
        final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        final feedbackCorrect = (json['feedback_correct_v1'] as String?)?.trim();
        final feedbackIncorrect =
            (json['feedback_incorrect_v1'] as String?)?.trim();
        final feedbackAcceptable =
            (json['feedback_acceptable_v1'] as String?)?.trim();

        expect(
          feedbackCorrect,
          isNotNull,
          reason: '$relativePath should keep feedback_correct_v1.',
        );
        expect(
          feedbackIncorrect,
          isNotNull,
          reason: '$relativePath should keep feedback_incorrect_v1.',
        );
        expect(
          feedbackAcceptable,
          isNotNull,
          reason: '$relativePath should keep authored feedback_acceptable_v1.',
        );
        expect(
          feedbackAcceptable,
          isNot(feedbackCorrect),
          reason: '$relativePath acceptable feedback should not mirror the positive path.',
        );
        expect(
          feedbackAcceptable,
          isNot(feedbackIncorrect),
          reason: '$relativePath acceptable feedback should not mirror the wrong-path correction.',
        );
        expect(
          hasGenericAcceptableFeedbackV1(feedbackAcceptable),
          isFalse,
          reason: '$relativePath acceptable feedback should stay scenario-first, not generic.',
        );
        expect(
          hasGenericIncorrectFeedbackV1(feedbackIncorrect),
          isFalse,
          reason: '$relativePath incorrect feedback should stay scenario-first, not generic.',
        );
      }
    },
  );
}
