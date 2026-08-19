// B7 canonical scene composition evidence.
//
// Drives the real canonical learning route through every settled endpoint at
// the three canonical phone viewports, at SINGLE_CANONICAL_PRODUCT_SCALE, and
// records both the captures and the physical scene geometry that
// `TABLE_GEOMETRY_INVARIANT_V1` holds fixed.
//
// It reuses the harness pattern of `tools/act0_b7_cohesion_capture_v1.dart`
// rather than adding a second capture architecture.
//
// Output is local-only and uncommitted.
import 'dart:convert';
import 'dart:io';

const _outputRootPathV1 = 'output/visual_gauntlet_b7_canonical_scene';

const _endpointsV1 = <String>[
  'decision',
  'correct_feedback',
  'wrong_feedback',
  'repair',
  'recheck',
];

const _camerasV1 = <String>['canonical'];

class _VariantV1 {
  const _VariantV1({
    required this.id,
    required this.width,
    required this.height,
  });
  final String id;
  final double width;
  final double height;
}

const _variantsV1 = <_VariantV1>[
  _VariantV1(id: 'canonical_402x874', width: 402, height: 874),
  _VariantV1(id: 'compact_375x812', width: 375, height: 812),
  _VariantV1(id: 'large_430x932', width: 430, height: 932),
];

Future<void> main(List<String> args) async {
  final labelIndex = args.indexOf('--label');
  final label = labelIndex >= 0 && labelIndex + 1 < args.length
      ? args[labelIndex + 1]
      : 'gauntlet';

  final sha = (await Process.run('git', <String>[
    'rev-parse',
    'HEAD',
  ])).stdout.toString().trim();

  final outputDir = Directory('$_outputRootPathV1/$label');
  if (outputDir.existsSync()) outputDir.deleteSync(recursive: true);
  outputDir.createSync(recursive: true);

  final tempDir = Directory.systemTemp.createTempSync('act0_b7_camera_');
  final testFile = File(
    '${tempDir.path}/act0_b7_scene_camera_gauntlet_test.dart',
  );
  testFile.writeAsStringSync(_testSourceV1(outputDir.absolute.path));

  final result = await Process.start(
    'flutter',
    <String>['test', testFile.path, '-r', 'compact'],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  await stdout.addStream(result.stdout);
  await stderr.addStream(result.stderr);
  final exitCode = await result.exitCode.timeout(
    const Duration(minutes: 40),
    onTimeout: () {
      result.kill(ProcessSignal.sigterm);
      return 124;
    },
  );
  try {
    tempDir.deleteSync(recursive: true);
  } catch (_) {}
  if (exitCode != 0) exit(exitCode);

  final missing = <String>[];
  for (final variant in _variantsV1) {
    for (final camera in _camerasV1) {
      for (final endpoint in _endpointsV1) {
        final path = '${outputDir.path}/${variant.id}/$camera/$endpoint.png';
        final file = File(path);
        if (!file.existsSync() || file.lengthSync() == 0) missing.add(path);
      }
    }
  }
  if (missing.isNotEmpty) {
    stderr.writeln('Missing captures:\n${missing.join('\n')}');
    exit(1);
  }

  File('${outputDir.path}/manifest.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': 'act0_visual_gauntlet_b7_canonical_scene_evidence_v1', 'mission': 'B7_CANONICAL_SCENE_COMPOSITION_AND_GEOMETRY_V1', 'label': label, 'exact_sha': sha, 'text_scale_policy': 'SINGLE_CANONICAL_PRODUCT_SCALE', 'variants': _variantsV1.map((v) => v.id).toList(), 'endpoints': _endpointsV1, 'note': 'Generated B7 evidence is local-only and uncommitted.'})}\n',
  );
  stdout.writeln(outputDir.path);
}

