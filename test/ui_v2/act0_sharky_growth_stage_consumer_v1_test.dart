import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';

const _stateRingKey = Key('act0_shell_sharky_mascot_frame_accent_ring');
const _growthRingKey = Key('act0_shell_sharky_mascot_frame_growth_ring');

void main() {
  group('Session Summary growth-stage admission', () {
    testWidgets('Foundation world (2) shows no growth ring', (tester) async {
      await tester.pumpWidget(_host(_summary(worldNumber: 2, sharkyLine: 'x')));
      await tester.pumpAndSettle();

      expect(find.byKey(_growthRingKey), findsNothing);
    });

    testWidgets('Developing world (5) shows the growth ring', (tester) async {
      await tester.pumpWidget(_host(_summary(worldNumber: 5, sharkyLine: 'x')));
      await tester.pumpAndSettle();

      expect(find.byKey(_growthRingKey), findsOneWidget);
    });

    testWidgets('proof count alone does not change growth stage', (
      tester,
    ) async {
      const bankedReceipt = Act0RepairOutcomeSessionReceiptV1(
        title: "Fixes you've banked",
        lines: <String>['1 repair completed'],
        isBankedFixProof: true,
      );

      await tester.pumpWidget(
        _host(
          _summary(worldNumber: 5, sharkyLine: 'x'),
          repairOutcomeConsumer: const Act0RepairOutcomeConsumerV1(
            sessionReceipt: bankedReceipt,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(_growthRingKey), findsOneWidget);

      await tester.pumpWidget(_host(_summary(worldNumber: 5, sharkyLine: 'x')));
      await tester.pumpAndSettle();
      expect(find.byKey(_growthRingKey), findsOneWidget);
    });

    testWidgets('companion state alone does not change growth stage', (
      tester,
    ) async {
      // repair-flavored (fails accuracy gate)
      await tester.pumpWidget(
        _host(_summary(worldNumber: 5, sharkyLine: 'x', qualifies: false)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(_growthRingKey), findsOneWidget);

      // confirm-flavored (banked proof)
      const bankedReceipt = Act0RepairOutcomeSessionReceiptV1(
        title: "Fixes you've banked",
        lines: <String>['1 repair completed'],
        isBankedFixProof: true,
      );
      await tester.pumpWidget(
        _host(
          _summary(worldNumber: 5, sharkyLine: 'x'),
          repairOutcomeConsumer: const Act0RepairOutcomeConsumerV1(
            sessionReceipt: bankedReceipt,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(_growthRingKey), findsOneWidget);
    });

    testWidgets(
      'completion alone does not change growth stage: W4->W5 milestone '
      'still resolves Foundation growth',
      (tester) async {
        await tester.pumpWidget(
          _host(
            Act0BlockCompletionSummaryV1(
              lessonTitle: 'A lesson',
              xpEarned: 24,
              errorCount: 0,
              taskCount: 4,
              correctCount: 4,
              startLevel: 1,
              endLevel: 2,
              startXp: 188,
              endXp: 12,
              xpTarget: 200,
              sharkyLine: 'World done.',
              milestoneTier: Act0ProgressMilestoneTierV1.world,
              worldNumber: 4,
              worldTitle: 'Bet Purpose / Price',
              nextWorldNumber: 5,
              nextWorldTitle: 'Board Awareness',
              perfectClearCount: 12,
              completedClearCount: 12,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Milestone companion state is present (state ring), but growth
        // stage stays Foundation because world 4 is still below the W4->W5
        // boundary.
        expect(find.byKey(_stateRingKey), findsOneWidget);
        expect(find.byKey(_growthRingKey), findsNothing);
      },
    );

    testWidgets('same repair state composes with both growth stages', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(_summary(worldNumber: 3, sharkyLine: 'x', qualifies: false)),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(
          const Key('act0_shell_sharky_presence_mascot_repair'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(_growthRingKey), findsNothing);

      await tester.pumpWidget(
        _host(_summary(worldNumber: 6, sharkyLine: 'x', qualifies: false)),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(
          const Key('act0_shell_sharky_presence_mascot_repair'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(_growthRingKey), findsOneWidget);
    });

    testWidgets('same improve state composes with both growth stages', (
      tester,
    ) async {
      const improveReceipt = Act0RepairOutcomeSessionReceiptV1(
        title: "Fixes you've banked",
        lines: <String>['1 repair completed'],
        isBankedFixProof: true,
        hasImprovementObservation: true,
      );

      await tester.pumpWidget(
        _host(
          _summary(worldNumber: 2, sharkyLine: 'x'),
          repairOutcomeConsumer: const Act0RepairOutcomeConsumerV1(
            sessionReceipt: improveReceipt,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(_stateRingKey), findsOneWidget);
      expect(find.byKey(_growthRingKey), findsNothing);

      await tester.pumpWidget(
        _host(
          _summary(worldNumber: 7, sharkyLine: 'x'),
          repairOutcomeConsumer: const Act0RepairOutcomeConsumerV1(
            sessionReceipt: improveReceipt,
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Both rings compose: the improve state ring plus the Developing
      // growth ring, nested.
      expect(find.byKey(_stateRingKey), findsOneWidget);
      expect(find.byKey(_growthRingKey), findsOneWidget);
    });

    testWidgets('primary CTA callback is preserved with Developing growth', (
      tester,
    ) async {
      var continued = 0;
      await tester.pumpWidget(
        _host(
          _summary(worldNumber: 6, sharkyLine: 'x'),
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

    testWidgets('compact layout with growth ring + state ring has no overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const improveReceipt = Act0RepairOutcomeSessionReceiptV1(
        title: "Fixes you've banked",
        lines: <String>['1 repair completed'],
        isBankedFixProof: true,
        hasImprovementObservation: true,
      );
      await tester.pumpWidget(
        _host(
          _summary(worldNumber: 8, sharkyLine: 'x'),
          repairOutcomeConsumer: const Act0RepairOutcomeConsumerV1(
            sessionReceipt: improveReceipt,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('no XP/level/rank/rarity language appears', (tester) async {
      await tester.pumpWidget(_host(_summary(worldNumber: 6, sharkyLine: 'x')));
      await tester.pumpAndSettle();

      final text = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
          .join(' ')
          .toLowerCase();

      for (final forbidden in <String>[
        'xp',
        'level up',
        'leveled up',
        'rank',
        'rarity',
        'evolved',
        'evolution',
      ]) {
        expect(text, isNot(contains(forbidden)));
      }
    });
  });

  group('Foundation vs Developing structural distinction', () {
    testWidgets(
      'Developing differs from Foundation via at least two structural '
      'signals, not color alone',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Act0SharkyCompanionAvatarV1(
                state: Act0SharkyCompanionStateV1.neutral,
                growthStage: Act0SharkyGrowthStageV1.foundation,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final foundationContainer = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(Act0SharkyCompanionAvatarV1),
                matching: find.byType(Container),
              ),
            )
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .firstWhere((d) => d.border != null && d.boxShadow != null);
        final foundationBorderWidth = foundationContainer.border!.top.width;
        final foundationShadowBlur =
            foundationContainer.boxShadow!.first.blurRadius;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Act0SharkyCompanionAvatarV1(
                state: Act0SharkyCompanionStateV1.neutral,
                growthStage: Act0SharkyGrowthStageV1.developing,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Signal 1: the growth ring is a structural extra layer.
        expect(find.byKey(_growthRingKey), findsOneWidget);

        final developingContainer = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(Act0SharkyCompanionAvatarV1),
                matching: find.byType(Container),
              ),
            )
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .firstWhere((d) => d.border != null && d.boxShadow != null);
        final developingBorderWidth = developingContainer.border!.top.width;
        final developingShadowBlur =
            developingContainer.boxShadow!.first.blurRadius;

        // Signal 2: border width increases (structure, not just color).
        expect(developingBorderWidth, greaterThan(foundationBorderWidth));
        // Signal 3 (bonus): shadow depth also increases.
        expect(developingShadowBlur, greaterThan(foundationShadowBlur));
      },
    );
  });

  group('Welcome growth-stage admission', () {
    testWidgets('Welcome intro always renders Foundation growth', (
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

      expect(find.byKey(_growthRingKey), findsNothing);
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

    testWidgets('GuideCard forwards Developing growth in row layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 520,
              child: Act0SharkyGuideCardV1(
                eyebrow: 'SHARKY',
                line: 'Read the full signal before acting.',
                mood: Act0SharkyMoodV1.neutral,
                growthStage: Act0SharkyGrowthStageV1.developing,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(_growthRingKey), findsOneWidget);
    });
  });

  group('Shared component API stays bounded', () {
    test(
      'Act0SharkyCompanionAvatarV1 exposes no mood/level/rank/xp/rarity/'
      'random-seed parameter',
      () {
        final source = File(
          'lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart',
        ).readAsStringSync();
        final start = source.indexOf('class Act0SharkyCompanionAvatarV1');
        expect(start, greaterThan(-1));
        final end = source.indexOf('\nclass ', start + 1);
        final classBody = source.substring(
          start,
          end == -1 ? source.length : end,
        );

        expect(classBody, isNot(contains('required this.mood')));
        for (final forbidden in <String>[
          'level',
          'rank',
          'xp',
          'rarity',
          'randomSeed',
          'seed',
          'Colors.',
        ]) {
          expect(
            classBody,
            isNot(contains(forbidden)),
            reason: 'shared avatar API must not expose "$forbidden"',
          );
        }
      },
    );
  });
}

Act0BlockCompletionSummaryV1 _summary({
  required int worldNumber,
  required String sharkyLine,
  bool qualifies = true,
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
    nextLessonTitle: 'Next lesson in this world',
    worldNumber: worldNumber,
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
