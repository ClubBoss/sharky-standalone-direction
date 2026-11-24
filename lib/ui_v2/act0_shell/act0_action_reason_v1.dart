enum Act0ReasonGradeV1 { sound, partial, wrong }

enum Act0MisconceptionTagV1 {
  price,
  range,
  bluffPurpose,
  effectiveDepth;

  String get label => switch (this) {
    price => 'Call price',
    range => 'Range after visible cards',
    bluffPurpose => 'Fold equity',
    effectiveDepth => 'Effective stack and payoff',
  };

  String get repair => switch (this) {
    price =>
      'Divide the call by the pot after calling. Compare that threshold with your chance to win before you pick an action.',
    range =>
      'Cross out hands that use a visible card. Count which remaining hands you beat, then compare your winning share with the call price.',
    bluffPurpose =>
      'Compare a free card with betting. Count both how often a bet wins immediately and what happens when it gets called.',
    effectiveDepth =>
      'Cap any future payment at the opponent’s remaining stack. Compare what you gain on a hit with what you lose on a miss.',
  };
}

class Act0ReasonV1 {
  const Act0ReasonV1(this.text, this.grade, this.tag);

  final String text;
  final Act0ReasonGradeV1 grade;
  final Act0MisconceptionTagV1 tag;

  bool get isSound => grade == Act0ReasonGradeV1.sound;
}

class Act0ActionReasonResultV1 {
  const Act0ActionReasonResultV1(this.actionCorrect, this.reason);

  final bool actionCorrect;
  final Act0ReasonV1 reason;

  bool get needsRepair => actionCorrect && !reason.isSound;

  String get title => switch ((actionCorrect, reason.isSound)) {
    (true, true) => 'Right move and sound reasoning',
    (true, false) => 'Right move, but not for that reason',
    (false, true) => 'Sound reasoning, wrong move',
    (false, false) => 'Revisit the move and the reason',
  };

  Map<String, Object?> toPayload() => {
    'actionCorrect': actionCorrect,
    'reason': reason.text,
    'reasonGrade': reason.grade.name,
    'misconceptionTag': reason.tag.name,
  };

  static Act0ActionReasonResultV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final actionCorrect = raw['actionCorrect'];
    final reason = raw['reason'];
    final grade = Act0ReasonGradeV1.values
        .where((value) => value.name == raw['reasonGrade'])
        .firstOrNull;
    final tag = Act0MisconceptionTagV1.values
        .where((value) => value.name == raw['misconceptionTag'])
        .firstOrNull;
    if (actionCorrect is! bool ||
        reason is! String ||
        reason.trim().isEmpty ||
        grade == null ||
        tag == null)
      return null;
    return Act0ActionReasonResultV1(
      actionCorrect,
      Act0ReasonV1(reason, grade, tag),
    );
  }
}

class Act0ActionReasonPilotV1 {
  const Act0ActionReasonPilotV1(this.retestTaskId, this.reasons);

  final String retestTaskId;
  final List<Act0ReasonV1> reasons;
}

const _sound = Act0ReasonGradeV1.sound;
const _partial = Act0ReasonGradeV1.partial;
const _wrong = Act0ReasonGradeV1.wrong;
const _price = Act0MisconceptionTagV1.price;
const _folds = Act0MisconceptionTagV1.bluffPurpose;
const _range = Act0MisconceptionTagV1.range;
const _depth = Act0MisconceptionTagV1.effectiveDepth;

