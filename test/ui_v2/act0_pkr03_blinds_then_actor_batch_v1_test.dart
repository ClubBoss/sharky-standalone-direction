// PKR-03 batch by shared template: "SB blind, BB blind, <SEAT> acts".
//
// Test-only package for the integrator; no State, Runner or contract change.
// In these authored preflop scenes the seats before the acting player are
// already drawn folded, but their folds are not recorded. The authored pot
// (1.5 BB = the blinds) leaves no chip for a limp, and the marker names the
// next seat to act, so each skipped OCCUPIED seat can only have folded, in
// seat order. Empty seats never act and get no line. The batch proposes
// exactly those fold lines and nothing else.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

const _order = ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'];
// UTG-to-act scenes skip nobody and are not part of this template.
final _marker = RegExp(r'^(HJ|CO|BTN) acts$');

/// Exact authored members of the template on main (lesson/task).
const _members = <String>{
  'what_poker_is/first_table_guide_one_clear_choice',
  'what_poker_is/first_table_guide_route_roles',
  'fold_check_call_raise/actions_theory',
  'fold_check_call_raise/actions_raise_drill',
  'fold_check_call_raise/actions_review',
  'hand_discipline_buckets/hand_discipline_buckets_intro',
  'hand_discipline_buckets/hand_discipline_buckets_premium',
  'hand_discipline_buckets/hand_discipline_buckets_strong',
  'hand_discipline_buckets/hand_discipline_buckets_medium',
  'hand_discipline_buckets/hand_discipline_buckets_borderline',
  'hand_discipline_buckets/hand_discipline_buckets_recap',
  'weak_ace_warning/weak_ace_warning_w3_dominated_intro',
  'continue_or_let_go/continue_or_let_go_continue_intro',
  'continue_or_let_go/continue_or_let_go_premium_continue',
  'continue_or_let_go/continue_or_let_go_medium_open',
  'hand_discipline_apply/apply_intro',
  'hand_discipline_apply/apply_btn_open',
  'hand_discipline_apply/apply_hj_decision',
  'discipline_checkpoint/discipline_checkpoint_checkpoint_intro',
  'discipline_checkpoint/discipline_checkpoint_checkpoint_premium',
  'button_advantage/button_advantage_button_open',
  'same_hand_different_seat/same_hand_different_seat_same_hand_late_open',
  'position_apply/position_apply_btn_open',
  'position_apply/position_apply_late_open',
  'position_apply/position_apply_recap',
  'position_checkpoint/position_checkpoint_position_checkpoint_late_open',
  'position_checkpoint/position_checkpoint_position_checkpoint_review',
};

Map<String, Act0TableStateV1> _template() {
  final out = <String, Act0TableStateV1>{};
  for (final w in Act0ShellStateV1.sample.worlds) {
    for (final l in w.lessons) {
      for (final t in l.taskList) {
        final tb = t.runner.table;
        if (tb.scope != Act0TableScopeV1.playedHand) continue;
        final labels = [for (final a in tb.actionTrail) a.label];
        if (labels.length == 3 &&
            labels[0] == 'SB blind 0.5 BB' &&
            labels[1] == 'BB blind 1 BB' &&
            _marker.hasMatch(labels[2])) {
          out['${l.lessonId}/${t.taskId}'] = tb;
        }
      }
    }
  }
  return out;
}

/// Occupied seats strictly between BB and the marker actor, in preflop
/// order. An empty seat is not a player and never folds.
List<String> _skipped(Act0TableStateV1 t) {
  final actor = _marker.firstMatch(t.actionTrail.last.label)!.group(1)!;
  final occupied = {
    for (final s in t.seats)
      if (s.isOccupied) s.seatLabel,
  };
  return [
    for (final s in _order.sublist(0, _order.indexOf(actor)))
      if (occupied.contains(s)) s,
  ];
}

Act0TableStateV1 _proposed(Act0TableStateV1 t) => t.copyWith(
  actionTrail: [
    t.actionTrail[0],
    t.actionTrail[1],
    for (final s in _skipped(t)) Act0ActionTrailItemV1(label: '$s folds'),
    t.actionTrail[2],
  ],
);

