import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_north_star_preview_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final zeroStreakState = _withStreakDays(Act0ShellStateV1.sample, 0);

  Future<void> setReferenceViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'compile-time Home preview preserves source truth, one CTA, and fallback',
    (tester) async {
      await setReferenceViewport(tester);
      var continueCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0HomeShellV1(
              state: zeroStreakState,
              pathProgressLabel: '2 of 8 lessons complete',
              nextActionTitle: 'Fold, check, call, raise',
              nextActionSubtitle: 'Read the action before choosing a move.',
              nextActionCtaLabel: 'Continue',
              onContinue: () => continueCount++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_main_cta')), findsOneWidget);
      if (kAct0HomeNorthStarPreviewV1) {
        expect(
          find.byKey(const Key('act0_home_north_star_world_title')),
          findsOneWidget,
        );
        expect(find.text('Recall'), findsOneWidget);
        expect(find.text('Learn'), findsOneWidget);
        expect(find.text('Apply'), findsOneWidget);
        expect(find.text('25%'), findsOneWidget);
        expect(find.text('2 of 8 lessons complete'), findsOneWidget);
        expect(
          find.byKey(const Key('act0_home_north_star_streak')),
          findsNothing,
        );
        final background = tester.widget<ColoredBox>(
          find.byKey(const Key('act0_shell_home_page_background')),
        );
        expect(background.color, Act0HomeNorthStarPaletteV1.ink);
      } else {
        expect(
          find.byKey(const Key('act0_home_north_star_world_title')),
          findsNothing,
        );
        final background = tester.widget<Container>(
          find.byKey(const Key('act0_shell_home_page_background')),
        );
        expect(background.color, Act0AcademyDesignTokensV1.pageSurface);
      }

      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      expect(continueCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('preview dark chrome is Home-only at the reference viewport', (
    tester,
  ) async {
    await setReferenceViewport(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          state: zeroStreakState,
          showPlacementOnStart: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tabs = find.byKey(const Key('act0_shell_bottom_nav'));
    for (final label in <String>[
      'Home',
      'Learn',
      'Practice',
      'Review',
      'You',
    ]) {
      expect(
        find.descendant(of: tabs, matching: find.text(label)),
        findsOneWidget,
      );
    }

    if (kAct0HomeNorthStarPreviewV1) {
      expect(find.byKey(const Key('act0_shell_top_bar')), findsNothing);
      final navDecorations = tester.widgetList<DecoratedBox>(
        find.descendant(of: tabs, matching: find.byType(DecoratedBox)),
      );
      expect(
        navDecorations.any(
          (decorated) =>
              decorated.decoration is BoxDecoration &&
              (decorated.decoration as BoxDecoration).color ==
                  Act0HomeNorthStarPaletteV1.ink,
        ),
        isTrue,
        reason: 'Home navigation must share the immersive background',
      );

      await tester.tap(find.descendant(of: tabs, matching: find.text('Learn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_top_bar')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_home_north_star_world_title')),
        findsNothing,
      );
    } else {
      expect(find.byKey(const Key('act0_shell_top_bar')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_home_north_star_world_title')),
        findsNothing,
      );
    }
    expect(tester.takeException(), isNull);
  });
}

Act0ShellStateV1 _withStreakDays(Act0ShellStateV1 source, int streakDays) {
  return Act0ShellStateV1(
    courseTitle: source.courseTitle,
    courseSubtitle: source.courseSubtitle,
    levelLabel: source.levelLabel,
    xp: source.xp,
    xpTarget: source.xpTarget,
    streakDays: streakDays,
    dailyGoalLabel: source.dailyGoalLabel,
    dailyGoalValue: source.dailyGoalValue,
    pathProgressLabel: source.pathProgressLabel,
    selectedWorldId: source.selectedWorldId,
    worlds: source.worlds,
    lessons: source.lessons,
    review: source.review,
    profile: source.profile,
  );
}
