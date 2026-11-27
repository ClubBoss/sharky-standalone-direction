// G1 pre-choice witnesses for manually adjudicated B153 pairs.
// This is a snapshot projection, not the Flutter B44 catalog exporter.
import 'dart:convert';
import 'dart:io';
import '../../tools/transfer_novelty_check_v1.dart';

const b153Witnesses =
    <String, (String, String, String, String, String, String)>{
      'paired_board_texture_lite_intro': (
        'visible_king_combo_reduction_intro',
        'Two sevens are visible',
        'A king is on the board',
        'visible_rank_count',
        '[2]',
        '[1]',
      ),
      'visible_card_combo_density_transfer_check': (
        'paired_board_texture_lite_intro',
        'Three queens are visible',
        'Two sevens are visible',
        'visible_rank_count',
        '[3]',
        '[2]',
      ),
      'w7_effective_stack_100bb': (
        'w7_effective_stack_30bb',
        'BB stack 100 BB',
        'You have 200 BB. The other player has 30 BB',
        'live_stacks',
        '[100,100]',
        '[200,30]',
      ),
      'w7_table_effective_notice': (
        'w7_effective_stack_30bb',
        '120 BB behind with BB’s 18 BB',
        '200 BB. The other player has 30 BB',
        'live_stacks',
        '[120,18]',
        '[200,30]',
      ),
      'w8_effective_stack_seat': (
        'w7_effective_stack_30bb',
        'CO Th Tc stack 70 BB',
        'You have 200 BB. The other player has 30 BB',
        'live_stacks',
        '[70,18]',
        '[200,30]',
      ),
      'w8_hero_stack_cap_seat': (
        'w8_effective_stack_seat',
        'HJ Ac 9h stack 22 BB',
        'BB stack 18 BB',
        'live_stacks',
        '[22,65]',
        '[70,18]',
      ),
      'w7_40bb_middle': (
        'w7_100bb_tighter',
        '5 BB flop bet and a 10 BB turn bet',
        '4 BB flop bet and an 8 BB turn bet',
        'stack_then_bets',
        '[40,5,10]',
        '[100,4,8]',
      ),
      'w7_high_spr_room': (
        'w7_low_spr_commit',
        'SPR is 8 on the flop',
        'SPR is 2 on the flop',
        'spr',
        '[8]',
        '[2]',
      ),
      'w7_spr4_middle': (
        'w7_low_spr_commit',
        'SPR is 4',
        'SPR is 2 on the flop',
        'spr',
        '[4]',
        '[2]',
      ),
      'w9_m_ratio_red_zone_shove': (
        'w9_short_stack_survival',
        'Stack: 12 BB',
        'You start with 9 BB',
        'first_in_stack_and_blinds',
        '[12,2]',
        '[9,1]',
      ),
      'w9_checkpoint_zone_line': (
        'w9_m_ratio_table_window_transfer',
        'Starting stack: 33 BB',
        'Stack: 18 BB. No antes',
        'm_inputs_and_frame',
        '[33,1.5,"first_in"]',
        '[18,1.5,"bb_free"]',
      ),
      'w10_overbluff_punish': (
        'w10_same_hand_river_overbluff',
        '55% and',
        'Half the bets',
        'bluff_share_pct',
        '[55]',
        '[50]',
      ),
      'w10_checkpoint_table_notice': (
        'w10_overbluff_punish',
        '50% missed JT or T9',
        '55% and',
        'bluff_share_pct',
        '[50]',
        '[55]',
      ),
      'w11_checkpoint_plan_line': (
        'w11_sb_3bet_value',
        '3-bets with AT, A9s, KQ and 88-JJ',
        '3-bets with 99-JJ, ATs and KQs',
        'three_bet_caller_range',
        '["AT","A9s","KQ","88-JJ"]',
        '["99-JJ","ATs","KQs"]',
      ),
      'w11_checkpoint_review': (
        'w11_spr_low_overpair',
        'wins 60%',
        'wins 65%',
        'spr_and_win_pct',
        '[1.5,60]',
        '[2.1,65]',
      ),
      'w11_y5d_river_read_transfer': (
        'w11_y5d_guided_river_read',
        '15% of the bets',
        '40% of the bets',
        'bluff_share_pct',
        '[15]',
        '[40]',
      ),
      'w12_clean_outs_vs_set': (
        'w12_bad_call_good_result',
        'SB bets 2 into 12',
        'BB bets 12 into 10',
        'call_pot_pair',
        '[2,14,"99"]',
        '[12,22,"KK"]',
      ),
      'w12_river_price_call': (
        'w12_good_fold_bad_result',
        '35% missed',
        '3 missed KQ/QT',
        'bluff_share_pct',
        '[35]',
        '[15]',
      ),
      'w12_discipline_under_pressure': (
        'w12_good_fold_bad_result',
        '45% missed',
        '3 missed KQ/QT',
        'bluff_share_pct',
        '[45]',
        '[15]',
      ),
      'w12_pretty_hand_bad_price_fold': (
        'w12_discipline_under_pressure',
        'one was missed JT',
        '45% missed',
        'bluff_share_pct',
        '[5]',
        '[45]',
      ),
      'w12_y5d_range_read_transfer': (
        'w12_y5d_guided_range_read',
        '35% of the bets',
        '18% of the bets',
        'bluff_share_pct',
        '[35]',
        '[18]',
      ),
      'w12_cur04b_call_after_loss': (
        'w12_good_fold_bad_result',
        'As Js, Ks Js, Ad Qc, Kd Qd, 6c 6d and 8c 8d',
        '3 missed KQ/QT',
        'current_bet_mix',
        '["As Js","Ks Js","Ad Qc","Kd Qd","6c 6d","8c 8d"]',
        '[15]',
      ),
      'w12_cur04b_ignore_one_show': (
        'w12_good_fold_bad_result',
        'Ad Td, Ah Js, Kd Jh, 8c 8h and 5c 5h',
        '3 missed KQ/QT',
        'current_bet_mix',
        '["Ad Td","Ah Js","Kd Jh","8c 8h","5c 5h"]',
        '[15]',
      ),
      'w12_checkpoint_process_line': (
        'w12_good_fold_bad_result',
        'missed AJ/KT 40%',
        '3 missed KQ/QT',
        'bluff_share_pct',
        '[40]',
        '[15]',
      ),
      'w12_checkpoint_discipline_line': (
        'w12_discipline_under_pressure',
        '12% missed JT',
        '45% missed',
        'bluff_share_pct',
        '[12]',
        '[45]',
      ),
      'w7_clean_outs_lower_price': (
        'w4_big_price_marginal_fold',
        'To call 3 BB',
        'win 1 time in 4 (25%)',
        'call_pot_pair',
        '[3,11]',
        '[6,13]',
      ),
      'w7_clean_outs_higher_price': (
        'w4_big_price_marginal_fold',
        'To call 6 BB',
        'win 1 time in 4 (25%)',
        'call_pot_pair',
        '[6,14]',
        '[6,13]',
      ),
      'spaced_review_w7_w7_visible_cards_and_price_pot_to_call_v1': (
        'w4_big_price_marginal_fold',
        'To call 2 BB',
        'win 1 time in 4 (25%)',
        'call_pot_pair',
        '[2,8]',
        '[6,13]',
      ),
      'spaced_review_w8_effective_stack_basics_board_cards_v1': (
        'w7_effective_stack_30bb',
        'stack 36 BB',
        '200 BB. The other player has 30 BB',
        'live_stacks',
        '[68,36]',
        '[200,30]',
      ),
      'spaced_review_w8_effective_stack_basics_hero_cards_board_pot_v1': (
        'w7_effective_stack_30bb',
        'stack 24 BB',
        '200 BB. The other player has 30 BB',
        'live_stacks',
        '[82,24]',
        '[200,30]',
      ),
      'spaced_review_w8_effective_stack_basics_hero_seat_v1': (
        'w8_effective_stack_seat',
        'HJ Qs Jc stack 16 BB',
        'CO Th Tc stack 70 BB',
        'live_stacks',
        '[16,54]',
        '[70,18]',
      ),
      'spaced_review_w8_effective_stack_basics_big_blind_v1': (
        'w8_hero_stack_cap_seat',
        'BB stack 14 BB',
        'HJ Ac 9h stack 22 BB',
        'live_stacks',
        '[42,14]',
        '[22,65]',
      ),
      'spaced_review_w8_same_hand_different_depth_hero_cards_board_pot_v1': (
        'w7_table_effective_notice',
        'stack 29 BB',
        '120 BB behind with BB’s 18 BB',
        'live_stacks',
        '[43,29]',
        '[120,18]',
      ),
      'spaced_review_w8_same_hand_different_depth_pot_to_call_v1': (
        'w7_ajs_btn_25bb_transfer',
        'reraise to 9 BB',
        'raise to 7.5 BB',
        'small_reraise_model',
        '[9,24]',
        '[7.5,25]',
      ),
      'spaced_review_w8_spr_and_commitment_board_cards_v1': (
        'w7_low_spr_commit',
        'smaller stack at 12 BB',
        'SPR is 2 on the flop',
        'stack_and_pot',
        '[12,6]',
        '[10,5]',
      ),
      'spaced_review_w9_m_ratio_zones_lite_misread_tournament_pressure_v1': (
        'w9_m_ratio_table_window_transfer',
        'Six seats pay 0.1 BB each',
        'Stack: 18 BB. No antes',
        'm_inputs_and_frame',
        '[18,2.1,"first_in"]',
        '[18,1.5,"bb_free"]',
      ),
      'spaced_review_w9_bubble_risk_premium_misread_tournament_pressure_v1': (
        'w9_cash_vs_tournament',
        'You win 70%',
        'You win 40%',
        'win_and_prize_threshold_pct',
        '[70,50.7]',
        '[40,62.4]',
      ),
      'spaced_review_w10_player_type_basics_hero_cards_board_pot_v1': (
        'w10_underbluff_second',
        '55% missed high cards',
        'last 8%',
        'bluff_share_pct',
        '[55]',
        '[8]',
      ),
      'spaced_review_w10_adjust_one_lever_board_cards_v1': (
        'w10_vs_caller_value_heavier',
        'CO calls 3 BB and 4 BB',
        'BB always calls 2 or 3 BB',
        'weak_caller_sizes',
        '[3,4,18]',
        '[2,3,15]',
      ),
      'w11_day7_bb_decision': (
        'w11_bb_defend_price',
        'To call 2 BB',
        'To call 1 BB',
        'wide_open_price',
        '[3,2]',
        '[2,1]',
      ),
      'w12_day7_outcome_bias': (
        'w12_good_fold_bad_result',
        '38% missed KT/QJ',
        '3 missed KQ/QT',
        'bluff_share_pct',
        '[38]',
        '[15]',
      ),
      'w12_day7_river_underbluff': (
        'w12_discipline_under_pressure',
        '15% are missed QJ/JT',
        '45% missed',
        'bluff_share_pct',
        '[15]',
        '[45]',
      ),
      'w10_same_hand_river_overbluff': (
        'w10_underbluff_second',
        'Half the bets',
        'last 8%',
        'bluff_share_pct',
        '[50]',
        '[8]',
      ),
      'w9_checkpoint_review': (
        'w9_cash_vs_tournament',
        'Call uses your last 19 BB',
        'You win 40%',
        'prize_risk_inputs',
        '["AA","QQ+/AK",19,2]',
        '[40,62.4]',
      ),
    };

