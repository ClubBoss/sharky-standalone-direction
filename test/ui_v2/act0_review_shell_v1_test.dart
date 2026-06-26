import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/services/session_drill_recheck_user_launch_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';

void main() {
  Widget reviewHost(
    Act0ReviewStateV1 review, {
    List<Act0ReviewMistakeHistoryItemV1> historyItems =
        const <Act0ReviewMistakeHistoryItemV1>[],
    ValueChanged<Act0MistakeCardV1>? onFixMistake,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Act0ReviewShellV1(
          review: review,
          selected: null,
          onSelected: (_) {},
          onFixMistake: onFixMistake ?? (_) {},
          onReplayFixedMistake: (_) {},
          mistakeHistoryItems: historyItems,
        ),
      ),
    );
  }

  const activeMistake = Act0MistakeCardV1(
    taskId: 'actions_check_drill',
    lessonId: 'fold_check_call_raise',
    title: 'No bet yet',
    weaknessLabel: 'Action read',
    selectedOptionId: 'bet',
    selectedLabel: 'Bet',
    betterLabel: 'Check',
    reason: 'Nobody had bet, so checking kept the action honest.',
    attempts: 2,
    repairActionLabel: 'Review why the table was telling you to check.',
  );

  const recoveredMistake = Act0MistakeCardV1(
    taskId: 'actions_check_replay',
    lessonId: 'fold_check_call_raise',
    title: 'No bet yet',
    weaknessLabel: 'Action read',
    selectedOptionId: 'check',
    selectedLabel: 'Check',
    betterLabel: 'Check',
    reason: 'You caught the missing bet before acting.',
    attempts: 1,
  );

  const w6RecheckItem = SessionDrillRecheckLaunchQueueItemV1(
    queueKind: 'session_drill_recheck',
    jobId: 'session_drill_recheck:w6.s01:classify_missed_fold_recheck',
    launchSessionId: 'w6.s01',
    sourceWorldId: 'world_6',
    sourceSessionId: 'w6.s01',
    sourceDrillId: 'classify_missed_fold',
    drillFamilyId: 'range_bucket_classifier_v1',
    missedSignalId: 'range_bucket_missed',
    missedSignalLabel: 'Missed range bucket',
    chosenActionId: 'raise',
    expectedActionId: 'fold',
    targetSessionId: 'w6.s01',
    targetDrillId: 'classify_missed_fold_recheck',
    targetKind: 'same_signal_recheck',
    errorClass: 'expected_action_mismatch',
  );

  const boardTextureRecheckItem = SessionDrillRecheckLaunchQueueItemV1(
    queueKind: 'session_drill_recheck',
    jobId: 'session_drill_recheck:w5.s01:classify_texture_intro_dry_raise_v1',
    launchSessionId: 'w5.s01',
    sourceWorldId: 'world_5',
    sourceSessionId: 'w5.s01',
    sourceDrillId: 'classify_texture_intro_dry_raise_v1',
    drillFamilyId: 'board_texture_classifier_v1',
    missedSignalId: 'board_texture_dry',
    missedSignalLabel: 'Dry board texture',
    chosenActionId: 'fold',
    expectedActionId: 'raise',
    targetSessionId: 'w5.s01',
    targetDrillId: 'classify_texture_intro_dry_raise_v1',
    targetKind: 'exact_replay',
    errorClass: 'expected_action_mismatch',
  );

  const readOnlyHistoryItem = Act0ReviewMistakeHistoryItemV1(
    stableKey: 'history-1',
    sourceTaskId: 'actions_legal_context',
    primaryLabel: 'Action read',
    detailLine: 'Missed action read',
    decisionLine: 'You chose fold; better was check.',
    contextLine: 'fold check call raise',
    orderLabel: 'Most recent',
  );

  testWidgets(
    'Review keeps one compact active repair note without a Home redirect',
    (tester) async {
      await tester.pumpWidget(
        reviewHost(
          const Act0ReviewStateV1(
            title: 'Review',
            subtitle: 'Repair the clue that slipped.',
            weaknessLabel: 'Action read',
            reason: '',
            stats: <Act0ReviewStatV1>[],
            chosenLabel: 'Bet',
            betterLabel: 'Check',
            mistakes: <Act0MistakeCardV1>[activeMistake],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_review_repair_coach_card')),
        findsOneWidget,
      );
      expect(find.text('Active repair'), findsOneWidget);
      expect(find.text('What to fix next'), findsOneWidget);
      expect(find.text('Active repair note'), findsNothing);
      expect(find.text('Your active repair is waiting on Home.'), findsNothing);
      expect(find.text('1 fix waiting'), findsNothing);
      expect(
        find.text('The no-bet-yet clue is still the one to fix.'),
        findsOneWidget,
      );
      expect(find.text('Pattern to practice'), findsOneWidget);
      expect(find.text('You are working on No bet yet.'), findsOneWidget);
      expect(
        find.text('Next rep: spot the clue before choosing.'),
        findsOneWidget,
      );
      expect(
        find.text('Review why the table was telling you to check.'),
        findsOneWidget,
      );
      expect(
        find.text('Keep this clue in view before your next hand.'),
        findsOneWidget,
      );
      expect(find.text('This is the spot to clean up.'), findsOneWidget);
      expect(find.textContaining('Home'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_review_practice_cta')),
        findsOneWidget,
      );
      expect(find.text('Practice this spot'), findsOneWidget);
      expect(find.text('Repair this clue'), findsNothing);
    },
  );

  testWidgets('Review practice CTA uses existing active repair callback', (
    tester,
  ) async {
    Act0MistakeCardV1? tappedMistake;
    await tester.pumpWidget(
      reviewHost(
        const Act0ReviewStateV1(
          title: 'Review',
          subtitle: 'Repair the clue that slipped.',
          weaknessLabel: 'Action read',
          reason: '',
          stats: <Act0ReviewStatV1>[],
          chosenLabel: 'Bet',
          betterLabel: 'Check',
          mistakes: <Act0MistakeCardV1>[activeMistake],
        ),
        onFixMistake: (mistake) {
          tappedMistake = mistake;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_review_practice_cta')));
    await tester.pumpAndSettle();

    expect(tappedMistake, activeMistake);
    expect(find.text('What to fix next'), findsOneWidget);
    expect(find.text('Pattern to practice'), findsOneWidget);
    expect(find.text('This is the spot to clean up.'), findsOneWidget);
    expect(find.text('Practice this spot'), findsOneWidget);
    expect(find.textContaining('Fixed'), findsNothing);
    expect(find.textContaining('Cleared'), findsNothing);
    expect(find.textContaining('Resolved'), findsNothing);
    expect(find.textContaining('Recovered'), findsNothing);
    expect(find.textContaining('AI'), findsNothing);
    expect(find.textContaining('GTO'), findsNothing);
    expect(find.textContaining('solver'), findsNothing);
    expect(find.textContaining('premium'), findsNothing);
    expect(find.textContaining('Level'), findsNothing);
    expect(find.textContaining('Radar'), findsNothing);
    expect(find.textContaining('rating'), findsNothing);
    expect(find.textContaining('master'), findsNothing);
    expect(find.textContaining('all-time'), findsNothing);
  });

  testWidgets(
    'Review active repair remains passive when no launch callback exists',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0ReviewShellV1(
              review: const Act0ReviewStateV1(
                title: 'Review',
                subtitle: 'Repair the clue that slipped.',
                weaknessLabel: 'Action read',
                reason: '',
                stats: <Act0ReviewStatV1>[],
                chosenLabel: 'Bet',
                betterLabel: 'Check',
                mistakes: <Act0MistakeCardV1>[activeMistake],
              ),
              selected: null,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_review_repair_coach_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_review_practice_cta')),
        findsNothing,
      );
      expect(find.text('Pattern to practice'), findsOneWidget);
    },
  );

  testWidgets(
    'Review shows W6 recheck queue card only for real session-drill queue item',
    (tester) async {
      BuildContext? hostContext;
      SessionDrillRecheckLaunchQueueItemV1? tappedItem;
      CanonicalLauncherV1? launched;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              hostContext = context;
              return Scaffold(
                body: Act0ReviewShellV1(
                  review: const Act0ReviewStateV1(
                    title: 'Review',
                    subtitle: 'Confidence repair board',
                    weaknessLabel: 'Range bucket',
                    reason: '',
                    stats: <Act0ReviewStatV1>[],
                    chosenLabel: 'Raise',
                    betterLabel: 'Fold',
                  ),
                  selected: null,
                  onSelected: (_) {},
                  sessionDrillRecheckQueueItems:
                      const <SessionDrillRecheckLaunchQueueItemV1>[
                        w6RecheckItem,
                      ],
                  onStartSessionDrillRecheck: (item) {
                    tappedItem = item;
                    final route =
                        sessionDrillRecheckLaunchRouteV1(item)
                            as MaterialPageRoute<void>;
                    launched =
                        route.builder(hostContext!) as CanonicalLauncherV1;
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_review_recheck_queue_card')),
        findsOneWidget,
      );
      expect(find.text('Review this practice mistake'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_review_recheck_cta')),
        findsOneWidget,
      );
      expect(find.text('Repair this clue'), findsNothing);

      await tester.tap(find.byKey(const Key('act0_shell_review_recheck_cta')));
      await tester.pumpAndSettle();

      expect(tappedItem, same(w6RecheckItem));
      expect(launched?.sessionId, w6RecheckItem.launchSessionId);
      expect(launched?.initialDrillId, w6RecheckItem.targetDrillId);
      expect(launched?.isRecheckLaunchV1, isTrue);
    },
  );

  testWidgets(
    'Review shows board texture recheck queue item through the same card',
    (tester) async {
      BuildContext? hostContext;
      SessionDrillRecheckLaunchQueueItemV1? tappedItem;
      CanonicalLauncherV1? launched;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              hostContext = context;
              return Scaffold(
                body: Act0ReviewShellV1(
                  review: const Act0ReviewStateV1(
                    title: 'Review',
                    subtitle: 'Confidence repair board',
                    weaknessLabel: 'Board texture',
                    reason: '',
                    stats: <Act0ReviewStatV1>[],
                    chosenLabel: 'Fold',
                    betterLabel: 'Raise',
                  ),
                  selected: null,
                  onSelected: (_) {},
                  sessionDrillRecheckQueueItems:
                      const <SessionDrillRecheckLaunchQueueItemV1>[
                        boardTextureRecheckItem,
                      ],
                  onStartSessionDrillRecheck: (item) {
                    tappedItem = item;
                    final route =
                        sessionDrillRecheckLaunchRouteV1(item)
                            as MaterialPageRoute<void>;
                    launched =
                        route.builder(hostContext!) as CanonicalLauncherV1;
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_review_recheck_queue_card')),
        findsOneWidget,
      );
      expect(find.text('Review this practice mistake'), findsOneWidget);
      expect(
        find.text(
          'Dry board texture: you chose fold; try the raise line again.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_review_recheck_cta')),
        findsOneWidget,
      );
      expect(find.text('Repair this clue'), findsNothing);

      await tester.tap(find.byKey(const Key('act0_shell_review_recheck_cta')));
      await tester.pumpAndSettle();

      expect(tappedItem, same(boardTextureRecheckItem));
      expect(launched?.sessionId, boardTextureRecheckItem.launchSessionId);
      expect(launched?.initialDrillId, boardTextureRecheckItem.targetDrillId);
      expect(launched?.isRecheckLaunchV1, isTrue);
    },
  );

  testWidgets('Review hides W6 recheck queue card when no queue item exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      reviewHost(
        const Act0ReviewStateV1(
          title: 'Review',
          subtitle: 'Confidence repair board',
          weaknessLabel: 'Range bucket',
          reason: '',
          stats: <Act0ReviewStatV1>[],
          chosenLabel: 'Raise',
          betterLabel: 'Fold',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_review_recheck_queue_card')),
      findsNothing,
    );
  });

  testWidgets(
    'Review does not turn pending repairs into grouped history or counts',
    (tester) async {
      await tester.pumpWidget(
        reviewHost(
          const Act0ReviewStateV1(
            title: 'Review',
            subtitle: 'Repair the clue that slipped.',
            weaknessLabel: 'Action read',
            reason: '',
            stats: <Act0ReviewStatV1>[],
            chosenLabel: 'Bet',
            betterLabel: 'Check',
            mistakes: <Act0MistakeCardV1>[
              activeMistake,
              Act0MistakeCardV1(
                taskId: 'actions_check_drill_2',
                lessonId: 'fold_check_call_raise',
                title: 'No bet yet',
                weaknessLabel: 'Action read',
                selectedOptionId: 'bet',
                selectedLabel: 'Bet',
                betterLabel: 'Check',
                reason: 'Check when nobody has bet yet.',
                attempts: 2,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_review_pattern_card')),
        findsNothing,
      );
      expect(find.textContaining('showing up 2 times'), findsNothing);
      expect(find.textContaining('next spot gets easier'), findsNothing);
      expect(find.textContaining('leak'), findsNothing);
    },
  );

  testWidgets('Review hides pattern coaching without active repair evidence', (
    tester,
  ) async {
    await tester.pumpWidget(
      reviewHost(
        const Act0ReviewStateV1(
          title: 'Review',
          subtitle: 'Repair the clue that slipped.',
          weaknessLabel: 'Action read',
          reason: '',
          stats: <Act0ReviewStatV1>[],
          chosenLabel: 'Bet',
          betterLabel: 'Check',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No misses saved yet'), findsOneWidget);
    expect(find.text('Pattern to practice'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_review_pattern_focus_line')),
      findsNothing,
    );
  });

  testWidgets('Review keeps past repair notes as secondary proof', (
    tester,
  ) async {
    await tester.pumpWidget(
      reviewHost(
        const Act0ReviewStateV1(
          title: 'Review',
          subtitle: 'Repair the clue that slipped.',
          weaknessLabel: 'Action read',
          reason: '',
          stats: <Act0ReviewStatV1>[],
          chosenLabel: 'Bet',
          betterLabel: 'Check',
          mistakes: <Act0MistakeCardV1>[activeMistake],
          fixedMistakes: <Act0MistakeCardV1>[recoveredMistake],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Active repair'), findsOneWidget);
    expect(find.text('What to fix next'), findsOneWidget);
    expect(find.text('Active repair note'), findsNothing);
    expect(find.text('Worth replaying'), findsOneWidget);
    expect(find.textContaining('Recovered'), findsNothing);
    expect(find.textContaining('Fixed'), findsNothing);
    expect(find.textContaining('Cleared'), findsNothing);
    expect(find.textContaining('Resolved'), findsNothing);
    expect(find.textContaining('mastered forever'), findsNothing);
  });

  testWidgets('Review has a calm no-repair fallback without session ceremony', (
    tester,
  ) async {
    await tester.pumpWidget(
      reviewHost(
        const Act0ReviewStateV1(
          title: 'Review',
          subtitle: 'Repair the clue that slipped.',
          weaknessLabel: 'Action read',
          reason: '',
          stats: <Act0ReviewStatV1>[],
          chosenLabel: 'Bet',
          betterLabel: 'Check',
          fixedMistakes: <Act0MistakeCardV1>[recoveredMistake],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clean board'), findsOneWidget);
    expect(find.text('Worth replaying'), findsOneWidget);
    expect(find.textContaining('Recovered'), findsNothing);
    expect(find.textContaining('Fixed'), findsNothing);
    expect(find.textContaining('Cleared'), findsNothing);
    expect(find.textContaining('Resolved'), findsNothing);
    expect(find.text('Repair coach'), findsNothing);
    expect(find.textContaining('Session proof'), findsNothing);
    expect(find.textContaining('Today you repaired'), findsNothing);
  });

  testWidgets('Review shows an honest empty state without fake past spots', (
    tester,
  ) async {
    await tester.pumpWidget(
      reviewHost(
        const Act0ReviewStateV1(
          title: 'Review',
          subtitle: 'Confidence repair board',
          weaknessLabel: 'Action read',
          reason: '',
          stats: <Act0ReviewStatV1>[],
          chosenLabel: 'Bet',
          betterLabel: 'Check',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No misses saved yet'), findsOneWidget);
    expect(
      find.text(
        'Useful misses will appear here after a hand is worth repeating.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Fixed'), findsNothing);
    expect(find.textContaining('Recovered'), findsNothing);
    expect(find.textContaining('Cleared'), findsNothing);
    expect(find.textContaining('Resolved'), findsNothing);
    expect(find.textContaining('mistake history'), findsNothing);
    expect(find.textContaining('personalized'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_review_fix_next_cta')),
      findsNothing,
    );
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('Review renders persisted mistake history as read-only notes', (
    tester,
  ) async {
    await tester.pumpWidget(
      reviewHost(
        const Act0ReviewStateV1(
          title: 'Review',
          subtitle: 'Confidence repair board',
          weaknessLabel: 'Action read',
          reason: '',
          stats: <Act0ReviewStatV1>[],
          chosenLabel: 'Fold',
          betterLabel: 'Check',
        ),
        historyItems: const <Act0ReviewMistakeHistoryItemV1>[
          readOnlyHistoryItem,
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_review_mistake_history_list')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_review_mistake_history_row_history-1')),
      findsOneWidget,
    );
    expect(find.text('Past spots to review'), findsWidgets);
    expect(find.text('Action read'), findsOneWidget);
    expect(find.text('Missed action read'), findsOneWidget);
    expect(find.text('You chose fold; better was check.'), findsOneWidget);
    expect(find.text('fold check call raise'), findsOneWidget);
    expect(find.text('Most recent'), findsOneWidget);
    expect(find.text('No misses saved yet'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_review_fix_next_cta')),
      findsNothing,
    );
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets(
    'Read-only history rows contain no forbidden controls or claims',
    (tester) async {
      await tester.pumpWidget(
        reviewHost(
          const Act0ReviewStateV1(
            title: 'Review',
            subtitle: 'Confidence repair board',
            weaknessLabel: 'Action read',
            reason: '',
            stats: <Act0ReviewStatV1>[],
            chosenLabel: 'Fold',
            betterLabel: 'Check',
          ),
          historyItems: const <Act0ReviewMistakeHistoryItemV1>[
            readOnlyHistoryItem,
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Clear'), findsNothing);
      expect(find.textContaining('clear'), findsNothing);
      expect(find.textContaining('Fix'), findsNothing);
      expect(find.textContaining('fix'), findsNothing);
      expect(find.textContaining('Resolved'), findsNothing);
      expect(find.textContaining('resolved'), findsNothing);
      expect(find.textContaining('mastery'), findsNothing);
      expect(find.textContaining('leak'), findsNothing);
      expect(find.textContaining('AI'), findsNothing);
      expect(find.textContaining('GTO'), findsNothing);
      expect(find.textContaining('solver'), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    },
  );

  testWidgets('What to fix next stays separate from read-only history', (
    tester,
  ) async {
    await tester.pumpWidget(
      reviewHost(
        const Act0ReviewStateV1(
          title: 'Review',
          subtitle: 'Repair the clue that slipped.',
          weaknessLabel: 'Action read',
          reason: '',
          stats: <Act0ReviewStatV1>[],
          chosenLabel: 'Bet',
          betterLabel: 'Check',
          mistakes: <Act0MistakeCardV1>[activeMistake],
        ),
        historyItems: const <Act0ReviewMistakeHistoryItemV1>[
          readOnlyHistoryItem,
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('What to fix next'), findsOneWidget);
    expect(find.text('Active repair note'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_review_mistake_history_list')),
      findsOneWidget,
    );
    expect(find.text('Action read'), findsOneWidget);
    expect(find.text('Repair this clue'), findsNothing);
    expect(find.text('Your active repair is waiting on Home.'), findsNothing);
  });
}
