import 'dart:convert';

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

/// PR224_V4R1_FINAL_SPATIAL_SUPPORT_INTEGRATION_V1.
///
/// Narrow guards for the three admitted risks of the manager-final V4R1
/// integration: the asset/registration authority itself, `ONE_PHYSICAL_TABLE_
/// READ` ownership versus the procedural fallback, and the metadata-only
/// opponent card+label anchor contract. Nothing here builds golden imagery.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  // ---------------------------------------------------------------- T1 ----
  test('T1 manager-final five seat -> asset mapping is exact', () {
    const expected = <Act0SceneCharacterIdentityV1, (String, String, double)>{
      Act0SceneCharacterIdentityV1.utg: (
        'UTG_SEAT_ACTIVE_V4R1_MANAGER_FINAL.png',
        'UTG_PLAYER_EFFECT_MASK_V4R1_MANAGER_FINAL.png',
        1.0,
      ),
      Act0SceneCharacterIdentityV1.bb: (
        'BB_SEAT_ACTIVE_V4R1_MANAGER_FINAL.png',
        'BB_PLAYER_EFFECT_MASK_V4R1_MANAGER_FINAL.png',
        0.95,
      ),
      Act0SceneCharacterIdentityV1.hj: (
        'HJ_SEAT_ACTIVE_V4R1_MANAGER_FINAL.png',
        'HJ_PLAYER_EFFECT_MASK_V4R1_MANAGER_FINAL.png',
        0.95,
      ),
      Act0SceneCharacterIdentityV1.sb: (
        'SB_SEAT_ACTIVE_V4R1_MANAGER_FINAL.png',
        'SB_PLAYER_EFFECT_MASK_V4R1_MANAGER_FINAL.png',
        0.94,
      ),
      Act0SceneCharacterIdentityV1.co: (
        'CO_SEAT_ACTIVE_V4R1_MANAGER_FINAL.png',
        'CO_PLAYER_EFFECT_MASK_V4R1_MANAGER_FINAL.png',
        0.94,
      ),
    };

    expect(
      Act0SceneRegisteredCastRegistryV1.compositionOrder,
      Act0SceneCharacterIdentityV1.values,
    );
    expect(
      Act0SceneRegisteredCastRegistryV1.registrations.length,
      expected.length,
    );
    for (final entry in expected.entries) {
      final registration = Act0SceneRegisteredCastRegistryV1.registrationFor(
        entry.key,
      );
      expect(registration.seatActiveAsset, entry.value.$1);
      expect(registration.playerEffectMaskAsset, entry.value.$2);
      expect(registration.uniformScale, entry.value.$3);
    }

    // The rejected generated CO support must not come back under any name.
    final referenced = <String>[
      for (final registration
          in Act0SceneRegisteredCastRegistryV1.registrations.values) ...[
        registration.seatActiveAsset,
        registration.playerEffectMaskAsset,
      ],
    ];
    expect(
      referenced.where((asset) => asset.startsWith('CO_')).toList(),
      <String>[
        'CO_SEAT_ACTIVE_V4R1_MANAGER_FINAL.png',
        'CO_PLAYER_EFFECT_MASK_V4R1_MANAGER_FINAL.png',
      ],
    );
    expect(
      referenced.every((asset) => asset.endsWith('_V4R1_MANAGER_FINAL.png')),
      isTrue,
      reason: 'superseded V3 seat assets are no longer referenced',
    );
  });

  // ---------------------------------------------------------------- T2 ----
  testWidgets(
    'T2 manager-final registration maps 941x1672 deterministically across '
    '375/402/430',
    (tester) async {
      final source =
          jsonDecode(
                await rootBundle.loadString(
                  Act0SceneRegisteredCastRegistryV1.registrationSourcePath,
                ),
              )
              as Map<String, dynamic>;
      expect(source['version'], 'v4r1_manager_final');
      expect(source['sourceCanvasWidth'], 941);
      expect(source['sourceCanvasHeight'], 1672);

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
          reason: '${identity.name} rect comes from the authority file',
        );
        expect(registration.seatActiveAsset, jsonSeat['seatActiveAsset']);
        expect(
          registration.playerEffectMaskAsset,
          jsonSeat['playerEffectMaskAsset'],
        );
        expect(
          registration.uniformScale,
          (jsonSeat['uniformScale'] as num).toDouble(),
        );
        // Registration is the authority; the supplied bytes must agree with
        // it rather than the runtime inferring placement from asset bounds.
        final bytes = await rootBundle.load(registration.seatActivePath);
        expect(
          _pngSize(bytes),
          registration.sourceRect.size,
          reason: '${identity.name} PNG matches its authored rect exactly',
        );
      }

      const mapper = Act0SceneRegisteredCastMapperV1();
      final scales = <double>[];
      for (final viewport in _viewports) {
        final stage = Act0SceneCameraV1.canonical.stageRect(viewport).size;
        final shell = mapper.shellRectInStageFor(stage);
        final canvas = Act0SceneRegisteredCastRegistryV1.sourceCanvasSize;
        final xScale = shell.width / canvas.width;
        final yScale = shell.height / canvas.height;
        expect(xScale, closeTo(yScale, 1e-9), reason: 'one uniform scale');
        scales.add(xScale);
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
          // Inverting the mapping returns the authored source rect, so the
          // three widths share one contract rather than three placements.
          expect(
            (destination.left - mapper.shellRectInStageFor(stage).left) /
                xScale,
            closeTo(registration.sourceRect.left, 1e-6),
          );
        }
      }
      expect(scales.length, 3);
    },
  );

  // ---------------------------------------------------------------- T3 ----
  test('T3 UTG/BB/HJ stay back plane and SB/CO stay front plane', () {
    Iterable<Act0SceneCharacterIdentityV1> onPlane(
      Act0SceneTieredPlaneV1 plane,
    ) => Act0SceneRegisteredCastRegistryV1.compositionOrder.where(
      (identity) =>
          Act0SceneRegisteredCastRegistryV1.registrationFor(identity).plane ==
          plane,
    );

    expect(
      onPlane(Act0SceneTieredPlaneV1.back).toList(),
      <Act0SceneCharacterIdentityV1>[
        Act0SceneCharacterIdentityV1.utg,
        Act0SceneCharacterIdentityV1.bb,
        Act0SceneCharacterIdentityV1.hj,
      ],
    );
    expect(
      onPlane(Act0SceneTieredPlaneV1.front).toList(),
      <Act0SceneCharacterIdentityV1>[
        Act0SceneCharacterIdentityV1.sb,
        Act0SceneCharacterIdentityV1.co,
      ],
    );
  });

  // ------------------------------------------------------------- T4/T5 ----
  for (final viewport in _viewports) {
    testWidgets(
      'T4 hybrid-ready suppresses exactly the three duplicate full-table '
      'layers while local semantics remain — ${viewport.width.toInt()}',
      (tester) async {
        _resetProductionCast();
        addTearDown(_resetProductionCast);
        await tester.runAsync(
          () => Act0SceneRegisteredCastReadinessV1.shared.warmUp(),
        );
        expect(Act0SceneHybridShellRegistryV1.shellStore.isReady, isTrue);
        await _pumpRunner(tester, viewport);

        for (final key in _oneTableDuplicateOwners) {
          expect(
            find.byKey(key),
            findsNothing,
            reason: '$key is the baked shell\'s pixel area once it is ready',
          );
        }
        // The procedural rail and felt material were already shell-owned and
        // must stay suppressed with them.
        expect(
          find.byKey(const Key('act0_scene_table_material')),
          findsNothing,
        );
        expect(find.byKey(const Key('act0_scene_felt_material')), findsNothing);

        // Local poker semantics are never suppressed with them.
        _expectLocalSemantics(tester);
      },
    );

    testWidgets(
      'T5 no-shell fallback still renders complete procedural table ownership '
      '— ${viewport.width.toInt()}',
      (tester) async {
        _resetProductionCast();
        addTearDown(_resetProductionCast);
        expect(Act0SceneHybridShellRegistryV1.shellStore.isReady, isFalse);
        // No `runAsync`, so the shell never resolves: this is the supported
        // rollback state, and the whole procedural table must still be here.
        await _pumpRunner(tester, viewport, settle: false);

        for (final key in _oneTableDuplicateOwners) {
          expect(
            find.byKey(key),
            findsOneWidget,
            reason: '$key still owns the fallback table',
          );
        }
        expect(
          find.byKey(const Key('act0_scene_table_material')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('act0_scene_felt_material')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('act0_shell_table_felt')), findsOneWidget);
        _expectLocalSemantics(tester);
      },
    );
  }

  // ---------------------------------------------------------------- T6 ----
  testWidgets(
    'T6 opponent card+label anchors follow the manager-final metadata with no '
    'width-specific offsets',
    (tester) async {
      final source =
          jsonDecode(
                await rootBundle.loadString(
                  Act0SceneRegisteredCastAnchorsV1.recommendationSourcePath,
                ),
              )
              as Map<String, dynamic>;
      expect(source['version'], 'v4r1');
      expect(source['policy'], 'metadata_only_no_semantics_baked');
      expect(source['sourceCanvasWidth'], 941);
      expect(source['sourceCanvasHeight'], 1672);
      expect(
        Rect.fromLTRB(
          ((source['physicalFeltBBoxSource'] as List)[0] as num).toDouble(),
          ((source['physicalFeltBBoxSource'] as List)[1] as num).toDouble(),
          ((source['physicalFeltBBoxSource'] as List)[2] as num).toDouble(),
          ((source['physicalFeltBBoxSource'] as List)[3] as num).toDouble(),
        ),
        Act0SceneRegisteredCastAnchorsV1.physicalFeltBBoxSource,
      );

      final seats = source['seats'] as Map<String, dynamic>;
      for (final identity
          in Act0SceneRegisteredCastRegistryV1.compositionOrder) {
        final jsonSeat =
            seats[identity.name.toUpperCase()] as Map<String, dynamic>;
        final delta = jsonSeat['deltaSourcePx'] as List;
        expect(
          Act0SceneRegisteredCastAnchorsV1.sourceDeltaFor(identity),
          Offset((delta[0] as num).toDouble(), (delta[1] as num).toDouble()),
          reason: '${identity.name} delta comes from the authority file',
        );
        // One delta, applied to the seat's card pair group and its own
        // position-label group together.
        expect(jsonSeat['applySameDeltaToPositionLabelGroup'], isTrue);
      }
      expect(
        Act0SceneRegisteredCastAnchorsV1.sourceDeltaFor(
          Act0SceneCharacterIdentityV1.utg,
        ),
        Offset.zero,
        reason: 'UTG remains zero delta',
      );

      // Width independence: at every viewport the stage-space delta is the
      // authored source delta times the one uniform registered-cast scale.
      // There is no per-width term, so the three widths share one contract.
      const mapper = Act0SceneRegisteredCastMapperV1();
      for (final viewport in _viewports) {
        final stage = Act0SceneCameraV1.canonical.stageRect(viewport).size;
        final scale =
            mapper.shellRectInStageFor(stage).width /
            Act0SceneRegisteredCastRegistryV1.sourceCanvasSize.width;
        for (final identity
            in Act0SceneRegisteredCastRegistryV1.compositionOrder) {
          final authored = Act0SceneRegisteredCastAnchorsV1.sourceDeltaFor(
            identity,
          );
          final stageDelta = mapper.stageDeltaFor(stage, authored);
          expect(stageDelta.dx / scale, closeTo(authored.dx, 1e-6));
          expect(stageDelta.dy / scale, closeTo(authored.dy, 1e-6));
          final normalized = mapper.normalizedSemanticAnchorDeltaFor(
            stage,
            identity,
          );
          expect(normalized.dx * stage.width, closeTo(stageDelta.dx, 1e-9));
          expect(normalized.dy * stage.height, closeTo(stageDelta.dy, 1e-9));
        }
      }
    },
  );

  // ---------------------------------------------------------------- T7 ----
  for (final viewport in _viewports) {
    testWidgets(
      'T7 every opponent card pair still belongs to its own seat after anchor '
      'mapping — ${viewport.width.toInt()}',
      (tester) async {
        _resetProductionCast();
        addTearDown(_resetProductionCast);
        await tester.runAsync(
          () => Act0SceneRegisteredCastReadinessV1.shared.warmUp(),
        );
        await _pumpRunner(tester, viewport);

        final bodies = <String, Rect>{};
        final cards = <String, Rect>{};
        for (final seatId in _opponentSeatIds) {
          bodies[seatId] = _globalRect(
            find.byKey(Key('act0_scene_player_figure_$seatId')),
          )!;
          final pair = find.descendant(
            of: find.byKey(Key('act0_shell_seat_node_$seatId')),
            matching: find.byKey(const Key('act0_shell_quiet_card_back')),
          );
          expect(
            pair,
            findsNWidgets(2),
            reason: '$seatId keeps its own two-card pair',
          );
          Rect? group;
          for (final element in pair.evaluate()) {
            final rect = _globalRectOf(element.renderObject! as RenderBox);
            group = group == null ? rect : group.expandToInclude(rect);
          }
          cards[seatId] = group!;
        }

        for (final seatId in _opponentSeatIds) {
          final own = (cards[seatId]!.center - bodies[seatId]!.center).distance;
          for (final other in _opponentSeatIds) {
            if (other == seatId) continue;
            final rival =
                (cards[seatId]!.center - bodies[other]!.center).distance;
            expect(
              own,
              lessThan(rival),
              reason:
                  '$seatId cards (${cards[seatId]!.center}) belong to $seatId '
                  '(${own.toStringAsFixed(1)}) not $other '
                  '(${rival.toStringAsFixed(1)})',
            );
          }
        }
      },
    );
  }
}

