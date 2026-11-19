// P1: response, frames and memory on a real iPhone, profile build.
//
// Run with the iPhone connected: tools/p1/run_p1_on_iphone.sh (see the
// script header). The report is written to build/p1_perf_report.json.
//
// A fresh learner goes through W1–W4 with one mistake and one remount per
// world, like act0_w1_long_session_v1_test, but with real time, real frames
// and real storage. The test clears this build's saved progress first.
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _lastWorld = int.fromEnvironment('P1_LAST_WORLD', defaultValue: 4);

const _continueKeys = [
  'act0_shell_theory_continue_cta',
  'act0_shell_feedback_continue_cta',
  'act0_shell_block_summary_continue_cta',
  'act0_shell_continue_cta',
  'act0_shell_welcome_primary_cta',
  'act0_shell_main_cta',
  'act0_academy_home_leaf_cta',
  'act0_shell_current_mission_cta',
];

/// Frame timings collected by the engine, bucketed by the current world.
final _frames = <String, List<FrameTiming>>{};
var _bucket = 'onboarding';

/// Wall time from a tap until the screen settles, by action kind.
final _actions = <String, List<int>>{};

/// Resident memory (MB) at checkpoints.
final _memory = <String, double>{};

double _rssMb() => ProcessInfo.currentRss / (1024 * 1024);

Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pumpAndSettle(
    const Duration(milliseconds: 16),
    EnginePhase.sendSemanticsUpdate,
    const Duration(minutes: 2),
  );
}

/// Real time passes, so runtime timers (choreography beats) fire as in use.
Future<void> _wait(WidgetTester t, int ms) async {
  await Future<void>.delayed(Duration(milliseconds: ms));
  await _settle(t);
}

bool _nextControlReady() => find
    .byWidgetPredicate((w) {
      final key = w.key;
      if (key is! ValueKey<String>) return false;
      final v = key.value;
      return _continueKeys.contains(v) ||
          v.startsWith('act0_shell_option_') ||
          v.startsWith('act0_shell_seat_tap_') ||
          v.startsWith('act0_shell_placement_');
    })
    .hitTestable()
    .evaluate()
    .isNotEmpty;

String _kindOf(String key) {
  if (key.startsWith('act0_shell_option_') ||
      key.startsWith('act0_shell_seat_tap_') ||
      key.startsWith('act0_shell_sizing')) {
    return 'answer_to_review';
  }
  if (key == 'act0_shell_feedback_continue_cta') return 'review_to_next';
  if (key == 'act0_shell_theory_continue_cta' ||
      key == 'act0_shell_continue_cta') {
    return 'theory_next';
  }
  if (key == 'act0_shell_current_mission_cta' ||
      key == 'act0_shell_main_cta' ||
      key == 'act0_academy_home_leaf_cta') {
    return 'enter_lesson';
  }
  if (key == 'act0_shell_block_summary_continue_cta') return 'lesson_summary';
  return 'other';
}

Future<bool> _tapFirst(WidgetTester t, List<String> keys) async {
  for (final k in keys) {
    final f = find.byKey(Key(k));
    if (f.evaluate().isEmpty) continue;
    await t.ensureVisible(f.first);
    await _settle(t);
    final hit = f.hitTestable();
    if (hit.evaluate().isEmpty) continue;
    final kind = _kindOf(k);
    final sw = Stopwatch()..start();
    await t.tap(hit.first, warnIfMissed: false);
    await t.pump();
    _actions
        .putIfAbsent('$kind.first_frame', () => [])
        .add(sw.elapsedMilliseconds);
    // Ready: the next control the learner would press is on screen and tappable.
    while (sw.elapsedMilliseconds < 5000 && !_nextControlReady()) {
      await t.pump();
    }
    _actions.putIfAbsent('$kind.ready', () => []).add(sw.elapsedMilliseconds);
    await _settle(t);
    _actions.putIfAbsent('$kind.settled', () => []).add(sw.elapsedMilliseconds);
    return true;
  }
  return false;
}

Future<void> _mount(WidgetTester t, {bool firstRun = false}) async {
  final sw = Stopwatch()..start();
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
  await _settle(t);
  sw.stop();
  _actions.putIfAbsent('mount_home', () => []).add(sw.elapsedMilliseconds);
}

Map<String, Object> _pct(List<num> raw) {
  if (raw.isEmpty) return {'n': 0};
  final v = [...raw]..sort();
  num at(double p) => v[((v.length - 1) * p).round()];
  return {
    'n': v.length,
    'p50': at(.5),
    'p90': at(.9),
    'p99': at(.99),
    'max': v.last,
  };
}

