import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_character_asset_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_hybrid_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_player_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_registered_cast_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Act0SceneCharacterImageStoreV1 store;

  setUp(() {
    store = Act0SceneCharacterImageStoreV1();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  tearDown(() => store.clear());

  test(
    'T1 canonical identity maps deterministically to all supplied assets',
    () {
      const expected = <Act0SceneCharacterIdentityV1, (String, String)>{
        Act0SceneCharacterIdentityV1.utg: (
          'UTG_SEAT_ACTIVE.png',
          'UTG_PLAYER_EFFECT_MASK.png',
        ),
        Act0SceneCharacterIdentityV1.bb: (
          'BB_SEAT_ACTIVE.png',
          'BB_PLAYER_EFFECT_MASK.png',
        ),
        Act0SceneCharacterIdentityV1.hj: (
          'HJ_SEAT_ACTIVE.png',
          'HJ_PLAYER_EFFECT_MASK.png',
        ),
        Act0SceneCharacterIdentityV1.sb: (
          'SB_SEAT_ACTIVE.png',
          'SB_PLAYER_EFFECT_MASK.png',
        ),
        Act0SceneCharacterIdentityV1.co: (
          'CO_SEAT_ACTIVE.png',
          'CO_PLAYER_EFFECT_MASK.png',
        ),
      };

      expect(
        Act0SceneRegisteredCastRegistryV1.compositionOrder,
        Act0SceneCharacterIdentityV1.values,
      );
      for (final entry in expected.entries) {
        final registration = Act0SceneRegisteredCastRegistryV1.registrationFor(
          entry.key,
        );
        expect(registration.seatActiveAsset, entry.value.$1);
        expect(registration.playerEffectMaskAsset, entry.value.$2);
      }
    },
  );

  testWidgets(
    'T2 source JSON and runtime registration share one 941x1672 map',
    (tester) async {
      final source =
          jsonDecode(
                await rootBundle.loadString(
                  Act0SceneRegisteredCastRegistryV1.registrationSourcePath,
                ),
              )
              as Map<String, dynamic>;
      expect(source['sourceCanvasWidth'], 941);
      expect(source['sourceCanvasHeight'], 1672);
      expect(source['compositionOrder'], <String>[
        'UTG',
        'BB',
        'HJ',
        'SB',
        'CO',
      ]);

      final seats = source['seats'] as Map<String, dynamic>;
      for (final identity
          in Act0SceneRegisteredCastRegistryV1.compositionOrder) {
        final registration = Act0SceneRegisteredCastRegistryV1.registrationFor(
          identity,
        );
        final jsonSeat =
            seats[identity.name.toUpperCase()] as Map<String, dynamic>;
        expect(
          registration.sourceRect,
          Rect.fromLTWH(
            (jsonSeat['x'] as num).toDouble(),
            (jsonSeat['y'] as num).toDouble(),
            (jsonSeat['width'] as num).toDouble(),
            (jsonSeat['height'] as num).toDouble(),
          ),
        );
        expect(registration.seatActiveAsset, jsonSeat['seatActiveAsset']);
        expect(
          registration.playerEffectMaskAsset,
          jsonSeat['playerEffectMaskAsset'],
        );
      }

      const mapper = Act0SceneRegisteredCastMapperV1();
      for (final viewport in const <Size>[
        Size(375, 812),
        Size(402, 874),
        Size(430, 932),
      ]) {
        final stage = Act0SceneCameraV1.canonical.stageRect(viewport).size;
        final shell = mapper.shellRectInStageFor(stage);
        final xScale =
            shell.width /
            Act0SceneRegisteredCastRegistryV1.sourceCanvasSize.width;
        final yScale =
            shell.height /
            Act0SceneRegisteredCastRegistryV1.sourceCanvasSize.height;
        expect(xScale, closeTo(yScale, 1e-9));
        for (final registration
            in Act0SceneRegisteredCastRegistryV1.registrations.values) {
          final destination = mapper.destinationRectFor(
            stage,
            registration.sourceRect,
          );
          expect(
            destination.width / registration.sourceRect.width,
            closeTo(xScale, 1e-9),
          );
          expect(
            destination.height / registration.sourceRect.height,
            closeTo(yScale, 1e-9),
          );
        }
      }
    },
  );

  testWidgets('T3 ready registered path bypasses generic ArtFit authority', (
    tester,
  ) async {
    await _preloadRegisteredAssets(tester, store);
    await tester.pumpWidget(
      _castHost(store: store, foldedSeatIds: const <String>{}),
    );
    await tester.pump();

    for (final identity in Act0SceneCharacterIdentityV1.values) {
      expect(
        find.byKey(Key('act0_scene_registered_${identity.name}_ready')),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('act0_scene_character_${identity.name}_ready')),
        findsNothing,
      );
    }
  });

  test('T4 registered depth ownership is back three then front two', () {
    expect(
      Act0SceneRegisteredCastRegistryV1.compositionOrder
          .where(
            (identity) =>
                Act0SceneRegisteredCastRegistryV1.registrationFor(
                  identity,
                ).plane ==
                Act0SceneTieredPlaneV1.back,
          )
          .toList(),
      <Act0SceneCharacterIdentityV1>[
        Act0SceneCharacterIdentityV1.utg,
        Act0SceneCharacterIdentityV1.bb,
        Act0SceneCharacterIdentityV1.hj,
      ],
    );
    expect(
      Act0SceneRegisteredCastRegistryV1.compositionOrder
          .where(
            (identity) =>
                Act0SceneRegisteredCastRegistryV1.registrationFor(
                  identity,
                ).plane ==
                Act0SceneTieredPlaneV1.front,
          )
          .toList(),
      <Act0SceneCharacterIdentityV1>[
        Act0SceneCharacterIdentityV1.sb,
        Act0SceneCharacterIdentityV1.co,
      ],
    );
  });

  testWidgets('T5 registered cast coexists with live semantic table widgets', (
    tester,
  ) async {
    await tester.runAsync(
      () => Act0SceneHybridShellRegistryV1.shellStore.warmUp(),
    );
    await _preloadRegisteredAssets(
      tester,
      Act0SceneCharacterImageStoreV1.shared,
    );
    addTearDown(() {
      Act0SceneHybridShellRegistryV1.shellStore.clear();
      Act0SceneCharacterImageStoreV1.shared.clear();
    });
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          state: Act0ShellStateV1.sample,
          showPlacementOnStart: false,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
            worldId: 'world_1',
            lessonId: 'fold_check_call_raise',
            taskId: 'actions_check_drill',
          ),
        ),
      ),
    );
    await _settle(tester);

    expect(
      find.byKey(const Key('act0_scene_player_volume_plane')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_scene_player_front_plane')),
      findsOneWidget,
    );
    for (final key in const <Key>[
      Key('act0_shell_card_board_0'),
      Key('act0_shell_card_hero_0'),
      Key('act0_shell_wave1_pot_priority_stat'),
      Key('act0_scene_hero_foreground_volume'),
      Key('act0_shell_runner_action_dock'),
    ]) {
      expect(
        find.byKey(key),
        findsWidgets,
        reason: '$key remains source-owned',
      );
    }
  });

  testWidgets('T6 folded overlay changes human pixels but not seat support', (
    tester,
  ) async {
    final registration = Act0SceneRegisteredCastRegistryV1.registrationFor(
      Act0SceneCharacterIdentityV1.sb,
    );
    await tester.runAsync(() async {
      final images = await Future.wait<ui.Image?>(<Future<ui.Image?>>[
        store.load(registration.seatActivePath),
        store.load(registration.playerEffectMaskPath),
      ]);
      final seat = images[0]!;
      final mask = images[1]!;
      final active = await _render(
        Act0SceneRegisteredSeatPainterV1(
          seatImage: seat,
          playerEffectMask: mask,
          folded: false,
        ),
        Size(seat.width.toDouble(), seat.height.toDouble()),
      );
      final folded = await _render(
        Act0SceneRegisteredSeatPainterV1(
          seatImage: seat,
          playerEffectMask: mask,
          folded: true,
        ),
        Size(seat.width.toDouble(), seat.height.toDouble()),
      );
      final maskBytes = (await mask.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      final seatBytes = (await seat.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      final activeBytes = (await active.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      final foldedBytes = (await folded.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();

      int? humanOffset;
      int? supportOffset;
      for (var offset = 0; offset < maskBytes.length; offset += 4) {
        final maskLuminance = maskBytes[offset];
        final seatAlpha = seatBytes[offset + 3];
        if (humanOffset == null && maskLuminance > 240 && seatAlpha > 240) {
          humanOffset = offset;
        }
        if (supportOffset == null && maskLuminance == 0 && seatAlpha > 16) {
          supportOffset = offset;
        }
        if (humanOffset != null && supportOffset != null) break;
      }
      expect(humanOffset, isNotNull);
      expect(supportOffset, isNotNull);
      final supportDelta = <int>[
        for (var channel = 0; channel < 4; channel++)
          (foldedBytes[supportOffset! + channel] -
                  activeBytes[supportOffset + channel])
              .abs(),
      ];
      expect(supportDelta, everyElement(lessThanOrEqualTo(1)));
      final humanDelta = <int>[
        for (var channel = 0; channel < 3; channel++)
          (foldedBytes[humanOffset! + channel] -
                  activeBytes[humanOffset + channel])
              .abs(),
      ];
      expect(humanDelta.reduce((a, b) => a + b), greaterThan(12));
    });
  });
  for (final viewport in const <Size>[
    Size(375, 812),
    Size(402, 874),
    Size(430, 932),
  ]) {
    testWidgets(
      'T7 both HJ hole cards render unobscured by the registered front plane '
      '— ${viewport.width.toInt()}',
      (tester) async {
        await _preloadProductionCast(tester);
        addTearDown(_resetProductionCast);
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_runnerHost());
        await _settle(tester);
        for (final identity in Act0SceneCharacterIdentityV1.values) {
          expect(
            find.byKey(Key('act0_scene_registered_${identity.name}_ready')),
            findsOneWidget,
          );
        }

        final hjCardBacks = find.descendant(
          of: find.byKey(const Key('act0_shell_seat_node_hj')),
          matching: find.byKey(const Key('act0_shell_quiet_card_back')),
        );
        expect(hjCardBacks, findsNWidgets(2));

        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('act0_registered_cast_test_boundary')),
        );
        final frame = await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData();
          return (image.width, bytes!);
        });
        final (frameWidth, frameBytes) = frame!;

        for (final element in hjCardBacks.evaluate()) {
          final box = element.renderObject! as RenderBox;
          final toGlobal = box.getTransformTo(null);
          var sampled = 0;
          var cardBack = 0;
          // The quiet back is a navy gradient (0xFF172B45 -> 0xFF233B59). An
          // inset keeps antialiased edges and the faint border out of the
          // sample; every remaining pixel must still be that live card back.
          for (var y = 3.0; y <= box.size.height - 3; y += 1) {
            for (var x = 3.0; x <= box.size.width - 3; x += 1) {
              final global = MatrixUtils.transformPoint(toGlobal, Offset(x, y));
              final offset =
                  (global.dy.floor() * frameWidth + global.dx.floor()) * 4;
              final r = frameBytes.getUint8(offset);
              final g = frameBytes.getUint8(offset + 1);
              final b = frameBytes.getUint8(offset + 2);
              sampled++;
              if (r >= 0x11 &&
                  r <= 0x29 &&
                  g >= 0x25 &&
                  g <= 0x41 &&
                  b >= 0x3F &&
                  b <= 0x5F) {
                cardBack++;
              }
            }
          }
          expect(sampled, greaterThan(300));
          expect(
            cardBack,
            sampled,
            reason:
                'HJ card at ${MatrixUtils.transformRect(toGlobal, Offset.zero & box.size)} '
                'must be owned by the live card back ($cardBack/$sampled)',
          );
        }
      },
    );
  }

  testWidgets(
    'T8 cold start presents no opponent identity until all five register '
    'together',
    (tester) async {
      _resetProductionCast();
      addTearDown(_resetProductionCast);
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_runnerHost());
      await tester.pump();

      // First visible frame: nothing is decoded, so both opponent planes are
      // held and no generic or V3 identity is presented.
      expect(
        Act0SceneRegisteredCastReadinessV1.shared.phase,
        Act0SceneRegisteredCastPhaseV1.pending,
      );
      _expectPlanesPresented(tester, presented: false);
      expect(_readySeatCount(), 0);

      var sawReady = false;
      for (var hop = 0; hop < 200 && !sawReady; hop++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump(const Duration(milliseconds: 16));
        final ready = _readySeatCount();
        final phase = Act0SceneRegisteredCastReadinessV1.shared.phase;
        if (phase == Act0SceneRegisteredCastPhaseV1.ready) {
          sawReady = true;
          expect(ready, 5, reason: 'all five register in the same frame');
          _expectPlanesPresented(tester, presented: true);
        } else {
          // Partial decode never leaks: planes stay held and no seat has
          // swapped to its registered composite ahead of the others.
          expect(phase, Act0SceneRegisteredCastPhaseV1.pending);
          expect(ready, 0, reason: 'no early per-seat identity swap');
          _expectPlanesPresented(tester, presented: false);
        }
      }
      expect(sawReady, isTrue, reason: 'bundled V3 cast must become ready');

      await _settle(tester);
      expect(_readySeatCount(), 5);
      for (final identity in Act0SceneCharacterIdentityV1.values) {
        expect(
          find.byKey(Key('act0_scene_registered_${identity.name}_fallback')),
          findsNothing,
        );
      }
    },
  );

  testWidgets('T9 a partially decoded set keeps every seat on one identity', (
    tester,
  ) async {
    final registrations = Act0SceneRegisteredCastRegistryV1.registrations;
    final early = <Act0SceneCharacterIdentityV1>[
      Act0SceneCharacterIdentityV1.utg,
      Act0SceneCharacterIdentityV1.hj,
      Act0SceneCharacterIdentityV1.co,
    ];
    await tester.runAsync(
      () => Future.wait<ui.Image?>(<Future<ui.Image?>>[
        for (final identity in early) ...[
          store.load(registrations[identity]!.seatActivePath),
          store.load(registrations[identity]!.playerEffectMaskPath),
        ],
      ]),
    );
    await tester.pumpWidget(
      _castHost(store: store, foldedSeatIds: const <String>{}),
    );
    await tester.pump();
    for (final identity in Act0SceneCharacterIdentityV1.values) {
      expect(
        find.byKey(Key('act0_scene_registered_${identity.name}_ready')),
        findsNothing,
      );
      expect(
        find.byKey(Key('act0_scene_registered_${identity.name}_fallback')),
        findsOneWidget,
      );
    }

    await _preloadRegisteredAssets(tester, store);
    await tester.pumpWidget(
      _castHost(store: store, foldedSeatIds: const <String>{'hj-seat'}),
    );
    await tester.pump();
    for (final identity in Act0SceneCharacterIdentityV1.values) {
      expect(
        find.byKey(Key('act0_scene_registered_${identity.name}_ready')),
        findsOneWidget,
      );
    }
  });

  for (final failure in _AssetFailureV1.values) {
    testWidgets(
      'T10 a ${failure.name} V3 asset falls back safely as one cast',
      (tester) async {
        _resetProductionCast();
        addTearDown(_resetProductionCast);
        final hj = Act0SceneRegisteredCastRegistryV1.registrationFor(
          Act0SceneCharacterIdentityV1.hj,
        );
        final bundle = _FailingAssetBundleV1(
          failingPath: failure == _AssetFailureV1.missing
              ? hj.seatActivePath
              : hj.playerEffectMaskPath,
          failure: failure,
        );
        final reported = <FlutterErrorDetails>[];
        final phase = await tester.runAsync(() async {
          final previous = FlutterError.onError;
          FlutterError.onError = reported.add;
          try {
            return await Act0SceneRegisteredCastReadinessV1.shared.warmUp(
              bundle: bundle,
            );
          } finally {
            FlutterError.onError = previous;
          }
        });
        expect(phase, Act0SceneRegisteredCastPhaseV1.unavailable);
        expect(
          reported,
          failure == _AssetFailureV1.corrupt ? isNotEmpty : isEmpty,
        );
        expect(Act0SceneHybridShellRegistryV1.shellStore.isReady, isTrue);

        tester.view.physicalSize = const Size(402, 874);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(_runnerHost());
        await _settle(tester);

        _expectPlanesPresented(tester, presented: true);
        expect(_readySeatCount(), 0);
        for (final identity in Act0SceneCharacterIdentityV1.values) {
          expect(
            find.byKey(Key('act0_scene_registered_${identity.name}_fallback')),
            findsOneWidget,
            reason: '${identity.name} uses the generic fallback with the cast',
          );
        }
      },
    );
  }
}

