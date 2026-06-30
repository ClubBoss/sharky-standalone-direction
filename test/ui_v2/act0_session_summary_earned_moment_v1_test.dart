import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

void main() {
  testWidgets('Session Summary renders no earned moment with empty consumer', (
    tester,
  ) async {
    await _pumpSummary(tester, consumer: const Act0AchievementSeedConsumerV1());

    expect(
      find.byKey(const Key('act0_shell_block_summary_earned_moment')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_block_summary_evidence_card')),
      findsOneWidget,
    );
    expect(find.text('You played 2 spots.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
      findsOneWidget,
    );
  });

  testWidgets('Session Summary renders no repair receipt without outcomes', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
        const Act0RepairOutcomeProjectionV1(),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_session_repair_outcome_receipt')),
      findsNothing,
    );
    expect(find.text("Fixes you've banked"), findsNothing);
    expect(find.text('Good fixes: 1'), findsNothing);
    expect(find.text('Still to fix: 1'), findsNothing);
    expect(find.text('Fixes tried: 1'), findsNothing);
    expect(find.text('You played 2 spots.'), findsOneWidget);
  });

  testWidgets('Session Summary shows good repair receipt from projection', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
        _repairOutcomeProjection(outcomeState: act0RepairOutcomeStateCorrectV1),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_session_repair_outcome_receipt')),
      findsOneWidget,
    );
    expect(find.text("Fixes you've banked"), findsOneWidget);
    expect(find.text('Good fixes: 1'), findsOneWidget);
    expect(find.text('Still to fix: 1'), findsNothing);
    expect(find.text('Fixes tried: 1'), findsNothing);
  });

  testWidgets('Session Summary shows worth repeating repair receipt', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
        _repairOutcomeProjection(
          outcomeState: act0RepairOutcomeStateStillNeedsRepV1,
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_session_repair_outcome_receipt')),
      findsOneWidget,
    );
    expect(find.text("Fixes you've banked"), findsOneWidget);
    expect(find.text('Still to fix: 1'), findsOneWidget);
    expect(find.text('Good fixes: 1'), findsNothing);
  });

  testWidgets('Session Summary shows attempted-only repair receipt', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
        _repairOutcomeProjection(
          outcomeState: act0RepairOutcomeStateAttemptedV1,
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_session_repair_outcome_receipt')),
      findsOneWidget,
    );
    expect(find.text("Fixes you've banked"), findsOneWidget);
    expect(find.text('Fixes tried: 1'), findsOneWidget);
    expect(find.text('Good fixes: 1'), findsNothing);
    expect(find.text('Still to fix: 1'), findsNothing);
  });

  testWidgets('Session Summary repair receipt summarizes deterministically', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
        Act0RepairOutcomeProjectionV1(
          outcomes: <Act0RepairOutcomeV1>[
            _repairOutcome(
              outcomeState: act0RepairOutcomeStateStillNeedsRepV1,
              sequence: 3,
              queueItemId: 'queue_3',
            ),
            _repairOutcome(
              outcomeState: act0RepairOutcomeStateCorrectV1,
              sequence: 1,
              queueItemId: 'queue_1',
            ),
            _repairOutcome(
              outcomeState: act0RepairOutcomeStateCorrectV1,
              sequence: 2,
              queueItemId: 'queue_2',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Good fixes: 2'), findsOneWidget);
    expect(find.text('Still to fix: 1'), findsOneWidget);
    final goodTop = tester.getTopLeft(find.text('Good fixes: 2')).dy;
    final repeatTop = tester.getTopLeft(find.text('Still to fix: 1')).dy;
    expect(goodTop, lessThan(repeatTop));
  });

  testWidgets(
    'Session Summary hero leads with correct read and good fix proof',
    (tester) async {
      await _pumpSummary(
        tester,
        consumer: Act0AchievementSeedConsumerV1.fromProjection(
          Act0AchievementSeedProjectionV1(
            seeds: <Act0AchievementSeedV1>[
              _seed(act0AchievementSeedFirstCorrectReadV1, sequence: 1),
            ],
          ),
        ),
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          _repairOutcomeProjection(
            outcomeState: act0RepairOutcomeStateCorrectV1,
          ),
        ),
      );

      expect(find.text('Proof banked'), findsWidgets);
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('act0_shell_block_summary_title')),
            )
            .data,
        'You turned one miss into a fix.',
      );
      expect(find.text('First read banked. Fix landed.'), findsOneWidget);
      expect(find.text('Almost there - replay to unlock'), findsNothing);
      expect(find.text('Replay before next lesson'), findsOneWidget);
      expect(find.text("Fixes you've banked"), findsOneWidget);
      expect(find.text('Good fixes: 1'), findsOneWidget);
      expect(find.text('Small win, real proof.'), findsOneWidget);

      final next = find.byKey(const Key('act0_shell_block_summary_next_label'));
      final habit = find.byKey(
        const Key('act0_shell_block_summary_habit_reward'),
      );
      final receipt = find.byKey(
        const Key('act0_shell_session_repair_outcome_receipt'),
      );
      expect(next, findsOneWidget);
      expect(habit, findsOneWidget);
      expect(receipt, findsOneWidget);
      expect(tester.getTopLeft(next).dy, lessThan(tester.getTopLeft(habit).dy));
      expect(
        tester.getTopLeft(next).dy,
        lessThan(tester.getTopLeft(receipt).dy),
      );
    },
  );

  testWidgets('Session Summary hero can lead with correct read proof only', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: Act0AchievementSeedConsumerV1.fromProjection(
        Act0AchievementSeedProjectionV1(
          seeds: <Act0AchievementSeedV1>[
            _seed(act0AchievementSeedFirstCorrectReadV1, sequence: 1),
          ],
        ),
      ),
    );

    expect(
      tester
          .widget<Text>(find.byKey(const Key('act0_shell_block_summary_title')))
          .data,
      'First read banked.',
    );
    expect(
      find.text('One clean read is saved from this session.'),
      findsOneWidget,
    );
    expect(find.text('Session closed with proof'), findsNothing);
    expect(find.text('Good fix banked.'), findsNothing);
  });

  testWidgets('Session Summary hero can lead with good fix proof only', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
        _repairOutcomeProjection(outcomeState: act0RepairOutcomeStateCorrectV1),
      ),
    );

    expect(find.text('Fix landed.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_payoff_motion_reveal')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_block_summary_next_motion_reveal')),
      findsOneWidget,
    );
    expect(find.byType(AnimatedSlide), findsWidgets);
    expect(find.byType(AnimatedOpacity), findsWidgets);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('act0_shell_block_summary_title')))
          .data,
      'Fix landed.',
    );
    expect(find.text('You turned one miss into a fix.'), findsOneWidget);
    expect(find.text('Small win, real proof.'), findsOneWidget);
    expect(find.text('Almost there - replay to unlock'), findsNothing);
  });

  testWidgets('Session Summary keeps gate-first hero without proof', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
        const Act0RepairOutcomeProjectionV1(),
      ),
    );

    expect(
      tester
          .widget<Text>(find.byKey(const Key('act0_shell_block_summary_title')))
          .data,
      'Almost there - replay to unlock',
    );
    expect(find.text('Session closed with proof'), findsNothing);
    expect(find.text('First correct read banked.'), findsNothing);
    expect(find.text('Good fix banked.'), findsNothing);
    expect(find.text('Small win, real proof.'), findsNothing);
  });

  testWidgets('Session Summary repair receipt contains no forbidden copy', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
        _repairOutcomeProjection(outcomeState: act0RepairOutcomeStateCorrectV1),
      ),
    );

    final receiptText = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(
              const Key('act0_shell_session_repair_outcome_receipt'),
            ),
            matching: find.byType(Text),
          ),
        )
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();

    for (final forbidden in <String>[
      'fixed',
      'cleared',
      'resolved',
      'fixed forever',
      'completed',
      'mastered',
      'leak',
      'all-time',
      'rating',
      'radar',
      'level',
      'ai',
      'gto',
      'solver',
      'premium',
      'guaranteed improvement',
    ]) {
      expect(_containsForbiddenTokenInText(receiptText, forbidden), isFalse);
    }
  });

  testWidgets('Session Summary renders repair candidate line safely', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      evidenceSummary: const Act0SessionSummaryEvidenceViewModelV1(
        hasEvidence: true,
        title: 'This run',
        runId: 'run_v1|world_1|fold_check_call_raise|lesson|1',
        runKind: 'lesson',
        spotsLine: 'You played 2 spots.',
        resultLine: '1 correct / 1 to review.',
        repairFocusLine: 'You missed Action reads recently.',
        repairCandidateLine:
            'Suggested focus: Action reads. Worth practicing next.',
        currentSessionOnly: true,
      ),
    );

    expect(
      find.text('Suggested focus: Action reads. Worth practicing next.'),
      findsOneWidget,
    );
    final body = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();
    expect(body, isNot(contains('recommended repair')));
    expect(body, isNot(contains('no_bet_yet')));
    expect(body, isNot(contains('ai found')));
    expect(body, isNot(contains('gto')));
    expect(body, isNot(contains('solver')));
    expect(body, isNot(contains('guaranteed')));
  });

  testWidgets('Session Summary renders later-correct proof line safely', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      evidenceSummary: const Act0SessionSummaryEvidenceViewModelV1(
        hasEvidence: true,
        title: 'This run',
        runId: 'run_v1|world_1|fold_check_call_raise|lesson|2',
        runKind: 'lesson',
        spotsLine: 'You played 1 spot.',
        resultLine: '1 correct / 0 to review.',
        repairFocusLine: null,
        repairCandidateLine: null,
        learningProofLine: 'You later answered this focus correctly.',
        currentSessionOnly: true,
      ),
    );

    expect(
      find.text('You later answered this focus correctly.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_block_summary_evidence_learning_proof')),
      findsOneWidget,
    );
    final body = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();
    expect(body, isNot(contains('practice fixed')));
    expect(body, isNot(contains('practice improved')));
    expect(body, isNot(contains('mastered')));
    expect(body, isNot(contains('fixed')));
    expect(body, isNot(contains('solved')));
    expect(body, isNot(contains('guaranteed improvement')));
    expect(body, isNot(contains('proven improvement')));
    expect(body, isNot(contains('ai saw')));
    expect(body, isNot(contains('gto')));
    expect(body, isNot(contains('solver')));
  });

  testWidgets('Session Summary shows Practice CTA for safe mapper target', (
    tester,
  ) async {
    Act0PracticeRepairQueueLaunchRequestV1? capturedRequest;
    const request = Act0PracticeRepairQueueLaunchRequestV1(
      targetWorldId: 'world_1',
      targetLessonId: 'fold_check_call_raise',
      targetTaskId: 'actions_check_drill',
      targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
      sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
      sourceTaskId: 'actions_legal_context',
      repairTaskId: 'actions_check_drill',
      repairFocusKey: 'actions_legal_context|no_bet_yet',
      queueItemId: 'practice_repair_queue_v1|concept_candidate|no_bet_yet',
    );

    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      evidenceSummary: const Act0SessionSummaryEvidenceViewModelV1(
        hasEvidence: true,
        title: 'This run',
        runId: 'run_v1|world_1|fold_check_call_raise|lesson|1',
        runKind: 'lesson',
        spotsLine: 'You played 2 spots.',
        resultLine: '1 correct / 1 to review.',
        repairFocusLine: 'You missed Action reads recently.',
        repairCandidateLine:
            'Suggested focus: Action reads. Worth practicing next.',
        practiceLaunchRequest: request,
        currentSessionOnly: true,
      ),
      onLaunchPracticeRepairQueueTarget: (request) {
        capturedRequest = request;
      },
    );

    expect(find.text('Practice this next'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_session_summary_practice_cta')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_session_summary_practice_cta')),
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_session_summary_practice_cta')),
    );

    expect(capturedRequest?.targetWorldId, 'world_1');
    expect(capturedRequest?.targetLessonId, 'fold_check_call_raise');
    expect(capturedRequest?.targetTaskId, 'actions_check_drill');
    expect(capturedRequest?.sourceTaskId, 'actions_legal_context');
    expect(capturedRequest?.repairTaskId, 'actions_check_drill');
  });

  testWidgets('Session Summary hides Practice CTA without mapped target', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      evidenceSummary: const Act0SessionSummaryEvidenceViewModelV1(
        hasEvidence: true,
        title: 'This run',
        runId: 'run_v1|world_1|fold_check_call_raise|lesson|1',
        runKind: 'lesson',
        spotsLine: 'You played 2 spots.',
        resultLine: '1 correct / 1 to review.',
        repairFocusLine: 'You missed Action reads recently.',
        repairCandidateLine:
            'Suggested focus: Action reads. Worth practicing next.',
        currentSessionOnly: true,
      ),
      onLaunchPracticeRepairQueueTarget: (_) {},
    );

    expect(find.text('Practice this next'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_session_summary_practice_cta')),
      findsNothing,
    );
  });

  testWidgets('Session Summary renders exactly one earned moment', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: Act0AchievementSeedConsumerV1.fromProjection(
        Act0AchievementSeedProjectionV1(
          seeds: <Act0AchievementSeedV1>[
            _seed(act0AchievementSeedFirstCorrectReadV1, sequence: 1),
            _seed(act0AchievementSeedFirstRepairNoteV1, sequence: 2),
          ],
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_block_summary_earned_moment')),
      findsOneWidget,
    );
    expect(find.text('Collected proof'), findsOneWidget);
    expect(find.text('Small win earned. Sharky can prove it.'), findsOneWidget);
    expect(find.text('Earned moment'), findsNothing);
    expect(find.text('First correct read'), findsOneWidget);
    expect(find.text('First repair note'), findsNothing);
  });

  testWidgets('Session Summary hides blocked and unearned seeds', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: Act0AchievementSeedConsumerV1.fromProjection(
        Act0AchievementSeedProjectionV1(
          seeds: <Act0AchievementSeedV1>[
            _seed(
              act0AchievementSeedFirstLessonCompleteV1,
              state: act0AchievementSeedStateBlockedMissingSourceV1,
              earned: false,
            ),
            _seed(
              act0AchievementSeedFirstCleanMiniDrillV1,
              state: act0AchievementSeedStateBlockedMissingSourceV1,
              earned: false,
            ),
            _seed(
              act0AchievementSeedFirstEvidenceSignalV1,
              state: act0AchievementSeedStateNotEarnedV1,
              earned: false,
            ),
          ],
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_block_summary_earned_moment')),
      findsNothing,
    );
    expect(find.text('Lesson complete'), findsNothing);
    expect(find.text('Clean mini-drill'), findsNothing);
    expect(find.text('First evidence signal'), findsNothing);
    expect(find.text('Collected proof'), findsNothing);
    expect(find.text('Small win earned. Sharky can prove it.'), findsNothing);
  });

  testWidgets('Session Summary earned moment contains no forbidden copy', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: Act0AchievementSeedConsumerV1.fromProjection(
        Act0AchievementSeedProjectionV1(
          seeds: <Act0AchievementSeedV1>[
            _seed(act0AchievementSeedFirstReviewHistoryItemV1, sequence: 1),
          ],
        ),
      ),
    );

    final blockText = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('act0_shell_block_summary_earned_moment')),
            matching: find.byType(Text),
          ),
        )
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();

    for (final forbidden in <String>[
      'achievement unlocked',
      'mastered',
      'leak fixed',
      'ai detected',
      'gto',
      'solver',
      'premium',
      'top player',
      'clean mini-drill',
      'lesson complete',
      'resolved',
      'reward',
      'xp',
      'leaderboard',
    ]) {
      expect(blockText, isNot(contains(forbidden)));
    }
  });

  testWidgets('Session Summary level-up card avoids forbidden level copy', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      consumer: const Act0AchievementSeedConsumerV1(),
      errorCount: 0,
      correctCount: 2,
      startXp: 195,
      endXp: 215,
      endLevel: 2,
    );

    expect(
      find.byKey(const Key('act0_shell_block_summary_xp_total')),
      findsOneWidget,
    );
    expect(find.text('Local proof saved'), findsOneWidget);
    expect(find.text('Level 2'), findsNothing);
  });

  testWidgets('Session Summary callbacks remain route-neutral', (tester) async {
    var continued = 0;
    await _pumpSummary(
      tester,
      consumer: Act0AchievementSeedConsumerV1.fromProjection(
        Act0AchievementSeedProjectionV1(
          seeds: <Act0AchievementSeedV1>[
            _seed(act0AchievementSeedFirstSessionCompleteV1, sequence: 1),
          ],
        ),
      ),
      onContinue: () => continued += 1,
      errorCount: 0,
      correctCount: 2,
    );

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(continued, 1);
    expect(find.byType(Act0BlockCompletionShellV1), findsOneWidget);
  });
}

