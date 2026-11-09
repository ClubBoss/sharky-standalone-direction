import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Evidence scope is independent of whether the numbers happen to parse.
enum Act0Pkr06CapScopeV1 { playedHand, historical, unknown }

enum Act0Pkr06CapVerdictV1 { proved, unproved, contradiction }

enum Act0Pkr06CapReasonV1 {
  amountWithinPreflopBudget,
  amountExceedsPreflopBudget,
  sourceTimeBudgetUnproved,
  unsupportedTrailLabel,
  actorNotUnique,
  stackMissingOrUnsupported,
  commitmentMissingOrUnsupported,
  contributionWithoutAttributedAmount,
  noCapComparisons,
  scopeUnclassified,
}

/// One necessary numerical condition, not a legal action or a complete ledger.
/// Paths/indexes refer to the supplied source table, never a replay projection.
class Act0Pkr06CapRowV1 {
  const Act0Pkr06CapRowV1._({
    required this.sourcePath,
    required this.sourceLabel,
    required this.verdict,
    required this.reason,
    this.actorSeatId,
    this.amountMicros,
    this.preflopBudgetMicros,
  });

  final String sourcePath;
  final String sourceLabel;
  final Act0Pkr06CapVerdictV1 verdict;
  final Act0Pkr06CapReasonV1 reason;
  final String? actorSeatId;

  /// Exact millionths of a BB. Null means unsupported/absent, never zero.
  final int? amountMicros;

  /// Derived remaining + current preflop commitment, not an authored initial
  /// stack. Present only when the bounded preflop time basis is established.
  final int? preflopBudgetMicros;
}

/// Recorded-amount upper bounds only. Even [amountVerdict] == proved does NOT
/// establish cumulative contributions, a pending call/raise's affordability,
/// actor/order, prices, pot accounting, entitlement, winners or payouts.
///
/// Do not use this as a legal-execution or learner-success certificate. An
/// executable consumer needs separate positive evidence for every applicable
/// obligation. Historical/unknown evidence does not instruct a UI to hide a
/// scene or disable a conceptual question. Presentation policy belongs to its
/// source owner and must distinguish a supplied premise from a legal replay.
class Act0Pkr06CapEvidenceV1 {
  Act0Pkr06CapEvidenceV1._(this.scope, List<Act0Pkr06CapRowV1> rows)
    : rows = List<Act0Pkr06CapRowV1>.unmodifiable(rows),
      amountVerdict =
          rows.any((row) => row.verdict == Act0Pkr06CapVerdictV1.contradiction)
          ? Act0Pkr06CapVerdictV1.contradiction
          : rows.isEmpty ||
                rows.any((row) => row.verdict == Act0Pkr06CapVerdictV1.unproved)
          ? Act0Pkr06CapVerdictV1.unproved
          : Act0Pkr06CapVerdictV1.proved;

  final Act0Pkr06CapScopeV1 scope;
  final Act0Pkr06CapVerdictV1 amountVerdict;
  final List<Act0Pkr06CapRowV1> rows;
}

const _microsPerBb = 1000000;
// Match the existing source-price contract's bounded decimal precision. This
// avoids an epsilon accepting a genuine excess and stays exact on Dart web.
const _number = r'[0-9]{1,7}(?:\.[0-9]{1,6})?';
final _bbAmount = RegExp('^($_number)\\s+BB\$', caseSensitive: false);
final _blindSummary = RegExp(
  '^Blinds:\\s*($_number)\\s+BB\$',
  caseSensitive: false,
);
final _action = RegExp(
  r'^(?:(Preflop|Flop|Turn|River):\s*)?'
  r'(UTG|HJ|CO|BTN|SB|BB|Hero)\s+'
  r'(folds|checks|(?:blind|posts|bets|calls,?|raises to|shoves(?: to)?|all-in|contributes)'
  '\\s+($_number)\\s+BB(?: total| \\(limps\\))?(?:, then folds)?)\$',
  caseSensitive: false,
);

int? _micros(String? label) {
  final match = _bbAmount.firstMatch(label?.trim() ?? '');
  if (match == null) return null;
  return _numberMicros(match[1]!);
}

int _numberMicros(String value) {
  final parts = value.split('.');
  return int.parse(parts[0]) * _microsPerBb +
      (parts.length == 1 ? 0 : int.parse(parts[1].padRight(6, '0')));
}

