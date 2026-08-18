// Visual Gauntlet B6 motion evidence.
//
// Static screenshots cannot prove B6, so this drives the *real* canonical
// learning route with real taps and captures the frame sequence each
// transition actually produces, plus the settled endpoint of every phase.
//
// It deliberately reuses the existing evidence pattern rather than adding a
// harness: the same generated-widget-test frame capture as
// `tools/act0_motion_evidence_capture_v1.dart`, and the same GIF encoder as
// `tools/act0_motion_media_export_v1.dart`.
//
// Output is local-only and uncommitted.
import 'dart:convert';
import 'dart:io';

import 'act0_motion_media_export_v1.dart'
    show Act0MotionMediaMomentV1, exportAct0MotionMediaMomentGifV1;

const _outputRootPathV1 = 'output/visual_gauntlet_b6';

/// Frame offsets in ms after the tap, chosen to cover the measured travel
/// profile: the departure frame, the responsive first half, and the settle.
const _frameTimesMsV1 = <int>[0, 32, 64, 128, 192, 260];

/// Every transition the B6 packet requires evidence for.
const _transitionsV1 = <String>[
  'decision_to_correct_feedback',
  'decision_to_wrong_feedback',
  'wrong_feedback_to_targeted_repair',
  'repair_success_to_targeted_recheck',
  'recheck_to_result_continuation',
];

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
    this.textScale = 1.0,
    this.reducedMotion = false,
  });

  final String id;
  final double width;
  final double height;
  final double textScale;
  final bool reducedMotion;
}

