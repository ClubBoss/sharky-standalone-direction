import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

enum Act0StreetReplayStreetV1 { preflop, flop, turn, river }

class Act0StreetReplayV1 {
  const Act0StreetReplayV1({
    required this.steps,
    required this.currentStreet,
    this.keyClue = '',
    this.decisionContext = '',
    this.sourceLabel = 'act0_table_action_trail_v1',
  });

  final List<Act0StreetReplayStepV1> steps;
  final Act0StreetReplayStreetV1 currentStreet;
  final String keyClue;
  final String decisionContext;
  final String sourceLabel;
}

class Act0StreetReplayStepV1 {
  const Act0StreetReplayStepV1({
    required this.street,
    required this.actionSummary,
    this.boardCardsAtStreet = const <String>[],
    this.potAtStreet = '',
    this.isCurrentStreet = false,
    this.compactLabel = '',
  });

  final Act0StreetReplayStreetV1 street;
  final String actionSummary;
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

  final grouped = <Act0StreetReplayStreetV1, List<String>>{
    Act0StreetReplayStreetV1.preflop: <String>[],
  };
  var activeStreet = Act0StreetReplayStreetV1.preflop;
  for (final rawLabel in trailLabels) {
    final parsedStreet = _act0StreetReplayStreetFromTrailLabelV1(rawLabel);
    if (parsedStreet != null) {
      activeStreet = parsedStreet;
    }
    final action = _act0StreetReplayActionLabelV1(rawLabel, parsedStreet);
    if (action.isEmpty) {
      continue;
    }
    grouped.putIfAbsent(activeStreet, () => <String>[]).add(action);
  }

  final steps = <Act0StreetReplayStepV1>[];
  for (final street in Act0StreetReplayStreetV1.values) {
    final actions = grouped[street] ?? const <String>[];
    if (actions.isEmpty && street.index > currentStreet.index) {
      continue;
    }
    if (actions.isEmpty && street != currentStreet) {
      continue;
    }
    final boardCards = _act0StreetReplayBoardCardsForStreetV1(
      table.boardCards,
      street,
    );
    final isCurrentStreet = street == currentStreet;
    steps.add(
      Act0StreetReplayStepV1(
        street: street,
        actionSummary: actions.isEmpty
            ? 'Current decision.'
            : actions.join('. '),
        boardCardsAtStreet: boardCards,
        potAtStreet: isCurrentStreet ? table.potLabel.trim() : '',
        isCurrentStreet: isCurrentStreet,
        compactLabel: isCurrentStreet ? 'Current street' : '',
      ),
    );
  }

  if (steps.isEmpty || !steps.any((step) => step.isCurrentStreet)) {
    return null;
  }

  return Act0StreetReplayV1(
    steps: List<Act0StreetReplayStepV1>.unmodifiable(steps),
    currentStreet: currentStreet,
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
