import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_home_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_settings_leaf_v1.dart';

const _key = 'act0_shell_progress_v1';
final _store = Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true);

Future<void> _mount(
  WidgetTester tester,
  Act0ShellTabV1 tab, {
  bool priorProgress = false,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await _store.flush();
  });
  final world = Act0ShellStateV1.sample.worlds.first;
  SharedPreferences.setMockInitialValues({
    'unrelated': 'keep',
    'intake_completed_v1': true,
    'act0_welcome_completed_v1': true,
    _key: jsonEncode({
      'schemaVersion': 18,
      'completedTaskIds': priorProgress
          ? world.lessons.first.taskList.map((t) => t.taskId).toList()
          : [],
      'skippedTaskIds': [],
      'completedLessonIds': [],
      'selectedWorldId': world.worldId,
      'selectedLessonId': world.lessons.first.lessonId,
      'selectedTaskId': world.lessons.first.taskList.first.taskId,
      'earnedXp': priorProgress ? 20 : 0,
    }),
  });
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: tab,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('act0_shell_bottom_nav')),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  if (!act0AcademyHomePreviewV1) {
    test('Academy defaults preserve the accepted runtime', () {
      expect([
        act0AcademyHomePreviewV1,
        act0AcademyPracticePreviewV1,
        act0AcademyReviewPreviewV1,
        act0AcademyYouPreviewV1,
        act0AcademySettingsPreviewV1,
      ], everyElement(isFalse));
    });
    return;
  }

  test('explicit Academy activation for this integration suite', () {
    expect([
      act0AcademyHomePreviewV1,
      act0AcademyPracticePreviewV1,
      act0AcademyReviewPreviewV1,
      act0AcademyYouPreviewV1,
      act0AcademySettingsPreviewV1,
    ], everyElement(isTrue));
  });

  testWidgets(
    'real shell mounts source-backed Academy and preserves tab return',
    (tester) async {
      await _mount(tester, Act0ShellTabV1.home);
      final home = tester.widget<Act0AcademyHomeLeafV1>(
        find.byType(Act0AcademyHomeLeafV1),
      );
      expect(home.input.earnedLessonCount, 0);
      expect(home.input.nextAction, isNotNull);
      await _tab(tester, 'Practice');
      expect(
        find.byKey(const Key('act0_academy_practice_leaf')),
        findsOneWidget,
      );
      await _tab(tester, 'Review');
      final review = tester
          .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
          .input;
      expect(review.openMistakes, isEmpty);
      expect(review.dueItems, isEmpty);
      await _tab(tester, 'You');
      final you = tester
          .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
          .input;
      expect(you.completedTaskCount, 0);
      expect(you.earnedMoments, isEmpty);
      expect(you.onRecoveryOptions, isNotNull);
      await _tab(tester, 'Home');
      expect(
        tester
            .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
            .input
            .nextAction!
            .title,
        home.input.nextAction!.title,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Settings persists haptics and preserves intro and learner data',
    (tester) async {
      await _mount(tester, Act0ShellTabV1.profile);
      await tester.tap(find.byKey(const Key('act0_academy_you_leaf_settings')));
      await tester.pumpAndSettle();
      final input = tester
          .widget<Act0AcademySettingsLeafV1>(
            find.byType(Act0AcademySettingsLeafV1),
          )
          .input;
      expect(input.onRecoveryOptions, isNotNull);
      expect(input.onSoundChanged, isNull);
      final before = input.hapticsEnabled;
      await tester.tap(
        find.byKey(const Key('act0_academy_settings_leaf_haptics')),
      );
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('haptics_enabled'), !before);
      expect(prefs.getString('unrelated'), 'keep');
      expect(prefs.getBool('intake_completed_v1'), true);
      expect(prefs.getBool('act0_welcome_completed_v1'), true);
      final raw = jsonDecode((await _store.load())!) as Map;
      expect(raw['earnedXp'], 0);
      expect(raw['completedTaskIds'], isEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_academy_you_leaf_settings')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Act0AcademySettingsLeafV1>(
              find.byType(Act0AcademySettingsLeafV1),
            )
            .input
            .hapticsEnabled,
        !before,
      );
    },
  );

  testWidgets(
    'recovery clears Academy projections and fences retained navigation',
    (tester) async {
      await _mount(tester, Act0ShellTabV1.profile, priorProgress: true);
      final oldYou = tester
          .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
          .input;
      expect(
        oldYou.completedTaskCount,
        greaterThan(0),
        reason: 'Positive pre-reset completion control',
      );
      final dynamic runtime = tester.state(
        find.byType(Act0ShellPreviewScreenV1),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, 'damaged');
      await prefs.setString('${_key}_head', '{invalid');
      await prefs.setBool('${_key}_recovery', false);
      await prefs.setInt('${_key}_backup', 41);
      await tester.runAsync(
        () => runtime.debugReloadProgressV1() as Future<void>,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_options')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_confirm')));
      await tester.pumpAndSettle();
      oldYou.onOpenSettings!();
      oldYou.onOpenReview!();
      await tester.pumpAndSettle();
      expect(find.byType(Act0AcademySettingsLeafV1), findsNothing);
      await _tab(tester, 'Review');
      final review = tester
          .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
          .input;
      expect(review.openMistakes, isEmpty);
      expect(review.pastRepairs, isEmpty);
      expect(review.dueItems, isEmpty);
      expect(review.savedChecks, isEmpty);
      await _tab(tester, 'You');
      final fresh = tester
          .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
          .input;
      expect(fresh.earnedMoments, isEmpty);
      expect(fresh.completedTaskCount, 0);
      expect(fresh.openRepairCount, 0);
      expect(fresh.dueReviewCount, 0);
      expect(prefs.getString('unrelated'), 'keep');
      expect(prefs.getBool('intake_completed_v1'), true);
    },
  );

  testWidgets(
    'Review launches the current due selector target and rejects stale callback',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final due = [
        for (final id in ['oldest', 'recommended'])
          Act0DueReviewItemV1(
            conceptFamilyId: id,
            worldId: 'world_1',
            lessonId: 'lesson',
            taskId: id,
            nextDueAtUtc: DateTime.utc(2026),
            repeatedMissCount: 0,
            lapseCount: 0,
          ),
      ];
      var current = true;
      String? launched;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => act0AcademyReviewRuntimeV1(
              context,
              isCurrent: () => current,
              legacy: Act0ReviewShellV1(
                review: Act0ShellStateV1.sample.review,
                selected: null,
                onSelected: (_) {},
                dueReviewItems: due,
                nextStep: const Act0PersonalizedReturnReasonV1(
                  reasonType: 'due_review',
                  conceptFamilyId: 'recommended',
                  evidenceKind: 'durable_retention',
                  messageKey: 'due_review',
                  priorityClass: 2,
                  recommendedAction: 'spaced_review',
                  sourceTaskId: 'recommended',
                ),
                onStartDueReview: (item) => launched = item.taskId,
              ),
            ),
          ),
        ),
      );
      final leaf = tester.widget<Act0AcademyReviewLeafV1>(
        find.byType(Act0AcademyReviewLeafV1),
      );
      expect(leaf.input.dueItems.first.taskId, 'recommended');
      leaf.input.onStartDueReview!(leaf.input.dueItems.first);
      expect(launched, 'recommended');
      launched = null;
      current = false;
      leaf.input.onStartDueReview!(leaf.input.dueItems.first);
      expect(launched, isNull);
    },
  );
}
