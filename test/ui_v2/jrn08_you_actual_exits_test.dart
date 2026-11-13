import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';

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
  final target = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text(label),
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<Map<String, Object?>> _prefs(WidgetTester tester) async {
  await tester.runAsync(
    () => _store.flush().timeout(const Duration(seconds: 2)),
  );
  final p = await SharedPreferences.getInstance();
  return {for (final key in p.getKeys()) key: p.get(key)};
}

void main() {
  // Existing persisted-host harness with SYNTHETIC schema18 bootstrap.
  // Host passes required int completion count; unknown/null leaf is NOT reachable
  // through this adapter. Corrupt bootstrap is separately guarded before You.
  testWidgets('real You recovery cancel and Learn exit preserve learning', (
    tester,
  ) async {
    await _mount(tester, Act0ShellTabV1.profile);
    Act0AcademyYouLeafInputV1 you() => tester
        .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
        .input;
    expect(you().completedTaskCount, 0);
    expect(you().earnedMoments, isEmpty);
    final xp = you().xpLine;
    final before = await _prefs(tester);
    final recover = find.byKey(const Key('act0_profile_recovery_options'));
    await tester.scrollUntilVisible(
      recover,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(recover.hitTestable(), findsOneWidget);
    await tester.tap(recover);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.textContaining('Recovery copies stay on this device'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_recovery_confirm')), findsNothing);
    final cancel = find.byKey(const Key('act0_recovery_cancel'));
    expect(cancel.hitTestable(), findsOneWidget);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(Act0AcademyYouLeafV1), findsOneWidget);
    expect(await _prefs(tester), before);
    final learn = find.byKey(const Key('act0_academy_you_leaf_learn'));
    await tester.scrollUntilVisible(
      learn,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(learn.hitTestable(), findsOneWidget);
    await tester.tap(learn);
    await tester.pumpAndSettle();
    expect(find.byType(Act0LearnPathShellV1), findsOneWidget);
    expect(find.byType(Act0AcademyYouLeafV1), findsNothing);
    expect(await _prefs(tester), before);
    await _tab(tester, 'You');
    expect(you().completedTaskCount, 0);
    expect(you().xpLine, xp);
    expect(you().earnedMoments, isEmpty);
    expect(you().openRepairCount, 0);
    expect(you().dueReviewCount, 0);
    expect(await _prefs(tester), before);
    expect(tester.takeException(), isNull);
  });
}
