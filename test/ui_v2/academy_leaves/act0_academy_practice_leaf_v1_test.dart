import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_practice_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart'
    show Act0PracticeGroupV1;

Act0PracticeGroupV1 _group(
  String id, {
  bool enabled = true,
  String? title,
  bool skipTeaching = false,
}) => Act0PracticeGroupV1(
  groupId: id,
  title: title ?? 'Group $id',
  subtitle: 'Subtitle $id',
  ctaLabel: 'Go',
  categoryLabel: 'Cat',
  isEnabled: enabled,
  targetWorldId: 'w1',
  targetLessonId: 'l1',
  targetTaskId: 't_$id',
  skipTeaching: skipTeaching,
);

const _launchTarget = Act0PracticeRepairQueueLaunchTargetV1(
  worldId: 'w2',
  lessonId: 'w2_l1',
  taskId: 'w2_t3',
  source: 'active_repair_v1',
  targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
);

const _launchRequest = Act0PracticeRepairQueueLaunchRequestV1(
  targetWorldId: 'w2',
  targetLessonId: 'w2_l1',
  targetTaskId: 'w2_t3',
  targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
  sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
  sourceTaskId: 'w2_t3',
  repairTaskId: 'w2_t3_repair',
  repairFocusKey: 'focus',
  queueItemId: 'q1',
);

const _launchableRepair = Act0PracticeRepairQueueItemViewModelV1(
  itemId: 'q1',
  title: 'Price the call',
  isPinned: true,
  launchTarget: _launchTarget,
  launchRequest: _launchRequest,
  detail: 'Button vs big blind',
);

// Complete request but the target itself is not an active-repair target:
// the accepted shell exposes no CTA for this shape.
const _mismatchedTargetRepair = Act0PracticeRepairQueueItemViewModelV1(
  itemId: 'q3',
  title: 'Mismatched target',
  isPinned: false,
  launchTarget: Act0PracticeRepairQueueLaunchTargetV1.notLaunchable(),
  launchRequest: _launchRequest,
);

const _historyOnlyRepair = Act0PracticeRepairQueueItemViewModelV1(
  itemId: 'q2',
  title: 'Old miss',
  isPinned: false,
);