/// Reads the supplied table without mutation, inference, solver dependencies or
/// imports from test/support. This is deliberately not a betting engine.
///
/// The comparison is decisive only for a preflop snapshot with no board and a
/// fully recognized preflop-only trail: no earlier street's commitment, return
/// or award can be omitted from remaining + current preflop commitment. A late
/// snapshot, unsupported grammar, missing amount/stack/commitment or ambiguous
/// actor stays UNPROVED. Calls may be totals or increments: either is bounded
/// by this necessary upper bound, but summing them would require semantics not
/// proved here. The source's blind summary is recognized, never synthesized
/// into individual blind actions or invented stacks.
Act0Pkr06CapEvidenceV1 act0Pkr06CapEvidenceForTableV1(Act0TableStateV1 table) {
  final scope = switch (table.scope) {
    Act0TableScopeV1.playedHand => Act0Pkr06CapScopeV1.playedHand,
    Act0TableScopeV1.orientation ||
    Act0TableScopeV1.explanation => Act0Pkr06CapScopeV1.historical,
    Act0TableScopeV1.unclassified => Act0Pkr06CapScopeV1.unknown,
  };
  final matches = [
    for (final item in table.actionTrail) _action.firstMatch(item.label.trim()),
  ];
  final hasPreflopBudget =
      scope != Act0Pkr06CapScopeV1.unknown &&
      table.streetLabel.trim().toLowerCase() == 'preflop' &&
      table.boardCards.isEmpty &&
      table.actionTrail.isNotEmpty &&
      List.generate(table.actionTrail.length, (index) => index).every((index) {
        final match = matches[index];
        if (match == null) {
          return _blindSummary.hasMatch(table.actionTrail[index].label.trim());
        }
        return match[1] == null || match[1]!.toLowerCase() == 'preflop';
      });
  final rows = <Act0Pkr06CapRowV1>[];
  final attributedSeatIds = <String>{};
  var contributionCount = 0;
  void unknown(
    String path,
    String label,
    Act0Pkr06CapReasonV1 reason, {
    String? actorSeatId,
  }) {
    rows.add(
      Act0Pkr06CapRowV1._(
        sourcePath: path,
        sourceLabel: label,
        verdict: Act0Pkr06CapVerdictV1.unproved,
        reason: reason,
        actorSeatId: actorSeatId,
      ),
    );
  }

  for (var index = 0; index < table.actionTrail.length; index++) {
    final label = table.actionTrail[index].label;
    final path = 'actionTrail[$index].label';
    final match = matches[index];
    if (match == null) {
      if (!_blindSummary.hasMatch(label.trim())) {
        unknown(path, label, Act0Pkr06CapReasonV1.unsupportedTrailLabel);
      }
      continue;
    }
    final actor = match[2]!.toUpperCase();
    final seats = table.seats
        .where(
          (seat) => actor == 'HERO'
              ? seat.isHero
              : seat.seatLabel.trim().toUpperCase() == actor,
        )
        .toList();
    // IDs must also be unique: evidence cannot bind to an ambiguous source row.
    if (seats.length != 1 ||
        table.seats.where((s) => s.seatId == seats.single.seatId).length != 1) {
      unknown(path, label, Act0Pkr06CapReasonV1.actorNotUnique);
      continue;
    }
    final amountText = match[4];
    if (amountText == null) continue; // Fold/check has no chip cap claim.
    contributionCount++;
    final seat = seats.single;
    attributedSeatIds.add(seat.seatId);
    if (!hasPreflopBudget) {
      unknown(
        path,
        label,
        Act0Pkr06CapReasonV1.sourceTimeBudgetUnproved,
        actorSeatId: seat.seatId,
      );
      continue;
    }
    final remaining = _micros(seat.stackLabel);
    final committed = _micros(seat.currentBetLabel);
    if (remaining == null || committed == null) {
      unknown(
        path,
        label,
        remaining == null
            ? Act0Pkr06CapReasonV1.stackMissingOrUnsupported
            : Act0Pkr06CapReasonV1.commitmentMissingOrUnsupported,
        actorSeatId: seat.seatId,
      );
      continue;
    }
    final amount = _numberMicros(amountText);
    final budget = remaining + committed;
    final exceeds = amount > budget;
    rows.add(
      Act0Pkr06CapRowV1._(
        sourcePath: path,
        sourceLabel: label,
        actorSeatId: seat.seatId,
        amountMicros: amount,
        preflopBudgetMicros: budget,
        verdict: exceeds
            ? Act0Pkr06CapVerdictV1.contradiction
            : Act0Pkr06CapVerdictV1.proved,
        reason: exceeds
            ? Act0Pkr06CapReasonV1.amountExceedsPreflopBudget
            : Act0Pkr06CapReasonV1.amountWithinPreflopBudget,
      ),
    );
  }

  // Displayed commitments also need attributable evidence. Missing historical
  // dead-blind stacks are kept as historical unknowns, not executable blockers.
  for (var index = 0; index < table.seats.length; index++) {
    final seat = table.seats[index];
    final label = seat.currentBetLabel;
    if (label == null) continue;
    final committed = _micros(label);
    final path = 'seats[$index].currentBetLabel';
    if (committed == null) {
      unknown(
        path,
        label,
        Act0Pkr06CapReasonV1.commitmentMissingOrUnsupported,
        actorSeatId: seat.seatId,
      );
    } else if (committed > 0) {
      if (_micros(seat.stackLabel) == null) {
        unknown(
          path,
          label,
          Act0Pkr06CapReasonV1.stackMissingOrUnsupported,
          actorSeatId: seat.seatId,
        );
      } else if (!attributedSeatIds.contains(seat.seatId)) {
        unknown(
          path,
          label,
          Act0Pkr06CapReasonV1.contributionWithoutAttributedAmount,
          actorSeatId: seat.seatId,
        );
      }
    }
  }
  if (contributionCount == 0) {
    unknown('actionTrail', '', Act0Pkr06CapReasonV1.noCapComparisons);
  }
  if (scope == Act0Pkr06CapScopeV1.unknown) {
    unknown('scope', '', Act0Pkr06CapReasonV1.scopeUnclassified);
  }
  if (!hasPreflopBudget) {
    unknown('budget', '', Act0Pkr06CapReasonV1.sourceTimeBudgetUnproved);
  }
  return Act0Pkr06CapEvidenceV1._(scope, rows);
}
