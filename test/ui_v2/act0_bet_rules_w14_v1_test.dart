import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Bet and stack rules across the whole W1–W12 route (PKR-02.a, PKR-06.a):
// a call matches the price, a raise is at least a min-raise, a bet is at least
// one big blind, nobody puts in more than their stack, and when every seat
// started with 100 BB the chips on the table add up to 600 BB.
double? _bb(String? s) {
  if (s == null) return null;
  final m = RegExp(r'([\d.]+)\s*BB').firstMatch(s);
  return m == null ? null : double.parse(m[1]!);
}

void main() {
  test('W1–W12 bet sizes and stacks follow the rules', () {
    final problems = <String>[];
    var amounts = 0;
    var conserved = 0;
    for (final w in Act0ShellStateV1.sample.worlds) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          final table = t.runner.table;
          final call = _bb(table.toCallLabel) ?? 0;
          final bets = [
            for (final s in table.seats) _bb(s.currentBetLabel) ?? 0,
          ];
          final maxBet = bets.isEmpty
              ? 0.0
              : bets.reduce((a, b) => a > b ? a : b);
          final hero = table.seats.where((s) => s.isHero).toList();
          final heroStack = hero.isEmpty ? null : _bb(hero.first.stackLabel);
          final heroBet = hero.isEmpty
              ? 0.0
              : _bb(hero.first.currentBetLabel) ?? 0;
          for (final o in t.runner.options) {
            final amount = _bb(o.amountLabel);
            if (amount == null) continue;
            amounts++;
            final label = o.label.toLowerCase();
            final allIn = label.contains('all');
            if (label.startsWith('call') &&
                call > 0 &&
                amount != call &&
                amount != maxBet) {
              problems.add(
                '${t.taskId}/${o.id}: call ${o.amountLabel} vs ${table.toCallLabel}',
              );
            }
            if (label.startsWith('raise') && !allIn && amount < 2 * maxBet) {
              problems.add(
                '${t.taskId}/${o.id}: raise ${o.amountLabel} below min-raise over $maxBet BB',
              );
            }
            if (label.startsWith('bet') && amount < 1) {
              problems.add(
                '${t.taskId}/${o.id}: bet ${o.amountLabel} below 1 BB',
              );
            }
            if (heroStack != null && !allIn && amount - heroBet > heroStack) {
              problems.add(
                '${t.taskId}/${o.id}: ${o.amountLabel} exceeds stack ${hero.first.stackLabel}',
              );
            }
          }
          final stacks = [for (final s in table.seats) _bb(s.stackLabel)];
          final pot = _bb(table.potLabel);
          // W1's fully authored decision frames start with 100 BB per seat.
          // Their teaching captions no longer repeat the starting stacks.
          final hasUniformStartingStacks =
              (w.worldNumber == 1 && table.decisionSeatId != null) ||
              t.runner.caption.contains('100 BB');
          if (hasUniformStartingStacks &&
              stacks.length == 6 &&
              !stacks.contains(null) &&
              pot != null) {
            final ledger = table.handContributions;
            // A caption may give the stack at a later street. When source
            // records all six starting stacks, use their actual sum.
            final starting = ledger?.startingStackBbBySeat;
            final expected =
                starting != null &&
                    table.seats.every(
                      (seat) => starting.containsKey(seat.seatId),
                    )
                ? table.seats.fold<double>(
                    0,
                    (sum, seat) => sum + starting[seat.seatId]!,
                  )
                : 600.0;
            final onTable = stacks.fold<double>(0, (a, b) => a + b!) + pot;
            final withBets = onTable + bets.fold<double>(0, (a, b) => a + b);
            if ((onTable - expected).abs() > 1e-6 &&
                (withBets - expected).abs() > 1e-6) {
              problems.add(
                '${t.taskId}: chips add up to $onTable/$withBets, expected $expected BB',
              );
            } else {
              conserved++;
            }
          }
        }
      }
    }
    expect(amounts, greaterThan(50), reason: 'the check must see bet options');
    expect(
      conserved,
      greaterThan(10),
      reason: 'the check must see full stacks',
    );
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
