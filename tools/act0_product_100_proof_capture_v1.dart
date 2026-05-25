import 'dart:convert';
import 'dart:io';

const _outputDirPathV1 = 'output/device_audit/act0_product_100';

void main(List<String> args) async {
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

  final result = await Process.start(
    'flutter',
    <String>['test', testFile.path],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  stdout.addStream(result.stdout);
  stderr.addStream(result.stderr);
  final exitCode = await result.exitCode;

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

  const viewports = <String>['compact_phone', 'large_phone', 'tablet'];
  const surfaces = <String>[
    'placement',
    'home',
    'learn',
    'learn_detail',
    'play',
    'review',
    'profile',
    'table',
    'result',
  ];
  final entries = <Map<String, Object?>>[];
  for (final viewport in viewports) {
    for (final surface in surfaces) {
      final file = File(
        '${outputDir.path}${Platform.pathSeparator}$viewport.$surface.png',
      );
      if (!file.existsSync()) {
        throw StateError('Missing screenshot artifact `${file.path}`.');
      }
      entries.add(<String, Object?>{
        'viewport': viewport,
        'surface': surface,
        'path': file.path.replaceAll(
          '${Directory.current.path}${Platform.pathSeparator}',
          '',
        ),
        'bytes': file.lengthSync(),
      });
    }
  }

  final manifestFile = File(
    '${outputDir.path}${Platform.pathSeparator}manifest.json',
  );
  manifestFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'artifact_dir': outputDir.path.replaceAll('${Directory.current.path}${Platform.pathSeparator}', ''), 'lane_type': 'preview_contract', 'render_kind': 'nonliteral_preview_contract', 'viewports': viewports, 'surfaces': surfaces, 'entries': entries})}\n',
  );
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

  Future<void> openBottomTabByIndexV1(WidgetTester tester, int index) async {
    final nav = find.byKey(const Key('act0_shell_bottom_nav'));
    if (nav.evaluate().isEmpty) {
      throw StateError('Missing bottom nav.');
    }
    final rect = tester.getRect(nav);
    final itemWidth = rect.width / 5;
    final target = Offset(
      rect.left + (itemWidth * index) + (itemWidth / 2),
      rect.top + (rect.height / 2),
    );
    await tester.tapAt(target);
    await tester.pumpAndSettle();
  }

  Future<void> startPlacementIfNeeded(WidgetTester tester) async {
    final introCta = find.byKey(const Key('act0_shell_placement_intro_cta'));
    if (introCta.evaluate().isNotEmpty) {
      await tester.tap(introCta);
      await tester.pumpAndSettle();
    }
  }

  Future<void> answerPlacementQuestion(
    WidgetTester tester,
    String optionId,
  ) async {
    await startPlacementIfNeeded(tester);
    await tester.tap(find.byKey(Key('act0_shell_placement_option_' + optionId)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_placement_next_cta')));
    await tester.pumpAndSettle();
  }

  Future<void> advanceTeachingToDrill(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      if (find.byKey(const Key('act0_shell_action_panel')).evaluate().isNotEmpty ||
          find.byKey(const Key('act0_shell_option_raise')).evaluate().isNotEmpty ||
          find.byKey(const Key('act0_shell_option_check')).evaluate().isNotEmpty ||
          find.byKey(const Key('act0_shell_option_call')).evaluate().isNotEmpty ||
          find.byKey(const Key('act0_shell_option_fold')).evaluate().isNotEmpty ||
          find.byKey(const Key('act0_shell_seat_tap_prompt')).evaluate().isNotEmpty) {
        return;
      }
      final cta = find.byKey(const Key('act0_shell_continue_cta'));
      if (cta.evaluate().isEmpty) {
        throw StateError('Teaching steps did not reveal a drill surface.');
      }
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(cta);
      await tester.pumpAndSettle();
    }
    throw StateError('Teaching steps did not reveal a drill surface.');
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
      throw StateError('Missing learn lesson cards.');
    }
    await tester.ensureVisible(lessonCards.first);
    await tester.tap(lessonCards.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    if (find.byKey(const Key('act0_shell_selected_lesson_panel')).evaluate().isEmpty) {
      throw StateError('Learn detail panel did not open.');
    }
  }

  Future<void> openPracticeRunV1(WidgetTester tester) async {
    final featuredCta = find.byKey(const Key('act0_shell_play_featured_cta'));
    if (featuredCta.evaluate().isNotEmpty) {
      await tester.ensureVisible(featuredCta);
      await tester.tap(featuredCta);
      await tester.pumpAndSettle();
      return;
    }

    const fallbackKeys = <Key>[
      Key('act0_shell_practice_group_daily'),
      Key('act0_shell_practice_group_continue'),
      Key('act0_shell_practice_group_weak_spots'),
    ];
    for (final key in fallbackKeys) {
      final finder = find.byKey(key);
      if (finder.evaluate().isNotEmpty) {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
        return;
      }
    }
    throw StateError('Missing practice launch entry.');
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

  Future<void> captureSurface(
    WidgetTester tester,
    String viewportName,
    Size size,
    String surfaceName,
    _BuildFlowV1 buildFlow,
    bool showPlacementOnStart,
    Act0ShellTabV1 initialTab,
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
        ),
      ),
      size,
    );
    await buildFlow();
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
        true,
        Act0ShellTabV1.home,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'home',
        () async {},
        false,
        Act0ShellTabV1.home,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'learn',
        () async {},
        false,
        Act0ShellTabV1.learn,
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
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'play',
        () async {
          await openBottomTabByIndexV1(tester, 2);
        },
        false,
        Act0ShellTabV1.home,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'review',
        () async {},
        false,
        Act0ShellTabV1.review,
      );

      await captureSurface(
        tester,
        viewportName,
        size,
        'profile',
        () async {},
        false,
        Act0ShellTabV1.profile,
      );

      await captureSurface(tester, viewportName, size, 'table', () async {
        await openBottomTabByIndexV1(tester, 2);
        await openPracticeRunV1(tester);
        await advanceTeachingToDrill(tester);
      }, false, Act0ShellTabV1.home);

      await captureSurface(tester, viewportName, size, 'result', () async {
        await openBottomTabByIndexV1(tester, 2);
        await openPracticeRunV1(tester);
        await advanceTeachingToDrill(tester);

        const optionKeys = <Key>[
          Key('act0_shell_option_check'),
          Key('act0_shell_option_fold'),
          Key('act0_shell_option_call'),
          Key('act0_shell_option_raise'),
        ];
        var tapped = false;
        for (final optionKey in optionKeys) {
          final finder = find.byKey(optionKey);
          if (finder.evaluate().isNotEmpty) {
            await tester.tap(finder);
            await tester.pumpAndSettle();
            tapped = true;
            break;
          }
        }
        if (!tapped) {
          final seatTap = find.byKey(const Key('act0_shell_seat_tap_btn'));
          if (seatTap.evaluate().isNotEmpty) {
            await tester.tap(seatTap);
            await tester.pumpAndSettle();
            tapped = true;
          }
        }
        if (!tapped) {
          throw StateError('No visible runner option to produce feedback.');
        }
      }, false, Act0ShellTabV1.home);
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
