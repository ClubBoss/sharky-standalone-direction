import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// S10 Lean: the You tab entry must say what it opens (first-start tools, not a
// phantom account area), and the Home primary CTA must be reachable in the
// first viewport of an ordinary standard phone (390x844) and a compact phone.
void main() {
  Future<void> setSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('You entry is honest and keeps progress when opened', (
    tester,
  ) async {
    await setSize(tester, const Size(390, 844));
    var retaken = 0;
    var replayed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0ProfileShellV1(
            profile: Act0ShellStateV1.sample.profile,
            onRetakePlacement: () => retaken++,
            onReplayWelcome: () => replayed++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final row = find.byKey(
      const Key('act0_shell_profile_first_start_tools_button'),
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      row,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    expect(find.text('Intro & placement'), findsOneWidget);
    expect(find.textContaining('Account'), findsNothing);
    expect(find.textContaining('notifications'), findsNothing);
    expect(find.textContaining('Your progress stays'), findsOneWidget);

    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_profile_first_start_tools')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_profile_retake_placement')),
    );
    await tester.pumpAndSettle();
    expect(retaken, 1);
    expect(replayed, 0);
  });

  for (final size in [const Size(390, 844), const Size(360, 640)]) {
    testWidgets('Home primary CTA is inside the first viewport at '
        '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      await setSize(tester, size);
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0HomeShellV1(
              state: Act0ShellStateV1.sample,
              pathProgressLabel: '1 of 9 lessons complete',
              onContinue: () => taps++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final cta = find.byKey(const Key('act0_shell_main_cta'));
      expect(cta, findsOneWidget);
      final rect = tester.getRect(cta);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(size.height));
      await tester.tap(cta);
      expect(taps, 1);
    });
  }
}
