import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_pw_c3_facade_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Felt extents of the owner-clean plate, measured from its pixels (green
/// felt run per image row, normalized). Rows are (y, left, right).
const _feltRowsV1 = <List<double>>[
  [.40, .369, .709],
  [.44, .348, .731],
  [.48, .326, .752],
  [.52, .305, .774],
  [.56, .284, .773],
  [.60, .267, .748],
  [.64, .252, .811],
  [.68, .235, .833],
  [.72, .230, .848],
  [.76, .262, .810],
];

bool _onFeltV1(Offset p) {
  if (p.dy < _feltRowsV1.first[0] || p.dy > _feltRowsV1.last[0]) return false;
  for (var i = 0; i < _feltRowsV1.length - 1; i++) {
    final a = _feltRowsV1[i], b = _feltRowsV1[i + 1];
    if (p.dy >= a[0] && p.dy <= b[0]) {
      final t = (p.dy - a[0]) / (b[0] - a[0]);
      final left = a[1] + (b[1] - a[1]) * t;
      final right = a[2] + (b[2] - a[2]) * t;
      return p.dx > left && p.dx < right;
    }
  }
  return false;
}

(Act0LessonTaskV1, String, String) _task(String id) {
  for (final w in Act0ShellStateV1.sample.worlds) {
    for (final l in w.lessons) {
      for (final t in l.taskList) {
        if (t.taskId == id) return (t, l.lessonId, w.worldId);
      }
    }
  }
  throw StateError('missing task $id');
}

Rect _painted(WidgetTester t, Finder f) {
  final box = t.renderObject<RenderBox>(f);
  final points = [
    Offset.zero,
    Offset(box.size.width, 0),
    Offset(0, box.size.height),
    box.size.bottomRight(Offset.zero),
  ].map(box.localToGlobal).toList();
  return Rect.fromLTRB(
    points.map((p) => p.dx).reduce(math.min),
    points.map((p) => p.dy).reduce(math.min),
    points.map((p) => p.dx).reduce(math.max),
    points.map((p) => p.dy).reduce(math.max),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const p = act0PremiumTableSceneProfileV1;
  setUpAll(() async {
    // Ahem's square glyphs inflate chip/pot pill widths; measure with
    // Flutter's bundled Roboto as the existing composition tests do.
    var directory = File(Platform.resolvedExecutable).parent;
    while (directory.parent.path != directory.path) {
      final fonts = Directory(
        '${directory.path}/bin/cache/artifacts/material_fonts',
      );
      if (fonts.existsSync()) {
        final loader = FontLoader('Roboto');
        for (final weight in ['Regular', 'Medium', 'Bold']) {
          final file = File('${fonts.path}/Roboto-$weight.ttf');
          if (file.existsSync()) {
            loader.addFont(
              Future.value(ByteData.sublistView(file.readAsBytesSync())),
            );
          }
        }
        await loader.load();
        break;
      }
      directory = directory.parent;
    }
    if (kAct0F7TableScenePreview) {
      await Act0SceneProfileGateV1.premiumStore.warmUp();
    }
  });

  // The app hosts the Runner below the status bar and lets the shelf own the
  // home-indicator inset; this mirrors that at the 393x852 reference.
  Future<Act0RunnerStateV1> mount(WidgetTester t, String id) async {
    final (task, lessonId, worldId) = _task(id);
    final runner = task.runner.copyWith(
      phase: task.phase,
      teachingStepIndex: task.phase == Act0LessonPhaseV1.theory
          ? 0
          : task.runner.teachingSteps.length,
    );
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.view.resetPadding);
    await t.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Roboto'),
        home: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Act0LessonRunnerShellV1(
              key: ValueKey(id),
              runner: runner,
              selectedWorldId: worldId,
              selectedLessonId: lessonId,
              selectedTaskId: id,
              selectedTaskFamily: task.resolvedTaskFamily,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    return runner;
  }

  Act0SceneRegistrationV1 registration(WidgetTester t) {
    final scene = t.getRect(find.byKey(const Key('act0_f7_registered_scene')));
    return p.register(scene.size);
  }

  Offset toImage(WidgetTester t, Offset global) {
    final scene = t.getRect(find.byKey(const Key('act0_f7_registered_scene')));
    return registration(t).unmap(global - scene.topLeft);
  }

  group('profile and compatibility', () {
    test(
      'runtime profile is valid, uses the Welcome plate and stays opt-in',
      () {
        expect(p.isValid, isTrue);
        expect(p.id, 'owner_clean_six_seated_p1_runtime_v1');
        expect(p.assetPath, kAct0PwC3RenderAssetV1);
        expect(p.sourceSize, const Size(965, 1629));
        expect(p.actorOwnership, Act0SceneActorOwnershipV1.bakedIntoPlate);
        expect(p.supportsFoldedSeatedPlayers, isTrue);
        expect(p.supportsEmptySeats, isFalse);
        expect(
          const bool.fromEnvironment('SHARKY_F7_TABLE_SCENE_PREVIEW'),
          kAct0F7TableScenePreview,
        );
        // Review calibration still round-trips the new shelf/scrim limits.
        final rt = act0SceneProfileFromCalibrationV1('');
        expect(rt, same(p));
      },
    );

    test('every commitment anchor rests on measured felt, not the rail', () {
      for (final a in p.betAnchorsFromHero) {
        expect(_onFeltV1(a), isTrue, reason: 'bet anchor $a');
      }
      for (final a in p.holeCardAnchorsFromHero.skip(1)) {
        expect(_onFeltV1(a), isTrue, reason: 'card anchor $a');
      }
      expect(_onFeltV1(p.boardAnchor), isTrue);
      expect(_onFeltV1(p.potAnchor), isTrue);
    });

    test('only source Empty seats make a scenario unsupported', () {
      final unsupported = <String>[];
      for (final w in Act0ShellStateV1.sample.worlds) {
        for (final l in w.lessons) {
          for (final task in l.taskList) {
            final tables = [
              task.runner.table,
              for (final s in task.runner.teachingSteps)
                if (s.table != null) s.table!,
            ];
            final hasEmpty = tables.any(
              (t) => t.seats.any((s) => !s.isOccupied),
            );
            expect(
              p.supportsScenario(tables),
              !hasEmpty,
              reason: '${task.taskId} compatibility must follow Empty only',
            );
            if (hasEmpty) unsupported.add(task.taskId);
          }
        }
      }
      expect(unsupported, isNotEmpty);
    });
  });

  group('registered runtime', skip: !kAct0F7TableScenePreview, () {
    testWidgets('folded seats keep a person, a badge and no cards', (t) async {
      final runner = await mount(t, 'your_first_hand_flop');
      expect(find.byKey(const Key('act0_f7_registered_scene')), findsOneWidget);
      final folded = runner.table.seats.where((s) => s.isFolded).toList();
      expect(folded, isNotEmpty);
      expect(
        find.byKey(const Key('act0_shell_folded_badge')),
        findsNWidgets(folded.length),
      );
      for (final s in folded) {
        expect(
          t.getSize(find.byKey(Key('act0_f7_hole_cards_${s.seatId}'))),
          Size.zero,
        );
        expect(
          find.byKey(Key('act0_shell_bet_chip_owner_${s.seatId}')),
          findsNothing,
        );
        final node = t.getRect(
          find.byKey(Key('act0_shell_seat_node_${s.seatId}')),
        );
        final badge = t.getRect(
          find.descendant(
            of: find.byKey(Key('act0_shell_seat_node_${s.seatId}')),
            matching: find.byKey(const Key('act0_shell_folded_badge')),
          ),
        );
        // Badge sits below the nameplate, away from the seated face/hands.
        expect(badge.center.dy, greaterThan(node.center.dy));
      }
    });

    testWidgets('seat labels are owned by their rotated source seats', (
      t,
    ) async {
      final runner = await mount(t, 'what_poker_is_table_read_transfer');
      final r = registration(t);
      final scene = t.getRect(
        find.byKey(const Key('act0_f7_registered_scene')),
      );
      final order = runner.table.seats;
      final hero = order.indexWhere((s) => s.isHero);
      for (var i = 0; i < 6; i++) {
        final seat = order[(hero + i) % 6];
        final node = t.getRect(
          find.byKey(Key('act0_shell_seat_node_${seat.seatId}')),
        );
        final anchor = r.map(p.seatAnchorsFromHero[i]) + scene.topLeft;
        expect(
          (node.center - anchor).distance,
          lessThan(12),
          reason: seat.seatId,
        );
      }
    });

    testWidgets('posted blinds stay on felt, clear of the rail', (t) async {
      final runner = await mount(t, 'blinds_posts_drill');
      final posted = runner.table.seats.where((s) => s.bet != null).toList();
      expect(posted.length, greaterThanOrEqualTo(2));
      for (final s in posted) {
        final chip = _painted(
          t,
          find.byKey(Key('act0_shell_bet_chip_owner_${s.seatId}')),
        );
        for (final corner in [
          chip.topLeft,
          chip.topRight,
          chip.bottomLeft,
          chip.bottomRight,
        ]) {
          expect(
            _onFeltV1(toImage(t, corner)),
            isTrue,
            reason: '${s.seatId} chip corner $corner of $chip',
          );
        }
        final clue = find.byKey(const Key('act0_f7_clue'));
        if (clue.evaluate().isNotEmpty) {
          expect(chip.overlaps(t.getRect(clue)), isFalse, reason: s.seatId);
        }
      }
    });

    testWidgets('Hero cards and hands keep clearances', (t) async {
      for (final id in ['your_first_hand_river', 'actions_call_drill']) {
        await mount(t, id);
        final r = registration(t);
        final scene = t.getRect(
          find.byKey(const Key('act0_f7_registered_scene')),
        );
        final hero = _painted(
          t,
          find
              .descendant(
                of: find.byKey(const Key('act0_f7_hole_cards_btn')),
                matching: find.byType(Row),
              )
              .first,
        );
        final pot = t.getRect(find.byKey(const Key('act0_f7_pot_price')));
        final badge = t.getRect(
          find.byKey(const Key('act0_shell_seat_node_btn')),
        );
        final shelf = t.getRect(
          find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
        );
        expect(pot.bottom, lessThan(hero.top), reason: id);
        expect(hero.overlaps(badge), isFalse, reason: id);
        for (final s in ['sb', 'co']) {
          final chip = find.byKey(Key('act0_shell_bet_chip_owner_$s'));
          if (chip.evaluate().isNotEmpty) {
            expect(hero.overlaps(_painted(t, chip)), isFalse, reason: '$id $s');
          }
        }
        // The baked Hero hands stay above the control shelf.
        final hands = r.map(Offset(.5, p.controlShelfTop!)) + scene.topLeft;
        expect(shelf.top, greaterThanOrEqualTo(hands.dy - .5), reason: id);
        expect(badge.bottom, lessThan(shelf.top), reason: id);
      }
    });

    testWidgets('decision shelf exposes whole answers, never a bare sliver', (
      t,
    ) async {
      for (final id in [
        'what_poker_is_table_read_transfer',
        'actions_call_drill',
        'your_first_hand_flop',
      ]) {
        final runner = await mount(t, id);
        final screen = Offset.zero & const Size(393, 852);
        final cue = find.byKey(const Key('act0_scene_shelf_more_cue'));
        final cueRect = cue.evaluate().isEmpty ? null : t.getRect(cue);
        for (final o in runner.options) {
          final rect = t.getRect(find.byKey(Key('act0_shell_option_${o.id}')));
          final visible = rect.intersect(screen);
          final shown = visible.height > 0 ? visible.height : 0.0;
          final uncovered = cueRect == null
              ? shown
              : math.max(
                  0.0,
                  math.min(visible.bottom, cueRect.top) - visible.top,
                );
          expect(
            uncovered == 0 || uncovered >= 44 || shown == rect.height,
            isTrue,
            reason: '$id ${o.id} exposes a ${uncovered}pt fragment',
          );
        }
        if (cueRect != null) {
          // One tap on the cue reveals the next whole answer.
          await t.tap(cue);
          await t.pumpAndSettle();
          final second = t.getRect(
            find.byKey(Key('act0_shell_option_${runner.options[1].id}')),
          );
          final cueNow = cue.evaluate().isEmpty ? null : t.getRect(cue);
          expect(second.height, greaterThanOrEqualTo(44));
          expect(
            second.bottom,
            lessThanOrEqualTo(cueNow?.top ?? 852),
            reason: id,
          );
        }
        // Every answer can be scrolled to a full, unobstructed touch target.
        for (final o in runner.options) {
          final f = find.byKey(Key('act0_shell_option_${o.id}'));
          await t.ensureVisible(f);
          await t.pumpAndSettle();
          final rect = t.getRect(f);
          expect(rect.height, greaterThanOrEqualTo(44));
          expect(rect.bottom, lessThanOrEqualTo(852), reason: '$id ${o.id}');
        }
      }
    });

    testWidgets('incompatible Empty scenario falls back and keeps state', (
      t,
    ) async {
      final runner = await mount(t, 'first_table_guide_one_clear_choice');
      expect(find.byKey(const Key('act0_f7_registered_scene')), findsNothing);
      expect(
        runner.table.seats.where((s) => !s.isOccupied).map((s) => s.seatId),
        ['utg'],
      );
    });
  });
}
