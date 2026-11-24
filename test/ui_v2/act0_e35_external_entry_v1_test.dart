import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_accessibility_semantics_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_growth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final ios = TargetPlatformVariant.only(TargetPlatform.iOS);
  const learnLink = 'sharky://open/v1/learn';
  const reminderChannel = MethodChannel(
    'com.clubboss.sharky/practice_reminder_v1',
  );
  int takes = 0;

  setUp(() {
    takes = 0;
    SharedPreferences.setMockInitialValues({});
    messenger.setMockMethodCallHandler(reminderChannel, (_) async => false);
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(reminderChannel, null);
    messenger.setMockMethodCallHandler(act0GrowthChannelV1, null);
  });

  Future<void> mount(
    WidgetTester tester, {
    String? pending,
    bool legacyPlacement = false,
  }) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    messenger.setMockMethodCallHandler(act0GrowthChannelV1, (call) async {
      expect(call.method, 'takeLink');
      takes++;
      final link = pending;
      pending = null;
      return link;
    });
    // AppRoot uses the production InkRipple theme and the real entry gate.
    await tester.pumpWidget(
      AppRoot(debugLegacyPlacementOnStart: legacyPlacement),
    );
    await tester.pumpAndSettle();
    expect(takes, 1);
  }

  Future<void> openLink(WidgetTester tester) async {
    await messenger.handlePlatformMessage(
      act0GrowthChannelV1.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('openLink', learnLink),
      ),
      null,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    expect(finder.hitTestable(), findsOneWidget);
    await tester.tap(finder.hitTestable());
    await tester.pumpAndSettle();
  }

  final basics = find.byKey(const Key('act0_shell_w1_start_basics'));
  final back = find.byKey(const Key('act0_shell_runner_back'));
  final runnerFinder = find.byType(Act0LessonRunnerShellV1);
  Act0LessonRunnerShellV1 runner(WidgetTester tester) =>
      tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
  String selectedTab(WidgetTester tester) => tester
      .widgetList<Act0SemanticActionV1>(
        find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.byType(Act0SemanticActionV1),
        ),
      )
      .singleWhere((tab) => tab.selected == true)
      .label;

  Future<void> closeRunnerAndExpectLearn(WidgetTester tester) async {
    await tap(tester, back);
    expect(selectedTab(tester), 'Learn');
    expect(takes, 1, reason: 'The queued link must not be fetched again.');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('E35 cold link waits for the real first-start gate', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await mount(tester, pending: learnLink);
      expect(basics, findsOneWidget);
      await tap(tester, basics);
      expect(runnerFinder, findsOneWidget);
      await closeRunnerAndExpectLearn(tester);
    } finally {
      semantics.dispose();
    }
  }, variant: ios);

  testWidgets(
    'E35 warm link preserves the active answer and defers navigation',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await mount(tester);
        await tap(tester, basics);
        await tester.pump(const Duration(seconds: 1));
        await tap(tester, find.text('Next'));
        await tap(tester, find.text('The shared cards in the middle'));
        final before = runner(tester);
        expect(before.runner.selectedOptionId, isNotNull);
        expect(before.runner.phase, Act0LessonPhaseV1.review);
        await openLink(tester);
        final after = runner(tester);
        expect(after.selectedLessonId, before.selectedLessonId);
        expect(after.selectedTaskId, before.selectedTaskId);
        expect(after.runner.phase, before.runner.phase);
        expect(after.runner.selectedOptionId, before.runner.selectedOptionId);
        expect(after.runner.reviewQuality, before.runner.reviewQuality);
        expect(find.text('Try same clue'), findsOneWidget);
        await closeRunnerAndExpectLearn(tester);
      } finally {
        semantics.dispose();
      }
    },
    variant: ios,
  );

  testWidgets('E35 warm link during placement is not dropped', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await mount(tester, legacyPlacement: true);
      final placement = find.byKey(const Key('act0_shell_placement_intro_cta'));
      expect(placement, findsOneWidget);
      await openLink(tester);
      expect(placement, findsOneWidget);
      expect(runnerFinder, findsNothing);
      await tap(
        tester,
        find.byKey(const Key('act0_shell_placement_skip_intro')),
      );
      expect(placement, findsNothing);
      expect(selectedTab(tester), 'Learn');
      expect(takes, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  }, variant: ios);

  testWidgets(
    'E35 practice reminder tap (blocked: no inbound tap bridge in #827)',
    (_) async {},
    skip: true, // #827 merged, but the channel has no inbound tap event.
  );
}
