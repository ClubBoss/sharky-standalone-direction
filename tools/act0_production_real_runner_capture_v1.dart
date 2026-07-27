import 'dart:convert';
import 'dart:io';

/// Captures deterministic states from the active Act0 content graph.
///
/// This deliberately differs from the older placement quick-check fixtures:
/// every runner below is resolved by `(worldId, lessonId, taskId)` from
/// [Act0ShellStateV1.sample] inside the generated test.  The harness is only a
/// screenshot transport; it never manufactures a runner or replaces content.
const _schema = 'production_real_runner_capture_v1';
const _outputRoot = 'output/visual_master_audit/raw';

class _Seed {
  const _Seed(
    this.stateId,
    this.worldId,
    this.lessonId,
    this.taskId,
    this.mode,
    this.phase, {
    this.auditSeedId,
  });

  final String stateId;
  final String worldId;
  final String lessonId;
  final String taskId;
  final String mode;
  final String phase;
  final String? auditSeedId;

  Map<String, String> toJson() => <String, String>{
    'visual_state_id': stateId,
    'world_id': worldId,
    'lesson_id': lessonId,
    'task_id': taskId,
    'mode': mode,
    'semantic_phase': phase,
    if (auditSeedId != null) 'audit_seed_id': auditSeedId!,
  };
}

const _seeds = <_Seed>[
  _Seed(
    'runner.theory.hand_rankings',
    'world_1',
    'hand_rankings_table',
    'hand_rankings_theory',
    'base',
    'theory',
  ),
  _Seed(
    'runner.table_read.live',
    'world_1',
    'what_poker_is',
    'what_poker_is_table_read_transfer',
    'base',
    'table_reading_prompt',
  ),
  _Seed(
    'runner.table_read.recheck.live',
    'world_1',
    'what_poker_is',
    'what_poker_is_table_read_recheck',
    'base',
    'recheck',
  ),
  _Seed(
    'runner.action_selection.live',
    'world_1',
    'fold_check_call_raise',
    'actions_call_drill',
    'base',
    'action_selection',
  ),
  _Seed(
    'runner.seat_selection.vrt02',
    'world_1',
    'positions',
    'positions_early_late',
    'base',
    'seat_selection',
  ),
  _Seed(
    'runner.seat_selection.vrt02_correct',
    'world_1',
    'positions',
    'positions_early_late',
    'correct',
    'correct_feedback',
  ),
  _Seed(
    'runner.seat_selection.vrt02_incorrect',
    'world_1',
    'positions',
    'positions_early_late',
    'incorrect',
    'incorrect_feedback',
  ),
  _Seed(
    'runner.world3_seat_derivative',
    'world_3',
    'early_vs_late',
    'early_pressure_choice',
    'base',
    'seat_selection_derivative',
    auditSeedId: 'world3_early_pressure',
  ),
  _Seed(
    'runner.hand_comparison.live',
    'world_1',
    'hand_rankings_table',
    'hand_rankings_full_house_vs_flush_drill',
    'base',
    'non_table_decision',
  ),
  _Seed(
    'runner.showdown.live',
    'world_1',
    'showdown_winning',
    'showdown_best_hand_drill',
    'base',
    'table_reading_prompt',
  ),
  _Seed(
    'runner.completion.review',
    'world_1',
    'positions',
    'positions_review',
    'base',
    'lesson_completion',
  ),
];

void main(List<String> args) async {
  if (args.length != 1 ||
      !const <String>[
        'compact',
        'tall_phone',
        'large_phone',
        'iphone17_class',
      ].contains(args.single)) {
    stderr.writeln(
      'Usage: dart run tools/act0_production_real_runner_capture_v1.dart <compact|tall_phone|large_phone|iphone17_class>',
    );
    exit(64);
  }
  final device = args.single;
  final packet = 'live_runner_${device}_v1';
  final output = Directory('$_outputRoot/$packet')..createSync(recursive: true);
  final temp = Directory.systemTemp.createTempSync('act0_live_runner_capture_');
  final test = File('${temp.path}/capture_test.dart');
  test.writeAsStringSync(_testSource(output.path, device));
  final result = await Process.start(
    'flutter',
    <String>['test', test.path],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  await stdout.addStream(result.stdout);
  await stderr.addStream(result.stderr);
  final code = await result.exitCode;
  temp.deleteSync(recursive: true);
  if (code != 0) exit(code);

  final commit = _git(<String>['rev-parse', 'HEAD']);
  final rows = <Map<String, Object?>>[];
  for (final seed in _seeds) {
    final png = File('${output.path}/$device.${seed.stateId}.png');
    if (!png.existsSync() || png.lengthSync() == 0) {
      throw StateError('Missing live-runner capture: ${png.path}');
    }
    rows.add(<String, Object?>{
      ...seed.toJson(),
      'route_id':
          'act0/$device/${seed.worldId}/${seed.lessonId}/${seed.taskId}',
      'actual_production_renderer': 'Act0LessonRunnerShellV1',
      'owner_family': 'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
      'deterministic_state_seed':
          'Act0ShellStateV1.sample direct task resolution',
      'device_class': device,
      'modifier': 'none',
      'expected_interaction': seed.mode == 'base'
          ? 'inspect production task state'
          : 'feedback state seeded from the production option',
      'content_status': 'LIVE_PRODUCTION',
      'capture_class': 'harness_capture',
      'screenshot_path': png.path,
      'sha256': _sha256(png),
      'candidate_commit_sha': commit,
    });
  }
  File('${output.path}/manifest.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(<String, Object?>{
          'schema': _schema,
          'candidate_commit_sha': commit,
          'device_class': device,
          'content_status_policy':
              'LIVE_PRODUCTION requires direct Act0ShellStateV1 task resolution; fixture-created runners are excluded.',
          'rows': rows,
        }) +
        '\n',
  );
}

