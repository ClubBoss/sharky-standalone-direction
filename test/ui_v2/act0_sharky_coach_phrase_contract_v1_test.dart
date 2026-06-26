import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';

void main() {
  test('Sharky coach phrase contract is short ascii and claim-safe', () {
    final moments = Act0SharkyCoachMomentV1.values;
    expect(moments, isNotEmpty);

    final seen = <String>{};
    for (final moment in moments) {
      final line = act0SharkyCoachLineForMomentV1(moment);
      expect(line, isNotEmpty);
      expect(line.length, lessThanOrEqualTo(58));
      expect(RegExp(r'^[\x00-\x7F]+$').hasMatch(line), isTrue);
      expect(seen.add(line), isTrue);

      final lower = line.toLowerCase();
      for (final forbidden in <String>[
        'ai',
        'gto',
        'solver',
        'master',
        'fixed forever',
        'cleared',
        'resolved',
        'recovered',
        'all-time',
        'rating',
        'radar',
        'level',
        'premium',
        'guaranteed',
      ]) {
        expect(lower, isNot(contains(forbidden)));
      }
    }
  });
}
