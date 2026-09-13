// PR224_V4R1_FINAL_SPATIAL_SUPPORT_INTEGRATION_V1 real-runtime evidence.
//
// Reuses the harness shape of `tools/act0_render_class_hybrid_capture_v1.dart`
// (three canonical viewports, real route taps, explicit authored-asset warm-up
// before the first pump) and records the states the manager-final integration
// has to be judged on: an ordinary decision, feedback/Coach, an inactive/folded
// opponent, the pre-Hero-ready choreography frame, the Hero-ready frame, and
// the cold first-visible frame. It also writes the ownership crops and the
// one-table contour proof so the manager inspects actual pixels rather than
// metrics.
//
// Output is local-only and uncommitted.
import 'dart:convert';
import 'dart:io';

const _outputRootPathV1 = 'output/pr224_v4r1_final_integration';

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
  _VariantV1(id: 'compact_375x812', width: 375, height: 812),
  _VariantV1(id: 'canonical_402x874', width: 402, height: 874),
  _VariantV1(id: 'large_430x932', width: 430, height: 932),
];

/// Endpoints captured at every viewport.
const _sharedEndpointsV1 = <String>[
  'ordinary_decision',
  'crop_bb_sb_ownership',
  'feedback_coach',
  'inactive_folded',
];

/// Endpoints captured only on the canonical viewport.
const _canonicalOnlyEndpointsV1 = <String>[
  'choreography_pre_hero_ready',
  'hero_ready',
  'cold_first_visible_frame',
  'cold_all_ready',
  'one_table_contour_proof',
  'crop_hj_co_ownership',
];

Future<void> main(List<String> args) async {
  final labelIndex = args.indexOf('--label');
  final label = labelIndex >= 0 && labelIndex + 1 < args.length
      ? args[labelIndex + 1]
      : 'v4r1_final';

  final sha = (await Process.run('git', <String>[
    'rev-parse',
    'HEAD',
  ])).stdout.toString().trim();

  final outputDir = Directory('$_outputRootPathV1/$label');
  if (outputDir.existsSync()) outputDir.deleteSync(recursive: true);
  outputDir.createSync(recursive: true);

  final tempDir = Directory.systemTemp.createTempSync('act0_v4r1_final_');
  final testFile = File('${tempDir.path}/act0_v4r1_final_capture_test.dart');
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
  void require(String path) {
    final file = File(path);
    if (!file.existsSync() || file.lengthSync() == 0) missing.add(path);
  }

  for (final variant in _variantsV1) {
    for (final endpoint in _sharedEndpointsV1) {
      require('${outputDir.path}/${variant.id}/$endpoint.png');
    }
  }
  for (final endpoint in _canonicalOnlyEndpointsV1) {
    require('${outputDir.path}/canonical_402x874/$endpoint.png');
  }
  if (missing.isNotEmpty) {
    stderr.writeln('Missing captures:\n${missing.join('\n')}');
    exit(1);
  }

  File('${outputDir.path}/manifest.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': 'act0_pr224_v4r1_final_integration_evidence_v1', 'mission': 'PR224_V4R1_FINAL_SPATIAL_SUPPORT_INTEGRATION_V1', 'label': label, 'exact_sha': sha, 'variants': _variantsV1.map((variant) => variant.id).toList(), 'shared_endpoints': _sharedEndpointsV1, 'canonical_only_endpoints': _canonicalOnlyEndpointsV1, 'note': 'Generated evidence is local-only and uncommitted.'})}\n',
  );
  stdout.writeln(outputDir.path);
}