enum _AssetFailureV1 { missing, corrupt }

class _FailingAssetBundleV1 extends CachingAssetBundle {
  _FailingAssetBundleV1({required this.failingPath, required this.failure});

  final String failingPath;
  final _AssetFailureV1 failure;

  @override
  Future<ByteData> load(String key) async {
    if (key == failingPath) {
      if (failure == _AssetFailureV1.missing) {
        throw FlutterError('Unable to load asset: "$key".');
      }
      return ByteData.sublistView(Uint8List.fromList(<int>[1, 2, 3, 4, 5]));
    }
    return rootBundle.load(key);
  }
}

Widget _runnerHost() => MaterialApp(
  home: RepaintBoundary(
    key: const Key('act0_registered_cast_test_boundary'),
    child: Act0ShellPreviewScreenV1(
      state: Act0ShellStateV1.sample,
      showPlacementOnStart: false,
      debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
        mode: Act0ControlledDemoCaptureModeV1.directState,
        surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
        worldId: 'world_1',
        lessonId: 'fold_check_call_raise',
        taskId: 'actions_check_drill',
      ),
    ),
  ),
);

Future<void> _preloadProductionCast(WidgetTester tester) async {
  await tester.runAsync(
    () => Act0SceneRegisteredCastReadinessV1.shared.warmUp(),
  );
  expect(
    Act0SceneRegisteredCastReadinessV1.shared.phase,
    Act0SceneRegisteredCastPhaseV1.ready,
  );
}

