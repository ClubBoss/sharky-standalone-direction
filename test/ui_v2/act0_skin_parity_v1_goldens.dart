// Run explicitly. Reference images live under ignored output/b32_skin/.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef _Surface = Act0ControlledDemoCaptureSurfaceV1;

void main() {
  const cases = <(String, _Surface, String)>[
    ('home', _Surface.home, 'act0_academy_home_leaf'),
    ('map', _Surface.learn, 'act0_shell_learn_screen'),
    ('lesson_intro', _Surface.runnerTheory, 'act0_shell_runner_screen'),
    ('result', _Surface.sessionSummary, 'act0_shell_block_summary_card'),
    ('review', _Surface.review, 'act0_academy_review_leaf'),
    ('profile', _Surface.profile, 'act0_academy_you_leaf'),
  ];
  const captureKey = Key('b32_visual_capture');

  for (final (name, surface, marker) in cases) {
    for (final (scale, suffix) in [(1.0, '100'), (1.3, '130')]) {
      testWidgets('$name at ${scale}× text', (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(393, 852);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          RepaintBoundary(
            key: captureKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData.dark(
                useMaterial3: true,
              ).copyWith(splashFactory: InkRipple.splashFactory),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: Act0ShellPreviewScreenV1(
                enableBetaMetrics: false,
                debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
                  mode: Act0ControlledDemoCaptureModeV1.directState,
                  surface: surface,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(Key(marker)), findsOneWidget);
        if (surface == _Surface.runnerTheory) {
          final runner = tester.widget<Act0LessonRunnerShellV1>(
            find.byType(Act0LessonRunnerShellV1),
          );
          expect(runner.selectedTaskId, 'what_poker_is_theory');
          expect(runner.runner.phase, Act0LessonPhaseV1.theory);
        }
        await expectLater(
          find.byKey(captureKey),
          matchesGoldenFile('../../output/b32_skin/${name}_$suffix.png'),
        );
      });
    }
  }
}
