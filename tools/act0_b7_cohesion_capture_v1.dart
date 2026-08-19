// Visual Gauntlet B7 cohesion evidence.
//
// B7 Iteration 1 is a *resting composition* wave: center hierarchy, vertical
// hierarchy, and a state-aware bottom dock. Motion is already proven by B6, so
// this tool deliberately captures only settled endpoints of the real canonical
// route.
//
// TEXT_SCALE_POLICY_V1 = SINGLE_CANONICAL_PRODUCT_SCALE: variants are the three
// required physical phone viewports at one canonical text scale. Accessibility
// text scaling is deferred, so there is no text-scale variant to capture.
//
// It reuses the harness pattern of `tools/act0_b6_semantic_motion_capture_v1.dart`
// rather than adding a second capture architecture.
//
// Output is local-only and uncommitted.
import 'dart:convert';
import 'dart:io';

const _outputRootPathV1 = 'output/visual_gauntlet_b7';

const _endpointsV1 = <String>[
  'endpoint_decision',
  'endpoint_correct_feedback',
  'endpoint_wrong_feedback',
  'endpoint_targeted_repair',
  'endpoint_targeted_recheck',
];

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
  if (args.contains('--help') || args.contains('-h')) {
    stderr.writeln(
      'Usage: dart run tools/act0_b7_cohesion_capture_v1.dart [--label <id>]',
    );
    exit(0);
  }
  final labelIndex = args.indexOf('--label');
  final label = labelIndex >= 0 && labelIndex + 1 < args.length
      ? args[labelIndex + 1]
      : 'current';

  final sha = (await Process.run('git', <String>[
    'rev-parse',
    'HEAD',
  ])).stdout.toString().trim();
  final dirty = (await Process.run('git', <String>[
    'status',
    '--porcelain',
  ])).stdout.toString().trim().isNotEmpty;

  final outputDir = Directory('$_outputRootPathV1/$label');
  if (outputDir.existsSync()) outputDir.deleteSync(recursive: true);
  outputDir.createSync(recursive: true);

  final tempDir = Directory.systemTemp.createTempSync('act0_b7_cohesion_');
  final testFile = File('${tempDir.path}/act0_b7_cohesion_capture_test.dart');
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
    const Duration(minutes: 15),
    onTimeout: () {
      result.kill(ProcessSignal.sigterm);
      return 124;
    },
  );
  try {
    tempDir.deleteSync(recursive: true);
  } catch (_) {}
  if (exitCode != 0) exit(exitCode);

  final entries = <Map<String, Object?>>[];
  for (final variant in _variantsV1) {
    for (final endpoint in _endpointsV1) {
      final path = '${outputDir.path}/${variant.id}/$endpoint.png';
      final file = File(path);
      if (!file.existsSync() || file.lengthSync() == 0) {
        stderr.writeln('Missing or empty B7 endpoint capture `$path`.');
        exit(1);
      }
      entries.add(<String, Object?>{
        'variant': variant.id,
        'endpoint': endpoint,
        'path': path,
        'bytes': file.lengthSync(),
      });
    }
  }

  File('${outputDir.path}/manifest.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': 'act0_visual_gauntlet_b7_cohesion_evidence_v1', 'mission': 'VISUAL_GAUNTLET_B7_BENCHMARK_COHESION_AND_POLISH_V1', 'label': label, 'exact_sha': sha, 'working_tree_dirty': dirty, 'render_kind': 'flutter_widget_test_driven_route_settled_endpoint', 'route': 'canonical learning loop, real taps, no direct state mutation', 'generated_at': DateTime.now().toUtc().toIso8601String(), 'text_scale_policy': 'SINGLE_CANONICAL_PRODUCT_SCALE', 'variants': _variantsV1.map((v) => v.id).toList(), 'endpoints': _endpointsV1, 'captures': entries, 'note': 'Generated B7 evidence is local-only and uncommitted.'})}\n',
  );
  stdout.writeln(outputDir.path);
}

String _testSourceV1(String outputDirPath) {
  final variantStatements = _variantsV1
      .map(
        (v) =>
            '''
    await captureVariant(
      tester,
      '${v.id}',
      const Size(${v.width}, ${v.height}),
    );''',
      )
      .join();
  return '''
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const outputDirPath = ${jsonEncode(outputDirPath)};

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
        key: const Key('act0_b7_capture_boundary'),
        child: Builder(
          builder: (context) => Act0ShellPreviewScreenV1(
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
      find.byKey(const Key('act0_b7_capture_boundary')),
    );
    final byteData = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    if (byteData == null) throw StateError('Failed to capture ' + path);
    File(path).writeAsBytesSync(Uint8List.view(byteData.buffer));
  }

  /// Settles without `pumpAndSettle`, which cannot be used mid-evidence because
  /// unrelated long-running proof motion also lives on this route.
  Future<void> settle(WidgetTester tester) async {
    var frames = 0;
    while (tester.binding.hasScheduledFrame && frames < 400) {
      await tester.pump(const Duration(milliseconds: 16));
      frames++;
    }
  }

  Future<void> hop(WidgetTester tester, Key key) async {
    final finder = find.byKey(key).first;
    await tester.ensureVisible(finder);
    await settle(tester);
    await tester.tap(finder, warnIfMissed: false);
    await settle(tester);
  }

  Future<void> captureVariant(
    WidgetTester tester,
    String variantId,
    Size size,
  ) async {
    final dir = Directory(outputDirPath + '/' + variantId)
      ..createSync(recursive: true);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;

    // Run A - the correct-first path.
    await tester.pumpWidget(host(variantId + '_a'));
    await settle(tester);
    await capture(tester, dir.path + '/endpoint_decision.png');
    await hop(tester, const Key('act0_shell_option_check'));
    await capture(tester, dir.path + '/endpoint_correct_feedback.png');

    // Run B - the canonical repair loop.
    await tester.pumpWidget(host(variantId + '_b'));
    await settle(tester);
    await hop(tester, const Key('act0_shell_option_fold'));
    await capture(tester, dir.path + '/endpoint_wrong_feedback.png');
    await hop(tester, const Key('act0_shell_feedback_continue_cta'));
    await capture(tester, dir.path + '/endpoint_targeted_repair.png');
    await hop(tester, const Key('act0_shell_option_check'));
    await hop(tester, const Key('act0_shell_feedback_continue_cta'));
    await capture(tester, dir.path + '/endpoint_targeted_recheck.png');

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('capture Visual Gauntlet B7 cohesion evidence', (tester) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(tester.platformDispatcher.resetSystemFontFamily);
$variantStatements
  });
}
''';
}
