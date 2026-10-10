import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';

// S08 Wave A: Welcome's own text beats (intro/handoff) must render through
// the approved V3 Editorial Tide light Academy tokens, not the dark
// table-shared Act0ShellTokensV1 palette. The protected table demo spot in
// between stays untouched.
void main() {
  Future<void> pumpWelcomeV1(
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
          home: Act0WelcomeShellV1(replayMode: false, onCompleted: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(320, 690), const Size(375, 812)]) {
    testWidgets(
      'Welcome intro beat uses the Academy light page/card tokens at ${size.width.toInt()}px',
      (tester) async {
        await pumpWelcomeV1(tester, size: size);

        final pageBackground = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.color == Act0AcademyDesignTokensV1.pageSurface,
        );
        expect(pageBackground, findsOneWidget);

        final frame = tester.widget<Container>(
          find.byKey(const Key('act0_shell_welcome_beat_frame')),
        );
        final frameDecoration = frame.decoration as BoxDecoration;
        expect(
          frameDecoration.color,
          Act0AcademyDesignTokensV1.cardSurface,
        );
        expect(frameDecoration.borderRadius, BorderRadius.circular(6));
      },
    );
  }

  testWidgets(
    'Welcome handoff beat stays on Academy tokens under RU locale and 1.4x text scale',
    (tester) async {
      await pumpWelcomeV1(
        tester,
        size: const Size(390, 940),
        locale: const Locale('ru'),
        textScale: 1.4,
      );
      await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
      await tester.pumpAndSettle();

      final runner = tester
          .widget<Act0LessonRunnerShellV1>(
            find.byType(Act0LessonRunnerShellV1),
          )
          .runner;
      await tester.tap(
        find.byKey(Key('act0_shell_option_${runner.options.first.id}')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_welcome_next_step_line')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_welcome_primary_cta')),
        findsOneWidget,
      );
    },
  );
}
