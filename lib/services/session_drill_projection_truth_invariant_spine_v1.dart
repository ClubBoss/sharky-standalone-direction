import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_truth_reconciliation_v1.dart';

ScenarioSpecV1 buildValidatedSessionDrillProjectedScenarioV1({
  required String errorPrefix,
  required SessionDrillReconciledTableTruthV1 reconciledTruthV1,
  required Street streetV1,
  required List<String> legalActionsV1,
  required String solutionBestActionV1,
}) {
  validateSessionDrillProjectionInvariantSpineV1(
    errorPrefix: errorPrefix,
    reconciledTruthV1: reconciledTruthV1,
  );
  final scenario = reconciledTruthV1.buildScenarioSpec(
    streetV1: streetV1,
    legalActionsV1: legalActionsV1,
    solutionBestActionV1: solutionBestActionV1,
  );
  scenario.validate();
  return scenario;
}

void validateSessionDrillProjectionInvariantSpineV1({
  required String errorPrefix,
  required SessionDrillReconciledTableTruthV1 reconciledTruthV1,
}) {
  if (reconciledTruthV1.heroSeatV1 == reconciledTruthV1.villainSeatV1) {
    throw StateError('$errorPrefix requires hero/villain seats to differ');
  }
  if (reconciledTruthV1.seatOrderV1.length != reconciledTruthV1.playerCountV1) {
    throw StateError('$errorPrefix requires seat order length to match player_count_v1');
  }
  if (reconciledTruthV1.seatOrderV1.toSet().length !=
      reconciledTruthV1.seatOrderV1.length) {
    throw StateError('$errorPrefix requires unique reconciled seat order');
  }
  final heroOccupancy =
      reconciledTruthV1.seatOccupanciesV1[reconciledTruthV1.heroSeatIndexV1];
  if (heroOccupancy == ScenarioSeatOccupancyV1.empty) {
    throw StateError('$errorPrefix requires hero seat to be non-empty');
  }
  final villainSeatIndexV1 =
      reconciledTruthV1.seatOrderV1.indexOf(reconciledTruthV1.villainSeatV1);
  if (villainSeatIndexV1 < 0) {
    throw StateError('$errorPrefix requires villain seat inside reconciled seat order');
  }
  final villainOccupancy =
      reconciledTruthV1.seatOccupanciesV1[villainSeatIndexV1];
  if (villainOccupancy == ScenarioSeatOccupancyV1.empty) {
    throw StateError('$errorPrefix requires villain seat to be non-empty');
  }
  final actingOccupancy =
      reconciledTruthV1.seatOccupanciesV1[reconciledTruthV1.actingSeatIndexV1];
  if (actingOccupancy != ScenarioSeatOccupancyV1.active) {
    throw StateError('$errorPrefix requires acting seat to be active');
  }
  final blindLevelState = reconciledTruthV1.blindLevelStateV1;
  if (blindLevelState != null) {
    if (reconciledTruthV1.seatOccupanciesV1[blindLevelState.smallBlindSeatIndexV1] ==
        ScenarioSeatOccupancyV1.empty) {
      throw StateError('$errorPrefix requires small blind seat to be non-empty');
    }
    if (reconciledTruthV1.seatOccupanciesV1[blindLevelState.bigBlindSeatIndexV1] ==
        ScenarioSeatOccupancyV1.empty) {
      throw StateError('$errorPrefix requires big blind seat to be non-empty');
    }
  }
}
