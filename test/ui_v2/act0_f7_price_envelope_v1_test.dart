import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// R2: the premium table's Pot and To-call badges keep whole envelopes clear
/// of every source-owned object on the felt (opponent and Hero cards, board,
/// chips, dealer button, street and clue), with one or both labels and the
/// longest admitted values, at the 393x852 reference.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Ahem's square glyphs inflate pill widths; measure with Roboto.
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

  ({String world, String lesson, Act0LessonTaskV1 task}) find0(String id) {
    for (final w in Act0ShellStateV1.sample.worlds) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          if (t.taskId == id) {
            return (world: w.worldId, lesson: l.lessonId, task: t);
          }
        }
      }
    }
    throw StateError(id);
  }

  Future<void> mount(
    WidgetTester t,
    String id, {
    Act0TableStateV1 Function(Act0TableStateV1)? table,
  }) async {
    final src = find0(id);
    final runner = src.task.runner;
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.view.resetPadding);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            key: ValueKey('$id${table == null ? '' : '_variant'}'),
            runner: runner.copyWith(
              phase: src.task.phase,
              teachingStepIndex: src.task.phase == Act0LessonPhaseV1.theory
                  ? 0
                  : runner.teachingSteps.length,
              table: table == null ? null : table(runner.table),
            ),
            selectedWorldId: src.world,
            selectedLessonId: src.lesson,
            selectedTaskId: id,
            selectedTaskFamily: src.task.resolvedTaskFamily,
            tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );
    // Let any table choreography finish so the decision frame is measured.
    await t.pump(const Duration(seconds: 8));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }

  Rect painted(WidgetTester t, Finder f) {
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

  Map<String, Rect> obstacles(WidgetTester t) {
    final out = <String, Rect>{};
    for (final e in find.byWidgetPredicate((w) {
      final k = w.key;
      if (k is! ValueKey<String>) return false;
      final v = k.value;
      return v.startsWith('act0_f7_hole_cards_') ||
          v.startsWith('act0_shell_card_board_') ||
          v.startsWith('act0_shell_bet_chip_owner_') ||
          v == 'act0_shell_wave1_dealer_marker' ||
          v == 'act0_f7_street' ||
          v == 'act0_f7_clue';
    }).evaluate()) {
      final key = (e.widget.key! as ValueKey<String>).value;
      final f = find.byKey(Key(key)).first;
      final rows = find.descendant(of: f, matching: find.byType(Row));
      final r = key.startsWith('act0_f7_hole_cards_')
          ? (rows.evaluate().isEmpty ? Rect.zero : painted(t, rows.first))
          : painted(t, f);
      if (!r.isEmpty) out[key] = r;
    }
    return out;
  }

  // Badges keep at least this much clear felt around their whole envelope.
  const clearance = 2.0;

  void expectClear(WidgetTester t, {required bool price}) {
    final badges = <String, Rect>{
      'pot': painted(
        t,
        find.byKey(const Key('act0_shell_wave1_pot_priority_stat')),
      ),
      if (price)
        'price': painted(
          t,
          find.byKey(const Key('act0_shell_wave1_price_priority_stat')),
        ),
    };
    final things = obstacles(t);
    expect(
      things.keys.where((k) => k.startsWith('act0_f7_hole_cards_')),
      isNotEmpty,
    );
    for (final b in badges.entries) {
      for (final o in things.entries) {
        expect(
          b.value.inflate(clearance).overlaps(o.value),
          isFalse,
          reason: '${b.key} ${b.value} touches ${o.key} ${o.value}',
        );
      }
    }
    if (price) {
      expect(badges['pot']!.overlaps(badges['price']!), isFalse);
    }
  }

  Act0TableStateV1 longest(Act0TableStateV1 table, {required bool preflop}) =>
      table.copyWith(
        streetLabel: preflop ? 'Preflop' : 'River',
        boardCards: preflop
            ? const <Act0CardStateV1>[]
            : const <Act0CardStateV1>[
                Act0CardStateV1(rank: 'T', suit: 'h'),
                Act0CardStateV1(rank: '8', suit: 'c'),
                Act0CardStateV1(rank: '3', suit: 'd'),
                Act0CardStateV1(rank: '2', suit: 's'),
                Act0CardStateV1(rank: 'K', suit: 'd'),
              ],
        potLabel: 'Pot 41.5 BB',
        toCallLabel: 'To call 15.5 BB',
      );

  group('premium price envelopes', skip: !kAct0F7TableScenePreview, () {
    testWidgets('preflop price with SB cards (W2 QJs)', (t) async {
      await mount(t, 'hand_discipline_buckets_borderline');
      expectClear(t, price: true);
    });
    testWidgets('preflop price, CO-open frame (W3)', (t) async {
      await mount(t, 'same_hand_different_seat_w3_same_hand_call');
      expectClear(t, price: true);
    });
    testWidgets('flop price with SB and BB live (F3 call)', (t) async {
      await mount(t, 'actions_call_drill');
      expectClear(t, price: true);
    });
    testWidgets('flop price, W11 HJ bettor', (t) async {
      await mount(t, 'w11_checkpoint_mixed_table_line');
      expectClear(t, price: true);
    });
    testWidgets('turn price with SB and CO cards (W4)', (t) async {
      await mount(t, 'w4_bad_price_fold');
      expectClear(t, price: true);
    });
    testWidgets('longest admitted values, preflop and river, six live', (
      t,
    ) async {
      for (final preflop in [true, false]) {
        await mount(
          t,
          'w4_bad_price_fold',
          table: (table) => longest(table, preflop: preflop),
        );
        expectClear(t, price: true);
      }
    });
    testWidgets('pot only stays clear on the flop and preflop', (t) async {
      await mount(t, 'cards_ranks_suits_private_board');
      expectClear(t, price: false);
      await mount(t, 'first_table_guide_one_clear_choice');
      expectClear(t, price: false);
    });
  });
}
