import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('Play surfaces one featured recommended group first', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0PlayShellV1(
            groups: const <Act0PracticeGroupV1>[
              Act0PracticeGroupV1(
                groupId: 'daily',
                title: '0/3 daily spots',
                subtitle: 'One short set to stay warm.',
                ctaLabel: 'Start',
                categoryLabel: 'Today',
                countLabel: '3 spots',
                sessionLabel: 'Daily set',
                durationLabel: '~3 min',
                isEnabled: true,
              ),
              Act0PracticeGroupV1(
                groupId: 'weak_spots',
                title: 'Repair this spot',
                subtitle: 'Fix the mistake that keeps repeating.',
                ctaLabel: 'Fix',
                categoryLabel: 'Repair',
                countLabel: '1 leak',
                durationLabel: '~3 min',
                isEnabled: true,
              ),
              Act0PracticeGroupV1(
                groupId: 'actions',
                title: 'Actions',
                subtitle: 'One crisp action family.',
                ctaLabel: 'Practice',
                categoryLabel: 'Drill',
                isEnabled: true,
              ),
            ],
            recommendedGroupId: 'daily',
            recommendedTitle: 'Quick daily drill',
            recommendedSubtitle: 'Run three short spots to keep today clean.',
            recommendedReasonLabel: 'Daily set',
            recommendedOutcome: '3 crisp reps, no extra noise.',
            recommendedOutcomeLead: 'Daily set first.',
            masteryLabel: 'Route step',
            onStartGroup: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_play_featured_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_play_featured_cta')),
      findsOneWidget,
    );
    expect(find.text('Quick daily drill'), findsOneWidget);
    expect(find.text('Return loop'), findsOneWidget);
    expect(find.text('Start daily set'), findsOneWidget);
    expect(
      find.textContaining('3 crisp reps, no extra noise.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_practice_group_daily')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_practice_group_weak_spots')),
      findsOneWidget,
    );
    expect(find.text('~3 min'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_actions')),
      180,
    );
    expect(
      find.byKey(const Key('act0_shell_practice_group_actions')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Disabled featured recommendation stays compact and non-duplicated',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0PlayShellV1(
              groups: const <Act0PracticeGroupV1>[
                Act0PracticeGroupV1(
                  groupId: 'actions',
                  title: 'Actions',
                  subtitle: 'One crisp action family.',
                  ctaLabel: 'Practice',
                  categoryLabel: 'Drill',
                  isEnabled: false,
                ),
              ],
              recommendedGroupId: 'actions',
              recommendedTitle: 'Best next action',
              recommendedSubtitle: 'One disabled group for copy truth.',
              recommendedReasonLabel: 'Why this next',
              recommendedOutcome: 'Keeps the route honest.',
              recommendedOutcomeLead: 'This next run',
              masteryLabel: 'Route step',
              onStartGroup: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('act0_shell_play_featured_card')),
        findsOneWidget,
      );
      expect(find.text('Later'), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_play_intro_card')), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_practice_group_actions')),
        findsNothing,
      );
    },
  );
}
