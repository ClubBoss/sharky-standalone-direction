import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

enum Act0StreetReplayStreetV1 { preflop, flop, turn, river }

enum Act0StreetReplayCompletenessV1 { complete, partialSafe, insufficient }

class Act0StreetReplayV1 {
  const Act0StreetReplayV1({
    required this.steps,
    required this.currentStreet,
    required this.completeness,
    required this.heroPosition,
    this.opponentPosition = '',
    this.effectiveStackBb = '',
    required this.currentDecisionActor,
    this.currentDecisionSummaryKey = '',
    this.sourceRefs = const <String>[],
    this.keyClue = '',
    this.decisionContext = '',
    this.sourceLabel = 'act0_table_action_trail_v1',
  });

  final List<Act0StreetReplayStepV1> steps;
  final Act0StreetReplayStreetV1 currentStreet;
  final Act0StreetReplayCompletenessV1 completeness;
  final String heroPosition;
  final String opponentPosition;
  final String effectiveStackBb;
  final String currentDecisionActor;
  final String currentDecisionSummaryKey;
  final List<String> sourceRefs;
  final String keyClue;
  final String decisionContext;
  final String sourceLabel;

  bool get isConsumerSafe =>
      completeness != Act0StreetReplayCompletenessV1.insufficient &&
      steps.isNotEmpty;
}

class Act0StreetReplayStepV1 {
  const Act0StreetReplayStepV1({
    required this.street,
    required this.actionSummary,
    required this.actorLabel,
    required this.actionTypeLabel,
    required this.order,
    this.amountLabel = '',
    this.boardCardsAtStreet = const <String>[],
    this.potAtStreet = '',
    this.isCurrentStreet = false,
    this.compactLabel = '',
  });

  final Act0StreetReplayStreetV1 street;
  final String actionSummary;
  final String actorLabel;
  final String actionTypeLabel;
  final String amountLabel;
  final int order;
  final List<String> boardCardsAtStreet;
  final String potAtStreet;
  final bool isCurrentStreet;
  final String compactLabel;

  String get streetLabel => switch (street) {
    Act0StreetReplayStreetV1.preflop => 'Preflop',
    Act0StreetReplayStreetV1.flop => 'Flop',
    Act0StreetReplayStreetV1.turn => 'Turn',
    Act0StreetReplayStreetV1.river => 'River',
  };

  String get youAreHereLabel => isCurrentStreet ? 'You are here' : '';
}

