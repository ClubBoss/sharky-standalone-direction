import 'dart:convert';
import '../support/act0_authored_repair_goal_fixture_v1.dart';
import '../support/act0_shell_presentation_finders_v1.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_multi_repair_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

void main() {
  for (final targetTaskId in <String>[
    'actions_check_drill',
    'cards_ranks_suits_rank_drill',
  ]) {
    for (final assistanceMode in <String>['quickHint', 'theoryRecall']) {
      testWidgets(
        'Practice Queue $targetTaskId $assistanceMode -> remount -> unassisted familiar/exact repair',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(393, 852));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          // SIMULATED persisted source events on the two already admitted goals.
          final intents = <Act0RepairIntentV1>[
            Act0AuthoredRepairGoalFixtureV1.noBet().intent,
            Act0AuthoredRepairGoalFixtureV1.rank().intent,
          ];
          var queue = const Act0MultiRepairQueueV1();
          for (var i = 0; i < intents.length; i++) {
            if (intents[i].targetTaskId != targetTaskId) continue;
            queue = queue.upsertIntent(intents[i], order: i + 1);
          }
          final seededXp = 10;
          final answerId = targetTaskId == 'actions_check_drill'
              ? 'check'
              : 'ace';
          SharedPreferences.setMockInitialValues(<String, Object>{
            'act0_welcome_completed_v1': true,
            'intake_completed_v1': true,
            'act0_shell_progress_v1': jsonEncode(<String, Object?>{
              'schemaVersion': 20,
              'pendingDecisionAssistance': <Object>[],
              'completedTaskIds': <String>[
                'what_poker_is_find_hero',
                'what_poker_is_theory',
              ],
              'skippedTaskIds': <String>[],
              'completedLessonIds': <String>[],
              'selectedWorldId': 'world_1',
              'selectedLessonId': 'what_poker_is',
              'selectedTaskId': 'what_poker_is_find_hero',
              'earnedXp': seededXp,
              'dailyCompletedRepCount': 0,
              'retentionMemory': <Object>[],
              'openRepairIntents': queue
                  .activeRepairIntents()
                  .map((intent) => intent.toPayload())
                  .toList(),
              'multiRepairQueue': queue.toPayload(),
              'multiRepairQueueOrder': 3,
              'repairOutcomeProjection': <Object>[],
              'reviewResolutionReceipts': <Object>[],
              'reviewMistakeHistory': <Object>[],
              'learningEvidenceHistory': act0AuthoredRepairFixtureHistoryV1(
                intents: queue.activeRepairIntents(),
              ).toPayload(),
              'learningEvidenceLineage': act0AuthoredRepairFixtureHistoryV1(
                intents: queue.activeRepairIntents(),
              ).lineagePayload(),
            }),
          });
          final sink = Act0InMemoryTelemetrySinkV1();
          await tester.pumpWidget(
            MaterialApp(
              home: Act0ShellPreviewScreenV1(
                showPlacementOnStart: false,
                telemetrySink: sink,
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Practice').last);
          await tester.pumpAndSettle();

          final launch = act0ShellPresentationFinderV1(
            'act0_shell_play_repair_queue_item_cta',
          );
          expect(launch, findsOneWidget);
          await tester.ensureVisible(launch);
          await tester.tap(launch);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<Act0LessonRunnerShellV1>(
                  find.byType(Act0LessonRunnerShellV1),
                )
                .selectedTaskId,
            targetTaskId,
          );

          final runner = tester.widget<Act0LessonRunnerShellV1>(
            find.byType(Act0LessonRunnerShellV1),
          );
          expect(runner.theoryRecallStep, isNotNull);
          final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
          expect(
            hint,
            findsOneWidget,
            reason: 'Real Practice Queue target must offer Quick Hint.',
          );
          await tester.ensureVisible(hint);
          await tester.tap(hint);
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('act0_shell_hint_body')), findsOneWidget);
          if (targetTaskId == 'actions_check_drill') {
            expect(
              find.text('Name the action before choosing what it means.'),
              findsOneWidget,
            );
          }

          if (assistanceMode == 'theoryRecall') {
            final full = find.byKey(
              const Key('act0_shell_review_full_idea_cta'),
            );
            expect(full, findsOneWidget);
            await tester.ensureVisible(full);
            await tester.tap(full);
            await tester.pumpAndSettle();
            expect(
              find.byKey(const Key('act0_shell_review_full_idea_cta')),
              findsNothing,
            );
          }
          await tester.tap(
            find.byKey(const Key('act0_shell_theory_recall_close_cta')),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(Key('act0_shell_option_$answerId')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('act0_shell_feedback_card')),
            findsOneWidget,
          );
          expect(sink.events.where((e) => e.name == 'fix_landed'), isEmpty);
          expect(
            find.text('Repair proved'),
            findsNothing,
            reason: 'Assisted correct is teaching, not proof of repair.',
          );
          expect(find.text('Continue to Review'), findsWidgets);
          final originalChoice = sink.events
              .where((e) => e.name == 'user_choice')
              .single;
          expect(originalChoice.fields['assistance_kind'], assistanceMode);
          var prefs = await SharedPreferences.getInstance();
          Map<String, dynamic> progress() =>
              jsonDecode(prefs.getString('act0_shell_progress_v1')!)
                  as Map<String, dynamic>;
          expect(
            (progress()['multiRepairQueue'] as Map)['entries'],
            hasLength(1),
          );
          expect(progress()['repairOutcomeProjection'], isEmpty);
          expect(progress()['earnedXp'], seededXp);
          expect(progress()['reviewResolutionReceipts'], isEmpty);
          final evidences = progress()['learningEvidenceHistory'] as List;
          expect((evidences.last as Map)['assistanceKind'], assistanceMode);

          await tester.tap(
            find.byKey(const Key('act0_shell_feedback_continue_cta')),
          );
          await tester.pumpAndSettle();
          expect(sink.events.where((e) => e.name == 'fix_landed'), isEmpty);
          expect(
            sink.events.where((e) => e.name == 'repair_completed'),
            hasLength(1),
          );

          expect(
            act0ShellPresentationFinderV1('act0_shell_review_screen'),
            findsOneWidget,
          );

          // Tear down the runner and reconstruct from persistent SharedPreferences.
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpWidget(
            MaterialApp(
              home: Act0ShellPreviewScreenV1(
                showPlacementOnStart: false,
                telemetrySink: sink,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            (progress()['multiRepairQueue'] as Map)['entries'],
            hasLength(1),
          );
          await tester.tap(find.text('Review').last);
          await tester.pumpAndSettle();
          expect(sink.events.where((e) => e.name == 'fix_landed'), isEmpty);
          await tester.tap(find.text('Practice').last);
          await tester.pumpAndSettle();
          final retry = act0ShellPresentationFinderV1(
            'act0_shell_play_repair_queue_item_cta',
          );
          expect(retry, findsOneWidget);
          await tester.ensureVisible(retry);
          await tester.tap(retry);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<Act0LessonRunnerShellV1>(
                  find.byType(Act0LessonRunnerShellV1),
                )
                .selectedTaskId,
            targetTaskId,
          );
          await tester.tap(find.byKey(Key('act0_shell_option_$answerId')));
          await tester.pumpAndSettle();
          expect(
            sink.events.where((e) => e.name == 'fix_landed'),
            hasLength(1),
          );
          await tester.tap(
            find.byKey(const Key('act0_shell_feedback_continue_cta')),
          );
          await tester.pumpAndSettle();
          expect(
            sink.events.where((e) => e.name == 'fix_landed'),
            hasLength(1),
          );
          expect((progress()['multiRepairQueue'] as Map)['entries'], isEmpty);
          final onceXp = progress()['earnedXp'];
          final outcomes = progress()['repairOutcomeProjection'] as List;
          expect(outcomes, hasLength(1));
          expect(
            (outcomes.single as Map)['sourceTaskId'],
            intents
                .singleWhere((intent) => intent.targetTaskId == targetTaskId)
                .sourceTaskId,
          );
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await tester.pumpWidget(
            MaterialApp(
              home: Act0ShellPreviewScreenV1(
                showPlacementOnStart: false,
                telemetrySink: sink,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(progress()['earnedXp'], onceXp);
          expect((progress()['multiRepairQueue'] as Map)['entries'], isEmpty);
          expect(progress()['repairOutcomeProjection'], outcomes);
        },
      );
    }
  }
  for (final assistanceMode in ['quickHint', 'theoryRecall']) {
    testWidgets(
      'ordinary board-count $assistanceMode keeps community-card teaching, not repair proof',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final world = Act0ShellStateV1.sample.worldById('world_1');
        final lesson = world.lessons.singleWhere(
          (lesson) => lesson.lessonId == 'cards_ranks_suits',
        );
        SharedPreferences.setMockInitialValues({
          'act0_welcome_completed_v1': true,
          'intake_completed_v1': true,
          'act0_shell_progress_v1': jsonEncode({
            'schemaVersion': 18,
            'earnedXp': 0,
            'completedTaskIds': <String>[],
            'completedLessonIds': <String>[],
            // Access-only skips are not earned progress or a repair occurrence.
            'skippedTaskIds': [
              for (final prior in world.lessons.takeWhile(
                (prior) => prior.lessonId != lesson.lessonId,
              ))
                for (final task in prior.taskList) task.taskId,
              for (final task in lesson.taskList.takeWhile(
                (task) => task.taskId != 'cards_ranks_suits_board_count',
              ))
                task.taskId,
            ],
            'selectedWorldId': 'world_1',
            'selectedLessonId': lesson.lessonId,
            'selectedTaskId': 'cards_ranks_suits_board_count',
          }),
        });
        final sink = Act0InMemoryTelemetrySinkV1();
        await tester.pumpWidget(
          MaterialApp(
            home: Act0ShellPreviewScreenV1(
              initialTab: Act0ShellTabV1.play,
              initialPhase: Act0LessonPhaseV1.drill,
              showPlacementOnStart: false,
              telemetrySink: sink,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
        for (var step = 0; step < 12 && hint.evaluate().isEmpty; step++) {
          final next = find.byKey(const Key('act0_shell_continue_cta'));
          expect(next, findsOneWidget);
          await tester.tap(next);
          await tester.pumpAndSettle();
        }
        expect(
          tester
              .widget<Act0LessonRunnerShellV1>(
                find.byType(Act0LessonRunnerShellV1),
              )
              .selectedTaskId,
          'cards_ranks_suits_board_count',
        );
        expect(hint, findsOneWidget);
        await tester.ensureVisible(hint);
        await tester.tap(hint);
        await tester.pumpAndSettle();
        expect(
          find.text('Count the shared cards in the middle.'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Count only chips that are actually in the pot or matched.',
          ),
          findsNothing,
        );
        if (assistanceMode == 'theoryRecall') {
          final full = find.byKey(const Key('act0_shell_review_full_idea_cta'));
          expect(full, findsOneWidget);
          await tester.ensureVisible(full);
          await tester.tap(full);
          await tester.pumpAndSettle();
        }
        await tester.tap(
          find.byKey(const Key('act0_shell_theory_recall_close_cta')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('act0_shell_option_five')));
        await tester.pumpAndSettle();
        final choice = sink.events
            .where((event) => event.name == 'user_choice')
            .single;
        expect(choice.fields['assistance_kind'], assistanceMode);
        expect(
          sink.events.where((event) => event.name == 'fix_landed'),
          isEmpty,
        );
        final prefs = await SharedPreferences.getInstance();
        final saved =
            jsonDecode(prefs.getString('act0_shell_progress_v1')!)
                as Map<String, dynamic>;
        expect(saved['openRepairIntents'], isEmpty);
        expect(saved['repairOutcomeProjection'], isEmpty);
        expect(
          (saved['learningEvidenceHistory'] as List).last['assistanceKind'],
          assistanceMode,
        );
      },
    );
  }
}