const List<Size> _viewports = <Size>[
  Size(375, 812),
  Size(402, 874),
  Size(430, 932),
];

const List<String> _opponentSeatIds = <String>['utg', 'bb', 'hj', 'sb', 'co'];

/// The three redundant full-table layers `ONE_PHYSICAL_TABLE_READ` owns.
const List<Key> _oneTableDuplicateOwners = <Key>[
  Key('act0_scene_table_inner_hairline'),
  Key('act0_scene_table_gradient_wash'),
  Key('act0_scene_hero_near_plane'),
];

Size _pngSize(ByteData bytes) =>
    Size(bytes.getUint32(16).toDouble(), bytes.getUint32(20).toDouble());

Rect _globalRectOf(RenderBox box) =>
    MatrixUtils.transformRect(box.getTransformTo(null), Offset.zero & box.size);

Rect? _globalRect(Finder finder) {
  final elements = finder.evaluate();
  if (elements.isEmpty) return null;
  return _globalRectOf(elements.first.renderObject! as RenderBox);
}

void _expectLocalSemantics(WidgetTester tester) {
  for (final key in const <Key>[
    Key('act0_shell_card_board_0'),
    Key('act0_shell_card_hero_0'),
    Key('act0_shell_wave1_pot_priority_stat'),
    Key('act0_shell_runner_action_dock'),
  ]) {
    expect(find.byKey(key), findsWidgets, reason: '$key remains source-owned');
  }
  for (final seatId in _opponentSeatIds) {
    expect(
      find.byKey(Key('act0_shell_seat_node_$seatId')),
      findsOneWidget,
      reason: '$seatId keeps its live seat semantics',
    );
  }
}

void _resetProductionCast() {
  Act0SceneHybridShellRegistryV1.shellStore.clear();
  Act0SceneCharacterImageStoreV1.shared.clear();
  Act0SceneRegisteredCastReadinessV1.shared.reset();
}

Future<void> _pumpRunner(
  WidgetTester tester,
  Size viewport, {
  bool settle = true,
}) async {
  tester.view.physicalSize = viewport;
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
  if (!settle) {
    await tester.pump();
    return;
  }
  var frames = 0;
  while (tester.binding.hasScheduledFrame && frames < 400) {
    await tester.pump(const Duration(milliseconds: 16));
    frames++;
  }
}