void _resetProductionCast() {
  Act0SceneHybridShellRegistryV1.shellStore.clear();
  Act0SceneCharacterImageStoreV1.shared.clear();
  Act0SceneRegisteredCastReadinessV1.shared.reset();
}

int _readySeatCount() => Act0SceneCharacterIdentityV1.values
    .where(
      (identity) => find
          .byKey(Key('act0_scene_registered_${identity.name}_ready'))
          .evaluate()
          .isNotEmpty,
    )
    .length;

void _expectPlanesPresented(WidgetTester tester, {required bool presented}) {
  for (final key in const <Key>[
    Key('act0_scene_player_volume_plane'),
    Key('act0_scene_player_front_plane'),
  ]) {
    final visibility = tester.widget<Visibility>(
      find
          .ancestor(of: find.byKey(key), matching: find.byType(Visibility))
          .first,
    );
    expect(visibility.visible, presented, reason: '$key presented');
  }
}

Widget _castHost({
  required Act0SceneCharacterImageStoreV1 store,
  required Set<String> foldedSeatIds,
}) => Directionality(
  textDirection: TextDirection.ltr,
  child: SizedBox(
    width: 330,
    height: 390,
    child: Stack(
      children: [
        for (final plane in Act0SceneTieredPlaneV1.values)
          Positioned.fill(
            child: Act0SceneRegisteredCastLayerV1(
              slots: _slots(),
              plane: plane,
              foldedSeatIds: foldedSeatIds,
              store: store,
            ),
          ),
      ],
    ),
  ),
);

