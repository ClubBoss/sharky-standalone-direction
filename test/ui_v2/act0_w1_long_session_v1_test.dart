import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_source_choreography_test_wait_v1.dart';

// Long session through the real app shell on iPhone 14 Pro: a fresh learner
// goes through the whole of Worlds 1–4 by tapping like a person, the app is
// restarted in every world, and progress must carry on from where it stopped.
// Any exception thrown by the app fails the test.
const _continueKeys = [
  'act0_shell_feedback_continue_cta',
  'act0_shell_block_summary_continue_cta',
  'act0_shell_continue_cta',
  'act0_shell_welcome_primary_cta',
  'act0_shell_main_cta',
  'act0_academy_home_leaf_cta',
];

Future<void> _mount(WidgetTester t, {bool firstRun = false}) async {
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        initialTab: Act0ShellTabV1.home,
        showPlacementOnStart: firstRun,
      ),
    ),
  );
  await t.pumpAndSettle();
}

final _tapLog = <String>[];

Future<bool> _tapFirst(WidgetTester t, List<Finder> finders) async {
  for (final f in finders) {
    if (f.evaluate().isEmpty) continue;
    await t.ensureVisible(f.first);
    await t.pumpAndSettle();
    final hit = f.hitTestable();
    if (hit.evaluate().isEmpty) continue;
    _tapLog.add(RegExp(r"'([a-z0-9_]+)'").firstMatch('$f')?.group(1) ?? '?');
    await t.tap(hit.first, warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 800));
    await t.pumpAndSettle();
    return true;
  }
  return false;
}

