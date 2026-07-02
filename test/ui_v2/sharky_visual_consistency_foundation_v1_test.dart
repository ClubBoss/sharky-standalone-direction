import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

void main() {
  Future<void> pumpCompact(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  Future<void> pumpTall(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  test('shared Sharky corner-radius ratio matches the companion frame', () {
    expect(Act0ShellTokensV1.sharkyTileRadiusRatio, 0.34);
  });

  testWidgets('correct feedback Sharky mascot uses the rounded-square family, not a circle', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Correct.',
            reason: 'Nobody had bet yet - that was the clue.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'Good read.',
            sharkyMood: Act0SharkyMoodV1.happy,
            selectedLabel: 'Check',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            signalProof: const Act0FeedbackSignalProofV1(
              signalId: 'no_bet_yet',
              label: 'No bet yet',
              proofLine: 'Signal: No bet yet',
            ),
            contextLabels: const <String>['No bet yet'],
            onContinue: () {},
          ),
        ),
      ),
    );

    final mascot = find.byKey(const Key('act0_shell_sharky_mascot'));
    expect(mascot, findsOneWidget);

    final decoration = tester
        .widgetList<DecoratedBox>(
          find.descendant(of: mascot, matching: find.byType(DecoratedBox)),
        )
        .first
        .decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.rectangle);
    expect(
      decoration.borderRadius,
      BorderRadius.circular(40 * Act0ShellTokensV1.sharkyTileRadiusRatio),
    );
  });

  testWidgets('wrong repair feedback Sharky mascot uses the rounded-square family, not a circle', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Good spot to fix.',
            reason: 'Checking is better because nobody has bet yet.',
            quality: Act0FeedbackQualityV1.wrong,
            sharkyLine: 'Good spot to fix.',
            sharkyMood: Act0SharkyMoodV1.repair,
            selectedLabel: 'Fold',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            signalProof: const Act0FeedbackSignalProofV1(
              signalId: 'no_bet_yet',
              label: 'No bet yet',
              proofLine: 'Signal: No bet yet',
            ),
            contextLabels: const <String>['No bet yet'],
            onContinue: () {},
          ),
        ),
      ),
    );

    final mascot = find.byKey(const Key('act0_shell_sharky_mascot'));
    expect(mascot, findsOneWidget);

    final decoration = tester
        .widgetList<DecoratedBox>(
          find.descendant(of: mascot, matching: find.byType(DecoratedBox)),
        )
        .first
        .decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.rectangle);
    expect(decoration.borderRadius, isNotNull);
  });

  testWidgets('Home identity avatar uses the rounded-square family, not a circle', (
    tester,
  ) async {
    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0HomeShellV1(
            state: Act0ShellStateV1.sample,
            showChecklist: true,
            nextActionTitle: 'Your first hand, dealt',
            nextActionSubtitle: 'Watch a hand from start to showdown.',
            onContinue: () {},
            onStartDailyDrill: () {},
          ),
        ),
      ),
    );

    final identity = find.byKey(const Key('act0_shell_home_identity_row'));
    expect(identity, findsOneWidget);

    final avatar = tester
        .widgetList<Container>(
          find.descendant(of: identity, matching: find.byType(Container)),
        )
        .first;
    final decoration = avatar.decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.rectangle);
    expect(
      decoration.borderRadius,
      BorderRadius.circular(38 * Act0ShellTokensV1.sharkyTileRadiusRatio),
    );
  });
}
