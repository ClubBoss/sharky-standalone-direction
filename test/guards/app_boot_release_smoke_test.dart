import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boot entry stays on the canonical Act0 shell', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
    });

    await tester.pumpWidget(const AppRoot());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.byType(Act0ShellPreviewScreenV1), findsOneWidget);
  });
}
