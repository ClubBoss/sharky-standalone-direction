const cur04bSummaryLessonIdV1 = 'w10_w12_summary_block';

const cur04bSummaryChoicesV1 = <String, List<(String, String, bool)>>{
  'w12_cur04b_call_after_loss': [
    ('fold', 'Fold because the last call lost', false),
    ('call_4_bb', 'Call 4 BB', true),
  ],
  'w12_cur04b_ignore_one_show': [
    ('call_6_bb', 'Call 6 BB because BB showed a bluff', false),
    ('fold', 'Fold at the current price', true),
  ],
  'w12_cur04b_both_opponents': [
    ('fold', 'Fold', true),
    ('call_3_bb', 'Call 3 BB', false),
  ],
  'w12_cur04b_log_price_not_result': [
    (
      'call_log_price_range',
      'Call and log the seat, price and hands you beat',
      true,
    ),
    ('call_log_result', 'Call and log only whether you won', false),
    ('fold_log_last_loss', 'Fold and log the last loss', false),
  ],
  'w12_cur04b_small_steal_reset': [
    ('raise_to_5_bb', 'Raise to 5 BB', false),
    ('fold', 'Fold', false),
    ('raise_to_2_bb', 'Raise to 2 BB', true),
  ],
  'w12_cur04b_stack_capped_value': [
    ('check', 'Check', false),
    ('bet_10_bb', 'Bet 10 BB', false),
    ('bet_3_bb', 'Bet 3 BB', true),
  ],
  'w12_cur04b_two_ranges_one_call': [
    ('call_vs_both', 'Call using the chance of beating both', true),
    (
      'call_vs_co_only',
      'Call because you beat three of CO’s four hands',
      false,
    ),
    ('fold_multiway', 'Fold because two opponents stayed in', false),
  ],
};