Act0StreetReplayV1? act0StreetReplayFromTableV1(Act0TableStateV1 table) {
  final trailLabels = table.actionTrail
      .map((item) => item.label.trim())
      .where((label) => label.isNotEmpty)
      .toList(growable: false);
  final currentStreet = _act0StreetReplayStreetFromLabelV1(table.streetLabel);
  if (trailLabels.isEmpty || currentStreet == null) {
    return null;
  }

  final heroSeat = table.heroSeat;
  final heroPosition = heroSeat.seatLabel.trim();
  final activeSeat = _act0StreetReplaySeatByIdV1(table, table.activeSeatId);
  final currentDecisionActor = activeSeat?.displayName.trim().isNotEmpty == true
      ? activeSeat!.displayName.trim()
      : activeSeat?.seatLabel.trim() ?? '';
  final opponentPosition = table.seats
      .where((seat) => !seat.isHero)
      .map((seat) => seat.seatLabel.trim())
      .firstWhere((label) => label.isNotEmpty, orElse: () => '');
  final effectiveStackBb = _act0StreetReplayEffectiveStackV1(table);
  final sourceRefs = <String>[
    'streetLabel',
    'actionTrail',
    if ((table.activeSeatId ?? '').trim().isNotEmpty) 'activeSeatId',
    if ((table.heroSeatId ?? '').trim().isNotEmpty) 'heroSeatId',
  ];

  if (heroPosition.isEmpty || currentDecisionActor.isEmpty) {
    return Act0StreetReplayV1(
      steps: const <Act0StreetReplayStepV1>[],
      currentStreet: currentStreet,
      completeness: Act0StreetReplayCompletenessV1.insufficient,
      heroPosition: heroPosition,
      opponentPosition: opponentPosition,
      effectiveStackBb: effectiveStackBb,
      currentDecisionActor: currentDecisionActor,
      currentDecisionSummaryKey: table.centerLabel.trim(),
      sourceRefs: List<String>.unmodifiable(sourceRefs),
      keyClue: table.focusCalloutLabel.trim(),
      decisionContext: _act0StreetReplayDecisionContextV1(table),
    );
  }

  final steps = <Act0StreetReplayStepV1>[];
  var activeStreet = Act0StreetReplayStreetV1.preflop;
  var failedActionTruth = false;
  for (var index = 0; index < trailLabels.length; index++) {
    final rawLabel = trailLabels[index];
    final parsedStreet = _act0StreetReplayStreetFromTrailLabelV1(rawLabel);
    if (parsedStreet != null) {
      activeStreet = parsedStreet;
    }
    final action = _act0StreetReplayActionLabelV1(rawLabel, parsedStreet);
    if (action.isEmpty) {
      continue;
    }
    final parsedAction = _act0StreetReplayParseActionV1(action);
    if (parsedAction == null) {
      failedActionTruth = true;
      break;
    }
    steps.add(
      Act0StreetReplayStepV1(
        street: activeStreet,
        actionSummary: action,
        actorLabel: parsedAction.actorLabel,
        actionTypeLabel: parsedAction.actionTypeLabel,
        amountLabel: parsedAction.amountLabel,
        order: index,
        boardCardsAtStreet: _act0StreetReplayBoardCardsForStreetV1(
          table.boardCards,
          activeStreet,
        ),
        potAtStreet: activeStreet == currentStreet ? table.potLabel.trim() : '',
        isCurrentStreet: activeStreet == currentStreet,
        compactLabel: activeStreet == currentStreet ? 'Current street' : '',
      ),
    );
  }

  return Act0StreetReplayV1(
    steps: failedActionTruth
        ? const <Act0StreetReplayStepV1>[]
        : List<Act0StreetReplayStepV1>.unmodifiable(steps),
    currentStreet: currentStreet,
    completeness: failedActionTruth || steps.isEmpty
        ? Act0StreetReplayCompletenessV1.insufficient
        : _act0StreetReplayCompletenessV1(
            table: table,
            heroPosition: heroPosition,
            currentDecisionActor: currentDecisionActor,
          ),
    heroPosition: heroPosition,
    opponentPosition: opponentPosition,
    effectiveStackBb: effectiveStackBb,
    currentDecisionActor: currentDecisionActor,
    currentDecisionSummaryKey: table.centerLabel.trim(),
    sourceRefs: List<String>.unmodifiable(sourceRefs),
    keyClue: table.focusCalloutLabel.trim(),
    decisionContext: _act0StreetReplayDecisionContextV1(table),
  );
}

Act0StreetReplayStreetV1? _act0StreetReplayStreetFromLabelV1(String label) {
  final normalized = label.trim().toLowerCase();
  return switch (normalized) {
    'preflop' => Act0StreetReplayStreetV1.preflop,
    'flop' => Act0StreetReplayStreetV1.flop,
    'turn' => Act0StreetReplayStreetV1.turn,
    'river' => Act0StreetReplayStreetV1.river,
    _ => null,
  };
}

Act0StreetReplayStreetV1? _act0StreetReplayStreetFromTrailLabelV1(
  String label,
) {
  final match = RegExp(
    r'^(flop|turn|river)(?::|\s)',
    caseSensitive: false,
  ).firstMatch(label.trim());
  if (match == null) {
    return null;
  }
  return _act0StreetReplayStreetFromLabelV1(match.group(1) ?? '');
}

String _act0StreetReplayActionLabelV1(
  String label,
  Act0StreetReplayStreetV1? street,
) {
  final trimmed = label.trim();
  if (street == null) {
    return trimmed;
  }
  final streetLabel = switch (street) {
    Act0StreetReplayStreetV1.preflop => 'Preflop',
    Act0StreetReplayStreetV1.flop => 'Flop',
    Act0StreetReplayStreetV1.turn => 'Turn',
    Act0StreetReplayStreetV1.river => 'River',
  };
  final colonPrefix = RegExp('^$streetLabel:\\s*', caseSensitive: false);
  final barePrefix = RegExp('^$streetLabel\\s+', caseSensitive: false);
  final withoutColon = trimmed.replaceFirst(colonPrefix, '').trim();
  if (withoutColon != trimmed) {
    return withoutColon;
  }
  return trimmed.replaceFirst(barePrefix, '').trim();
}

