import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  group('Wave 3 canonical same-world repair mapping', () {
    test('W2 hand-bucket misses map to W2 bucket drills, not W1 cards', () {
      final target = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_starting_hand_read',
        skillAtomId: 'starting_hand_read',
        sourceSignalId: 'hero_cards',
        sourceTaskId: 'hand_discipline_buckets_premium',
        receiptOutcome: 'repair_started',
      );

      expect(target?.worldId, 'world_2');
      expect(target?.lessonId, 'hand_discipline_buckets');
      expect(target?.taskId, 'hand_discipline_buckets_strong');
      expect(target?.mappingType, 'repair');
    });

    test('W4 purpose and price misses stay inside W4', () {
      final purposeTarget = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'hero_cards_board_pot',
        sourceTaskId: 'w4_value_purpose',
        receiptOutcome: 'repair_started',
      );
      final priceTarget = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_price_read',
        skillAtomId: 'price_read',
        sourceSignalId: 'pot_to_call',
        sourceTaskId: 'w4_good_price_call',
        receiptOutcome: 'needs_rep',
      );

      expect(purposeTarget?.worldId, 'world_4');
      expect(purposeTarget?.lessonId, 'why_bets_happen');
      expect(purposeTarget?.taskId, 'w4_bluff_purpose');
      expect(priceTarget?.worldId, 'world_4');
      expect(priceTarget?.lessonId, 'call_price');
      expect(priceTarget?.taskId, 'w4_bad_price_fold');
      expect(priceTarget?.mappingType, 'repair');
    });

    test('W5 texture misses map to W5 texture drills, not W1 board count', () {
      final target = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_board_read',
        skillAtomId: 'board_read',
        sourceSignalId: 'board_cards',
        sourceTaskId: 'board_texture_basics_w5_wet_board',
        receiptOutcome: 'repair_started',
      );

      expect(target?.worldId, 'world_5');
      expect(target?.lessonId, 'board_texture_basics');
      expect(target?.taskId, 'board_texture_basics_w5_dry_board');
      expect(target?.mappingType, 'repair');
    });

    test(
      'W5 connected-board misses use prefixed production task identities',
      () {
        final connectedBoards = Act0ShellStateV1.sample
            .worldById('world_5')
            .lessons
            .firstWhere((lesson) => lesson.lessonId == 'connected_boards');
        final taskIds = connectedBoards.taskList
            .map((task) => task.taskId)
            .toSet();
        const disconnected = 'connected_boards_w5_disconnected_board';
        const connected = 'connected_boards_w5_connected_board';

        expect(taskIds, containsAll(<String>{disconnected, connected}));
        expect(taskIds, isNot(contains('w5_disconnected_board')));
        expect(taskIds, isNot(contains('w5_connected_board')));

        final disconnectedTarget = act0FirstValueSameSignalRepMappingV1(
          nextRepId: 'repeat_board_read',
          skillAtomId: 'board_read',
          sourceSignalId: 'board_cards',
          sourceTaskId: disconnected,
          receiptOutcome: 'repair_started',
        );
        final connectedTarget = act0FirstValueSameSignalRepMappingV1(
          nextRepId: 'repeat_board_read',
          skillAtomId: 'board_read',
          sourceSignalId: 'board_cards',
          sourceTaskId: connected,
          receiptOutcome: 'repair_started',
        );

        expect(disconnectedTarget?.worldId, 'world_5');
        expect(disconnectedTarget?.lessonId, 'connected_boards');
        expect(disconnectedTarget?.taskId, connected);
        expect(disconnectedTarget?.mappingType, 'repair');
        expect(connectedTarget?.worldId, 'world_5');
        expect(connectedTarget?.lessonId, 'connected_boards');
        expect(connectedTarget?.taskId, disconnected);
        expect(connectedTarget?.mappingType, 'repair');
      },
    );

    test('W6 range-bucket and action misses map inside canonical W6', () {
      final bucketTarget = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'hero_cards_board_pot',
        sourceTaskId: 'w6_wrong_board',
        receiptOutcome: 'repair_started',
      );
      final actionTarget = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_action_read',
        skillAtomId: 'action_read',
        sourceSignalId: 'no_bet_yet',
        sourceTaskId: 'w6_value_range_action',
        receiptOutcome: 'repair_started',
      );

      expect(bucketTarget?.worldId, 'world_6');
      expect(bucketTarget?.lessonId, 'range_pressure_lines');
      expect(bucketTarget?.taskId, 'w6_wet_board_repair');
      expect(actionTarget?.worldId, 'world_6');
      expect(actionTarget?.lessonId, 'range_pressure_lines');
      expect(actionTarget?.taskId, 'w6_bluff_candidate');
    });

    test('unknown W4-W6 source still uses legacy generic fallback', () {
      final target = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_board_read',
        skillAtomId: 'board_read',
        sourceSignalId: 'board_cards',
        sourceTaskId: 'unknown_board_source',
        receiptOutcome: 'repair_started',
      );

      expect(target?.worldId, 'world_1');
      expect(target?.lessonId, 'cards_ranks_suits');
      expect(target?.taskId, 'cards_ranks_suits_board_count');
    });
  });

  group('Wave 3 canonical repair intents', () {
    test(
      'W2 intent preserves source task while targeting canonical W2 drill',
      () {
        final intent = _intentFor(
          sourceWorldId: 'world_2',
          sourceLessonId: 'hand_discipline_buckets',
          sourceTaskId: 'hand_discipline_buckets_premium',
          runner: _runnerForHeroCards(),
        );

        expect(intent?.sourceWorldId, 'world_2');
        expect(intent?.sourceTaskId, 'hand_discipline_buckets_premium');
        expect(intent?.missedSignalId, 'hero_cards');
        expect(intent?.skillAtomId, 'starting_hand_read');
        expect(intent?.targetWorldId, 'world_2');
        expect(intent?.targetTaskId, 'hand_discipline_buckets_strong');
        expect(intent?.reasonCode, 'same_signal_starting_hand_read_hero_cards');
      },
    );

    test(
      'W4 intent uses W4 price repair target and keeps source attribution',
      () {
        final intent = _intentFor(
          sourceWorldId: 'world_4',
          sourceLessonId: 'call_price',
          sourceTaskId: 'w4_good_price_call',
          runner: _runnerForPriceRead(),
        );

        expect(intent?.sourceWorldId, 'world_4');
        expect(intent?.sourceLessonId, 'call_price');
        expect(intent?.sourceTaskId, 'w4_good_price_call');
        expect(intent?.missedSignalId, 'pot_to_call');
        expect(intent?.skillAtomId, 'price_read');
        expect(intent?.targetWorldId, 'world_4');
        expect(intent?.targetLessonId, 'call_price');
        expect(intent?.targetTaskId, 'w4_bad_price_fold');
      },
    );

    test(
      'W5 intent uses W5 board repair target and keeps source attribution',
      () {
        final intent = _intentFor(
          sourceWorldId: 'world_5',
          sourceLessonId: 'board_texture_basics',
          sourceTaskId: 'board_texture_basics_w5_dry_board',
          runner: _runnerForBoardRead(),
        );

        expect(intent?.sourceWorldId, 'world_5');
        expect(intent?.sourceTaskId, 'board_texture_basics_w5_dry_board');
        expect(intent?.missedSignalId, 'board_cards');
        expect(intent?.skillAtomId, 'board_read');
        expect(intent?.targetWorldId, 'world_5');
        expect(intent?.targetLessonId, 'board_texture_basics');
        expect(intent?.targetTaskId, 'board_texture_basics_w5_wet_board');
      },
    );

    test(
      'W6 intent targets W6 repair drill without changing progression proof',
      () {
        final intent = _intentFor(
          sourceWorldId: 'world_6',
          sourceLessonId: 'range_board_fit',
          sourceTaskId: 'w6_wrong_board',
          runner: _runnerForTableRead(),
        );

        expect(intent?.sourceWorldId, 'world_6');
        expect(intent?.sourceLessonId, 'range_board_fit');
        expect(intent?.sourceTaskId, 'w6_wrong_board');
        expect(intent?.missedSignalId, 'hero_cards_board_pot');
        expect(intent?.skillAtomId, 'table_read');
        expect(intent?.targetWorldId, 'world_6');
        expect(intent?.targetLessonId, 'range_pressure_lines');
        expect(intent?.targetTaskId, 'w6_wet_board_repair');
        expect(intent?.mappingType, 'repair');
      },
    );
  });
}

