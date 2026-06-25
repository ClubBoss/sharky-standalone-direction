import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

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
    expect(find.text('Earned moment'), findsOneWidget);
    expect(find.text('Small win Sharky can prove.'), findsOneWidget);
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
            endLevel: 1,
            startXp: 80,
            endXp: 100,
            xpTarget: 200,
            nextLessonTitle: 'Blinds and action order',
          ),
          evidenceSummary: const Act0SessionSummaryEvidenceViewModelV1(
            hasEvidence: true,
            title: 'This run',
            runId: 'run_v1|world_1|fold_check_call_raise|lesson|1',
            runKind: 'lesson',
            spotsLine: 'You played 2 spots.',
            resultLine: '1 correct / 1 to review.',
            repairFocusLine: 'Main repair focus: position clue.',
            currentSessionOnly: true,
          ),
          earnedMomentConsumer: consumer,
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
