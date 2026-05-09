import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';

abstract class ScenarioReplayerEvent {
  const ScenarioReplayerEvent();
}

class StartHandEvent extends ScenarioReplayerEvent {
  const StartHandEvent();
}

class SubmitActionEvent extends ScenarioReplayerEvent {
  const SubmitActionEvent({
    required this.seat,
    required this.kind,
    this.amount,
  });

  final ReplayerSeat seat;
  final ReplayerActionKind kind;
  final int? amount;
}

class ResolveStreetEvent extends ScenarioReplayerEvent {
  const ResolveStreetEvent();
}

class CompleteEvaluationEvent extends ScenarioReplayerEvent {
  const CompleteEvaluationEvent();
}
