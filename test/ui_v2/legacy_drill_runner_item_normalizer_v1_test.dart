import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/factual_runner_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_runner_item_normalizer_v1.dart';

void main() {
  test(
    'normalizer lifts answer_choices and correct_answer into quiz semantics',
    () {
      final item = normalizeLegacyDrillRunnerItemV1(<String, dynamic>{
        'question': 'Who acts last?',
        'answer_choices': <String>['Button', 'Big Blind'],
        'correct_answer': 'Button',
        'reaction_text': 'Button closes the action.',
      });

      expect(item.prompt, 'Who acts last?');
      expect(item.explanation, 'Button closes the action.');
      expect(item.options, const <String>['Button', 'Big Blind']);
      expect(item.correctOptionIndex, 0);
      expect(item.isQuiz, isTrue);
    },
  );

  test(
    'normalizer lifts instruction and goal fields into prompt detail semantics',
    () {
      final item = normalizeLegacyDrillRunnerItemV1(<String, dynamic>{
        'question': 'Who has position here?',
        'instruction_text': 'Start by locating the button.',
        'goal_text': 'Explain who acts last after the flop.',
        'explanation': 'Position belongs to the button.',
      });

      expect(item.prompt, 'Who has position here?');
      expect(
        item.detailsPrompt,
        'Instruction\nStart by locating the button.\n\nGoal\nExplain who acts last after the flop.',
      );
      expect(item.explanation, 'Position belongs to the button.');
      expect(item.isQuiz, isFalse);
    },
  );

  test(
    'normalizer lifts why and explicit feedback variants into legacy feedback semantics',
    () {
      final item = normalizeLegacyDrillRunnerItemV1(<String, dynamic>{
        'question': 'Which player has initiative?',
        'why_v1': 'The last aggressor keeps initiative.',
        'feedback_correct_v1': 'Correct. Hero keeps initiative here.',
        'feedback_incorrect_v1': 'Incorrect. Villain did not raise last.',
      });

      expect(item.prompt, 'Which player has initiative?');
      expect(item.explanation, 'The last aggressor keeps initiative.');
      expect(item.correctFeedback, 'Correct. Hero keeps initiative here.');
      expect(item.incorrectFeedback, 'Incorrect. Villain did not raise last.');
      expect(item.isQuiz, isFalse);
    },
  );

  test(
    'normalizer lifts explicit legacy source meta fields into source meta entries',
    () {
      final item = normalizeLegacyDrillRunnerItemV1(<String, dynamic>{
        'question': 'Tap Small Blind.',
        'street_context': 'preflop',
        'outs_count_v1': '9 clean',
        'board_context_v1': 'K72 rainbow',
        'texture_tag_v1': 'dry',
        'format_context_v1': 'heads-up postflop',
        'hero_seat_v1': 'Button',
        'villain_seat_v1': 'Cutoff',
        'guided_scope': 'seats',
        'expected_action_kind': 'tap_seat',
        'spot_kind': 'l2_core_rules_check',
      });

      expect(
        item.sourceMeta.entries.map((entry) => entry.text).toList(),
        const <String>[
          'Street: PREFLOP',
          'Outs: 9 clean',
          'Board: K72 rainbow',
          'Texture: dry',
          'Format: heads-up postflop',
          'Hero Seat: Button',
          'Villain Seat: Cutoff',
          'Scope: seats',
          'Action Kind: tap_seat',
          'Spot Kind: l2_core_rules_check',
        ],
      );
    },
  );

  test(
    'normalizer accepts explicit authored factual family truth when present',
    () {
      final item = normalizeLegacyDrillRunnerItemV1(<String, dynamic>{
        'question': 'Who has position here?',
        'factual_family_v1': 'position',
        'explanation': 'The button acts last postflop.',
      });

      expect(item.factualFamily, FactualRunnerHostFamilyV1.position);
      expect(item.prompt, 'Who has position here?');
      expect(item.explanation, 'The button acts last postflop.');
    },
  );

  test(
    'normalizer leaves factual family absent and behavior unchanged when field is missing',
    () {
      final item = normalizeLegacyDrillRunnerItemV1(<String, dynamic>{
        'question': 'Who acts last?',
        'answer_choices': <String>['Button', 'Big Blind'],
        'correct_answer': 'Button',
        'reaction_text': 'Button closes the action.',
      });

      expect(item.factualFamily, isNull);
      expect(item.prompt, 'Who acts last?');
      expect(item.explanation, 'Button closes the action.');
      expect(item.options, const <String>['Button', 'Big Blind']);
      expect(item.correctOptionIndex, 0);
      expect(item.isQuiz, isTrue);
    },
  );
}
