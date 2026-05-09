import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_board_texture_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/factual_runner_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_source_meta_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_hand_chain_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_outs_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_seat_context_scenario_state_v1.dart';

class SessionDrillCanonicalSourceMetaInputV1 {
  const SessionDrillCanonicalSourceMetaInputV1({
    required this.family,
    this.street,
    this.playerCount,
    this.heroLabel,
    this.villainLabel,
    this.activeSeats,
    this.foldedSeats,
    this.emptySeats,
    this.boardCards,
    this.lastAggressor,
    this.initiativeOwner,
  });

  final FactualRunnerHostFamilyV1 family;
  final String? street;
  final int? playerCount;
  final String? heroLabel;
  final String? villainLabel;
  final List<String>? activeSeats;
  final List<String>? foldedSeats;
  final List<String>? emptySeats;
  final List<String>? boardCards;
  final String? lastAggressor;
  final String? initiativeOwner;
}

SessionDrillCanonicalSourceMetaInputV1
buildSessionDrillCanonicalSourceMetaInputForFamilyV1({
  required FactualRunnerHostFamilyV1 family,
  SessionDrillItemV1? currentDrill,
  DrillScenarioHandChainStepContextV1? handChainStep,
  SessionDrillCanonicalBoardTextureScenarioStateV1? resolvedTextureStateV1,
  SessionDrillCanonicalHandChainScenarioStateV1? resolvedHandChainStateV1,
  SessionDrillCanonicalOutsScenarioStateV1? resolvedOutsStateV1,
  SessionDrillCanonicalSeatContextScenarioStateV1? resolvedSeatContextStateV1,
}) {
  switch (family) {
    case FactualRunnerHostFamilyV1.position:
      final positionContext = currentDrill?.spec.scenarioPositionContextV1;
      return SessionDrillCanonicalSourceMetaInputV1(
        family: family,
        street: _normalizeUpperLabelV1(
          resolvedSeatContextStateV1?.streetV1 ?? positionContext?.streetV1,
        ),
        playerCount:
            resolvedSeatContextStateV1?.playerCountV1 ??
            positionContext?.playerCountV1,
        heroLabel: _normalizeUpperLabelV1(
          resolvedSeatContextStateV1?.heroSeatV1 ?? positionContext?.heroSeatV1,
        ),
        villainLabel: _normalizeUpperLabelV1(
          resolvedSeatContextStateV1?.villainSeatV1 ??
              positionContext?.villainSeatV1,
        ),
        activeSeats: _normalizeUpperLabelsV1(
          resolvedSeatContextStateV1?.activeSeatsV1 ??
              positionContext?.activeSeatsV1,
        ),
        foldedSeats: _normalizeUpperLabelsV1(
          resolvedSeatContextStateV1?.foldedSeatsV1 ??
              positionContext?.foldedSeatsV1,
        ),
        emptySeats: _normalizeUpperLabelsV1(
          resolvedSeatContextStateV1?.emptySeatsV1 ??
              positionContext?.emptySeatsV1,
        ),
      );
    case FactualRunnerHostFamilyV1.outs:
      final outsContext = currentDrill?.spec.scenarioOutsContextV1;
      return SessionDrillCanonicalSourceMetaInputV1(
        family: family,
        street: _normalizeUpperLabelV1(
          resolvedOutsStateV1?.streetV1 ?? outsContext?.streetV1,
        ),
        heroLabel: _joinCardsV1(
          resolvedOutsStateV1?.heroHoleCardsV1 ?? outsContext?.heroHoleCardsV1,
        ),
        boardCards: _normalizeCardListV1(
          resolvedOutsStateV1?.boardCardsV1 ?? outsContext?.boardCardsV1,
        ),
      );
    case FactualRunnerHostFamilyV1.initiative:
      final initiativeContext = currentDrill?.spec.scenarioInitiativeContextV1;
      return SessionDrillCanonicalSourceMetaInputV1(
        family: family,
        street: _normalizeUpperLabelV1(
          resolvedSeatContextStateV1?.streetV1 ?? initiativeContext?.streetV1,
        ),
        playerCount:
            resolvedSeatContextStateV1?.playerCountV1 ??
            initiativeContext?.playerCountV1,
        heroLabel: _normalizeUpperLabelV1(
          resolvedSeatContextStateV1?.heroSeatV1 ??
              initiativeContext?.heroSeatV1,
        ),
        villainLabel: _normalizeUpperLabelV1(
          resolvedSeatContextStateV1?.villainSeatV1 ??
              initiativeContext?.villainSeatV1,
        ),
        activeSeats: _normalizeUpperLabelsV1(
          resolvedSeatContextStateV1?.activeSeatsV1 ??
              initiativeContext?.activeSeatsV1,
        ),
        lastAggressor: _normalizeUpperLabelV1(
          resolvedSeatContextStateV1?.lastAggressorV1 ??
              initiativeContext?.lastAggressorV1,
        ),
        initiativeOwner: _normalizeUpperLabelV1(
          resolvedSeatContextStateV1?.initiativeOwnerV1 ??
              initiativeContext?.initiativeOwnerV1,
        ),
      );
    case FactualRunnerHostFamilyV1.texture:
      final textureContext = currentDrill?.spec.scenarioBoardTextureContextV1;
      return SessionDrillCanonicalSourceMetaInputV1(
        family: family,
        street: _normalizeUpperLabelV1(
          resolvedTextureStateV1?.streetV1 ?? textureContext?.streetV1,
        ),
        boardCards: _normalizeCardListV1(
          resolvedTextureStateV1?.boardCardsV1 ?? textureContext?.boardCardsV1,
        ),
      );
    case FactualRunnerHostFamilyV1.factualHandChain:
      final boardContext =
          resolvedHandChainStateV1?.tableContextV1?.boardContextV1 ??
          handChainStep?.tableContextV1?.boardContextV1;
      return SessionDrillCanonicalSourceMetaInputV1(
        family: family,
        street: _normalizeUpperLabelV1(
          resolvedHandChainStateV1?.coreV1.streetV1 ??
              handChainStep?.coreV1.streetV1,
        ),
        heroLabel: _joinCardsV1(boardContext?.heroHoleCardsV1),
        boardCards: _normalizeCardListV1(boardContext?.boardCardsV1),
      );
  }
}