Act0RepairIntentV1? _intentFor({
  required String sourceWorldId,
  required String sourceLessonId,
  required String sourceTaskId,
  required Act0RunnerStateV1 runner,
}) {
  final wrongOption = runner.options.firstWhere((option) => !option.isCorrect);
  return buildAct0RepairIntentV1(
    sourceWorldId: sourceWorldId,
    sourceLessonId: sourceLessonId,
    sourceTaskId: sourceTaskId,
    runner: runner,
    selectedOption: wrongOption,
    mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
  );
}

Act0RunnerStateV1 _runnerForHeroCards() {
  return _runnerWith(
    table: _baseTable().copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 's'),
        Act0CardStateV1(rank: 'K', suit: 'd'),
      ],
    ),
    wrongRepairFocusCardIds: const <String>['hero_0', 'hero_1'],
    wrongRepairFocusLabels: const <String>['Hero cards'],
  );
}

Act0RunnerStateV1 _runnerForPriceRead() {
  return _runnerWith(
    table: _baseTable().copyWith(
      potLabel: 'Pot 8 BB',
      toCallLabel: 'To call 1 BB',
    ),
    wrongRepairFocusLabels: const <String>['Pot / to call'],
  );
}

Act0RunnerStateV1 _runnerForBoardRead() {
  return _runnerWith(
    table: _baseTable().copyWith(
      boardCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 'c'),
        Act0CardStateV1(rank: '7', suit: 'd'),
        Act0CardStateV1(rank: '2', suit: 's'),
      ],
    ),
    wrongRepairFocusCardIds: const <String>['board_0', 'board_1', 'board_2'],
    wrongRepairFocusLabels: const <String>['Board cards'],
  );
}