void main() {
  final tables = _template();

  test('the template members are exactly the authored set', () {
    expect(tables.keys.toSet(), _members);
  });

  test('authored facts: blinds only in the pot, skipped seats drawn out', () {
    for (final e in tables.entries) {
      final t = e.value;
      expect(t.streetLabel, 'Preflop', reason: e.key);
      expect(t.potLabel, 'Pot 1.5 BB', reason: e.key);
      final by = {for (final s in t.seats) s.seatLabel: s};
      for (final s in _skipped(t)) {
        expect(by[s]!.isInHand, isFalse, reason: '${e.key} $s');
        expect(by[s]!.isFolded, isTrue, reason: '${e.key} $s');
      }
      // Before the actor, any seat that is not a folded player is empty.
      final actorSeat = _marker.firstMatch(t.actionTrail.last.label)!.group(1)!;
      for (final s in _order.sublist(0, _order.indexOf(actorSeat))) {
        if (!_skipped(t).contains(s)) {
          expect(by[s]!.isOccupied, isFalse, reason: '${e.key} $s');
        }
      }
      // The acting seat and the blinds stay in the hand.
      final actor = _marker.firstMatch(t.actionTrail.last.label)!.group(1)!;
      expect(by[actor]!.isInHand, isTrue, reason: e.key);
      expect(by['SB']!.isInHand && by['BB']!.isInHand, isTrue, reason: e.key);
    }
    // The shared template authors one stack: BTN 100 BB, nobody else.
    for (final e in tables.entries) {
      expect(
        {
          for (final s in e.value.seats)
            if (s.stackLabel != null) s.seatLabel: s.stackLabel,
        },
        {'BTN': '100 BB'},
        reason: e.key,
      );
    }
  });

  test('a limp by any skipped seat would break the authored pot', () {
    for (final e in tables.entries) {
      final skipped = _skipped(e.value);
      // Each skipped seat folds (0) or limps (1): only all-fold fits 1.5.
      var fits = 0;
      for (var mask = 0; mask < 1 << skipped.length; mask++) {
        final limps = List.generate(skipped.length, (i) => mask >> i & 1);
        if (1.5 + limps.fold(0, (a, b) => a + b) == 1.5) fits++;
      }
      expect(fits, 1, reason: e.key);
    }
  });

  test('the proposal only adds fold lines, in seat order', () {
    final added = <String, List<String>>{};
    for (final e in tables.entries) {
      final p = _proposed(e.value);
      final labels = [for (final a in p.actionTrail) a.label];
      final authored = [for (final a in e.value.actionTrail) a.label];
      final extra = [
        for (final l in labels)
          if (!authored.contains(l)) l,
      ];
      expect(extra.every((l) => l.endsWith(' folds')), isTrue);
      added[extra.join(', ')] = [...?added[extra.join(', ')], e.key];
    }
    // 26 scenes have an empty UTG seat: only HJ and CO fold there.
    expect(added.keys.toSet(), {'HJ folds, CO folds', 'UTG folds'});
    expect(added['HJ folds, CO folds'], hasLength(26));
    expect(added['UTG folds'], ['hand_discipline_apply/apply_hj_decision']);
  });

  test('public order and playback pot on every proposed scene', () {
    final truths = <String, int>{};
    for (final e in tables.entries) {
      final p = _proposed(e.value);
      final truth = act0BettingRoundOrderTruthForTableV1(p);
      expect(
        truth,
        isNot(Act0BettingRoundOrderTruthV1.contradiction),
        reason: e.key,
      );
      truths[truth.name] = (truths[truth.name] ?? 0) + 1;
      // Folds add no chip: the playback pot stays at the blinds.
      final last = p.actionTrail.length - 1;
      expect(act0CalcTableTrailPotV1(p, last).potBb, 1.5, reason: e.key);
    }
    // ignore: avoid_print
    print('PKR03_BLINDS_THEN_ACTOR $truths');
  });
}
