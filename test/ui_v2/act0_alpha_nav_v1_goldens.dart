// Run explicitly. Reference images live under ignored output/b34_alpha_nav/.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef _Surface = Act0ControlledDemoCaptureSurfaceV1;

void main() {
  const cases = <(String, _Surface, String)>[
    ('learn_top_and_tabs', _Surface.learn, 'act0_shell_learn_screen'),
  ];
  const captureKey = Key('b34_alpha_nav_capture');

  for (final (name, surface, marker) in cases) {
    for (final (scale, suffix) in [(1.0, '100'), (1.3, '130')]) {
      testWidgets('$name at $scale× text', (tester) async {
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
        expect(find.byKey(const Key('act0_shell_bottom_nav')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(captureKey),
          matchesGoldenFile('../../output/b34_alpha_nav/${name}_$suffix.png'),
        );
      });
    }
  }
}