Future<void> _pump(
  WidgetTester tester,
  Act0AcademyPracticeLeafInputV1 input,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Act0AcademyPracticeLeafV1(input: input)),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('starts exactly the source-recommended group object', (
    tester,
  ) async {
    final daily = _group('daily', skipTeaching: true);
    final started = <Act0PracticeGroupV1>[];
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [daily, _group('preflop')],
        recommendedGroupId: 'daily',
        recommendedTitle: 'Daily reps',
        recommendedSubtitle: 'Short reps from your lessons.',
        onStartGroup: started.add,
      ),
    );
    expect(find.text('Daily reps'), findsOneWidget);
    expect(find.text('Start practice'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_academy_practice_leaf_start')));
    expect(started, hasLength(1));
    // Identity: assisted/independent flags stay exactly as the source set them.
    expect(identical(started.single, daily), isTrue);
    expect(started.single.skipTeaching, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('locked recommendation never launches; offers Learn instead', (
    tester,
  ) async {
    final started = <Act0PracticeGroupV1>[];
    var learn = 0;
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [_group('daily', enabled: false)],
        recommendedGroupId: 'daily',
        recommendedTitle: 'Daily reps',
        recommendedSubtitle: 'Unlocks after your first lesson.',
        onStartGroup: started.add,
        onOpenLearn: () => learn++,
      ),
    );
    expect(find.text('Start practice'), findsNothing);
    expect(find.text('Continue learning'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_academy_practice_leaf_start')));
    expect(learn, 1);
    expect(started, isEmpty);
  });

  testWidgets('unresolved recommendation id never launches another group', (
    tester,
  ) async {
    final started = <Act0PracticeGroupV1>[];
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [_group('preflop')],
        recommendedGroupId: 'missing',
        recommendedTitle: 'Something',
        recommendedSubtitle: 'Sub',
        onStartGroup: started.add,
      ),
    );
    // No Learn callback either: no button rather than a fake action.
    expect(
      find.byKey(const Key('act0_academy_practice_leaf_start')),
      findsNothing,
    );
    expect(started, isEmpty);
  });

  testWidgets('launchable active repair leads and forwards the exact request', (
    tester,
  ) async {
    final launched = <Act0PracticeRepairQueueLaunchRequestV1>[];
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [_group('daily'), _group('weak_spots')],
        recommendedGroupId: 'daily',
        recommendedTitle: 'Daily reps',
        recommendedSubtitle: 'Sub',
        onStartGroup: (_) {},
        repairQueue: const Act0PracticeRepairQueueConsumerV1(
          items: [_launchableRepair],
        ),
        onLaunchRepair: launched.add,
      ),
    );
    expect(find.text('ACTIVE REPAIR FIRST'), findsOneWidget);
    expect(find.text('Price the call'), findsOneWidget);
    final queueY = tester
        .getTopLeft(
          find.byKey(const Key('act0_academy_practice_leaf_repair_queue')),
        )
        .dy;
    final recY = tester
        .getTopLeft(
          find.byKey(const Key('act0_academy_practice_leaf_recommendation')),
        )
        .dy;
    expect(queueY, lessThan(recY));
    // The recommendation is demoted to a secondary (outlined) action.
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_academy_practice_leaf_recommendation')),
        matching: find.byType(OutlinedButton),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('act0_academy_practice_leaf_repair_cta')),
    );
    expect(launched, hasLength(1));
    expect(identical(launched.single, _launchRequest), isTrue);
    // Never claims the repair is fixed.
    expect(find.textContaining(RegExp('fixed|mastered|Fixed')), findsNothing);
  });

  testWidgets('non-launchable repair debt stays visible without a CTA', (
    tester,
  ) async {
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [_group('daily')],
        recommendedGroupId: 'daily',
        recommendedTitle: 'Daily reps',
        recommendedSubtitle: 'Sub',
        onStartGroup: (_) {},
        repairQueue: const Act0PracticeRepairQueueConsumerV1(
          items: [_historyOnlyRepair, _mismatchedTargetRepair],
        ),
        onLaunchRepair: (_) {},
      ),
    );
    expect(find.text('OPEN REPAIRS'), findsOneWidget);
    expect(find.text('Old miss'), findsOneWidget);
    expect(find.text('Mismatched target'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_academy_practice_leaf_repair_cta')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_academy_practice_leaf_recommendation')),
        matching: find.byType(FilledButton),
      ),
      findsOneWidget,
    );
  });

  testWidgets('disabled weak spots without debt shows honest repair empty', (
    tester,
  ) async {
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [_group('daily'), _group('weak_spots', enabled: false)],
        recommendedGroupId: 'daily',
        recommendedTitle: 'Daily reps',
        recommendedSubtitle: 'Sub',
        onStartGroup: (_) {},
      ),
    );
    expect(
      find.byKey(const Key('act0_academy_practice_leaf_repair_empty')),
      findsOneWidget,
    );
    expect(find.text('Repair unlocks from real misses'), findsOneWidget);
  });

  testWidgets('locked topics are disabled and announced as locked', (
    tester,
  ) async {
    final started = <Act0PracticeGroupV1>[];
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [
          _group('daily'),
          _group('preflop', title: 'Preflop'),
          _group('postflop', title: 'Postflop', enabled: false),
        ],
        recommendedGroupId: 'daily',
        recommendedTitle: 'Daily reps',
        recommendedSubtitle: 'Sub',
        onStartGroup: started.add,
      ),
    );
    expect(find.bySemanticsLabel('Postflop, locked'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('act0_academy_practice_leaf_topic_postflop')),
      warnIfMissed: false,
    );
    expect(started, isEmpty);
    await tester.tap(
      find.byKey(const Key('act0_academy_practice_leaf_topic_preflop')),
    );
    expect(started.single.groupId, 'preflop');
    handle.dispose();
  });

  testWidgets('topic shelf expands only when more than two topics exist', (
    tester,
  ) async {
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [
          _group('daily'),
          _group('a', title: 'Topic A'),
          _group('b', title: 'Topic B'),
          _group('c', title: 'Topic C'),
        ],
        recommendedGroupId: 'daily',
        recommendedTitle: 'Daily reps',
        recommendedSubtitle: 'Sub',
        onStartGroup: (_) {},
      ),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_academy_practice_leaf_expand')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Topic C'), findsNothing);
    await tester.tap(
      find.byKey(const Key('act0_academy_practice_leaf_expand')),
    );
    await tester.pump();
    expect(find.text('Topic C'), findsOneWidget);
  });

  testWidgets('no groups and no debt renders an empty state, no fake start', (
    tester,
  ) async {
    var learn = 0;
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: const [],
        recommendedGroupId: 'daily',
        recommendedTitle: 'Daily reps',
        recommendedSubtitle: 'Sub',
        onStartGroup: (_) {},
        onOpenLearn: () => learn++,
      ),
    );
    expect(
      find.byKey(const Key('act0_academy_practice_leaf_empty')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_academy_practice_leaf_start')),
      findsNothing,
    );
    await tester.tap(
      find.byKey(const Key('act0_academy_practice_leaf_empty_learn')),
    );
    expect(learn, 1);
  });

  testWidgets('completion copy is shown only when the source supplies it', (
    tester,
  ) async {
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [_group('daily')],
        recommendedGroupId: 'daily',
        recommendedTitle: 'Daily reps',
        recommendedSubtitle: 'Sub',
        onStartGroup: (_) {},
      ),
    );
    expect(
      find.byKey(const Key('act0_academy_practice_leaf_completion')),
      findsNothing,
    );
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [_group('daily')],
        recommendedGroupId: 'daily',
        recommendedTitle: 'Daily reps',
        recommendedSubtitle: 'Sub',
        onStartGroup: (_) {},
        completionTitle: 'Session complete',
        completionBody: 'Extra reps are optional.',
      ),
    );
    expect(
      find.text('Session complete\nExtra reps are optional.'),
      findsOneWidget,
    );
  });
}
