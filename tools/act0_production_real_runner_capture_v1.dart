import 'dart:convert';
import 'dart:collection';
import 'dart:io';

/// Captures deterministic states from the active Act0 content graph.
///
/// This deliberately differs from the older placement quick-check fixtures:
/// every runner below is resolved by `(worldId, lessonId, taskId)` from
/// [Act0ShellStateV1.sample] inside the generated test.  The harness is only a
/// screenshot transport; it never manufactures a runner or replaces content.
const _schema = 'production_real_runner_capture_v1';
const _identitySchema = 'visual_evidence_identity_v1';
const _productEvidenceBaseline = 'b7db47a3145ba8653b90403a9aa48538c378cdb7';
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
  if ((args.length != 1 && args.length != 2) ||
      !const <String>[
        'compact',
        'tall_phone',
        'large_phone',
        'iphone17_class',
      ].contains(args.first) ||
      (args.length == 2 &&
          !const <String>[
            'text_scale_1_4',
            'reduced_motion',
          ].contains(args[1]))) {
    stderr.writeln(
      'Usage: dart run tools/act0_production_real_runner_capture_v1.dart <compact|tall_phone|large_phone|iphone17_class> [text_scale_1_4|reduced_motion]',
    );
    exit(64);
  }
  final device = args.first;
  final modifier = args.length == 2 ? args[1] : 'none';
  final packet = 'live_runner_${device}_${modifier}_v1';
  final output = Directory('$_outputRoot/$packet');
  // This command owns exactly one deterministic lane. Clear only that lane so
  // a changed seed set cannot leave stale screenshots in its manifest/package.
  if (output.existsSync()) {
    output.deleteSync(recursive: true);
  }
  output.createSync(recursive: true);
  final temp = Directory.systemTemp.createTempSync('act0_live_runner_capture_');
  final test = File('${temp.path}/capture_test.dart');
  test.writeAsStringSync(_testSource(output.path, device, modifier));
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
      'modifier': modifier,
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
          'modifier': modifier,
          'content_status_policy':
              'LIVE_PRODUCTION requires direct Act0ShellStateV1 task resolution; fixture-created runners are excluded.',
          'rows': rows,
        }) +
        '\n',
  );
  final identities = rows.map((row) {
    final dimensions = <String, Object?>{
      'capture_group': 'production_real_live',
      'capture_surface_id': row['visual_state_id'],
      'state_id': row['visual_state_id'],
      'task_id': row['task_id'],
      'device_class': device,
      'text_scale': modifier == 'text_scale_1_4' ? 1.4 : 1.0,
      'motion_mode': modifier == 'reduced_motion' ? 'reduced' : 'normal',
      'scroll_position': 'top',
    };
    final id = _sha256Text(_canonicalIdentityJson(dimensions));
    return <String, Object?>{
      'schema_version': _identitySchema,
      'evidence_id': 'vei1_$id',
      ...dimensions,
      'relative_png_path': '$device.${row['visual_state_id']}.png',
      'png_sha256': row['sha256'],
      'evidence_baseline_sha': _productEvidenceBaseline,
      'lesson_id': row['lesson_id'],
      'world_id': row['world_id'],
      'semantic_state': row['semantic_phase'],
      'interaction_state': row['mode'],
      'renderer_family': row['actual_production_renderer'],
      'production_owner': row['owner_family'],
      'runtime_reachable': true,
      'capture_role': modifier == 'text_scale_1_4'
          ? 'accessibility_representative'
          : 'production_representative',
      'viewport_width': 'UNKNOWN_TYPED_FIELD',
      'viewport_height': 'UNKNOWN_TYPED_FIELD',
      'scroll_contract': 'not_scrolled',
      'safe_area_class': 'fixture_controlled',
      'option_count': null,
      'control_type': null,
      'table_present': null,
      'table_presentation_class': null,
      'feedback_composition': row['semantic_phase'],
      'repair_capable': null,
      'recheck_capable': row['semantic_phase'] == 'recheck',
      'completion_form': row['semantic_phase'] == 'lesson_completion'
          ? 'lesson_completion'
          : null,
      'source_fixture_or_route': row['route_id'],
      'identity_source_owner': 'act0_production_real_runner_capture_v1.dart',
    };
  }).toList();
  File('${output.path}/visual_evidence_identity_v1.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema_version': _identitySchema, 'records': identities})}\n',
  );
}

String _git(List<String> args) =>
    Process.runSync('git', args).stdout.toString().trim();

String _sha256(File file) => Process.runSync('shasum', <String>[
  '-a',
  '256',
  file.path,
]).stdout.toString().trim().split(RegExp(r'\s+')).first;

String _sha256Text(String value) {
  final file = File(
    '${Directory.systemTemp.path}/vei1-${DateTime.now().microsecondsSinceEpoch}.json',
  )..writeAsStringSync(value);
  try {
    return _sha256(file);
  } finally {
    file.deleteSync();
  }
}

