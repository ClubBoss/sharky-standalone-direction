import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';

const _ringKey = Key('act0_shell_sharky_mascot_frame_accent_ring');

void main() {
  group('Session Summary companion state consumer', () {
    testWidgets('ordinary completion with no proof resolves neutral', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _summary(sharkyLine: 'Nice work today.', qualifies: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_sharky_presence_mascot_neutral')),
        findsOneWidget,
      );
      expect(find.byKey(_ringKey), findsNothing);
    });

    testWidgets('needs-repair completion resolves repair (never red)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _summary(sharkyLine: 'Try that again.', qualifies: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_sharky_presence_mascot_repair')),
        findsOneWidget,
      );
      expect(
        act0SharkyToneForMoodV1(Act0SharkyMoodV1.repair),
        isNot(Colors.red),
      );
      expect(act0SharkyToneForMoodV1(Act0SharkyMoodV1.repair), Act0ShellTokensV1.gold);
    });

    testWidgets('banked fix proof (no improvement) resolves confirm', (
      tester,
    ) async {
      const receipt = Act0RepairOutcomeSessionReceiptV1(
        title: "Fixes you've banked",
        lines: <String>['1 repair completed'],
        isBankedFixProof: true,
      );
      await tester.pumpWidget(
        _host(
          _summary(sharkyLine: 'One clean fix.', qualifies: true),
          repairOutcomeConsumer: const Act0RepairOutcomeConsumerV1(
            sessionReceipt: receipt,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_sharky_presence_mascot_happy')),
        findsOneWidget,
      );
      expect(find.byKey(_ringKey), findsNothing);
    });

    testWidgets(
      'banked fix proof with a later-improvement observation resolves '
      'improve with the accent ring',
      (tester) async {
        const receipt = Act0RepairOutcomeSessionReceiptV1(
          title: "Fixes you've banked",
          lines: <String>['1 repair completed'],
          isBankedFixProof: true,
          hasImprovementObservation: true,
        );
        await tester.pumpWidget(
          _host(
            _summary(sharkyLine: 'One clean fix.', qualifies: true),
            repairOutcomeConsumer: const Act0RepairOutcomeConsumerV1(
              sessionReceipt: receipt,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('act0_shell_sharky_presence_mascot_happy')),
          findsOneWidget,
        );
        expect(find.byKey(_ringKey), findsOneWidget);
      },
    );

    testWidgets(
      'world completion resolves milestone with the strongest accent ring, '
      'not activity alone',
      (tester) async {
        await tester.pumpWidget(
          _host(
            _summary(
              sharkyLine: 'World done.',
              qualifies: true,
              worldNumber: 1,
              nextWorldNumber: 2,
              nextWorldTitle: 'Hand Discipline',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('act0_shell_sharky_presence_mascot_celebrate')),
          findsOneWidget,
        );
        expect(find.byKey(_ringKey), findsOneWidget);
      },
    );

    testWidgets(
      'exactly one Sharky presence instance renders per Session Summary screen',
      (tester) async {
        await tester.pumpWidget(
          _host(
            _summary(
              sharkyLine: 'World done.',
              qualifies: true,
              worldNumber: 1,
              nextWorldNumber: 2,
              nextWorldTitle: 'Hand Discipline',
            ),
          ),
        );
        await tester.pumpAndSettle();

        var mascotCount = 0;
        for (final mood in Act0SharkyMoodV1.values) {
          mascotCount += tester
              .widgetList(
                find.byKey(
                  Key('act0_shell_sharky_presence_mascot_${mood.name}'),
                ),
              )
              .length;
        }
        expect(mascotCount, 1);
      },
    );

    testWidgets('primary CTA callback is preserved', (tester) async {
      var continued = 0;
      await tester.pumpWidget(
        _host(
          _summary(sharkyLine: 'Nice work today.', qualifies: true),
          onContinue: () => continued += 1,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_block_summary_continue_cta')),
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_block_summary_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(continued, 1);
    });

    testWidgets('compact layout with the accent ring has no overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _host(
          _summary(
            sharkyLine: 'World done.',
            qualifies: true,
            worldNumber: 1,
            nextWorldNumber: 2,
            nextWorldTitle: 'Hand Discipline',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('no XP/level/rank/mood-label language appears', (
      tester,
    ) async {
      const receipt = Act0RepairOutcomeSessionReceiptV1(
        title: "Fixes you've banked",
        lines: <String>['1 repair completed'],
        isBankedFixProof: true,
        hasImprovementObservation: true,
      );
      await tester.pumpWidget(
        _host(
          _summary(sharkyLine: 'One clean fix.', qualifies: true),
          repairOutcomeConsumer: const Act0RepairOutcomeConsumerV1(
            sessionReceipt: receipt,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
          .join(' ')
          .toLowerCase();

      for (final forbidden in <String>[
        'xp',
        'level',
        'rank',
        'rarity',
        'mood:',
        'happy state',
        'sad',
        'angry',
      ]) {
        expect(text, isNot(contains(forbidden)));
      }
    });
  });

  group('Welcome companion state consumer', () {
    testWidgets('intro/orientation beat resolves neutral', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0WelcomeShellV1(replayMode: false, onCompleted: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_sharky_presence_mascot_neutral')),
        findsOneWidget,
      );
    });

    testWidgets('Welcome primary CTA still routes to the demo spot', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0WelcomeShellV1(replayMode: false, onCompleted: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_welcome_demo_spot')), findsOneWidget);
    });
  });

  group('Companion-state visual grammar', () {
    test('milestone/improve are the only ring-earning states', () {
      for (final state in Act0SharkyCompanionStateV1.values) {
        final expectRing =
            state == Act0SharkyCompanionStateV1.improve ||
            state == Act0SharkyCompanionStateV1.milestone;
        expect(act0SharkyCompanionStateHasAccentRingV1(state), expectRing);
      }
    });

    test('no companion state maps to a new/unapproved asset mood', () {
      for (final state in Act0SharkyCompanionStateV1.values) {
        final mood = act0SharkyMoodForCompanionStateV1(state);
        expect(Act0SharkyMoodV1.values, contains(mood));
      }
    });
  });
}

Act0BlockCompletionSummaryV1 _summary({
  required String sharkyLine,
  required bool qualifies,
  int worldNumber = 0,
  String worldTitle = '',
  int? nextWorldNumber,
  String? nextWorldTitle,
}) {
  return Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson',
    xpEarned: 20,
    errorCount: qualifies ? 0 : 3,
    taskCount: 4,
    correctCount: qualifies ? 4 : 1,
    startLevel: 1,
    endLevel: 1,
    startXp: 40,
    endXp: 60,
    xpTarget: 200,
    sharkyLine: sharkyLine,
    nextLessonTitle: worldNumber > 0 ? null : 'Next lesson in this world',
    milestoneTier: worldNumber > 0
        ? Act0ProgressMilestoneTierV1.world
        : Act0ProgressMilestoneTierV1.lesson,
    worldNumber: worldNumber,
    worldTitle: worldNumber > 0 ? (worldTitle.isEmpty ? 'World' : worldTitle) : '',
    nextWorldNumber: nextWorldNumber,
    nextWorldTitle: nextWorldTitle,
    perfectClearCount: worldNumber > 0 ? 9 : 0,
    completedClearCount: worldNumber > 0 ? 9 : 0,
  );
}

Widget _host(
  Act0BlockCompletionSummaryV1 summary, {
  Act0RepairOutcomeConsumerV1 repairOutcomeConsumer =
      const Act0RepairOutcomeConsumerV1(),
  VoidCallback? onContinue,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Act0BlockCompletionShellV1(
        summary: summary,
        repairOutcomeConsumer: repairOutcomeConsumer,
        onReplay: () {},
        onContinue: onContinue ?? () {},
        onBackToMap: () {},
      ),
    ),
  );
}
