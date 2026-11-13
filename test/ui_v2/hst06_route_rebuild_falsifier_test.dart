// White-box lifecycle falsifier, not evidence of a reachable user double tap.
// Deliberately tests the known per-build callback guard boundary.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'hst06_review_route_proposal_test.dart' as fixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'rebuild falsifier: new callback should not stack another private editor',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final observer = fixture.RouteObserverProbe();
      final rebuild = ValueNotifier<int>(0);
      addTearDown(rebuild.dispose);
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: Scaffold(
            body: ValueListenableBuilder<int>(
              valueListenable: rebuild,
              builder: (context, value, child) => act0AcademyReviewRuntimeV1(
                context,
                legacy: Act0ReviewShellV1(
                  review: fixture.review,
                  selected: null,
                  onSelected: (_) {},
                ),
                isCurrent: () => true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final old = fixture.callback(tester);
      old();
      await tester.pumpAndSettle();
      rebuild.value++;
      await tester.pumpAndSettle();
      final refreshed = tester
          .widget<Act0AcademyReviewLeafV1>(
            find.byType(Act0AcademyReviewLeafV1, skipOffstage: false),
          )
          .input
          .onOpenPersonalHands!;
      // This simulates retained/cross-rebuild dispatch, not tapping through an opaque route.
      refreshed();
      await tester.pumpAndSettle();
      expect(
        observer.personalPushes,
        1,
        reason: 'Fails if the in-flight guard was reset by adapter rebuild.',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      refreshed();
      await tester.pumpAndSettle();
      expect(observer.personalPushes, 2, reason: 'Close must allow reopening.');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      refreshed();
      old();
      await tester.pumpAndSettle();
      expect(
        observer.personalPushes,
        2,
        reason: 'Unmounted callbacks are inert.',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
