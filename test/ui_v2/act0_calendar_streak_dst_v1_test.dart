import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

void main() {
  test('consecutive civil dates survive spring daylight saving jump', () {
    // New York clocks advance on Mar 8, 2026: 23 elapsed hours
    // separate Mar 8 and Mar 9 local midnights.
    expect(act0AreConsecutiveCivilDaysV1('2026-03-08', '2026-03-09'), isTrue);
    // Most of Europe moves forward on Mar 29, 2026.
    expect(act0AreConsecutiveCivilDaysV1('2026-03-29', '2026-03-30'), isTrue);
  });

  test('regular year boundaries and leap-day runs remain consecutive', () {
    expect(act0AreConsecutiveCivilDaysV1('2026-12-31', '2027-01-01'), isTrue);
    expect(act0AreConsecutiveCivilDaysV1('2028-02-28', '2028-02-29'), isTrue);
    expect(act0AreConsecutiveCivilDaysV1('2028-02-29', '2028-03-01'), isTrue);
  });

  test('same, skipped, backward or missing dates cannot continue streak', () {
    expect(act0AreConsecutiveCivilDaysV1('2026-03-08', '2026-03-08'), isFalse);
    expect(act0AreConsecutiveCivilDaysV1('2026-03-08', '2026-03-10'), isFalse);
    expect(act0AreConsecutiveCivilDaysV1('2026-03-10', '2026-03-09'), isFalse);
    expect(act0AreConsecutiveCivilDaysV1('', '2026-03-09'), isFalse);
    expect(act0AreConsecutiveCivilDaysV1('not-a-day', '2026-03-09'), isFalse);
  });
}