Map<String, Object> _frameStats(List<FrameTiming> f) {
  final build = f.map((x) => x.buildDuration.inMicroseconds / 1000).toList();
  final raster = f.map((x) => x.rasterDuration.inMicroseconds / 1000).toList();
  final total = f.map((x) => x.totalSpan.inMicroseconds / 1000).toList();
  int over(double ms) => f
      .where(
        (x) =>
            x.buildDuration.inMicroseconds / 1000 > ms ||
            x.rasterDuration.inMicroseconds / 1000 > ms,
      )
      .length;
  return {
    'frames': f.length,
    'build_ms': _pct(build),
    'raster_ms': _pct(raster),
    'total_span_ms': _pct(total),
    'over_8_3ms': over(8.33),
    'over_16_7ms': over(16.67),
    'over_33ms': over(33.3),
  };
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('P1: W1–W$_lastWorld on device', (t) async {
    SchedulerBinding.instance.addTimingsCallback((timings) {
      _frames.putIfAbsent(_bucket, () => []).addAll(timings);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final worlds = Act0ShellStateV1.sample.worlds
        .where((w) => w.worldNumber >= 1 && w.worldNumber <= _lastWorld)
        .toList();
    final taskWorld = {
      for (final w in worlds)
        for (final l in w.lessons)
          for (final task in l.taskList) task.taskId: w.worldNumber,
    };
    final missed = <int>{};
    final remounted = <int>{};
    final answered = <String>{};
    final entered = <int>{};
    final total = Stopwatch()..start();

    _memory['start'] = _rssMb();
    await _mount(t, firstRun: true);
    for (final k in [
      'act0_shell_placement_intro_cta',
      'act0_shell_placement_option_new',
      'act0_shell_placement_next_cta',
      'act0_shell_welcome_primary_cta',
    ]) {
      expect(await _tapFirst(t, [k]), isTrue, reason: k);
    }
    final demo = t
        .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
        .runner
        .options
        .firstWhere((o) => o.isCorrect);
    expect(await _tapFirst(t, ['act0_shell_option_${demo.id}']), isTrue);
    expect(await _tapFirst(t, ['act0_shell_welcome_primary_cta']), isTrue);
    _memory['after_onboarding'] = _rssMb();

    var stalls = 0;
    var reachedNext = false;
    for (var step = 0; step < 4000; step++) {
      final runnerFinder = find.byType(Act0LessonRunnerShellV1);
      if (runnerFinder.evaluate().isNotEmpty) {
        final shell = t.widget<Act0LessonRunnerShellV1>(runnerFinder.first);
        final runner = shell.runner;
        final taskId = shell.selectedTaskId ?? '';
        final world = taskWorld[taskId];
        if (world == null) {
          reachedNext = true; // the route moved past the last measured world
          break;
        }
        if (entered.add(world)) {
          if (world > 1) _memory['end_w${world - 1}'] = _rssMb();
          _bucket = 'w$world';
        }
        final deciding =
            runner.phase == Act0LessonPhaseV1.drill &&
            runner.activeTeachingStep == null &&
            runner.selectedOptionId == null &&
            runner.options.isNotEmpty;
        if (deciding) {
          final plan = act0TableChoreographyPlanForTableV1(runner.table);
          if (plan != null) await _wait(t, 500 * (plan.beats.length + 1));
          final wrong = runner.options.where((o) => !o.isCorrect).toList();
          final miss = !missed.contains(world) && wrong.isNotEmpty;
          final choice = miss
              ? wrong.first
              : runner.options.firstWhere((o) => o.isCorrect);
          if (miss) missed.add(world);
          final ok = await _tapFirst(t, [
            if (runner.sizingConfig.isEnabled)
              'act0_shell_sizing_preset_${choice.id}',
            'act0_shell_option_${choice.id}',
            if (choice.seatId != null) 'act0_shell_seat_tap_${choice.seatId}',
          ]);
          expect(ok, isTrue, reason: '$taskId: no answer');
          if (runner.sizingConfig.isEnabled) {
            expect(
              await _tapFirst(t, ['act0_shell_sizing_confirm_cta']),
              isTrue,
            );
          }
          answered.add(taskId);
          final done = answered.where((id) => taskWorld[id] == world).length;
          final all = taskWorld.values.where((n) => n == world).length;
          if (!remounted.contains(world) && done >= all ~/ 2) {
            remounted.add(world);
            await _mount(t);
            final learn = find.text('Learn');
            if (learn.evaluate().isNotEmpty) {
              await t.tap(learn.last, warnIfMissed: false);
              await _settle(t);
            }
          }
          stalls = 0;
          continue;
        }
      }
      final moved = await _tapFirst(t, _continueKeys);
      if (!moved) {
        // Teaching beats run on real timers: give them time before failing.
        await _wait(t, 600);
        if (++stalls > 20)
          fail('stalled at step $step after ${answered.length} answers');
      } else {
        stalls = 0;
      }
    }
    total.stop();
    _memory['end_w$_lastWorld'] = _rssMb();
    await Future<void>.delayed(const Duration(seconds: 3));
    _memory['idle_3s_after'] = _rssMb();

    final head = (await SharedPreferences.getInstance()).getString(
      'act0_shell_progress_v1_head',
    );
    final completed = head == null
        ? <String>{}
        : ((jsonDecode((jsonDecode(head) as Map)['payload'] as String)
                      as Map)['completedTaskIds']
                  as List)
              .cast<String>()
              .toSet();
    expect(reachedNext, isTrue, reason: 'route did not pass W$_lastWorld');
    expect(taskWorld.keys.toSet().difference(completed), isEmpty);
    binding.reportData = <String, Object?>{
      'worlds': _lastWorld,
      'decisions_answered': answered.length,
      'tasks_completed': completed.length,
      'mistakes': missed.length,
      'remounts': remounted.length,
      'wall_seconds': total.elapsed.inSeconds,
      'memory_rss_mb': _memory.map((k, v) => MapEntry(k, v.toStringAsFixed(1))),
      'actions_ms': _actions.map((k, v) => MapEntry(k, _pct(v))),
      'frames': _frames.map((k, v) => MapEntry(k, _frameStats(v))),
    };
  }, timeout: const Timeout(Duration(minutes: 60)));
}
