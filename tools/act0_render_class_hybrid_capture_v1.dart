// RENDER_CLASS_HYBRID_INTEGRATION_V1 real-runtime evidence.
//
// Reuses the harness shape of `tools/act0_b7_canonical_scene_capture_v1.dart`
// (three canonical viewports, real route taps, geometry.json) and adds
// exactly one thing on top: an explicit authored-asset warm-up before the
// first pump. `testWidgets` runs inside a fake-async zone, so real bundle I/O
// and image decoding never complete on their own — without `runAsync`, every
// capture would silently record the procedural/room-plate fallback instead of
// the hybrid shell, the Hero POV foreground and the production CAST V4, and
// the evidence would misreport what is actually being exercised.
//
// Output is local-only and uncommitted.
import 'dart:convert';
import 'dart:io';

const _outputRootPathV1 = 'output/visual_gauntlet_render_class_hybrid';

const _endpointsV1 = <String>[
  'decision',
  'correct_feedback',
  'wrong_feedback',
  'repair',
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

  final tempDir = Directory.systemTemp.createTempSync(
    'act0_render_class_hybrid_',
  );
  final testFile = File(
    '${tempDir.path}/act0_render_class_hybrid_capture_test.dart',
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
    for (final endpoint in _endpointsV1) {
      final path = '${outputDir.path}/${variant.id}/$endpoint.png';
      final file = File(path);
      if (!file.existsSync() || file.lengthSync() == 0) missing.add(path);
    }
  }
  if (missing.isNotEmpty) {
    stderr.writeln('Missing captures:\n${missing.join('\n')}');
    exit(1);
  }

  File('${outputDir.path}/manifest.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': 'act0_render_class_hybrid_evidence_v1', 'mission': 'RENDER_CLASS_HYBRID_INTEGRATION_GAUNTLET_V1', 'label': label, 'exact_sha': sha, 'variants': _variantsV1.map((v) => v.id).toList(), 'endpoints': _endpointsV1, 'note': 'Generated evidence is local-only and uncommitted.'})}\n',
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
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_character_asset_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_hybrid_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_room_plate_v1.dart';
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
        key: const Key('act0_render_class_hybrid_capture_boundary'),
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
      find.byKey(const Key('act0_render_class_hybrid_capture_boundary')),
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
      throw StateError('render-class gauntlet: missing route control ' + key.toString());
    }
    final finder = find.byKey(key).first;
    await tester.ensureVisible(finder);
    await settle(tester);
    await tester.tap(finder, warnIfMissed: false);
    await settle(tester);
  }

  Future<void> runVariant(
    WidgetTester tester,
    String variantId,
    Size viewport,
  ) async {
    final dir = Directory(outputDirPath + '/' + variantId)
      ..createSync(recursive: true);
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;

    // Run A - the correct-first path.
    await tester.pumpWidget(host(variantId + '_a'));
    await settle(tester);
    await capture(tester, dir.path + '/decision.png');
    await hop(tester, const Key('act0_shell_option_check'));
    await capture(tester, dir.path + '/correct_feedback.png');

    // Run B - the canonical repair loop.
    await tester.pumpWidget(host(variantId + '_b'));
    await settle(tester);
    await hop(tester, const Key('act0_shell_option_fold'));
    await capture(tester, dir.path + '/wrong_feedback.png');
    await hop(tester, const Key('act0_shell_feedback_continue_cta'));
    await capture(tester, dir.path + '/repair.png');

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('render-class hybrid capture', (tester) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(tester.platformDispatcher.resetSystemFontFamily);

    // Decode every authored asset on the real event loop before any frame is
    // pumped, so every captured endpoint renders the integrated hybrid scene
    // deterministically instead of silently recording a fallback.
    await tester.runAsync(() async {
      await Act0SceneRoomPlateImageStoreV1.shared.warmUp();
      await Act0SceneHybridShellRegistryV1.shellStore.warmUp();
      await Act0SceneHybridShellRegistryV1.heroStore.warmUp();
      for (final identity in Act0SceneCharacterIdentityV1.values) {
        await Act0SceneCharacterImageStoreV1.shared.load(
          Act0SceneCharacterAssetRegistryV1.engagedPathFor(identity),
        );
      }
    });
    if (!Act0SceneHybridShellRegistryV1.shellStore.isReady) {
      throw StateError('hybrid shell did not decode: capture would record the fallback room');
    }
    if (!Act0SceneHybridShellRegistryV1.heroStore.isReady) {
      throw StateError('Hero POV foreground did not decode: capture would record the procedural Hero');
    }
$variantStatements
  });
}
''';
}
