import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _outputDirPathV1 =
    'output/screen_review/current/act0_layout_masked_proof';

const _layoutAllowedClaimsV1 = <String>[
  'layout',
  'geometry',
  'safe_area',
  'cta_placement',
  'spacing',
  'surface_identity',
];

const _maskedDisallowedClaimsV1 = <String>[
  'copy',
  'content',
  'tone',
  'product_readiness',
  'premium_readiness',
  'learning_depth',
  'payoff_quality',
  'repair_personalization',
];

const _viewportsV1 = <String>[
  'compact_phone',
  'tall_phone',
  'large_phone',
  'tablet',
];

const _surfacesV1 = <String>[
  'placement',
  'welcome',
  'home',
  'learn',
  'learn_detail',
  'play',
  'feedback',
  'practice_repair',
  'completion_payoff',
  'summary',
  'review_profile',
  'w12_terminal',
];

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    _printUsageV1();
    exit(0);
  }

  final outputDir = Directory(_outputDirPathV1);
  if (outputDir.existsSync()) {
    outputDir.deleteSync(recursive: true);
  }
  outputDir.createSync(recursive: true);

  final tempDir = Directory.systemTemp.createTempSync(
    'act0_product_100_proof_capture_',
  );
  final testFile = File(
    '${tempDir.path}${Platform.pathSeparator}act0_product_100_proof_capture_test.dart',
  );
  testFile.writeAsStringSync(_flutterTestSource(outputDir.path));

  final result = await Process.start('flutter', <String>[
    'test',
    testFile.path,
  ], workingDirectory: Directory.current.path);
  final stdoutDone = stdout.addStream(result.stdout);
  final stderrDone = stderr.addStream(result.stderr);
  final exitCode = await result.exitCode;
  await Future.wait(<Future<void>>[stdoutDone, stderrDone]);

  try {
    tempDir.deleteSync(recursive: true);
  } catch (_) {
    // Best-effort cleanup.
  }

  if (exitCode != 0) {
    throw ProcessException(
      'flutter',
      <String>['test', testFile.path],
      'Act0 product 100 proof capture failed. See output above.',
      exitCode,
    );
  }

  final entries = <Map<String, Object?>>[];
  for (final viewport in _viewportsV1) {
    for (final surface in _surfacesV1) {
      final file = File(
        '${outputDir.path}${Platform.pathSeparator}$viewport.$surface.png',
      );
      if (!file.existsSync()) {
        throw StateError('Missing screenshot artifact `${file.path}`.');
      }
      entries.add(<String, Object?>{
        'lane_type': 'layout_contract',
        'evidence_type': 'layout_masked',
        'render_kind': 'nonliteral_preview_contract',
        'is_real_text': false,
        'supports_product_copy_review': false,
        'supports_alpha_admission': false,
        'viewport': viewport,
        'surface': surface,
        'surface_identity': surface,
        'path': file.path.replaceAll(
          '${Directory.current.path}${Platform.pathSeparator}',
          '',
        ),
        'bytes': file.lengthSync(),
        'sha256': sha256.convert(file.readAsBytesSync()).toString(),
        'allowed_claims': _layoutAllowedClaimsV1,
        'disallowed_claims': _maskedDisallowedClaimsV1,
        'semantic_assertions': _semanticAssertionsForSurfaceV1(surface),
        'debug_surface': _debugSurfaceForSurfaceV1(surface),
        'source_route': 'Act0ShellPreviewScreenV1.controlled_demo',
        'capture_source_policy': 'masked_layout_contract_only',
      });
    }
  }
  final terminalByteComparison = compareTerminalProofBytesV1(outputDir);
  final playHomeByteComparison = comparePlayHomeProofBytesV1(outputDir);
  final duplicateHashPolicy = duplicateHashPolicyV1(entries);

  final manifestFile = File(
    '${outputDir.path}${Platform.pathSeparator}manifest.json',
  );
  manifestFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'artifact_dir': outputDir.path.replaceAll('${Directory.current.path}${Platform.pathSeparator}', ''), 'lane_type': 'layout_contract', 'evidence_type': 'layout_masked', 'render_kind': 'nonliteral_preview_contract', 'is_real_text': false, 'supports_product_copy_review': false, 'supports_alpha_admission': false, 'allowed_claims': _layoutAllowedClaimsV1, 'disallowed_claims': _maskedDisallowedClaimsV1, 'viewports': _viewportsV1, 'surfaces': _surfacesV1, 'entries': entries, 'terminal_play_byte_comparison': terminalByteComparison, 'play_home_byte_comparison': playHomeByteComparison, 'duplicate_hash_policy': duplicateHashPolicy, 'note': 'Masked layout-contract evidence only. It supports geometry, clipping, overlap, safe-area, responsive recomposition, physical CTA visibility, and state/layout distinctness. It cannot authorize Alpha admission or product-copy review.'})}\n',
  );
}