List<String> _act0StreetReplayBoardCardsForStreetV1(
  List<Act0CardStateV1> boardCards,
  Act0StreetReplayStreetV1 street,
) {
  final count = switch (street) {
    Act0StreetReplayStreetV1.preflop => 0,
    Act0StreetReplayStreetV1.flop => 3,
    Act0StreetReplayStreetV1.turn => 4,
    Act0StreetReplayStreetV1.river => 5,
  };
  return boardCards
      .take(count)
      .map((card) => card.label)
      .where((label) => label.trim().isNotEmpty && !label.contains('?'))
      .toList(growable: false);
}

String _act0StreetReplayDecisionContextV1(Act0TableStateV1 table) {
  final parts = <String>[
    table.centerLabel.trim(),
    table.potLabel.trim(),
    table.toCallLabel.trim(),
  ].where((part) => part.isNotEmpty).toList(growable: false);
  if (parts.isEmpty) {
    return '';
  }
  return '${parts.join('. ')}.';
}

({String actorLabel, String actionTypeLabel, String amountLabel})?
_act0StreetReplayParseActionV1(String action) {
  final tokens = action.trim().split(RegExp(r'\s+'));
  if (tokens.length < 2) {
    return null;
  }
  final actor = tokens.first.trim();
  final actionType = tokens[1].trim();
  if (!_act0StreetReplayLooksLikeActorV1(actor) ||
      !_act0StreetReplayLooksLikeActionV1(actionType)) {
    return null;
  }
  final amountMatch = RegExp(
    r'(\d+(?:\.\d+)?)\s*BB\b',
    caseSensitive: false,
  ).firstMatch(action);
  return (
    actorLabel: actor,
    actionTypeLabel: actionType,
    amountLabel: amountMatch == null ? '' : '${amountMatch.group(1)} BB',
  );
}

bool _act0StreetReplayLooksLikeActorV1(String value) {
  final normalized = value.trim().toUpperCase();
  if (normalized.isEmpty) return false;
  return normalized == 'SB' ||
      normalized == 'BB' ||
      normalized == 'BTN' ||
      normalized == 'CO' ||
      normalized == 'HJ' ||
      normalized == 'LJ' ||
      normalized == 'UTG' ||
      normalized == 'MP' ||
      normalized.startsWith('UTG+');
}

bool _act0StreetReplayLooksLikeActionV1(String value) {
  return switch (value.trim().toLowerCase()) {
    'blind' ||
    'posts' ||
    'checks' ||
    'check' ||
    'bets' ||
    'bet' ||
    'raises' ||
    'raise' ||
    'calls' ||
    'call' ||
    'folds' ||
    'fold' ||
    'shoves' ||
    'shove' ||
    'jams' ||
    'jam' => true,
    _ => false,
  };
}

Act0SeatStateV1? _act0StreetReplaySeatByIdV1(
  Act0TableStateV1 table,
  String? seatId,
) {
  final normalized = seatId?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  for (final seat in table.seats) {
    if (seat.seatId == normalized) {
      return seat;
    }
  }
  return null;
}

String _act0StreetReplayEffectiveStackV1(Act0TableStateV1 table) {
  final labels = table.seats
      .map((seat) => seat.stackLabel?.trim() ?? '')
      .where((label) => label.isNotEmpty)
      .toList(growable: false);
  if (labels.isEmpty) {
    return '';
  }
  return labels.first;
}

Act0StreetReplayCompletenessV1 _act0StreetReplayCompletenessV1({
  required Act0TableStateV1 table,
  required String heroPosition,
  required String currentDecisionActor,
}) {
  final hasCompleteContext =
      heroPosition.trim().isNotEmpty &&
      currentDecisionActor.trim().isNotEmpty &&
      table.potLabel.trim().isNotEmpty &&
      table.centerLabel.trim().isNotEmpty;
  return hasCompleteContext
      ? Act0StreetReplayCompletenessV1.complete
      : Act0StreetReplayCompletenessV1.partialSafe;
}
