import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

void main() {
  testWidgets(
    'DAT06 ordinary unreadable progress offers recovery and cancel writes nothing',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        'act0_shell_progress_v1': 'unreadable synthetic machine fixture',
        'act0_shell_progress_v1_head': '{invalid',
        'act0_shell_progress_v1_recovery': true,
        'act0_shell_progress_v1_backup': 41,
        'unrelated_setting': 'keep',
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
      });
      final prefs = await SharedPreferences.getInstance();
      Map<String, Object?> values() => {
        for (final k in prefs.getKeys()) k: prefs.get(k),
      };
      final before = values();
      await tester.pumpWidget(
        const MaterialApp(home: Act0ShellPreviewScreenV1()),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Your saved progress could not be read.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      final options = find.byKey(const Key('act0_recovery_options'));
      expect(options, findsOneWidget);
      await tester.tap(options);
      await tester.pumpAndSettle();
      expect(find.textContaining('may not be restorable'), findsWidgets);
      await tester.tap(find.byKey(const Key('act0_recovery_cancel')));
      await tester.pumpAndSettle();
      await prefs.reload();
      expect(values(), before);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(values(), before);
    },
  );
}