List<String> _semanticAssertionsForSurfaceV1(String surface) {
  return switch (surface) {
    'play' => <String>[
      'runner_screen_present',
      'decision_prompt_present',
      'action_controls_present',
      'table_context_present',
    ],
    'w12_terminal' => <String>[
      'volume_i_terminal_review_present',
      'future_world_copy_present',
      'world13_absent',
      'w13_absent',
    ],
    _ => <String>['surface_renders_non_empty'],
  };
}

String _debugSurfaceForSurfaceV1(String surface) {
  return switch (surface) {
    'placement' => 'Act0ControlledDemoCaptureSurfaceV1.placement',
    'welcome' => 'Act0ControlledDemoCaptureSurfaceV1.welcome',
    'home' => 'Act0ControlledDemoCaptureSurfaceV1.firstWeekHome',
    'learn' => 'Act0ControlledDemoCaptureSurfaceV1.firstWeekLearn',
    'learn_detail' => 'Act0ShellPreviewScreenV1.learn_detail_interaction',
    'play' => 'Act0ControlledDemoCaptureSurfaceV1.runnerDrill',
    'feedback' => 'Act0ControlledDemoCaptureSurfaceV1.runnerFirstWrongFeedback',
    'practice_repair' =>
      'Act0ControlledDemoCaptureSurfaceV1.day2PracticeRepairTarget',
    'completion_payoff' => 'Act0ControlledDemoCaptureSurfaceV1.worldCompletion',
    'summary' => 'Act0ControlledDemoCaptureSurfaceV1.sessionSummary',
    'review_profile' => 'Act0ControlledDemoCaptureSurfaceV1.profileEvidence',
    'w12_terminal' => 'Act0ControlledDemoCaptureSurfaceV1.w12Terminal',
    _ => 'unknown',
  };
}

Map<String, Object?> compareTerminalProofBytesV1(Directory outputDir) {
  final results = <Map<String, Object?>>[];
  for (final viewport in _viewportsV1) {
    final playFile = File(
      '${outputDir.path}${Platform.pathSeparator}$viewport.play.png',
    );
    final terminalFile = File(
      '${outputDir.path}${Platform.pathSeparator}$viewport.w12_terminal.png',
    );
    if (!playFile.existsSync() || !terminalFile.existsSync()) {
      throw StateError('Missing play/w12_terminal byte comparison inputs.');
    }
    final playBytes = playFile.readAsBytesSync();
    final terminalBytes = terminalFile.readAsBytesSync();
    final byteIdentical = _sameBytesV1(playBytes, terminalBytes);
    if (byteIdentical) {
      throw StateError(
        'w12_terminal proof is byte-identical to play for `$viewport`.',
      );
    }
    results.add(<String, Object?>{
      'viewport': viewport,
      'play_path': playFile.path.replaceAll(
        '${Directory.current.path}${Platform.pathSeparator}',
        '',
      ),
      'terminal_path': terminalFile.path.replaceAll(
        '${Directory.current.path}${Platform.pathSeparator}',
        '',
      ),
      'byte_identical': false,
      'play_bytes': playBytes.length,
      'terminal_bytes': terminalBytes.length,
    });
  }
  return <String, Object?>{
    'all_terminal_images_differ_from_play': true,
    'comparisons': results,
  };
}

Map<String, Object?> comparePlayHomeProofBytesV1(Directory outputDir) {
  final results = <Map<String, Object?>>[];
  for (final viewport in _viewportsV1) {
    final playFile = File(
      '${outputDir.path}${Platform.pathSeparator}$viewport.play.png',
    );
    final homeFile = File(
      '${outputDir.path}${Platform.pathSeparator}$viewport.home.png',
    );
    if (!playFile.existsSync() || !homeFile.existsSync()) {
      throw StateError('Missing play/home byte comparison inputs.');
    }
    final playBytes = playFile.readAsBytesSync();
    final homeBytes = homeFile.readAsBytesSync();
    final byteIdentical = _sameBytesV1(playBytes, homeBytes);
    if (byteIdentical) {
      throw StateError('play proof is byte-identical to home for `$viewport`.');
    }
    results.add(<String, Object?>{
      'viewport': viewport,
      'play_path': playFile.path.replaceAll(
        '${Directory.current.path}${Platform.pathSeparator}',
        '',
      ),
      'home_path': homeFile.path.replaceAll(
        '${Directory.current.path}${Platform.pathSeparator}',
        '',
      ),
      'byte_identical': false,
      'play_bytes': playBytes.length,
      'home_bytes': homeBytes.length,
    });
  }
  return <String, Object?>{
    'all_play_images_differ_from_home': true,
    'comparisons': results,
  };
}