class B153SnapshotTask {
  B153SnapshotTask(this.id, this.world, this.lesson, this.course, this.phase);
  final String id;
  final int world;
  final String lesson;
  final bool course;
  final String phase;
  final List<String> prechoice = [];
  final List<String> choices = [];
  final List<String> correct = [];
  bool hasMiss = false;

  String field(String prefix) => prechoice
      .firstWhere((line) => line.startsWith(prefix), orElse: () => '')
      .replaceFirst(prefix, '');
}

Map<String, B153SnapshotTask> readB153Snapshot() {
  final tasks = <String, B153SnapshotTask>{};
  var course = true;
  var world = 0;
  var lesson = '';
  B153SnapshotTask? task;
  for (final line in File(
    'test/fixtures/act0_catalog_snapshot_v1.txt',
  ).readAsLinesSync()) {
    if (line.startsWith('=====')) {
      final match = RegExp(r'WORLD (\d+) · LESSON (\S+)').firstMatch(line);
      if (match == null) {
        course = false;
      } else {
        world = int.parse(match[1]!);
        lesson = match[2]!;
      }
      task = null;
      continue;
    }
    final heading = RegExp(r'^TASK (\S+) \[(\w+)\]').firstMatch(line);
    if (heading != null) {
      final id = heading[1]!;
      if (tasks.containsKey(id)) throw StateError('Duplicate G1 ID $id');
      task = B153SnapshotTask(id, world, lesson, course, heading[2]!);
      tasks[id] = task;
      continue;
    }
    if (task == null) continue;
    if ([
      'CAPTION: ',
      'Q: ',
      'TABLE: ',
      'SEATS: ',
      'TRAIL: ',
    ].any(line.startsWith)) {
      task.prechoice.add(line);
    }
    final option = RegExp(
      r'^  [+-] \[(correct|wrong|suboptimal)\] (.*?) — ',
    ).firstMatch(line);
    if (option != null) {
      final label = option[2]!.replaceFirst(RegExp(r' \[seat .*?\]$'), '');
      task.choices.add(label);
      if (option[1] == 'correct') {
        task.correct.add(label);
      } else {
        task.hasMiss = true;
      }
    }
  }
  return tasks;
}

