// Runtime proof for the vendored poker_solver ranking fix (issue #334).
// Mounts the real Act0 lesson runner, taps the board at decision time and
// reads which cards the runner's showdown insight highlights. In
// hand_rankings_full_house_vs_flush_drill Hero's A♠7♠ makes aces full of
// sevens on A♥A♦7♥2♥2♣ and beats CO's ace-high flush, so the lit board must be
// A♥A♦7♥ (board_0..2), never the flush-only 2♥ (board_3), and CO stays dark.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ui_v2/act0_teaching_integrity_harness_v1.dart';

Set<String> _highlightedCardIds() => find
    .byWidgetPredicate((widget) {
      try {
        final dynamic card = widget;
        return card.highlighted == true && card.cardId is String;
      } catch (_) {
        return false;
      }
    }, skipOffstage: false)
    .evaluate()
    .map((element) => (element.widget as dynamic).cardId as String)
    .toSet();

void main() {
  testWidgets('board tap highlights the full house, not the losing flush', (
    tester,
  ) async {
    final ref = act0TeachingTaskByIdV1(
      'hand_rankings_full_house_vs_flush_drill',
    );
    await act0PumpTeachingHarnessV1(tester, ref);
    for (
      var i = 0;
      i < 12 && act0TeachingContinueFinderV1.evaluate().isNotEmpty;
      i++
    ) {
      await act0TapTeachingContinueV1(tester);
      await act0SettleTeachingV1(tester);
    }

    final board = find.byKey(const Key('act0_shell_card_board_0'));
    expect(board, findsWidgets);
    await tester.tap(board.first, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The runner's tap insight lights board cards; Hero's hole cards keep
    // their authored highlight, so only the board set proves the winner.
    final litBoard = _highlightedCardIds().where(
      (id) => id.startsWith('board_'),
    );
    expect(litBoard.toSet(), <String>{'board_0', 'board_1', 'board_2'});
    expect(_highlightedCardIds(), isNot(contains('co_0')));
    expect(_highlightedCardIds(), isNot(contains('co_1')));
  });
}
