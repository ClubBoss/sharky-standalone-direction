import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart'
    as scenario_fsm;
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/models/card_model.dart';

class World1ModernTableAdapterInputV1 {
  const World1ModernTableAdapterInputV1({
    required this.seatIds,
    required this.heroSeatId,
    required this.actingSeatId,
    required this.selectedSeatId,
    required this.foldedBySeatId,
    required this.committedBySeatId,
    required this.pot,
    required this.currentBet,
    required this.actingSeatToCall,
    required this.lastAggressorSeatId,
    required this.priceSettingActionKindV1,
    required this.betOwnerSeatId,
    required this.currentStreet,
    required this.visibleBoardCount,
    required this.heroCards,
    required this.boardCards,
    required this.promptLabel,
    required this.showsActingSeat,
  });

  final List<String> seatIds;
  final String? heroSeatId;
  final String? actingSeatId;
  final String? selectedSeatId;
  final Map<String, bool> foldedBySeatId;
  final Map<String, int> committedBySeatId;
  final int pot;
  final int currentBet;
  final int actingSeatToCall;
  final String? lastAggressorSeatId;
  final ActionKindV1? priceSettingActionKindV1;
  final String? betOwnerSeatId;
  final scenario_fsm.Street currentStreet;
  final int visibleBoardCount;
  final List<CardModel> heroCards;
  final List<CardModel> boardCards;
  final String? promptLabel;
  final bool showsActingSeat;
}

class World1ModernTableAdapterBundleV1 {
  const World1ModernTableAdapterBundleV1({
    required this.seatIds,
    required this.scenarioSpec,
    required this.seatRoleLabels,
    required this.seatMarkerLabels,
    required this.seatContributionAmountsV1,
    required this.debugHeroCardLabels,
    required this.debugBoardCardLabels,
    required this.debugScenePromptLabel,
    required this.debugPotDisplayLabelV1,
    required this.debugScenePriceLabelV1,
    required this.debugPriceSetterSeatIndexV1,
    required this.debugPriceSetterCueLabelV1,
    required this.selectedSeatIndex,
    required this.showsActingSeat,
  });

  final List<String> seatIds;
  final scenario_fsm.ScenarioSpecV1 scenarioSpec;
  final Map<int, String> seatRoleLabels;
  final Map<int, String> seatMarkerLabels;
  final Map<int, int> seatContributionAmountsV1;
  final List<String> debugHeroCardLabels;
  final List<String> debugBoardCardLabels;
  final String? debugScenePromptLabel;
  final String? debugPotDisplayLabelV1;
  final String? debugScenePriceLabelV1;
  final int? debugPriceSetterSeatIndexV1;
  final String? debugPriceSetterCueLabelV1;
  final int? selectedSeatIndex;
  final bool showsActingSeat;

  int? seatIndexForId(String? seatId) {
    if (seatId == null) {
      return null;
    }
    final normalized = seatId.trim().toLowerCase();
    final index = seatIds.indexOf(normalized);
    return index >= 0 ? index : null;
  }

  String seatIdForIndex(int index) => seatIds[index];
}