String _git(List<String> args) =>
    Process.runSync('git', args).stdout.toString().trim();

String _sha256(File file) => Process.runSync('shasum', <String>[
  '-a',
  '256',
  file.path,
]).stdout.toString().trim().split(RegExp(r'\s+')).first;

String _testSource(String output, String device) {
  final calls = _seeds
      .map((seed) => "await capture(tester, ${jsonEncode(seed.toJson())});")
      .join('\n    ');
  return '''
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const outputPath = ${jsonEncode(output)};
  const device = '$device';
  const viewports = <String, Size>{
    'compact': Size(375, 812),
    'tall_phone': Size(402, 874),
    'large_phone': Size(430, 932),
    'iphone17_class': Size(402, 874),
  };
  Future<void> loadFont() async {
    final file = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (!file.existsSync()) throw StateError('No local real-text font found.');
    final bytes = await file.readAsBytes();
    for (final family in <String>['Roboto', 'Ahem']) {
      await (FontLoader(family)..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)))).load();
    }
  }
  setUpAll(loadFont);
  testWidgets('captures direct production runner seeds', (tester) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(() { tester.view.resetPhysicalSize(); tester.view.resetDevicePixelRatio(); tester.platformDispatcher.resetSystemFontFamily(); });
    Future<void> capture(WidgetTester tester, Map<String, dynamic> seed) async {
      final directSeed = seed['audit_seed_id'] as String?;
      final task = directSeed == null
          ? (() {
              final world = Act0ShellStateV1.sample.worldById(seed['world_id'] as String);
              final lesson = world.lessons.firstWhere(
                (item) => item.lessonId == seed['lesson_id'],
                orElse: () => throw StateError('Missing lesson for ' + (seed['visual_state_id'] as String) + ': ' + (seed['lesson_id'] as String)),
              );
              return lesson.taskList.firstWhere(
                (item) => item.taskId == seed['task_id'],
                orElse: () => throw StateError('Missing task for ' + (seed['visual_state_id'] as String) + ': ' + (seed['task_id'] as String)),
              );
            })()
          : act0ProductionVisualAuditTaskSeedV1(directSeed) ??
              (throw StateError('Missing audit seed ' + directSeed));
      final correct = task.runner.options.firstWhere((item) => item.isCorrect);
      final incorrect = task.runner.options.firstWhere((item) => !item.isCorrect, orElse: () => correct);
      final selected = seed['mode'] == 'correct' ? correct : seed['mode'] == 'incorrect' ? incorrect : null;
      final runner = selected == null ? task.runner : task.runner.copyWith(
        phase: Act0LessonPhaseV1.review,
        selectedOptionId: selected.id,
        feedbackTitle: selected.feedbackTitle,
        feedbackReason: selected.feedbackReason,
        primaryCtaLabel: 'Continue',
      );
      tester.view.physicalSize = viewports[device]!;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(MaterialApp(theme: ThemeData(fontFamily: 'Roboto'), home: MediaQuery(data: MediaQueryData(size: viewports[device]!), child: Scaffold(backgroundColor: const Color(0xFF070B12), body: RepaintBoundary(key: const Key('capture'), child: Act0LessonRunnerShellV1(runner: runner, selectedWorldId: seed['world_id'] as String, selectedLessonId: seed['lesson_id'] as String, selectedTaskId: seed['task_id'] as String, selectedTaskFamily: task.resolvedTaskFamily, tablePresentation: task.tablePresentation, onBack: () {}, onContinueTheory: () {}, onChooseOption: (_) {}, onContinueReview: () {}))))));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('capture')));
      final data = await tester.runAsync(() async => (await boundary.toImage(pixelRatio: 2)).toByteData(format: ui.ImageByteFormat.png));
      if (data == null) throw StateError('Unable to capture '+(seed['visual_state_id'] as String));
      File(outputPath + '/' + device + '.' + (seed['visual_state_id'] as String) + '.png').writeAsBytesSync(Uint8List.view(data.buffer));
    }
    $calls
  });
}
''';
}
