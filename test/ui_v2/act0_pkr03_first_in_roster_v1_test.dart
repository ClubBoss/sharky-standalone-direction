// Authored first-in snapshots, not synthetic completion of a played hand.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

Act0LessonTaskV1 _task(String id) => Act0ShellStateV1.sample.worlds
    .expand((w) => w.lessons)
    .expand((l) => l.taskList)
    .singleWhere((t) => t.taskId == id);

const _firstInIds = [
  'first_table_guide_one_clear_choice',
  'first_table_guide_route_roles',
  'actions_theory',
  'actions_raise_drill',
  'actions_review',
  'hand_discipline_buckets_intro',
  'hand_discipline_buckets_premium',
  'hand_discipline_buckets_strong',
  'hand_discipline_buckets_medium',
  'hand_discipline_buckets_borderline',
  'hand_discipline_buckets_recap',
  'weak_ace_warning_w3_dominated_intro',
  'continue_or_let_go_continue_intro',
  'continue_or_let_go_premium_continue',
  'continue_or_let_go_medium_open',
  'apply_intro',
  'apply_btn_open',
  'discipline_checkpoint_checkpoint_intro',
  'discipline_checkpoint_checkpoint_premium',
  'button_advantage_button_open',
  'same_hand_different_seat_same_hand_late_open',
  'position_apply_btn_open',
  'position_apply_late_open',
  'position_apply_recap',
  'position_checkpoint_position_checkpoint_late_open',
  'position_checkpoint_position_checkpoint_review',
];

void _firstIn(Act0TableStateV1 table) {
  final hj = table.seats.singleWhere((s) => s.seatId == 'hj');
  expect(hj.isFolded, isTrue);
  expect(hj.isInHand, isFalse);
  expect(hj.hasActed, isTrue);
  expect(table.activeSeatId, 'btn');
  expect(
    table.seats
        .where((s) => s.isOccupied && s.isInHand && !s.isFolded)
        .map((s) => s.seatId)
        .toSet(),
    {'btn', 'sb', 'bb'},
  );
  expect(table.actionTrail.map((a) => a.label), [
    'SB blind 0.5 BB',
    'BB blind 1 BB',
    'BTN acts',
  ]);
}

void main() {
  for (final id in _firstInIds) {
    test(
      '$id keeps source folded-to-BTN roster across consumer projections',
      () {
        final task = _task(id);
        final r = task.runner;
        _firstIn(r.table);
        for (final step in r.teachingSteps) {
          _firstIn(act0TeachingTableForRunnerV1(r.table, step));
        }
        for (final option in r.options) {
          _firstIn(act0RepairTableForRunnerV1(r.table, option));
          _firstIn(
            act0FeedbackTableForRunnerV1(
              runner: r.copyWith(
                phase: Act0LessonPhaseV1.review,
                selectedOptionId: option.id,
              ),
              taskFamily: task.resolvedTaskFamily,
            ),
          );
        }
      },
    );
  }
  for (final id in const [
    'hand_discipline_buckets_trash',
    'apply_utg_fold',
    'apply_hj_decision',
    'position_apply_hj_fold',
    'position_apply_early_fold',
  ]) {
    test('$id restores HJ when the authored earlier turn needs him live', () {
      final table = _task(id).runner.table;
      final hj = table.seats.singleWhere((s) => s.seatId == 'hj');
      expect(hj.isOccupied, isTrue);
      expect(hj.isInHand, isTrue);
      expect(hj.isFolded, isFalse);
      expect(
        hj.cardsVisibleMode,
        table.heroSeatId == 'hj'
            ? Act0CardsVisibleModeV1.faceUp
            : Act0CardsVisibleModeV1.faceDown,
      );
    });
  }
  testWidgets(
    'first-in roster reaches the real Runner scene in decision and feedback',
    (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final task = _task('first_table_guide_one_clear_choice');
      for (final phase in [Act0LessonPhaseV1.drill, Act0LessonPhaseV1.review]) {
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                key: ValueKey(phase),
                runner: task.runner.copyWith(
                  phase: phase,
                  selectedOptionId: phase == Act0LessonPhaseV1.review
                      ? task.runner.options.first.id
                      : null,
                  teachingStepIndex: task.runner.teachingSteps.length,
                ),
                selectedWorldId: 'world_1',
                selectedLessonId: 'first_table_guide',
                selectedTaskId: task.taskId,
                selectedTaskFamily: task.resolvedTaskFamily,
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
        final scene = t.widget<Act0TableSceneV1>(find.byType(Act0TableSceneV1));
        _firstIn(scene.table);
        final hjNode = find.byKey(const Key('act0_shell_seat_node_hj'));
        expect(
          find.descendant(of: hjNode, matching: find.text('Folded')),
          findsOneWidget,
        );
      }
    },
  );
}
