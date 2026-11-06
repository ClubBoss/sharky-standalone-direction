import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';

// REP-07: the default You surface must preserve the claim boundary already
// enforced on legacy Profile. These are widget falsifiers, never native proof.
void main() {
  Future<void> showYou(
    WidgetTester tester,
    Act0AcademyYouLeafInputV1 input,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Act0AcademyYouLeafV1(input: input)),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectNoMasteryClaim(WidgetTester tester) {
    final text = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();
    for (final claim in <String>[
      'mastered',
      'mastery',
      'skill level',
      'transfer confirmed',
      'retention confirmed',
      'retained',
      'skill improved',
    ]) {
      expect(text, isNot(contains(claim)), reason: claim);
    }
  }

  for (final activity in <Act0AcademyYouLeafInputV1>[
    const Act0AcademyYouLeafInputV1(levelLabel: 'Level 99', xpLine: '99999 XP'),
    const Act0AcademyYouLeafInputV1(streakDays: 30, completedTaskCount: 0),
    const Act0AcademyYouLeafInputV1(
      levelLabel: 'Level 99',
      xpLine: '99999 XP',
      streakDays: 30,
      completedTaskCount: 500,
    ),
  ]) {
    testWidgets(
      'activity (${activity.xpLine}/${activity.streakDays}) cannot imply skill',
      (tester) async {
        await showYou(tester, activity);
        expect(
          find.byKey(const Key('act0_academy_you_leaf_activity_boundary')),
          findsOneWidget,
        );
        expect(find.text('Not earned yet'), findsOneWidget);
        expect(find.text('EARNED'), findsNothing);
        expectNoMasteryClaim(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('one correct read stays one earned moment, not mastery', (
    tester,
  ) async {
    await showYou(
      tester,
      const Act0AcademyYouLeafInputV1(
        levelLabel: 'Level 2',
        xpLine: '60 XP',
        completedTaskCount: 1,
        earnedMoments: <Act0AchievementMomentViewModelV1>[
          Act0AchievementMomentViewModelV1(
            seedId: act0AchievementSeedFirstCorrectReadV1,
            label: 'First correct read',
          ),
        ],
      ),
    );
    expect(find.text('First correct read'), findsOneWidget);
    expect(find.text('1 earned'), findsOneWidget);
    expectNoMasteryClaim(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'saved repair and later evidence do not assert elapsed retention',
    (tester) async {
      await showYou(
        tester,
        const Act0AcademyYouLeafInputV1(
          completedTaskCount: 1,
          bankedRepairCount: 1,
          reinforcedRepairCount: 1,
          openRepairCount: 1,
          dueReviewCount: 1,
        ),
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_academy_you_leaf_reinforced')),
        150,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('1 repairs banked'), findsOneWidget);
      expect(find.text('1 with later supporting evidence'), findsOneWidget);
      expect(
        find.text('1 independent review due - 1 spot to repair'),
        findsOneWidget,
      );
      expectNoMasteryClaim(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a fresh profile keeps the first-read invitation', (
    tester,
  ) async {
    await showYou(
      tester,
      const Act0AcademyYouLeafInputV1(
        levelLabel: 'Level 1',
        xpLine: '0 XP',
        completedTaskCount: 0,
      ),
    );
    expect(find.text('Your journey'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_academy_you_leaf_activity_boundary')),
      findsNothing,
    );
    expectNoMasteryClaim(tester);
    expect(tester.takeException(), isNull);
  });
}
