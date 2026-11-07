import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// DAT04 fixture/restart consumer. Derived from the existing independent REP05
// once-only replay control; original control remains unchanged. Real visible
// choice/feedback paths create the snapshots. This is MACHINE widget evidence,
// never target-device proof. driver_v1.py also invokes this in a new OS process
// with the payload actually recovered after killing an in-flight store writer.
void main() {
  testWidgets(
    'DAT04 source snapshots and restart consumer preserve once-only reward',
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
      final restartFile = Platform.environment['DAT04_RESTART_PAYLOAD'];
      final restart = restartFile == null
          ? null
          : jsonDecode(File(restartFile).readAsStringSync()) as Map;
      Map<String, dynamic>? decisionSnapshot;
      SharedPreferencesStorePlatform.instance =
          InMemorySharedPreferencesStore.withData({
            'flutter.act0_welcome_completed_v1': true,
            'flutter.intake_completed_v1': true,
            'flutter.$key': restartFile != null
                ? File(restartFile).readAsStringSync()
                : jsonEncode({
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
        decisionSnapshot ??= await durable();
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
      final before = await durable();
      final initialXp = restart?['earnedXp'] ?? 20;
      final alreadyComplete = (restart?['completedTaskIds'] as List? ?? [])
          .contains(taskId);
      expect(before['earnedXp'], initialXp);
      await completeSourceTask();
      final first = await durable();
      expect(
        first['earnedXp'],
        initialXp + (alreadyComplete ? 0 : task.rewardXp),
      );
      final fixtureFile = Platform.environment['DAT04_FIXTURES'];
      if (fixtureFile != null) {
        expect(decisionSnapshot!['earnedXp'], initialXp);
        expect(
          (decisionSnapshot!['completedTaskIds'] as List).contains(taskId),
          isFalse,
        );
        expect(
          (decisionSnapshot!['learningEvidenceHistory'] as List).where(
            (r) => (r as Map)['taskId'] == taskId,
          ),
          hasLength(1),
        );
        File(fixtureFile).writeAsStringSync(
          jsonEncode({
            'before': jsonEncode(before),
            'decision': jsonEncode(decisionSnapshot),
            'completed': jsonEncode(first),
            'rewardXp': task.rewardXp,
            'sourceTaskId': taskId,
          }),
          flush: true,
        );
      }
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
