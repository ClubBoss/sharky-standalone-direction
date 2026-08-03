import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

void main() {
  Future<void> pumpPractice(
    WidgetTester tester, {
    required List<Act0PracticeGroupV1> groups,
    String recommendedGroupId = 'daily',
    Act0PracticeRepairQueueConsumerV1 repairQueueConsumer =
        const Act0PracticeRepairQueueConsumerV1(),
    double textScale = 1,
    ValueChanged<Act0PracticeGroupV1>? onStartGroup,
    ValueChanged<Act0PracticeRepairQueueLaunchRequestV1>?
    onLaunchRepairQueueTarget,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: Act0PlayShellV1(
              groups: groups,
              recommendedGroupId: recommendedGroupId,
              recommendedTitle: 'Start a short rep',
              recommendedSubtitle: 'Run short spots to keep today clean.',
              recommendedReasonLabel: 'Today\'s reps',
              recommendedOutcome:
                  'three short spots keep the current route sharp without opening a full lesson.',
              recommendedOutcomeLead: 'Sharpens today:',
              masteryLabel: 'Today\'s reps',
              repairQueueConsumer: repairQueueConsumer,
              onLaunchRepairQueueTarget: onLaunchRepairQueueTarget,
              onStartGroup: onStartGroup ?? (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const dailyGroup = Act0PracticeGroupV1(
    groupId: 'daily',
    title: '0/3 daily spots',
    subtitle: 'One short set to stay warm.',
    ctaLabel: 'Start',
    categoryLabel: 'Today',
    countLabel: '3 spots',
    sessionLabel: 'Short daily set',
    isEnabled: true,
  );

  const dailyWithDurationGroup = Act0PracticeGroupV1(
    groupId: 'daily',
    title: '0/3 daily spots',
    subtitle: 'One short set to stay warm.',
    ctaLabel: 'Start',
    categoryLabel: 'Today',
    countLabel: '3 spots',
    sessionLabel: 'Short daily set',
    durationLabel: '~3 min',
    isEnabled: true,
  );

  const unavailableDailyGroup = Act0PracticeGroupV1(
    groupId: 'daily',
    title: '0/3 daily spots',
    subtitle: 'Your next short rep becomes available on the active route.',
    ctaLabel: 'Later',
    categoryLabel: 'Today',
    isEnabled: false,
  );

  const disabledRepairGroup = Act0PracticeGroupV1(
    groupId: 'weak_spots',
    title: 'Review one quick fix',
    subtitle: 'Quick fixes unlock after you repair one spot in Review.',
    ctaLabel: 'Practice',
    categoryLabel: 'Repair',
    sessionLabel: 'Quick fix',
    durationLabel: '~4 min',
    isEnabled: false,
  );

  const enabledRepairGroup = Act0PracticeGroupV1(
    groupId: 'weak_spots',
    title: 'Repair this spot',
    subtitle: 'Practice the spot that keeps repeating.',
    ctaLabel: 'Practice',
    categoryLabel: 'Repair',
    countLabel: '1 spot',
    durationLabel: '~3 min',
    isEnabled: true,
  );

  const topicGroups = <Act0PracticeGroupV1>[
    Act0PracticeGroupV1(
      groupId: 'actions',
      title: 'Actions',
      subtitle: 'Clear it on the route first.',
      ctaLabel: 'Practice',
      categoryLabel: 'Drill',
      isEnabled: false,
    ),
    Act0PracticeGroupV1(
      groupId: 'blinds',
      title: 'Blinds',
      subtitle: 'Clear it on the route first.',
      ctaLabel: 'Practice',
      categoryLabel: 'Drill',
      isEnabled: false,
    ),
    Act0PracticeGroupV1(
      groupId: 'positions',
      title: 'Positions',
      subtitle: 'Clear it on the route first.',
      ctaLabel: 'Practice',
      categoryLabel: 'Drill',
      isEnabled: false,
    ),
    Act0PracticeGroupV1(
      groupId: 'showdown',
      title: 'Showdown',
      subtitle: 'Clear it on the route first.',
      ctaLabel: 'Practice',
      categoryLabel: 'Drill',
      isEnabled: false,
    ),
    Act0PracticeGroupV1(
      groupId: 'rankings',
      title: 'Hand rankings',
      subtitle: 'Clear it on the route first.',
      ctaLabel: 'Practice',
      categoryLabel: 'Drill',
      isEnabled: false,
    ),
  ];

  testWidgets('Practice renders a working daily training hero first', (
    tester,
  ) async {
    final started = <String>[];
    await pumpPractice(
      tester,
      groups: const <Act0PracticeGroupV1>[
        dailyGroup,
        disabledRepairGroup,
        ...topicGroups,
      ],
      onStartGroup: (group) => started.add(group.groupId),
    );

    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_play_header')), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Useful reps'), findsOneWidget);
    expect(find.text('Build the read one spot at a time.'), findsOneWidget);

    final hero = find.byKey(const Key('act0_shell_play_daily_hero'));
    expect(hero, findsOneWidget);
    expect(
      find.descendant(of: hero, matching: find.text('Start a short rep')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: hero,
        matching: find.text('One short rep keeps this table clue fresh.'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: hero, matching: find.text('3 spots')),
      findsOneWidget,
    );
    expect(find.text('~3 min'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_play_featured_reason')),
      findsNothing,
    );
    expect(
      find.text(
        'Tomorrow\'s short set keeps this skill feeling like part of your game.',
      ),
      findsNothing,
    );

    final cta = tester.widget<FilledButton>(
      find.byKey(const Key('act0_shell_play_featured_cta')),
    );
    expect(
      cta.style?.backgroundColor?.resolve(<WidgetState>{}),
      Act0ShellTokensV1.actionCyan,
    );
    expect(
      cta.style?.foregroundColor?.resolve(<WidgetState>{}),
      Act0ShellTokensV1.primaryDark,
    );

    await tester.tap(find.byKey(const Key('act0_shell_play_featured_cta')));
    expect(started, <String>['daily']);
  });

  testWidgets('Practice omits repair queue when projection has no rows', (
    tester,
  ) async {
    await pumpPractice(
      tester,
      groups: const <Act0PracticeGroupV1>[
        dailyGroup,
        disabledRepairGroup,
        ...topicGroups,
      ],
      repairQueueConsumer: Act0PracticeRepairQueueConsumerV1.fromProjection(
        const Act0PracticeRepairQueueProjectionV1(),
      ),
    );

    expect(find.byKey(const Key('act0_shell_play_repair_queue')), findsNothing);
    expect(find.byKey(const Key('act0_shell_play_daily_hero')), findsOneWidget);
  });

  testWidgets(
    'Practice keeps a passive repair queue secondary to the short rep hero',
    (tester) async {
      final started = <String>[];
      await pumpPractice(
        tester,
        groups: const <Act0PracticeGroupV1>[
          dailyGroup,
          disabledRepairGroup,
          ...topicGroups,
        ],
        repairQueueConsumer: Act0PracticeRepairQueueConsumerV1.fromProjection(
          Act0PracticeRepairQueueProjectionV1(
            items: <Act0PracticeRepairQueueItemV1>[
              _queueItem(safeLabel: 'Action read', context: 'No bet yet'),
            ],
          ),
        ),
        onStartGroup: (group) => started.add(group.groupId),
      );

      final queue = find.byKey(const Key('act0_shell_play_repair_queue'));
      expect(queue, findsOneWidget);
      expect(find.byKey(const Key('act0_shell_play_daily_hero')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_play_featured_status_row')), findsNothing);
      expect(
        find.descendant(of: queue, matching: find.text('Practice repair')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: queue,
          matching: find.text('Saved spots worth repeating.'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: queue, matching: find.text('Action read')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: queue, matching: find.text('No bet yet')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: queue, matching: find.byType(FilledButton)),
        findsNothing,
      );
      expect(started, isEmpty);
    },
  );

  testWidgets('Practice renders an unavailable recommendation as status only', (
    tester,
  ) async {
    await pumpPractice(
      tester,
      groups: const <Act0PracticeGroupV1>[
        unavailableDailyGroup,
        disabledRepairGroup,
        ...topicGroups,
      ],
    );

    expect(find.byKey(const Key('act0_shell_play_daily_hero')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_play_featured_status_row')),
      findsOneWidget,
    );
    expect(find.text('Later'), findsNothing);
    expect(find.byKey(const Key('act0_shell_play_short_rep_cta')), findsNothing);
  });

  testWidgets('Practice repair queue renders at most three compact rows', (
    tester,
  ) async {
    await pumpPractice(
      tester,
      groups: const <Act0PracticeGroupV1>[
        dailyGroup,
        disabledRepairGroup,
        ...topicGroups,
      ],
      repairQueueConsumer: Act0PracticeRepairQueueConsumerV1.fromProjection(
        Act0PracticeRepairQueueProjectionV1(
          items: <Act0PracticeRepairQueueItemV1>[
            for (var index = 0; index < 5; index++)
              _queueItem(
                itemId: 'queue_$index',
                sourceTaskId: 'task_$index',
                safeLabel: 'Queue row $index',
              ),
          ],
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_play_repair_queue_item_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_play_repair_queue_item_1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_play_repair_queue_item_2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_play_repair_queue_item_3')),
      findsNothing,
    );
    expect(find.text('Queue row 4'), findsNothing);
  });

  testWidgets('Practice repair queue pins the active item first', (
    tester,
  ) async {
    await pumpPractice(
      tester,
      groups: const <Act0PracticeGroupV1>[
        dailyGroup,
        disabledRepairGroup,
        ...topicGroups,
      ],
      repairQueueConsumer: Act0PracticeRepairQueueConsumerV1.fromProjection(
        Act0PracticeRepairQueueProjectionV1(
          items: <Act0PracticeRepairQueueItemV1>[
            _queueItem(itemId: 'history', safeLabel: 'History row'),
            _queueItem(
              itemId: 'active',
              sourceTaskId: 'active_task',
              safeLabel: 'Active row',
              sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
            ),
          ],
        ),
      ),
    );

    final first = find.byKey(const Key('act0_shell_play_repair_queue_item_0'));
    expect(
      find.descendant(of: first, matching: find.text('Active row')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: first, matching: find.text('Active repair')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: first,
        matching: find.text('Same table clue as the miss.'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'Practice repair queue shows CTA only for launchable active row',
    (tester) async {
      await pumpPractice(
        tester,
        groups: const <Act0PracticeGroupV1>[
          dailyGroup,
          disabledRepairGroup,
          ...topicGroups,
        ],
        repairQueueConsumer: Act0PracticeRepairQueueConsumerV1.fromProjection(
          Act0PracticeRepairQueueProjectionV1(
            items: <Act0PracticeRepairQueueItemV1>[
              _queueItem(
                itemId: 'active',
                safeLabel: 'Active row',
                sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
                launchTarget: const Act0PracticeRepairQueueLaunchTargetV1(
                  worldId: 'world_1',
                  lessonId: 'fold_check_call_raise',
                  taskId: 'actions_check_drill',
                  source: act0PracticeRepairQueueSourceActiveRepairV1,
                  targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
                ),
              ),
              _queueItem(itemId: 'history', safeLabel: 'History row'),
            ],
          ),
        ),
        onLaunchRepairQueueTarget: (_) {},
      );

      final active = find.byKey(
        const Key('act0_shell_play_repair_queue_item_0'),
      );
      final history = find.byKey(
        const Key('act0_shell_play_repair_queue_item_1'),
      );
      final queue = find.byKey(const Key('act0_shell_play_repair_queue'));
      final shortRep = find.byKey(
        const Key('act0_shell_play_featured_status_row'),
      );
      expect(queue, findsOneWidget);
      expect(shortRep, findsOneWidget);
      expect(
        tester.getTopLeft(queue).dy,
        lessThan(tester.getTopLeft(shortRep).dy),
      );
      expect(
        find.descendant(of: queue, matching: find.text('Active repair first')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: queue,
          matching: find.text(
            'Start the same table clue before browsing drills.',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: queue,
          matching: find.text(
            'Before choosing, check whether a bet is in front of you.',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: active, matching: find.text('Practice this')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: active,
          matching: find.byKey(
            const Key('act0_shell_play_repair_queue_cta_press_motion'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: active, matching: find.byType(AnimatedScale)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: active, matching: find.text('Active repair')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: history, matching: find.text('Practice this')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: history,
          matching: find.text(
            'Before choosing, check whether a bet is in front of you.',
          ),
        ),
        findsNothing,
      );
      for (final forbidden in <String>[
        'Fix',
        'Clear',
        'Resolve',
        'Complete',
        'Master',
        'Leak',
        'AI',
        'GTO',
        'Solver',
        'Premium',
      ]) {
        expect(find.textContaining(forbidden), findsNothing);
      }
    },
  );

  testWidgets(
    'Practice repair queue CTA launches target and keeps row visible',
    (tester) async {
      final launched = <Act0PracticeRepairQueueLaunchRequestV1>[];
      await pumpPractice(
        tester,
        groups: const <Act0PracticeGroupV1>[
          dailyGroup,
          disabledRepairGroup,
          ...topicGroups,
        ],
        repairQueueConsumer: Act0PracticeRepairQueueConsumerV1.fromProjection(
          Act0PracticeRepairQueueProjectionV1(
            items: <Act0PracticeRepairQueueItemV1>[
              _queueItem(
                itemId: 'active',
                sourceTaskId: 'actions_legal_context',
                safeLabel: 'Action read',
                sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
                launchTarget: const Act0PracticeRepairQueueLaunchTargetV1(
                  worldId: 'world_1',
                  lessonId: 'fold_check_call_raise',
                  taskId: 'actions_check_drill',
                  source: act0PracticeRepairQueueSourceActiveRepairV1,
                  targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
                ),
              ),
            ],
          ),
        ),
        onLaunchRepairQueueTarget: launched.add,
      );

      await tester.tap(find.text('Practice this'));
      await tester.pump();

      expect(launched, hasLength(1));
      expect(
        find.byKey(const Key('act0_shell_play_repair_queue_cta_press_motion')),
        findsOneWidget,
      );
      expect(launched.single.targetWorldId, 'world_1');
      expect(launched.single.targetLessonId, 'fold_check_call_raise');
      expect(launched.single.targetTaskId, 'actions_check_drill');
      expect(launched.single.sourceTaskId, 'actions_legal_context');
      expect(launched.single.repairTaskId, 'actions_check_drill');
      expect(launched.single.queueItemId, 'active');
      expect(
        find.byKey(const Key('act0_shell_play_repair_queue_item_0')),
        findsOneWidget,
      );
      expect(find.text('Action read'), findsOneWidget);
    },
  );

  testWidgets('Practice repair queue does not render forbidden claims', (
    tester,
  ) async {
    await pumpPractice(
      tester,
      groups: const <Act0PracticeGroupV1>[
        dailyGroup,
        disabledRepairGroup,
        ...topicGroups,
      ],
      repairQueueConsumer: Act0PracticeRepairQueueConsumerV1.fromProjection(
        Act0PracticeRepairQueueProjectionV1(
          items: <Act0PracticeRepairQueueItemV1>[
            _queueItem(
              safeLabel: '',
              errorDetail: 'gto solver leak fixed',
              context: 'premium mastery',
            ),
          ],
        ),
      ),
    );

    final queue = find.byKey(const Key('act0_shell_play_repair_queue'));
    expect(
      find.descendant(of: queue, matching: find.text('Practice repair')),
      findsWidgets,
    );
    for (final forbidden in <String>[
      'fixed',
      'cleared',
      'resolved',
      'completed',
      'leak',
      'mastery',
      'GTO',
      'solver',
      'premium',
    ]) {
      expect(
        find.descendant(of: queue, matching: find.textContaining(forbidden)),
        findsNothing,
      );
    }
  });

  testWidgets(
    'Daily hero only shows duration when real group data provides it',
    (tester) async {
      await pumpPractice(
        tester,
        groups: const <Act0PracticeGroupV1>[
          dailyWithDurationGroup,
          disabledRepairGroup,
          ...topicGroups,
        ],
      );

      final hero = find.byKey(const Key('act0_shell_play_daily_hero'));
      expect(
        find.descendant(of: hero, matching: find.text('~3 min')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Quick reps empty state is compact secondary training support', (
    tester,
  ) async {
    await pumpPractice(
      tester,
      groups: const <Act0PracticeGroupV1>[
        dailyGroup,
        disabledRepairGroup,
        ...topicGroups,
      ],
    );

    final empty = find.byKey(const Key('act0_shell_play_repair_empty'));
    expect(empty, findsOneWidget);
    expect(find.text('Repair unlocks from real misses'), findsOneWidget);
    expect(
      find.text('Miss a lesson spot and Practice brings back the same clue.'),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_practice_group_weak_spots')),
      findsNothing,
    );
    expect(tester.getRect(empty).height, lessThanOrEqualTo(48));
  });

  testWidgets('Enabled repair item keeps its existing callback', (
    tester,
  ) async {
    final started = <String>[];
    await pumpPractice(
      tester,
      groups: const <Act0PracticeGroupV1>[
        dailyGroup,
        enabledRepairGroup,
        ...topicGroups,
      ],
      onStartGroup: (group) => started.add(group.groupId),
    );

    final repair = find.byKey(
      const Key('act0_shell_practice_group_weak_spots'),
    );
    expect(repair, findsOneWidget);
    await tester.tap(repair);
    expect(started, <String>['weak_spots']);
  });

  testWidgets(
    'Repair recommendation remains a secondary Practice reinforcement entry',
    (tester) async {
      final started = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0PlayShellV1(
              groups: const <Act0PracticeGroupV1>[
                dailyGroup,
                enabledRepairGroup,
                ...topicGroups,
              ],
              recommendedGroupId: 'weak_spots',
              recommendedTitle: 'Practice the no-bet-yet clue',
              recommendedSubtitle: 'One same-clue rep will help lock this in.',
              recommendedReasonLabel: 'Repair reinforcement',
              recommendedOutcome: 'Keep the no-bet-yet clue warm.',
              recommendedOutcomeLead: 'Repair reinforcement',
              masteryLabel: 'Repair reinforcement',
              onStartGroup: (group) => started.add(group.groupId),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hero = find.byKey(const Key('act0_shell_play_daily_hero'));
      expect(
        find.descendant(of: hero, matching: find.text('Start a short rep')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: hero,
          matching: find.text('One short rep keeps this table clue fresh.'),
        ),
        findsOneWidget,
      );
      final repair = find.byKey(
        const Key('act0_shell_practice_group_weak_spots'),
      );
      expect(repair, findsOneWidget);
      expect(
        find.descendant(of: repair, matching: find.text('Repair this spot')),
        findsOneWidget,
      );
      expect(find.text('Session proof'), findsNothing);
      expect(find.text('Review'), findsNothing);
      expect(find.text('Learn'), findsNothing);
      expect(find.text('Profile'), findsNothing);

      await tester.tap(repair);
      expect(started, <String>['weak_spots']);
    },
  );

  testWidgets(
    'Topic reps render compact route-backed previews without lockwall claims',
    (tester) async {
      await pumpPractice(
        tester,
        groups: const <Act0PracticeGroupV1>[
          dailyGroup,
          disabledRepairGroup,
          ...topicGroups,
        ],
      );

      expect(
        find.byKey(const Key('act0_shell_play_topic_hub')),
        findsOneWidget,
      );
      expect(find.text('Short reps'), findsOneWidget);
      expect(
        find.text('A good rep is one clearer table decision.'),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('act0_shell_practice_group_actions')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_practice_group_blinds')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_practice_group_positions')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_practice_group_showdown')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_practice_group_rankings')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_play_locked_packs_summary')),
        findsOneWidget,
      );

      expect(find.text('Later'), findsNothing);
      expect(find.text('Clear it on the route first.'), findsNothing);
      expect(find.text('0/12'), findsNothing);
      expect(find.textContaining('premium'), findsNothing);
      expect(find.textContaining('pay'), findsNothing);
      expect(find.textContaining('recommended for you'), findsNothing);
      expect(find.textContaining('based on your mistakes'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_play_locked_packs_summary')),
        findsOneWidget,
      );
      expect(
        find.text('More practice areas open with the route'),
        findsNothing,
      );
      expect(
        find.text('More practice opens through the route'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Locked topics stay below today\'s rep. Finish route steps to open more.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('drill gym'), findsNothing);
      expect(find.textContaining('many drill packs'), findsNothing);
    },
  );

  testWidgets('Locked and unlocked skill-pack truth is preserved', (
    tester,
  ) async {
    final started = <String>[];
    await pumpPractice(
      tester,
      groups: const <Act0PracticeGroupV1>[
        dailyGroup,
        disabledRepairGroup,
        Act0PracticeGroupV1(
          groupId: 'actions',
          title: 'Actions',
          subtitle: 'Betting and lines.',
          ctaLabel: 'Practice',
          categoryLabel: 'Drill',
          isEnabled: true,
        ),
        Act0PracticeGroupV1(
          groupId: 'blinds',
          title: 'Blinds',
          subtitle: 'Clear it on the route first.',
          ctaLabel: 'Practice',
          categoryLabel: 'Drill',
          isEnabled: false,
        ),
      ],
      onStartGroup: (group) => started.add(group.groupId),
    );

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_practice_group_blinds')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_practice_group_blinds')));
    expect(started, isEmpty);

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_practice_group_actions')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_practice_group_actions')),
    );
    expect(started, <String>['actions']);
  });

  testWidgets('Practice has no old teal dominant CTA color', (tester) async {
    await pumpPractice(
      tester,
      groups: const <Act0PracticeGroupV1>[
        dailyGroup,
        disabledRepairGroup,
        ...topicGroups,
      ],
    );

    final cta = tester.widget<FilledButton>(
      find.byKey(const Key('act0_shell_play_featured_cta')),
    );
    expect(
      cta.style?.backgroundColor?.resolve(<WidgetState>{}),
      isNot(const Color(0xFF087B91)),
    );
  });

  testWidgets('Practice coach sentence remains fully readable at 1.0x and 1.4x', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const coachKey = Key('act0_shell_play_sharky_coach_line');
    const queueKey = Key('act0_shell_play_repair_queue');
    const ctaKey = Key('act0_shell_play_short_rep_cta');
    final phrase = act0SharkyCoachLineForMomentV1(
      Act0SharkyCoachMomentV1.practiceCurrentFix,
    );
    Act0PracticeRepairQueueConsumerV1 activeConsumer() =>
        Act0PracticeRepairQueueConsumerV1.fromProjection(
          Act0PracticeRepairQueueProjectionV1(
            items: <Act0PracticeRepairQueueItemV1>[
              _queueItem(
                itemId: 'active',
                sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
                launchTarget: const Act0PracticeRepairQueueLaunchTargetV1(
                  worldId: 'world_1',
                  lessonId: 'fold_check_call_raise',
                  taskId: 'actions_check_drill',
                  source: act0PracticeRepairQueueSourceActiveRepairV1,
                  targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
                ),
              ),
              _queueItem(itemId: 'history', safeLabel: 'History row'),
            ],
          ),
        );

    for (final textScale in <double>[1, 1.4]) {
      await pumpPractice(
        tester,
        textScale: textScale,
        groups: const <Act0PracticeGroupV1>[
          dailyGroup,
          disabledRepairGroup,
          ...topicGroups,
        ],
        repairQueueConsumer: activeConsumer(),
        onLaunchRepairQueueTarget: (_) {},
      );

      final coachFinder = find.byKey(coachKey);
      final coach = tester.widget<Text>(coachFinder);
      final paragraph = tester.renderObject<RenderParagraph>(coachFinder);
      final queueRect = tester.getRect(find.byKey(queueKey));
      final coachRect = tester.getRect(coachFinder);
      final painter = TextPainter(
        text: TextSpan(text: phrase, style: coach.style),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.linear(textScale),
        maxLines: coach.maxLines,
      )..layout(maxWidth: paragraph.size.width);
      final naturalPainter = TextPainter(
        text: TextSpan(text: phrase, style: coach.style),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.linear(textScale),
      )..layout(maxWidth: paragraph.size.width);

      expect(coach.data, phrase);
      expect(
        MediaQuery.textScalerOf(tester.element(coachFinder)).scale(1),
        textScale,
      );
      expect(coach.style?.letterSpacing, 0);
      expect(coach.maxLines, textScale > 1.2 ? 4 : 3);
      expect(coach.softWrap, isTrue);
      expect(coach.overflow, TextOverflow.clip);
      expect(
        painter.didExceedMaxLines,
        isFalse,
        reason:
            'scale=$textScale width=${paragraph.size.width} lines=${painter.computeLineMetrics().length} natural=${naturalPainter.computeLineMetrics().length}',
      );
      expect(
        painter.computeLineMetrics().length,
        lessThanOrEqualTo(textScale > 1.2 ? 4 : 3),
      );
      expect(paragraph.size.height, greaterThanOrEqualTo(painter.height));
      expect(coachRect.left, greaterThanOrEqualTo(queueRect.left));
      expect(coachRect.right, lessThanOrEqualTo(queueRect.right));
      expect(coachRect.top, greaterThanOrEqualTo(queueRect.top));
      expect(coachRect.bottom, lessThanOrEqualTo(queueRect.bottom));
      expect(
        coachRect.bottom,
        lessThanOrEqualTo(tester.view.physicalSize.height),
      );

      await tester.ensureVisible(find.byKey(ctaKey));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(ctaKey)).height, greaterThan(0));
      expect(tester.takeException(), isNull);
    }
  });
}

Act0PracticeRepairQueueItemV1 _queueItem({
  String itemId = 'queue_item',
  String sourceTaskId = 'actions_legal_context',
  String safeLabel = 'Action read',
  String errorDetail = 'missed_action_read',
  String context = 'No bet yet',
  String sourceType = act0PracticeRepairQueueSourceReviewHistoryV1,
  Act0PracticeRepairQueueLaunchTargetV1 launchTarget =
      const Act0PracticeRepairQueueLaunchTargetV1.notLaunchable(
        source: act0PracticeRepairQueueSourceReviewHistoryV1,
      ),
  Act0PracticeRepairQueueLaunchRequestV1? launchRequest,
}) {
  final resolvedLaunchRequest =
      launchRequest ??
      (launchTarget.isLaunchable
          ? Act0PracticeRepairQueueLaunchRequestV1(
              targetWorldId: launchTarget.worldId,
              targetLessonId: launchTarget.lessonId,
              targetTaskId: launchTarget.taskId,
              targetType: launchTarget.targetType,
              sourceType: sourceType,
              sourceTaskId: sourceTaskId,
              repairTaskId: launchTarget.taskId,
              repairFocusKey: 'key_$itemId',
              queueItemId: itemId,
            )
          : null);
  return Act0PracticeRepairQueueItemV1(
    itemId: itemId,
    sourceRecordId: 'record_$itemId',
    sourceKey: 'key_$itemId',
    sourceTaskId: sourceTaskId,
    skillTag: 'action_read',
    safeLabel: safeLabel,
    errorDetail: errorDetail,
    selectedId: 'fold',
    betterId: 'check',
    context: context,
    priority: 0,
    sourceType: sourceType,
    state: act0PracticeRepairQueueStateQueuedUnresolvedV1,
    launchTarget: launchTarget,
    launchRequest: resolvedLaunchRequest,
  );
}