/// Only observable G1 inputs: no generated scenarios or task IDs used as
/// decision features. The call threshold is the displayed pot fraction;
/// non-call questions have no call threshold. The selected premise witness
/// supplements the table where B44's original metadata cannot represent
/// tournament thresholds, stack caps, or visible-card counts.
Map<String, dynamic> b153Spot(
  B153SnapshotTask task,
  String witness,
  String signal,
  String decisionInput,
) {
  if (!task.prechoice
      .join('\n')
      .toLowerCase()
      .contains(witness.toLowerCase())) {
    throw StateError('${task.id}: missing pre-choice witness $witness');
  }
  final table = task.field('TABLE: ');
  final parts = table.split(' | ');
  String part(String prefix) => parts
      .firstWhere((value) => value.startsWith(prefix), orElse: () => '')
      .replaceFirst(prefix, '');
  final pot = double.parse(RegExp(r'\bPot ([\d.]+) BB').firstMatch(table)![1]!);
  final callMatch = RegExp(r'\bTo call ([\d.]+) BB').firstMatch(table);
  final call = callMatch == null ? 0.0 : double.parse(callMatch[1]!);
  final position = part('Seat ');
  final cards = part(
    'You ',
  ).split(' ').map((card) => [card[0], card[1]]).toList();
  final bucket = transferHandBucketV2(cards);
  if (bucket == null || position.isEmpty || task.correct.length != 1) {
    throw StateError('${task.id}: incomplete decision projection');
  }
  return {
    'id': task.id,
    'position': [
      position,
      part('Decision ').isEmpty ? position : part('Decision '),
    ],
    'price': call,
    'decisionPotBb': pot,
    'thresholdBucket': call == 0
        ? ['no_call']
        : ['authored_call_threshold', transferPriceBucketV2(pot, call)],
    'handBucket': bucket,
    'actionSet': task.choices,
    'answer': task.correct,
    'spot': jsonEncode([
      parts.first,
      position,
      part('Facts '),
      signal,
      pot,
      jsonDecode(decisionInput),
    ]),
    'cosmetics': jsonEncode([cards, part('Board ')]),
  };
}

