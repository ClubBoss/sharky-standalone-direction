import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// S08 Wave A: Home must render through the approved V3 Editorial Tide light
// Academy tokens (same family already lifted on Welcome in PR #262), while
// keeping the real first-value contract intact: one dominant source-backed
// CTA, the current World/lesson, and the ordered task checklist, at compact
// widths and under RU x1.4.
void main() {
  Future<void> pumpHomeV1(
    WidgetTester tester, {
    required Size size,
    Locale locale = const Locale('en'),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ru')],
          home: Scaffold(
            body: Act0HomeShellV1(
              state: Act0ShellStateV1.sample,
              pathProgressLabel: '1 of 9 lessons complete',
              onContinue: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(320, 690), const Size(375, 812)]) {
    testWidgets(
      'Home uses the Academy light page/card tokens at ${size.width.toInt()}px',
      (tester) async {
        await pumpHomeV1(tester, size: size);

        final pageBackground = tester.widget<Container>(
          find.byKey(const Key('act0_shell_home_page_background')),
        );
        expect(pageBackground.color, Act0AcademyDesignTokensV1.pageSurface);

        final missionCard = tester.widget<Container>(
          find.byKey(const Key('act0_shell_home_mission_command_card')),
        );
        final missionDecoration = missionCard.decoration as BoxDecoration;
        expect(
          missionDecoration.color,
          Act0AcademyDesignTokensV1.cardSurface,
        );
        expect(missionDecoration.borderRadius, BorderRadius.circular(6));
      },
    );
  }

  testWidgets(
    'Home keeps one dominant CTA, the current World/lesson and the ordered '
    'checklist under RU locale and 1.4x text scale at 320px',
    (tester) async {
      await pumpHomeV1(
        tester,
        size: const Size(320, 760),
        locale: const Locale('ru'),
        textScale: 1.4,
      );

      // One dominant source-backed CTA.
      expect(find.byKey(const Key('act0_shell_main_cta')), findsOneWidget);

      // Current World / lesson title stays reachable and truthful.
      expect(
        find.byKey(const Key('act0_shell_home_primary_route_title')),
        findsOneWidget,
      );

      // Ordered task rows: learn (1), practice (2), review (3) survive.
      expect(
        find.byKey(const Key('act0_shell_home_checklist_row_learn')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_home_checklist_row_drill')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_home_checklist_row_review')),
        findsOneWidget,
      );

      // No overflow/render error at compact width under RU + 1.4x scale.
      expect(tester.takeException(), isNull);
    },
  );
}