String _testSourceV1(String outputDirPath) {
  final variantStatements = _variantsV1
      .map(
        (v) => '''
    await runVariant(tester, '${v.id}', const Size(${v.width}, ${v.height}));''',
      )
      .join('\n');
  return '''
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const outputDirPath = ${jsonEncode(outputDirPath)};
  final measurements = <Map<String, Object?>>[];

  Widget host(Object remountKey) {
    final realTextButtonStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all(const TextStyle(fontFamily: 'Roboto')),
    );
    return MaterialApp(
      locale: const Locale('en'),
      theme: ThemeData(
        fontFamily: 'Roboto',
        filledButtonTheme: FilledButtonThemeData(style: realTextButtonStyle),
        outlinedButtonTheme: OutlinedButtonThemeData(style: realTextButtonStyle),
        textButtonTheme: TextButtonThemeData(style: realTextButtonStyle),
      ),
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: RepaintBoundary(
        key: const Key('act0_b7_camera_boundary'),
        child: Act0ShellPreviewScreenV1(
          key: ValueKey<Object>(remountKey),
          state: Act0ShellStateV1.sample,
          showPlacementOnStart: false,
          debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
            worldId: 'world_1',
            lessonId: 'fold_check_call_raise',
            taskId: 'actions_check_drill',
          ),
        ),
      ),
    );
  }

  Future<void> loadFontFamily(String family, Uint8List bytes) async {
    final loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load().timeout(const Duration(seconds: 10));
  }

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  setUpAll(() async {
    final file = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (file.existsSync()) {
      final bytes = await file.readAsBytes();
      await loadFontFamily('Roboto', bytes);
      await loadFontFamily('Ahem', bytes);
    }
    for (final path in const <String>[
      'build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
      'build/flutter_assets/fonts/MaterialIcons-Regular.otf',
    ]) {
      final iconFile = File(path);
      if (iconFile.existsSync()) {
        await loadFontFamily('MaterialIcons', await iconFile.readAsBytes());
        break;
      }
    }
  });

  Future<void> capture(WidgetTester tester, String path) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('act0_b7_camera_boundary')),
    );
    final byteData = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    if (byteData == null) throw StateError('capture failed: ' + path);
    File(path).writeAsBytesSync(Uint8List.view(byteData.buffer));
  }

  Future<void> settle(WidgetTester tester) async {
    var frames = 0;
    while (tester.binding.hasScheduledFrame && frames < 400) {
      await tester.pump(const Duration(milliseconds: 16));
      frames++;
    }
  }

  Future<void> hop(WidgetTester tester, Key key) async {
    if (find.byKey(key).evaluate().isEmpty) {
      throw StateError('B7 gauntlet: missing route control ' + key.toString());
    }
    final finder = find.byKey(key).first;
    await tester.ensureVisible(finder);
    await settle(tester);
    await tester.tap(finder, warnIfMissed: false);
    await settle(tester);
  }

  Object? sanitize(Object? value) {
    if (value is double) return value.isFinite ? value : null;
    if (value is Map) {
      return value.map<String, Object?>(
        (k, v) => MapEntry(k.toString(), sanitize(v)),
      );
    }
    if (value is List) return value.map(sanitize).toList();
    return value;
  }

  Map<String, Object?>? rectOf(WidgetTester tester, Key key) {
    final finder = find.byKey(key);
    if (finder.evaluate().isEmpty) return null;
    final r = tester.getRect(finder.first);
    return <String, Object?>{
      'left': r.left,
      'top': r.top,
      'right': r.right,
      'bottom': r.bottom,
      'width': r.width,
      'height': r.height,
      'centerX': r.center.dx,
      'centerY': r.center.dy,
    };
  }

  Map<String, Object?> prefixedRects(WidgetTester tester, String prefix) {
    final out = <String, Object?>{};
    final elements = find
        .byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith(prefix),
        )
        .evaluate()
        .toList();
    for (final element in elements) {
      final id = (element.widget.key as ValueKey<String>).value;
      final ro = element.renderObject;
      if (ro is! RenderBox || !ro.hasSize) continue;
      final topLeft = ro.localToGlobal(Offset.zero);
      out[id] = <String, Object?>{
        'left': topLeft.dx,
        'top': topLeft.dy,
        'width': ro.size.width,
        'height': ro.size.height,
        'centerY': topLeft.dy + (ro.size.height / 2),
      };
    }
    return out;
  }

  Map<String, Object?> measure(
    WidgetTester tester,
    String variantId,
    Size viewport,
    String cameraId,
    String endpoint,
  ) {
    final felt = rectOf(tester, const Key('act0_shell_table_felt'));
    // The integrated scene keys its outer table container by prototype id, and
    // the felt fills it inside the 10 px rail band, so the physical table
    // envelope is the felt rect inflated by the rail.
    final stage = felt == null
        ? null
        : <String, Object?>{
            'left': (felt['left']! as double) - 10.0,
            'top': (felt['top']! as double) - 10.0,
            'width': (felt['width']! as double) + 20.0,
            'height': (felt['height']! as double) + 20.0,
          };
    final nearFactor = Act0ScenePerspectiveV1.canonical.nearWidthFactor;
    final farFactor = Act0ScenePerspectiveV1.canonical.farWidthFactor;
    final stageWidth = stage == null ? 0.0 : stage['width']! as double;
    final stageTop = stage == null ? 0.0 : stage['top']! as double;
    final stageHeight = stage == null ? 0.0 : stage['height']! as double;
    return <String, Object?>{
      'variant': variantId,
      'camera': cameraId,
      'endpoint': endpoint,
      'viewport': <String, double>{'w': viewport.width, 'h': viewport.height},
      'stage_region_top': rectOf(
        tester,
        const Key('act0_shell_runner_scroll'),
      )?['top'],
      'stage_rect': stage,
      'felt_rect': felt,
      'outer_table_width': stageWidth * nearFactor,
      'outer_table_width_fraction': (stageWidth * nearFactor) / viewport.width,
      'far_silhouette_width': stageWidth * farFactor,
      'far_near_ratio': farFactor / nearFactor,
      'projected_height_fraction': stageHeight / viewport.height,
      'far_rail_fraction': stageTop / viewport.height,
      'near_rail_fraction': (stageTop + stageHeight) / viewport.height,
      'table_center_fraction':
          (stageTop + (stageHeight / 2)) / viewport.height,
      'board_card_0': rectOf(tester, const Key('act0_shell_card_board_0')),
      'board_card_1': rectOf(tester, const Key('act0_shell_card_board_1')),
      'hero_card_0': rectOf(tester, const Key('act0_shell_card_hero_0')),
      'hero_card_1': rectOf(tester, const Key('act0_shell_card_hero_1')),
      'center_info_card': rectOf(
        tester,
        const Key('act0_shell_center_info_card'),
      ),
      'pot_stat': rectOf(
        tester,
        const Key('act0_shell_wave1_pot_priority_stat'),
      ),
      'top_coaching_surface': rectOf(
        tester,
        const Key('act0_wave_a_learning_context'),
      ),
      'top_coaching_support': rectOf(
        tester,
        const Key('act0_learning_scene_v3_support'),
      ),
      'action_dock': rectOf(
        tester,
        const Key('act0_shell_runner_action_dock'),
      ),
      'hero_near_plane': rectOf(
        tester,
        const Key('act0_scene_hero_near_plane'),
      ),
      'player_figures': prefixedRects(tester, 'act0_scene_player_figure_'),
      'lower_surface': rectOf(
        tester,
        const Key('act0_shell_shared_runner_cycle_envelope'),
      ),
    };
  }

  Future<void> runCamera(
    WidgetTester tester,
    String variantId,
    Size viewport,
    String cameraId,
  ) async {
    final dir = Directory(outputDirPath + '/' + variantId + '/' + cameraId)
      ..createSync(recursive: true);


    // Run A - the correct-first path.
    await tester.pumpWidget(host(variantId + cameraId + '_a'));
    await settle(tester);
    await capture(tester, dir.path + '/decision.png');
    measurements.add(
      measure(tester, variantId, viewport, cameraId, 'decision'),
    );
    await hop(tester, const Key('act0_shell_option_check'));
    await capture(tester, dir.path + '/correct_feedback.png');
    measurements.add(
      measure(tester, variantId, viewport, cameraId, 'correct_feedback'),
    );

    // Run B - the canonical repair loop.
    await tester.pumpWidget(host(variantId + cameraId + '_b'));
    await settle(tester);
    await hop(tester, const Key('act0_shell_option_fold'));
    await capture(tester, dir.path + '/wrong_feedback.png');
    measurements.add(
      measure(tester, variantId, viewport, cameraId, 'wrong_feedback'),
    );
    await hop(tester, const Key('act0_shell_feedback_continue_cta'));
    await capture(tester, dir.path + '/repair.png');
    measurements.add(measure(tester, variantId, viewport, cameraId, 'repair'));
    await hop(tester, const Key('act0_shell_option_check'));
    await hop(tester, const Key('act0_shell_feedback_continue_cta'));
    await capture(tester, dir.path + '/recheck.png');
    measurements.add(measure(tester, variantId, viewport, cameraId, 'recheck'));
  }

  Future<void> runVariant(
    WidgetTester tester,
    String variantId,
    Size viewport,
  ) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;

    for (final cameraId in const <String>[
      'canonical',
    ]) {
      await runCamera(tester, variantId, viewport, cameraId);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('B7 scene camera gauntlet', (tester) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(tester.platformDispatcher.resetSystemFontFamily);
$variantStatements
    File(outputDirPath + '/geometry.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(sanitize(measurements)) +
          '\\n',
    );
  });
}
''';
}