Future<void> _pumpSummary(
  WidgetTester tester, {
  required Act0AchievementSeedConsumerV1 consumer,
  VoidCallback? onContinue,
  int errorCount = 1,
  int correctCount = 1,
  int startXp = 80,
  int endXp = 100,
  int endLevel = 1,
  Act0RepairOutcomeConsumerV1 repairOutcomeConsumer =
      const Act0RepairOutcomeConsumerV1(),
  Act0SessionSummaryEvidenceViewModelV1? evidenceSummary,
  ValueChanged<Act0PracticeRepairQueueLaunchRequestV1>?
  onLaunchPracticeRepairQueueTarget,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0BlockCompletionShellV1(
          summary: Act0BlockCompletionSummaryV1(
            lessonTitle: 'Action words',
            xpEarned: 20,
            errorCount: errorCount,
            taskCount: 2,
            correctCount: correctCount,
            startLevel: 1,
            endLevel: endLevel,
            startXp: startXp,
            endXp: endXp,
            xpTarget: 200,
            nextLessonTitle: 'Blinds and action order',
          ),
          evidenceSummary:
              evidenceSummary ??
              const Act0SessionSummaryEvidenceViewModelV1(
                hasEvidence: true,
                title: 'This run',
                runId: 'run_v1|world_1|fold_check_call_raise|lesson|1',
                runKind: 'lesson',
                spotsLine: 'You played 2 spots.',
                resultLine: '1 correct / 1 to review.',
                repairFocusLine: 'You missed Action reads recently.',
                currentSessionOnly: true,
              ),
          earnedMomentConsumer: consumer,
          repairOutcomeConsumer: repairOutcomeConsumer,
          onLaunchPracticeRepairQueueTarget: onLaunchPracticeRepairQueueTarget,
          onReplay: () {},
          onContinue: onContinue ?? () {},
          onBackToMap: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0AchievementSeedV1 _seed(
  String id, {
  String state = act0AchievementSeedStateEarnedV1,
  bool earned = true,
  int? sequence,
}) {
  return Act0AchievementSeedV1(
    id: id,
    internalTitle: id,
    sourceOwner: 'test_projection',
    state: state,
    earned: earned,
    earnedSequence: sequence,
    sourceSummary: const <String, Object?>{},
    eligibilityState: state,
  );
}

Act0RepairOutcomeProjectionV1 _repairOutcomeProjection({
  required String outcomeState,
}) {
  return Act0RepairOutcomeProjectionV1(
    outcomes: <Act0RepairOutcomeV1>[
      _repairOutcome(outcomeState: outcomeState, sequence: 1),
    ],
  );
}

Act0RepairOutcomeV1 _repairOutcome({
  required String outcomeState,
  required int sequence,
  String queueItemId = 'queue_item',
}) {
  return Act0RepairOutcomeV1(
    sourceTaskId: 'actions_legal_context',
    repairTaskId: 'actions_check_drill',
    repairFocusKey: 'focus_key',
    queueItemId: queueItemId,
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    selectedChoiceId: outcomeState == act0RepairOutcomeStateCorrectV1
        ? 'check'
        : 'fold',
    correctChoiceId: 'check',
    isCorrect: outcomeState == act0RepairOutcomeStateCorrectV1
        ? true
        : outcomeState == act0RepairOutcomeStateStillNeedsRepV1
        ? false
        : null,
    outcomeState: outcomeState,
    sequence: sequence,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
  );
}

bool _containsForbiddenTokenInText(String text, String token) {
  final pattern = RegExp(
    r'(^|[^a-z0-9])' + RegExp.escape(token) + r'([^a-z0-9]|$)',
  );
  return pattern.hasMatch(text.toLowerCase());
}
