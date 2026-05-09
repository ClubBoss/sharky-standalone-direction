import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_runner_item_normalizer_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_host_grammar_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';

void main() {
  testWidgets(
    'drill runner uses host contract for prompt ids and legacy continuation labels',
    (tester) async {
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'First prompt',
          'options': <String>['A', 'B'],
          'answer_index': 0,
          'rationale': 'First explanation',
        },
        <String, dynamic>{
          'question': 'Second prompt',
          'options': <String>['C', 'D'],
          'answer_index': 0,
          'rationale': 'Second explanation',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DrillRunnerScreen(
            moduleId: 'legacy_alignment_v1',
            debugItemsOverrideV1: items,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_legacy_alignment_v1#drill1',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_header_title_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_text_v1')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey<String>('drill_option_0')));
      await tester.pumpAndSettle();
      expect(find.text('NEXT DRILL'), findsOneWidget);
      expect(
        find.byKey(const Key('drill_runner_quiz_completion_action_stack_v1')),
        findsOneWidget,
      );

      await tester.tap(find.text('NEXT DRILL'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_legacy_alignment_v1#drill2',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_header_title_v1')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey<String>('drill_option_0')));
      await tester.pumpAndSettle();
      expect(find.text('FINISH'), findsOneWidget);
      expect(
        find.byKey(const Key('drill_runner_quiz_completion_action_stack_v1')),
        findsOneWidget,
      );

      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();

      expect(find.byType(SessionResultScreen), findsOneWidget);
    },
  );

  testWidgets(
    'drill runner uses embedded host flag to switch shell and progress zones',
    (tester) async {
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Legacy prompt',
          'options': <String>['A', 'B'],
          'answer_index': 0,
          'rationale': 'Explanation',
        },
      ];

      Future<void> pumpForModule(String moduleId) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DrillRunnerScreen(
              moduleId: moduleId,
              debugItemsOverrideV1: items,
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpForModule('legacy_alignment_v1');
      expect(find.byKey(const Key('table_first_practice_shell')), findsNothing);
      expect(find.text('Progress 1/1'), findsOneWidget);
      expect(
        find.byKey(const Key('drill_runner_prompt_header_status_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_header_title_v1')),
        findsOneWidget,
      );

      await pumpForModule('world1_act0_table_literacy');
      expect(
        find.byKey(const Key('table_first_practice_shell')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('table_first_step_header')), findsOneWidget);
      expect(
        find.byKey(const Key('table_first_step_header_title_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('table_first_step_header_status_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(find.text('Progress 1/1'), findsNothing);
      expect(
        find.byKey(const Key('drill_runner_prompt_header_status_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_header_title_v1')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'drill runner uses completion contract for final reveal-answer finish label',
    (tester) async {
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Final reveal prompt',
          'explanation': 'Reveal explanation',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DrillRunnerScreen(
            moduleId: 'legacy_alignment_v1',
            debugItemsOverrideV1: items,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('REVEAL ANSWER'), findsOneWidget);
      await tester.tap(find.text('REVEAL ANSWER'));
      await tester.pumpAndSettle();

      expect(find.text('FINISH'), findsOneWidget);
      expect(find.text('Got it'), findsNothing);
      expect(
        find.byKey(const Key('drill_runner_reveal_completion_action_stack_v1')),
        findsOneWidget,
      );

      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();

      expect(find.byType(SessionResultScreen), findsOneWidget);
    },
  );

  testWidgets(
    'drill runner normalizes answer_choices quiz items through the contract path',
    (tester) async {
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Who acts last?',
          'answer_choices': <String>['Button', 'Big Blind'],
          'correct_answer': 'Button',
          'reaction_text': 'Button closes the action.',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DrillRunnerScreen(
            moduleId: 'legacy_alignment_v1',
            debugItemsOverrideV1: items,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('drill_option_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('drill_option_1')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey<String>('drill_option_0')));
      await tester.pumpAndSettle();

      expect(find.text('Button closes the action.'), findsOneWidget);
      expect(find.text('FINISH'), findsOneWidget);
    },
  );

  testWidgets(
    'drill runner uses normalized incorrect feedback through the contract path',
    (tester) async {
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Who keeps initiative?',
          'answer_choices': <String>['Hero', 'Villain'],
          'correct_answer': 'Hero',
          'why_v1': 'The last aggressor keeps initiative.',
          'feedback_correct_v1':
              'Correct. Hero raised last, so hero keeps initiative.',
          'feedback_incorrect_v1':
              'Incorrect. Villain did not make the last aggressive action.',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DrillRunnerScreen(
            moduleId: 'legacy_alignment_v1',
            debugItemsOverrideV1: items,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('drill_option_1')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Incorrect. Villain did not make the last aggressive action.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'drill runner exposes normalized prompt details through the contract path',
    (tester) async {
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Who has position here?',
          'instruction_text': 'Start by locating the button.',
          'goal_text': 'Explain who acts last after the flop.',
          'explanation': 'Position belongs to the button.',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DrillRunnerScreen(
            moduleId: 'legacy_alignment_v1',
            debugItemsOverrideV1: items,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Who has position here?'), findsOneWidget);
      expect(
        find.byKey(const Key('drill_runner_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_header_title_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_details_button_legacy_alignment_v1#drill1',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_support_lane_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_details_button_legacy_alignment_v1#drill1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_details_legacy_alignment_v1#drill1',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Instruction\nStart by locating the button.\n\nGoal\nExplain who acts last after the flop.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'drill runner exposes normalized source meta through the contract path',
    (tester) async {
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Tap Small Blind.',
          'street_context': 'preflop',
          'guided_scope': 'seats',
          'expected_action_kind': 'tap_seat',
          'spot_kind': 'l2_core_rules_check',
          'explanation': 'Small Blind anchor stabilizes orientation.',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DrillRunnerScreen(
            moduleId: 'legacy_alignment_v1',
            debugItemsOverrideV1: items,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('drill_runner_source_meta_block_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_support_lane_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('legacy_drill_runner_source_street_v1')),
        findsOneWidget,
      );
      expect(find.text('Street: PREFLOP'), findsOneWidget);
      expect(find.text('Scope: seats'), findsOneWidget);
      expect(find.text('Action Kind: tap_seat'), findsOneWidget);
      expect(find.text('Spot Kind: l2_core_rules_check'), findsOneWidget);
    },
  );

  testWidgets(
    'drill runner keeps the normalized legacy contract path coherent end to end',
    (tester) async {
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Who keeps initiative here?',
          'instruction_text':
              'Read the last aggressive action before choosing.',
          'goal_text': 'Choose the player who still has initiative.',
          'street_context': 'flop',
          'guided_scope': 'seats',
          'expected_action_kind': 'tap_seat',
          'spot_kind': 'l2_core_rules_check',
          'answer_choices': <String>['Hero', 'Villain'],
          'correct_answer': 'Hero',
          'why_v1': 'The last aggressor keeps initiative.',
          'feedback_correct_v1':
              'Correct. Hero raised last, so hero keeps initiative.',
          'feedback_incorrect_v1':
              'Incorrect. Villain did not make the last aggressive action.',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DrillRunnerScreen(
            moduleId: 'legacy_alignment_v1',
            debugItemsOverrideV1: items,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_legacy_alignment_v1#drill1',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_header_title_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_details_button_legacy_alignment_v1#drill1',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_source_meta_block_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_support_lane_v1')),
        findsOneWidget,
      );
      expect(find.text('Street: FLOP'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('drill_option_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('drill_option_1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_details_button_legacy_alignment_v1#drill1',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Instruction\nRead the last aggressive action before choosing.\n\nGoal\nChoose the player who still has initiative.',
        ),
        findsOneWidget,
      );

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('drill_option_1')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Incorrect. Villain did not make the last aggressive action.',
        ),
        findsOneWidget,
      );
      expect(find.text('FINISH'), findsOneWidget);
      expect(
        find.byKey(const Key('drill_runner_quiz_completion_action_stack_v1')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'drill runner factual legacy slice aligns with canonical seams without claiming shell adoption',
    (tester) async {
      final adoption = resolveSharedLearnerHostGrammarAdoptionV1(
        hostFamily: 'drillRunner',
        screenFamily: 'DrillRunnerScreen',
        itemType: 'legacy_factual_drill',
        modeFamily: 'factualLegacy',
      );
      expect(adoption, isNull);

      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Who keeps initiative here?',
          'instruction_text':
              'Read the last aggressive action before choosing.',
          'goal_text': 'Choose the player who still has initiative.',
          'street_context': 'flop',
          'guided_scope': 'seats',
          'expected_action_kind': 'tap_seat',
          'spot_kind': 'l2_core_rules_check',
          'answer_choices': <String>['Hero', 'Villain'],
          'correct_answer': 'Hero',
          'why_v1': 'The last aggressor keeps initiative.',
          'feedback_correct_v1':
              'Correct. Hero raised last, so hero keeps initiative.',
          'feedback_incorrect_v1':
              'Incorrect. Villain did not make the last aggressive action.',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DrillRunnerScreen(
            moduleId: 'legacy_alignment_v1',
            debugItemsOverrideV1: items,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_legacy_alignment_v1#drill1',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_header_title_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_details_button_legacy_alignment_v1#drill1',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('drill_runner_source_meta_block_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'drill_runner_prompt_details_button_legacy_alignment_v1#drill1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Instruction\nRead the last aggressive action before choosing.\n\nGoal\nChoose the player who still has initiative.',
        ),
        findsOneWidget,
      );
      expect(find.text('Street: FLOP'), findsOneWidget);
      expect(find.text('Scope: seats'), findsOneWidget);
      expect(find.text('Action Kind: tap_seat'), findsOneWidget);
      expect(find.text('Spot Kind: l2_core_rules_check'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('drill_option_0')));
      await tester.pumpAndSettle();

      expect(
        find.text('Correct. Hero raised last, so hero keeps initiative.'),
        findsOneWidget,
      );
      expect(find.text('FINISH'), findsOneWidget);
      expect(
        find.byKey(const Key('drill_runner_quiz_completion_action_stack_v1')),
        findsOneWidget,
      );
    },
  );

  test(
    'drill runner consumes explicit authored factual family through the canonical runtime path',
    () async {
      final textureContent = await File(
        'content/core_board_textures/v1/drills.jsonl',
      ).readAsString();
      final textureAuthoredLines = textureContent
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(16)
          .toList(growable: false);
      expect(textureAuthoredLines, hasLength(16));

      for (var index = 0; index < textureAuthoredLines.length; index++) {
        final line = textureAuthoredLines[index];
        expect(line, contains('"factual_family_v1":"texture"'));
        final rawItem = jsonDecode(line) as Map<String, dynamic>;
        final item = normalizeLegacyDrillRunnerItemV1(rawItem);
        final presentation = resolveRunnerHostPromptRevealPresentationV1(
          RunnerHostPromptRevealPresentationInputV1(
            sourceId: 'core_board_textures#drill${index + 1}',
            canonicalPrompt: item.prompt,
            shortPromptOverride: item.prompt,
          ),
        );
        final contract = buildLegacyDrillRunnerFactualHostContractV1(
          item: item,
          presentation: presentation,
          sections: const RunnerHostSectionResponsibilityV1(),
        );

        expect(contract, isNotNull);
        expect(contract!.family.name, 'texture');
        expect(contract.shortPrompt, item.prompt);
        expect(
          contract.sourceMetaEntries.map((entry) => entry.text).toList(),
          <String>[
            if ((rawItem['board_context_v1'] as String?)?.trim().isNotEmpty ??
                false)
              'Board: ${(rawItem['board_context_v1'] as String).trim()}',
            if ((rawItem['texture_tag_v1'] as String?)?.trim().isNotEmpty ??
                false)
              'Texture: ${(rawItem['texture_tag_v1'] as String).trim()}',
            'Spot Kind: ${(rawItem['spot_kind'] as String).trim()}',
          ],
        );
      }

      final outsContent = await File(
        'content/core_pot_odds_equity/v1/drills.jsonl',
      ).readAsString();
      final outsAuthoredLines = outsContent
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(16)
          .toList(growable: false);
      expect(outsAuthoredLines, hasLength(16));

      for (var index = 0; index < outsAuthoredLines.length; index++) {
        final line = outsAuthoredLines[index];
        expect(line, contains('"factual_family_v1":"outs"'));
        final rawItem = jsonDecode(line) as Map<String, dynamic>;
        final item = normalizeLegacyDrillRunnerItemV1(rawItem);
        final presentation = resolveRunnerHostPromptRevealPresentationV1(
          RunnerHostPromptRevealPresentationInputV1(
            sourceId: 'core_pot_odds_equity#drill${index + 1}',
            canonicalPrompt: item.prompt,
            shortPromptOverride: item.prompt,
          ),
        );
        final contract = buildLegacyDrillRunnerFactualHostContractV1(
          item: item,
          presentation: presentation,
          sections: const RunnerHostSectionResponsibilityV1(),
        );

        expect(contract, isNotNull);
        expect(contract!.family.name, 'outs');
        expect(contract.shortPrompt, item.prompt);
        expect(contract.sourceMetaEntries.map((entry) => entry.text).toList(), <
          String
        >[
          if ((rawItem['street_context'] as String?)?.trim().isNotEmpty ??
              false)
            'Street: ${(rawItem['street_context'] as String).trim().toUpperCase()}',
          if ((rawItem['outs_count_v1'] as String?)?.trim().isNotEmpty ?? false)
            'Outs: ${(rawItem['outs_count_v1'] as String).trim()}',
          'Spot Kind: l1_core_call_vs_price',
        ]);
      }

      final positionContent = await File(
        'content/core_positions_and_initiative/v1/drills.jsonl',
      ).readAsString();
      final positionAuthoredLines = positionContent
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(3)
          .toList(growable: false);
      expect(positionAuthoredLines, hasLength(3));

      for (var index = 0; index < positionAuthoredLines.length; index++) {
        final line = positionAuthoredLines[index];
        expect(line, contains('"factual_family_v1":"position"'));
        final rawItem = jsonDecode(line) as Map<String, dynamic>;
        final item = normalizeLegacyDrillRunnerItemV1(rawItem);
        final presentation = resolveRunnerHostPromptRevealPresentationV1(
          RunnerHostPromptRevealPresentationInputV1(
            sourceId: 'core_positions_and_initiative#drill${index + 1}',
            canonicalPrompt: item.prompt,
            shortPromptOverride: item.prompt,
          ),
        );
        final contract = buildLegacyDrillRunnerFactualHostContractV1(
          item: item,
          presentation: presentation,
          sections: const RunnerHostSectionResponsibilityV1(),
        );

        expect(contract, isNotNull);
        expect(contract!.family.name, 'position');
        expect(contract.shortPrompt, item.prompt);
        expect(contract.sourceMetaEntries.map((entry) => entry.text).toList(), <
          String
        >[
          if ((rawItem['format_context_v1'] as String?)?.trim().isNotEmpty ??
              false)
            'Format: ${(rawItem['format_context_v1'] as String).trim()}',
          if ((rawItem['hero_seat_v1'] as String?)?.trim().isNotEmpty ?? false)
            'Hero Seat: ${(rawItem['hero_seat_v1'] as String).trim()}',
          if ((rawItem['villain_seat_v1'] as String?)?.trim().isNotEmpty ??
              false)
            'Villain Seat: ${(rawItem['villain_seat_v1'] as String).trim()}',
        ]);
      }
    },
  );

  test(
    'drill runner factual host contract stays absent for legacy items without authored family truth',
    () {
      final item = normalizeLegacyDrillRunnerItemV1(<String, dynamic>{
        'question': 'Who acts last?',
        'answer_choices': <String>['Button', 'Big Blind'],
        'correct_answer': 'Button',
        'reaction_text': 'Button closes the action.',
      });
      final presentation = resolveRunnerHostPromptRevealPresentationV1(
        const RunnerHostPromptRevealPresentationInputV1(
          sourceId: 'legacy_alignment_v1#drill1',
          canonicalPrompt: 'Who acts last?',
          shortPromptOverride: 'Who acts last?',
        ),
      );
      final contract = buildLegacyDrillRunnerFactualHostContractV1(
        item: item,
        presentation: presentation,
        sections: const RunnerHostSectionResponsibilityV1(),
      );

      expect(contract, isNull);
    },
  );
}