String _testSourceV1(String outputDirPath) {
  final variantStatements = _variantsV1
      .map(
        (variant) => '''
    await runVariant(tester, '${variant.id}', const Size(${variant.width}, ${variant.height}));''',
      )
      .join('\n');
  return '''
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
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_registered_cast_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_room_plate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const outputDirPath = ${jsonEncode(outputDirPath)};
  const boundaryKey = Key('act0_v4r1_final_capture_boundary');

  Widget host(Object remountKey, {String taskId = 'actions_check_drill'}) {
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
        key: boundaryKey,
        child: Act0ShellPreviewScreenV1(
          key: ValueKey<Object>(remountKey),
          state: Act0ShellStateV1.sample,
          showPlacementOnStart: false,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
            worldId: 'world_1',
            lessonId: 'fold_check_call_raise',
            taskId: taskId,
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
    // Real glyphs, so the Coach and action surfaces are legible in the
    // evidence instead of the test binding's blank boxes. The macOS path is
    // the original harness's; the Linux fallbacks keep CI/container captures
    // readable. Nothing here reaches production.
    for (final candidate in const <String>[
      '/System/Library/Fonts/Supplemental/Arial.ttf',
      '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
      '/usr/share/fonts/truetype/freefont/FreeSans.ttf',
    ]) {
      final file = File(candidate);
      if (!file.existsSync()) continue;
      final bytes = await file.readAsBytes();
      await loadFontFamily('Roboto', bytes);
      await loadFontFamily('Ahem', bytes);
      break;
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

  Future<void> capture(WidgetTester tester, String path, {Rect? crop}) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundaryKey),
    );
    final byteData = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      if (crop == null) {
        return image.toByteData(format: ui.ImageByteFormat.png);
      }
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final source = Rect.fromLTRB(
        crop.left * 2.0,
        crop.top * 2.0,
        crop.right * 2.0,
        crop.bottom * 2.0,
      );
      final destination = Rect.fromLTWH(0, 0, source.width, source.height);
      canvas.drawImageRect(image, source, destination, Paint());
      final cropped = await recorder.endRecording().toImage(
        source.width.round(),
        source.height.round(),
      );
      return cropped.toByteData(format: ui.ImageByteFormat.png);
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
      throw StateError('v4r1 capture: missing route control ' + key.toString());
    }
    final finder = find.byKey(key).first;
    await tester.ensureVisible(finder);
    await settle(tester);
    await tester.tap(finder, warnIfMissed: false);
    await settle(tester);
  }

  Rect? globalRectOf(Finder finder) {
    final elements = finder.evaluate();
    if (elements.isEmpty) return null;
    final box = elements.first.renderObject! as RenderBox;
    return MatrixUtils.transformRect(
      box.getTransformTo(null),
      Offset.zero & box.size,
    );
  }

  Rect ownershipCrop(List<String> seatIds, Size viewport) {
    Rect? union;
    for (final seatId in seatIds) {
      for (final finder in <Finder>[
        find.byKey(Key('act0_scene_player_figure_' + seatId)),
        find.byKey(Key('act0_shell_seat_node_' + seatId)),
        // The commitment chip belongs in the ownership crop: the SB clearance
        // repair is only provable if its own blind chip is visible beside it.
        find.byKey(Key('act0_shell_bet_chip_owner_' + seatId)),
      ]) {
        final rect = globalRectOf(finder);
        if (rect == null) continue;
        union = union == null ? rect : union.expandToInclude(rect);
      }
    }
    final base = union ?? (Offset.zero & viewport);
    return Rect.fromLTRB(
      (base.left - 18).clamp(0.0, viewport.width),
      (base.top - 18).clamp(0.0, viewport.height),
      (base.right + 18).clamp(0.0, viewport.width),
      (base.bottom + 18).clamp(0.0, viewport.height),
    );
  }

  Future<void> warmEverything(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Act0SceneRoomPlateImageStoreV1.shared.warmUp();
      await Act0SceneHybridShellRegistryV1.heroStore.warmUp();
      await Act0SceneRegisteredCastReadinessV1.shared.warmUp();
    });
    if (!Act0SceneHybridShellRegistryV1.shellStore.isReady) {
      throw StateError(
        'hybrid shell did not decode: capture would record the fallback room',
      );
    }
    if (Act0SceneRegisteredCastReadinessV1.shared.phase !=
        Act0SceneRegisteredCastPhaseV1.ready) {
      throw StateError(
        'registered V4R1 cast did not decode: capture would record the fallback cast',
      );
    }
  }

  void resetStores() {
    Act0SceneRoomPlateImageStoreV1.shared.clear();
    Act0SceneHybridShellRegistryV1.shellStore.clear();
    Act0SceneHybridShellRegistryV1.heroStore.clear();
    Act0SceneCharacterImageStoreV1.shared.clear();
    Act0SceneRegisteredCastReadinessV1.shared.reset();
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
    final canonical = variantId == 'canonical_402x874';

    if (canonical) {
      // Cold start, nothing decoded: the first visible frame must already be
      // one coherent scene, with no generic cast that later swaps identity.
      resetStores();
      await tester.pumpWidget(host(variantId + '_cold'));
      await tester.pump();
      await capture(tester, dir.path + '/cold_first_visible_frame.png');
      await capture(tester, dir.path + '/choreography_pre_hero_ready.png');
      await warmEverything(tester);
      await settle(tester);
      await capture(tester, dir.path + '/cold_all_ready.png');
      await capture(tester, dir.path + '/hero_ready.png');
    }

    await warmEverything(tester);

    // Run A - the ordinary decision and the Coach/feedback surface.
    await tester.pumpWidget(host(variantId + '_a'));
    await settle(tester);
    await capture(tester, dir.path + '/ordinary_decision.png');
    await capture(
      tester,
      dir.path + '/crop_bb_sb_ownership.png',
      crop: ownershipCrop(const <String>['bb', 'sb'], viewport),
    );
    if (canonical) {
      await capture(tester, dir.path + '/one_table_contour_proof.png');
      await capture(
        tester,
        dir.path + '/crop_hj_co_ownership.png',
        crop: ownershipCrop(const <String>['hj', 'co'], viewport),
      );
    }
    await hop(tester, const Key('act0_shell_option_check'));
    await capture(tester, dir.path + '/feedback_coach.png');

    // Run B - a source-owned inactive/folded opponent. `actions_raise_drill`
    // authors CO as folded and UTG as out of hand, so the human-only fold
    // attenuation is exercised on the real table rather than simulated.
    await tester.pumpWidget(
      host(variantId + '_b', taskId: 'actions_raise_drill'),
    );
    await settle(tester);
    if (find.byKey(const Key('act0_shell_folded_badge')).evaluate().isEmpty) {
      throw StateError(
        'v4r1 capture: ' +
            variantId +
            ' inactive/folded endpoint has no folded opponent',
      );
    }
    await capture(tester, dir.path + '/inactive_folded.png');

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('pr224 v4r1 final integration capture', (tester) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(tester.platformDispatcher.resetSystemFontFamily);
$variantStatements
  });
}
''';
}
