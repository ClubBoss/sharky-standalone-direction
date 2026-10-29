import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_hybrid_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const profile = act0PremiumTableSceneProfileV1;
Act0SeatStateV1 altered(
  Act0SeatStateV1 s, {
  bool folded = false,
  bool empty = false,
}) => Act0SeatStateV1(
  seatId: s.seatId,
  seatLabel: s.seatLabel,
  displayName: s.displayName,
  isHero: s.isHero,
  isOccupied: !empty,
  isFolded: folded,
  isInHand: !folded,
  holeCards: s.holeCards,
);

class _Missing extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw FlutterError('Missing test plate');
}

class _Bytes extends CachingAssetBundle {
  _Bytes(this.bytes);
  final Uint8List bytes;
  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(bytes);
}

Act0TableStateV1 sourceTable() => Act0ShellStateV1.sample
    .lessonById('what_poker_is')
    .taskList
    .firstWhere((t) => t.taskId == 'what_poker_is_table_read_transfer')
    .runner
    .table;

void main() {
  test(
    'review geometry round trips as data and invalid profiles fail closed',
    () {
      final j = profile.calibrationData;
      expect(
        act0SceneProfileFromCalibrationV1(
          jsonEncode(j),
        )!.holeCardAnchorsFromHero,
        profile.holeCardAnchorsFromHero,
      );
      j['board'] = [2, 0];
      expect(act0SceneProfileFromCalibrationV1(jsonEncode(j)), isNull);
      expect(act0SceneProfileFromCalibrationV1('{broken'), isNull);
    },
  );
  test(
    'image dimensions, one transform, felt and overlay anchors register',
    () {
      expect(profile.isValid, isTrue);
      final bytes = File(profile.assetPath).readAsBytesSync();
      final width = bytes
          .sublist(16, 20)
          .fold(0, (int a, int b) => a * 256 + b);
      final height = bytes
          .sublist(20, 24)
          .fold(0, (int a, int b) => a * 256 + b);
      expect(Size(width.toDouble(), height.toDouble()), profile.sourceSize);
      final r = profile.register(const Size(393, 759));
      expect(
        r.destinationRect.width / r.destinationRect.height,
        closeTo(965 / 1629, 1e-10),
      );
      expect(r.sourceRect, Offset.zero & profile.sourceSize);
      for (final a in [
        ...profile.seatAnchorsFromHero,
        ...profile.betAnchorsFromHero,
        profile.heroAnchor,
        profile.boardAnchor,
        profile.potAnchor,
      ]) {
        expect((r.unmap(r.map(a)) - a).distance, lessThan(1e-10));
        expect(r.destinationRect.contains(r.map(a)), isTrue);
        expect(profile.uiExclusionZones.any((z) => z.contains(a)), isFalse);
      }
      expect(profile.feltSafeRegion.contains(profile.boardAnchor), isTrue);
      expect(profile.feltSafeRegion.contains(profile.potAnchor), isTrue);
      expect(profile.paintsIndependentActors, isFalse);
      expect(profile.actorOwnership, Act0SceneActorOwnershipV1.bakedIntoPlate);
    },
  );

  test(
    'six seated players, folds and real streets; empty or incompatible seats fail closed',
    () {
      final table = sourceTable();
      expect(profile.supports(table), isTrue);
      final folded = table.copyWith(
        seats: [
          for (final s in table.seats)
            if (!s.isHero) altered(s, folded: true) else s,
        ],
      );
      expect(profile.supports(folded), isTrue);
      final empty = table.copyWith(
        seats: [
          for (final s in table.seats)
            if (!s.isHero) altered(s, empty: true) else s,
        ],
      );
      expect(profile.supports(empty), isFalse);
      expect(profile.supportsScenario([table, empty]), isFalse);
      expect(
        profile.supports(
          table.copyWith(tableFormat: Act0TableFormatV1.nineMax),
        ),
        isFalse,
      );
      expect(
        profile.supports(table.copyWith(seats: table.seats.take(5).toList())),
        isFalse,
      );
      for (final count in [0, 3, 4, 5]) {
        expect(
          profile.supports(
            table.copyWith(
              boardCards: List.generate(count, (_) => table.boardCards.first),
            ),
          ),
          isTrue,
        );
      }
      expect(
        profile.supports(
          table.copyWith(boardCards: table.boardCards.take(2).toList()),
        ),
        isFalse,
      );
    },
  );

  Future<void> mount(
    WidgetTester t, {
    bool enabled = true,
    String scenario = 'one',
    Act0SceneSinglePlateImageStoreV1? store,
    AssetBundle? bundle,
    List<Act0TableStateV1>? tables,
  }) async {
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        home: Act0SceneProfileGateV1(
          enabled: enabled,
          scenarioKey: scenario,
          profile: profile,
          sourceTables: tables ?? [sourceTable()],
          store: store,
          assetBundle: bundle,
          originalBuilder: (_) => const Text('original'),
          registeredBuilder: (_, image, p) =>
              Text('registered ${image.width} ${p.id}'),
        ),
      ),
    );
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 180)),
    );
    await t.pumpAndSettle();
  }

  testWidgets('preview OFF preserves original path without loading a plate', (
    t,
  ) async {
    final store = Act0SceneSinglePlateImageStoreV1(
      profile.assetPath,
      library: 'F7 test',
    );
    await mount(t, enabled: false, store: store);
    expect(find.text('original'), findsOneWidget);
    expect(store.isReady, isFalse);
    expect(store.isMissing, isFalse);
    expect(store.isPending, isFalse);
  });
  testWidgets('missing asset falls back for the entire attempt', (t) async {
    final store = Act0SceneSinglePlateImageStoreV1(
      profile.assetPath,
      library: 'F7 test',
    );
    await t.runAsync(() => store.warmUp(bundle: _Missing()));
    await mount(t, store: store);
    expect(find.text('original'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('wrong dimensions and corrupt image bytes preserve original', (
    t,
  ) async {
    final tiny = Act0SceneSinglePlateImageStoreV1(
      profile.assetPath,
      library: 'F7 test',
    );
    await t.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.black, BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(1, 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await tiny.warmUp(bundle: _Bytes(bytes!.buffer.asUint8List()));
      image.dispose();
      picture.dispose();
    });
    await mount(t, store: tiny);
    expect(find.text('original'), findsOneWidget);
    final bad = Act0SceneSinglePlateImageStoreV1(
      profile.assetPath,
      library: 'F7 test',
    );
    final errors = <FlutterErrorDetails>[];
    final old = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await mount(
        t,
        store: bad,
        scenario: 'corrupt',
        bundle: _Bytes(Uint8List.fromList([1, 2, 3])),
      );
    } finally {
      FlutterError.onError = old;
    }
    expect(errors, hasLength(1));
    expect(find.text('original'), findsOneWidget);
  });
  testWidgets(
    'valid image loads once and profile selection is stable across feedback',
    (t) async {
      final store = Act0SceneSinglePlateImageStoreV1(
        profile.assetPath,
        library: 'F7 test',
      );
      await mount(t, store: store);
      expect(find.textContaining('registered 965'), findsOneWidget);
      final image = store.readyImage;
      await mount(t, store: store, enabled: false);
      expect(find.textContaining('registered 965'), findsOneWidget);
      expect(store.readyImage, same(image));
      await mount(t, store: store, enabled: false, scenario: 'two');
      expect(find.text('original'), findsOneWidget);
    },
  );
  testWidgets(
    'an unsupported teaching variant retains original for all phases',
    (t) async {
      final table = sourceTable();
      await mount(
        t,
        tables: [
          table,
          table.copyWith(tableFormat: Act0TableFormatV1.nineMax),
        ],
      );
      expect(find.text('original'), findsOneWidget);
      await mount(t);
      expect(find.text('original'), findsOneWidget);
    },
  );
}