List<RunnerHostSourceMetaEntryV1> buildSessionDrillCanonicalSourceMetaEntriesV1(
  SessionDrillCanonicalSourceMetaInputV1 input,
) {
  switch (input.family) {
    case FactualRunnerHostFamilyV1.position:
      if (input.street == null ||
          input.playerCount == null ||
          input.heroLabel == null ||
          input.villainLabel == null ||
          input.activeSeats == null) {
        return const <RunnerHostSourceMetaEntryV1>[];
      }
      return <RunnerHostSourceMetaEntryV1>[
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_position_source_street_v1',
          text: 'Street: ${input.street!}',
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_position_source_players_v1',
          text: 'Players: ${input.playerCount}',
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_position_source_hero_v1',
          text: 'Hero: ${input.heroLabel!}',
          useBodySmall: true,
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_position_source_villain_v1',
          text: 'Villain: ${input.villainLabel!}',
          useBodySmall: true,
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_position_source_active_v1',
          text: 'Active: ${input.activeSeats!.join(', ')}',
          useBodySmall: true,
        ),
        if (input.foldedSeats != null && input.foldedSeats!.isNotEmpty)
          RunnerHostSourceMetaEntryV1(
            testKey: 'session_drill_player_position_source_folded_v1',
            text: 'Folded: ${input.foldedSeats!.join(', ')}',
            useBodySmall: true,
          ),
        if (input.emptySeats != null && input.emptySeats!.isNotEmpty)
          RunnerHostSourceMetaEntryV1(
            testKey: 'session_drill_player_position_source_empty_v1',
            text: 'Empty: ${input.emptySeats!.join(', ')}',
            useBodySmall: true,
          ),
      ];
    case FactualRunnerHostFamilyV1.outs:
      if (input.street == null ||
          input.heroLabel == null ||
          input.boardCards == null) {
        return const <RunnerHostSourceMetaEntryV1>[];
      }
      return <RunnerHostSourceMetaEntryV1>[
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_outs_source_street_v1',
          text: 'Street: ${input.street!}',
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_outs_source_hero_v1',
          text: 'Hero: ${input.heroLabel!}',
          useBodySmall: true,
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_outs_source_board_v1',
          text: 'Board: ${input.boardCards!.join(' ')}',
          useBodySmall: true,
        ),
      ];
    case FactualRunnerHostFamilyV1.initiative:
      if (input.street == null ||
          input.playerCount == null ||
          input.heroLabel == null ||
          input.villainLabel == null ||
          input.activeSeats == null ||
          input.lastAggressor == null ||
          input.initiativeOwner == null) {
        return const <RunnerHostSourceMetaEntryV1>[];
      }
      return <RunnerHostSourceMetaEntryV1>[
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_initiative_source_street_v1',
          text: 'Street: ${input.street!}',
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_initiative_source_players_v1',
          text: 'Players: ${input.playerCount}',
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_initiative_source_hero_v1',
          text: 'Hero: ${input.heroLabel!}',
          useBodySmall: true,
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_initiative_source_villain_v1',
          text: 'Villain: ${input.villainLabel!}',
          useBodySmall: true,
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_initiative_source_active_v1',
          text: 'Active: ${input.activeSeats!.join(', ')}',
          useBodySmall: true,
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_initiative_source_last_aggressor_v1',
          text: 'Last Aggressor: ${input.lastAggressor!}',
          useBodySmall: true,
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_initiative_source_owner_v1',
          text: 'Initiative: ${input.initiativeOwner!}',
          useBodySmall: true,
        ),
      ];
    case FactualRunnerHostFamilyV1.texture:
      if (input.street == null || input.boardCards == null) {
        return const <RunnerHostSourceMetaEntryV1>[];
      }
      return <RunnerHostSourceMetaEntryV1>[
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_source_street_v1',
          text: 'Street: ${input.street!}',
        ),
        RunnerHostSourceMetaEntryV1(
          testKey: 'session_drill_player_source_board_v1',
          text: 'Board: ${input.boardCards!.join(' ')}',
          useBodySmall: true,
        ),
      ];
    case FactualRunnerHostFamilyV1.factualHandChain:
      if (input.street == null &&
          (input.heroLabel == null || input.heroLabel!.isEmpty) &&
          (input.boardCards == null || input.boardCards!.isEmpty)) {
        return const <RunnerHostSourceMetaEntryV1>[];
      }
      return <RunnerHostSourceMetaEntryV1>[
        if (input.street != null)
          RunnerHostSourceMetaEntryV1(
            testKey: 'session_drill_player_hand_chain_source_street_v1',
            text: 'Street: ${input.street!}',
          ),
        if (input.heroLabel != null && input.heroLabel!.isNotEmpty)
          RunnerHostSourceMetaEntryV1(
            testKey: 'session_drill_player_hand_chain_source_hero_v1',
            text: 'Hero: ${input.heroLabel!}',
            useBodySmall: true,
          ),
        if (input.boardCards != null && input.boardCards!.isNotEmpty)
          RunnerHostSourceMetaEntryV1(
            testKey: 'session_drill_player_hand_chain_source_board_v1',
            text: 'Board: ${input.boardCards!.join(' ')}',
            useBodySmall: true,
          ),
      ];
  }
}

String? _normalizeUpperLabelV1(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return trimmed.toUpperCase();
}

List<String>? _normalizeUpperLabelsV1(List<String>? values) {
  if (values == null) return null;
  final normalized = values
      .map(_normalizeUpperLabelV1)
      .whereType<String>()
      .toList(growable: false);
  return normalized;
}

List<String>? _normalizeCardListV1(List<String>? cards) {
  if (cards == null) return null;
  final normalized = cards
      .map((card) => card.trim())
      .where((card) => card.isNotEmpty)
      .toList(growable: false);
  return normalized;
}

String? _joinCardsV1(List<String>? cards) {
  final normalized = _normalizeCardListV1(cards);
  if (normalized == null || normalized.isEmpty) return null;
  return normalized.join(' ');
}
