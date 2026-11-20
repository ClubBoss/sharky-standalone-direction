import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
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
      currentFingerprintForIdentity:
          act0CurrentAuthoredSourceFingerprintForIdentityV1,
    );

    expect(intent, isNotNull);
    expect(intent?.schemaVersion, 1);
    expect(intent?.sourceTaskId, 'actions_legal_context');
    expect(intent?.choiceId, 'fold');
    expect(intent?.result, 'incorrect');
    expect(intent?.errorType, 'misread_action_legality');
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

  test(
    'mistaking shared cards opens the private and shared cards rehearsal',
    () {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .expand((lesson) => lesson.taskList)
          .firstWhere((task) => task.taskId == 'what_poker_is_find_hero');
      final wrongOption = task.runner.options.firstWhere(
        (option) => !option.isCorrect,
      );

      final intent = buildAct0RepairIntentV1(
        sourceWorldId: 'world_1',
        sourceLessonId: 'what_poker_is',
        sourceTaskId: task.taskId,
        runner: task.runner,
        selectedOption: wrongOption,
        mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      );

      expect(intent, isNotNull);
      expect(intent?.sourceTaskId, 'what_poker_is_find_hero');
      expect(intent?.choiceId, wrongOption.id);
      expect(intent?.missedSignalId, 'hero_button');
      expect(intent?.skillAtomId, 'table_position_read');
      expect(intent?.targetWorldId, 'world_1');
      expect(intent?.targetLessonId, 'what_poker_is');
      expect(intent?.targetTaskId, 'first_table_guide_shared_cards_repair');
      expect(intent?.goalId, 'shared_board_vs_private_cards');
      expect(intent?.mappingType, 'repair');
      expect(intent?.reasonCode, 'same_signal_table_position_read_hero_button');

      final unchangedCorrectRoute = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_table_position_read',
        skillAtomId: 'table_position_read',
        sourceSignalId: 'hero_button',
        sourceTaskId: task.taskId,
        receiptOutcome: 'learned',
      );
      expect(
        unchangedCorrectRoute?.taskId,
        'position_checkpoint_position_checkpoint_table_notice',
      );
    },
  );

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
      currentFingerprintForIdentity:
          act0CurrentAuthoredSourceFingerprintForIdentityV1,
    );
    final second = buildAct0RepairIntentV1(
      sourceWorldId: 'world_1',
      sourceLessonId: 'fold_check_call_raise',
      sourceTaskId: 'actions_legal_context',
      runner: runner,
      selectedOption: wrongOption,
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
      currentFingerprintForIdentity:
          act0CurrentAuthoredSourceFingerprintForIdentityV1,
    );

    expect(first?.targetTaskId, second?.targetTaskId);
    expect(first?.mappingType, second?.mappingType);
    expect(first?.reasonCode, second?.reasonCode);
    expect(first?.toPayload(), second?.toPayload());
  });

  test(
    'previous exact fallback now uses adjudicated alternate deterministically',
    () {
      final runner = _runnerForNoBetActionRead(taskId: 'actions_check_drill');
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
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      );

      expect(intent, isNotNull);
      expect(intent?.targetWorldId, 'world_1');
      expect(intent?.targetLessonId, 'fold_check_call_raise');
      expect(intent?.targetTaskId, 'actions_legal_context');
      expect(intent?.mappingType, 'repair');
      expect(intent?.reasonCode, 'same_signal_action_read_no_bet_yet');
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
      currentFingerprintForIdentity:
          act0CurrentAuthoredSourceFingerprintForIdentityV1,
    );

    expect(intent, isNull);
  });

  test(
    'new and legacy error identities round-trip without a schema change',
    () {
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
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      )!;

      expect(
        Act0RepairIntentV1.tryParse(intent.toPayload())?.errorType,
        'misread_action_legality',
      );
      final legacy = <String, Object>{
        ...intent.toPayload(),
        'errorType': 'missed_action_read',
      };
      expect(
        Act0RepairIntentV1.tryParse(legacy)?.errorType,
        'missed_action_read',
      );
      expect(Act0RepairIntentV1.tryParse(legacy)?.schemaVersion, 1);
    },
  );

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
      currentFingerprintForIdentity:
          act0CurrentAuthoredSourceFingerprintForIdentityV1,
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

Act0RunnerStateV1 _runnerForNoBetActionRead({
  String taskId = 'actions_legal_context',
}) => Act0ShellStateV1.sample
    .worldById('world_1')
    .lessons
    .singleWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
    .taskList
    .singleWhere((task) => task.taskId == taskId)
    .runner;
