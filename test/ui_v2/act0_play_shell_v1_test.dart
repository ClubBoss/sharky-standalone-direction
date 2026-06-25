import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

void main() {
  Future<void> pumpPractice(
    WidgetTester tester, {
    required List<Act0PracticeGroupV1> groups,
    String recommendedGroupId = 'daily',
    Act0PracticeRepairQueueConsumerV1 repairQueueConsumer =
        const Act0PracticeRepairQueueConsumerV1(),
    ValueChanged<Act0PracticeGroupV1>? onStartGroup,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0PlayShellV1(
            groups: groups,
            recommendedGroupId: recommendedGroupId,
            recommendedTitle: 'Quick daily drill',
            recommendedSubtitle: 'Run short spots to keep today clean.',
            recommendedReasonLabel: 'Today\'s reps',
            recommendedOutcome:
                'three short spots keep the current route sharp without opening a full lesson.',
            recommendedOutcomeLead: 'Sharpens today:',
            masteryLabel: 'Today\'s reps',
            repairQueueConsumer: repairQueueConsumer,
            onStartGroup: onStartGroup ?? (_) {},
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

  const disabledRepairGroup = Act0PracticeGroupV1(
    groupId: 'weak_spots',
    title: 'Review one quick fix',
    subtitle: 'Quick fixes unlock after you repair one spot in Review.',
    ctaLabel: 'Fix',
    categoryLabel: 'Repair',
    sessionLabel: 'Quick fix',
    durationLabel: '~4 min',
    isEnabled: false,
  );

  const enabledRepairGroup = Act0PracticeGroupV1(
    groupId: 'weak_spots',
    title: 'Repair this spot',
    subtitle: 'Fix the mistake that keeps repeating.',
    ctaLabel: 'Fix',
    categoryLabel: 'Repair',
    countLabel: '1 leak',
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
    expect(find.text('Sharpen your game'), findsOneWidget);
    expect(
      find.text('Short reps. Real spots. Stronger decisions.'),
      findsOneWidget,
    );
    expect(find.textContaining('Sharky'), findsNothing);

    final hero = find.byKey(const Key('act0_shell_play_daily_hero'));
    expect(hero, findsOneWidget);
    expect(
      find.descendant(of: hero, matching: find.text('Quick daily drill')),
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
      Act0ShellTokensV1.actionBlue,
    );
    expect(
      cta.style?.foregroundColor?.resolve(<WidgetState>{}),
      Act0ShellTokensV1.text,
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
    'Practice renders a passive repair queue without replacing hero',
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
      expect(
        find.byKey(const Key('act0_shell_play_daily_hero')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: queue, matching: find.text('Repair queue')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: queue,
          matching: find.text('Spots Sharky can prove are worth repeating.'),
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
      find.descendant(of: first, matching: find.text('Pinned')),
      findsOneWidget,
    );
  });

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
      findsOneWidget,
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
    expect(find.text('Nothing to repair right now.'), findsOneWidget);
    expect(
      find.text('Topic reps stay ready for extra practice areas.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_practice_group_weak_spots')),
      findsNothing,
    );
    expect(tester.getRect(empty).height, lessThanOrEqualTo(104));
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
        find.descendant(of: hero, matching: find.text('Quick daily drill')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: hero,
          matching: find.text('Short spots from completed lessons.'),
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
      expect(find.text('Topic reps'), findsOneWidget);
      expect(
        find.text('Focused reps open as your route grows.'),
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
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_practice_group_showdown')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_practice_group_rankings')),
        findsNothing,
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
        findsOneWidget,
      );
      expect(
        find.text('Finish lessons to open more focused reps.'),
        findsOneWidget,
      );
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
}

Act0PracticeRepairQueueItemV1 _queueItem({
  String itemId = 'queue_item',
  String sourceTaskId = 'actions_legal_context',
  String safeLabel = 'Action read',
  String errorDetail = 'missed_action_read',
  String context = 'No bet yet',
  String sourceType = act0PracticeRepairQueueSourceReviewHistoryV1,
}) {
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
  );
}
