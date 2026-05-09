import 'dart:io';

Future<void> main() async {
  // See docs/visual_ssot_v1.md for baseline usage.
  final tempDir = Directory.systemTemp.createTempSync(
    'modern_table_screenshot_',
  );
  final testFile = File('${tempDir.path}/modern_table_screenshot_test.dart');
  testFile.writeAsStringSync(_flutterTestSource());

  final result = await Process.start(
    'flutter',
    ['test', testFile.path],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  stdout.addStream(result.stdout);
  stderr.addStream(result.stderr);
  final exitCode = await result.exitCode;

  try {
    tempDir.deleteSync(recursive: true);
  } catch (_) {
    // Best-effort cleanup; ignore failures.
  }

  if (exitCode != 0) {
    throw ProcessException(
      'flutter',
      ['test', testFile.path],
      'Screenshot test failed. See output above.',
      exitCode,
    );
  }
}

String _flutterTestSource() {
  return r'''
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/screens/module_catalog_screen.dart';
import 'package:poker_analyzer/services/content_module_loader_service.dart';
import 'package:poker_analyzer/services/module_progress_service.dart';
import 'package:poker_analyzer/services/xp_service.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture modern table screenshots', (tester) async {
    const landscapeSize = Size(1200, 900);
    const portraitSize = Size(390, 844);
    const iphonePortraitSize = portraitSize;
    void setTestWindow(Size size) {
      tester.binding.window.physicalSizeTestValue = size;
      tester.binding.window.devicePixelRatioTestValue = 1.0;
    }
    Future<void> waitForAny(
      List<Finder> finders, {
      int ticks = 200,
      Duration step = const Duration(milliseconds: 16),
    }) async {
      for (var i = 0; i < ticks; i++) {
        if (finders.any((finder) => finder.evaluate().isNotEmpty)) {
          return;
        }
        await tester.pump(step);
      }
      throw StateError(
        'Timed out waiting for any of: '
        '${finders.map((finder) => finder.description).join(', ')}',
      );
    }
    Future<void> waitForWidget(
      Finder finder, {
      int ticks = 200,
      Duration step = const Duration(milliseconds: 16),
      String? label,
    }) async {
      for (var i = 0; i < ticks; i++) {
        if (finder.evaluate().isNotEmpty) {
          return;
        }
        await tester.pump(step);
      }
      throw StateError(
        'Timed out waiting for ${label ?? finder.description} '
        '(ticks=$ticks, stepMs=${step.inMilliseconds})',
      );
    }
    Rect largestRectFor(Finder finder) {
      final elements = finder.evaluate().toList(growable: false);
      expect(elements.isNotEmpty, isTrue);
      Rect? largest;
      var largestArea = -1.0;
      for (final element in elements) {
        final renderObject = element.renderObject;
        if (renderObject is! RenderBox) {
          continue;
        }
        final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
        final area = rect.width * rect.height;
        if (area > largestArea) {
          largestArea = area;
          largest = rect;
        }
      }
      expect(largest, isNotNull);
      return largest!;
    }
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    const assetPath = 'assets/scenarios/demo_hu.json';
    final richSpec = {
      'schema_version': 1,
      'seatCount': 6,
      'heroSeat': 0,
      'initialStacks': [1200, 0, 950, 1100, 0, 880],
      'actingSeatStart': 2,
      'decisionNodeV1': {
        'street': 'river',
        'legalActions': ['fold', 'call', 'raise'],
        'solutionBestAction': 'call',
      },
      'nodes': [
        {
          'id': 'n1',
          'street': 'river',
          'actingSeatIndex': 2,
          'pot': 240,
          'decisionNode': {
            'street': 'river',
            'legalActions': ['fold', 'call', 'raise'],
            'solutionBestAction': 'call',
          },
        },
      ],
    };
    final richSpecJson = const JsonEncoder().convert(richSpec);
    const debugBoardCardLabels = ['As', 'Kd', '7h', '2c', 'Tc'];
    final assetContent = richSpecJson;
    final theoryIndexAssetContent = () {
      final file = File('assets/theory_index.json');
      if (file.existsSync()) {
        return file.readAsStringSync();
      }
      return '[]';
    }();
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        if (message == null) {
          return null;
        }
        final key = utf8.decode(message.buffer.asUint8List());
        if (key == assetPath) {
          final bytes = Uint8List.fromList(utf8.encode(assetContent));
          return ByteData.view(bytes.buffer);
        }
        if (key == 'assets/theory_index.json') {
          final bytes = Uint8List.fromList(
            utf8.encode(theoryIndexAssetContent),
          );
          return ByteData.view(bytes.buffer);
        }
        return null;
      },
    );

    Future<void> captureCase({
      required String name,
      required Widget child,
      required String expectedLabel,
      required Size size,
    }) async {
      setTestWindow(size);
      await tester.pumpWidget(MaterialApp(home: child));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final bannerFinder = find.byKey(const Key('modern_table_debug_banner'));
      expect(bannerFinder, findsOneWidget);
      final textFinder = find.descendant(
        of: bannerFinder,
        matching: find.byType(Text),
      );
      final textWidget = tester.widget<Text>(textFinder.first);
      final bannerText = textWidget.data ?? '';
      expect(bannerText.contains('VISUAL_SSOT_V1'), isTrue);
      expect(bannerText.contains(expectedLabel), isTrue);

      final boundaryFinder = find.ancestor(
        of: find.byKey(const Key('modern_table_scene')),
        matching: find.byType(RepaintBoundary),
      );
      if (boundaryFinder.evaluate().isEmpty) {
        throw StateError('Missing RepaintBoundary for $name.');
      }
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        boundaryFinder.first,
      );
      final byteData = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);

      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/modern_table_$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureFullScreenCase({
      required String name,
      required Widget child,
      required Size size,
    }) async {
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(key: rootBoundaryKey, child: child),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));
      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureMapCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': false,
        'world5_calibration_completed_v1': false,
        'world6_calibration_completed_v1': false,
        'world7_calibration_completed_v1': false,
        'world8_calibration_completed_v1': false,
        'world9_calibration_completed_v1': false,
        'world10_calibration_completed_v1': false,
      });

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: rootBoundaryKey,
            child: const UiV2ProgressMapScreenV2(),
          ),
        ),
      );
      await tester.pump();

      final mapSection = find.byKey(const Key('world_campaign_section'));
      final mapLoading = find.byKey(const Key('map_loading_v1'));
      final mapFallback = find.byKey(const Key('map_render_fallback_v1'));
      for (var i = 0; i < 160; i++) {
        if (mapSection.evaluate().isNotEmpty ||
            mapLoading.evaluate().isNotEmpty ||
            mapFallback.evaluate().isNotEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 40));
      }
      expect(mapSection, findsOneWidget);

      final nextPackCta = find.byKey(const Key('world_campaign_next_pack_cta'));
      for (var i = 0; i < 120; i++) {
        if (nextPackCta.evaluate().isNotEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 40));
      }
      expect(nextPackCta, findsOneWidget);
      await tester.ensureVisible(nextPackCta);
      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureMapSingleSpineCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1',
      });

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: rootBoundaryKey,
            child: const UiV2ProgressMapScreenV2(),
          ),
        ),
      );
      await tester.pump();

      final mapShell = find.byKey(const Key('map_shell_v1'));
      final mapSection = find.byKey(const Key('world_campaign_section'));
      final nextPackCta = find.byKey(const Key('world_campaign_next_pack_cta'));
      for (var i = 0; i < 200; i++) {
        if (mapShell.evaluate().isNotEmpty &&
            mapSection.evaluate().isNotEmpty &&
            nextPackCta.evaluate().isNotEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(mapShell, findsOneWidget);
      expect(mapSection, findsOneWidget);
      expect(nextPackCta, findsOneWidget);
      expect(find.byKey(const Key('inline_pack_node_1_1')), findsOneWidget);
      expect(find.text('Cash'), findsNothing);
      expect(find.text('MTT'), findsNothing);
      await tester.ensureVisible(nextPackCta);
      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureMapWorldDetailSheetCase({
      required String name,
      required Size size,
      double? textScale,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final child = RepaintBoundary(
                key: rootBoundaryKey,
                child: const UiV2ProgressMapScreenV2(),
              );
              if (textScale == null) return child;
              final media = MediaQuery.maybeOf(context);
              if (media == null) return child;
              return MediaQuery(
                data: media.copyWith(textScaler: TextScaler.linear(textScale)),
                child: child,
              );
            },
          ),
        ),
      );
      await tester.pump();

      final mapShell = find.byKey(const Key('map_shell_v1'));
      final campaignSection = find.byKey(const Key('world_campaign_section'));
      final inlineNode = find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is! ValueKey<String>) return false;
        return key.value.startsWith('inline_pack_node_');
      });
      await waitForAny(<Finder>[mapShell, campaignSection], ticks: 220);
      expect(mapShell, findsOneWidget);
      expect(campaignSection, findsOneWidget);
      await waitForAny(<Finder>[inlineNode], ticks: 220);
      expect(inlineNode, findsWidgets);
      await tester.ensureVisible(inlineNode.first);
      await tester.tap(inlineNode.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 16));

      final nodePreviewOverlay = find.byKey(
        const Key('map_node_preview_overlay_v1'),
      );
      final nodePreviewPrimary = find.byKey(
        const Key('map_node_preview_primary_cta_v1'),
      );
      await waitForAny(<Finder>[nodePreviewOverlay, nodePreviewPrimary], ticks: 240);
      expect(nodePreviewOverlay, findsOneWidget);
      expect(nodePreviewPrimary, findsOneWidget);

      await tester.pump(const Duration(milliseconds: 120));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureMapReviewDueCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b0,world1_spine_followup_v1_b1',
        'review_queue_v1::world1_spine_followup_v1_b2':
            '[{"packId":"world1_spine_followup_v1_b2","stepIndex":2}]',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: rootBoundaryKey,
            child: const UiV2ProgressMapScreenV2(),
          ),
        ),
      );
      await tester.pump();

      final mapSection = find.byKey(const Key('world_campaign_section'));
      final nextPackCta = find.byKey(const Key('world_campaign_next_pack_cta'));
      final reviewStrip = find.byKey(const Key('map_review_queue_strip'));
      await waitForAny(<Finder>[mapSection, nextPackCta, reviewStrip], ticks: 260);
      expect(mapSection, findsOneWidget);
      expect(nextPackCta, findsOneWidget);
      expect(reviewStrip, findsOneWidget);
      expect(find.text('REVIEW MISSED'), findsWidgets);

      await tester.ensureVisible(nextPackCta);
      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureMapLevelsSheetCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1',
      });

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: rootBoundaryKey,
            child: const UiV2ProgressMapScreenV2(),
          ),
        ),
      );
      await tester.pump();

      final levelsButton = find.byKey(const Key('map_levels_button_v1'));
      await waitForAny(<Finder>[levelsButton], ticks: 220);
      expect(levelsButton, findsOneWidget);
      await tester.tap(levelsButton, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 16));

      final levelsSheet = find.byKey(const Key('map_levels_sheet_v1'));
      final tile0 = find.byKey(const Key('map_levels_tile_0_v1'));
      final tile1 = find.byKey(const Key('map_levels_tile_1_v1'));
      await waitForAny(<Finder>[levelsSheet, tile0, tile1], ticks: 220);
      expect(levelsSheet, findsOneWidget);
      expect(tile0, findsOneWidget);
      expect(tile1, findsOneWidget);

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureModuleCatalogGemsProofCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final contentLoader = ContentModuleLoaderService();
      final moduleProgressService = ModuleProgressService();
      final xpService = XpService();
      await moduleProgressService.initialize();
      contentLoader.setProgressService(moduleProgressService);
      await contentLoader.initialize();

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ContentModuleLoaderService>.value(value: contentLoader),
            Provider<ModuleProgressService>.value(value: moduleProgressService),
            Provider<XpService>.value(value: xpService),
          ],
          child: MaterialApp(
            home: RepaintBoundary(
              key: rootBoundaryKey,
              child: ModuleCatalogScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      await waitForAny(<Finder>[
        find.text('Training Module Catalog'),
        find.byType(TextField),
      ], ticks: 260);
      expect(find.text('Training Module Catalog'), findsOneWidget);

      final loading = find.byType(CircularProgressIndicator);
      for (var i = 0; i < 240; i++) {
        if (loading.evaluate().isEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(loading, findsNothing);

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      Future<void> expectModuleTitleViaSearch({
        required String moduleIdQuery,
        required String title,
      }) async {
        await tester.enterText(searchField, moduleIdQuery);
        await tester.pump(const Duration(milliseconds: 340));
        await tester.pump(const Duration(milliseconds: 120));
        expect(find.text(title), findsOneWidget);
      }

      await expectModuleTitleViaSearch(
        moduleIdQuery: 'core_pot_odds_equity',
        title: 'Pot Odds & Equity',
      );
      await expectModuleTitleViaSearch(
        moduleIdQuery: 'core_bankroll_management',
        title: 'Bankroll Management',
      );
      await expectModuleTitleViaSearch(
        moduleIdQuery: 'core_board_textures',
        title: 'Board Texture',
      );

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureModuleCatalogPostflopProofCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final contentLoader = ContentModuleLoaderService();
      final moduleProgressService = ModuleProgressService();
      final xpService = XpService();
      await moduleProgressService.initialize();
      contentLoader.setProgressService(moduleProgressService);
      await contentLoader.initialize();

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ContentModuleLoaderService>.value(value: contentLoader),
            Provider<ModuleProgressService>.value(value: moduleProgressService),
            Provider<XpService>.value(value: xpService),
          ],
          child: MaterialApp(
            home: RepaintBoundary(
              key: rootBoundaryKey,
              child: ModuleCatalogScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      await waitForAny(<Finder>[
        find.text('Training Module Catalog'),
        find.byType(TextField),
      ], ticks: 260);
      expect(find.text('Training Module Catalog'), findsOneWidget);

      final loading = find.byType(CircularProgressIndicator);
      for (var i = 0; i < 240; i++) {
        if (loading.evaluate().isEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(loading, findsNothing);

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      Future<void> expectPostflopTitle({
        required String moduleIdQuery,
        required String title,
      }) async {
        await tester.enterText(searchField, moduleIdQuery);
        await tester.pump(const Duration(milliseconds: 340));
        await tester.pump(const Duration(milliseconds: 120));
        expect(find.text(title), findsOneWidget);
      }

      await expectPostflopTitle(
        moduleIdQuery: 'core_board_textures',
        title: 'Board Texture',
      );
      await expectPostflopTitle(
        moduleIdQuery: 'core_flop_fundamentals',
        title: 'Flop Fundamentals',
      );

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureModuleCatalogPostflop2ProofCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final contentLoader = ContentModuleLoaderService();
      final moduleProgressService = ModuleProgressService();
      final xpService = XpService();
      await moduleProgressService.initialize();
      contentLoader.setProgressService(moduleProgressService);
      await contentLoader.initialize();

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ContentModuleLoaderService>.value(value: contentLoader),
            Provider<ModuleProgressService>.value(value: moduleProgressService),
            Provider<XpService>.value(value: xpService),
          ],
          child: MaterialApp(
            home: RepaintBoundary(
              key: rootBoundaryKey,
              child: ModuleCatalogScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      await waitForAny(<Finder>[
        find.text('Training Module Catalog'),
        find.byType(TextField),
      ], ticks: 260);
      expect(find.text('Training Module Catalog'), findsOneWidget);

      final loading = find.byType(CircularProgressIndicator);
      for (var i = 0; i < 240; i++) {
        if (loading.evaluate().isEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(loading, findsNothing);

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      Future<void> expectPostflop2Title({
        required String moduleIdQuery,
        required String title,
      }) async {
        await tester.enterText(searchField, moduleIdQuery);
        await tester.pump(const Duration(milliseconds: 340));
        await tester.pump(const Duration(milliseconds: 120));
        expect(find.text(title), findsOneWidget);
      }

      await expectPostflop2Title(
        moduleIdQuery: 'core_equity_realization',
        title: 'Equity Realization',
      );
      await expectPostflop2Title(
        moduleIdQuery: 'core_flop_fundamentals',
        title: 'Flop Fundamentals',
      );

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureModuleCatalogPostflop3ProofCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final contentLoader = ContentModuleLoaderService();
      final moduleProgressService = ModuleProgressService();
      final xpService = XpService();
      await moduleProgressService.initialize();
      contentLoader.setProgressService(moduleProgressService);
      await contentLoader.initialize();

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ContentModuleLoaderService>.value(value: contentLoader),
            Provider<ModuleProgressService>.value(value: moduleProgressService),
            Provider<XpService>.value(value: xpService),
          ],
          child: MaterialApp(
            home: RepaintBoundary(
              key: rootBoundaryKey,
              child: ModuleCatalogScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      await waitForAny(<Finder>[
        find.text('Training Module Catalog'),
        find.byType(TextField),
      ], ticks: 260);
      expect(find.text('Training Module Catalog'), findsOneWidget);

      final loading = find.byType(CircularProgressIndicator);
      for (var i = 0; i < 240; i++) {
        if (loading.evaluate().isEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(loading, findsNothing);

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      Future<void> expectPostflop3Title({
        required String moduleIdQuery,
        required String title,
      }) async {
        await tester.enterText(searchField, moduleIdQuery);
        await tester.pump(const Duration(milliseconds: 340));
        await tester.pump(const Duration(milliseconds: 120));
        expect(find.text(title), findsOneWidget);
      }

      await expectPostflop3Title(
        moduleIdQuery: 'core_turn_fundamentals',
        title: 'Turn Fundamentals',
      );
      await expectPostflop3Title(
        moduleIdQuery: 'core_equity_realization',
        title: 'Equity Realization',
      );

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureModuleCatalogPostflop4ProofCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final contentLoader = ContentModuleLoaderService();
      final moduleProgressService = ModuleProgressService();
      final xpService = XpService();
      await moduleProgressService.initialize();
      contentLoader.setProgressService(moduleProgressService);
      await contentLoader.initialize();

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ContentModuleLoaderService>.value(value: contentLoader),
            Provider<ModuleProgressService>.value(value: moduleProgressService),
            Provider<XpService>.value(value: xpService),
          ],
          child: MaterialApp(
            home: RepaintBoundary(
              key: rootBoundaryKey,
              child: ModuleCatalogScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      await waitForAny(<Finder>[
        find.text('Training Module Catalog'),
        find.byType(TextField),
      ], ticks: 260);
      expect(find.text('Training Module Catalog'), findsOneWidget);

      final loading = find.byType(CircularProgressIndicator);
      for (var i = 0; i < 240; i++) {
        if (loading.evaluate().isEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(loading, findsNothing);

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      Future<void> expectPostflop4Title({
        required String moduleIdQuery,
        required String title,
      }) async {
        await tester.enterText(searchField, moduleIdQuery);
        await tester.pump(const Duration(milliseconds: 340));
        await tester.pump(const Duration(milliseconds: 120));
        expect(find.text(title), findsOneWidget);
      }

      await expectPostflop4Title(
        moduleIdQuery: 'core_river_fundamentals',
        title: 'River Fundamentals',
      );
      await expectPostflop4Title(
        moduleIdQuery: 'core_turn_fundamentals',
        title: 'Turn Fundamentals',
      );

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureModuleCatalogCoreParityProofCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final contentLoader = ContentModuleLoaderService();
      final moduleProgressService = ModuleProgressService();
      final xpService = XpService();
      await moduleProgressService.initialize();
      contentLoader.setProgressService(moduleProgressService);
      await contentLoader.initialize();

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ContentModuleLoaderService>.value(value: contentLoader),
            Provider<ModuleProgressService>.value(value: moduleProgressService),
            Provider<XpService>.value(value: xpService),
          ],
          child: MaterialApp(
            home: RepaintBoundary(
              key: rootBoundaryKey,
              child: ModuleCatalogScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await waitForAny(<Finder>[
        find.text('Training Module Catalog'),
        find.byType(TextField),
      ], ticks: 260);
      expect(find.text('Training Module Catalog'), findsOneWidget);
      final loading = find.byType(CircularProgressIndicator);
      for (var i = 0; i < 240; i++) {
        if (loading.evaluate().isEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(loading, findsNothing);

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      Future<void> expectCoreParityTitle({
        required String moduleIdQuery,
        required String title,
      }) async {
        await tester.enterText(searchField, moduleIdQuery);
        await tester.pump(const Duration(milliseconds: 340));
        await tester.pump(const Duration(milliseconds: 120));
        expect(find.text(title), findsOneWidget);
      }

      await expectCoreParityTitle(
        moduleIdQuery: 'core_positions_and_initiative',
        title: 'Core Positions And Initiative',
      );
      await expectCoreParityTitle(
        moduleIdQuery: 'core_starting_hands',
        title: 'Core Starting Hands',
      );

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureSessionResultCase({
      required String name,
      required Size size,
      double? textScale,
      int correctCount = 4,
      int totalCount = 5,
      String moduleId = 'world2_spine_campaign_v1',
      bool requireUpNext = false,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_spine_campaign_v1,world1_spine_followup_v1_b0',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'chips_balance_v1': 7,
        'chips_earned_total_v1': 14,
        'chips_spent_total_v1': 4,
      });

      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final child = RepaintBoundary(
                key: rootBoundaryKey,
                child: SessionResultScreen(
                  correctCount: correctCount,
                  totalCount: totalCount,
                  moduleId: moduleId,
                ),
              );
              if (textScale == null) return child;
              final media = MediaQuery.maybeOf(context);
              if (media == null) return child;
              return MediaQuery(
                data: media.copyWith(textScaler: TextScaler.linear(textScale)),
                child: child,
              );
            },
          ),
        ),
      );
      await tester.pump();

      final continueCta = find.byKey(const Key('session_result_next_module_cta'));
      final backToMapCta = find.byKey(const Key('session_result_back_to_map_cta'));
      final xpStrip = find.byKey(const Key('session_result_xp_summary_strip'));
      final upNext = find.byKey(const Key('session_result_up_next_v1'));
      for (var i = 0; i < 260; i++) {
        if (continueCta.evaluate().isNotEmpty &&
            backToMapCta.evaluate().isNotEmpty &&
            xpStrip.evaluate().isNotEmpty &&
            (!requireUpNext || upNext.evaluate().isNotEmpty)) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(continueCta, findsOneWidget);
      expect(backToMapCta, findsOneWidget);
      expect(xpStrip, findsOneWidget);
      if (requireUpNext) {
        expect(upNext, findsOneWidget);
      }

      await tester.pump(const Duration(milliseconds: 120));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerPortraitFullWidthCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: rootBoundaryKey,
              child: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();
      final tableFinder = find.byKey(const Key('microtask_table_canvas'));
      final clusterFinder = find.byKey(const Key('microtask_table_center_cluster'));
      for (var i = 0; i < 160; i++) {
        if (tableFinder.evaluate().isNotEmpty && clusterFinder.evaluate().isNotEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tableFinder, findsOneWidget);
      expect(clusterFinder, findsOneWidget);
      final tableRect = tester.getRect(tableFinder);
      final clusterRect = tester.getRect(clusterFinder);
      final widthRatio = clusterRect.width / tableRect.width;
      expect(
        widthRatio >= 0.92,
        isTrue,
        reason:
            'runner full-width ratio too small: ${widthRatio.toStringAsFixed(3)} '
            '(cluster=${clusterRect.width.toStringAsFixed(1)}, table=${tableRect.width.toStringAsFixed(1)})',
      );
      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureTheoryRunnerInstructionOverrideCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: rootBoundaryKey,
            child: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'season1_demo_multistreet_v1',
              moduleTitle: 'Streets Demo',
              mode: kWorld1RunnerModeDemoHandLoopV1,
              instructionSourceV1: _HarnessTheoryInstructionSourceV1(),
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final coachStrip = find.byKey(const Key('microtask_coach_strip_v1'));
      final feltPrompt = find.byKey(const Key('microtask_demo_prompt_box_v1'));
      final promptText = find.byKey(const Key('microtask_step_prompt'));
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      final heroCards = find.byKey(const Key('microtask_engine_hero_hole_cards'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final seatSb = find.byKey(const Key('microtask_seat_sb'));
      final seatBtn = find.byKey(const Key('microtask_seat_btn'));
      await waitForAny(
        <Finder>[runnerRoot, coachStrip, feltPrompt, promptText, checkCta, actionBar],
        ticks: 280,
      );
      expect(runnerRoot, findsOneWidget);
      for (var i = 0; i < 120; i++) {
        final ready =
            actionBar.evaluate().isNotEmpty &&
            boardStrip.evaluate().isNotEmpty &&
            heroCards.evaluate().isNotEmpty;
        if (ready) {
          break;
        }
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 120));
          continue;
        }
        if (checkCta.evaluate().isNotEmpty) {
          if (seatSb.evaluate().isNotEmpty) {
            await tester.tap(seatSb, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 16));
          } else if (seatBtn.evaluate().isNotEmpty) {
            await tester.tap(seatBtn, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 16));
          }
          await tester.tap(checkCta, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 120));
          continue;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      await waitForAny(
        <Finder>[coachStrip, feltPrompt, promptText, actionBar, boardStrip, heroCards],
        ticks: 160,
      );
      expect(
        coachStrip.evaluate().isNotEmpty ||
            feltPrompt.evaluate().isNotEmpty ||
            promptText.evaluate().isNotEmpty,
        isTrue,
      );
      expect(actionBar, findsOneWidget);
      expect(boardStrip, findsOneWidget);
      expect(heroCards, findsOneWidget);
      expect(
        coachStrip.evaluate().isNotEmpty ||
            feltPrompt.evaluate().isNotEmpty ||
            promptText.evaluate().isNotEmpty,
        isTrue,
      );

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureTheoryRunnerInstructionE2ECase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      debugHasWorld1MicroTaskPackOverride = (_) => true;
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TheorySessionScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              debugTheoryMarkdownOverrideV1:
                  '# Title\\nE2E_INTRO_MARK_V1\\n## Practice\\n- Step: E2E_STEP_MARK_V1\\n## Feedback\\n- feedback: E2E_OUTCOME_MARK_V1\\n',
            ),
          ),
        ),
      );
      await tester.pump();

      final theoryStartCta = find.byKey(const Key('theory_start_practice_cta'));
      await waitForAny(<Finder>[theoryStartCta], ticks: 240);
      expect(theoryStartCta, findsOneWidget);
      await tester.tap(theoryStartCta, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 16));

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final tablePracticeRunnerRoot = find.byKey(
        const Key('table_practice_runner'),
      );
      final coachStrip = find.byKey(const Key('microtask_coach_strip_v1'));
      final preludeContinue = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      final introContinue = find.byKey(
        const Key('microtask_intro_continue_cta_v1'),
      );
      await waitForAny(
        <Finder>[
          runnerRoot,
          tablePracticeRunnerRoot,
          coachStrip,
          preludeContinue,
          introContinue,
        ],
        ticks: 320,
      );
      expect(
        runnerRoot.evaluate().isNotEmpty ||
            tablePracticeRunnerRoot.evaluate().isNotEmpty,
        isTrue,
      );
      expect(coachStrip, findsOneWidget);
      expect(find.textContaining('E2E_INTRO_MARK_V1'), findsOneWidget);

      await tester.pump();
      Finder rootBoundaryFinder = find.byKey(rootBoundaryKey);
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final matches = rootBoundaryFinder.evaluate().toList(growable: false);
        if (matches.length == 1) {
          final ro = matches.single.renderObject;
          if (ro is RenderRepaintBoundary) {
            break;
          }
        }
      }
      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        rootBoundaryFinder,
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
      debugHasWorld1MicroTaskPackOverride = null;
    }

    Future<void> captureRunnerIntroPreludeCoachCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      debugHasWorld1MicroTaskPackOverride = (_) => true;
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TheorySessionScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              debugTheoryMarkdownOverrideV1:
                  '# Title\\nINTRO_PRELUDE_MARK_V1\\n## Practice\\n- Step: INTRO_PRACTICE_MARK_V1\\n## Feedback\\n- feedback: INTRO_OUTCOME_MARK_V1\\n',
            ),
          ),
        ),
      );
      await tester.pump();

      final theoryStartCta = find.byKey(const Key('theory_start_practice_cta'));
      await waitForAny(<Finder>[theoryStartCta], ticks: 240);
      expect(theoryStartCta, findsOneWidget);
      await tester.tap(theoryStartCta, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 16));

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final tablePracticeRunnerRoot = find.byKey(
        const Key('table_practice_runner'),
      );
      final coachStrip = find.byKey(const Key('microtask_coach_strip_v1'));
      final introSequence = find.byKey(const Key('microtask_intro_sequence_v1'));
      final preludeSurface = find.byKey(const Key('microtask_prelude_v1'));
      final preludeContinue = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      final introContinue = find.byKey(
        const Key('microtask_intro_continue_cta_v1'),
      );
      await waitForAny(
        <Finder>[
          runnerRoot,
          tablePracticeRunnerRoot,
          coachStrip,
          preludeSurface,
          preludeContinue,
          introSequence,
          introContinue,
        ],
        ticks: 320,
      );
      expect(
        runnerRoot.evaluate().isNotEmpty ||
            tablePracticeRunnerRoot.evaluate().isNotEmpty,
        isTrue,
      );
      expect(
        coachStrip.evaluate().isNotEmpty ||
            introSequence.evaluate().isNotEmpty ||
            preludeSurface.evaluate().isNotEmpty ||
            introContinue.evaluate().isNotEmpty,
        isTrue,
      );
      expect(find.textContaining('INTRO_PRELUDE_MARK_V1'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
      debugHasWorld1MicroTaskPackOverride = null;
    }

    Future<void> captureRunnerVerticalFinalCase({
      required String name,
      required Size size,
      String moduleId = 'world1_spine_campaign_v1',
      String moduleTitle = 'World 1',
      String mode = kWorld1RunnerModeCampaignSpine,
      int? debugSeatLayoutMaxPlayersV1,
      RunnerDebugBootstrapStateV1? debugBootstrapStateV1,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
        'spine_calibration_completed_v1': false,
        'spine_calibration_band_v1': 0,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: World1FoundationsMicroTaskRunnerScreen(
              moduleId: moduleId,
              moduleTitle: moduleTitle,
              mode: mode,
              debugSeatLayoutMaxPlayersV1: debugSeatLayoutMaxPlayersV1,
              debugBootstrapStateV1: debugBootstrapStateV1,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      await waitForAny(<Finder>[runnerRoot], ticks: 260);
      expect(runnerRoot, findsOneWidget);

      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      final heroCards = find.byKey(const Key('microtask_engine_hero_hole_cards'));
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final tableCanvas = find.byKey(const Key('microtask_table_canvas'));
      Future<void> progressRunnerUntilHandLoopVisuals({int steps = 12}) async {
        for (var i = 0; i < steps; i++) {
          if (boardStrip.evaluate().isNotEmpty &&
              heroCards.evaluate().isNotEmpty &&
              actionBar.evaluate().isNotEmpty) {
            return;
          }
          final checkCta = find.byKey(const Key('microtask_check_cta'));
          final seatSb = find.byKey(const Key('microtask_seat_sb'));
          final seatBtn = find.byKey(const Key('microtask_seat_btn'));
          if (checkCta.evaluate().isNotEmpty &&
              (seatSb.evaluate().isNotEmpty || seatBtn.evaluate().isNotEmpty)) {
            await tester.tap(
              seatSb.evaluate().isNotEmpty ? seatSb : seatBtn,
              warnIfMissed: false,
            );
            await tester.pump(const Duration(milliseconds: 16));
            await tester.tap(checkCta, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 160));
          }
          final continueCta = find.byKey(const Key('microtask_continue_cta'));
          if (continueCta.evaluate().isNotEmpty) {
            await tester.tap(continueCta, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 180));
          }
          await tester.pump(const Duration(milliseconds: 16));
        }
      }
      await waitForAny(<Finder>[tableCanvas, runnerRoot], ticks: 260);
      await progressRunnerUntilHandLoopVisuals();
      await waitForAny(<Finder>[boardStrip, heroCards, actionBar], ticks: 160);
      expect(boardStrip, findsOneWidget);
      expect(heroCards, findsOneWidget);
      expect(actionBar, findsOneWidget);
      expect(tableCanvas, findsOneWidget);

      final canvasRect = largestRectFor(tableCanvas);
      final widthRatio = canvasRect.width / size.width;
      expect(
        widthRatio >= 0.92,
        isTrue,
        reason:
            'runner vertical final must keep table canvas near full portrait width '
            '(ratio=${widthRatio.toStringAsFixed(3)})',
      );
      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerReviewQueueCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'review_queue_v1::world1_spine_followup_v1_b1':
            '[{"packId":"world1_spine_followup_v1_b1","stepIndex":0},{"packId":"world1_spine_followup_v1_b1","stepIndex":3}]',
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_followup_v1_b1',
              moduleTitle: 'Review Missed',
              mode: kWorld1RunnerModeReviewQueue,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final feltCaption = find.byKey(
        const Key('microtask_felt_caption_container_v1'),
      );
      await waitForAny(<Finder>[runnerRoot, checkCta, feltCaption], ticks: 260);
      expect(runnerRoot, findsOneWidget);
      expect(checkCta, findsOneWidget);
      expect(feltCaption, findsOneWidget);
      final prompt = tester.widget<Text>(
        find.byKey(const Key('microtask_step_prompt')),
      );
      expect(prompt.data ?? '', isNot('Find Big Blind'));

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureDeviceEntryParityCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const UniversalIntakePlanScreen(),
          ),
        ),
      );
      await tester.pump();

      final openMapCta = find.byKey(const Key('today_plan_open_map_cta'));
      await waitForAny(<Finder>[openMapCta]);
      expect(openMapCta, findsOneWidget);
      await tester.tap(openMapCta, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 16));

      final mapShell = find.byKey(const Key('map_shell_v1'));
      final campaignSection = find.byKey(const Key('world_campaign_section'));
      await waitForAny(<Finder>[mapShell, campaignSection]);
      expect(mapShell, findsOneWidget);
      expect(campaignSection, findsOneWidget);

      final startNowCta = find.byKey(const Key('world_campaign_next_pack_cta'));
      await waitForAny(<Finder>[startNowCta]);
      expect(startNowCta, findsOneWidget);
      await tester.ensureVisible(startNowCta);
      await tester.tap(startNowCta, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 16));

      final worldDetailSheet = find.byKey(const Key('world_detail_sheet_v1'));
      final worldDetailPrimary = find.byKey(
        const Key('world_detail_primary_cta_v1'),
      );
      final lessonBuyInCard = find.byKey(const Key('lesson_buy_in_card_v1'));
      final lessonBuyInStart = find.byKey(const Key('lesson_buy_in_start_cta_v1'));
      final nodePreviewOverlay = find.byKey(
        const Key('map_node_preview_overlay_v1'),
      );
      final nodePreviewPrimary = find.byKey(
        const Key('map_node_preview_primary_cta_v1'),
      );
      final runnerRoot = find.byKey(const Key('microtask_runner'));
      await waitForAny(
        <Finder>[
          nodePreviewOverlay,
          nodePreviewPrimary,
          worldDetailSheet,
          worldDetailPrimary,
          lessonBuyInCard,
          lessonBuyInStart,
          runnerRoot,
        ],
      );
      if (nodePreviewPrimary.evaluate().isNotEmpty) {
        await tester.tap(nodePreviewPrimary, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 16));
        await waitForAny(
          <Finder>[worldDetailSheet, lessonBuyInCard, lessonBuyInStart, runnerRoot],
          ticks: 180,
        );
      }
      if (worldDetailSheet.evaluate().isEmpty &&
          nodePreviewOverlay.evaluate().isEmpty &&
          lessonBuyInCard.evaluate().isEmpty &&
          runnerRoot.evaluate().isEmpty) {
        final inlineNode = find.byKey(const Key('inline_pack_node_1_1'));
        await waitForAny(<Finder>[inlineNode, startNowCta], ticks: 120);
        if (inlineNode.evaluate().isNotEmpty) {
          await tester.ensureVisible(inlineNode);
          await tester.tap(inlineNode, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 16));
          await waitForAny(
            <Finder>[
              nodePreviewOverlay,
              nodePreviewPrimary,
              lessonBuyInCard,
              lessonBuyInStart,
              runnerRoot,
            ],
            ticks: 180,
          );
          if (nodePreviewPrimary.evaluate().isNotEmpty) {
            await tester.tap(nodePreviewPrimary, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 16));
            await waitForAny(
              <Finder>[worldDetailSheet, lessonBuyInCard, lessonBuyInStart, runnerRoot],
              ticks: 180,
            );
          }
        }
      }
      if (worldDetailPrimary.evaluate().isNotEmpty) {
        expect(worldDetailSheet, findsOneWidget);
      }

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());

      if (worldDetailPrimary.evaluate().isNotEmpty) {
        await tester.tap(worldDetailPrimary, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 16));
      } else if (lessonBuyInStart.evaluate().isNotEmpty) {
        await tester.tap(lessonBuyInStart, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 16));
      }
      final mapSectionAfterCta = find.byKey(const Key('world_campaign_section'));
      await waitForAny(<Finder>[runnerRoot, mapSectionAfterCta], ticks: 260);
      if (runnerRoot.evaluate().isEmpty) {
        final nextPackCta = find.byKey(const Key('world_campaign_next_pack_cta'));
        if (nextPackCta.evaluate().isNotEmpty) {
          await tester.ensureVisible(nextPackCta);
          await tester.tap(nextPackCta, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 16));
          await waitForAny(<Finder>[runnerRoot, mapSectionAfterCta], ticks: 260);
        }
      }
      if (runnerRoot.evaluate().isEmpty &&
          find.byType(UiV2ProgressMapScreenV2).evaluate().isNotEmpty) {
        final mapContext = tester.element(find.byType(UiV2ProgressMapScreenV2));
        Navigator.of(mapContext).push(
          MaterialPageRoute<void>(
            builder: (_) => const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      final runnerTable = find.byKey(const Key('microtask_table_canvas'));
      final runnerCluster = find.byKey(
        const Key('microtask_table_center_cluster'),
      );
      final runnerSeatQuizTable = find.byKey(const Key('microtask_table'));
      await waitForAny(
        <Finder>[runnerRoot, runnerTable, runnerSeatQuizTable],
        ticks: 260,
      );
      expect(runnerRoot, findsOneWidget);
      if (runnerTable.evaluate().isNotEmpty && runnerCluster.evaluate().isNotEmpty) {
        final tableRect = tester.getRect(runnerTable);
        final clusterRect = tester.getRect(runnerCluster);
        final ratio = clusterRect.width / tableRect.width;
        expect(
          ratio >= 0.92,
          isTrue,
          reason:
              'entry parity runner cluster must stay wide in portrait '
              '(ratio=${ratio.toStringAsFixed(3)})',
        );
      } else {
        expect(runnerSeatQuizTable, findsOneWidget);
        final seatQuizRect = tester.getRect(runnerSeatQuizTable);
        final ratio = seatQuizRect.width / size.width;
        expect(
          ratio >= 0.90,
          isTrue,
          reason:
              'entry parity seat-quiz table must stay wide in portrait '
              '(ratio=${ratio.toStringAsFixed(3)})',
        );
      }
    }

    Future<void> captureTodayPlanRunnerVerticalProofCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const UniversalIntakePlanScreen(),
          ),
        ),
      );
      await tester.pump();

      final openMapCta = find.byKey(const Key('today_plan_open_map_cta'));
      await waitForAny(<Finder>[openMapCta]);
      expect(openMapCta, findsOneWidget);
      await tester.tap(openMapCta, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 16));

      final mapShell = find.byKey(const Key('map_shell_v1'));
      final campaignSection = find.byKey(const Key('world_campaign_section'));
      await waitForAny(<Finder>[mapShell, campaignSection]);
      expect(mapShell, findsOneWidget);
      expect(campaignSection, findsOneWidget);

      final startNowCta = find.byKey(const Key('world_campaign_next_pack_cta'));
      await waitForAny(<Finder>[startNowCta]);
      expect(startNowCta, findsOneWidget);
      await tester.ensureVisible(startNowCta);
      await tester.tap(startNowCta, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 16));

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final worldDetailSheet = find.byKey(const Key('world_detail_sheet_v1'));
      final worldDetailPrimary = find.byKey(
        const Key('world_detail_primary_cta_v1'),
      );
      final lessonBuyInCard = find.byKey(const Key('lesson_buy_in_card_v1'));
      final lessonBuyInStart = find.byKey(const Key('lesson_buy_in_start_cta_v1'));
      final nodePreviewOverlay = find.byKey(
        const Key('map_node_preview_overlay_v1'),
      );
      final nodePreviewPrimary = find.byKey(
        const Key('map_node_preview_primary_cta_v1'),
      );
      await waitForAny(
        <Finder>[
          nodePreviewOverlay,
          nodePreviewPrimary,
          worldDetailSheet,
          worldDetailPrimary,
          lessonBuyInCard,
          lessonBuyInStart,
          runnerRoot,
        ],
        ticks: 120,
      );
      if (nodePreviewPrimary.evaluate().isNotEmpty) {
        await tester.tap(nodePreviewPrimary, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 16));
        await waitForAny(
          <Finder>[worldDetailSheet, worldDetailPrimary, lessonBuyInCard, lessonBuyInStart, runnerRoot],
          ticks: 120,
        );
      }
      if (worldDetailPrimary.evaluate().isNotEmpty) {
        expect(worldDetailSheet, findsOneWidget);
        await tester.tap(worldDetailPrimary, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 16));
      } else if (lessonBuyInStart.evaluate().isNotEmpty) {
        await tester.tap(lessonBuyInStart, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 16));
      }

      final nextPackCta = find.byKey(const Key('world_campaign_next_pack_cta'));
      await waitForAny(<Finder>[runnerRoot, nextPackCta], ticks: 260);
      if (runnerRoot.evaluate().isEmpty && nextPackCta.evaluate().isNotEmpty) {
        await tester.ensureVisible(nextPackCta);
        await tester.tap(nextPackCta, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 16));
        await waitForAny(<Finder>[runnerRoot, campaignSection], ticks: 260);
      }
      if (runnerRoot.evaluate().isEmpty &&
          find.byType(UiV2ProgressMapScreenV2).evaluate().isNotEmpty) {
        final mapContext = tester.element(find.byType(UiV2ProgressMapScreenV2));
        Navigator.of(mapContext).push(
          MaterialPageRoute<void>(
            builder: (_) => const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }

      final runnerTable = find.byKey(const Key('microtask_table_canvas'));
      await waitForAny(<Finder>[runnerRoot, runnerTable], ticks: 260);
      expect(runnerRoot, findsOneWidget);
      expect(runnerTable, findsOneWidget);
      final tableRect = tester.getRect(runnerTable);
      final widthRatio = tableRect.width / size.width;
      expect(
        widthRatio >= 0.92,
        isTrue,
        reason:
            'today plan runner table width ratio too small: ${widthRatio.toStringAsFixed(3)}',
      );

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureIntakeTableVerticalProofCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': false,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: const MaterialApp(home: UniversalIntakePlanScreen()),
        ),
      );
      await tester.pump();

      final intakeTable = find.byKey(const Key('intake_table'));
      await waitForAny(<Finder>[intakeTable], ticks: 220);
      expect(intakeTable, findsOneWidget);
      final tableRect = tester.getRect(intakeTable);
      final widthRatio = tableRect.width / size.width;
      expect(
        widthRatio >= 0.92,
        isTrue,
        reason:
            'intake table width ratio too small: ${widthRatio.toStringAsFixed(3)}',
      );

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerTableFirstIphoneCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Deterministic harness route: bypass Today router path so screenshot
            // capture is not affected by daily routing (gauntlet/leaks/practice).
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final tableCanvas = find.byKey(const Key('microtask_table_canvas'));
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final seatBtn = find.byKey(const Key('microtask_seat_btn'));
      await waitForWidget(
        runnerRoot,
        ticks: 280,
        label: 'microtask_runner (direct runner harness)',
      );
      await waitForAny(<Finder>[tableCanvas, seatBtn], ticks: 280);
      Future<void> progressRunnerUntilActionBar({int steps = 8}) async {
        for (var i = 0; i < steps; i++) {
          if (actionBar.evaluate().isNotEmpty) {
            return;
          }
          final checkCta = find.byKey(const Key('microtask_check_cta'));
          final seatSb = find.byKey(const Key('microtask_seat_sb'));
          final seatAny = find.byKey(const Key('microtask_seat_btn'));
          if (checkCta.evaluate().isNotEmpty &&
              (seatSb.evaluate().isNotEmpty || seatAny.evaluate().isNotEmpty)) {
            await tester.tap(
              seatSb.evaluate().isNotEmpty ? seatSb : seatAny,
              warnIfMissed: false,
            );
            await tester.pump(const Duration(milliseconds: 16));
            await tester.tap(checkCta, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 120));
          }
          final continueCta = find.byKey(const Key('microtask_continue_cta'));
          if (continueCta.evaluate().isNotEmpty) {
            await tester.tap(continueCta, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 140));
          }
          await tester.pump(const Duration(milliseconds: 16));
        }
      }
      await progressRunnerUntilActionBar();
      if (actionBar.evaluate().isEmpty && runnerRoot.evaluate().isNotEmpty) {
        final runnerContext = tester.element(runnerRoot);
        Navigator.of(runnerContext).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
        await waitForAny(<Finder>[runnerRoot, tableCanvas], ticks: 260);
        await progressRunnerUntilActionBar(steps: 10);
      }
      expect(runnerRoot.evaluate().isNotEmpty, isTrue);
      expect(tableCanvas.evaluate().isNotEmpty, isTrue);
      expect(actionBar.evaluate().isNotEmpty, isTrue);
      expect(seatBtn.evaluate().isNotEmpty, isTrue);

      final runnerRect = largestRectFor(runnerRoot);
      final canvasRect = largestRectFor(tableCanvas);
      final widthRatio = canvasRect.width / size.width;
      final heightRatio = canvasRect.height / size.height;
      final headerBlockHeight = (canvasRect.top - runnerRect.top).clamp(
        0.0,
        size.height,
      );
      final headerBlockHeightRatio = headerBlockHeight / size.height;
      debugPrint(
        'runner_table_first_iphone_v1 ratios '
        'width=${widthRatio.toStringAsFixed(3)} '
        'height=${heightRatio.toStringAsFixed(3)} '
        'header=${headerBlockHeightRatio.toStringAsFixed(3)}',
      );
      expect(
        widthRatio >= 0.92,
        isTrue,
        reason:
            'runner iPhone table width ratio too small: ${widthRatio.toStringAsFixed(3)}',
      );
      expect(
        heightRatio >= 0.52,
        isTrue,
        reason:
            'runner iPhone table height ratio too small: ${heightRatio.toStringAsFixed(3)}',
      );
      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerSpineStreetBoardCase({
      required String name,
      required Size size,
      required MicroTaskStreetV1 targetStreet,
      required int expectedVisibleBoardCards,
      bool requireCaptionAboveBoard = false,
      bool requirePotNoOverlap = false,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      final feltCaption = find.byKey(
        const Key('microtask_felt_caption_container_v1'),
      );
      final potValue = find.byKey(const Key('microtask_pot_value_v1'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final stepIndexTextFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );
      final stepTargetTextFinder = find.byKey(
        const Key('spine_contract_expected_target'),
        skipOffstage: false,
      );

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      final targetStepIndex = steps.indexWhere((s) => s.street == targetStreet);
      expect(targetStepIndex, greaterThanOrEqualTo(0));

      int currentStepIndex() {
        if (stepIndexTextFinder.evaluate().isEmpty) {
          return -1;
        }
        final value = tester.widget<Text>(stepIndexTextFinder.first).data ?? '';
        final match = RegExp(r'^i=(\d+)$').firstMatch(value.trim());
        return int.tryParse(match?.group(1) ?? '') ?? -1;
      }

      String currentTargetToken() {
        if (stepTargetTextFinder.evaluate().isEmpty) {
          return '';
        }
        final value = tester.widget<Text>(stepTargetTextFinder.first).data ?? '';
        final match = RegExp(r'^target=(.+)$').firstMatch(value.trim());
        return (match?.group(1) ?? '').trim();
      }

      Finder boardVisibleCardFinder() => find.descendant(
        of: boardStrip,
        matching: find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == 'PlayingCardWidget',
        ),
      );

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (checkCta.evaluate().isNotEmpty) {
          final token = currentTargetToken();
          if (token.isNotEmpty) {
            final contractTarget = find.byKey(
              Key('spine_contract_target_$token'),
              skipOffstage: false,
            );
            if (contractTarget.evaluate().isNotEmpty) {
              await tester.tap(contractTarget.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            }
          } else {
            final seatSb = find.byKey(const Key('microtask_seat_sb'));
            final seatBtn = find.byKey(const Key('microtask_seat_btn'));
            if (seatSb.evaluate().isNotEmpty) {
              await tester.tap(seatSb.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            } else if (seatBtn.evaluate().isNotEmpty) {
              await tester.tap(seatBtn.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            }
          }
          await tester.tap(checkCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 160));
          return;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }

      await waitForAny(<Finder>[runnerRoot], ticks: 320);
      expect(runnerRoot, findsOneWidget);

      for (var i = 0; i < 320; i++) {
        final index = currentStepIndex();
        final hasBoard = boardStrip.evaluate().isNotEmpty;
        final visibleCards = hasBoard ? boardVisibleCardFinder().evaluate().length : 0;
        if (index == targetStepIndex &&
            hasBoard &&
            visibleCards == expectedVisibleBoardCards &&
            checkCta.evaluate().isNotEmpty) {
          break;
        }
        await progressOneStep();
      }

      expect(
        currentStepIndex(),
        targetStepIndex,
        reason: 'Expected runner to settle on spine step $targetStepIndex for $targetStreet',
      );
      expect(boardStrip, findsOneWidget);
      expect(
        boardVisibleCardFinder(),
        findsNWidgets(expectedVisibleBoardCards),
        reason:
            'Expected $expectedVisibleBoardCards visible board cards for $targetStreet',
      );
      if (requireCaptionAboveBoard) {
        expect(feltCaption, findsOneWidget);
        final captionRect = tester.getRect(feltCaption);
        final boardRect = tester.getRect(boardStrip);
        expect(
          boardRect.top >= captionRect.bottom,
          isTrue,
          reason: 'Board strip must be below felt caption in action state',
        );
      }
      if (requirePotNoOverlap) {
        if (potValue.evaluate().isNotEmpty) {
          final boardRect = tester.getRect(boardStrip);
          final potRect = tester.getRect(potValue);
          expect(
            boardRect.overlaps(potRect),
            isFalse,
            reason: 'Board strip must not overlap pot value in spine flop proof',
          );
        }
      }

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerSpineBoardCountsCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
      final stepPrompt = find.byKey(const Key('microtask_step_prompt'));
      final stepIndexTextFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );
      final stepTargetTextFinder = find.byKey(
        const Key('spine_contract_expected_target'),
        skipOffstage: false,
      );

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      final preflopIndex = steps.indexWhere((step) => step.street == null);
      final flopIndex = steps.indexWhere(
        (step) => step.street == MicroTaskStreetV1.flop,
      );
      final riverIndex = steps.indexWhere(
        (step) => step.street == MicroTaskStreetV1.river,
      );
      expect(preflopIndex, greaterThanOrEqualTo(0));
      expect(flopIndex, greaterThanOrEqualTo(0));
      expect(riverIndex, greaterThanOrEqualTo(0));

      int currentStepIndex() {
        if (stepIndexTextFinder.evaluate().isEmpty) {
          return -1;
        }
        final value = tester.widget<Text>(stepIndexTextFinder.first).data ?? '';
        final match = RegExp(r'^i=(\d+)$').firstMatch(value.trim());
        return int.tryParse(match?.group(1) ?? '') ?? -1;
      }

      String currentTargetToken() {
        if (stepTargetTextFinder.evaluate().isEmpty) {
          return '';
        }
        final value = tester.widget<Text>(stepTargetTextFinder.first).data ?? '';
        final match = RegExp(r'^target=(.+)$').firstMatch(value.trim());
        return (match?.group(1) ?? '').trim();
      }

      Finder boardVisibleCardFinder() => find.descendant(
        of: boardStrip,
        matching: find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == 'PlayingCardWidget',
        ),
      );

      String currentPromptText() {
        for (final element in stepPrompt.evaluate()) {
          final widget = element.widget;
          if (widget is Text) {
            final text = (widget.data ?? '').trim();
            if (text.isNotEmpty) {
              return text;
            }
          }
        }
        return '';
      }

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (checkCta.evaluate().isNotEmpty && actionBar.evaluate().isNotEmpty) {
          final token = currentTargetToken();
          if (token.isNotEmpty) {
            final targetFinder = find.byKey(
              Key('spine_contract_target_$token'),
              skipOffstage: false,
            );
            if (targetFinder.evaluate().isNotEmpty) {
              await tester.tap(targetFinder.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            }
          }
          await tester.tap(checkCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 160));
          return;
        }
        await tester.pump(const Duration(milliseconds: 24));
      }

      Future<void> settleAtStep(int targetIndex) async {
        for (var i = 0; i < 420; i++) {
          if (currentStepIndex() == targetIndex &&
              actionBar.evaluate().isNotEmpty &&
              checkCta.evaluate().isNotEmpty &&
              outcomeSurface.evaluate().isEmpty) {
            return;
          }
          await progressOneStep();
        }
        fail('Failed to settle on target spine step index=$targetIndex');
      }

      await waitForAny(<Finder>[runnerRoot, boardStrip], ticks: 320);
      expect(runnerRoot, findsOneWidget);
      expect(boardStrip, findsOneWidget);

      await settleAtStep(preflopIndex);
      expect(
        boardVisibleCardFinder(),
        findsNothing,
        reason: 'Preflop must reveal 0 board cards',
      );

      await settleAtStep(flopIndex);
      expect(
        boardVisibleCardFinder(),
        findsNWidgets(3),
        reason: 'Flop must reveal 3 board cards',
      );
      expect(currentPromptText(), isNotEmpty);

      await settleAtStep(riverIndex);
      expect(
        boardVisibleCardFinder(),
        findsNWidgets(5),
        reason: 'River must reveal 5 board cards',
      );
      expect(currentPromptText(), isNotEmpty);

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerSpineActionLegalityCase({
      required String name,
      required Size size,
      required bool targetToCallZero,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final stepIndexTextFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );
      final stepTargetTextFinder = find.byKey(
        const Key('spine_contract_expected_target'),
        skipOffstage: false,
      );
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final feltCaption = find.byKey(
        const Key('microtask_felt_caption_container_v1'),
      );

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      final targetStepIndex = steps.indexWhere((s) {
        final toCall = s.toCall ?? -1;
        if (targetToCallZero) {
          return toCall == 0 && (s.allowedActions?.contains('check') ?? false);
        }
        return toCall > 0 && (s.allowedActions?.contains('call') ?? false);
      });
      expect(targetStepIndex, greaterThanOrEqualTo(0));
      final targetStep = steps[targetStepIndex];
      final targetHasRaise =
          (targetStep.allowedActions ?? const <String>[]).any(
            (action) => action.startsWith('raise'),
          );

      int currentStepIndex() {
        if (stepIndexTextFinder.evaluate().isEmpty) return -1;
        final value = tester.widget<Text>(stepIndexTextFinder.first).data ?? '';
        final match = RegExp(r'^i=(\d+)$').firstMatch(value.trim());
        return int.tryParse(match?.group(1) ?? '') ?? -1;
      }

      String currentTargetToken() {
        if (stepTargetTextFinder.evaluate().isEmpty) return '';
        final value = tester.widget<Text>(stepTargetTextFinder.first).data ?? '';
        final match = RegExp(r'^target=(.+)$').firstMatch(value.trim());
        return (match?.group(1) ?? '').trim();
      }

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (checkCta.evaluate().isNotEmpty) {
          final token = currentTargetToken();
          if (token.isNotEmpty) {
            final contractTarget = find.byKey(
              Key('spine_contract_target_$token'),
              skipOffstage: false,
            );
            if (contractTarget.evaluate().isNotEmpty) {
              await tester.tap(contractTarget.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            }
          } else {
            final seatSb = find.byKey(const Key('microtask_seat_sb'));
            final seatBtn = find.byKey(const Key('microtask_seat_btn'));
            if (seatSb.evaluate().isNotEmpty) {
              await tester.tap(seatSb.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            } else if (seatBtn.evaluate().isNotEmpty) {
              await tester.tap(seatBtn.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            }
          }
          await tester.tap(checkCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 160));
          return;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }

      await waitForAny(<Finder>[runnerRoot], ticks: 320);
      expect(runnerRoot, findsOneWidget);

      for (var i = 0; i < 320; i++) {
        if (currentStepIndex() == targetStepIndex &&
            actionBar.evaluate().isNotEmpty &&
            checkCta.evaluate().isNotEmpty) {
          break;
        }
        await progressOneStep();
      }

      expect(
        currentStepIndex(),
        targetStepIndex,
        reason:
            'Expected runner to settle on spine action step $targetStepIndex (toCallZero=$targetToCallZero)',
      );
      expect(actionBar, findsOneWidget);
      expect(
        feltCaption.evaluate().isNotEmpty || checkCta.evaluate().isNotEmpty,
        isTrue,
      );

      final foldLabel = find.descendant(of: actionBar, matching: find.text('FOLD'));
      final callLabel = find.descendant(of: actionBar, matching: find.text('CALL'));
      final checkLabel = find.descendant(of: actionBar, matching: find.text('CHECK'));
      final betLabels = find.descendant(
        of: actionBar,
        matching: find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.startsWith('BET'),
        ),
      );
      final raiseLabels = find.descendant(
        of: actionBar,
        matching: find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.startsWith('RAISE'),
        ),
      );

      if (targetToCallZero) {
        expect(checkLabel, findsOneWidget);
        expect(callLabel, findsNothing);
      } else {
        expect(callLabel, findsOneWidget);
        expect(foldLabel, findsOneWidget);
        expect(checkLabel, findsNothing);
      }

      if (targetHasRaise) {
        expect(raiseLabels.evaluate().isNotEmpty, isTrue);
      } else {
        expect(raiseLabels, findsNothing);
      }
      if (targetToCallZero) {
        expect(betLabels.evaluate().isNotEmpty || checkLabel.evaluate().isNotEmpty, isTrue);
      }

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerSpineActionVarietyCase({
      required String name,
      required Size size,
      required bool targetToCallZero,
      required String requiredAction,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final stepIndexTextFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );
      final stepTargetTextFinder = find.byKey(
        const Key('spine_contract_expected_target'),
        skipOffstage: false,
      );
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      final targetStepIndex = steps.indexWhere((step) {
        final toCall = step.toCall ?? -1;
        final matchesToCall = targetToCallZero ? toCall == 0 : toCall > 0;
        final actions = (step.allowedActions ?? const <String>[])
            .map((value) => value.trim().toLowerCase())
            .toSet();
        return matchesToCall && actions.contains(requiredAction);
      });
      expect(
        targetStepIndex,
        greaterThanOrEqualTo(0),
        reason:
            'Missing target step for action=$requiredAction toCallZero=$targetToCallZero',
      );

      int currentStepIndex() {
        if (stepIndexTextFinder.evaluate().isEmpty) return -1;
        final value = tester.widget<Text>(stepIndexTextFinder.first).data ?? '';
        final match = RegExp(r'^i=(\d+)$').firstMatch(value.trim());
        return int.tryParse(match?.group(1) ?? '') ?? -1;
      }

      String currentTargetToken() {
        if (stepTargetTextFinder.evaluate().isEmpty) return '';
        final value = tester.widget<Text>(stepTargetTextFinder.first).data ?? '';
        final match = RegExp(r'^target=(.+)$').firstMatch(value.trim());
        return (match?.group(1) ?? '').trim();
      }

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (checkCta.evaluate().isNotEmpty) {
          final token = currentTargetToken();
          if (token.isNotEmpty) {
            final contractTarget = find.byKey(
              Key('spine_contract_target_$token'),
              skipOffstage: false,
            );
            if (contractTarget.evaluate().isNotEmpty) {
              await tester.tap(contractTarget.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            }
          } else {
            final seatSb = find.byKey(const Key('microtask_seat_sb'));
            final seatBtn = find.byKey(const Key('microtask_seat_btn'));
            if (seatSb.evaluate().isNotEmpty) {
              await tester.tap(seatSb.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            } else if (seatBtn.evaluate().isNotEmpty) {
              await tester.tap(seatBtn.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            }
          }
          await tester.tap(checkCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 160));
          return;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }

      await waitForAny(<Finder>[runnerRoot], ticks: 320);
      expect(runnerRoot, findsOneWidget);

      for (var i = 0; i < 320; i++) {
        if (currentStepIndex() == targetStepIndex &&
            actionBar.evaluate().isNotEmpty &&
            checkCta.evaluate().isNotEmpty) {
          break;
        }
        await progressOneStep();
      }

      expect(
        currentStepIndex(),
        targetStepIndex,
        reason:
            'Expected runner to settle on action-variety step $targetStepIndex (action=$requiredAction)',
      );
      expect(actionBar, findsOneWidget);

      final callLabel = find.descendant(of: actionBar, matching: find.text('CALL'));
      final checkLabel = find.descendant(of: actionBar, matching: find.text('CHECK'));
      final betLabels = find.descendant(
        of: actionBar,
        matching: find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.startsWith('BET'),
        ),
      );
      final raiseLabels = find.descendant(
        of: actionBar,
        matching: find.byWidgetPredicate(
          (widget) => widget is Text && widget.data != null && widget.data!.startsWith('RAISE'),
        ),
      );

      if (requiredAction == 'bet') {
        expect(betLabels.evaluate().isNotEmpty, isTrue);
        expect(callLabel, findsNothing);
      } else if (requiredAction == 'raise_to') {
        expect(raiseLabels.evaluate().isNotEmpty, isTrue);
        expect(checkLabel, findsNothing);
      } else {
        fail('Unsupported requiredAction=$requiredAction');
      }

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerWorld1FollowupBoardActionsCase({
      required String name,
      required Size size,
    }) async {
      const followupPackIds = <String>[
        'world1_spine_followup_v1_b0',
        'world1_spine_followup_v1_b1',
        'world1_spine_followup_v1_b2',
      ];

      String? targetPackId;
      List<MicroTaskStep> targetSteps = const <MicroTaskStep>[];
      int targetFlopStepIndex = -1;
      int targetToCallGt0StepIndex = -1;

      for (final packId in followupPackIds) {
        final pack = kCampaignPacksV1[packId];
        if (pack == null) {
          continue;
        }
        final steps = pack12(pack);
        final flopIndex = steps.indexWhere((step) {
          final actions = (step.allowedActions ?? const <String>[])
              .map((value) => value.trim().toLowerCase())
              .toSet();
          return step.street == MicroTaskStreetV1.flop && actions.isNotEmpty;
        });
        var toCallGt0Index = -1;
        if (flopIndex >= 0) {
          for (var i = flopIndex; i < steps.length; i++) {
            final step = steps[i];
            final toCall = step.toCall ?? -1;
            final actions = (step.allowedActions ?? const <String>[])
                .map((value) => value.trim().toLowerCase())
                .toSet();
            if (toCall > 0 &&
                actions.contains('call') &&
                actions.contains('fold') &&
                !actions.contains('check')) {
              toCallGt0Index = i;
              break;
            }
          }
        }
        if (flopIndex >= 0 && toCallGt0Index >= 0) {
          targetPackId = packId;
          targetSteps = steps;
          targetFlopStepIndex = flopIndex;
          targetToCallGt0StepIndex = toCallGt0Index;
          break;
        }
      }

      expect(targetPackId, isNotNull, reason: 'Missing actionable followup pack');
      expect(targetFlopStepIndex, greaterThanOrEqualTo(0));
      expect(targetToCallGt0StepIndex, greaterThanOrEqualTo(0));

      var calibrationBand = 0;
      var completedPacks =
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1';
      if (targetPackId == 'world1_spine_followup_v1_b1') {
        calibrationBand = 1;
        completedPacks = '$completedPacks,world1_spine_followup_v1_b0';
      } else if (targetPackId == 'world1_spine_followup_v1_b2') {
        calibrationBand = 2;
        completedPacks =
            '$completedPacks,world1_spine_followup_v1_b0,world1_spine_followup_v1_b1';
      }

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': targetPackId!,
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': completedPacks,
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': calibrationBand,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: World1FoundationsMicroTaskRunnerScreen(
              moduleId: targetPackId!,
              moduleTitle: 'World 1 Followup',
              mode: kWorld1RunnerModeDemoHandLoopV1,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      final stepPrompt = find.byKey(const Key('microtask_step_prompt'));
      final stepTargetTextFinder = find.byKey(
        const Key('spine_contract_expected_target'),
        skipOffstage: false,
      );
      final stepByPrompt = <String, MicroTaskStep>{
        for (final step in targetSteps) step.prompt.trim(): step,
      };

      String currentTargetToken() {
        if (stepTargetTextFinder.evaluate().isEmpty) return '';
        final value = tester.widget<Text>(stepTargetTextFinder.first).data ?? '';
        final match = RegExp(r'^target=(.+)$').firstMatch(value.trim());
        return (match?.group(1) ?? '').trim();
      }

      Finder boardVisibleCardFinder() => find.descendant(
        of: boardStrip,
        matching: find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == 'PlayingCardWidget',
        ),
      );

      String currentPromptText() {
        for (final element in stepPrompt.evaluate()) {
          final widget = element.widget;
          if (widget is Text) {
            final text = (widget.data ?? '').trim();
            if (text.isNotEmpty) {
              return text;
            }
          }
        }
        return '';
      }

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (checkCta.evaluate().isNotEmpty) {
          var selectedAction = false;
          final prompt = currentPromptText();
          final step = stepByPrompt[prompt];
          final expectedAction = step?.expectedActionKind
              ?.trim()
              .toLowerCase()
              .replaceAll('-', '_');
          if (expectedAction != null && actionBar.evaluate().isNotEmpty) {
            Finder? expectedFinder;
            switch (expectedAction) {
              case 'fold':
                expectedFinder = find.descendant(
                  of: actionBar,
                  matching: find.text('FOLD'),
                );
                break;
              case 'call':
                expectedFinder = find.descendant(
                  of: actionBar,
                  matching: find.text('CALL'),
                );
                break;
              case 'check':
                expectedFinder = find.descendant(
                  of: actionBar,
                  matching: find.text('CHECK'),
                );
                break;
              case 'bet':
                expectedFinder = find.descendant(
                  of: actionBar,
                  matching: find.byWidgetPredicate(
                    (widget) =>
                        widget is Text &&
                        widget.data != null &&
                        widget.data!.startsWith('BET'),
                  ),
                );
                break;
              case 'raise':
              case 'raise_to':
              case 'raise_min':
                expectedFinder = find.descendant(
                  of: actionBar,
                  matching: find.byWidgetPredicate(
                    (widget) =>
                        widget is Text &&
                        widget.data != null &&
                        widget.data!.startsWith('RAISE'),
                  ),
                );
                break;
            }
            if (expectedFinder != null && expectedFinder.evaluate().isNotEmpty) {
              await tester.tap(expectedFinder.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
              selectedAction = true;
            }
          }
          final token = currentTargetToken();
          if (!selectedAction && token.isNotEmpty) {
            final contractTarget = find.byKey(
              Key('spine_contract_target_$token'),
              skipOffstage: false,
            );
            if (contractTarget.evaluate().isNotEmpty) {
              await tester.tap(contractTarget.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
              selectedAction = true;
            }
          }
          if (!selectedAction && actionBar.evaluate().isNotEmpty) {
            Finder? fallbackAction;
            final callAction = find.descendant(
              of: actionBar,
              matching: find.text('CALL'),
            );
            final checkAction = find.descendant(
              of: actionBar,
              matching: find.text('CHECK'),
            );
            final foldAction = find.descendant(
              of: actionBar,
              matching: find.text('FOLD'),
            );
            if (callAction.evaluate().isNotEmpty) {
              fallbackAction = callAction;
            } else if (checkAction.evaluate().isNotEmpty) {
              fallbackAction = checkAction;
            } else if (foldAction.evaluate().isNotEmpty) {
              fallbackAction = foldAction;
            }
            if (fallbackAction != null &&
                fallbackAction.evaluate().isNotEmpty) {
              await tester.tap(fallbackAction.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            }
          }
          await tester.tap(checkCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 160));
          return;
        }
        await tester.pump(const Duration(milliseconds: 24));
      }

      bool hasCallFoldNoCheck() {
        final callLabel = find.descendant(
          of: actionBar,
          matching: find.text('CALL'),
        );
        final foldLabel = find.descendant(
          of: actionBar,
          matching: find.text('FOLD'),
        );
        final checkLabel = find.descendant(
          of: actionBar,
          matching: find.text('CHECK'),
        );
        return callLabel.evaluate().isNotEmpty &&
            foldLabel.evaluate().isNotEmpty &&
            checkLabel.evaluate().isEmpty;
      }

      bool hasCheckNoCallFold() {
        final callLabel = find.descendant(
          of: actionBar,
          matching: find.text('CALL'),
        );
        final foldLabel = find.descendant(
          of: actionBar,
          matching: find.text('FOLD'),
        );
        final checkLabel = find.descendant(
          of: actionBar,
          matching: find.text('CHECK'),
        );
        return checkLabel.evaluate().isNotEmpty &&
            callLabel.evaluate().isEmpty &&
            foldLabel.evaluate().isEmpty;
      }

      Future<void> settleWhere({
        required bool Function() predicate,
        required String label,
      }) async {
        for (var i = 0; i < 420; i++) {
          if (predicate()) {
            return;
          }
          await progressOneStep();
        }
        fail('Failed to settle on followup state=$label pack=$targetPackId');
      }

      await waitForAny(<Finder>[runnerRoot], ticks: 320);
      expect(runnerRoot, findsOneWidget);

      final flopStep = targetSteps[targetFlopStepIndex];
      expect(
        flopStep.boardCards?.length ?? 0,
        3,
        reason: 'Followup flop step metadata must expose 3 board cards',
      );
      final flopActions = (flopStep.allowedActions ?? const <String>[])
          .map((value) => value.trim().toLowerCase())
          .toSet();
      if ((flopStep.toCall ?? -1) == 0) {
        expect(
          flopActions.contains('check') || flopActions.contains('bet'),
          isTrue,
          reason: 'Followup flop toCall==0 must include check or bet',
        );
        expect(flopActions.contains('call'), isFalse);
        expect(flopActions.contains('fold'), isFalse);
      } else {
        expect(flopActions.contains('call'), isTrue);
        expect(flopActions.contains('fold'), isTrue);
        expect(flopActions.contains('check'), isFalse);
      }

      final toCallGt0Step = targetSteps[targetToCallGt0StepIndex];
      final toCallGt0Actions = (toCallGt0Step.allowedActions ?? const <String>[])
          .map((value) => value.trim().toLowerCase())
          .toSet();
      expect(
        toCallGt0Step.toCall ?? -1,
        greaterThan(0),
        reason: 'Followup toCall>0 step metadata must have positive toCall',
      );
      expect(
        toCallGt0Actions.contains('call'),
        isTrue,
        reason: 'Followup toCall>0 step metadata must include CALL',
      );
      expect(
        toCallGt0Actions.contains('fold'),
        isTrue,
        reason: 'Followup toCall>0 step metadata must include FOLD',
      );
      expect(
        toCallGt0Actions.contains('check'),
        isFalse,
        reason: 'Followup toCall>0 step metadata must exclude CHECK',
      );

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerSpinePreflopPotBlindsCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final potValueFinder = find.byKey(
        const Key('microtask_pot_value_v1'),
        skipOffstage: false,
      );

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      final preflopSteps = <MicroTaskStep>[
        for (final step in steps)
          if (step.street == null && (step.boardCards?.isEmpty ?? true)) step,
      ];
      final bbCandidates = preflopSteps
          .where((step) => (step.heroSeatId ?? '').toUpperCase() != 'SB')
          .map((step) => step.toCall)
          .whereType<int>()
          .where((value) => value > 0)
          .toList(growable: false);
      expect(
        bbCandidates,
        isNotEmpty,
        reason: 'No positive non-SB preflop toCall for bb',
      );
      final bb = bbCandidates.reduce((a, b) => a < b ? a : b);
      expect(bb % 2, 0, reason: 'Expected integer sb from bb=$bb');
      final sb = bb ~/ 2;
      final expectedPot = sb + bb;
      final targetStepIndex = steps.indexWhere(
        (step) =>
            step.street == null &&
            (step.boardCards?.isEmpty ?? true) &&
            (step.toCall ?? -1) == bb,
      );
      expect(targetStepIndex, greaterThanOrEqualTo(0));
      expect(
        targetStepIndex,
        0,
        reason:
            'Expected first preflop step with toCall=bb to stay at index 0 for deterministic proof',
      );

      await waitForAny(<Finder>[runnerRoot], ticks: 320);
      expect(runnerRoot, findsOneWidget);
      await waitForAny(<Finder>[actionBar, potValueFinder, checkCta], ticks: 320);
      expect(actionBar, findsOneWidget);
      expect(potValueFinder, findsOneWidget);
      final potTextWidget = tester.widget<Text>(potValueFinder.first);
      final potText = (potTextWidget.data ?? '').trim();
      expect(
        potText,
        expectedPot.toString(),
        reason:
            'Expected pot text to equal SB+BB=$expectedPot on preflop step=$targetStepIndex (bb=$bb, sb=$sb)',
      );

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerSpinePotValueCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final potValueFinder = find.byKey(
        const Key('microtask_pot_value_v1'),
        skipOffstage: false,
      );
      final stepIndexFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );

      await waitForAny(<Finder>[runnerRoot], ticks: 320);
      expect(runnerRoot, findsOneWidget);
      await waitForAny(<Finder>[actionBar, potValueFinder, stepIndexFinder], ticks: 320);
      expect(actionBar, findsOneWidget);
      expect(potValueFinder, findsOneWidget);
      expect(stepIndexFinder, findsOneWidget);

      final stepIndexText =
          (tester.widget<Text>(stepIndexFinder.first).data ?? '').trim();
      final stepIndexMatch = RegExp(r'^i=(\d+)$').firstMatch(stepIndexText);
      final stepIndex = int.tryParse(stepIndexMatch?.group(1) ?? '');
      expect(stepIndex, isNotNull);

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      final expectedPot = steps[stepIndex!].pot;
      expect(expectedPot, isNotNull);

      final potText = (tester.widget<Text>(potValueFinder.first).data ?? '').trim();
      final parsedPot = int.tryParse(potText);
      expect(parsedPot, isNotNull, reason: 'Pot text must be parseable int');
      expect(
        parsedPot,
        expectedPot,
        reason:
            'Expected displayed pot=$parsedPot to match step[$stepIndex].pot=$expectedPot',
      );

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerSpineOutcomeFocusCase({
      required String name,
      required Size size,
      bool requireExpectedLine = false,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
              debugBootstrapStateV1:
                  RunnerDebugBootstrapStateV1.outcomeIncorrectRange,
            ),
          ),
        ),
      );
      await tester.pump();
      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));

      await waitForAny(<Finder>[outcomeSurface], ticks: 240);
      expect(outcomeSurface, findsOneWidget);
      expect(
        find.descendant(
          of: outcomeSurface,
          matching: find.textContaining('Focus:'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: outcomeSurface,
          matching: find.textContaining('Why:'),
        ),
        findsOneWidget,
      );
      if (requireExpectedLine) {
        expect(
          find.descendant(
            of: outcomeSurface,
            matching: find.textContaining('Expected:'),
          ),
          findsOneWidget,
        );
      }

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerSpineOutcomeCorrectCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final stepTargetTextFinder = find.byKey(
        const Key('spine_contract_expected_target'),
        skipOffstage: false,
      );
      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));

      String currentTargetToken() {
        if (stepTargetTextFinder.evaluate().isEmpty) return '';
        final value = tester.widget<Text>(stepTargetTextFinder.first).data ?? '';
        final match = RegExp(r'^target=(.+)$').firstMatch(value.trim());
        return (match?.group(1) ?? '').trim();
      }

      await waitForAny(<Finder>[runnerRoot], ticks: 240);
      expect(runnerRoot, findsOneWidget);

      for (var i = 0; i < 240; i++) {
        if (outcomeSurface.evaluate().isNotEmpty) {
          break;
        }
        if (checkCta.evaluate().isNotEmpty) {
          final token = currentTargetToken();
          if (token.isNotEmpty) {
            final target = find.byKey(
              Key('spine_contract_target_$token'),
              skipOffstage: false,
            );
            if (target.evaluate().isNotEmpty) {
              await tester.tap(target.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 24));
            }
          }
          await tester.tap(checkCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 160));
          continue;
        }
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          continue;
        }
        await tester.pump(const Duration(milliseconds: 24));
      }

      await waitForAny(<Finder>[outcomeSurface], ticks: 240);
      expect(outcomeSurface, findsOneWidget);
      expect(
        find.descendant(
          of: outcomeSurface,
          matching: find.textContaining('Correct:'),
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerSpinePromptVarietyCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      final flopIndex = steps.indexWhere((step) => step.street == MicroTaskStreetV1.flop);
      final riverIndex = steps.indexWhere((step) => step.street == MicroTaskStreetV1.river);
      expect(flopIndex, greaterThanOrEqualTo(0));
      expect(riverIndex, greaterThanOrEqualTo(0));
      expect(riverIndex > flopIndex, isTrue);

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
      final stepPrompt = find.byKey(const Key('microtask_step_prompt'));
      final stepIndexTextFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );

      int currentStepIndex() {
        if (stepIndexTextFinder.evaluate().isEmpty) return -1;
        final value = tester.widget<Text>(stepIndexTextFinder.first).data ?? '';
        final match = RegExp(r'^i=(\d+)$').firstMatch(value.trim());
        return int.tryParse(match?.group(1) ?? '') ?? -1;
      }

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (checkCta.evaluate().isNotEmpty && actionBar.evaluate().isNotEmpty) {
          final actionButtons = find.descendant(
            of: actionBar,
            matching: find.byType(OutlinedButton),
          );
          for (final buttonElement in actionButtons.evaluate()) {
            final button = buttonElement.widget as OutlinedButton;
            if (button.onPressed != null) {
              await tester.tap(find.byWidget(button), warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 140));
              return;
            }
          }
        }
        await tester.pump(const Duration(milliseconds: 30));
      }

      Future<void> settleAtStep(int targetIndex) async {
        for (var i = 0; i < 360; i++) {
          if (currentStepIndex() == targetIndex &&
              actionBar.evaluate().isNotEmpty &&
              checkCta.evaluate().isNotEmpty &&
              outcomeSurface.evaluate().isEmpty) {
            return;
          }
          await progressOneStep();
        }
        fail('Failed to settle on target spine step index=$targetIndex');
      }

      await waitForAny(<Finder>[runnerRoot], ticks: 320);
      expect(runnerRoot, findsOneWidget);
      await settleAtStep(flopIndex);
      expect(stepPrompt, findsOneWidget);
      final flopPrompt = (tester.widget<Text>(stepPrompt).data ?? '').trim();

      await settleAtStep(riverIndex);
      expect(stepPrompt, findsOneWidget);
      final riverPrompt = (tester.widget<Text>(stepPrompt).data ?? '').trim();

      expect(flopPrompt, isNotEmpty);
      expect(riverPrompt, isNotEmpty);
      expect(flopPrompt, isNot('Choose the best action for this spot.'));
      expect(riverPrompt, isNot('Choose the best action for this spot.'));
      expect(flopPrompt, isNot(equals(riverPrompt)));

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureRunnerSpineTaskLineCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      final flopIndex = steps.indexWhere((step) {
        return step.street == MicroTaskStreetV1.flop;
      });
      expect(flopIndex, greaterThanOrEqualTo(0));

      final runnerRoot = find.byKey(const Key('microtask_runner'));
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
      final stepPrompt = find.byKey(const Key('microtask_step_prompt'));
      final stepIndexTextFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );

      int currentStepIndex() {
        if (stepIndexTextFinder.evaluate().isEmpty) return -1;
        final value = tester.widget<Text>(stepIndexTextFinder.first).data ?? '';
        final match = RegExp(r'^i=(\d+)$').firstMatch(value.trim());
        return int.tryParse(match?.group(1) ?? '') ?? -1;
      }

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (checkCta.evaluate().isNotEmpty && actionBar.evaluate().isNotEmpty) {
          final actionButtons = find.descendant(
            of: actionBar,
            matching: find.byType(OutlinedButton),
          );
          for (final buttonElement in actionButtons.evaluate()) {
            final button = buttonElement.widget as OutlinedButton;
            if (button.onPressed != null) {
              await tester.tap(find.byWidget(button), warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 140));
              return;
            }
          }
        }
        await tester.pump(const Duration(milliseconds: 24));
      }

      Future<void> settleAtStep(int targetIndex) async {
        for (var i = 0; i < 360; i++) {
          if (currentStepIndex() == targetIndex &&
              actionBar.evaluate().isNotEmpty &&
              checkCta.evaluate().isNotEmpty &&
              outcomeSurface.evaluate().isEmpty) {
            return;
          }
          await progressOneStep();
        }
        fail('Failed to settle on target spine step index=$targetIndex');
      }

      await waitForAny(<Finder>[runnerRoot], ticks: 320);
      expect(runnerRoot, findsOneWidget);
      await settleAtStep(flopIndex);
      await waitForAny(<Finder>[stepPrompt], ticks: 220);
      expect(stepPrompt, findsWidgets);
      expect(find.textContaining('Task:', findRichText: true), findsWidgets);

      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureMapLadderIphoneCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const UniversalIntakePlanScreen(),
          ),
        ),
      );
      await tester.pump();

      final openMapCta = find.byKey(const Key('today_plan_open_map_cta'));
      await waitForAny(<Finder>[openMapCta], ticks: 220);
      expect(openMapCta, findsOneWidget);
      await tester.tap(openMapCta, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 16));

      final mapShell = find.byKey(const Key('map_shell_v1'));
      final campaignSection = find.byKey(const Key('world_campaign_section'));
      final nextPackCta = find.byKey(const Key('world_campaign_next_pack_cta'));
      await waitForAny(<Finder>[mapShell, campaignSection, nextPackCta], ticks: 260);
      expect(mapShell, findsOneWidget);
      expect(campaignSection, findsOneWidget);
      expect(nextPackCta, findsOneWidget);
      expect(find.byKey(const Key('inline_pack_node_1_1')), findsOneWidget);
      expect(find.text('Progress Map V2', skipOffstage: false), findsNothing);
      final unlockHintVisible =
          find
              .text(
                'Complete World 1 to unlock World 2',
                skipOffstage: false,
              )
              .evaluate()
              .isNotEmpty ||
          find.text('World 2 unlocked', skipOffstage: false).evaluate().isNotEmpty;
      expect(
        unlockHintVisible,
        isTrue,
        reason:
            'map iPhone completeness failed: unlock context hint is not visible',
      );
      await tester.ensureVisible(nextPackCta);
      final nextPackRect = tester.getRect(nextPackCta);
      expect(
        nextPackRect.bottom <= size.height,
        isTrue,
        reason: 'map iPhone CTA appears clipped at bottom edge',
      );
      await tester.pump(const Duration(milliseconds: 80));

      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    Future<void> captureIntakeSeatOrderCase({
      required String name,
      required Size size,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': false,
      });
      final rootBoundaryKey = Key('capture_$name');
      setTestWindow(size);
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootBoundaryKey,
          child: const MaterialApp(home: UniversalIntakePlanScreen()),
        ),
      );
      await tester.pump();
      final seatIds = <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'];
      final seatFinders = <Finder, String>{
        for (final id in seatIds) find.byKey(Key('intake_seat_$id')): id,
      };
      await waitForAny(seatFinders.keys.toList(growable: false), ticks: 220);
      for (final finder in seatFinders.keys) {
        expect(finder, findsOneWidget);
      }
      final tableRect = tester.getRect(find.byKey(const Key('intake_table')));
      final tableCenter = tableRect.center;
      final seatAngles = <String, double>{};
      final seatRects = <String, Rect>{};
      for (final entry in seatFinders.entries) {
        final rect = tester.getRect(entry.key);
        seatRects[entry.value] = rect;
        final dx = rect.center.dx - tableCenter.dx;
        final dy = tableCenter.dy - rect.center.dy;
        final angle = math.atan2(dy, dx);
        seatAngles[entry.value] = angle < 0 ? angle + (math.pi * 2.0) : angle;
      }
      final clockwise = seatIds.toList(growable: false)
        ..sort((a, b) => seatAngles[b]!.compareTo(seatAngles[a]!));
      final startIndex = clockwise.indexOf('btn');
      expect(startIndex, isNot(-1));
      final rotated = <String>[
        ...clockwise.sublist(startIndex),
        ...clockwise.sublist(0, startIndex),
      ];
      expect(rotated, <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co']);
      final rootBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(rootBoundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await rootBoundary.toImage(pixelRatio: 2.0);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      expect(byteData, isNotNull);
      final outDir = Directory('out');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      final outFile = File('out/$name.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());
    }

    await captureCase(
      name: 'default',
      child: ModernTableScreenV1(
        seatCount: 6,
        scenarioSpec: ScenarioSpecV1.fromJson(richSpec),
        debugBoardCardLabels: debugBoardCardLabels,
      ),
      expectedLabel: 'default',
      size: landscapeSize,
    );
    await captureCase(
      name: 'json',
      child: ModernTableScreenV1(
        scenarioJson: richSpecJson,
        debugBoardCardLabels: debugBoardCardLabels,
      ),
      expectedLabel: 'json',
      size: landscapeSize,
    );

    await captureCase(
      name: 'asset',
      child: ModernTableScreenV1(
        scenarioAssetPath: assetPath,
        debugBoardCardLabels: debugBoardCardLabels,
      ),
      expectedLabel: 'asset',
      size: landscapeSize,
    );

    await captureCase(
      name: 'default_portrait',
      child: ModernTableScreenV1(
        seatCount: 6,
        scenarioSpec: ScenarioSpecV1.fromJson(richSpec),
        debugBoardCardLabels: debugBoardCardLabels,
      ),
      expectedLabel: 'default',
      size: portraitSize,
    );

    await captureCase(
      name: 'json_portrait',
      child: ModernTableScreenV1(
        scenarioJson: richSpecJson,
        debugBoardCardLabels: debugBoardCardLabels,
      ),
      expectedLabel: 'json',
      size: portraitSize,
    );

    await captureCase(
      name: 'asset_portrait',
      child: ModernTableScreenV1(
        scenarioAssetPath: assetPath,
        debugBoardCardLabels: debugBoardCardLabels,
      ),
      expectedLabel: 'asset',
      size: portraitSize,
    );

    await captureFullScreenCase(
      name: 'modern_table_action_context',
      child: ModernTableScreenV1(
        scenarioJson: richSpecJson,
        debugBoardCardLabels: debugBoardCardLabels,
      ),
      size: landscapeSize,
    );
    await captureFullScreenCase(
      name: 'modern_table_action_context_portrait',
      child: ModernTableScreenV1(
        scenarioAssetPath: assetPath,
        debugBoardCardLabels: debugBoardCardLabels,
      ),
      size: portraitSize,
    );

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await captureFullScreenCase(
      name: 'runner_outcome_store',
      child: const World1FoundationsMicroTaskRunnerScreen(
        moduleId: 'intro_welcome',
        moduleTitle: 'Welcome to Poker',
      ),
      size: const Size(800, 1200),
    );
    await tester.tap(find.byKey(const Key('microtask_seat_sb')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pump(const Duration(milliseconds: 180));
    expect(find.byKey(const Key('microtask_outcome_surface')), findsOneWidget);
    final runnerBoundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('capture_runner_outcome_store')),
    );
    final runnerBytes = await tester.runAsync(() async {
      final image = await runnerBoundary.toImage(pixelRatio: 2.0);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    expect(runnerBytes, isNotNull);
    final runnerFile = File('out/runner_outcome_store.png');
    runnerFile.writeAsBytesSync(runnerBytes!.buffer.asUint8List());

    await captureMapCase(
      name: 'campaign_map_duolingo_v1',
      size: portraitSize,
    );
    await captureMapSingleSpineCase(
      name: 'campaign_map_single_spine_v2',
      size: portraitSize,
    );
    await captureMapWorldDetailSheetCase(
      name: 'map_world_detail_sheet_v1',
      size: portraitSize,
    );
    await captureMapWorldDetailSheetCase(
      name: 'map_world_detail_sheet_v1_ts115',
      size: portraitSize,
      textScale: 1.15,
    );
    await captureMapReviewDueCase(
      name: 'map_review_due_proof_v1',
      size: portraitSize,
    );
    await captureMapLevelsSheetCase(
      name: 'map_levels_sheet_proof_v1',
      size: portraitSize,
    );
    await captureModuleCatalogGemsProofCase(
      name: 'module_catalog_gems_proof_v1',
      size: landscapeSize,
    );
    await captureModuleCatalogPostflopProofCase(
      name: 'module_catalog_postflop_proof_v1',
      size: landscapeSize,
    );
    await captureModuleCatalogPostflop2ProofCase(
      name: 'module_catalog_postflop2_proof_v1',
      size: landscapeSize,
    );
    await captureModuleCatalogPostflop3ProofCase(
      name: 'module_catalog_postflop3_proof_v1',
      size: landscapeSize,
    );
    await captureModuleCatalogPostflop4ProofCase(
      name: 'module_catalog_postflop4_proof_v1',
      size: landscapeSize,
    );
    await captureModuleCatalogCoreParityProofCase(
      name: 'module_catalog_core_parity_proof_v1',
      size: landscapeSize,
    );
    await captureRunnerPortraitFullWidthCase(
      name: 'runner_portrait_fullwidth_v1',
      size: portraitSize,
    );
    await captureRunnerIntroPreludeCoachCase(
      name: 'runner_intro_prelude_coach_v1',
      size: portraitSize,
    );
    await captureRunnerVerticalFinalCase(
      name: 'runner_vertical_final_v1',
      size: portraitSize,
    );
    await captureRunnerVerticalFinalCase(
      name: 'runner_9max_overlay_proof_v1',
      size: portraitSize,
      moduleId: 'season1_demo_multistreet_v1',
      moduleTitle: 'Streets Demo',
      mode: kWorld1RunnerModeDemoHandLoopV1,
      debugSeatLayoutMaxPlayersV1: 9,
    );
    await captureRunnerVerticalFinalCase(
      name: 'runner_10max_overlay_proof_v1',
      size: portraitSize,
      moduleId: 'season1_demo_multistreet_v1',
      moduleTitle: 'Streets Demo',
      mode: kWorld1RunnerModeDemoHandLoopV1,
      debugSeatLayoutMaxPlayersV1: 10,
    );
    await captureRunnerVerticalFinalCase(
      name: 'runner_demo_multistreet_hero_co_v1',
      size: portraitSize,
      moduleId: 'season1_demo_multistreet_v1',
      moduleTitle: 'Streets Demo',
      mode: kWorld1RunnerModeDemoHandLoopV1,
    );
    await captureRunnerVerticalFinalCase(
      name: 'runner_demo_multistreet_hero_sb_v1',
      size: portraitSize,
      moduleId: 'season1_demo_multistreet_v1',
      moduleTitle: 'Streets Demo',
      mode: kWorld1RunnerModeDemoHandLoopV1,
      debugBootstrapStateV1: RunnerDebugBootstrapStateV1.demoDecisionHeroSb,
    );
    await captureRunnerVerticalFinalCase(
      name: 'runner_demo_multistreet_hero_bb_v1',
      size: portraitSize,
      moduleId: 'season1_demo_multistreet_v1',
      moduleTitle: 'Streets Demo',
      mode: kWorld1RunnerModeDemoHandLoopV1,
      debugBootstrapStateV1: RunnerDebugBootstrapStateV1.demoDecisionHeroBb,
    );
    await captureRunnerReviewQueueCase(
      name: 'runner_review_queue_proof_v1',
      size: portraitSize,
    );
    await captureDeviceEntryParityCase(
      name: 'device_entry_path_parity_v1',
      size: portraitSize,
    );
    await captureSessionResultCase(
      name: 'session_result_screen_v1',
      size: portraitSize,
    );
    await captureSessionResultCase(
      name: 'session_result_screen_v1_ts115',
      size: portraitSize,
      textScale: 1.15,
    );
    await captureSessionResultCase(
      name: 'session_result_up_next_proof_v1',
      size: portraitSize,
      requireUpNext: true,
    );
    await captureTheoryRunnerInstructionOverrideCase(
      name: 'theory_runner_instruction_override_v1',
      size: portraitSize,
    );
    await captureTheoryRunnerInstructionE2ECase(
      name: 'theory_runner_instruction_e2e_v1',
      size: portraitSize,
    );
    await captureIntakeSeatOrderCase(
      name: 'intake_seat_order_v1',
      size: portraitSize,
    );
    await captureTodayPlanRunnerVerticalProofCase(
      name: 'today_plan_runner_vertical_proof_v1',
      size: portraitSize,
    );
    await captureIntakeTableVerticalProofCase(
      name: 'intake_table_vertical_proof_v1',
      size: portraitSize,
    );
    await captureRunnerTableFirstIphoneCase(
      name: 'runner_table_first_iphone_v1',
      size: iphonePortraitSize,
    );
    await captureRunnerSpineStreetBoardCase(
      name: 'runner_spine_flop_board_v1',
      size: portraitSize,
      targetStreet: MicroTaskStreetV1.flop,
      expectedVisibleBoardCards: 3,
    );
    await captureRunnerSpineStreetBoardCase(
      name: 'runner_spine_turn_board_v1',
      size: portraitSize,
      targetStreet: MicroTaskStreetV1.turn,
      expectedVisibleBoardCards: 4,
    );
    await captureRunnerSpineStreetBoardCase(
      name: 'runner_spine_river_board_v1',
      size: portraitSize,
      targetStreet: MicroTaskStreetV1.river,
      expectedVisibleBoardCards: 5,
    );
    await captureRunnerSpineStreetBoardCase(
      name: 'runner_spine_felt_zones_v1',
      size: portraitSize,
      targetStreet: MicroTaskStreetV1.flop,
      expectedVisibleBoardCards: 3,
      requireCaptionAboveBoard: true,
      requirePotNoOverlap: true,
    );
    await captureRunnerSpineBoardCountsCase(
      name: 'runner_spine_board_counts_v1',
      size: portraitSize,
    );
    await captureRunnerSpineActionLegalityCase(
      name: 'runner_spine_actions_tocall0_v1',
      size: portraitSize,
      targetToCallZero: true,
    );
    await captureRunnerSpineActionLegalityCase(
      name: 'runner_spine_actions_tocallgt0_v1',
      size: portraitSize,
      targetToCallZero: false,
    );
    await captureRunnerWorld1FollowupBoardActionsCase(
      name: 'runner_world1_followup_board_actions_v1',
      size: portraitSize,
    );
    await captureRunnerSpineActionVarietyCase(
      name: 'runner_spine_actions_bet_v1',
      size: portraitSize,
      targetToCallZero: true,
      requiredAction: 'bet',
    );
    await captureRunnerSpineActionVarietyCase(
      name: 'runner_spine_actions_raise_to_v1',
      size: portraitSize,
      targetToCallZero: false,
      requiredAction: 'raise_to',
    );
    await captureRunnerSpinePreflopPotBlindsCase(
      name: 'runner_spine_preflop_pot_blinds_v1',
      size: portraitSize,
    );
    await captureRunnerSpinePotValueCase(
      name: 'runner_spine_pot_value_v1',
      size: portraitSize,
    );
    await captureRunnerSpineOutcomeFocusCase(
      name: 'runner_spine_outcome_focus_v1',
      size: landscapeSize,
    );
    await captureRunnerSpineOutcomeFocusCase(
      name: 'runner_spine_outcome_why_v1',
      size: landscapeSize,
    );
    await captureRunnerSpineOutcomeFocusCase(
      name: 'runner_spine_outcome_expected_v1',
      size: landscapeSize,
      requireExpectedLine: true,
    );
    await captureRunnerSpineOutcomeCorrectCase(
      name: 'runner_spine_outcome_correct_v1',
      size: landscapeSize,
    );
    await captureRunnerSpinePromptVarietyCase(
      name: 'runner_spine_prompt_variety_v1',
      size: landscapeSize,
    );
    await captureRunnerSpineTaskLineCase(
      name: 'runner_spine_task_line_v1',
      size: portraitSize,
    );
    await captureMapLadderIphoneCase(
      name: 'map_ladder_iphone_v1',
      size: iphonePortraitSize,
    );

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await captureFullScreenCase(
      name: 'seat_quiz_order_v1',
      child: const World1FoundationsMicroTaskRunnerScreen(
        moduleId: 'world1_spine_campaign_v1',
        moduleTitle: 'World 1',
        mode: kWorld1RunnerModeCampaignSpine,
      ),
      size: const Size(390, 844),
    );
    final continueCta = find.byKey(const Key('microtask_continue_cta'));
    for (var i = 0; i < 80; i++) {
      if (continueCta.evaluate().isNotEmpty) {
        break;
      }
      final allSeatsPresent = <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co']
          .every((id) => find.byKey(Key('microtask_seat_$id')).evaluate().isNotEmpty);
      if (allSeatsPresent) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 16));
    }
    if (continueCta.evaluate().isNotEmpty) {
      await tester.tap(continueCta, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
    }
    final seatIds = <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'];
    for (var i = 0; i < 80; i++) {
      final allPresent = seatIds.every(
        (id) => find.byKey(Key('microtask_seat_$id')).evaluate().isNotEmpty,
      );
      if (allPresent) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 16));
    }
    for (final id in seatIds) {
      expect(find.byKey(Key('microtask_seat_$id')), findsOneWidget);
    }
    final tableRect = tester.getRect(find.byKey(const Key('microtask_table')));
    final tableCenter = tableRect.center;
    final seatAngle = <String, double>{
      for (final id in seatIds)
        id: (() {
          final center = tester.getRect(find.byKey(Key('microtask_seat_$id'))).center;
          final dx = center.dx - tableCenter.dx;
          final dy = tableCenter.dy - center.dy;
          final angle = math.atan2(dy, dx);
          return angle < 0 ? angle + (math.pi * 2.0) : angle;
        })(),
    };
    final clockwise = seatIds.toList(growable: false)
      ..sort((a, b) => seatAngle[b]!.compareTo(seatAngle[a]!));
    final startIndex = clockwise.indexOf('btn');
    expect(startIndex, isNot(-1));
    final rotated = <String>[
      ...clockwise.sublist(startIndex),
      ...clockwise.sublist(0, startIndex),
    ];
    expect(rotated, <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co']);
    final seatBoundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('capture_seat_quiz_order_v1')),
    );
    final seatBytes = await tester.runAsync(() async {
      final image = await seatBoundary.toImage(pixelRatio: 2.0);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    expect(seatBytes, isNotNull);
    final seatFile = File('out/seat_quiz_order_v1.png');
    seatFile.writeAsBytesSync(seatBytes!.buffer.asUint8List());
  });
}

class _HarnessTheoryInstructionSourceV1 implements RunnerInstructionSourceV1 {
  const _HarnessTheoryInstructionSourceV1();

  @override
  RunnerInstructionContentV1? getIntroInstruction({
    required String moduleId,
    required String moduleTitle,
    required int railIndex,
    required int railTotal,
    required RunnerInstructionContentV1 fallback,
  }) {
    return const RunnerInstructionContentV1(
      title: 'OVR_INTRO_PROOF_V1',
      subtitle: 'OVR_INTRO_PROOF_SUB_V1',
    );
  }

  @override
  RunnerInstructionContentV1? getOutcomeInstruction({
    required String moduleId,
    required bool handLoopMode,
    required bool isCorrect,
    required RunnerInstructionContentV1 fallback,
  }) {
    return null;
  }

  @override
  RunnerInstructionContentV1? getStepInstruction({
    required String moduleId,
    required bool handLoopMode,
    required RunnerInstructionContentV1 fallback,
  }) {
    return const RunnerInstructionContentV1(
      title: 'OVR_STEP_PROOF_V1',
      subtitle: 'OVR_STEP_PROOF_SUB_V1',
    );
  }
}
''';
}
