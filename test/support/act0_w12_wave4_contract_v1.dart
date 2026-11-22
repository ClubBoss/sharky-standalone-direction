// Exact additions and incorrect-grade corrections admitted for W12.
const w12Wave4ChoiceContractV1 = <String, (String, List<List<Object?>>)>{
  'w12_river_price_call': (
    'decision_over_outcome',
    [
      ['call_10_bb', 'Call 10 BB', true, 'correct', 'Call 10 BB'],
      ['fold', 'Fold', false, 'wrong', 'Call 10 BB'],
      ['raise_to_35_bb', 'Raise to 35 BB', false, 'wrong', 'Call 10 BB'],
    ],
  ),
  'w12_river_ev_costly_call': (
    'decision_over_outcome',
    [
      ['fold', 'Fold', true, 'correct', 'Fold'],
      ['call', 'Call', false, 'wrong', 'Fold'],
      ['raise', 'Raise', false, 'wrong', 'Fold'],
    ],
  ),
  'w12_turn_count_heart_outs': (
    'decision_over_outcome',
    [
      ['choice_1', '7', false, 'wrong', '9'],
      ['choice_2', '9', true, 'correct', '9'],
      ['choice_3', '11', false, 'wrong', '9'],
    ],
  ),
  'w12_tilt_after_lucky_win': (
    'tilt_reset_protocol',
    [
      ['fold', 'Fold', true, 'correct', 'Fold'],
      ['call', 'Call', false, 'wrong', 'Fold'],
      ['raise', 'Raise', false, 'wrong', 'Fold'],
    ],
  ),
  'w12_tilt_after_river_beat': (
    'tilt_reset_protocol',
    [
      [
        'speed',
        'Speed up so you do not freeze',
        false,
        'wrong',
        'Take one breath and read the new hand',
      ],
      [
        'pause',
        'Take one breath and read the new hand',
        true,
        'correct',
        'Take one breath and read the new hand',
      ],
      [
        'target',
        'Focus on bets from CO for this orbit',
        false,
        'wrong',
        'Take one breath and read the new hand',
      ],
    ],
  ),
  'w12_confidence_spr': (
    'confidence_and_discipline',
    [
      ['choice_1', '3', true, 'correct', '3'],
      ['choice_2', '6', false, 'wrong', '3'],
      ['choice_3', '9', false, 'wrong', '3'],
    ],
  ),
  'w12_river_ev_turn_draw_miss': (
    'confidence_and_discipline',
    [
      ['fold', 'Fold', true, 'correct', 'Fold'],
      ['call', 'Call', false, 'wrong', 'Fold'],
      ['raise', 'Raise', false, 'wrong', 'Fold'],
    ],
  ),
  'w12_river_ev_draw_hit': (
    'mindset_bridge_checkpoint',
    [
      ['fold', 'Fold', false, 'wrong', 'Raise'],
      ['call', 'Call', false, 'wrong', 'Raise'],
      ['raise', 'Raise', true, 'correct', 'Raise'],
    ],
  ),
  'w12_river_ev_new_sample': (
    'mindset_bridge_checkpoint',
    [
      ['fold', 'Fold', false, 'wrong', 'Call'],
      ['call', 'Call', true, 'correct', 'Call'],
      ['raise', 'Raise', false, 'wrong', 'Call'],
    ],
  ),
};

const w12Wave4GradeCorrectionsV1 = <String, String>{
  'w12_bad_call_good_result': 'self_blame',
  'w12_after_mistake_reset': 'deny_mistake',
  'w12_assertive_not_ego': 'play_scared',
  'w12_pretty_hand_bad_price_fold': 'hero_call',
  'w12_revenge_raise_trap': 'snap_fold_noise',
  'w12_checkpoint_process_line': 'avoid_review',
  'w12_checkpoint_reset_line': 'deny_tilt',
  'w12_checkpoint_discipline_line': 'fear_line',
  'w12_checkpoint_full_loop_line': 'fold_scared',
};

const w12Wave4ReplayTasksV1 = <String>{
  'w12_river_price_call',
  'w12_river_ev_costly_call',
  'w12_tilt_after_lucky_win',
  'w12_tilt_after_river_beat',
  'w12_river_ev_turn_draw_miss',
  'w12_river_ev_draw_hit',
  'w12_river_ev_new_sample',
};

Map<String, Object?> w12Wave4TableTruthContractV1() => {
  for (final entry in w12Wave4ChoiceContractV1.entries)
    entry.key: {
      'rewardXp': 10,
      'family': 'decision',
      'options': [
        for (final [id, _, correct, quality, _] in entry.value.$2)
          {
            'id': id,
            'correct': correct,
            'quality': quality,
            'seat': null,
            'repairSeats': const [],
            'repairCards': const [],
            'repairLabels': const [],
          },
      ],
    },
};
