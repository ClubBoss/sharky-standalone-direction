import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _progressKey = 'act0_shell_progress_v1';
const _mixedTaskIds = <String>[
  'what_poker_is_table_read_transfer',
  'cards_ranks_suits_private_board',
  'actions_legal_context',
];

void main() {
  test(
    'cue-first fixture keeps distinct source-owned families and table contexts',
    () {
      expect(act0CueFirstMixedRetrievalEntriesV1, hasLength(3));
      expect(
        act0CueFirstMixedRetrievalEntriesV1
            .map((entry) => entry.conceptFamilyId)
            .toSet(),
        hasLength(3),
      );
      expect(
        act0CueFirstMixedRetrievalEntriesV1
            .map((entry) => entry.contextDimensions.join('|'))
            .toSet(),
        hasLength(3),
      );

      final world = Act0ShellStateV1.sample.worldById('world_1');
      Act0LessonTaskV1 sourceTask(Act0CueFirstMixedRetrievalEntryV1 entry) {
        final lesson = world.lessons.firstWhere(
          (lesson) => lesson.lessonId == entry.lessonId,
        );
        return lesson.taskList.firstWhere(
          (task) => task.taskId == entry.taskId,
        );
      }

      final sourceTasks = act0CueFirstMixedRetrievalEntriesV1
          .map(sourceTask)
          .toList(growable: false);
      expect(
        sourceTasks.every((task) => task.phase == Act0LessonPhaseV1.drill),
        isTrue,
      );
      expect(
        sourceTasks.every(
          (task) =>
              task.runner.options.where((option) => option.isCorrect).length ==
              1,
        ),
        isTrue,
      );
      expect(
        sourceTasks.every(
          (task) => task.runner.options.any((option) => !option.isCorrect),
        ),
        isTrue,
      );
      expect(sourceTasks[0].runner.caption, contains('two cards'));
      expect(sourceTasks[0].runner.caption, contains('pot is 6 BB'));
      expect(sourceTasks[1].runner.caption, contains('Private cards'));
      expect(
        sourceTasks[2].runner.caption,
        contains('whether a bet is facing you'),
      );
    },
  );

  Future<void> pumpPreview(
    WidgetTester tester, {
    required List<String> completedTaskIds,
    Act0TelemetrySinkV1? telemetrySink,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'intake_completed_v1': true,
      'act0_welcome_completed_v1': true,
      _progressKey: jsonEncode(<String, Object>{
        'schemaVersion': 17,
        'completedTaskIds': completedTaskIds,
        'skippedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'fold_check_call_raise',
        'selectedTaskId': 'actions_check_drill',
        'earnedXp': 0,
      }),
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          showPlacementOnStart: false,
          telemetrySink: telemetrySink,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();
  }

  Future<void> completeCurrentDecision(WidgetTester tester) async {
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    runner.onChooseOption(
      runner.runner.options.firstWhere((option) => option.isCorrect),
    );
    await tester.pumpAndSettle();
    tester
        .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
        .onContinueReview();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'cue-first mixed retrieval remains blocked until all route spots are complete',
    (tester) async {
      await pumpPreview(
        tester,
        completedTaskIds: _mixedTaskIds.take(2).toList(),
      );

      final group = find.byKey(
        const Key('act0_shell_practice_group_cue_first_mixed'),
      );
      expect(group, findsOneWidget);
      await tester.drag(
        find.byKey(const Key('act0_shell_play_screen')),
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();
      await tester.tap(group);
      await tester.pumpAndSettle();
      expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    },
  );

  testWidgets(
    'cue-first mixed retrieval runs three existing contexts without task-title cues',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await pumpPreview(
        tester,
        completedTaskIds: _mixedTaskIds,
        telemetrySink: sink,
      );

      final group = find.byKey(
        const Key('act0_shell_practice_group_cue_first_mixed'),
      );
      await tester.drag(
        find.byKey(const Key('act0_shell_play_screen')),
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();
      await tester.tap(group);
      await tester.pumpAndSettle();

      for (final taskId in _mixedTaskIds) {
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(runner.selectedTaskId, taskId);
        expect(runner.cueFirstRetrievalMode, isTrue);
        expect(find.text('Table check'), findsOneWidget);
        expect(find.text('Read the table'), findsNothing);
        expect(find.text('Private vs board'), findsNothing);
        expect(find.text('Legal actions'), findsNothing);
        expect(find.textContaining('Private cards belong'), findsNothing);
        expect(find.textContaining('Legal actions depend'), findsNothing);
        expect(find.textContaining('No bet means check'), findsNothing);
        await completeCurrentDecision(tester);
      }

      expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
      expect(find.text('Table check complete'), findsOneWidget);
      final completed = sink.events.singleWhere(
        (event) => event.name == 'practice_completed',
      );
      expect(completed.fields['practiceGroupId'], 'cue_first_mixed');
      expect(completed.fields['completedRepCount'], 3);
      expect(completed.fields['cleanRepCount'], 3);
    },
  );
}
