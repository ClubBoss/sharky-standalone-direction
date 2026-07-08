import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w11_board_texture_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w12_review_decision_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w8_stack_depth_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart';

const _admittedW1W6FixturePaths = <String>[
  'test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_starting_hand_discipline_migration_batch1_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_seat_role_orientation_migration_pr2_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_card_board_orientation_migration_pr2_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_bet_size_vocabulary_preview_migration_pr3_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_checkpoint_synthesis_migration_pr3_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_showdown_basics_source_authorship_repair_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w2_canonical_certification_pilot_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w2_facing_price_discipline_canonical_pr2_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w2_approved_raise_discipline_canonical_pr3_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w3_canonical_certification_pilot_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w3_hand_bucket_action_frame_canonical_pr2_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w4_price_given_before_action_canonical_pilot_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w4_intent_action_discipline_canonical_pr2_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w5_board_texture_classification_canonical_pilot_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w5_board_shift_awareness_canonical_pr2_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w5_basic_outs_awareness_canonical_prerequisite_repair_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w6_range_bucket_by_board_fit_canonical_pilot_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w6_range_width_awareness_canonical_pr2_v1.json',
];

const _forbiddenClaimFragments = <String>[
  'gto',
  'solver-approved',
  'optimal',
  'profitable every time',
  'correct every time',
  'guaranteed improvement',
  'mastered',
  'fixed forever',
];

void main() {
  test('admitted W1-W6 fixtures preserve answer and feedback integrity', () {
    final worldCounts = <String, int>{};

    for (final path in _admittedW1W6FixturePaths) {
      final decoded = jsonDecode(File(path).readAsStringSync());
      expect(decoded, isA<Map<String, Object?>>(), reason: path);
      final tasks = ((decoded as Map<String, Object?>)['tasks']! as List)
          .cast<Map<String, Object?>>();
      expect(tasks, isNotEmpty, reason: path);

      for (final task in tasks) {
        final taskId = task['task_id']! as String;
        final context = '$path::$taskId';
        final worldId = task['world_id']! as String;
        worldCounts[worldId] = (worldCounts[worldId] ?? 0) + 1;

        final correctAction = (task['correct_action'] as String?)?.trim();
        final expectedChoice = (task['expected_choice'] as String?)?.trim();
        expect(
          correctAction?.isNotEmpty == true ||
              expectedChoice?.isNotEmpty == true,
          isTrue,
          reason: context,
        );
        expect((task['feedback_reason'] as String?)?.trim(), isNotEmpty);
        expect((task['repair_focus_id'] as String?)?.trim(), isNotEmpty);
        expect((task['concept_family_id'] as String?)?.trim(), isNotEmpty);

        final choices = task['choices'];
        if (choices is List && expectedChoice != null) {
          final choiceIds = choices
              .whereType<Map<String, Object?>>()
              .map((choice) => choice['id'])
              .whereType<String>()
              .toSet();
          expect(choiceIds, contains(expectedChoice), reason: context);
        }

        final sourceText = jsonEncode(task).toLowerCase();
        for (final forbidden in _forbiddenClaimFragments) {
          expect(sourceText, isNot(contains(forbidden)), reason: context);
        }
      }
    }

    expect(worldCounts['world_1'], 42);
    expect(worldCounts['world_2'], 20);
    expect(worldCounts['world_3'], 12);
    expect(worldCounts['world_4'], 12);
    expect(worldCounts['world_5'], 18);
    expect(worldCounts['world_6'], 12);
  });

  test('W5 outs classifications keep exact beginner-count truth', () {
    final decoded = jsonDecode(
      File(
        'test/fixtures/content_factory_mvp/'
        'w5_basic_outs_awareness_canonical_prerequisite_repair_v1.json',
      ).readAsStringSync(),
    );
    final tasks = ((decoded as Map<String, Object?>)['tasks']! as List)
        .cast<Map<String, Object?>>();

    final expectedBySurface = <Pattern, String>{
      RegExp('flush_draw'): 'nine_outs',
      RegExp('open_ended_straight_draw'): 'eight_outs',
      RegExp('gutshot'): 'four_outs',
    };

    for (final task in tasks) {
      final surface = task['transfer_surface_id']! as String;
      final expectedAction = expectedBySurface.entries
          .singleWhere((entry) => entry.key.allMatches(surface).isNotEmpty)
          .value;
      expect(task['correct_action'], expectedAction, reason: surface);
    }
  });

  test('W7-W12 route owner specs keep answer and explanation integrity', () {
    final specs = <dynamic>[
      ...act0W7VisibleAceHiddenTaskSpecsV1,
      ...act0W8StackDepthHiddenTaskSpecsV1,
      ...act0W9TournamentPressureHiddenTaskSpecsV1,
      ...act0W10BetPurposeHiddenTaskSpecsV1,
      ...act0W11BoardTextureHiddenTaskSpecsV1,
      ...act0W12ReviewDecisionHiddenTaskSpecsV1,
    ];

    expect(specs, hasLength(24));

    for (final dynamic spec in specs) {
      final taskId = spec.taskId as String;
      final expectedChoiceId = spec.expectedChoiceId as String;
      final choiceIds = (spec.choiceIds as List).cast<String>();
      final incorrectFeedback = (spec.incorrectFeedback as Map)
          .cast<String, String>();

      expect(choiceIds, contains(expectedChoiceId), reason: taskId);
      expect(spec.learnerPrompt as String, isNotEmpty, reason: taskId);
      expect(spec.feedbackReason as String, isNotEmpty, reason: taskId);
      expect(spec.boardContext as String, isNotEmpty, reason: taskId);
      expect(spec.practiceCtaAllowed, isFalse, reason: taskId);
      expect(
        spec.mapperNoTargetReason as String,
        contains('no_safe_practice_target'),
        reason: taskId,
      );
      for (final wrongChoiceId in choiceIds.where(
        (choiceId) => choiceId != expectedChoiceId,
      )) {
        expect(
          incorrectFeedback,
          contains(wrongChoiceId),
          reason: '$taskId::$wrongChoiceId',
        );
      }

      final sourceText = jsonEncode(spec.copySafetyPayload).toLowerCase();
      for (final forbidden in _forbiddenClaimFragments) {
        expect(sourceText, isNot(contains(forbidden)), reason: taskId);
      }
    }
  });

  test(
    'W9 tournament-pressure tasks stay classification-only, not hidden math',
    () {
      for (final spec in act0W9TournamentPressureHiddenTaskSpecsV1) {
        final copy = <String>[
          spec.boardContext,
          spec.learnerPrompt,
          spec.feedbackReason,
        ].join(' ').toLowerCase();
        expect(copy, contains('tournament'));
        expect(copy, contains('pressure'));
        expect(copy, isNot(contains('%')));
        expect(copy, isNot(contains('odds threshold')));
        expect(copy, isNot(contains('equity needed')));
        expect(copy, isNot(contains('call price')));
        expect(copy, isNot(contains('pot odds')));
      }
    },
  );

  test('W10 value and bluff tasks name target logic without solver claims', () {
    final copy = act0W10BetPurposeHiddenTaskSpecsV1
        .map(
          (spec) => <String>[
            spec.boardContext,
            spec.learnerPrompt,
            spec.feedbackReason,
          ].join(' '),
        )
        .join(' ')
        .toLowerCase();

    expect(copy, contains('worse hands'));
    expect(copy, contains('stronger hands'));
    expect(copy, isNot(contains('solver')));
    expect(copy, isNot(contains('gto')));
    expect(copy, isNot(contains('optimal')));
  });
}
