import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('action choice emits a completed-decision contract', (
    tester,
  ) async {
    final task = _task(
      'world_1',
      'fold_check_call_raise',
      'actions_raise_drill',
    );
    Act0CompletedDecisionV1? completed;

    await _pumpRunner(
      tester,
      runner: task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingSteps: const <Act0TeachingStepV1>[],
      ),
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: task.taskId,
      onCompletedDecision: (value) => completed = value,
    );

    final selected = task.runner.options.firstWhere(
      (option) => !option.isCorrect,
    );
    await tester.tap(find.byKey(Key('act0_shell_option_${selected.id}')));
    await tester.pump();

    expect(completed, isNotNull);
    expect(completed!.decisionKind, Act0CompletedDecisionKindV1.actionList);
    expect(completed!.selectedId, selected.id);
    expect(
      completed!.expectedId,
      task.runner.options.firstWhere((option) => option.isCorrect).id,
    );
    expect(completed!.isCorrect, isFalse);
    expect(completed!.resultKind, 'incorrect');
    expect(completed!.errorType, startsWith('missed_'));
    expect(completed!.skillAtomId, isNotEmpty);
    expect(completed!.repairFocusId, isNotEmpty);
    expect(completed!.decisionTimeBucket, isNot('unknown'));
    expect(completed!.attemptKey, contains('|actionList|${selected.id}|1'));
  });

  testWidgets(
    'seat choice resolves its option before emitting a completed-decision contract',
    (tester) async {
      final task = _task(
        'world_1',
        'blinds_action_order',
        'blinds_first_actor',
      );
      final runner = normalizeAct0SeatTapRunnerV1(
        task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
      );
      Act0CompletedDecisionV1? completed;

      await _pumpRunner(
        tester,
        runner: runner,
        worldId: 'world_1',
        lessonId: 'blinds_action_order',
        taskId: task.taskId,
        onCompletedDecision: (value) => completed = value,
      );

      final selected = runner.options.firstWhere(
        (option) => option.seatId != null,
      );
      await tester.tap(
        find.byKey(Key('act0_shell_seat_tap_${selected.seatId}')),
      );
      await tester.pump();

      expect(completed, isNotNull);
      expect(completed!.decisionKind, Act0CompletedDecisionKindV1.seat);
      expect(completed!.selectedId, selected.id);
      expect(completed!.decisionTimeBucket, isNot('unknown'));
      expect(completed!.resultKind, isNotEmpty);
      expect(completed!.skillAtomId, isNotEmpty);
      expect(completed!.missedSignalId, isNotEmpty);
    },
  );

  testWidgets(
    'sizing confirmation resolves its preset option before emitting a completed-decision contract',
    (tester) async {
      final task = _task('world_5', 'small_half_pot', 'w4_half_pot_bet');
      Act0CompletedDecisionV1? completed;
      var selectedPresetId = task.runner.options.first.id;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: Act0LessonPhaseV1.drill,
                teachingSteps: const <Act0TeachingStepV1>[],
                selectedPresetId: selectedPresetId,
                sizingConfig: Act0SizingConfigV1(
                  mode: Act0SizingUiModeV1.presetsOnly,
                  presets: task.runner.options
                      .map(
                        (option) => Act0SizingPresetV1(
                          id: option.id,
                          label: option.label,
                          potFraction: 0.5,
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              selectedWorldId: 'world_5',
              selectedLessonId: 'small_half_pot',
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onSelectSizingPreset: (preset) =>
                  setState(() => selectedPresetId = preset.id),
              onConfirmSizingPreset: () {},
              onCompletedDecision: (value) => completed = value,
              onContinueReview: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('act0_shell_sizing_confirm_cta')));
      await tester.pump();

      expect(completed, isNotNull);
      expect(completed!.decisionKind, Act0CompletedDecisionKindV1.sizing);
      expect(completed!.selectedId, selectedPresetId);
      expect(completed!.decisionTimeBucket, isNot('unknown'));
      expect(completed!.resultKind, isNotEmpty);
      expect(completed!.skillAtomId, isNotEmpty);
    },
  );
}

Future<void> _pumpRunner(
  WidgetTester tester, {
  required Act0RunnerStateV1 runner,
  required String worldId,
  required String lessonId,
  required String taskId,
  required ValueChanged<Act0CompletedDecisionV1> onCompletedDecision,
}) => tester.pumpWidget(
  MaterialApp(
    home: Act0LessonRunnerShellV1(
      runner: runner,
      selectedWorldId: worldId,
      selectedLessonId: lessonId,
      selectedTaskId: taskId,
      onBack: () {},
      onContinueTheory: () {},
      onChooseOption: (_) {},
      onChooseSeat: (_) {},
      onCompletedDecision: onCompletedDecision,
      onContinueReview: () {},
    ),
  ),
);

Act0LessonTaskV1 _task(String worldId, String lessonId, String taskId) =>
    Act0ShellStateV1.sample
        .worldById(worldId)
        .lessons
        .firstWhere((lesson) => lesson.lessonId == lessonId)
        .taskList
        .firstWhere((task) => task.taskId == taskId);