Act0RunnerStateV1 _runnerForTableRead() {
  return _runnerWith(
    table: _baseTable().copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 's'),
        Act0CardStateV1(rank: 'Q', suit: 'd'),
      ],
      boardCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: '8', suit: 'h'),
        Act0CardStateV1(rank: '7', suit: 'h'),
        Act0CardStateV1(rank: '6', suit: 'c'),
      ],
      potLabel: 'Pot 6 BB',
    ),
    wrongRepairFocusCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
    wrongRepairFocusLabels: const <String>[
      'Hero cards',
      'Board cards',
      'Pot 6 BB',
    ],
  );
}

Act0RunnerStateV1 _runnerWith({
  required Act0TableStateV1 table,
  List<String> wrongRepairFocusCardIds = const <String>[],
  List<String> wrongRepairFocusLabels = const <String>[],
}) {
  return Act0RunnerStateV1(
    lessonId: 'wave3_contract',
    lessonTitle: 'Wave 3 contract',
    lessonSubtitle: 'Canonical repair coverage',
    beatIndex: 0,
    beatCount: 1,
    phase: Act0LessonPhaseV1.drill,
    caption: 'Read the spot.',
    hint: 'Use the active clue.',
    question: 'What is the best answer?',
    options: <Act0RunnerOptionV1>[
      const Act0RunnerOptionV1(
        id: 'correct',
        label: 'Correct',
        isCorrect: true,
        preferredLabel: 'Correct',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'Correct.',
        feedbackReason: 'The clue was read correctly.',
      ),
      Act0RunnerOptionV1(
        id: 'wrong',
        label: 'Wrong',
        isCorrect: false,
        preferredLabel: 'Correct',
        betterAnswerLabel: 'Correct',
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: 'Not quite.',
        feedbackReason: 'The active clue was missed.',
        repairFocusCardIds: wrongRepairFocusCardIds,
        repairFocusLabels: wrongRepairFocusLabels,
      ),
    ],
    feedbackTitle: 'Read the spot.',
    feedbackReason: 'Use the active clue.',
    primaryCtaLabel: 'Continue',
    nextLessonId: null,
    returnTarget: 'learn',
    table: table,
  );
}

Act0TableStateV1 _baseTable() {
  return const Act0TableStateV1(
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[],
    heroCards: <Act0CardStateV1>[],
    boardCards: <Act0CardStateV1>[],
    streetLabel: 'Flop',
    potLabel: '',
    toCallLabel: '',
    centerLabel: '',
    highlightedSeatIds: <String>[],
    highlightedCardIds: <String>[],
  );
}