List<Map<String, dynamic>> b153NoveltyPairs(
  Map<String, B153SnapshotTask> tasks,
) => [
  for (final entry in b153Witnesses.entries)
    {
      'world': tasks[entry.key]!.world,
      'kind': 'authored_b153',
      'source': b153Spot(
        tasks[entry.key]!,
        entry.value.$2,
        entry.value.$4,
        entry.value.$5,
      ),
      'repeat': b153Spot(
        tasks[entry.value.$1]!,
        entry.value.$3,
        entry.value.$4,
        entry.value.$6,
      ),
    },
];

// Pure Dart entry point for sandbox evidence, shared with the adjudication test.
void main(List<String> args) {
  if (args.length != 1) throw ArgumentError('Expected an output JSON path');
  final pairs = b153NoveltyPairs(readB153Snapshot());
  for (final pair in pairs) {
    final result = classifyTransferPairV2(pair['source'], pair['repeat']);
    if (result.exactReplay ||
        result.result.classification != TransferNoveltyV1.changedDecision) {
      throw StateError('${pair['source']['id']}: ${result.result}');
    }
  }
  File(args.single).writeAsStringSync(jsonEncode({'pairs': pairs}));
  stdout.writeln(
    'B153 G1 projection: ${pairs.length} changed decisions; 0 exact; 0 unknown',
  );
}
