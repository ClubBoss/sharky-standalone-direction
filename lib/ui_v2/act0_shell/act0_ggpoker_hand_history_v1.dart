part of 'act0_imported_hand_v1.dart';

final _ggHeaderPrefix = RegExp(r'^Poker Hand #');
final _ggHeader = RegExp(
  r"^Poker Hand #HD([1-9]\d{0,19}): Hold'em No Limit \(" +
      _money +
      '/' +
      _money +
      r'(?: USD)?\) - (.+)$',
);
final _ggTotal = RegExp(
  r'^Total pot ' +
      _money +
      r' \| Rake ' +
      _money +
      r'(?: \| Jackpot \$0(?:\.0{1,2})? \| Bingo \$0(?:\.0{1,2})?'
          r' \| Fortune \$0(?:\.0{1,2})? \| Tax \$0(?:\.0{1,2})?)?$',
);
final _ggSummaryCollection = RegExp(r'^won \(' + _money + r'\)$');
final _ggInsurance = RegExp(
  r'\ball[ -]in (?:insurance|cashout)\b',
  caseSensitive: false,
);

class _GGPokerParser extends _SinglePotCashParser {
  _GGPokerParser(super.text);

  @override
  String get room => 'ggpoker';

  @override
  String get showdownMarker => '*** SHOWDOWN ***';

  @override
  bool get allowsFoldOutMarker => true;

  @override
  RegExp get totalPattern => _ggTotal;

  @override
  RegExp get summaryCollection => _ggSummaryCollection;

  @override
  RegExpMatch readHeader() {
    final header = _ggHeader.firstMatch(_line);
    if (header == null) {
      _unsupported('Expected a GGPoker USD NLHE cash header.');
    }
    final summary = _lines.indexWhere((line) => line.text == '*** SUMMARY ***');
    for (final (index, line) in _lines.indexed) {
      if (_ggInsurance.hasMatch(line.text)) {
        _unsupported(
          'All-in insurance and cashout are unsupported.',
          line.number,
        );
      }
      if (index == summary + 1 &&
          summary >= 0 &&
          line.text.contains(' | Jackpot ') &&
          _ggTotal.firstMatch(line.text) == null) {
        _unsupported('Additional pot deductions are unsupported.', line.number);
      }
    }
    if (summary < 0) _unsupported('Missing hand summary.');
    return header;
  }

  @override
  String readTimestamp(String value) {
    if (!_validSourceTime(value)) _fail();
    return value;
  }

  Never _unsupported(String reason, [int? line]) =>
      throw Act0HandImportExceptionV1(
        Act0HandImportErrorV1.unsupportedFormat,
        line: line ?? _lines.firstOrNull?.number,
        reason: reason,
      );
}
