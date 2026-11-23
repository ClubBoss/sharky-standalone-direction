import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_reasoning_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_seat_order_v1.dart';

import 'act0_catalog_decision_v1.dart';
import 'act0_catalog_snapshot_v1.dart';
import 'act0_pot_showdown_truth_v1.dart';

typedef DecisionCopyFindingV1 = ({
  int rule,
  String taskId,
  String optionId,
  String quote,
});

const _positions = r'UTG\+1|UTG\+2|UTG|MP|LJ|HJ|CO|BTN|SB|BB';
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
final _utgReference = RegExp(
  r'\b(?:UTG\s+(?:is|acts)\s+first|behind\s+UTG\b(?![+’\x27]))',
  caseSensitive: false,
);
final _utgFrame = RegExp(
  r'\b(?:UTG\s+(?:is|acts)\s+first|behind\s+UTG\b(?![+’\x27])|'
  r'(?:five|5)\s+players?\s+(?:are\s+)?(?:still\s+)?left(?:\s+to\s+act\b|(?=\s*[,.;!?]|$)))',
  caseSensitive: false,
);
final _utgQuestion = RegExp(
  r'\b(?:UTG(?![+])|(?:who|which (?:seat|player))\s+acts? first|next clockwise after the big blind)\b',
  caseSensitive: false,
);
final _heroSizing = RegExp(
  r'(?:^(?:your\s+|a\s+|an\s+|the\s+)?|\byour\s+|\b(?:pressure\s+of|instead\s+of|rather\s+than)\s+(?:(?:a|an|the)\s+)?)'
  r'(\d+(?:\.\d+)?)\s*BB\s+(open|raise|bet)\b',
  caseSensitive: false,
  multiLine: true,
);
final _amount = RegExp(r'\b(\d+(?:\.\d+)?)\s*BB\b', caseSensitive: false);

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
  final positions = decision.table.canonicalSeatOrder;
  final order = positions.length <= 9
      ? Act0SeatOrderV1(positions, 'BTN').actionOrder(street)
      : street == PokerStreet.preflop
      ? positions
      : [
          ...positions.skip(positions.length - 2),
          ...positions.take(positions.length - 2),
        ];
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
  final runner = task.runner;
  final table = runner.table;
  final heroSeat = table.seats.where((seat) => seat.isHero).singleOrNull;
  if (heroSeat == null || runner.options.isEmpty) return;
  final hero = heroSeat.seatLabel.toUpperCase();
  final street = decisionStreetV1(table);
  final isTableDecision =
      catalogDecisionKindV1(task, row.world.worldNumber) ==
      Act0DecisionKindV1.table;
  final playedHand = table.scope == Act0TableScopeV1.playedHand;
  final active = table.activeSeatId;
  final authoredTurn = table.decisionSeatId;
  final heroDecides =
      isTableDecision ||
      authoredTurn == heroSeat.seatId ||
      (authoredTurn == null &&
          table.actionTrail.where((item) => !item.isNote).lastOrNull?.label ==
              '${active?.toUpperCase()} acts');
  if (playedHand &&
      heroDecides &&
      active != null &&
      active.isNotEmpty &&
      active != heroSeat.seatId) {
    yield (
      rule: 39,
      taskId: task.taskId,
      optionId: 'table',
      quote: 'Seat $hero · Active ${active.toUpperCase()}',
    );
  }

  final question = catalogQuestion(task).split(RegExp(r'(?<=[.!?])\s+')).last;
  final checkUtgFrame =
      playedHand && hero != 'UTG' && !_utgQuestion.hasMatch(question);
  if (!isTableDecision && !checkUtgFrame) return;
  final decision = CatalogDecisionLedgerV1(table);
  final behind = isTableDecision ? _playersAfterHero(decision, street) : null;
  for (final option in runner.options) {
    final text = option.feedbackReason;
    final utgPattern = table.tableFormat == Act0TableFormatV1.sixMax
        ? _utgFrame
        : _utgReference;
    String? seatQuote = checkUtgFrame
        ? utgPattern.firstMatch(text)?.group(0)
        : null;
    if (isTableDecision) {
      for (final match in _heroSeat.allMatches(text)) {
        if (match[1]!.toUpperCase() != hero) seatQuote ??= match[0]!.trim();
      }
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

    if (!isTableDecision) continue;
    final choices = [
      option,
      ...runner.options.where(
        (candidate) =>
            act0RunnerOptionIsPreferredV1(candidate) &&
            candidate.id != option.id,
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
