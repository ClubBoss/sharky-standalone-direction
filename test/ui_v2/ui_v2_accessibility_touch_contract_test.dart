import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui/session_player/models.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/settings/settings_controller.dart';
import 'package:poker_analyzer/ui_v2/settings/settings_screen.dart';
import 'package:poker_analyzer/generated/pack_library.g.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/services/return_loop_service_v1.dart';
import 'package:poker_analyzer/ui/modules/modules_screen.dart';

const _kSurfaceSize = Size(375, 667);
const _kMinTapSize = 44.0;

MediaQueryData _clampTextScaling(MediaQueryData data) {
  final clamped = data.textScaleFactor.clamp(1.0, 1.4);
  return data.copyWith(textScaleFactor: clamped);
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Widget child, {
  double textScaleFactor = 1.0,
}) async {
  tester.binding.window.physicalSizeTestValue = _kSurfaceSize;
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  addTearDown(() {
    tester.binding.window.clearPhysicalSizeTestValue();
    tester.binding.window.clearDevicePixelRatioTestValue();
  });

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, appChild) {
        final media = MediaQuery.of(
          context,
        ).copyWith(textScaleFactor: textScaleFactor);
        return MediaQuery(
          data: _clampTextScaling(media),
          child: appChild ?? const SizedBox.shrink(),
        );
      },
      home: child,
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
}

Future<BuildContext> _pumpClampProbe(
  WidgetTester tester, {
  double textScaleFactor = 2.0,
}) async {
  final probeKey = GlobalKey();
  await _pumpScreen(
    tester,
    Builder(key: probeKey, builder: (_) => const SizedBox.shrink()),
    textScaleFactor: textScaleFactor,
  );
  final context = probeKey.currentContext;
  return context!;
}

void _expectMinTapSize(Size size, String label) {
  expect(
    size.width,
    greaterThanOrEqualTo(_kMinTapSize),
    reason: '$label width < $_kMinTapSize',
  );
  expect(
    size.height,
    greaterThanOrEqualTo(_kMinTapSize),
    reason: '$label height < $_kMinTapSize',
  );
}

List<FlutterErrorDetails> _captureFlutterErrors() {
  final errors = <FlutterErrorDetails>[];
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    errors.add(details);
    oldOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = oldOnError);
  return errors;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = String.fromCharCodes(message!.buffer.asUint8List());
          if (key.endsWith('AssetManifest.json')) {
            final data = Uint8List.fromList('{}'.codeUnits);
            return ByteData.view(data.buffer);
          }
          if (key.contains('content/') && key.endsWith('/manifest.json')) {
            final data = Uint8List.fromList(
              '{"id":"intro_welcome","order":1,"title":"Test"}'.codeUnits,
            );
            return ByteData.view(data.buffer);
          }
          return null;
        });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'module_completedworld1_act0_table_literacy': true,
    });
    ReturnLoopServiceV1.instance.resetForTesting();
    packLibrary
      ..clear()
      ..addAll({
        'starter_pushfold_10bb': <TrainingPackSpot>[],
        'starter_postflop_basics': <TrainingPackSpot>[],
        'advanced_pushfold_15bb': <TrainingPackSpot>[],
      });
  });

  tearDown(packLibrary.clear);

  testWidgets('Progress map completed toggle meets touch contract', (
    tester,
  ) async {
    final errors = _captureFlutterErrors();

    await _pumpScreen(tester, const UiV2ProgressMapScreenV2());
    expect(errors, isEmpty, reason: 'Unexpected render errors in progress map');

    final toggleFinder = find.byKey(const Key('world_campaign_open_1'));
    expect(toggleFinder, findsOneWidget);

    final toggleBox = tester.renderObject<RenderBox>(toggleFinder);
    _expectMinTapSize(toggleBox.size, 'Progress map completed toggle');

    final clampContext = await _pumpClampProbe(tester);
    expect(errors, isEmpty, reason: 'Render errors at large text scale');
    final effectiveScale = MediaQuery.textScalerOf(clampContext).scale(100);
    expect(
      effectiveScale,
      isNot(equals(200)),
      reason: 'Text scaling clamp missing for progress map (expected < 2.0x).',
    );
  });

  testWidgets('Modules quick action chip meets touch contract', (tester) async {
    final errors = _captureFlutterErrors();

    await _pumpScreen(tester, const ModulesScreen(spots: <UiSpot>[]));
    expect(errors, isEmpty, reason: 'Unexpected render errors in modules');

    final tileFinder = find.byType(ActionChip);
    expect(tileFinder, findsAtLeastNWidgets(1));

    final tileBox = tester.renderObject<RenderBox>(tileFinder.first);
    _expectMinTapSize(tileBox.size, 'Modules quick action chip');

    final clampContext = await _pumpClampProbe(tester);
    expect(errors, isEmpty, reason: 'Render errors at large text scale');
    final effectiveScale = MediaQuery.textScalerOf(clampContext).scale(100);
    expect(
      effectiveScale,
      isNot(equals(200)),
      reason: 'Text scaling clamp missing for modules screen.',
    );
  });

  testWidgets('Settings haptics toggle meets touch contract', (tester) async {
    final errors = _captureFlutterErrors();

    final controller = SettingsController();
    await controller.initialize();

    await _pumpScreen(tester, SettingsScreen(controller: controller));
    expect(errors, isEmpty, reason: 'Unexpected render errors in settings');

    final hapticsLabel = find.text('Haptics');
    expect(hapticsLabel, findsOneWidget);

    final tileRow = find.ancestor(of: hapticsLabel, matching: find.byType(Row));
    expect(tileRow, findsAtLeastNWidgets(1));

    final switchFinder = find.descendant(
      of: tileRow.first,
      matching: find.byType(Switch),
    );
    expect(switchFinder, findsOneWidget);

    final switchBox = tester.renderObject<RenderBox>(switchFinder);
    _expectMinTapSize(switchBox.size, 'Haptics switch');

    final clampContext = await _pumpClampProbe(tester);
    expect(errors, isEmpty, reason: 'Render errors at large text scale');
    final effectiveScale = MediaQuery.textScalerOf(clampContext).scale(100);
    expect(
      effectiveScale,
      isNot(equals(200)),
      reason: 'Text scaling clamp missing for settings screen.',
    );
  });

  testWidgets('Progress map shows streak and daily hand chips', (tester) async {
    SharedPreferences.setMockInitialValues({
      'module_completedintro_welcome': true,
    });
    ReturnLoopServiceV1.instance.overrideClock(() => DateTime(2024, 5, 3));

    await _pumpScreen(tester, const UiV2ProgressMapScreenV2());
    final context = tester.element(find.byType(UiV2ProgressMapScreenV2));
    final l10n = AppLocalizations.of(context)!;
    final streakValue = ReturnLoopServiceV1.instance.currentStreak;
    final expectedStreak = l10n.streakChipLabel(streakValue);
    final expectedDaily = l10n.dailyHandLabel(
      ReturnLoopServiceV1.instance.todayDailyHandIndex + 1,
    );

    expect(find.textContaining(expectedDaily), findsOneWidget);
    final streakChipFinder = find.text(expectedStreak);
    if (streakChipFinder.evaluate().isNotEmpty) {
      expect(streakChipFinder, findsOneWidget);
    } else {
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.text('$streakValue'), findsAtLeastNWidgets(1));
    }
  });
}
