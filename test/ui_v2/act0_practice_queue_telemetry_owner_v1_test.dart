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
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_practice_leaf_v1.dart';

Act0ReviewMistakeHistoryV1 _reviewForEvidence(
  Act0LearningEvidenceHistoryV1 evidence,
) {
  Act0ReviewMistakeRecordV1 reviewRecord(Act0LearningEvidenceRecordV1 source) =>
      Act0ReviewMistakeRecordV1(
        recordId: 'review-${source.recordId}',
        sourceDecisionId: source.recordId,
        createdOrder: source.createdOrder,
        updatedOrder: source.createdOrder,
        worldId: source.worldId,
        lessonId: source.lessonId,
        decisionTaskId: source.taskId,
        sourceTaskId: source.taskId,
        decisionKind: 'actionList',
        selectedId: source.choiceId,
        expectedId: source.expectedChoiceId,
        resultKind: source.resultKind,
        errorType: source.errorType,
        skillAtomId: source.skillAtomId,
        repairFocusId: source.repairFocusId,
        runId: source.runId,
        runKind: source.runKind,
        runOrdinal: source.runOrdinal,
        attemptRecordIds: [source.recordId],
        dedupUsesFallback: false,
      );
  return Act0ReviewMistakeHistoryV1.tryParse([
    for (final source in evidence.records.where((r) => !r.isCorrect))
      reviewRecord(source).toPayload(),
  ])!;
}

