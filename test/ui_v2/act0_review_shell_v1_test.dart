import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/services/session_drill_recheck_user_launch_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';

void main() {
  Widget reviewHost(Act0ReviewStateV1 review) {
    return MaterialApp(
      home: Scaffold(
        body: Act0ReviewShellV1(
          review: review,
          selected: null,
          onSelected: (_) {},
          onFixMistake: (_) {},
          onReplayFixedMistake: (_) {},
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

  testWidgets('Review gives an active clue a card-based repair coach entry', (
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
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_review_repair_coach_card')),
      findsOneWidget,
    );
    expect(find.text('Repair coach'), findsOneWidget);
    expect(find.text('No-bet-yet is still the clue to fix.'), findsOneWidget);
    expect(
      find.text('Review why the table was telling you to check.'),
      findsOneWidget,
    );
    expect(find.text('Next repair: one no-bet-yet hand'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_review_fix_next_cta')),
      findsOneWidget,
    );
  });

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
        find.byKey(const Key('act0_shell_review_w6_recheck_queue_card')),
        findsOneWidget,
      );
      expect(find.text('Review the range-bucket mistake'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_review_w6_recheck_cta')),
        findsOneWidget,
      );
      expect(find.text('Repair this clue'), findsNothing);

      await tester.tap(
        find.byKey(const Key('act0_shell_review_w6_recheck_cta')),
      );
      await tester.pumpAndSettle();

      expect(tappedItem, same(w6RecheckItem));
      expect(launched?.sessionId, w6RecheckItem.launchSessionId);
      expect(launched?.initialDrillId, w6RecheckItem.targetDrillId);
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
      find.byKey(const Key('act0_shell_review_w6_recheck_queue_card')),
      findsNothing,
    );
  });

  testWidgets(
    'Review makes a repeated pending pattern actionable without an error log',
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

      expect(find.text('Pattern to repair'), findsOneWidget);
      expect(
        find.text('Action read is showing up 2 times. Fix this pattern first.'),
        findsOneWidget,
      );
      expect(
        tester
            .getTopLeft(find.byKey(const Key('act0_shell_review_pattern_card')))
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const Key('act0_shell_review_repair_coach_card')),
              )
              .dy,
        ),
      );
      expect(find.textContaining('leak'), findsNothing);
    },
  );

  testWidgets('Review keeps recovered mistakes as secondary proof', (
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

    expect(find.text('Repair coach'), findsOneWidget);
    expect(find.text('Recovered lately'), findsOneWidget);
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
    expect(find.text('Recovered lately'), findsOneWidget);
    expect(find.text('Repair coach'), findsNothing);
    expect(find.textContaining('Session proof'), findsNothing);
    expect(find.textContaining('Today you repaired'), findsNothing);
  });
}
