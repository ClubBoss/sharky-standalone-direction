import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

void main() {
  const progressKey = 'act0_shell_progress_v1';
  const lessonId = 'fold_check_call_raise';
  final world = Act0ShellStateV1.sample.worldById('world_1');
  final lesson = world.lessons.firstWhere((item) => item.lessonId == lessonId);

  testWidgets(
    'new helped replay after widget recreation has distinct durable attempt',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final task = lesson.taskList.firstWhere(
        (item) => item.taskId == 'actions_check_drill',
      );
      var history = const Act0LearningEvidenceHistoryV1();
      final attempts = <Act0CompletedDecisionV1>[];
      final sink = Act0InMemoryTelemetrySinkV1();
      Widget host() => MaterialApp(
        home: Act0LessonRunnerShellV1(
          runner: task.runner.copyWith(
            phase: Act0LessonPhaseV1.drill,
            teachingSteps: const <Act0TeachingStepV1>[],
          ),
          selectedWorldId: 'world_1',
          selectedLessonId: lessonId,
          selectedTaskId: task.taskId,
          selectedTaskFamily: task.resolvedTaskFamily,
          theoryRecallStep: const Act0TeachingStepV1(
            title: 'Recall',
            body: 'Remember the rule',
          ),
          telemetrySink: sink,
          evidenceNextOrder: history.records.isEmpty
              ? 1
              : history.records.last.createdOrder + 1,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
          onCompletedDecision: (decision) {
            attempts.add(decision);
            history = history.appendCompletedDecision(decision);
          },
        ),
      );
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pumpAndSettle();
      expect(attempts, hasLength(1));
      // Duplicate delivery while the same attempt is already committed is inert.
      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pump();
      expect(attempts, hasLength(1));
      expect(sink.events.where((e) => e.name == 'user_choice'), hasLength(1));
      // A deliberate new tap after a stable rebuild is a new completed attempt.
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pumpAndSettle();
      expect(attempts, hasLength(2));
      expect(history.records, hasLength(2));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_theory_recall_cta')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_theory_recall_close_cta')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pumpAndSettle();
      expect(attempts, hasLength(3));
      expect(
        history.records,
        hasLength(3),
        reason:
            'new assisted attempt must not reuse an independent attempt key',
      );
      expect(
        history.records.last.assistanceKind,
        Act0DecisionAssistanceV1.quickHint,
      );
      final choiceEvents = sink.events
          .where((e) => e.name == 'user_choice')
          .toList();
      final decisionEvents = sink.events
          .where((e) => e.name == 'decision_made')
          .toList();
      final resultEvents = sink.events
          .where((e) => e.name == 'task_result')
          .toList();
      expect(choiceEvents, hasLength(3));
      expect(decisionEvents, hasLength(3));
      expect(resultEvents, hasLength(3));
      expect(
        choiceEvents.first.fields['attempt_id'],
        isNot(choiceEvents.last.fields['attempt_id']),
      );
      expect(
        choiceEvents.map((e) => e.fields['attempt_id']),
        orderedEquals(decisionEvents.map((e) => e.fields['attempt_id'])),
      );
      expect(
        choiceEvents.map((e) => e.fields['attempt_id']),
        orderedEquals(resultEvents.map((e) => e.fields['attempt_id'])),
      );
      expect(
        history.records.map((e) => e.recordId),
        orderedEquals(choiceEvents.map((e) => e.fields['attempt_id'])),
      );
    },
  );

  testWidgets(
    'one-task replay of completed assisted lesson cannot claim whole-lesson clean pass',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final prior = <String>[
        for (final l in world.lessons.takeWhile((l) => l.lessonId != lessonId))
          for (final task in l.taskList) task.taskId,
      ];
      final allIds = <String>[
        ...prior,
        for (final task in lesson.taskList) task.taskId,
      ];
      SharedPreferences.setMockInitialValues(<String, Object>{
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        progressKey: jsonEncode(<String, Object?>{
          'schemaVersion': 18,
          'completedTaskIds': allIds,
          'completedLessonIds': <String>[
            for (final l in world.lessons.takeWhile(
              (l) => l.lessonId != lessonId,
            ))
              l.lessonId,
            lessonId,
          ],
          'selectedWorldId': 'world_1',
          'selectedLessonId': lessonId,
          'selectedTaskId': 'actions_review',
          'earnedXp': 65,
          'lessonRunEvidenceBoundaries': <String, Object?>{lessonId: 0},
          'learningEvidenceHistory': <Object>[
            <String, Object?>{
              'schemaVersion': 1,
              'recordId': 'prior|hint|1',
              'createdOrder': 1,
              'worldId': 'world_1',
              'lessonId': lessonId,
              'taskId': 'actions_check_drill',
              'choiceId': 'check',
              'expectedChoiceId': 'check',
              'isCorrect': true,
              'errorType': 'none',
              'skillAtomId': 'action_read',
              'decisionTimeBucket': '3_to_10s',
              'resultKind': 'correct',
              'assistanceKind': 'quickHint',
            },
          ],
        }),
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(
            showPlacementOnStart: false,
            initialTab: Act0ShellTabV1.learn,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final learn = find.byType(Act0LearnPathShellV1);
      expect(learn, findsOneWidget);
      tester.widget<Act0LearnPathShellV1>(learn).onSelectLesson(lessonId);
      await tester.pumpAndSettle();
      tester
          .widget<Act0LearnPathShellV1>(learn)
          .onStartTask(lessonId, 'actions_review');
      await tester.pumpAndSettle();
      final runner = find.byType(Act0LessonRunnerShellV1);
      expect(runner, findsOneWidget);
      expect(
        tester.widget<Act0LessonRunnerShellV1>(runner).selectedTaskId,
        'actions_review',
      );
      // Replay opens the previously completed recap in review phase;
      // pressing Continue is intentionally a partial replay, not an assessment.
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_block_summary_accuracy')),
        findsOneWidget,
      );
      expect(find.text('Clean pass'), findsNothing);
      expect(find.textContaining('100% accuracy'), findsNothing);
    },
  );
  testWidgets(
    'persisted real Learn replay creates one new assisted durable identity',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final previous = <String>[
        for (final l in world.lessons.takeWhile((l) => l.lessonId != lessonId))
          for (final t in l.taskList) t.taskId,
        'actions_theory',
        'actions_legal_context',
        'actions_check_drill',
      ];
      SharedPreferences.setMockInitialValues(<String, Object>{
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        progressKey: jsonEncode(<String, Object?>{
          'schemaVersion': 18,
          'completedTaskIds': previous,
          'completedLessonIds': <String>[
            for (final l in world.lessons.takeWhile(
              (l) => l.lessonId != lessonId,
            ))
              l.lessonId,
          ],
          'selectedWorldId': 'world_1',
          'selectedLessonId': lessonId,
          'selectedTaskId': 'actions_fold_drill',
          'lessonRunEvidenceBoundaries': <String, Object?>{lessonId: 0},
          'learningEvidenceHistory': <Object>[
            <String, Object?>{
              'schemaVersion': 1,
              'recordId':
                  'v1|world_1|fold_check_call_raise|actions_check_drill|actionList|check|1',
              'createdOrder': 1,
              'worldId': 'world_1',
              'lessonId': lessonId,
              'taskId': 'actions_check_drill',
              'choiceId': 'check',
              'expectedChoiceId': 'check',
              'isCorrect': true,
              'errorType': 'none',
              'skillAtomId': 'action_read',
              'decisionTimeBucket': '3_to_10s',
              'resultKind': 'correct',
              'assistanceKind': 'none',
            },
          ],
        }),
      });
      final sink = Act0InMemoryTelemetrySinkV1();
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            showPlacementOnStart: false,
            initialTab: Act0ShellTabV1.learn,
            telemetrySink: sink,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final learn = find.byType(Act0LearnPathShellV1);
      tester.widget<Act0LearnPathShellV1>(learn).onSelectLesson(lessonId);
      await tester.pumpAndSettle();
      tester
          .widget<Act0LearnPathShellV1>(learn)
          .onStartTask(lessonId, 'actions_check_drill');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        'actions_check_drill',
      );
      final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
      for (var i = 0; i < 12 && hint.evaluate().isEmpty; i++) {
        final next =
            find
                .byKey(const Key('act0_shell_theory_continue_cta'))
                .evaluate()
                .isNotEmpty
            ? find.byKey(const Key('act0_shell_theory_continue_cta'))
            : find.byKey(const Key('act0_shell_continue_cta'));
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      await tester.tap(hint);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_theory_recall_close_cta')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonDecode(prefs.getString(progressKey)!) as Map;
      final records = (payload['learningEvidenceHistory'] as List).cast<Map>();
      expect(records, hasLength(2));
      expect(records.last['assistanceKind'], 'quickHint');
      expect(records.first['recordId'], isNot(records.last['recordId']));
      final choice = sink.events
          .where(
            (e) =>
                e.name == 'user_choice' &&
                e.fields['taskId'] == 'actions_check_drill',
          )
          .toList();
      final decisions = sink.events
          .where(
            (e) =>
                e.name == 'decision_made' &&
                e.fields['taskId'] == 'actions_check_drill',
          )
          .toList();
      final results = sink.events
          .where(
            (e) =>
                e.name == 'task_result' &&
                e.fields['taskId'] == 'actions_check_drill',
          )
          .toList();
      expect(choice, hasLength(1));
      expect(decisions, hasLength(1));
      expect(results, hasLength(1));
      expect(records.last['recordId'], choice.single.fields['attempt_id']);
      expect(
        choice.single.fields['attempt_id'],
        decisions.single.fields['attempt_id'],
      );
      expect(
        choice.single.fields['attempt_id'],
        results.single.fields['attempt_id'],
      );
    },
  );
}
