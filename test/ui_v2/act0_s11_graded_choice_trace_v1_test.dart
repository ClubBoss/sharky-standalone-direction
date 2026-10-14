import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

void main() {
  for (final kind in Act0CompletedDecisionKindV1.values) {
    for (final correct in [true, false]) {
      testWidgets(
        '$kind ${correct ? "correct" : "wrong"}: one joined trace despite double submit',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 1800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final sizing = kind == Act0CompletedDecisionKindV1.sizing;
          final seat = kind == Act0CompletedDecisionKindV1.seat;
          final world = Act0ShellStateV1.sample.worldById(
            sizing ? 'world_4' : 'world_1',
          );
          final taskId = sizing
              ? 'w4_small_bet'
              : seat
              ? 'positions_button'
              : 'actions_legal_context';
          final lesson = world.lessons.firstWhere(
            (l) => l.taskList.any((t) => t.taskId == taskId),
          );
          final task = lesson.taskList.firstWhere((t) => t.taskId == taskId);
          final option = task.runner.options.firstWhere(
            (o) => o.isCorrect == correct && (!seat || o.seatId != null),
          );
          final sink = Act0InMemoryTelemetrySinkV1();
          final completed = <Act0CompletedDecisionV1>[];
          final runner = task.runner.copyWith(
            phase: Act0LessonPhaseV1.drill,
            teachingSteps: const [],
            selectedPresetId: sizing ? option.id : null,
            sizingConfig: sizing
                ? Act0SizingConfigV1(
                    mode: Act0SizingUiModeV1.presetsOnly,
                    showGuidance: false,
                    presets: task.runner.options
                        .map(
                          (o) => Act0SizingPresetV1(
                            id: o.id,
                            label: o.label,
                            potFraction: 0.5,
                          ),
                        )
                        .toList(),
                  )
                : const Act0SizingConfigV1.disabled(),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Act0LessonRunnerShellV1(
                  runner: runner,
                  selectedWorldId: world.worldId,
                  selectedLessonId: lesson.lessonId,
                  selectedTaskId: task.taskId,
                  selectedTaskFamily: task.resolvedTaskFamily,
                  telemetrySink: sink,
                  evidenceRunId: 's11-regression',
                  evidenceNextOrder: 7,
                  onBack: () {},
                  onContinueTheory: () {},
                  onChooseOption: (_) {},
                  onContinueReview: () {},
                  onChooseSeat: (_) {},
                  onSelectSizingPreset: (_) {},
                  onConfirmSizingPreset: () {},
                  onCompletedDecision: completed.add,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final target = find.byKey(
            Key(
              sizing
                  ? 'act0_shell_sizing_confirm_cta'
                  : seat
                  ? 'act0_shell_seat_tap_${option.seatId}'
                  : 'act0_shell_option_${option.id}',
            ),
          );
          await tester.ensureVisible(target);
          await tester.tap(target);
          await tester.tap(target);
          await tester.pumpAndSettle();
          expect(completed, hasLength(1));
          for (final name in ['user_choice', 'decision_made', 'task_result']) {
            final events = sink.events.where((e) => e.name == name).toList();
            expect(events, hasLength(1), reason: name);
            final fields = events.single.fields;
            expect(
              fields['attempt_id'],
              completed.single.attemptKey,
              reason: name,
            );
            expect(fields['chosen_action'], option.id);
            expect(fields['correct'], correct);
            if (name != 'task_result')
              expect(fields['assistance_kind'], 'none');
          }
        },
      );
    }
  }
}
