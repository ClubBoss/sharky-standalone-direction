import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_reasoning_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_decision_v1.dart';
import 'act0_catalog_snapshot_v1.dart';
import 'act0_pot_showdown_truth_v1.dart';

typedef DecisionCopyFindingV1 = ({
  int rule,
  String taskId,
  String optionId,
  String quote,
});

const _positions = r'UTG\+1|UTG\+2|UTG|LJ|HJ|CO|BTN|SB|BB';
const _actions =
    r'fold(?:ing)?|call(?:ing)?|limp(?:ing)?|rais(?:e|ing)|bett?ing|bet|open(?:ing)?|check(?:ing)?|shov(?:e|ing)';
final _heroSeat = RegExp(
  r'(?:^|[.!?]\s+|[—:]\s+)(?:(?:you|your|a|an|the)\s+)?(?:\d+(?:\.\d+)?\s+BB\s+)?'
  '(?:$_actions)'
  r'\b(?:(?!\b(?:may|might|can|could|will|would|lets?|gives?|keeps?|makes?)\b)[^,.!?]){0,45}?\b(?:from|on|in)\s+'
  '($_positions)'
  r'(?![a-zA-Z0-9+’\x27])',
  caseSensitive: false,
);
final _countBehind = RegExp(
  r'\b(\d+|one|two|three|four|five|six|seven|eight)\s+(?:players?|seats?)\s+'
  r'(?:(?:are\s+)?(?:still\s+)?(?:left\s+)?to act|behind(?: you)?)\b',
  caseSensitive: false,
);
final _otherSubject = RegExp(
  '\\b(?:$_positions)'
  r'\s+(?:has|have|with|faces?)\b|\bbehind (?:it|them|him|her)\b|\b(?:adding|add|remove|removing)\s+(?:seats?|players?|UTG\+|LJ)',
  caseSensitive: false,
);
final _heroSizing = RegExp(
  r'(?:^(?:your\s+|a\s+|an\s+|the\s+)?|\byour\s+|\b(?:pressure\s+of|instead\s+of|rather\s+than)\s+(?:(?:a|an|the)\s+)?)'
  r'(\d+(?:\.\d+)?)\s*BB\s+(open|raise|bet)\b',
  caseSensitive: false,
  multiLine: true,
);
final _amount = RegExp(r'\b(\d+(?:\.\d+)?)\s*BB\b', caseSensitive: false);

const _preflop = ['UTG', 'UTG+1', 'UTG+2', 'LJ', 'HJ', 'CO', 'BTN', 'SB', 'BB'];
const _postflop = [
  'SB',
  'BB',
  'UTG',
  'UTG+1',
  'UTG+2',
  'LJ',
  'HJ',
  'CO',
  'BTN',
];
const _smallNumbers = [
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
];

int? _playersAfterHero(CatalogDecisionLedgerV1 decision, PokerStreet? street) {
  if (street == null) return null;
  final order = street == PokerStreet.preflop ? _preflop : _postflop;
  final hero = order.indexOf(decision.table.heroSeat.seatLabel.toUpperCase());
  if (hero < 0) return null;
  var count = 0;
  for (final seat in decision.table.seats) {
    if (seat.isHero ||
        !decision.activeSeatIds.contains(seat.seatId) ||
        seat.bet?.kind == Act0SeatBetKindV1.allIn)
      continue;
    final index = order.indexOf(seat.seatLabel.toUpperCase());
    if (index < 0) return null;
    if (index > hero) count++;
  }
  return count;
}

Iterable<DecisionCopyFindingV1> auditDecisionCopyV1(CatalogTask row) sync* {
  final task = row.task;
  if (catalogDecisionKindV1(task, row.world.worldNumber) !=
      Act0DecisionKindV1.table)
    return;
  final runner = task.runner;
  final decision = CatalogDecisionLedgerV1(runner.table);
  final hero = runner.table.heroSeat.seatLabel.toUpperCase();
  final behind = _playersAfterHero(decision, decisionStreetV1(runner.table));
  for (final option in runner.options) {
    final text = option.feedbackReason;
    final seatMatches = _heroSeat.allMatches(text);
    String? seatQuote;
    for (final match in seatMatches) {
      if (match[1]!.toUpperCase() != hero) seatQuote ??= match[0]!.trim();
    }
    if (behind != null && seatQuote == null) {
      for (final sentence in text.split(RegExp(r'(?<=[.!?])\s+'))) {
        if (_otherSubject.hasMatch(sentence)) continue;
        for (final match in _countBehind.allMatches(sentence)) {
          final word = match[1]!.toLowerCase();
          final claimed = int.tryParse(word) ?? _smallNumbers.indexOf(word);
          if (claimed != behind) seatQuote ??= match[0];
        }
      }
    }
    if (seatQuote != null) {
      yield (
        rule: 39,
        taskId: task.taskId,
        optionId: option.id,
        quote: seatQuote,
      );
    }

    final choices = [
      option,
      ...runner.options.where(
        (candidate) => candidate.isCorrect && candidate.id != option.id,
      ),
    ];
    final sizes = {
      for (final choice in choices)
        for (final match in _amount.allMatches(
          '${choice.label} ${choice.amountLabel}',
        ))
          double.parse(match[1]!),
      for (final item in runner.table.actionTrail)
        if (potTruthParseActionV1(runner.table, item.label) case final action?
            when (action.actor == hero || action.actor == 'HERO') &&
                const {'bet', 'raise_to'}.contains(action.chipVerb))
          if (action.amount case final amount?) amount,
      for (final match in _heroSizing.allMatches(runner.caption))
        double.parse(match[1]!),
      for (final match in _heroSizing.allMatches(catalogQuestion(task)))
        double.parse(match[1]!),
    };
    for (final sentence in text.split(RegExp(r'(?<=[.!?])\s+'))) {
      for (final match in _heroSizing.allMatches(sentence)) {
        if (!sizes.contains(double.parse(match[1]!))) {
          yield (
            rule: 40,
            taskId: task.taskId,
            optionId: option.id,
            quote: match[0]!.trim(),
          );
          break;
        }
      }
    }
  }
}
