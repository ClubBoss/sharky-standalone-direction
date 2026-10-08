import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_multi_repair_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

void main() {
  for (final targetTaskId in <String>[
    'actions_check_drill',
    'cards_ranks_suits_board_count',
  ]) {
    for (final assistanceMode in <String>['quickHint', 'theoryRecall']) {
      testWidgets(
        'Practice Queue $targetTaskId $assistanceMode -> remount -> independent repair',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(430, 932));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          const source = 'what_poker_is_table_read_transfer';
          final intents = <Act0RepairIntentV1>[
            const Act0RepairIntentV1(
              sourceWorldId: 'world_1',
              sourceLessonId: 'what_poker_is',
              sourceTaskId: source,
              choiceId: 'raise',
              result: 'incorrect',
              errorType: 'confused_table_identity',
              missedSignalId: 'no_bet_yet',
              missedSignalLabel: 'No bet yet',
              skillAtomId: 'action_read',
              skillLabel: 'Action read',
              targetWorldId: 'world_1',
              targetLessonId: 'fold_check_call_raise',
              targetTaskId: 'actions_check_drill',
              mappingType: 'repair',
              reasonCode: 'same_signal_action_read_no_bet_yet',
            ),
            const Act0RepairIntentV1(
              sourceWorldId: 'world_1',
              sourceLessonId: 'what_poker_is',
              sourceTaskId: source,
              choiceId: 'not_sure_yet',
              result: 'suboptimal',
              errorType: 'confused_table_identity',
              missedSignalId: 'board_cards',
              missedSignalLabel: 'Board cards',
              skillAtomId: 'board_read',
              skillLabel: 'Board read',
              targetWorldId: 'world_1',
              targetLessonId: 'cards_ranks_suits',
              targetTaskId: 'cards_ranks_suits_board_count',
              mappingType: 'repair',
              reasonCode: 'same_signal_board_read_board_cards',
            ),
          ];
          var queue = const Act0MultiRepairQueueV1();
          for (var i = 0; i < intents.length; i++) {
            if (intents[i].targetTaskId != targetTaskId) continue;
            queue = queue.upsertIntent(intents[i], order: i + 1);
          }
          final answerId = targetTaskId == 'actions_check_drill'
              ? 'check'
              : 'five';
          SharedPreferences.setMockInitialValues(<String, Object>{
            'act0_welcome_completed_v1': true,
            'intake_completed_v1': true,
            'act0_shell_progress_v1': jsonEncode(<String, Object?>{
              'schemaVersion': 17,
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
              'reviewMistakeHistory': <Object>[],
              'learningEvidenceHistory': <Object>[],
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

          final launch = find.byKey(
            const Key('act0_shell_play_repair_queue_item_cta'),
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
          final retry = find.byKey(
            const Key('act0_shell_play_repair_queue_item_cta'),
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
        },
      );
    }
  }
}