const act0ActionReasonPilotsV1 = <String, Act0ActionReasonPilotV1>{
  'w4_good_price_call': Act0ActionReasonPilotV1('w4_bad_price_fold', [
    Act0ReasonV1(
      'A pair of tens is strong enough to continue.',
      _wrong,
      _price,
    ),
    Act0ReasonV1('25% beats the 11.1% needed to call.', _sound, _price),
    Act0ReasonV1('Calling costs only 1 BB.', _partial, _price),
  ]),
  'w4_bad_price_fold': Act0ActionReasonPilotV1('w4_cheap_price_marginal_call', [
    Act0ReasonV1('25% falls below the 33.3% needed to call.', _sound, _price),
    Act0ReasonV1('A pair of eights can never call here.', _wrong, _price),
    Act0ReasonV1('Calling costs 7 BB.', _partial, _price),
  ]),
  'w4_cheap_price_marginal_call':
      Act0ActionReasonPilotV1('w4_big_price_marginal_fold', [
        Act0ReasonV1('The bet is small.', _partial, _price),
        Act0ReasonV1(
          'Middle pair should always continue against a small bet.',
          _wrong,
          _price,
        ),
        Act0ReasonV1('15% beats the 9.1% needed to call.', _sound, _price),
      ]),
  'flush_draw': Act0ActionReasonPilotV1('combo_draw', [
    Act0ReasonV1('A flush draw should always bet big.', _wrong, _folds),
    Act0ReasonV1(
      'The larger bet gains enough from folds plus nine winning rivers to beat checking.',
      _sound,
      _folds,
    ),
    Act0ReasonV1(
      'The larger bet sometimes wins immediately.',
      _partial,
      _folds,
    ),
  ]),
  'combo_draw': Act0ActionReasonPilotV1('flush_draw', [
    Act0ReasonV1(
      'Twelve winning rivers and too few folds to 3 BB make checking worth more.',
      _sound,
      _folds,
    ),
    Act0ReasonV1('Checking lets me see a free river.', _partial, _folds),
    Act0ReasonV1(
      'Draws should always check when offered a free card.',
      _wrong,
      _folds,
    ),
  ]),
  'w6_check_line_call': Act0ActionReasonPilotV1('w6_check_line_fold', [
    Act0ReasonV1('Checking first commits me to calling.', _wrong, _price),
    Act0ReasonV1('A call costs 2 BB.', _partial, _price),
    Act0ReasonV1(
      '30% beats the 20% call price, and a raise loses when called in this model.',
      _sound,
      _price,
    ),
  ]),
  'w6_check_line_fold': Act0ActionReasonPilotV1('w6_check_line_call', [
    Act0ReasonV1(
      '20% falls below the roughly 29% needed to call.',
      _sound,
      _price,
    ),
    Act0ReasonV1('A check means I should give up to any bet.', _wrong, _price),
    Act0ReasonV1('The opponent bet 4 BB.', _partial, _price),
  ]),
  'w7_river_one_bluff_of_six':
      Act0ActionReasonPilotV1('w7_river_two_bluffs_of_six', [
        Act0ReasonV1('My queen-jack beats jack-ten.', _partial, _range),
        Act0ReasonV1(
          'One win in six falls below the 25% call price.',
          _sound,
          _range,
        ),
        Act0ReasonV1('An all-in bettor never bluffs.', _wrong, _range),
      ]),
  'w7_river_two_bluffs_of_six': Act0ActionReasonPilotV1(
    'w7_river_one_bluff_of_six',
    [
      Act0ReasonV1('Two wins in six beat the 25% call price.', _sound, _range),
      Act0ReasonV1(
        'Any bluff in the range makes calling profitable.',
        _wrong,
        _range,
      ),
      Act0ReasonV1('I beat jack-ten and ace-eight.', _partial, _range),
    ],
  ),
  'w7_read_visible_card_call': Act0ActionReasonPilotV1(
    'w7_checkpoint_river_card_excludes_hand',
    [
      Act0ReasonV1(
        'Any river ace removes all the stronger hands.',
        _wrong,
        _range,
      ),
      Act0ReasonV1(
        'The ace of clubs rules out the listed ace-queen.',
        _partial,
        _range,
      ),
      Act0ReasonV1(
        'After removing ace-queen, two wins in three beat the 25% call price.',
        _sound,
        _range,
      ),
    ],
  ),
  'draw_deep': Act0ActionReasonPilotV1('draw_shallow', [
    Act0ReasonV1('The bettor has a deep stack.', _partial, _depth),
    Act0ReasonV1(
      'Nine winning rivers are enough at the direct 25% price.',
      _wrong,
      _depth,
    ),
    Act0ReasonV1(
      'The extra 6 BB on a hit makes up for falling short of the direct price.',
      _sound,
      _depth,
    ),
  ]),
  'draw_shallow': Act0ActionReasonPilotV1('draw_deep', [
    Act0ReasonV1(
      'Only 3 BB more can be won on a hit, which leaves calling unprofitable.',
      _sound,
      _depth,
    ),
    Act0ReasonV1('A flush draw can never call a turn bet.', _wrong, _depth),
    Act0ReasonV1('The bettor has only 3 BB left.', _partial, _depth),
  ]),
};

String act0ReasonErrorTypeV1(Act0MisconceptionTagV1 tag) =>
    'reason_${tag.name}';

bool act0IsReasonErrorTypeV1(String errorType) => Act0MisconceptionTagV1.values
    .any((tag) => act0ReasonErrorTypeV1(tag) == errorType);

const act0ReasonRetestFamilyPrefixV1 = 'action_reason:';
