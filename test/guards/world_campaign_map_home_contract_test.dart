import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_growth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const reminderChannel = MethodChannel(
    'com.clubboss.sharky/practice_reminder_v1',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    messenger.setMockMethodCallHandler(reminderChannel, (_) async => false);
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(reminderChannel, null);
    messenger.setMockMethodCallHandler(act0GrowthChannelV1, null);
  });

  testWidgets(
    'Act0 shell owns the canonical cold /home entry contract',
    (tester) async {
      var pendingLinkTakes = 0;
      messenger.setMockMethodCallHandler(act0GrowthChannelV1, (call) async {
        expect(call.method, 'takeLink');
        pendingLinkTakes++;
        return null;
      });
      tester.binding.platformDispatcher.defaultRouteNameTestValue = '/home';
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AppRoot());
      await tester.pumpAndSettle();

      expect(
        find.byType(Act0ShellPreviewScreenV1, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_w1_start_basics')),
        findsOneWidget,
      );
      expect(pendingLinkTakes, 1);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  test('retired campaign map owner paths are not required by current route', () {
    expect(
      File('lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart').existsSync(),
      isFalse,
    );
    expect(
      File(
        'lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart',
      ).existsSync(),
      isFalse,
    );
    expect(
      File(
        'lib/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart',
      ).existsSync(),
      isTrue,
    );
  });
}
