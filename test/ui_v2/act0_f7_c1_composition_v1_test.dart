import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => Act0SceneProfileGateV1.premiumStore.warmUp());

  Future<void> mount(WidgetTester t, String lesson, String id) async {
    final task = Act0ShellStateV1.sample
        .lessonById(lesson)
        .taskList
        .firstWhere((task) => task.taskId == id);
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
            key: ValueKey(id),
            runner: task.runner.copyWith(
              phase: task.phase,
              teachingStepIndex: task.phase == Act0LessonPhaseV1.theory
                  ? 0
                  : task.runner.teachingSteps.length,
            ),
            selectedWorldId: lesson == 'hand_discipline_apply'
                ? 'world_2'
                : 'world_1',
            selectedLessonId: lesson,
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
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }

  // Use transformed paint bounds, not the unscaled layout box of the wrapper.
  Rect paintedRow(WidgetTester t, String key) {
    final row = find
        .descendant(of: find.byKey(Key(key)), matching: find.byType(Row))
        .first;
    final box = t.renderObject<RenderBox>(row);
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

  testWidgets(
    'fixed five-slot board keeps actual source card anchors and scale across streets',
    (t) async {
      final anchors = <Rect>[];
      for (final street in ['flop', 'turn', 'river']) {
        await mount(t, 'your_first_hand', 'your_first_hand_$street');
        final count = street == 'flop'
            ? 3
            : street == 'turn'
            ? 4
            : 5;
        for (var i = 0; i < count; i++) {
          final card = t.getRect(find.byKey(Key('act0_shell_card_board_$i')));
          if (i < anchors.length) {
            expect(
              card,
              anchors[i],
              reason: 'board_$i must stay physically fixed on $street',
            );
          } else {
            anchors.add(card);
          }
        }
        for (var i = count; i < 5; i++) {
          expect(find.byKey(Key('act0_shell_card_board_$i')), findsNothing);
        }
      }
      expect(anchors.length, 5);
      expect(anchors.map((r) => r.size).toSet().length, 1);
      expect(anchors.first.left, greaterThan(0));
      expect(anchors.last.right, lessThan(393));
    },
  );

  testWidgets(
    'actual four/five-card source rows remain visible and separate from Hero and pot',
    (t) async {
      for (final street in ['turn', 'river']) {
        await mount(t, 'your_first_hand', 'your_first_hand_$street');
        expect(
          find.byKey(const Key('act0_f7_registered_scene')),
          findsOneWidget,
        );
        final board = paintedRow(t, 'act0_f7_board');
        final hero = paintedRow(t, 'act0_f7_hole_cards_btn');
        final pot = t.getRect(find.byKey(const Key('act0_f7_pot_price')));
        expect(board.width, greaterThan(100));
        expect(board.left, greaterThan(0));
        expect(board.right, lessThan(393));
        expect(board.bottom, lessThan(pot.top));
        expect(board.overlaps(hero), isFalse);
        expect(pot.bottom, lessThan(hero.top));
      }
    },
  );

  testWidgets(
    'source clue is separate from inward opponent cards, street and board',
    (t) async {
      await mount(t, 'what_poker_is', 'what_poker_is_table_read_transfer');
      final clue = t.getRect(find.byKey(const Key('act0_f7_clue')));
      final street = t.getRect(find.byKey(const Key('act0_f7_street')));
      final board = paintedRow(t, 'act0_f7_board');
      for (final seat in ['bb', 'hj', 'utg']) {
        expect(
          clue.overlaps(paintedRow(t, 'act0_f7_hole_cards_$seat')),
          isFalse,
        );
      }
      expect(clue.bottom, lessThan(street.top));
      expect(street.bottom, lessThan(board.top));
    },
  );

  testWidgets(
    'actual seated fold keeps source cue and empty-seat scenario still falls back',
    (t) async {
      await mount(t, 'hand_discipline_apply', 'apply_hj_decision');
      expect(find.byKey(const Key('act0_f7_registered_scene')), findsOneWidget);
      expect(find.text('Folded'), findsOneWidget);
      expect(
        t.getSize(find.byKey(const Key('act0_f7_hole_cards_utg'))),
        Size.zero,
      );
      await mount(t, 'what_poker_is', 'first_table_guide_one_clear_choice');
      expect(find.byKey(const Key('act0_f7_registered_scene')), findsNothing);
      expect(
        find.byKey(const Key('act0_integrated_scene_perspective_table')),
        findsOneWidget,
      );
    },
  );
}
