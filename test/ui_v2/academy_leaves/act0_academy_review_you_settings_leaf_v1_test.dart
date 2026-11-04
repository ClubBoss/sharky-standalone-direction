import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_settings_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart'
    show Act0DueReviewItemV1;
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart'
    show Act0MistakeCardV1;

Act0MistakeCardV1 _mistake(
  String taskId, {
  String title = 'Blind defense spot',
  String weakness = 'Blind defense',
  String better = 'Call',
}) => Act0MistakeCardV1(
  taskId: taskId,
  lessonId: 'l1',
  worldId: 'w1',
  title: title,
  weaknessLabel: weakness,
  selectedOptionId: 'fold',
  selectedLabel: 'Fold',
  betterLabel: better,
  reason: 'r',
  attempts: 1,
);

Act0DueReviewItemV1 _due(String taskId) => Act0DueReviewItemV1(
  conceptFamilyId: 'cf',
  worldId: 'w1',
  lessonId: 'l1',
  taskId: taskId,
  nextDueAtUtc: DateTime.utc(2026, 11, 1),
  repeatedMissCount: 0,
  lapseCount: 0,
);

Act0AchievementSeedV1 _seed(String id, {int? seq}) => Act0AchievementSeedV1(
  id: id,
  internalTitle: id,
  sourceOwner: 'test',
  state: act0AchievementSeedStateEarnedV1,
  earned: true,
  earnedSequence: seq,
  sourceSummary: const {},
  eligibilityState: 'eligible',
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pump();
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pump();
}

