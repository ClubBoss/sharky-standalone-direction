// PR #213 / V2_PRODUCTION_SPATIAL_BASELINE — the V2 tiered-opponent skeleton
// guard.
//
// The owner closed structural visual exploration and admitted the Cycle C V2
// spatial arrangement as the production learning-scene baseline, with one
// bounded camera exception. This test drives the real learning loop and pins
// the admitted V2 mechanics:
//
//   * production camera is exactly 0.27 / 0.47, width 0.810 unchanged;
//   * five opponent seat envelopes resolve distinctly, on both planes;
//   * flank envelopes are no longer the historical ~16 px sliver geometry;
//   * a far / upper / near depth-scale hierarchy exists;
//   * poker information (board, pot, hero cards) stays present and dominant;
//   * geometry does not drift across decide / correct / wrong / repair;
//   * the reserved top Coach Surface budget remains viable;
//   * 375 portrait remains usable.
//
// No final character art and no 9-max fan-out are in scope here; this guards
// spatial plumbing only.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_player_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _viewportsV1 = <String, Size>{
  'compact_375x812': Size(375, 812),
  'canonical_402x874': Size(402, 874),
  'large_430x932': Size(430, 932),
};

/// Half a logical pixel — the tolerance the canonical geometry invariant holds.
const _toleranceV1 = 0.5;

/// The realistic R2.3 Coach Surface reservation proven in Cycle C: ~183 px on
/// an 874-tall viewport. Expressed as a fraction so it scales per viewport.
const _coachBudgetFractionV1 = 0.20;

