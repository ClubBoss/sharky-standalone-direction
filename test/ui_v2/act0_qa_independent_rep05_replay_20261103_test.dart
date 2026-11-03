import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Independent synthetic QA: real UI callbacks over a mock preference platform.
// This is a widget remount and source-task reward check, never iOS restart proof.
void main() {
  testWidgets(
    'completed source task replay after remount cannot earn XP twice',
    (tester) async {
      const key = 'act0_shell_progress_v1';
      const lessonId = 'fold_check_call_raise';
      const taskId = 'actions_check_drill';
      final world = Act0ShellStateV1.sample.worldById('world_1');
      final lesson = world.lessons.firstWhere((l) => l.lessonId == lessonId);
      final task = lesson.taskList.singleWhere((t) => t.taskId == taskId);
      final store = Act0ProgressStoreV1(key: key, isValidPayload: (_) => true);
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        key: jsonEncode({
          'schemaVersion': 18,
          'completedTaskIds': [
            for (final l in world.lessons.takeWhile(
              (l) => l.lessonId != lessonId,
            ))
              for (final t in l.taskList) t.taskId,
            'actions_theory',
            'actions_legal_context',
          ],
          'skippedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'selectedWorldId': 'world_1',
          'selectedLessonId': lessonId,
          'selectedTaskId': taskId,
          'earnedXp': 20,
          'learningEvidenceHistory': <Object>[],
        }),
      });
      Future<void> mount() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Act0ShellPreviewScreenV1(
              showPlacementOnStart: false,
              initialTab: Act0ShellTabV1.learn,
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<Map<String, dynamic>> durable() async {
        final dynamic state = tester.state(
          find.byType(Act0ShellPreviewScreenV1),
        );
        state.debugPersistProgressV1();
        await tester.pump(const Duration(milliseconds: 300));
        await store.flush();
        return jsonDecode((await store.load())!) as Map<String, dynamic>;
      }

      Future<void> completeSourceTask() async {
        tester
            .widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1))
            .onStartTask(lessonId, taskId);
        await tester.pumpAndSettle();
        final choice = find.byKey(const Key('act0_shell_option_check'));
        for (var step = 0; step < 12 && choice.evaluate().isEmpty; step++) {
          final theory = find.byKey(
            const Key('act0_shell_theory_continue_cta'),
          );
          final next = theory.evaluate().isNotEmpty
              ? theory
              : find.byKey(const Key('act0_shell_continue_cta'));
          expect(next, findsOneWidget);
          await tester.tap(next);
          await tester.pumpAndSettle();
        }
        expect(choice, findsOneWidget);
        expect(
          tester
              .widget<Act0LessonRunnerShellV1>(
                find.byType(Act0LessonRunnerShellV1),
              )
              .runner
              .options
              .singleWhere((o) => o.id == 'check')
              .isCorrect,
          isTrue,
        );
        await tester.tap(choice);
        await tester.pumpAndSettle();
        final feedback = find.byKey(
          const Key('act0_shell_feedback_continue_cta'),
        );
        expect(feedback, findsOneWidget);
        await tester.tap(feedback);
        await tester.pumpAndSettle();
      }

      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await store.flush();
      });
      await mount();
      expect((await durable())['earnedXp'], 20);
      await completeSourceTask();
      final first = await durable();
      expect(first['earnedXp'], 20 + task.rewardXp);
      expect(
        (first['completedTaskIds'] as List).where((id) => id == taskId),
        hasLength(1),
      );
      final firstRecords = (first['learningEvidenceHistory'] as List)
          .where((r) => (r as Map)['taskId'] == taskId)
          .cast<Map>()
          .toList();
      expect(firstRecords, isNotEmpty);
      final firstEventId = firstRecords.first['recordId'];
      expect(firstEventId, isNotEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await store.flush();
      await mount();
      expect((await durable())['earnedXp'], first['earnedXp']);
      await completeSourceTask();
      final replay = await durable();
      expect(replay['earnedXp'], first['earnedXp']);
      expect(
        (replay['completedTaskIds'] as List).where((id) => id == taskId),
        hasLength(1),
      );
      expect(
        (replay['learningEvidenceHistory'] as List).any(
          (r) => (r as Map)['recordId'] == firstEventId,
        ),
        isTrue,
      );
    },
  );
}