// First run exactly as a new learner does it: placement "new", then Welcome
// with its demo answer, then Home.
Future<void> _onboard(WidgetTester t) async {
  for (final k in [
    'act0_shell_placement_intro_cta',
    'act0_shell_placement_option_new',
    'act0_shell_placement_next_cta',
    'act0_shell_welcome_primary_cta',
  ]) {
    await t.tap(find.byKey(Key(k)));
    await t.pumpAndSettle();
  }
  final demo = t
      .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
      .runner
      .options
      .firstWhere((o) => o.isCorrect);
  await t.tap(find.byKey(Key('act0_shell_option_${demo.id}')));
  await t.pumpAndSettle();
  await t.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
  await t.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester t) async {
  Map<String, dynamic>? result;
  await t.runAsync(() async {
    await Act0ProgressStoreV1(
      key: 'act0_shell_progress_v1',
      isValidPayload: (_) => false,
    ).flush().timeout(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final head = prefs.getString('act0_shell_progress_v1_head');
    expect(head, isNotNull);
    expect(prefs.getString('act0_shell_progress_v1_backup'), head);
    expect(prefs.getString('act0_shell_progress_v1_recovery'), head);
    result =
        jsonDecode((jsonDecode(head!) as Map)['payload'] as String)
            as Map<String, dynamic>;
  });
  return result!;
}

void main() {
  testWidgets(
    'a fresh learner finishes W1-W4 with mistakes, retries and four restarts',
    (t) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final worlds = Act0ShellStateV1.sample.worlds
          .where((w) => w.worldNumber >= 1 && w.worldNumber <= 4)
          .toList();
      final taskWorld = {
        for (final w in worlds)
          for (final l in w.lessons)
            for (final task in l.taskList) task.taskId: w.worldNumber,
      };
      final rewards = {
        for (final w in worlds)
          for (final l in w.lessons)
            for (final task in l.taskList) task.taskId: task.rewardXp,
      };
      final answered = <String>{};
      final missedWorlds = <int>{};
      final confirmedMisses = <int>{};
      final restartedWorlds = <int>{};
      final enteredWorlds = <int>{};
      var complete = false;
      await _mount(t, firstRun: true);
      await _onboard(t);

      for (var step = 0; step < 2600 && !complete; step++) {
        final runnerFinder = find.byType(Act0LessonRunnerShellV1);
        if (runnerFinder.evaluate().isNotEmpty) {
          final shell = t.widget<Act0LessonRunnerShellV1>(runnerFinder.first);
          final runner = shell.runner;
          final taskId = shell.selectedTaskId ?? '';
          final world = taskWorld[taskId];
          if (world == null) break; // Never answer a future-world task.
          if (enteredWorlds.add(world)) {
            final snapshot = await _saved(t);
            final completed = (snapshot['completedTaskIds'] as List)
                .cast<String>()
                .toSet();
            final prerequisites = taskWorld.entries
                .where((e) => e.value < world)
                .map((e) => e.key)
                .toSet();
            expect(
              completed.containsAll(prerequisites),
              isTrue,
              reason:
                  'W$world unlocked before ${prerequisites.difference(completed)}',
            );
          }
          if (_tapLog.isEmpty || _tapLog.last != '@$taskId')
            _tapLog.add('@$taskId');
          final deciding =
              runner.phase == Act0LessonPhaseV1.drill &&
              runner.activeTeachingStep == null &&
              runner.selectedOptionId == null &&
              runner.options.isNotEmpty;
          if (deciding) {
            await pumpSourceChoreographyToDecisionV1(t, runner.table);
            final wrong = runner.options.where((o) => !o.isCorrect).toList();
            final injectMiss =
                !missedWorlds.contains(world) && wrong.isNotEmpty;
            final choice = injectMiss
                ? wrong.first
                : runner.options.firstWhere((o) => o.isCorrect);
            if (injectMiss) missedWorlds.add(world);
            final tapped = await _tapFirst(t, [
              if (runner.sizingConfig.isEnabled)
                find.byKey(Key('act0_shell_sizing_preset_${choice.id}')),
              find.byKey(Key('act0_shell_option_${choice.id}')),
              if (choice.seatId != null)
                find.byKey(Key('act0_shell_seat_tap_${choice.seatId}')),
            ]);
            expect(tapped, isTrue, reason: '$taskId: no answer');
            if (runner.sizingConfig.isEnabled) {
              expect(
                await _tapFirst(t, [
                  find.byKey(const Key('act0_shell_sizing_confirm_cta')),
                ]),
                isTrue,
              );
            }
            if (injectMiss) {
              final missSnapshot = await _saved(t);
              final evidence = (missSnapshot['learningEvidenceHistory'] as List)
                  .cast<Map>();
              expect(
                evidence.any(
                  (r) => r['taskId'] == taskId && r['isCorrect'] == false,
                ),
                isTrue,
              );
              confirmedMisses.add(world);
            }
            answered.add(taskId);
            final worldAnswered = answered
                .where((id) => taskWorld[id] == world)
                .length;
            final worldTotal = taskWorld.values.where((n) => n == world).length;
            if (!restartedWorlds.contains(world) &&
                worldAnswered >= worldTotal ~/ 2) {
              final before = await _saved(t);
              await _mount(t);
              final after = await _saved(t);
              expect(after['completedTaskIds'], before['completedTaskIds']);
              expect(after['earnedXp'], before['earnedXp']);
              expect(after['selectedWorldId'], before['selectedWorldId']);
              expect(after['selectedTaskId'], before['selectedTaskId']);
              restartedWorlds.add(world);
              // A learner can return to Learn even while an open repair is shown on Home.
              await _tapFirst(t, [find.text('Learn').last]);
              await _tapFirst(t, [
                find.byKey(const Key('act0_shell_current_mission_cta')),
              ]);
            }
            continue;
          }
        } else {
          final snapshot = await _saved(t);
          final completed = (snapshot['completedTaskIds'] as List)
              .cast<String>()
              .toSet();
          complete = completed.containsAll(taskWorld.keys);
          if (complete) break;
        }
        final moved = await _tapFirst(t, [
          find.byKey(const Key('act0_shell_theory_continue_cta')),
          for (final key in _continueKeys) find.byKey(Key(key)),
        ]);
        expect(
          moved,
          isTrue,
          reason:
              'Step $step stalled; recent taps: ${_tapLog.reversed.take(12).toList()}',
        );
      }
      final snapshot = await _saved(t);
      final completed = (snapshot['completedTaskIds'] as List)
          .cast<String>()
          .toSet();
      expect(taskWorld.keys.toSet().difference(completed), isEmpty);
      expect(taskWorld.length, 181);
      expect(missedWorlds, {1, 2, 3, 4});
      expect(restartedWorlds, {1, 2, 3, 4});
      expect(snapshot['skippedTaskIds'], isEmpty);
      expect(
        snapshot['earnedXp'],
        completed.fold<int>(0, (sum, id) => sum + (rewards[id] ?? 0)),
      );
      expect(confirmedMisses, {1, 2, 3, 4});
      expect(t.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