void main() {
  group('Review leaf', () {
    testWidgets('open repair and genuine due review stay separate', (
      tester,
    ) async {
      final repaired = <String>[];
      final dueStarted = <Act0DueReviewItemV1>[];
      final due = _due('t9');
      await _pump(
        tester,
        Act0AcademyReviewLeafV1(
          input: Act0AcademyReviewLeafInputV1(
            openMistakes: [_mistake('t1'), _mistake('t2')],
            dueItems: [due],
            onRepairMistake: (m) => repaired.add(m.taskId),
            onStartDueReview: dueStarted.add,
          ),
        ),
      );
      expect(find.text('2'), findsOneWidget);
      expect(find.text('spots to repair'), findsOneWidget);
      expect(find.text('1 independent review due'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('act0_academy_review_leaf_repair_cta')),
      );
      expect(repaired, ['t1']);
      await _reveal(
        tester,
        find.byKey(const Key('act0_academy_review_leaf_start_due')),
      );
      await tester.tap(
        find.byKey(const Key('act0_academy_review_leaf_start_due')),
      );
      expect(identical(dueStarted.single, due), isTrue);
      expect(repaired, ['t1']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('every open mistake stays listed (unrelated debt kept)', (
      tester,
    ) async {
      await _pump(
        tester,
        Act0AcademyReviewLeafV1(
          input: Act0AcademyReviewLeafInputV1(
            openMistakes: [for (var i = 1; i <= 5; i++) _mistake('t$i')],
          ),
        ),
      );
      for (var i = 2; i <= 5; i++) {
        await _reveal(
          tester,
          find.byKey(Key('act0_academy_review_leaf_mistake_t$i')),
        );
        expect(
          find.byKey(Key('act0_academy_review_leaf_mistake_t$i')),
          findsOneWidget,
        );
      }
    });

    testWidgets('no due work is never invented', (tester) async {
      await _pump(
        tester,
        Act0AcademyReviewLeafV1(
          input: Act0AcademyReviewLeafInputV1(openMistakes: [_mistake('t1')]),
        ),
      );
      expect(
        find.byKey(const Key('act0_academy_review_leaf_due')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_academy_review_leaf_no_due')),
        findsOneWidget,
      );
    });

    testWidgets('due-only state is not described as caught up', (tester) async {
      await _pump(
        tester,
        Act0AcademyReviewLeafV1(
          input: Act0AcademyReviewLeafInputV1(
            dueItems: [_due('t9')],
            pastRepairs: [_mistake('t0')],
          ),
        ),
      );
      expect(find.text('0 open mistakes'), findsOneWidget);
      expect(find.text('All caught up'), findsNothing);
    });

    testWidgets('caught up only with no open, due or saved work', (
      tester,
    ) async {
      await _pump(
        tester,
        Act0AcademyReviewLeafV1(
          input: Act0AcademyReviewLeafInputV1(pastRepairs: [_mistake('t0')]),
        ),
      );
      expect(find.text('All caught up'), findsOneWidget);
      await _pump(
        tester,
        const Act0AcademyReviewLeafV1(input: Act0AcademyReviewLeafInputV1()),
      );
      expect(find.text('No saved mistakes yet'), findsOneWidget);
    });

    testWidgets('saved check forwards its own id', (tester) async {
      final started = <String>[];
      await _pump(
        tester,
        Act0AcademyReviewLeafV1(
          input: Act0AcademyReviewLeafInputV1(
            savedChecks: const [Act0AcademyReviewSavedCheckV1(checkId: 'j1')],
            onStartSavedCheck: (c) => started.add(c.checkId),
          ),
        ),
      );
      await _reveal(
        tester,
        find.byKey(const Key('act0_academy_review_leaf_saved_j1')),
      );
      await tester.tap(
        find.byKey(const Key('act0_academy_review_leaf_saved_j1')),
      );
      expect(started, ['j1']);
    });

    test('gateway title never echoes the keyed answer', () {
      expect(
        act0AcademyReviewMistakeTitleV1(
          _mistake('a', title: 'Call the river', better: 'Call'),
        ),
        'Blind defense',
      );
      expect(
        act0AcademyReviewMistakeTitleV1(
          _mistake('b', title: 'Check when no bet'),
        ),
        'No bet yet',
      );
      expect(
        act0AcademyReviewMistakeTitleV1(_mistake('c', title: 'Blind spot')),
        'Blind spot',
      );
    });
  });

  testWidgets('Review hero grows with large text instead of overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.6)),
          child: child!,
        ),
        home: Scaffold(
          body: Act0AcademyReviewLeafV1(
            input: Act0AcademyReviewLeafInputV1(openMistakes: [_mistake('t1')]),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  group('You leaf', () {
    test('open-mistake seeds are excluded before the three-moment cap', () {
      final moments = act0AcademyYouEarnedMomentsV1(
        Act0AchievementSeedProjectionV1(
          seeds: [
            _seed(act0AchievementSeedFirstRepairNoteV1, seq: 1),
            _seed(act0AchievementSeedFirstReviewHistoryItemV1, seq: 2),
            _seed(act0AchievementSeedFirstCorrectReadV1, seq: 3),
            _seed(act0AchievementSeedFirstEvidenceSignalV1, seq: 4),
            _seed(act0AchievementSeedFirstSessionCompleteV1, seq: 5),
          ],
        ),
      );
      expect(moments.map((m) => m.seedId), [
        act0AchievementSeedFirstCorrectReadV1,
        act0AchievementSeedFirstEvidenceSignalV1,
        act0AchievementSeedFirstSessionCompleteV1,
      ]);
    });

    testWidgets('unresolved mistakes are never shown as earned', (
      tester,
    ) async {
      await _pump(
        tester,
        const Act0AcademyYouLeafV1(
          input: Act0AcademyYouLeafInputV1(
            earnedMoments: [
              Act0AchievementMomentViewModelV1(
                seedId: act0AchievementSeedFirstReviewHistoryItemV1,
                label: 'One miss to fix',
              ),
            ],
            openRepairCount: 1,
          ),
        ),
      );
      expect(find.text('One miss to fix'), findsNothing);
      expect(find.text('Not earned yet'), findsOneWidget);
      expect(find.text('1 spot to repair'), findsOneWidget);
      expect(find.text('Spots to repair'), findsOneWidget);
    });

    testWidgets('evidence-backed earned moments are kept', (tester) async {
      await _pump(
        tester,
        const Act0AcademyYouLeafV1(
          input: Act0AcademyYouLeafInputV1(
            displayName: 'Ana',
            levelLabel: 'Level 2',
            xpLine: '60 XP',
            completedTaskCount: 7,
            bankedRepairCount: 2,
            earnedMoments: [
              Act0AchievementMomentViewModelV1(
                seedId: act0AchievementSeedFirstCorrectReadV1,
                label: 'First correct read',
              ),
            ],
          ),
        ),
      );
      expect(
        find.byKey(
          const Key(
            'act0_academy_you_leaf_moment_$act0AchievementSeedFirstCorrectReadV1',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('1 earned'), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Level 2 - 60 XP'), findsOneWidget);
      expect(find.text('7 tasks completed'), findsOneWidget);
      expect(find.text('2 repairs banked'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_academy_you_leaf_reinforced')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('explicit zero record is fresh: no XP, tasks or debt', (
      tester,
    ) async {
      await _pump(
        tester,
        const Act0AcademyYouLeafV1(
          input: Act0AcademyYouLeafInputV1(
            levelLabel: 'Level 1',
            xpLine: '0 XP',
            completedTaskCount: 0,
          ),
        ),
      );
      expect(find.text('Your journey'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_academy_you_leaf_tasks')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_academy_you_leaf_review')),
        findsNothing,
      );
      expect(find.textContaining('XP'), findsNothing);
    });

    testWidgets('unknown task count never hides a supplied level or XP', (
      tester,
    ) async {
      await _pump(
        tester,
        const Act0AcademyYouLeafV1(
          input: Act0AcademyYouLeafInputV1(
            levelLabel: 'Level 3',
            xpLine: '120 XP',
          ),
        ),
      );
      expect(find.text('Your journey'), findsNothing);
      expect(find.text('Level 3 - 120 XP'), findsOneWidget);
      expect(find.text('Your learning, saved'), findsOneWidget);
    });

    testWidgets('leaf never adds XP the source did not supply', (tester) async {
      await _pump(
        tester,
        const Act0AcademyYouLeafV1(
          input: Act0AcademyYouLeafInputV1(
            levelLabel: 'Level 2',
            completedTaskCount: 3,
          ),
        ),
      );
      expect(find.text('Level 2'), findsOneWidget);
      expect(find.textContaining('XP'), findsNothing);
    });
  });

  group('Settings leaf', () {
    testWidgets('toggles reflect and forward the persisted values', (
      tester,
    ) async {
      final haptics = <bool>[];
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        Act0AcademySettingsLeafV1(
          input: Act0AcademySettingsLeafInputV1(
            hapticsEnabled: true,
            onHapticsChanged: haptics.add,
            onOpenTerms: () {},
          ),
        ),
      );
      final sw = tester.widget<Switch>(
        find.byKey(const Key('act0_academy_settings_leaf_haptics')),
      );
      expect(sw.value, isTrue);
      await tester.tap(
        find.byKey(const Key('act0_academy_settings_leaf_haptics')),
      );
      expect(haptics, [false]);
      // Label and switch are one control for screen readers: the node that
      // carries the "Haptics" label is the toggled switch itself.
      final node = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Haptics')),
      );
      expect(node.getSemanticsData().flagsCollection.isToggled, isTrue);
      handle.dispose();
      // Sound is not wired: no fake toggle.
      expect(
        find.byKey(const Key('act0_academy_settings_leaf_sound')),
        findsNothing,
      );
    });

    testWidgets('no wired settings means no toggles and no saved claim', (
      tester,
    ) async {
      await _pump(
        tester,
        const Act0AcademySettingsLeafV1(
          input: Act0AcademySettingsLeafInputV1(),
        ),
      );
      expect(find.byType(Switch), findsNothing);
      expect(
        find.byKey(const Key('act0_academy_settings_leaf_saved_note')),
        findsNothing,
      );
      expect(find.text('Privacy Policy'), findsNothing);
    });

    testWidgets('support, legal and learning rows use real destinations', (
      tester,
    ) async {
      final opened = <String>[];
      await _pump(
        tester,
        Act0AcademySettingsLeafV1(
          input: Act0AcademySettingsLeafInputV1(
            onReplayWelcome: () => opened.add('welcome'),
            onRetakePlacement: () => opened.add('placement'),
            onOpenPrivacy: () => opened.add('privacy'),
            onOpenTerms: () => opened.add('terms'),
          ),
        ),
      );
      for (final id in ['welcome', 'placement', 'privacy', 'terms']) {
        final finder = find.byKey(Key('act0_academy_settings_leaf_$id'));
        await _reveal(tester, finder);
        await tester.tap(finder);
      }
      expect(opened, ['welcome', 'placement', 'privacy', 'terms']);
    });

    testWidgets('load failure offers retry, never stale toggles', (
      tester,
    ) async {
      var retries = 0;
      await _pump(
        tester,
        Act0AcademySettingsLeafV1(
          input: Act0AcademySettingsLeafInputV1(
            loadState: Act0AcademySettingsLoadStateV1.failed,
            onHapticsChanged: (_) {},
            onRetryLoad: () => retries++,
          ),
        ),
      );
      expect(find.byType(Switch), findsNothing);
      await tester.tap(
        find.byKey(const Key('act0_academy_settings_leaf_retry')),
      );
      expect(retries, 1);
    });
  });
}
