import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('wrong answer creates deterministic mapped repair intent', () {
    final runner = _runnerForNoBetActionRead();
    final wrongOption = runner.options.firstWhere(
      (option) => !option.isCorrect,
    );

    final intent = buildAct0RepairIntentV1(
      sourceWorldId: 'world_1',
      sourceLessonId: 'fold_check_call_raise',
      sourceTaskId: 'actions_legal_context',
      runner: runner,
      selectedOption: wrongOption,
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
    );

    expect(intent, isNotNull);
    expect(intent?.schemaVersion, 1);
    expect(intent?.sourceTaskId, 'actions_legal_context');
    expect(intent?.choiceId, 'bet');
    expect(intent?.result, 'incorrect');
    expect(intent?.errorType, 'missed_action_read');
    expect(intent?.missedSignalId, 'no_bet_yet');
    expect(intent?.missedSignalLabel, 'No bet yet');
    expect(intent?.skillAtomId, 'action_read');
    expect(intent?.skillLabel, 'Action read');
    expect(intent?.targetWorldId, 'world_1');
    expect(intent?.targetLessonId, 'fold_check_call_raise');
    expect(intent?.targetTaskId, 'actions_check_drill');
    expect(intent?.mappingType, 'repair');
    expect(intent?.reasonCode, 'same_signal_action_read_no_bet_yet');
  });

  test('same input creates same target and reason code', () {
    final runner = _runnerForNoBetActionRead();
    final wrongOption = runner.options.firstWhere(
      (option) => !option.isCorrect,
    );

    final first = buildAct0RepairIntentV1(
      sourceWorldId: 'world_1',
      sourceLessonId: 'fold_check_call_raise',
      sourceTaskId: 'actions_legal_context',
      runner: runner,
      selectedOption: wrongOption,
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
    );
    final second = buildAct0RepairIntentV1(
      sourceWorldId: 'world_1',
      sourceLessonId: 'fold_check_call_raise',
      sourceTaskId: 'actions_legal_context',
      runner: runner,
      selectedOption: wrongOption,
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
    );

    expect(first?.targetTaskId, second?.targetTaskId);
    expect(first?.mappingType, second?.mappingType);
    expect(first?.reasonCode, second?.reasonCode);
    expect(first?.toPayload(), second?.toPayload());
  });

  test(
    'unavailable mapped target falls back to exact replay deterministically',
    () {
      final runner = _runnerForNoBetActionRead();
      final wrongOption = runner.options.firstWhere(
        (option) => !option.isCorrect,
      );

      final intent = buildAct0RepairIntentV1(
        sourceWorldId: 'world_1',
        sourceLessonId: 'fold_check_call_raise',
        sourceTaskId: 'actions_check_drill',
        runner: runner,
        selectedOption: wrongOption,
        mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
      );

      expect(intent, isNotNull);
      expect(intent?.targetWorldId, 'world_1');
      expect(intent?.targetLessonId, 'fold_check_call_raise');
      expect(intent?.targetTaskId, 'actions_check_drill');
      expect(intent?.mappingType, 'exact');
      expect(intent?.reasonCode, 'exact_replay_action_read_no_bet_yet');
    },
  );

  test('correct answer does not create open repair intent', () {
    final runner = _runnerForNoBetActionRead();
    final correctOption = runner.options.firstWhere(
      (option) => option.isCorrect,
    );

    final intent = buildAct0RepairIntentV1(
      sourceWorldId: 'world_1',
      sourceLessonId: 'fold_check_call_raise',
      sourceTaskId: 'actions_legal_context',
      runner: runner,
      selectedOption: correctOption,
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
    );

    expect(intent, isNull);
  });

  test('repair intent payload excludes forbidden AI and commerce fields', () {
    final runner = _runnerForNoBetActionRead();
    final wrongOption = runner.options.firstWhere(
      (option) => !option.isCorrect,
    );

    final intent = buildAct0RepairIntentV1(
      sourceWorldId: 'world_1',
      sourceLessonId: 'fold_check_call_raise',
      sourceTaskId: 'actions_legal_context',
      runner: runner,
      selectedOption: wrongOption,
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
    );

    final payload = intent!.toPayload();
    const forbiddenKeys = <String>{
      'ai',
      'ml',
      'adaptive',
      'solver',
      'gto',
      'commerce',
      'trial',
      'paywall',
      'premium',
      'price',
      'purchase',
      'restore',
      'premiumHub',
    };
    for (final key in forbiddenKeys) {
      expect(payload.containsKey(key), isFalse, reason: key);
    }
  });
}

Act0RunnerStateV1 _runnerForNoBetActionRead() {
  return Act0RunnerStateV1(
    lessonId: 'fold_check_call_raise',
    lessonTitle: 'Fold, check, call, raise',
    lessonSubtitle: 'Choose the legal action.',
    beatIndex: 0,
    beatCount: 1,
    phase: Act0LessonPhaseV1.drill,
    caption: 'No bet yet.',
    hint: 'Check is free when no bet faces you.',
    question: 'What can Hero do?',
    options: const <Act0RunnerOptionV1>[
      Act0RunnerOptionV1(
        id: 'check',
        label: 'Check',
        isCorrect: true,
        preferredLabel: 'Check',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'Correct.',
        feedbackReason: 'No bet faces Hero, so checking keeps the hand moving.',
        repairFocusLabels: <String>['No bet yet'],
      ),
      Act0RunnerOptionV1(
        id: 'bet',
        label: 'Bet',
        isCorrect: false,
        preferredLabel: 'Check',
        betterAnswerLabel: 'Check',
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: 'Not quite.',
        feedbackReason: 'No bet faces Hero yet. Check is the clean action.',
        repairFocusLabels: <String>['No bet yet'],
      ),
    ],
    feedbackTitle: 'Choose the legal action.',
    feedbackReason: 'No bet faces Hero.',
    primaryCtaLabel: 'Continue',
    nextLessonId: null,
    returnTarget: 'learn',
    table: const Act0TableStateV1(
      tableFormat: Act0TableFormatV1.sixMax,
      playerCount: 6,
      seats: <Act0SeatStateV1>[],
      heroCards: <Act0CardStateV1>[],
      boardCards: <Act0CardStateV1>[],
      streetLabel: 'Preflop',
      potLabel: '',
      toCallLabel: '',
      centerLabel: 'No bet yet',
      highlightedSeatIds: <String>[],
      highlightedCardIds: <String>[],
    ),
  );
}
