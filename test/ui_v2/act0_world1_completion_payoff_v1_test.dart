import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('W1 completion payoff renders only after world completion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Act0BlockCompletionSummaryV1(
          lessonTitle: 'Showdown winning',
          xpEarned: 24,
          errorCount: 0,
          taskCount: 4,
          correctCount: 4,
          startLevel: 1,
          endLevel: 2,
          startXp: 188,
          endXp: 12,
          xpTarget: 200,
          skillGains: <Act0SkillGainV1>[
            Act0SkillGainV1(
              label: 'Hand reading',
              gain: 8,
              source: 'Poker from Zero',
            ),
          ],
          milestoneTier: Act0ProgressMilestoneTierV1.world,
          worldNumber: 1,
          worldTitle: 'Poker from Zero',
          nextWorldNumber: 2,
          nextWorldTitle: 'Hand Discipline',
          perfectClearCount: 12,
          completedClearCount: 12,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_world1_completion_payoff')),
      findsOneWidget,
    );
    expect(find.text('You banked the first table read.'), findsOneWidget);
    expect(
      find.text('First milestone in the 36-world Core Shark Path.'),
      findsOneWidget,
    );
    expect(find.text('Next: Hand Discipline'), findsOneWidget);
    expect(
      find.text(
        'World 2 starts with a simple question: which hands deserve action?',
      ),
      findsOneWidget,
    );
    expect(find.text('Open next world'), findsOneWidget);
    expect(find.textContaining('mastered'), findsNothing);
    expect(find.textContaining('36 worlds unlocked'), findsNothing);
    expect(find.textContaining('pro-level'), findsNothing);
  });

  testWidgets('W1 payoff does not render for unlocked next lesson only', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Act0BlockCompletionSummaryV1(
          lessonTitle: 'Action words',
          xpEarned: 20,
          errorCount: 0,
          taskCount: 4,
          correctCount: 4,
          startLevel: 1,
          endLevel: 1,
          startXp: 40,
          endXp: 60,
          xpTarget: 200,
          nextLessonTitle: 'Blinds & action order',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_world1_completion_payoff')),
      findsNothing,
    );
    expect(find.text('First table read banked.'), findsNothing);
    expect(find.text('Next: Hand Discipline'), findsNothing);
    expect(find.text('Open next lesson'), findsOneWidget);
  });
}

Widget _host(Act0BlockCompletionSummaryV1 summary) {
  return MaterialApp(
    home: Scaffold(
      body: Act0BlockCompletionShellV1(
        summary: summary,
        onReplay: () {},
        onContinue: () {},
        onBackToMap: () {},
      ),
    ),
  );
}