const _variantsV1 = <_VariantV1>[
  _VariantV1(id: 'canonical_402x874', width: 402, height: 874),
  _VariantV1(
    id: 'reduced_motion_402x874',
    width: 402,
    height: 874,
    reducedMotion: true,
  ),
  _VariantV1(id: 'compact_375x812', width: 375, height: 812),
  _VariantV1(id: 'large_430x932', width: 430, height: 932),
  _VariantV1(id: 'text_1_4x_402x874', width: 402, height: 874, textScale: 1.4),
];

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    stderr.writeln(
      'Usage: dart run tools/act0_b6_semantic_motion_capture_v1.dart',
    );
    exit(args.contains('--help') || args.contains('-h') ? 0 : 64);
  }

  final sha = (await Process.run('git', <String>[
    'rev-parse',
    'HEAD',
  ])).stdout.toString().trim();
  final dirty = (await Process.run('git', <String>[
    'status',
    '--porcelain',
  ])).stdout.toString().trim().isNotEmpty;

  final outputDir = Directory(_outputRootPathV1);
  if (outputDir.existsSync()) outputDir.deleteSync(recursive: true);
  outputDir.createSync(recursive: true);

  final tempDir = Directory.systemTemp.createTempSync('act0_b6_motion_');
  final testFile = File(
    '${tempDir.path}/act0_b6_semantic_motion_capture_test.dart',
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
    const Duration(minutes: 10),
    onTimeout: () {
      result.kill(ProcessSignal.sigterm);
      return 124;
    },
  );
  try {
    tempDir.deleteSync(recursive: true);
  } catch (_) {}
  if (exitCode != 0) exit(exitCode);

  // Verify every required artefact exists, then encode one GIF per transition.
  final entries = <Map<String, Object?>>[];
  final gifs = <Map<String, Object?>>[];
  for (final variant in _variantsV1) {
    final variantDir = Directory('${outputDir.path}/${variant.id}');
    for (final transition in _transitionsV1) {
      for (final frameMs in _frameTimesMsV1) {
        final path =
            '${variantDir.path}/${transition}_frame_${frameMs.toString().padLeft(3, '0')}ms.png';
        final file = File(path);
        if (!file.existsSync() || file.lengthSync() == 0) {
          stderr.writeln('Missing or empty B6 motion frame `$path`.');
          exit(1);
        }
        entries.add(<String, Object?>{
          'variant': variant.id,
          'transition': transition,
          'frame_ms': frameMs,
          'path': path,
          'bytes': file.lengthSync(),
        });
      }
      final export = exportAct0MotionMediaMomentGifV1(
        inputRoot: variantDir,
        outputRoot: Directory('${outputDir.path}/${variant.id}/gif'),
        moment: Act0MotionMediaMomentV1(
          id: transition,
          frameTimesMs: _frameTimesMsV1,
        ),
      );
      gifs.add(export.toJson()..['variant'] = variant.id);
    }
    for (final endpoint in _endpointsV1) {
      final path = '${variantDir.path}/$endpoint.png';
      final file = File(path);
      if (!file.existsSync() || file.lengthSync() == 0) {
        stderr.writeln('Missing or empty B6 endpoint capture `$path`.');
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
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': 'act0_visual_gauntlet_b6_motion_evidence_v1', 'mission': 'VISUAL_GAUNTLET_B6_SEMANTIC_MOTION_V1', 'exact_sha': sha, 'working_tree_dirty': dirty, 'render_kind': 'flutter_widget_test_driven_route_frame_sequence', 'route': 'canonical learning loop, real taps, no direct state mutation', 'generated_at': DateTime.now().toUtc().toIso8601String(), 'frame_times_ms': _frameTimesMsV1, 'variants': _variantsV1.map((v) => v.id).toList(), 'frames': entries, 'gifs': gifs, 'note': 'Generated B6 evidence is local-only and uncommitted.'})}\n',
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
      ${v.textScale},
      ${v.reducedMotion},
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
  const frameTimesMs = <int>${jsonEncode(_frameTimesMsV1)};

  Widget host(Object remountKey, double textScale, bool reducedMotion) {
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
        key: const Key('act0_b6_capture_boundary'),
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: reducedMotion ? true : null,
              textScaler: TextScaler.linear(textScale),
            ),
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
      find.byKey(const Key('act0_b6_capture_boundary')),
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

  /// Taps a real control and captures the frames the transition produces.
  Future<void> transition(
    WidgetTester tester,
    String dir,
    String id,
    Key key,
  ) async {
    final finder = find.byKey(key).first;
    await tester.ensureVisible(finder);
    await settle(tester);
    await tester.tap(finder, warnIfMissed: false);
    var elapsed = 0;
    for (final frameMs in frameTimesMs) {
      final delta = frameMs - elapsed;
      if (delta > 0) {
        await tester.pump(Duration(milliseconds: delta));
        elapsed = frameMs;
      } else {
        await tester.pump();
      }
      final name =
          id + '_frame_' + frameMs.toString().padLeft(3, '0') + 'ms.png';
      await capture(tester, dir + '/' + name);
    }
    await settle(tester);
  }

  Future<void> captureVariant(
    WidgetTester tester,
    String variantId,
    Size size,
    double textScale,
    bool reducedMotion,
  ) async {
    final dir = Directory(outputDirPath + '/' + variantId)
      ..createSync(recursive: true);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;

    // Run A - the correct-first path, for `decision -> correct feedback`.
    await tester.pumpWidget(host(variantId + '_a', textScale, reducedMotion));
    await settle(tester);
    await capture(tester, dir.path + '/endpoint_decision.png');
    await transition(
      tester,
      dir.path,
      'decision_to_correct_feedback',
      const Key('act0_shell_option_check'),
    );
    await capture(tester, dir.path + '/endpoint_correct_feedback.png');

    // Run B - the canonical repair loop.
    await tester.pumpWidget(host(variantId + '_b', textScale, reducedMotion));
    await settle(tester);
    await transition(
      tester,
      dir.path,
      'decision_to_wrong_feedback',
      const Key('act0_shell_option_fold'),
    );
    await capture(tester, dir.path + '/endpoint_wrong_feedback.png');

    await transition(
      tester,
      dir.path,
      'wrong_feedback_to_targeted_repair',
      const Key('act0_shell_feedback_continue_cta'),
    );
    await capture(tester, dir.path + '/endpoint_targeted_repair.png');

    // Repair success resolves through the correct-feedback beat and then
    // releases into the targeted recheck.
    await transition(
      tester,
      dir.path,
      'repair_success_to_targeted_recheck',
      const Key('act0_shell_option_check'),
    );
    await transition(
      tester,
      dir.path,
      'recheck_to_result_continuation',
      const Key('act0_shell_feedback_continue_cta'),
    );
    await capture(tester, dir.path + '/endpoint_targeted_recheck.png');

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('capture Visual Gauntlet B6 semantic motion evidence', (
    tester,
  ) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(tester.platformDispatcher.resetSystemFontFamily);
$variantStatements
  });
}
''';
}