void main() {
  for (final hasCanonicalAttempt in [true, false]) {
    testWidgets(
      'real Practice root restores pruned repair history with canonical attempt=$hasCanonicalAttempt',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        // SIMULATED stored events on admitted authored goals. The real root
        // must pass outcomes as well as evidence to its Practice projection.
        final rank = Act0AuthoredRepairGoalFixtureV1.rank();
        final unresolved = Act0AuthoredRepairGoalFixtureV1.noBet();
        final outcome = rank.outcome();
        final fullEvidence = act0AuthoredRepairFixtureHistoryV1(
          intents: [rank.intent, unresolved.intent],
          outcomes: [outcome],
        );
        final evidence = Act0LearningEvidenceHistoryV1(
          records: fullEvidence.records
              .where(
                (r) =>
                    hasCanonicalAttempt ||
                    r.recordId != outcome.repairAttemptId,
              )
              .toList(),
        );
        final review = _reviewForEvidence(evidence);
        final payload = <String, Object?>{
          'schemaVersion': 20,
          'pendingDecisionAssistance': <Object>[],
          'completedTaskIds': [
            'what_poker_is_find_hero',
            'what_poker_is_theory',
          ],
          'skippedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'selectedWorldId': 'world_1',
          'selectedLessonId': 'what_poker_is',
          'selectedTaskId': 'what_poker_is_find_hero',
          'earnedXp': 10,
          'openRepairIntents': <Object>[],
          'multiRepairQueue': const Act0MultiRepairQueueV1().toPayload(),
          'repairOutcomeProjection': [outcome.toPayload()],
          'reviewMistakeHistory': review.toPayload(),
          'learningEvidenceHistory': evidence.toPayload(),
          'learningEvidenceLineage': evidence.lineagePayload(),
        };
        SharedPreferences.setMockInitialValues({
          'act0_welcome_completed_v1': true,
          'intake_completed_v1': true,
          'act0_shell_progress_v1': jsonEncode(payload),
        });
        for (var mount = 0; mount < 2; mount++) {
          await tester.pumpWidget(
            const MaterialApp(
              home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Practice').last);
          await tester.pumpAndSettle();
          final leaf = tester.widget<Act0AcademyPracticeLeafV1>(
            find.byType(Act0AcademyPracticeLeafV1),
          );
          final items = leaf.input.repairQueue.items;
          expect(items, hasLength(hasCanonicalAttempt ? 1 : 2));
          expect(
            items.any(
              (i) => i.itemId.endsWith(
                'review-${unresolved.intent.repairOccurrenceId}',
              ),
            ),
            isTrue,
          );
          final queue = find.byKey(
            const Key('act0_academy_practice_leaf_repair_queue'),
          );
          expect(queue, findsOneWidget);
          expect(
            find.descendant(
              of: queue,
              matching: find.text('You chose king - better: ace'),
            ),
            hasCanonicalAttempt ? findsNothing : findsOneWidget,
          );
          final prefs = await SharedPreferences.getInstance();
          final saved =
              jsonDecode(prefs.getString('act0_shell_progress_v1')!) as Map;
          expect(saved['earnedXp'], 10);
          expect(saved['reviewMistakeHistory'], review.toPayload());
          expect(saved['repairOutcomeProjection'], [outcome.toPayload()]);
          expect(saved['completedTaskIds'], payload['completedTaskIds']);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        }
      },
    );
  }
  for (final historicalCheckSource in [false, true]) {
    testWidgets(
      historicalCheckSource
          ? 'historical Check source keeps Queue repair credit without current Action policy'
          : 'one unassisted familiar/exact Practice Queue answer owns one success pair',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        // SIMULATED persisted source events on the two already admitted goals.
        final sourceTask = act0AuthoredRepairFixtureTaskV1(
          'world_1',
          'fold_check_call_raise',
          'actions_check_drill',
        );
        final builtCheck = buildAct0RepairIntentV1(
          sourceWorldId: 'world_1',
          sourceLessonId: 'fold_check_call_raise',
          sourceTaskId: sourceTask.taskId,
          runner: sourceTask.runner,
          selectedOption: sourceTask.runner.options.singleWhere(
            (option) => option.id == 'fold',
          ),
          currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
        )!;
        final historicalIntent = Act0RepairIntentV1.tryParse({
          ...builtCheck.toPayload(),
          'repairOccurrenceId': 'historical_check_source',
        })!;
        final intents = <Act0RepairIntentV1>[
          historicalCheckSource
              ? historicalIntent
              : Act0AuthoredRepairGoalFixtureV1.noBet().intent,
          Act0AuthoredRepairGoalFixtureV1.rank().intent,
        ];
        final firstRepairTaskId = intents.first.targetTaskId;
        expect(
          firstRepairTaskId,
          historicalCheckSource
              ? 'actions_legal_context'
              : 'actions_check_drill',
        );
        var queue = const Act0MultiRepairQueueV1();
        for (var i = 0; i < intents.length; i++) {
          queue = queue.upsertIntent(intents[i], order: i + 1);
        }
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
            'earnedXp': 10,
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
            'reviewMistakeHistory': _reviewForEvidence(
              act0AuthoredRepairFixtureHistoryV1(
                intents: queue.activeRepairIntents(),
              ),
            ).toPayload(),
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
          firstRepairTaskId,
        );

        final answer = find.byKey(const Key('act0_shell_option_check'));
        expect(answer, findsOneWidget);
        await tester.tap(answer);
        await tester.pumpAndSettle();
        expect(sink.events.where((e) => e.name == 'user_choice'), hasLength(1));
        expect(
          sink.events.where((e) => e.name == 'repair_completed'),
          hasLength(1),
        );
        expect(sink.events.where((e) => e.name == 'fix_landed'), hasLength(1));

        final next = find.byKey(const Key('act0_shell_feedback_continue_cta'));
        expect(next, findsOneWidget);
        await tester.tap(next);
        await tester.pumpAndSettle();

        expect(
          sink.events.where((e) => e.name == 'repair_completed'),
          hasLength(1),
          reason:
              'Feedback continuation must not emit an answer already owned.',
        );
        expect(sink.events.where((e) => e.name == 'fix_landed'), hasLength(1));
        final prefs = await SharedPreferences.getInstance();
        final progress =
            jsonDecode(prefs.getString('act0_shell_progress_v1')!)
                as Map<String, dynamic>;
        final entries =
            (progress['multiRepairQueue'] as Map<String, dynamic>)['entries']
                as List<dynamic>;
        expect(entries, hasLength(1));
        expect(
          (entries.single
              as Map<String, dynamic>)['repairIntent']['targetTaskId'],
          'cards_ranks_suits_rank_drill',
        );

        // A distinct admitted exact rehearsal retains its own event pair.
        await tester.tap(find.text('Practice').last);
        await tester.pumpAndSettle();
        final secondLaunch = act0ShellPresentationFinderV1(
          'act0_shell_play_repair_queue_item_cta',
        );
        expect(secondLaunch, findsOneWidget);
        await tester.ensureVisible(secondLaunch);
        await tester.tap(secondLaunch);
        await tester.pumpAndSettle();
        final secondRunner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(secondRunner.selectedTaskId, 'cards_ranks_suits_rank_drill');
        final secondCorrect = secondRunner.runner.options.firstWhere(
          (option) => option.isCorrect,
        );
        await tester.tap(
          find.byKey(Key('act0_shell_option_${secondCorrect.id}')),
        );
        await tester.pumpAndSettle();
        expect(sink.events.where((e) => e.name == 'user_choice'), hasLength(2));
        expect(
          sink.events.where((e) => e.name == 'repair_completed'),
          hasLength(2),
        );
        expect(sink.events.where((e) => e.name == 'fix_landed'), hasLength(2));
        await tester.tap(
          find.byKey(const Key('act0_shell_feedback_continue_cta')),
        );
        await tester.pumpAndSettle();
        expect(
          sink.events.where((e) => e.name == 'repair_completed'),
          hasLength(2),
        );
        expect(sink.events.where((e) => e.name == 'fix_landed'), hasLength(2));
        final independentSources = sink.events
            .where((e) => e.name == 'fix_landed')
            .map((e) => e.fields['taskId'])
            .toSet();
        expect(independentSources, <String>{
          firstRepairTaskId,
          'cards_ranks_suits_rank_drill',
        });
        final finalProgress =
            jsonDecode(prefs.getString('act0_shell_progress_v1')!)
                as Map<String, dynamic>;
        final onceXp = finalProgress['earnedXp'];
        expect((finalProgress['multiRepairQueue'] as Map)['entries'], isEmpty);
        expect(finalProgress['repairOutcomeProjection'], hasLength(2));
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
        final restored =
            jsonDecode(prefs.getString('act0_shell_progress_v1')!)
                as Map<String, dynamic>;
        expect(restored['earnedXp'], onceXp);
        await tester.tap(find.text('Practice').last);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<Act0AcademyPracticeLeafV1>(
                find.byType(Act0AcademyPracticeLeafV1),
              )
              .input
              .repairQueue
              .items,
          isEmpty,
          reason:
              'Actual Queue answers must not resurrect the two preserved raw source misses.',
        );
        expect(restored['reviewMistakeHistory'], hasLength(2));
        expect(
          restored['repairOutcomeProjection'],
          finalProgress['repairOutcomeProjection'],
        );
        expect(sink.events.where((e) => e.name == 'fix_landed'), hasLength(2));
        expect(
          sink.events.where(
            (event) =>
                event.name == 'recommendation_generated' &&
                event.fields['sequence_stage'] == 'repair',
          ),
          isEmpty,
          reason:
              'A persisted source miss is genuine repair provenance, not a source policy decision observed in this host.',
        );
      },
    );
  }
}