World1ModernTableAdapterBundleV1 resolveWorld1ModernTableAdapterV1(
  World1ModernTableAdapterInputV1 input,
) {
  final seatIds = input.seatIds
      .map((seatId) => seatId.trim().toLowerCase())
      .where((seatId) => seatId.isNotEmpty)
      .toList(growable: false);
  final fallbackHeroSeatId = seatIds.contains('btn')
      ? 'btn'
      : (seatIds.isEmpty ? 'btn' : seatIds.first);
  final heroSeatId =
      _resolveSeatIdOrFallbackV1(input.heroSeatId, seatIds) ??
      fallbackHeroSeatId;
  final heroSeatIndex = seatIds.indexOf(heroSeatId);
  final actingSeatIndex = input.showsActingSeat
      ? (seatIds.indexOf(
                  _resolveSeatIdOrFallbackV1(input.actingSeatId, seatIds) ??
                      heroSeatId,
                ) >=
                0
            ? seatIds.indexOf(
                _resolveSeatIdOrFallbackV1(input.actingSeatId, seatIds) ??
                    heroSeatId,
              )
            : heroSeatIndex)
      : heroSeatIndex;
  final occupancies = List<scenario_fsm.ScenarioSeatOccupancyV1>.generate(
    seatIds.length,
    (index) {
      final seatId = seatIds[index];
      final isFolded = input.foldedBySeatId[seatId] ?? false;
      return isFolded
          ? scenario_fsm.ScenarioSeatOccupancyV1.folded
          : scenario_fsm.ScenarioSeatOccupancyV1.active;
    },
    growable: false,
  );
  final scenarioSpec = scenario_fsm.ScenarioSpecV1(
    seatCount: seatIds.length,
    heroSeat: heroSeatIndex,
    initialStacks: List<int>.filled(seatIds.length, 1000, growable: false),
    actingSeatStart: actingSeatIndex,
    seatOccupancies: occupancies,
    decisionNodeV1: scenario_fsm.DecisionNodeV1(
      street: input.currentStreet,
      legalActions: const <String>['Fold', 'Call', 'Raise'],
      solutionBestAction: 'Call',
    ),
    nodes: <scenario_fsm.ScenarioNodeV1>[
      scenario_fsm.ScenarioNodeV1(
        id: 'world1_current',
        street: input.currentStreet,
        actingSeatIndex: actingSeatIndex,
        pot: input.pot,
        decisionNode: scenario_fsm.DecisionNodeV1(
          street: input.currentStreet,
          legalActions: const <String>['Fold', 'Call', 'Raise'],
          solutionBestAction: 'Call',
        ),
      ),
    ],
  );
  final seatRoleLabels = <int, String>{
    for (var i = 0; i < seatIds.length; i++) i: _seatRoleLabelV1(seatIds[i]),
  };
  final seatMarkerLabels = <int, String>{};
  for (var i = 0; i < seatIds.length; i++) {
    final label = _seatMarkerLabelV1(seatIds[i]);
    if (label != null) {
      seatMarkerLabels[i] = label;
    }
  }
  final seatContributionAmountsV1 = <int, int>{};
  for (final entry in input.committedBySeatId.entries) {
    final normalizedSeatId = entry.key.trim().toLowerCase();
    final index = seatIds.indexOf(normalizedSeatId);
    if (index >= 0 && entry.value > 0) {
      seatContributionAmountsV1[index] = entry.value;
    }
  }
  final debugHeroCardLabels = input.heroCards
      .take(2)
      .map(_cardLabelV1)
      .toList(growable: false);
  final debugBoardCardLabels = input.boardCards
      .take(input.visibleBoardCount.clamp(0, 5))
      .map(_cardLabelV1)
      .toList(growable: false);
  final promptLabel = input.promptLabel?.trim();
  final debugPotDisplayLabelV1 = '${_formatUnitsToBbDisplayV1(input.pot)} BB';
  final debugScenePriceLabelV1 = input.actingSeatToCall > 0
      ? 'TO CALL ${_formatUnitsToBbDisplayV1(input.actingSeatToCall)} BB'
      : null;
  final debugPriceSetterSeatIndexV1 = _resolvePriceSetterSeatIndexV1(
    input: input,
    seatIds: seatIds,
  );
  final debugPriceSetterCueLabelV1 = debugPriceSetterSeatIndexV1 == null
      ? null
      : _resolvePriceSetterCueLabelV1(input);
  return World1ModernTableAdapterBundleV1(
    seatIds: seatIds,
    scenarioSpec: scenarioSpec,
    seatRoleLabels: seatRoleLabels,
    seatMarkerLabels: seatMarkerLabels,
    seatContributionAmountsV1: seatContributionAmountsV1,
    debugHeroCardLabels: debugHeroCardLabels,
    debugBoardCardLabels: debugBoardCardLabels,
    debugScenePromptLabel: promptLabel == null || promptLabel.isEmpty
        ? null
        : promptLabel,
    debugPotDisplayLabelV1: debugPotDisplayLabelV1,
    debugScenePriceLabelV1: debugScenePriceLabelV1,
    debugPriceSetterSeatIndexV1: debugPriceSetterSeatIndexV1,
    debugPriceSetterCueLabelV1: debugPriceSetterCueLabelV1,
    selectedSeatIndex:
        seatIds.indexOf(
              _resolveSeatIdOrFallbackV1(input.selectedSeatId, seatIds) ?? '',
            ) >=
            0
        ? seatIds.indexOf(
            _resolveSeatIdOrFallbackV1(input.selectedSeatId, seatIds) ?? '',
          )
        : null,
    showsActingSeat: input.showsActingSeat,
  );
}