Map<String, Object?> duplicateHashPolicyV1(List<Map<String, Object?>> entries) {
  final byViewport = <String, Map<String, List<String>>>{};
  for (final entry in entries) {
    final viewport = entry['viewport'] as String;
    final surface = entry['surface'] as String;
    final hash = entry['sha256'] as String;
    byViewport.putIfAbsent(viewport, () => <String, List<String>>{});
    byViewport[viewport]!.putIfAbsent(hash, () => <String>[]).add(surface);
  }
  final duplicates = <Map<String, Object?>>[];
  for (final viewportEntry in byViewport.entries) {
    for (final hashEntry in viewportEntry.value.entries) {
      if (hashEntry.value.length <= 1) {
        continue;
      }
      duplicates.add(<String, Object?>{
        'viewport': viewportEntry.key,
        'sha256': hashEntry.key,
        'surfaces': hashEntry.value,
      });
    }
  }
  if (duplicates.isNotEmpty) {
    throw StateError(
      'Unlisted duplicate screenshot hashes in layout-contract lane: '
      '$duplicates',
    );
  }
  return <String, Object?>{
    'policy': 'disallow_unlisted_duplicates',
    'intentional_same_state_allowlist': <String>[],
    'duplicates': duplicates,
  };
}

bool _sameBytesV1(List<int> left, List<int> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

String _flutterTestSource(String outputDirPath) {
  final escapedOutputDir = jsonEncode(outputDirPath);
  return '''
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef _BuildFlowV1 = Future<void> Function();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const outputDirPath = $escapedOutputDir;
  final outputDir = Directory(outputDirPath)..createSync(recursive: true);
  const viewports = <String, Size>{
    'compact_phone': Size(375, 812),
    'tall_phone': Size(390, 844),
    'large_phone': Size(430, 932),
    'tablet': Size(834, 1194),
  };

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget host({
    Act0ShellTabV1 tab = Act0ShellTabV1.home,
    Act0LessonPhaseV1 phase = Act0LessonPhaseV1.theory,
    bool showPlacementOnStart = false,
    Act0ControlledDemoCaptureSurfaceV1? debugSurface,
    String? worldId,
    String? lessonId,
    String? taskId,
  }) {
    return MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        initialTab: tab,
        initialPhase: phase,
        showPlacementOnStart: showPlacementOnStart,
        debugHarnessEntry: debugSurface == null
            ? null
            : Act0ShellDebugHarnessEntryV1(
                mode: Act0ControlledDemoCaptureModeV1.directState,
                surface: debugSurface,
                worldId: worldId,
                lessonId: lessonId,
                taskId: taskId,
              ),
      ),
    );
  }

  Future<void> pumpSized(
    WidgetTester tester,
    Widget widget,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  Future<void> tapVisibleTargetV1(
    WidgetTester tester,
    Finder target,
    String targetDescription,
  ) async {
    if (target.evaluate().isEmpty) {
      throw StateError('Missing visible target for ' + targetDescription);
    }
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    final center = tester.getCenter(target);
    final rootSize = Size(
      tester.view.physicalSize.width / tester.view.devicePixelRatio,
      tester.view.physicalSize.height / tester.view.devicePixelRatio,
    );
    if (center.dx < 0 ||
        center.dy < 0 ||
        center.dx > rootSize.width ||
        center.dy > rootSize.height) {
      throw StateError(
        'Target center outside viewport for ' +
            targetDescription +
            ': ' +
            center.toString() +
            ' outside ' +
            rootSize.toString(),
      );
    }
    await tester.tap(target, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  Future<void> openBottomTabByLabelV1(
    WidgetTester tester,
    String label,
  ) async {
    final nav = find.byKey(const Key('act0_shell_bottom_nav'));
    if (nav.evaluate().isEmpty) {
      throw StateError('Missing visible target for bottom nav');
    }
    final target = find.descendant(of: nav, matching: find.text(label)).first;
    await tapVisibleTargetV1(tester, target, 'bottom nav ' + label);
  }

  Finder findLessonCardsV1() {
    return find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key != null && key.toString().contains('act0_shell_lesson_');
    });
  }

  Future<void> openLearnDetailIfNeededV1(WidgetTester tester) async {
    if (find.byKey(const Key('act0_shell_selected_lesson_panel')).evaluate().isNotEmpty) {
      return;
    }
    final lessonCards = findLessonCardsV1();
    if (lessonCards.evaluate().isEmpty) {
      throw StateError('Missing visible target for learn lesson card');
    }
    await tapVisibleTargetV1(tester, lessonCards.first, 'learn lesson card');
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    if (find.byKey(const Key('act0_shell_selected_lesson_panel')).evaluate().isEmpty) {
      throw StateError(
        'Learn detail panel did not open after tapping learn lesson card.',
      );
    }
  }

  Future<void> captureBoundary(
    WidgetTester tester,
    Key boundaryKey,
    String fileName,
  ) async {
    await tester.pump(const Duration(milliseconds: 160));
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundaryKey),
    );
    final byteData = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    if (byteData == null) {
      throw StateError('Failed to capture screenshot for ' + fileName);
    }
    final file = File('\${outputDir.path}/' + fileName);
    file.writeAsBytesSync(Uint8List.view(byteData.buffer));
  }

  Future<void> validateTerminalSemanticEvidenceV1(
    WidgetTester tester,
  ) async {
    await tester.pumpAndSettle();
	    expect(find.textContaining('Volume I review'), findsWidgets);
	    expect(find.textContaining('later worlds stay locked'), findsWidgets);
    expect(find.textContaining('World 13'), findsNothing);
    expect(find.textContaining('W13'), findsNothing);
  }

  Future<void> validatePlaySemanticEvidenceV1(
    WidgetTester tester,
  ) async {
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key != null &&
            key.toString().contains(
              'act0_shell_runner_prompt_panel_compact_',
            );
      }),
      findsWidgets,
    );
    expect(
      find.byKey(const Key('act0_shell_runner_action_dock')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
  }

  Future<void> captureSurface(
    WidgetTester tester,
    String viewportName,
    Size size,
    String surfaceName,
    _BuildFlowV1 buildFlow,
    bool showPlacementOnStart,
    Act0ShellTabV1 initialTab,
    Act0ControlledDemoCaptureSurfaceV1? debugSurface,
    {
    String? worldId,
    String? lessonId,
    String? taskId,
  }
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final boundaryKey = Key('capture_' + viewportName + '_' + surfaceName);
    await pumpSized(
      tester,
      RepaintBoundary(
        key: boundaryKey,
        child: host(
          tab: initialTab,
          showPlacementOnStart: showPlacementOnStart,
          debugSurface: debugSurface,
          worldId: worldId,
          lessonId: lessonId,
          taskId: taskId,
        ),
      ),
      size,
    );
    try {
      await buildFlow();
    } on StateError catch (error) {
      throw StateError(surfaceName + ' surface failed: ' + error.message);
    }
    await captureBoundary(
      tester,
      boundaryKey,
      viewportName + '.' + surfaceName + '.png',
    );
  }

  testWidgets('capture Act0 product 100 proof surfaces', (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final entry in viewports.entries) {
      final viewportName = entry.key;
      final size = entry.value;

      await captureSurface(
        tester,
        viewportName,
        size,
        'placement',
        () async {},
        false,
        Act0ShellTabV1.home,
        Act0ControlledDemoCaptureSurfaceV1.placement,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'welcome',
        () async {},
        false,
        Act0ShellTabV1.home,
        Act0ControlledDemoCaptureSurfaceV1.welcome,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'home',
        () async {},
        false,
        Act0ShellTabV1.home,
        Act0ControlledDemoCaptureSurfaceV1.firstWeekHome,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'learn',
        () async {},
        false,
        Act0ShellTabV1.learn,
        Act0ControlledDemoCaptureSurfaceV1.firstWeekLearn,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'learn_detail',
        () async {
          await openLearnDetailIfNeededV1(tester);
        },
        false,
        Act0ShellTabV1.learn,
        null,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'play',
        () async {
          await validatePlaySemanticEvidenceV1(tester);
        },
        false,
        Act0ShellTabV1.play,
        Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
        worldId: 'world_1',
        lessonId: 'what_poker_is',
        taskId: 'what_poker_is_theory',
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'feedback',
        () async {},
        false,
        Act0ShellTabV1.play,
        Act0ControlledDemoCaptureSurfaceV1.runnerFirstWrongFeedback,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'practice_repair',
        () async {},
        false,
        Act0ShellTabV1.play,
        Act0ControlledDemoCaptureSurfaceV1.day2PracticeRepairTarget,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'completion_payoff',
        () async {},
        false,
        Act0ShellTabV1.play,
        Act0ControlledDemoCaptureSurfaceV1.worldCompletion,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'summary',
        () async {},
        false,
        Act0ShellTabV1.play,
        Act0ControlledDemoCaptureSurfaceV1.sessionSummary,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'review_profile',
        () async {},
        false,
        Act0ShellTabV1.profile,
        Act0ControlledDemoCaptureSurfaceV1.profileEvidence,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'w12_terminal',
        () async {
          await validateTerminalSemanticEvidenceV1(tester);
        },
        false,
        Act0ShellTabV1.play,
        Act0ControlledDemoCaptureSurfaceV1.w12Terminal,
      );
    }
  });
}
''';
}

void _printUsageV1() {
  stderr.writeln(
    'Usage: dart run tools/act0_product_100_proof_capture_v1.dart',
  );
}
