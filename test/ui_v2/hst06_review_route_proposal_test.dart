// Private adapter integration tests, not AppRoot or native route evidence.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_screen_v1.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';

const review = Act0ReviewStateV1(
  title: 'Review',
  subtitle: '',
  weaknessLabel: '',
  reason: '',
  stats: [],
  chosenLabel: '',
  betterLabel: '',
);
const synthetic =
    r'''PokerStars Hand #42: Hold'em No Limit ($0.01/$0.02 USD) - 2026/01/01
Table 'Synthetic' 2-max Seat #1 is the button
Seat 1: Alice ($1.00 in chips)
Seat 2: Bob ($2.00 in chips)
*** HOLE CARDS ***
Dealt to Alice [Ah Kd]
Alice: calls $0.02
Bob: checks
*** SUMMARY ***
Total pot $0.04 | Rake $0.00''';

class RouteObserverProbe extends NavigatorObserver {
  int personalPushes = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/personal-hands') personalPushes++;
  }
}

Future<Map<String, Object?>> snapshot() async {
  final prefs = await SharedPreferences.getInstance();
  return {for (final key in prefs.getKeys()) key: prefs.get(key)};
}

Future<void> mount(
  WidgetTester tester,
  bool Function() current,
  RouteObserverProbe observer,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: [observer],
      home: Scaffold(
        body: Builder(
          builder: (context) => act0AcademyReviewRuntimeV1(
            context,
            legacy: Act0ReviewShellV1(
              review: review,
              selected: null,
              onSelected: (_) {},
            ),
            isCurrent: current,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

VoidCallback callback(WidgetTester tester) => tester
    .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
    .input
    .onOpenPersonalHands!;

Future<void> open(WidgetTester tester) async {
  final cta = find.byKey(const Key('act0_academy_review_leaf_personal_hands'));
  await tester.scrollUntilVisible(cta, 200);
  await tester.pumpAndSettle();
  await tester.tap(cta);
  await tester.pumpAndSettle();
  expect(find.byType(Hst06PersonalHandScreen), findsOneWidget);
}

Future<void> preview(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).first, synthetic);
  await tester.tap(find.byKey(const Key('hst06-preview-button')));
  await tester.pumpAndSettle();
  expect(find.textContaining('Hero cards: Ah Kd'), findsOneWidget);
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'unrelated_xp_sentinel': 30,
      'unrelated_completion_sentinel': '["existing-task"]',
      'unrelated_evidence_sentinel': 'keep-existing-evidence',
    }),
  );

  testWidgets(
    'adapter import preview cancel and back preserve all preferences',
    (tester) async {
      final observer = RouteObserverProbe();
      await mount(tester, () => true, observer);
      final before = await snapshot();
      await open(tester);
      await preview(tester);
      await tapKey(tester, 'hst06-cancel-0');
      expect(await Hst06PersonalStore().load(), isEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(Act0AcademyReviewLeafV1), findsOneWidget);
      expect(observer.personalPushes, 1);
      expect(await snapshot(), before);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'adapter explicit save changes only personal key and survives reopen',
    (tester) async {
      final observer = RouteObserverProbe();
      await mount(tester, () => true, observer);
      final before = await snapshot();
      await open(tester);
      await preview(tester);
      await tapKey(tester, 'hst06-confirm-0');
      expect(await Hst06PersonalStore().load(), hasLength(1));
      final after = await snapshot();
      expect(after.containsKey(Hst06PersonalStore.storageKey), isTrue);
      after.remove(Hst06PersonalStore.storageKey);
      expect(after, before);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await open(tester);
      expect(find.text('Saved personal hands: 1'), findsOneWidget);
      expect(observer.personalPushes, 2);
      expect(await Hst06PersonalStore().load(), hasLength(1));
    },
  );

  testWidgets(
    'same retained callback rejects stale and repeated launch then permits reopen',
    (tester) async {
      var current = true;
      final observer = RouteObserverProbe();
      await mount(tester, () => current, observer);
      final launch = callback(tester);
      current = false;
      launch();
      await tester.pumpAndSettle();
      expect(observer.personalPushes, 0);
      current = true;
      launch();
      launch();
      await tester.pumpAndSettle();
      expect(observer.personalPushes, 1);
      await tester.pageBack();
      await tester.pumpAndSettle();
      launch();
      await tester.pumpAndSettle();
      expect(observer.personalPushes, 2);
    },
  );

  testWidgets('disposed adapter context cannot launch from retained callback', (
    tester,
  ) async {
    final observer = RouteObserverProbe();
    await mount(tester, () => true, observer);
    final launch = callback(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    launch();
    await tester.pumpAndSettle();
    expect(observer.personalPushes, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'recovery fence blocks new launch but does not dismiss an open private editor',
    (tester) async {
      var current = true;
      final observer = RouteObserverProbe();
      await mount(tester, () => current, observer);
      final launch = callback(tester);
      final before = await snapshot();
      launch();
      await tester.pumpAndSettle();
      current = false;
      launch();
      await tester.pumpAndSettle();
      expect(observer.personalPushes, 1);
      expect(find.byType(Hst06PersonalHandScreen), findsOneWidget);
      await preview(tester);
      await tapKey(tester, 'hst06-cancel-0');
      await tester.pageBack();
      await tester.pumpAndSettle();
      launch();
      await tester.pumpAndSettle();
      expect(observer.personalPushes, 1);
      expect(await snapshot(), before);
    },
  );
}
