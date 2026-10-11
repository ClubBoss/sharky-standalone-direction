import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(
    WidgetTester tester,
    Widget child,
    Size size, {
    String language = 'ru',
    double scale = 1.4,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(language),
        supportedLocales: const [Locale('en'), Locale('ru')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Put the scaler below MaterialApp, as in the real native view.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: child,
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 375.0]) {
    testWidgets('complete RU Home instruction and CTA at $width / 1.4x', (
      tester,
    ) async {
      var activated = false;
      const instruction =
          '\u0421\u043d\u0430\u0447\u0430\u043b\u0430 \u043f\u0440\u043e\u0447\u0438\u0442\u0430\u0439 \u0434\u043e\u0441\u0442\u0443\u043f\u043d\u044b\u0435 \u0434\u0435\u0439\u0441\u0442\u0432\u0438\u044f, \u0447\u0442\u043e\u0431\u044b \u043f\u0435\u0440\u0432\u0430\u044f \u0440\u0435\u0430\u043b\u044c\u043d\u0430\u044f \u0440\u0430\u0437\u0434\u0430\u0447\u0430 \u043d\u0435 \u0431\u044b\u043b\u0430 \u0443\u0433\u0430\u0434\u044b\u0432\u0430\u043d\u0438\u0435\u043c.';
      await pump(
        tester,
        Scaffold(
          body: Act0HomeShellV1(
            state: Act0ShellStateV1.sample,
            nextActionHint: instruction,
            pathProgressLabel: '0 of 9 lessons complete',
            onContinue: () => activated = true,
          ),
        ),
        Size(width, 667),
      );
      final text = find.byKey(
        const Key('act0_shell_home_next_action_subtitle'),
      );
      expect(tester.widget<Text>(text).data, instruction);
      expect(
        tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
        isFalse,
      );
      expect(find.text('Poker from Zero'), findsNothing);
      expect(find.text("Today's table read"), findsNothing);
      expect(find.text('Sharky has one table clue ready.'), findsNothing);
      expect(find.text('Learning path'), findsNothing);
      expect(find.text('Current lesson is above.'), findsNothing);
      expect(find.text('0 of 9 lessons complete'), findsNothing);
      final cta = find.byKey(const Key('act0_shell_main_cta'));
      await tester.ensureVisible(cta);
      await tester.pumpAndSettle();
      await tester.tap(cta);
      expect(activated, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('real RU Learn locale, Worlds owner and activation at $width', (
      tester,
    ) async {
      await pump(
        tester,
        const Act0ShellPreviewScreenV1(
          initialTab: Act0ShellTabV1.learn,
          showPlacementOnStart: false,
        ),
        Size(width, 667),
      );
      expect(find.text('First Table Guide'), findsNothing);
      expect(find.text('Poker from Zero'), findsNothing);
      expect(find.text("Today's table read"), findsNothing);
      expect(find.text('Sharky has one table clue ready.'), findsNothing);
      expect(find.text('Learning path'), findsNothing);
      expect(find.text('Current lesson is above.'), findsNothing);
      expect(
        find.text(
          '\u041f\u0435\u0440\u0432\u044b\u0439 \u0440\u0430\u0437\u0431\u043e\u0440 \u0441\u0442\u043e\u043b\u0430',
        ),
        findsOneWidget,
      );
      final heading = find.byKey(const Key('act0_shell_current_mission_card'));
      expect(
        MediaQuery.textScalerOf(tester.element(heading)).scale(14),
        closeTo(19.6, .001),
      );
      final semantics = tester.ensureSemantics();
      await tester.pump();
      final worlds = find.bySemanticsLabel(
        '\u041e\u0442\u043a\u0440\u044b\u0442\u044c \u043c\u0438\u0440\u044b',
      );
      expect(worlds, findsOneWidget);
      expect(
        tester.getSemantics(worlds),
        matchesSemantics(
          label:
              '\u041e\u0442\u043a\u0440\u044b\u0442\u044c \u043c\u0438\u0440\u044b',
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(tester.getSize(worlds).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(worlds).height, greaterThanOrEqualTo(48));
      await tester.tap(worlds);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_levels_menu')), findsOneWidget);
      semantics.dispose();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'RU Welcome scrolls to an honest acknowledged handoff at $width',
      (tester) async {
        var completed = false;
        await pump(
          tester,
          Act0WelcomeShellV1(
            replayMode: false,
            onCompleted: () => completed = true,
          ),
          Size(width, 667),
        );
        final cta = find.byKey(const Key('act0_shell_welcome_primary_cta'));
        await tester.ensureVisible(cta);
        await tester.pumpAndSettle();
        await tester.tap(cta);
        await tester.pumpAndSettle();
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        // Academy large text must not alter the protected Welcome Table.
        expect(
          MediaQuery.textScalerOf(
            tester.element(find.byType(Act0LessonRunnerShellV1)),
          ).scale(14),
          14,
        );
        final wrong = runner.runner.options.firstWhere(
          (option) => !option.isCorrect,
        );
        // The same ungraded callback handles every option, without assessment.
        runner.onChooseOption(wrong);
        await tester.pumpAndSettle();
        expect(find.textContaining('This preview was ungraded'), findsNothing);
        expect(
          find.textContaining(
            '\u0422\u0432\u043e\u0439 \u0432\u044b\u0431\u043e\u0440:',
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('act0_shell_feedback_continue_cta')),
          findsNothing,
        );
        await tester.ensureVisible(cta);
        await tester.pumpAndSettle();
        await tester.tap(cta);
        expect(completed, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('current authored theory RU meaning and unknown-copy failback', (
    tester,
  ) async {
    await pump(
      tester,
      Builder(
        builder: (context) {
          return Text(
            act0AcademyTeachingCopyV1(
              context,
              runnerLessonId: 'first_table_guide_meet_table',
              source: 'One loop first.',
              fallback: 'old task copy',
            ),
          );
        },
      ),
      const Size(375, 812),
    );
    expect(find.text('old task copy'), findsNothing);
    final context = tester.element(find.byType(Text).first);
    expect(
      act0AcademyTeachingCopyV1(
        context,
        runnerLessonId: 'first_table_guide_meet_table',
        source: 'changed source',
        fallback: 'old task copy',
      ),
      'changed source',
    );
    expect(
      act0AcademyProgressLabelV1(context, 'technical_id_9'),
      'technical_id_9',
    );
  });
}