List<Act0SceneSeatSlotV1> _slots() => <Act0SceneSeatSlotV1>[
  _slot('utg-seat', x: 0.5, depth: 0.1),
  _slot('bb-seat', x: 0.1, depth: 0.3),
  _slot('hj-seat', x: 0.9, depth: 0.3),
  _slot('sb-seat', x: 0.1, depth: 0.8),
  _slot('co-seat', x: 0.9, depth: 0.8),
  _slot('hero-seat', x: 0.5, depth: 0.9, isHero: true),
];

Act0SceneSeatSlotV1 _slot(
  String seatId, {
  required double x,
  required double depth,
  bool isHero = false,
}) => Act0SceneSeatSlotV1(
  seatId: seatId,
  depth: depth,
  plateAnchor: Offset(x, depth),
  characterAnchor: Offset(x, depth),
  betAnchor: Offset(x, depth),
  cardAnchor: Offset(x, depth),
  plateScale: 1,
  volumeScale: 1,
  isHero: isHero,
);

Future<void> _preloadRegisteredAssets(
  WidgetTester tester,
  Act0SceneCharacterImageStoreV1 store,
) async {
  await tester.runAsync(
    () => Future.wait<ui.Image?>(<Future<ui.Image?>>[
      for (final registration
          in Act0SceneRegisteredCastRegistryV1.registrations.values) ...[
        store.load(registration.seatActivePath),
        store.load(registration.playerEffectMaskPath),
      ],
    ]),
  );
}

Future<void> _settle(WidgetTester tester) async {
  var frames = 0;
  while (tester.binding.hasScheduledFrame && frames < 400) {
    await tester.pump(const Duration(milliseconds: 16));
    frames++;
  }
}

Future<ui.Image> _render(CustomPainter painter, Size size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  painter.paint(canvas, size);
  return recorder.endRecording().toImage(
    size.width.toInt(),
    size.height.toInt(),
  );
}
