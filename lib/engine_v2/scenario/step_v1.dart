import '../fsm/engine_fsm_v1.dart';
import '../model/action_v1.dart';
import '../model/money_state_v1.dart';

class StepExpectationV1 {
  const StepExpectationV1({
    required this.expectedAction,
    this.allowAlternatives = const <ActionV1>[],
  });

  final ActionV1 expectedAction;
  final List<ActionV1> allowAlternatives;

  bool matches(ActionV1 action) {
    if (action == expectedAction) {
      return true;
    }
    return allowAlternatives.any((candidate) => candidate == action);
  }

  @override
  bool operator ==(Object other) {
    if (other is! StepExpectationV1) {
      return false;
    }
    return expectedAction == other.expectedAction &&
        _listEquals(allowAlternatives, other.allowAlternatives);
  }

  @override
  int get hashCode =>
      Object.hash(expectedAction, Object.hashAll(allowAlternatives));
}

abstract class StepV1 {
  const StepV1();

  EngineEventV1 toEvent();

  String get label;
}

class StartHandStepV1 extends StepV1 {
  const StartHandStepV1();

  @override
  EngineEventV1 toEvent() => const StartHandEventV1();

  @override
  String get label => 'startHand';

  @override
  bool operator ==(Object other) => other is StartHandStepV1;

  @override
  int get hashCode => 1;
}

class PlayerActionStepV1 extends StepV1 {
  const PlayerActionStepV1({
    required this.playerId,
    required this.action,
    this.expectation,
  });

  final PlayerIdV1 playerId;
  final ActionV1 action;
  final StepExpectationV1? expectation;

  @override
  EngineEventV1 toEvent() => PlayerActionEventV1(action);

  @override
  String get label => 'playerAction:${playerId.value}:${action.kind.name}';

  @override
  bool operator ==(Object other) {
    if (other is! PlayerActionStepV1) {
      return false;
    }
    return playerId == other.playerId &&
        action == other.action &&
        expectation == other.expectation;
  }

  @override
  int get hashCode => Object.hash(playerId, action, expectation);
}

class AdvanceStepV1 extends StepV1 {
  const AdvanceStepV1();

  @override
  EngineEventV1 toEvent() => const AdvanceEventV1();

  @override
  String get label => 'advance';

  @override
  bool operator ==(Object other) => other is AdvanceStepV1;

  @override
  int get hashCode => 2;
}

class FinishStepV1 extends StepV1 {
  const FinishStepV1();

  @override
  EngineEventV1 toEvent() => const FinishEventV1();

  @override
  String get label => 'finish';

  @override
  bool operator ==(Object other) => other is FinishStepV1;

  @override
  int get hashCode => 3;
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
