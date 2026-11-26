// Run with flutter test (see capture_act0_screens_v1.sh v9 walkthrough).
// Each world starts from a fresh mock save; W2+ seed only prerequisite credit.
// Navigation and grading are performed through the actual Act0 shell widgets.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show FlutterExceptionHandler;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../test/support/act0_route_practice_runner_test_v1.dart';
import '../test/ui_v2/act0_w1_long_session_v1_test.dart';
import 'act0_widget_capture_v1.dart';

void main() => registerV9WalkthroughV1(
  lastWorld: const int.fromEnvironment('V9_LAST_WORLD', defaultValue: 12),
);

void registerV9WalkthroughV1({int lastWorld = 12}) {
  if (lastWorld < 1 || lastWorld > 12) {
    throw ArgumentError.value(lastWorld, 'lastWorld', 'Expected 1–12');
  }
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAct0CaptureFontsV1);
  for (var world = 1; world <= lastWorld; world++) {
    registerLongSessionRoutes(
      tierARange: (first: world, last: world),
      walkthrough: V9WalkthroughV1(),
    );
  }
}

class V9WalkthroughV1 implements Act0LongSessionObserverV1 {
  Directory? _outputDirectory;
  Directory get _output => _outputDirectory!;
  late int _world;
  late int _priorXp;
  late Set<String> _expected;
  int _tasks = 0;
  int _xpDelta = 0;
  final _screens = <String>{};
  final _overflowErrors = <String>[];
  final _exceptions = <String>[];
  String _repair = 'missing';
  String? _wrongTask;
  bool _retryOffered = false;
  FlutterExceptionHandler? _previousErrorHandler;

