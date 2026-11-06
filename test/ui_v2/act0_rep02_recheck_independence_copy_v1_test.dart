import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

/// REP-02 / REP-03 falsifier from the exact native candidate (3c83f85d,
/// EN iPhone 14 Pro): the repair practice intro read
/// "Same idea, new frame. You chose Fold. Better: Check." and the table callout
/// "Repair: Fold misses this. Better: Check.", yet the next answer was recorded
/// with assistance_kind none and closed the repair as independent.
void main() {
  const better = 'Check';
  const selected = 'Fold';

  test('repair practice intro never names the better action', () {
    for (final sameTask in [true, false]) {
      final body = act0RepairPracticeIntroBodyV1(
        selectedLabel: selected,
        sameTask: sameTask,
      );
      expect(body, contains('You chose $selected'));
      expect(body, isNot(contains(better)));
      expect(body.toLowerCase(), isNot(contains('better')));
      expect(body, contains('clue'));
    }
  });

  test('repair focus callout on the table never names the better action', () {
    final callout = act0RepairFocusCalloutV1(selectedLabel: selected);
    expect(callout, contains(selected));
    expect(callout, isNot(contains(better)));
    expect(callout.toLowerCase(), isNot(contains('better')));
  });
}
