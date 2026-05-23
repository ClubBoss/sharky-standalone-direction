import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets(
    'Practice surfaces one featured recommended group with purpose and payoff first',
    (tester) async {
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
              recommendedReasonLabel: 'Today\'s reps',
              recommendedOutcome:
                  'three short spots keep the current route sharp without opening a full lesson.',
              recommendedOutcomeLead: 'Sharpens today:',
              masteryLabel: 'Today\'s reps',
              screenSubtitle:
                  'Short reps keep today\'s skill sharp. Learn adds new ideas. Review fixes misses.',
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
      expect(find.text('Practice'), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_play_subtitle')), findsOneWidget);
      expect(
        find.text(
          'Short reps keep today\'s skill sharp. Learn adds new ideas. Review fixes misses.',
        ),
        findsOneWidget,
      );
      expect(find.text('Quick daily drill'), findsOneWidget);
      expect(find.text('Today\'s reps'), findsWidgets);
      expect(
        find.byKey(const Key('act0_shell_play_featured_cta')),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Sharpens today: three short spots keep the current route sharp without opening a full lesson.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Tomorrow\'s short set keeps this skill feeling like part of your game.',
        ),
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
      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_practice_group_actions')),
        180,
      );
      expect(
        find.byKey(const Key('act0_shell_practice_group_actions')),
        findsOneWidget,
      );
    },
  );

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

  testWidgets(
    'Disabled topic practice card uses a soft later chip instead of a CTA row',
    (tester) async {
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
                  groupId: 'actions',
                  title: 'Actions',
                  subtitle: 'One crisp action family.',
                  ctaLabel: 'Practice',
                  categoryLabel: 'Drill',
                  isEnabled: false,
                ),
              ],
              recommendedGroupId: 'daily',
              recommendedTitle: 'Quick daily drill',
              recommendedSubtitle: 'Run three short spots to keep today clean.',
              recommendedReasonLabel: 'Today\'s reps',
              recommendedOutcome:
                  'three short spots keep the current route sharp without opening a full lesson.',
              recommendedOutcomeLead: 'Sharpens today:',
              masteryLabel: 'Today\'s reps',
              onStartGroup: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final actionsCard = find.byKey(
        const Key('act0_shell_practice_group_actions'),
      );
      expect(actionsCard, findsOneWidget);
      expect(
        find.descendant(
          of: actionsCard,
          matching: find.byKey(
            const Key('act0_shell_practice_group_actions_disabled_chip'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: actionsCard, matching: find.text('Later')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: actionsCard,
          matching: find.byIcon(Icons.arrow_forward_rounded),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Disabled repair group collapses to one empty-state message instead of a duplicate quick-fix card',
    (tester) async {
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
                  title: 'Review one quick fix',
                  subtitle:
                      'Quick fixes unlock after you repair one spot in Review.',
                  ctaLabel: 'Fix',
                  categoryLabel: 'Repair',
                  sessionLabel: 'Quick fix',
                  durationLabel: '~4 min',
                  isEnabled: false,
                ),
              ],
              recommendedGroupId: 'daily',
              recommendedTitle: 'Quick daily drill',
              recommendedSubtitle: 'Run three short spots to keep today clean.',
              recommendedReasonLabel: 'Today\'s reps',
              recommendedOutcome:
                  'three short spots keep the current route sharp without opening a full lesson.',
              recommendedOutcomeLead: 'Sharpens today:',
              masteryLabel: 'Today\'s reps',
              onStartGroup: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_play_repair_empty')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_practice_group_weak_spots')),
        findsNothing,
      );
      expect(find.text('Nothing to repair right now.'), findsOneWidget);
      expect(find.text('Review one quick fix'), findsNothing);
    },
  );

  testWidgets(
    'Non-daily featured recommendation does not show the tomorrow reset value line',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0PlayShellV1(
              groups: const <Act0PracticeGroupV1>[
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
              ],
              recommendedGroupId: 'weak_spots',
              recommendedTitle: 'Sharpen one repaired spot',
              recommendedSubtitle:
                  'Keep one fixed idea stable without dropping back into full Review.',
              recommendedReasonLabel: 'Keep it sharp',
              recommendedOutcome:
                  'stabilize the fix, then move back into today\'s reps or one skill pack.',
              recommendedOutcomeLead: 'One calm rep:',
              masteryLabel: 'Light repair rep',
              onStartGroup: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.text(
          'Tomorrow\'s short set keeps this skill feeling like part of your game.',
        ),
        findsNothing,
      );
    },
  );
}