String? _resolvePriceSetterCueLabelV1(World1ModernTableAdapterInputV1 input) {
  final actionKind = input.priceSettingActionKindV1;
  if (actionKind == null || input.currentBet <= 0) {
    return null;
  }
  if (input.currentStreet == scenario_fsm.Street.preflop) {
    return _resolvePreflopPriceSetterCueLabelV1(input);
  }
  return switch (actionKind) {
    ActionKindV1.bet => 'BET',
    ActionKindV1.raise => 'RAISE',
    _ => null,
  };
}

String? _resolvePreflopPriceSetterCueLabelV1(
  World1ModernTableAdapterInputV1 input,
) {
  final ownerSeatId = input.betOwnerSeatId?.trim().toLowerCase();
  if (ownerSeatId == null || ownerSeatId.isEmpty) {
    return 'OPEN';
  }
  final priorPriceSetterExists = input.committedBySeatId.entries.any((entry) {
    final seatId = entry.key.trim().toLowerCase();
    if (seatId == ownerSeatId || seatId == 'sb' || seatId == 'bb') {
      return false;
    }
    final amount = entry.value;
    return amount > 2 && amount < input.currentBet;
  });
  return priorPriceSetterExists ? 'RAISE' : 'OPEN';
}

int? _resolvePriceSetterSeatIndexV1({
  required World1ModernTableAdapterInputV1 input,
  required List<String> seatIds,
}) {
  if (input.currentBet <= 0) {
    return null;
  }
  final resolvedLastAggressorSeatId = _resolveSeatIdOrFallbackV1(
    input.lastAggressorSeatId,
    seatIds,
  );
  if (resolvedLastAggressorSeatId == null) {
    return null;
  }
  final resolvedBetOwnerSeatId = _resolveSeatIdOrFallbackV1(
    input.betOwnerSeatId,
    seatIds,
  );
  final ownerCandidateSeatId =
      resolvedBetOwnerSeatId ?? resolvedLastAggressorSeatId;
  final ownerContributionAmount =
      input.committedBySeatId[ownerCandidateSeatId] ?? 0;
  if (ownerContributionAmount >= input.currentBet) {
    return seatIds.indexOf(ownerCandidateSeatId);
  }
  final aggressorContributionAmount =
      input.committedBySeatId[resolvedLastAggressorSeatId] ?? 0;
  if (aggressorContributionAmount >= input.currentBet) {
    return seatIds.indexOf(resolvedLastAggressorSeatId);
  }
  return null;
}

String? _seatMarkerLabelV1(String seatId) {
  return switch (seatId) {
    'btn' => 'D',
    'sb' => 'SB',
    'bb' => 'BB',
    _ => null,
  };
}

String? _resolveSeatIdOrFallbackV1(String? seatId, List<String> seatIds) {
  if (seatId == null) {
    return null;
  }
  final normalized = seatId.trim().toLowerCase();
  return seatIds.contains(normalized) ? normalized : null;
}

String _seatRoleLabelV1(String seatId) {
  return switch (seatId) {
    'btn' => 'BTN',
    'sb' => 'SB',
    'bb' => 'BB',
    'utg' => 'UTG',
    'utg1' => 'UTG+1',
    'mp' => 'MP',
    'mp1' => 'MP+1',
    'hj' => 'HJ',
    'co' => 'CO',
    'lj' => 'LJ',
    _ => seatId.toUpperCase(),
  };
}

String _cardLabelV1(CardModel card) => '${card.rank}${card.suit}';

String _formatUnitsToBbDisplayV1(int units) {
  final negative = units < 0;
  final absUnits = units.abs();
  final whole = absUnits ~/ 2;
  final hasHalf = absUnits.isOdd;
  final bb = hasHalf ? '$whole.5' : '$whole';
  return negative ? '-$bb' : bb;
}
