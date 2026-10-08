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
  testWidgets('one independent Practice Queue answer owns one success pair', (
    tester,
  ) async {
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
      queue = queue.upsertIntent(intents[i], order: i + 1);
    }
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
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      'actions_check_drill',
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
      reason: 'Feedback continuation must not emit an answer already owned.',
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
      (entries.single as Map<String, dynamic>)['repairIntent']['targetTaskId'],
      'cards_ranks_suits_board_count',
    );

    // A distinct independent repair attempt retains its own event pair.
    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();
    final secondLaunch = find.byKey(
      const Key('act0_shell_play_repair_queue_item_cta'),
    );
    expect(secondLaunch, findsOneWidget);
    await tester.ensureVisible(secondLaunch);
    await tester.tap(secondLaunch);
    await tester.pumpAndSettle();
    final secondRunner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(secondRunner.selectedTaskId, 'cards_ranks_suits_board_count');
    final secondCorrect = secondRunner.runner.options.firstWhere(
      (option) => option.isCorrect,
    );
    await tester.tap(find.byKey(Key('act0_shell_option_${secondCorrect.id}')));
    await tester.pumpAndSettle();
    expect(sink.events.where((e) => e.name == 'user_choice'), hasLength(2));
    expect(
      sink.events.where((e) => e.name == 'repair_completed'),
      hasLength(2),
    );
    expect(sink.events.where((e) => e.name == 'fix_landed'), hasLength(2));
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
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
      'actions_check_drill',
      'cards_ranks_suits_board_count',
    });
  });
}