String _canonicalIdentityJson(Map<String, Object?> dimensions) =>
    jsonEncode(SplayTreeMap<String, Object?>.of(dimensions));

String _testSource(String output, String device, String modifier) {
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
  const modifier = '$modifier';
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
  Future<void> loadFontFamily(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    await (FontLoader(family)
          ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes))))
        .load();
  }
  Future<void> loadIconFonts() async {
    const candidates = <(String, String)>[
      ('MaterialIcons', 'build/unit_test_assets/fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('MaterialIcons', 'build/flutter_assets/fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'build/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
    ];
    final loaded = <String>{};
    for (final candidate in candidates) {
      if (loaded.contains(candidate.\$1) || !File(candidate.\$2).existsSync()) continue;
      await loadFontFamily(candidate.\$1, candidate.\$2);
      loaded.add(candidate.\$1);
    }
    if (!loaded.contains('MaterialIcons')) throw StateError('No local MaterialIcons font found.');
  }
  String colorToHex(Color color) {
    final alpha = (color.a * 255).round().clamp(0, 255);
    final red = (color.r * 255).round().clamp(0, 255);
    final green = (color.g * 255).round().clamp(0, 255);
    final blue = (color.b * 255).round().clamp(0, 255);
    return '#'
        '\${alpha.toRadixString(16).padLeft(2, '0')}'
        '\${red.toRadixString(16).padLeft(2, '0')}'
        '\${green.toRadixString(16).padLeft(2, '0')}'
        '\${blue.toRadixString(16).padLeft(2, '0')}';
  }
  void writeTextRepairOverlays(WidgetTester tester, String pngPath) {
    final overlays = <Map<String, Object?>>[];
    for (final element in find.byType(Text).evaluate()) {
      final widget = element.widget;
      if (widget is! Text) continue;
      final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      if (text.trim().isEmpty) continue;
      final inherited = DefaultTextStyle.of(element).style;
      final explicit = widget.style;
      if (inherited.fontFamily != null || explicit?.fontFamily != null) continue;
      final box = element.renderObject;
      if (box is! RenderBox || !box.hasSize) continue;
      final origin = box.localToGlobal(Offset.zero);
      overlays.add(<String, Object?>{
        'text': text, 'left': origin.dx, 'top': origin.dy,
        'width': box.size.width, 'height': box.size.height,
        'fontSize': explicit?.fontSize ?? inherited.fontSize ?? 14,
        'fontWeight': (explicit?.fontWeight ?? inherited.fontWeight ?? FontWeight.w400).value,
        'color': colorToHex(explicit?.color ?? inherited.color ?? Colors.white),
      });
    }
    File(pngPath + '.text_overlays.json').writeAsStringSync(jsonEncode(overlays));
  }
  setUpAll(() async { await loadFont(); await loadIconFonts(); });
  testWidgets('captures direct production runner seeds', (tester) async {
    if (modifier == 'reduced_motion') {
      (WidgetsBinding.instance.platformDispatcher as TestPlatformDispatcher)
          .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    }
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
      const realTextStyle = TextStyle(fontFamily: 'Roboto');
      await tester.pumpWidget(MaterialApp(theme: ThemeData(fontFamily: 'Roboto', filledButtonTheme: FilledButtonThemeData(style: ButtonStyle(textStyle: WidgetStatePropertyAll(realTextStyle))), outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(textStyle: WidgetStatePropertyAll(realTextStyle))), textButtonTheme: TextButtonThemeData(style: ButtonStyle(textStyle: WidgetStatePropertyAll(realTextStyle)))), home: MediaQuery(data: MediaQueryData(size: viewports[device]!, textScaler: modifier == 'text_scale_1_4' ? const TextScaler.linear(1.4) : const TextScaler.linear(1)), child: Scaffold(backgroundColor: const Color(0xFF070B12), body: RepaintBoundary(key: const Key('capture'), child: Act0LessonRunnerShellV1(runner: runner, selectedWorldId: seed['world_id'] as String, selectedLessonId: seed['lesson_id'] as String, selectedTaskId: seed['task_id'] as String, selectedTaskFamily: task.resolvedTaskFamily, tablePresentation: task.tablePresentation, onBack: () {}, onContinueTheory: () {}, onChooseOption: (_) {}, onContinueReview: () {}))))));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      final pngPath = outputPath + '/' + device + '.' + (seed['visual_state_id'] as String) + '.png';
      writeTextRepairOverlays(tester, pngPath);
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('capture')));
      final data = await tester.runAsync(() async => (await boundary.toImage(pixelRatio: 2)).toByteData(format: ui.ImageByteFormat.png));
      if (data == null) throw StateError('Unable to capture '+(seed['visual_state_id'] as String));
      File(pngPath).writeAsBytesSync(Uint8List.view(data.buffer));
    }
    $calls
  });
}
''';
}
