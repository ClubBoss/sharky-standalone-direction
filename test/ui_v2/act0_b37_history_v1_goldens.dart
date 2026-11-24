// Establish the seven reference frames with --update-goldens, then compare
// on the same Flutter SDK. The PNGs live in the local build directory.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_replay_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _frame = Key('history_golden_frame');
const _play = Key('act0_attempt_replay_play_pause');
const _next = Key('act0_attempt_replay_next');

Act0ArchivedAttemptV1 _savedAttempt() {
  const world = 'world_4';
  const lesson = 'call_price';
  final task = Act0ShellStateV1.sample
      .worldById(world)
      .lessons
      .singleWhere((entry) => entry.lessonId == lesson)
      .taskList
      .singleWhere((entry) => entry.taskId == 'w4_cheap_price_marginal_call');
  final table = task.runner.table;
  return Act0ArchivedAttemptV1.fromRecordedDecision(
    Act0LearningEvidenceRecordV1(
      recordId: 'golden-attempt',
      createdOrder: 1,
      worldId: world,
      lessonId: lesson,
      taskId: task.taskId,
      choiceId: 'call',
      expectedChoiceId: 'call',
      isCorrect: true,
      errorType: 'none',
      repairFocusId: 'pot',
      skillAtomId: 'call_price',
      decisionTimeBucket: 'under_3s',
      resultKind: 'correct',
      assistanceKind: Act0DecisionAssistanceV1.none,
      recordedAtUtc: DateTime.utc(2026, 11, 24, 12),
      authoredSourceFingerprint: act0AuthoredSourceFingerprintV1(
        worldId: world,
        lessonId: lesson,
        task: task,
      )!,
    ),
    taskLabel: task.runner.question,
    choiceLabel: 'Call',
    timelineSnapshot: table.handTimelinePrefix,
    tableFingerprint: act0ReplayTableFingerprintV1(table),
    recordedTrail: [
      ...table.actionTrail,
      const Act0ActionTrailItemV1.note(label: 'Your choice: Call'),
    ],
  )!;
}

Future<void> _mount(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      home: Scaffold(
        body: RepaintBoundary(key: _frame, child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(String state) => expectLater(
  find.byKey(_frame),
  matchesGoldenFile('../../.dart_tool/b37_history_goldens/$state.png'),
);

void main() {
  for (final expanded in [false, true]) {
    testWidgets('archive ${expanded ? 'expanded' : 'list'}', (tester) async {
      final attempt = _savedAttempt();
      final archive = const Act0AttemptArchiveV1.empty().add(attempt);
      await _mount(
        tester,
        Act0AttemptArchiveScreenV1(
          archive: expanded ? archive.select(attempt.id) : archive,
          onClose: () {},
          onSelect: (_) {},
          onRemove: (_) {},
          onOwnHandsChanged: (_) {},
        ),
      );
      await _capture(expanded ? 'archive_expanded' : 'archive_list');
    });
  }

  for (final state in ['playing', 'paused', 'end']) {
    testWidgets('replay $state', (tester) async {
      final attempt = _savedAttempt();
      await _mount(
        tester,
        Act0AttemptReplayScreenV1(attempt: attempt, onClose: () {}),
      );
      expect(
        find.byKey(const Key('act0_attempt_replay_table')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(_play));
      await tester.pump(const Duration(seconds: 1));
      if (state == 'paused') {
        await tester.tap(find.byKey(_play));
        await tester.pumpAndSettle();
      } else if (state == 'end') {
        await tester.pump(Duration(seconds: attempt.events.length));
        await tester.pumpAndSettle();
      }
      expect(
        tester.widget<TextButton>(find.byKey(_next)).onPressed,
        state == 'end' ? isNull : isNotNull,
      );
      await _capture('replay_$state');
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final populated in [false, true]) {
    testWidgets('own hands ${populated ? 'list' : 'empty'}', (tester) async {
      const archive = Act0AttemptArchiveV1.empty();
      await _mount(
        tester,
        Act0AttemptArchiveScreenV1(
          archive: populated
              ? archive.importPokerStars(
                  File(
                    'test/fixtures/hand_history/pokerstars_nlhe_usd_fold.txt',
                  ).readAsStringSync(),
                )
              : archive,
          ownHands: true,
          onClose: () {},
          onSelect: (_) {},
          onRemove: (_) {},
          onOwnHandsChanged: (_) {},
        ),
      );
      await _capture(populated ? 'own_hands_list' : 'own_hands_empty');
    });
  }
}