  @override
  void start(int world, Set<String> tasks, int priorXp) {
    _world = world;
    _expected = tasks;
    _priorXp = priorXp;
    _outputDirectory = Directory(
      'build/v9/w${world.toString().padLeft(2, '0')}',
    );
    if (_output.existsSync()) _output.deleteSync(recursive: true);
    _output.createSync(recursive: true);
    _previousErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      failure(details.exception);
      _previousErrorHandler?.call(details);
    };
  }

  bool _has(String key) => find.byKey(Key(key)).evaluate().isNotEmpty;

  Future<void> _capture(WidgetTester tester, String kind) async {
    if (_screens.contains('$kind.png')) return;
    final name = '$kind.png';
    await captureAct0WidgetPngV1(
      tester,
      find.byKey(const Key('act0_walkthrough_capture')),
      File('${_output.path}/$name'),
    );
    _screens.add(name);
  }

  @override
  Future<void> screen(WidgetTester tester) async {
    if (_has('act0_shell_result_close')) {
      await _capture(tester, 'result');
      return;
    }
    if (_has('act0_learning_run_payoff_complete_cta')) {
      await _capture(tester, 'learning_run_payoff');
      return;
    }
    final shell = tester
        .widgetList<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        )
        .firstOrNull;
    if (shell == null) {
      if (_has('act0_shell_w1_start_basics')) {
        await _capture(tester, 'welcome');
      } else if (_has('act0_shell_learn_screen') ||
          _has('act0_shell_current_mission_cta')) {
        await _capture(tester, 'lesson_map');
      } else if (_has('act0_academy_home_leaf')) {
        await _capture(tester, 'home');
      } else if (_has('act0_academy_review_leaf')) {
        await _capture(tester, 'review');
      }
      return;
    }
    if (shell.selectedWorldId != 'world_$_world' &&
        act0RoutePracticeFinder.evaluate().isEmpty)
      return;
    final runner = shell.runner;
    if (act0RoutePracticeFinder.evaluate().isNotEmpty) {
      await _capture(tester, 'route_practice_${runner.phase.name}');
      return;
    }
    await _capture(tester, 'lesson_start');
    final family = shell.selectedTaskFamily?.name ?? 'unknown';
    final table = runner.hideTable ? 'text' : 'table';
    if (runner.phase == Act0LessonPhaseV1.review) {
      final quality = runner.selectedOption?.quality.name ?? 'unknown';
      await _capture(tester, 'feedback_${quality}_$family');
    } else if (runner.activeTeachingStep != null ||
        runner.phase == Act0LessonPhaseV1.theory) {
      await _capture(tester, 'theory_${table}_$family');
    } else {
      final control = runner.sizingConfig.isEnabled
          ? 'sizing'
          : runner.options.any((o) => o.seatId != null)
          ? 'seat'
          : 'choice';
      await _capture(tester, 'decision_${control}_${table}_$family');
      // A retry is proved by a reachable retry CTA AND its actual ensuing
      // source or repair drill, not merely the presence of generic Continue.
      if (_retryOffered &&
          runner.phase == Act0LessonPhaseV1.drill &&
          runner.selectedOptionId == null) {
        // Only the first actionable drill after the deliberate miss can be
        // its repair. A later unrelated fix must not make this row pass.
        _retryOffered = false;
        if (shell.selectedTaskId == _wrongTask ||
            shell.selectedTaskFamily == Act0TaskFamilyV1.repair) {
          _repair = 'ok';
          await _capture(tester, 'repair');
        }
      }
    }
  }

  @override
  Future<void> wrongAnswer(WidgetTester tester) async {
    final shell = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    _wrongTask = shell.selectedTaskId;
    await _capture(tester, 'wrong_feedback');
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    // A generic Continue label is not proof by itself. Require its real
    // ensuing retry/repair drill in screen(), regardless of skin copy.
    _retryOffered =
        shell.runner.selectedOption?.quality == Act0FeedbackQualityV1.wrong &&
        tester
            .widgetList<ButtonStyleButton>(cta)
            .any((button) => button.onPressed != null);
  }

  @override
  Future<void> finalResult(WidgetTester tester) =>
      _capture(tester, 'final_result');

  @override
  void snapshot(Map<String, dynamic> progress) {
    _tasks = (progress['completedTaskIds'] as List)
        .toSet()
        .intersection(_expected)
        .length;
    _xpDelta = (progress['earnedXp'] as int) - _priorXp;
  }

  @override
  void failure(Object error) {
    final message = error.toString();
    if (message.toLowerCase().contains('overflow')) {
      _overflowErrors.add(message);
    } else {
      _exceptions.add(message);
    }
  }

  @override
  void finish() {
    if (_outputDirectory == null) return;
    FlutterError.onError = _previousErrorHandler;
    if (_tasks != _expected.length) {
      _exceptions.add('Incomplete course: $_tasks/${_expected.length} tasks');
    }
    final row = <String, Object>{
      'world': _world,
      'tasks': _tasks,
      'screens': _screens.toList(),
      'wrong_answer_repair': _repair,
      'overflow_errors': _overflowErrors,
      'exceptions': _exceptions,
      'xp_delta': _xpDelta,
    };
    File(
      '${_output.path}/row.json',
    ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(row)}\n');
    // Validate the same persisted JSON contract in W1 smoke and full run.
    final decoded =
        jsonDecode(File('${_output.path}/row.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(decoded.keys.toSet(), row.keys.toSet());
    expect(decoded['world'], _world);
    // Preserve the original route failure rather than masking it in finally.
    if (_exceptions.isNotEmpty || _overflowErrors.isNotEmpty) return;
    expect(decoded['tasks'], _expected.length);
    expect(
      decoded['screens'],
      containsAll([
        'lesson_start.png',
        'wrong_feedback.png',
        'repair.png',
        'result.png',
        'final_result.png',
      ]),
    );
    expect(decoded['wrong_answer_repair'], 'ok');
    expect(decoded['overflow_errors'], isEmpty);
    expect(decoded['exceptions'], isEmpty);
    expect(decoded['xp_delta'], isA<int>());
    for (final name in (decoded['screens'] as List).cast<String>()) {
      expect(
        File('${_output.path}/$name').readAsBytesSync().take(8).toList(),
        [137, 80, 78, 71, 13, 10, 26, 10],
        reason: name,
      );
    }
  }
}
