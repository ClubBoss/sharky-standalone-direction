// Real UI reset with an offstage first-start host; widget proof, not native.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';

void main() {
  testWidgets(
    'reset retires mounted questionnaire callbacks without resurrecting choices',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Widget hosts({required bool resetter, bool old = true}) => Stack(
        alignment: Alignment.topLeft,
        children: [
          if (old)
            Offstage(
              offstage: resetter,
              child: TickerMode(
                enabled: !resetter,
                child: MaterialApp(
                  key: const ValueKey('questionnaire-A'),
                  home: const Act0ShellPreviewScreenV1(),
                ),
              ),
            ),
          if (resetter)
            MaterialApp(
              key: const ValueKey('resetter-B'),
              home: const Act0ShellPreviewScreenV1(showPlacementOnStart: false),
            ),
        ],
      );
      Future<void> tap(String key) async {
        final f = find.byKey(Key(key));
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        expect(f.hitTestable(), findsOneWidget);
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(hosts(resetter: false));
      await tester.pumpAndSettle();
      await tap('act0_shell_placement_intro_cta');
      await tap('act0_shell_placement_option_friends');
      await tap('act0_shell_placement_next_cta');
      final initial = tester.widget<Act0PlacementShellV1>(
        find.byType(Act0PlacementShellV1),
      );
      expect(initial.currentQuestionIndex, 1);
      expect(initial.selectedOptionIds['experience'], {'friends'});
      final staleNext = initial.onNext;
      await tester.pumpWidget(hosts(resetter: true));
      await tester.pumpAndSettle();
      expect(
        find.byType(Act0ShellPreviewScreenV1, skipOffstage: false),
        findsNWidgets(2),
      );
      await tap('act0_academy_home_leaf_dev_menu');
      await tap('act0_shell_dev_menu_reset_progress');
      await tap('act0_shell_dev_menu_reset_confirm');
      staleNext();
      await tester.pumpAndSettle();
      await tester.pumpWidget(hosts(resetter: true, old: false));
      await tester.pumpAndSettle();
      final canonical = Act0ProgressStoreV1(
        key: 'act0_shell_progress_v1',
        isValidPayload: (_) => true,
      );
      await tester.runAsync(
        () => canonical.flush().timeout(const Duration(seconds: 2)),
      );
      final resetSnapshot = await tester.runAsync(
        () =>
            canonical.readDurableSnapshot().timeout(const Duration(seconds: 2)),
      );
      expect(
        resetSnapshot!.payload,
        isNotNull,
        reason: 'Reset initiator retains canonical fresh-write capability',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        MaterialApp(home: Act0ShellPreviewScreenV1(key: UniqueKey())),
      );
      await tester.pumpAndSettle();
      final fresh = tester.widget<Act0PlacementShellV1>(
        find.byType(Act0PlacementShellV1),
      );
      expect(fresh.showIntro, isTrue);
      expect(fresh.currentQuestionIndex, 0);
      expect(fresh.selectedOptionIds, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('intake_completed_v1') ?? false, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
