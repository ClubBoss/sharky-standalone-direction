import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_accessibility_semantics_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_growth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

Act0BlockCompletionSummaryV1 _summary({
  bool world = true,
  bool completed = true,
  bool verified = true,
  bool openMistake = false,
  int errors = 0,
  int assists = 0,
  int xp = 12,
}) => Act0BlockCompletionSummaryV1(
  lessonTitle: 'Private fixture name',
  sharkyLine: 'Private fixture answer',
  xpEarned: xp,
  errorCount: errors,
  assistedCount: assists,
  independentProvenanceKnown: verified,
  curriculumCompleted: completed,
  taskCount: 2,
  correctCount: 2 - errors,
  startLevel: 1,
  endLevel: 1,
  startXp: 0,
  endXp: xp,
  xpTarget: 100,
  worldNumber: 1,
  worldTitle: 'Private fixture history',
  milestoneTier: world
      ? Act0ProgressMilestoneTierV1.world
      : Act0ProgressMilestoneTierV1.lesson,
  hasSafeReviewTarget: openMistake,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() {
    messenger.setMockMethodCallHandler(shareChannel, null);
    messenger.setMockMethodCallHandler(act0GrowthChannelV1, null);
  });

  testWidgets('cold Learn link and warm fallback use the existing shell tabs', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    messenger.setMockMethodCallHandler(act0GrowthChannelV1, (call) async {
      expect(call.method, 'takeLink');
      return 'sharky://open/v1/learn';
    });
    await tester.pumpWidget(
      const MaterialApp(
        home: Act0ShellPreviewScreenV1(
          showPlacementOnStart: false,
          enableBetaMetrics: false,
          debugSessionDrillRecheckQueueItemsV1: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    String selectedTabLabel() => tester
        .widgetList<Act0SemanticActionV1>(
          find.descendant(
            of: find.byKey(const Key('act0_shell_bottom_nav')),
            matching: find.byType(Act0SemanticActionV1),
          ),
        )
        .singleWhere((tab) => tab.selected == true)
        .label;
    expect(selectedTabLabel(), 'Learn');

    await messenger.handlePlatformMessage(
      act0GrowthChannelV1.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('openLink', 'sharky://open/v0/learn'),
      ),
      null,
    );
    await tester.pumpAndSettle();
    expect(selectedTabLabel(), 'Home');
  });

  testWidgets(
    'summary previews the exact public payload before native sharing',
    (tester) async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(shareChannel, (call) async {
        calls.add(call);
        return null;
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0BlockCompletionShellV1(
              summary: _summary(),
              canShareResult: true,
              onContinue: () {},
              onBackToMap: () {},
            ),
          ),
        ),
      );
      final shareResult = find.text('Share result');
      await tester.scrollUntilVisible(
        shareResult,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(shareResult);
      await tester.pumpAndSettle();
      const publicText =
          'I completed a poker lesson in Sharky.\nsharky://open/v1/learn';
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(publicText),
        ),
        findsOneWidget,
      );
      expect(calls, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      await tester.tap(shareResult);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(calls.single.method, 'share');
      expect(calls.single.arguments['text'], publicText);
    },
  );

  test(
    'only a newly earned, clean and verified world completion qualifies',
    () {
      expect(
        act0IsStoreReviewMilestoneV1(_summary(), hadRunMistake: false),
        isTrue,
      );
      expect(
        act0IsStoreReviewMilestoneV1(_summary(), hadRunMistake: true),
        isFalse,
      );
      for (final summary in [
        _summary(world: false),
        _summary(completed: false),
        _summary(verified: false),
        _summary(errors: 1),
        _summary(assists: 1),
        _summary(openMistake: true),
        _summary(xp: 0),
      ]) {
        expect(
          act0IsStoreReviewMilestoneV1(summary, hadRunMistake: false),
          isFalse,
        );
      }
    },
  );

  testWidgets(
    'review skips hidden and stale summaries and caps a dismissed request',
    (tester) async {
      final calls = <String>[];
      messenger.setMockMethodCallHandler(act0GrowthChannelV1, (call) async {
        calls.add(call.method);
        // StoreKit reports neither a rating nor whether it showed a prompt.
        return null;
      });
      final now = DateTime.utc(2026, 11, 23);
      var summaryVisible = false;
      final review = Act0StoreReviewV1();
      await review.requestAfterMilestone(
        now: now,
        canPresent: () => summaryVisible,
      );
      expect(calls, isEmpty);

      // Navigate away while opening the preference store.
      summaryVisible = true;
      final stale = review.requestAfterMilestone(
        now: now,
        canPresent: () => summaryVisible,
      );
      summaryVisible = false;
      await stale;
      expect(calls, isEmpty);

      summaryVisible = true;
      Future<void> attempt(DateTime date) => Act0StoreReviewV1()
          .requestAfterMilestone(now: date, canPresent: () => summaryVisible);
      await attempt(now);
      await attempt(now.add(const Duration(days: 179)));
      await attempt(now.subtract(const Duration(days: 1)));
      expect(calls, ['requestReview']);
      await attempt(now.add(Act0StoreReviewV1.cooldown));
      expect(calls, ['requestReview', 'requestReview']);
    },
  );

  test('a failed native request still consumes the cap', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(act0GrowthChannelV1, (call) async {
      calls++;
      throw PlatformException(code: 'unavailable');
    });
    final now = DateTime.utc(2026, 11, 23);
    await Act0StoreReviewV1().requestAfterMilestone(
      now: now,
      canPresent: () => true,
    );
    await Act0StoreReviewV1().requestAfterMilestone(
      now: now,
      canPresent: () => true,
    );
    expect(calls, 1);
  });
}
