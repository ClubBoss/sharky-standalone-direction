import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_source_choreography_test_wait_v1.dart';

// Long session through the real app shell on iPhone 14 Pro: a fresh learner
// goes through the whole of World 1 by tapping like a person, the app is
// restarted half-way, and progress must carry on from where it stopped.
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

void main() {
  testWidgets('a fresh learner finishes World 1 across a restart', (t) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final w1 = Act0ShellStateV1.sample.worlds.firstWhere(
      (w) => w.worldNumber == 1,
    );
    final w1Tasks = {
      for (final l in w1.lessons)
        for (final task in l.taskList) task.taskId,
    };
    final answered = <String>{};
    var restarted = false;
    String? lastBeforeRestart;
    String? firstAfterRestart;
    var reachedWorld2 = false;
    final trail = <String>[];

    await _mount(t, firstRun: true);
    await _onboard(t);
    for (var step = 0; step < 900 && !reachedWorld2; step++) {
      final runnerFinder = find.byType(Act0LessonRunnerShellV1);
      if (runnerFinder.evaluate().isNotEmpty) {
        final shell = t.widget<Act0LessonRunnerShellV1>(runnerFinder.first);
        final runner = shell.runner;
        final worldId = shell.selectedWorldId ?? '';
        final taskId = shell.selectedTaskId ?? '';
        if (restarted && firstAfterRestart == null) {
          firstAfterRestart = '$worldId/$taskId';
        }
        if (worldId.isNotEmpty && worldId != w1.worldId) {
          reachedWorld2 = true;
          break;
        }
        if (trail.isEmpty || trail.last != taskId) {
          trail.add(taskId);
          _tapLog.add('@$taskId');
        }
        final deciding =
            runner.phase == Act0LessonPhaseV1.drill &&
            runner.activeTeachingStep == null &&
            runner.selectedOptionId == null &&
            runner.options.isNotEmpty;
        if (deciding) {
          await pumpSourceChoreographyToDecisionV1(t, runner.table);
          final correct = runner.options.firstWhere((o) => o.isCorrect);
          final tapped = await _tapFirst(t, [
            find.byKey(Key('act0_shell_option_${correct.id}')),
            if (correct.seatId != null)
              find.byKey(Key('act0_shell_seat_tap_${correct.seatId}')),
          ]);
          expect(tapped, isTrue, reason: '$taskId: no answer');
          if (w1Tasks.contains(taskId)) {
            answered.add(taskId);
          }
          // Restart once, half-way through World 1.
          if (!restarted && answered.length >= w1Tasks.length ~/ 2) {
            lastBeforeRestart = taskId;
            await t.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 300)),
            );
            await _mount(t);
            await t.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 300)),
            );
            await t.pumpAndSettle();
            restarted = true;
          }
          continue;
        }
      }
      final moved = await _tapFirst(t, [
        for (final k in _continueKeys) find.byKey(Key(k)),
      ]);
      if (!moved) {
        final keys =
            <String>{
                  for (final e
                      in find
                          .byWidgetPredicate((w) => w.key is ValueKey<String>)
                          .hitTestable()
                          .evaluate())
                    (e.widget.key! as ValueKey<String>).value,
                }
                .where(
                  (k) =>
                      k.contains('cta') ||
                      k.contains('continue') ||
                      k.contains('start'),
                )
                .toList();
        fail('stuck at step $step; tappable keys: $keys');
      }
    }

    expect(restarted, isTrue);
    // The restart came after the first half of World 1; the learner must
    // come back inside World 1, not at its first task or in a locked world.
    expect(
      firstAfterRestart,
      allOf(
        startsWith('${w1.worldId}/'),
        isNot('${w1.worldId}/${w1.lessons.first.taskList.first.taskId}'),
      ),
      reason: 'after restart at $lastBeforeRestart the learner did not resume',
    );
    final lastLesson = w1.lessons.last.taskList.map((x) => x.taskId).toSet();
    expect(
      trail.any(lastLesson.contains),
      isTrue,
      reason: 'the last World 1 lesson was never reached: ${trail.join(' > ')}',
    );
    expect(
      reachedWorld2,
      isTrue,
      reason:
          'World 1 was not finished; taps: ${_tapLog.reversed.take(30).join(' | ')}',
    );
  });
}
