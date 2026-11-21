// Exact additions and incorrect-grade corrections admitted for W11.
const w11Wave4ChoiceContractV1 = <String, (String, List<List<Object?>>)>{
  'w11_plan_hj_open': (
    'session_plan_basics',
    [
      ['fold', 'Fold', false, 'wrong', 'Raise to 2.5 BB'],
      ['raise', 'Raise to 2.5 BB', true, 'correct', 'Raise to 2.5 BB'],
      ['limp', 'Limp for 1 BB', false, 'wrong', 'Raise to 2.5 BB'],
    ],
  ),
  'w11_bankroll_set_limit': (
    'session_plan_basics',
    [
      ['choice_1', '5 chips', false, 'wrong', '10 chips'],
      ['choice_2', '10 chips', true, 'correct', '10 chips'],
      ['choice_3', '20 chips', false, 'wrong', '10 chips'],
    ],
  ),
  'w11_bankroll_move_down': (
    'session_plan_basics',
    [
      ['choice_1', '12 chips', true, 'correct', '12 chips'],
      ['choice_2', '15 chips', false, 'wrong', '12 chips'],
      ['choice_3', '24 chips', false, 'wrong', '12 chips'],
    ],
  ),
  'w11_sb_ajo_vs_btn': (
    'table_trigger_reads',
    [
      ['fold', 'Fold', false, 'wrong', 'Raise to 9 BB'],
      ['call', 'Call', false, 'wrong', 'Raise to 9 BB'],
      ['raise', 'Raise to 9 BB', true, 'correct', 'Raise to 9 BB'],
    ],
  ),
  'w11_sb_kjo_vs_btn': (
    'table_trigger_reads',
    [
      ['fold', 'Fold', true, 'correct', 'Fold'],
      ['call', 'Call', false, 'wrong', 'Fold'],
      ['raise', 'Raise to 9 BB', false, 'wrong', 'Fold'],
    ],
  ),
  'w11_bb_72o_vs_hj': (
    'table_trigger_reads',
    [
      ['fold', 'Fold', true, 'correct', 'Fold'],
      ['call', 'Call', false, 'wrong', 'Fold'],
      ['raise', 'Raise', false, 'wrong', 'Fold'],
    ],
  ),
  'w11_multiway_turn_fold': (
    'post_session_review_loop',
    [
      ['fold', 'Fold', true, 'correct', 'Fold'],
      ['call', 'Call', false, 'wrong', 'Fold'],
      ['raise', 'Raise', false, 'wrong', 'Fold'],
    ],
  ),
  'w11_checkpoint_short_spr': (
    'post_session_review_loop',
    [
      ['pot', 'The pot', false, 'wrong', 'Your stack'],
      ['short', 'Your stack', true, 'correct', 'Your stack'],
      ['deep', 'CO’s stack', false, 'wrong', 'Your stack'],
    ],
  ),
  'w11_multiway_first_seat': (
    'real_play_transfer_checkpoint',
    [
      ['co', 'CO', false, 'wrong', 'BB'],
      ['bb', 'BB', true, 'correct', 'BB'],
      ['btn', 'BTN', false, 'wrong', 'BB'],
    ],
  ),
  'w11_checkpoint_spr': (
    'real_play_transfer_checkpoint',
    [
      ['choice_1', '3', false, 'wrong', '6'],
      ['choice_2', '6', true, 'correct', '6'],
      ['choice_3', '12', false, 'wrong', '6'],
    ],
  ),
  'w11_checkpoint_turn_price': (
    'real_play_transfer_checkpoint',
    [
      ['fold', 'Fold', false, 'wrong', 'Call'],
      ['call', 'Call', true, 'correct', 'Call'],
      ['raise', 'Raise', false, 'wrong', 'Call'],
    ],
  ),
  'w11_checkpoint_multiway_value': (
    'real_play_transfer_checkpoint',
    [
      ['fold', 'Fold', false, 'wrong', 'Raise'],
      ['call', 'Call', false, 'wrong', 'Raise'],
      ['raise', 'Raise', true, 'correct', 'Raise'],
    ],
  ),
};

const w11Wave4GradeCorrectionsV1 = <String, String>{
  'w11_plan_avoid_overload': 'repeat_none',
  'w11_plan_table_focus_transfer': 'no_focus_until_review',
  'w11_trigger_overcall_flop': 'no_change',
  'w11_trigger_bad_price_fold': 'call_top_pair',
  'w11_review_pick_leak': 'skip_review',
  'w11_review_define_fix': 'no_fix',
  'w11_checkpoint_plan_line': 'no_objective',
  'w11_checkpoint_review_line': 'skip_closeout',
  'w11_checkpoint_review': 'content_only',
};

const w11Wave4ConceptTasksV1 = <String>{
  'w11_bankroll_set_limit',
  'w11_bankroll_move_down',
};

const w11Wave4ReplayTasksV1 = <String>{
  'w11_plan_hj_open',
  'w11_sb_ajo_vs_btn',
  'w11_sb_kjo_vs_btn',
  'w11_bb_72o_vs_hj',
  'w11_multiway_turn_fold',
  'w11_checkpoint_turn_price',
  'w11_checkpoint_multiway_value',
};

Map<String, Object?> w11Wave4TableTruthContractV1() => {
  for (final entry in w11Wave4ChoiceContractV1.entries)
    entry.key: {
      'rewardXp': 10,
      'family': 'decision',
      'options': [
        for (final [id, _, correct, quality, _] in entry.value.$2)
          {
            'id': id,
            'correct': correct,
            'quality': quality,
            'seat': entry.key == 'w11_multiway_first_seat' ? id : null,
            'repairSeats': const [],
            'repairCards': const [],
            'repairLabels': const [],
          },
      ],
    },
};
