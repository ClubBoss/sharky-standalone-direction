import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

void main() {
  const progressKey = 'act0_shell_progress_v1';
  const lessonId = 'fold_check_call_raise';

  Widget host() => const MaterialApp(
    home: Act0ShellPreviewScreenV1(
      showPlacementOnStart: false,
      initialTab: Act0ShellTabV1.play,
      tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
    ),
  );

  for (final mode in <String>[
    'quickHint',
    'theoryRecall',
    'repeatHint',
    'independent',
    'freshAfterOldHelp',
    'legacyUnknown',
  ]) {
    testWidgets('$mode -> durable restore -> truthful completion', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final world = Act0ShellStateV1.sample.worldById('world_1');
      final lesson = world.lessons.firstWhere((l) => l.lessonId == lessonId);
      final previouslyCompleted = <String>[
        for (final l in world.lessons.takeWhile((l) => l.lessonId != lessonId))
          for (final t in l.taskList) t.taskId,
        'actions_theory',
        'actions_legal_context',
      ];
      SharedPreferences.setMockInitialValues(<String, Object>{
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        progressKey: jsonEncode(<String, Object?>{
          'schemaVersion': 17,
          'completedTaskIds': previouslyCompleted,
          'skippedTaskIds': <String>[],
          'completedLessonIds': <String>[
            for (final l in world.lessons.takeWhile(
              (l) => l.lessonId != lessonId,
            ))
              l.lessonId,
          ],
          'selectedWorldId': 'world_1',
          'selectedLessonId': lessonId,
          'selectedTaskId': 'actions_check_drill',
          'earnedXp': 20,
          'learningEvidenceHistory': mode == 'freshAfterOldHelp'
              ? <Object>[
                  <String, Object?>{
                    'schemaVersion': 1,
                    'recordId': 'previous_run|1',
                    'createdOrder': 1,
                    'worldId': 'world_1',
                    'lessonId': lessonId,
                    'taskId': 'actions_check_drill',
                    'choiceId': 'check',
                    'expectedChoiceId': 'check',
                    'isCorrect': true,
                    'errorType': '',
                    'repairFocusId': '',
                    'skillAtomId': 'action_read',
                    'decisionTimeBucket': '3_to_10s',
                    'resultKind': 'correct',
                    'assistanceKind': 'quickHint',
                  },
                ]
              : <Object>[],
          if (mode != 'legacyUnknown') 'lessonRunEvidenceLessonId': lessonId,
          if (mode != 'legacyUnknown')
            'lessonRunEvidenceStartOrder': mode == 'freshAfterOldHelp' ? 1 : 0,
        }),
      });

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        'actions_check_drill',
      );
      for (
        var step = 0;
        step < 12 &&
            find
                .byKey(const Key('act0_shell_theory_recall_cta'))
                .evaluate()
                .isEmpty;
        step++
      ) {
        final next =
            find
                .byKey(const Key('act0_shell_theory_continue_cta'))
                .evaluate()
                .isNotEmpty
            ? find.byKey(const Key('act0_shell_theory_continue_cta'))
            : find.byKey(const Key('act0_shell_continue_cta'));
        expect(next, findsOneWidget);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
      expect(hint, findsOneWidget);
      if (mode != 'independent' && mode != 'freshAfterOldHelp') {
        for (
          var repeat = 0;
          repeat < (mode == 'repeatHint' ? 2 : 1);
          repeat++
        ) {
          await tester.ensureVisible(hint);
          await tester.tap(hint);
          await tester.pumpAndSettle();
          if (mode == 'theoryRecall') {
            final full = find.byKey(
              const Key('act0_shell_review_full_idea_cta'),
            );
            expect(full, findsOneWidget);
            await tester.tap(full);
            await tester.pumpAndSettle();
          }
          await tester.tap(
            find.byKey(const Key('act0_shell_theory_recall_close_cta')),
          );
          await tester.pumpAndSettle();
        }
      }
      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      final afterHint = jsonDecode(prefs.getString(progressKey)!) as Map;
      final evidence = afterHint['learningEvidenceHistory'] as List;
      if (mode != 'independent' && mode != 'freshAfterOldHelp') {
        final expectedKind = mode == 'theoryRecall'
            ? 'theoryRecall'
            : 'quickHint';
        expect(
          evidence.any(
            (record) =>
                (record as Map)['taskId'] == 'actions_check_drill' &&
                record['assistanceKind'] == expectedKind,
          ),
          isTrue,
        );
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      for (final taskId in <String>[
        'actions_fold_drill',
        'actions_call_drill',
        'actions_raise_drill',
        'actions_review',
      ]) {
        final current = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(current.selectedTaskId, taskId);
        final task = lesson.taskList.firstWhere((t) => t.taskId == taskId);
        final answer = task.runner.options.firstWhere((o) => o.isCorrect);
        final optionKey = Key('act0_shell_option_${answer.id}');
        final seatKey = Key('act0_shell_seat_tap_${answer.seatId}');
        final feedback = find.byKey(
          const Key('act0_shell_feedback_continue_cta'),
        );
        for (
          var step = 0;
          step < 12 &&
              find.byKey(optionKey).evaluate().isEmpty &&
              find.byKey(seatKey).evaluate().isEmpty &&
              feedback.evaluate().isEmpty;
          step++
        ) {
          final next =
              find
                  .byKey(const Key('act0_shell_theory_continue_cta'))
                  .evaluate()
                  .isNotEmpty
              ? find.byKey(const Key('act0_shell_theory_continue_cta'))
              : find.byKey(const Key('act0_shell_continue_cta'));
          expect(
            next,
            findsOneWidget,
            reason: 'task $taskId cannot reach a choice',
          );
          await tester.tap(next);
          await tester.pumpAndSettle();
        }
        if (find.byKey(seatKey).evaluate().isNotEmpty) {
          await tester.tap(find.byKey(seatKey));
          await tester.pumpAndSettle();
        } else if (find.byKey(optionKey).evaluate().isNotEmpty) {
          await tester.tap(find.byKey(optionKey));
          await tester.pumpAndSettle();
        }
        expect(
          feedback,
          findsOneWidget,
          reason: 'task $taskId missing feedback',
        );
        await tester.tap(feedback);
        await tester.pumpAndSettle();
      }
      expect(
        find.byKey(const Key('act0_shell_block_summary_accuracy')),
        findsOneWidget,
      );
      if (mode == 'independent' || mode == 'freshAfterOldHelp') {
        expect(find.textContaining('100% accuracy'), findsOneWidget);
        expect(find.textContaining('with help'), findsNothing);
      } else if (mode == 'legacyUnknown') {
        expect(find.text('Clean pass'), findsNothing);
        expect(find.textContaining('help history unverified'), findsOneWidget);
        expect(find.textContaining('100% accuracy'), findsNothing);
      } else {
        expect(find.text('Clean pass'), findsNothing);
        expect(find.textContaining('1 with help'), findsOneWidget);
        expect(find.textContaining('100% accuracy'), findsNothing);
      }
    });
  }
}
