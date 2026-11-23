bool act0IsNumberEntryChoiceV1(String? id) =>
    id?.startsWith('number_entry:') ?? false;

enum Act0NumberFormV1 {
  bigBlinds('BB', 'big blinds'),
  percent('%', 'percent'),
  fraction('Fraction', 'fraction'),
  oneIn('1 in N', 'one in N');

  const Act0NumberFormV1(this.label, this.spokenLabel);

  final String label;
  final String spokenLabel;
}

enum Act0NumberGradeV1 { correct, acceptable, mistake }

class Act0NumberEntryV1 {
  const Act0NumberEntryV1({
    required this.answer,
    required this.forms,
    required this.exactTolerance,
    required this.acceptableTolerance,
  });

  // Threshold answers and tolerances are in percentage points.
  final double answer;
  final List<Act0NumberFormV1> forms;
  final double exactTolerance;
  final double acceptableTolerance;

  bool get isPrice => forms.first == Act0NumberFormV1.bigBlinds;

  String get question => isPrice
      ? 'How much more must you put in to call?'
      : 'What winning chance breaks even if you call, with no ties or further bets?';

  double? parse(String input, Act0NumberFormV1 form) {
    if (!forms.contains(form) || input.length > 24) return null;
    final raw = input.trim().toLowerCase();
    final match = switch (form) {
      Act0NumberFormV1.bigBlinds => _bb.firstMatch(raw),
      Act0NumberFormV1.percent => _percent.firstMatch(raw),
      Act0NumberFormV1.fraction => _fraction.firstMatch(raw),
      Act0NumberFormV1.oneIn => _oneIn.firstMatch(raw),
    };
    if (match == null) return null;
    final first = double.parse(match[1]!);
    final value = switch (form) {
      Act0NumberFormV1.bigBlinds || Act0NumberFormV1.percent => first,
      Act0NumberFormV1.fraction => 100 * first / double.parse(match[2]!),
      Act0NumberFormV1.oneIn => 100 / first,
    };
    return value.isFinite ? value : null;
  }

  Act0NumberGradeV1 grade(double value) {
    final difference = (value - answer).abs();
    const roundingEpsilon = 1e-9;
    if (difference <= exactTolerance + roundingEpsilon) {
      return Act0NumberGradeV1.correct;
    }
    if (difference <= acceptableTolerance + roundingEpsilon) {
      return Act0NumberGradeV1.acceptable;
    }
    return Act0NumberGradeV1.mistake;
  }

  String formatInput(String input, Act0NumberFormV1 form) => switch (form) {
    Act0NumberFormV1.bigBlinds => '$input BB',
    Act0NumberFormV1.percent => '$input%',
    Act0NumberFormV1.fraction => input,
    Act0NumberFormV1.oneIn => '1 in $input',
  };

  static const _decimal = r'(\d+(?:\.\d+)?|\.\d+)';
  static final _bb = RegExp('^$_decimal(?:\\s*bb)?\$');
  static final _percent = RegExp('^$_decimal(?:\\s*%)?\$');
  static final _fraction = RegExp('^$_decimal\\s*/\\s*$_decimal\$');
  static final _oneIn = RegExp('^(?:1\\s+in\\s+)?$_decimal\$');
}

const _thresholdForms = [
  Act0NumberFormV1.percent,
  Act0NumberFormV1.fraction,
  Act0NumberFormV1.oneIn,
];

const act0W4NumberEntriesV1 = <String, Act0NumberEntryV1>{
  'w4_good_price_call': Act0NumberEntryV1(
    answer: 100 / 9,
    forms: _thresholdForms,
    exactTolerance: .005,
    acceptableTolerance: 1,
  ),
  'w4_bad_price_fold': Act0NumberEntryV1(
    answer: 100 / 3,
    forms: _thresholdForms,
    exactTolerance: .005,
    acceptableTolerance: 1,
  ),
  'w4_cheap_price_marginal_call': Act0NumberEntryV1(
    answer: 100 / 11,
    forms: _thresholdForms,
    exactTolerance: .005,
    acceptableTolerance: 1,
  ),
  'w4_big_price_marginal_fold': Act0NumberEntryV1(
    answer: 600 / 19,
    forms: _thresholdForms,
    exactTolerance: .005,
    acceptableTolerance: 1,
  ),
  'w4_protection_short_shove_price': Act0NumberEntryV1(
    answer: 100 / 3,
    forms: _thresholdForms,
    exactTolerance: .005,
    acceptableTolerance: 1,
  ),
  'w4_checkpoint_price': Act0NumberEntryV1(
    answer: 300 / 13,
    forms: _thresholdForms,
    exactTolerance: .005,
    acceptableTolerance: 1,
  ),
  'w4_checkpoint_table_price': Act0NumberEntryV1(
    answer: 2,
    forms: [Act0NumberFormV1.bigBlinds],
    exactTolerance: 0,
    acceptableTolerance: .1,
  ),
  'w4_checkpoint_table_purpose_price': Act0NumberEntryV1(
    answer: 2,
    forms: [Act0NumberFormV1.bigBlinds],
    exactTolerance: 0,
    acceptableTolerance: .1,
  ),
};
