import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pumpDebugSurface(
    WidgetTester tester, {
    required Act0ControlledDemoCaptureSurfaceV1 surface,
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Act0ShellPreviewScreenV1(
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: surface,
            worldId: 'world_12',
            lessonId: 'tilt_reset_protocol',
            taskId: 'w12_after_mistake_reset',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'practice repair runner fills the tablet gap between table and dock',
    (tester) async {
      await pumpDebugSurface(
        tester,
        surface: Act0ControlledDemoCaptureSurfaceV1.day2PracticeRepairTarget,
        size: const Size(834, 1194),
      );

      final table = find.byKey(const Key('act0_shell_table'));
      final dock = find.byKey(const Key('act0_shell_runner_action_dock'));

      expect(table, findsOneWidget);
      expect(dock, findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_runner_envelope_repairFill')),
        findsOneWidget,
      );

      final tableRect = tester.getRect(table);
      final dockRect = tester.getRect(dock);
      final viewportHeight = tester.view.physicalSize.height;

      expect(tableRect.height, greaterThan(430));
      expect(dockRect.top - tableRect.bottom, lessThanOrEqualTo(96));
      expect(dockRect.top, lessThan(viewportHeight * 0.76));
      expect(dockRect.bottom, lessThanOrEqualTo(viewportHeight));
    },
  );

  testWidgets(
    'tablet placement intro extends useful content toward the action bar',
    (tester) async {
      await pumpDebugSurface(
        tester,
        surface: Act0ControlledDemoCaptureSurfaceV1.placement,
        size: const Size(834, 1194),
      );

      final intro = find.byKey(const Key('act0_shell_placement_intro_card'));
      final fill = find.byKey(const Key('act0_shell_placement_tablet_fill'));
      final actionBar = find.byKey(
        const Key('act0_shell_placement_flow_action_bar'),
      );
      final cta = find.byKey(const Key('act0_shell_placement_intro_cta'));

      expect(intro, findsOneWidget);
      expect(fill, findsOneWidget);
      expect(actionBar, findsOneWidget);
      expect(cta, findsOneWidget);

      final fillRect = tester.getRect(fill);
      final actionBarRect = tester.getRect(actionBar);
      final ctaRect = tester.getRect(cta);
      final viewportHeight = tester.view.physicalSize.height;

      expect(fillRect.bottom, greaterThan(viewportHeight * 0.62));
      expect(actionBarRect.top - fillRect.bottom, lessThanOrEqualTo(260));
      expect(ctaRect.bottom, lessThanOrEqualTo(viewportHeight));
    },
  );

  testWidgets(
    'tablet welcome uses a wide content frame while compact stays bounded',
    (tester) async {
      await pumpDebugSurface(
        tester,
        surface: Act0ControlledDemoCaptureSurfaceV1.welcome,
        size: const Size(834, 1194),
      );

      final tabletFrame = find.byKey(
        const Key('act0_shell_welcome_beat_frame'),
      );
      final tabletCta = find.byKey(const Key('act0_shell_welcome_primary_cta'));
      expect(tabletFrame, findsOneWidget);
      expect(tabletCta, findsOneWidget);
      final tabletFrameRect = tester.getRect(tabletFrame);
      final tabletCtaRect = tester.getRect(tabletCta);
      expect(tabletFrameRect.width, greaterThanOrEqualTo(700));
      expect(tabletFrameRect.height, greaterThanOrEqualTo(440));
      expect(
        tabletCtaRect.top - tabletFrameRect.bottom,
        lessThanOrEqualTo(220),
      );
      expect(tabletCtaRect.bottom, lessThanOrEqualTo(1194));

      await pumpDebugSurface(
        tester,
        surface: Act0ControlledDemoCaptureSurfaceV1.welcome,
        size: const Size(375, 812),
      );

      final compactFrame = find.byKey(
        const Key('act0_shell_welcome_beat_frame'),
      );
      final compactCta = find.byKey(
        const Key('act0_shell_welcome_primary_cta'),
      );
      expect(compactFrame, findsOneWidget);
      expect(compactCta, findsOneWidget);
      expect(tester.getSize(compactFrame).width, lessThanOrEqualTo(420));
      expect(tester.getRect(compactCta).bottom, lessThanOrEqualTo(812));
    },
  );

  test(
    'product proof tool uses semantic W12 terminal capture and byte guard',
    () {
      final source = File(
        'tools/act0_product_100_proof_capture_v1.dart',
      ).readAsStringSync();

      expect(source, contains('compareTerminalProofBytesV1'));
      expect(source, contains('validateTerminalSemanticEvidenceV1'));
      expect(
        source,
        contains('Act0ControlledDemoCaptureSurfaceV1.w12Terminal'),
      );
      expect(
        source,
        isNot(
          contains(
            "'w12_terminal',\n        () async {},\n        false,\n        Act0ShellTabV1.play,\n        Act0ControlledDemoCaptureSurfaceV1.runnerDrill,",
          ),
        ),
      );
    },
  );
}
