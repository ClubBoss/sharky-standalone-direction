// ONB01 interruption falsifier. Widget-host remount, NOT native process restart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';

void main() {
  testWidgets(
    'interrupted questionnaire resumes page and actual choice without completion',
    (tester) async {
      SharedPreferences.setMockInitialValues({'onb01_unrelated': 'keep'});
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Future<void> mount() async {
        await tester.pumpWidget(
          MaterialApp(home: Act0ShellPreviewScreenV1(key: UniqueKey())),
        );
        await tester.pumpAndSettle();
      }

      Future<void> tap(String key) async {
        final target = find.byKey(Key(key));
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      Act0PlacementShellV1 placement() => tester.widget<Act0PlacementShellV1>(
        find.byType(Act0PlacementShellV1),
      );
      await mount();
      await tap('act0_shell_placement_intro_cta');
      await tap('act0_shell_placement_option_friends');
      await tap('act0_shell_placement_next_cta');
      expect(placement().showIntro, isFalse);
      expect(placement().currentQuestionIndex, 1);
      expect(placement().selectedOptionIds['experience'], {'friends'});
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('intake_completed_v1') ?? false, isFalse);
      expect(prefs.getBool('act0_welcome_completed_v1') ?? false, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      // Reuse actual mockbackend bytes: no seed, debugpersist, state injection.
      await mount();
      expect(
        placement().showIntro,
        isFalse,
        reason: 'Return to saved questionnaire place, not restart intro.',
      );
      expect(placement().currentQuestionIndex, 1);
      expect(placement().selectedOptionIds['experience'], {'friends'});
      expect(prefs.getBool('intake_completed_v1') ?? false, isFalse);
      expect(prefs.getBool('act0_welcome_completed_v1') ?? false, isFalse);
      expect(prefs.getString('onb01_unrelated'), 'keep');
      expect(tester.takeException(), isNull);
    },
  );
}