/// The historical pre-V2 flank sliver was ~16 px wide. A productionized
/// envelope must be unambiguously wider than that.
const _sliverCeilingPxV1 = 24.0;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('admitted V2 camera', () {
    test('production camera is exactly the admitted 0.27 / 0.47 baseline', () {
      const camera = Act0SceneCameraV1.canonical;
      expect(camera.farRailFraction, 0.27);
      expect(camera.projectedTableHeightFraction, 0.47);
    });

    test('width and derived rails follow the bounded exception only', () {
      const camera = Act0SceneCameraV1.canonical;
      // Width is frozen under PR #203 — the exception is two constants only.
      expect(camera.outerTableWidthFraction, 0.810);
      // near rail = far + projected height.
      expect(camera.nearRailFraction, closeTo(0.74, 1e-9));
    });
  });

  group('admitted V2 tiered seating grammar', () {
    const rules = Act0SceneTieredSeatingV1.production;

    test('three depth tiers form a far < upper < near scale ladder', () {
      final far = rules.scaleFor(Act0SceneOpponentTierV1.farCentre);
      final upper = rules.scaleFor(Act0SceneOpponentTierV1.upperFlank);
      final near = rules.scaleFor(Act0SceneOpponentTierV1.nearFlank);
      expect(far, lessThan(upper));
      expect(upper, lessThan(near));
      expect(far, 0.95);
      expect(upper, 1.35);
      expect(near, 1.55);
    });

    test('opponent world is wider than the felt stage', () {
      expect(rules.worldWidenFraction, greaterThan(0));
      expect(rules.horizontalInsetFor(300), lessThan(0));
      expect(rules.topInsetFor(600), lessThan(0));
      expect(rules.bottomInsetFor(600), lessThan(0));
    });

    test('only near-flank paints on the front plane', () {
      for (final tier in Act0SceneOpponentTierV1.values) {
        final onFront = rules.paintsOn(tier, Act0SceneTieredPlaneV1.front);
        final onBack = rules.paintsOn(tier, Act0SceneTieredPlaneV1.back);
        expect(onFront, tier == Act0SceneOpponentTierV1.nearFlank);
        expect(onFront, isNot(onBack));
      }
    });

    test('flank tiers face inward and mirror across the table', () {
      expect(
        rules.facingFor(Act0SceneOpponentTierV1.upperFlank, -1),
        -rules.facingFor(Act0SceneOpponentTierV1.upperFlank, 1),
      );
      expect(
        rules.facingFor(Act0SceneOpponentTierV1.nearFlank, -1).abs(),
        greaterThan(
          rules.facingFor(Act0SceneOpponentTierV1.upperFlank, -1).abs(),
        ),
      );
    });
  });

  Widget host(Object remountKey) => MaterialApp(
    home: Act0ShellPreviewScreenV1(
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
  );

  Future<void> settle(WidgetTester tester) async {
    var frames = 0;
    while (tester.binding.hasScheduledFrame && frames < 400) {
      await tester.pump(const Duration(milliseconds: 16));
      frames++;
    }
  }

  Future<void> hop(WidgetTester tester, Key key) async {
    expect(find.byKey(key), findsWidgets, reason: 'route control $key');
    await tester.tap(find.byKey(key).first, warnIfMissed: false);
    await settle(tester);
  }

  /// Every rendered opponent figure envelope, keyed by seat id.
  Map<String, Rect> opponentEnvelopes(WidgetTester tester) {
    final envelopes = <String, Rect>{};
    for (final element
        in find
            .byWidgetPredicate(
              (widget) =>
                  widget.key is ValueKey<String> &&
                  (widget.key as ValueKey<String>).value.startsWith(
                    'act0_scene_player_figure_',
                  ),
            )
            .evaluate()) {
      final id = (element.widget.key as ValueKey<String>).value.replaceFirst(
        'act0_scene_player_figure_',
        '',
      );
      // The hero has no figure key; every match here is an opponent. Keep the
      // first (outermost) rect per seat id.
      envelopes.putIfAbsent(
        id,
        () => tester.getRect(
          find.byElementPredicate((c) => identical(c, element)),
        ),
      );
    }
    return envelopes;
  }

  void expectPokerInformationIntact(WidgetTester tester, String where) {
    for (final key in const <Key>[
      Key('act0_shell_card_board_0'),
      Key('act0_shell_card_hero_0'),
      Key('act0_shell_wave1_pot_priority_stat'),
    ]) {
      final finder = find.byKey(key);
      expect(finder, findsWidgets, reason: '$where: $key must stay present');
      final rect = tester.getRect(finder.first);
      expect(
        rect.width * rect.height,
        greaterThan(0),
        reason: '$where: $key must keep real rendered area',
      );
    }
  }

  for (final entry in _viewportsV1.entries) {
    testWidgets('V2 opponent skeleton holds across the learning loop — '
        '${entry.key}', (tester) async {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(host('${entry.key}_v2'));
      await settle(tester);

      // Both composited planes are mounted.
      expect(
        find.byKey(const Key('act0_scene_player_volume_plane')),
        findsOneWidget,
        reason: 'back opponent plane present',
      );
      expect(
        find.byKey(const Key('act0_scene_player_front_plane')),
        findsOneWidget,
        reason: 'front opponent plane present',
      );

      final decide = opponentEnvelopes(tester);

      // Five distinct opponent seat envelopes resolve.
      expect(
        decide.length,
        greaterThanOrEqualTo(5),
        reason: 'five opponent envelopes: got ${decide.keys}',
      );
      final centres = decide.values.map((r) => r.center).toList();
      for (var i = 0; i < centres.length; i++) {
        for (var j = i + 1; j < centres.length; j++) {
          expect(
            (centres[i] - centres[j]).distance,
            greaterThan(1),
            reason: 'each opponent envelope occupies its own position',
          );
        }
      }

      // No flank sliver: every envelope is unambiguously wider than the
      // historical ~16 px sliver geometry.
      decide.forEach((id, rect) {
        expect(
          rect.width,
          greaterThan(_sliverCeilingPxV1),
          reason: '$id envelope is a seated figure, not a sliver ($rect)',
        );
      });

      // A far / upper / near scale hierarchy exists: the widest envelope
      // (a near-flank seat) is materially larger than the narrowest
      // (the far-centre seat).
      final widths = decide.values.map((r) => r.width).toList()..sort();
      expect(
        widths.last,
        greaterThan(widths.first * 1.25),
        reason: 'near envelopes out-scale far ones: $widths',
      );

      // The reserved top Coach Surface budget stays viable: the far-centre
      // opponent sits below it.
      final farCentre = decide.entries.reduce(
        (a, b) => a.value.width <= b.value.width ? a : b,
      );
      expect(
        farCentre.value.top,
        greaterThan(entry.value.height * _coachBudgetFractionV1),
        reason:
            'far-centre (${farCentre.key}) must clear the reserved coach band',
      );

      expectPokerInformationIntact(tester, '${entry.key} decide');

      // Deterministic geometry across the four named learning states.
      await hop(tester, const Key('act0_shell_option_check'));
      _expectSameEnvelopes(
        decide,
        opponentEnvelopes(tester),
        'correct',
        entry.key,
      );
      expectPokerInformationIntact(tester, '${entry.key} correct');

      await tester.pumpWidget(host('${entry.key}_v2b'));
      await settle(tester);
      await hop(tester, const Key('act0_shell_option_fold'));
      _expectSameEnvelopes(
        decide,
        opponentEnvelopes(tester),
        'wrong',
        entry.key,
      );
      expectPokerInformationIntact(tester, '${entry.key} wrong');

      await hop(tester, const Key('act0_shell_feedback_continue_cta'));
      _expectSameEnvelopes(
        decide,
        opponentEnvelopes(tester),
        'repair',
        entry.key,
      );
      expectPokerInformationIntact(tester, '${entry.key} repair');
    });
  }
}

void _expectSameEnvelopes(
  Map<String, Rect> reference,
  Map<String, Rect> actual,
  String state,
  String viewport,
) {
  for (final id in reference.keys) {
    final a = reference[id]!;
    final b = actual[id];
    expect(b, isNotNull, reason: '$viewport: $id must still render in $state');
    for (final (axis, x, y) in <(String, double, double)>[
      ('left', a.left, b!.left),
      ('top', a.top, b.top),
      ('width', a.width, b.width),
      ('height', a.height, b.height),
    ]) {
      expect(
        (x - y).abs(),
        lessThanOrEqualTo(_toleranceV1),
        reason:
            '$viewport: $id $axis moved ${(x - y).abs().toStringAsFixed(2)} '
            'px between decide and $state',
      );
    }
  }
}
