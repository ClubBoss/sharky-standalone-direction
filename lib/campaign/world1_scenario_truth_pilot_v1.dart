import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/canonical/learner_action_semantics_v1.dart';
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';

enum World1ScenarioTruthFamilyV1 {
  actionChoiceEarlyDecision,
  handLoopMismatchFooterFeedback,
}

class World1ScenarioTruthPilotV1 {
  const World1ScenarioTruthPilotV1({
    required this.family,
    required this.visibleAffordancesV1,
    required this.expectedActionFamilyV1,
    required this.acceptableActionsV1,
    required this.whyV1,
    required this.feedbackCorrectV1,
    required this.feedbackIncorrectV1,
    required this.requiredFocusLabelV1,
  });

  final World1ScenarioTruthFamilyV1 family;
  final List<String> visibleAffordancesV1;
  final ActionKindV1 expectedActionFamilyV1;
  final List<String> acceptableActionsV1;
  final String whyV1;
  final String feedbackCorrectV1;
  final String feedbackIncorrectV1;
  final String requiredFocusLabelV1;
}

World1ScenarioTruthPilotV1? world1ScenarioTruthPilotForStepV1({
  required MicroTaskStep step,
  required World1ScenarioTruthFamilyV1 family,
}) {
  final toCall = step.toCall ?? 0;
  final isPreflop = step.street == null;
  final normalizedAllowed = _normalizedAllowedActionsV1(
    step.allowedActions,
    isPreflop: isPreflop,
    toCall: toCall,
  );
  if (normalizedAllowed.isEmpty) {
    return null;
  }
  final expectedAction = world1ScenarioTruthExpectedActionKindV1(step);
  if (expectedAction == null) {
    return null;
  }
  final acceptableActions = _acceptableActionsV1(
    allowedActions: normalizedAllowed,
    expectedAction: expectedAction,
  );
  return World1ScenarioTruthPilotV1(
    family: family,
    visibleAffordancesV1: normalizedAllowed,
    expectedActionFamilyV1: expectedAction,
    acceptableActionsV1: acceptableActions,
    whyV1: _scenarioWhyLineV1(
      expectedAction: expectedAction,
      toCall: toCall,
      isPreflop: isPreflop,
    ),
    feedbackCorrectV1: _scenarioCorrectLineV1(
      expectedAction: expectedAction,
      toCall: toCall,
      isPreflop: isPreflop,
      allowedActions: step.allowedActions,
    ),
    feedbackIncorrectV1: _scenarioIncorrectLineV1(
      expectedAction: expectedAction,
    ),
    requiredFocusLabelV1: _requiredFocusLabelV1(
      expectedAction: expectedAction,
      toCall: toCall,
    ),
  );
}

ActionKindV1? world1ScenarioTruthExpectedActionKindV1(MicroTaskStep step) {
  final toCall = step.toCall ?? 0;
  final isPreflop = step.street == null;
  final actions = _normalizedAllowedActionsV1(
    step.allowedActions,
    isPreflop: isPreflop,
    toCall: toCall,
  ).toSet();
  if (actions.isEmpty) {
    return _explicitExpectedActionKindV1(
      step.expectedActionKind,
      isPreflop: isPreflop,
      toCall: toCall,
    );
  }

  final explicit = _explicitExpectedActionKindV1(
    step.expectedActionKind,
    isPreflop: isPreflop,
    toCall: toCall,
  );
  final hasRaise =
      actions.contains('raise') ||
      actions.contains('raise_to') ||
      actions.contains('raise_min');
  final isIllegalFacingBetExplicit =
      toCall > 0 &&
      (explicit == ActionKindV1.check || explicit == ActionKindV1.bet);
  final isIllegalNoToCallExplicit =
      toCall == 0 && explicit == ActionKindV1.call;
  if (explicit != null &&
      !isIllegalFacingBetExplicit &&
      !isIllegalNoToCallExplicit) {
    return explicit;
  }

  if (toCall > 0) {
    if (hasRaise) return ActionKindV1.raise;
    if (actions.contains('call')) return ActionKindV1.call;
    if (actions.contains('fold')) return ActionKindV1.fold;
    return null;
  }

  if (actions.contains('bet')) return ActionKindV1.bet;
  if (actions.contains('check')) return ActionKindV1.check;
  if (actions.contains('fold')) return ActionKindV1.fold;
  return null;
}

String? world1ScenarioTruthExpectedLineV1(MicroTaskStep step) {
  final expected = world1ScenarioTruthExpectedActionKindV1(step);
  if (expected == null) return null;
  final expectedLabel = _actionKindLabelV1(
    expected,
    isPreflop: step.street == null,
    toCall: step.toCall ?? 0,
    allowedActions: step.allowedActions,
  );
  return 'Expected: $expectedLabel';
}

List<String> validateWorld1ScenarioTruthPilotStepV1({
  required String packId,
  required int stepIndex,
  required MicroTaskStep step,
  required World1ScenarioTruthFamilyV1 family,
}) {
  final errors = <String>[];
  final toCall = step.toCall ?? 0;
  final isPreflop = step.street == null;
  final allowedActions = _normalizedAllowedActionsV1(
    step.allowedActions,
    isPreflop: isPreflop,
    toCall: toCall,
  );
  if (allowedActions.isEmpty) {
    return errors;
  }

  final truth = world1ScenarioTruthPilotForStepV1(step: step, family: family);
  if (truth == null) {
    errors.add(
      'pack=$packId step=$stepIndex family=${family.name}: missing pilot scenario truth',
    );
    return errors;
  }
  if (truth.requiredFocusLabelV1.trim().isEmpty) {
    errors.add(
      'pack=$packId step=$stepIndex family=${family.name}: missing required_focus_label_v1',
    );
  }

  final explicitExpected = _explicitExpectedActionKindV1(
    step.expectedActionKind,
    isPreflop: isPreflop,
    toCall: toCall,
  );
  if (explicitExpected == ActionKindV1.check && toCall > 0) {
    errors.add(
      'pack=$packId step=$stepIndex family=${family.name}: illegal explicit expected CHECK while facing bet',
    );
  }
  if (explicitExpected == ActionKindV1.bet && toCall > 0) {
    errors.add(
      'pack=$packId step=$stepIndex family=${family.name}: illegal explicit expected BET while facing bet',
    );
  }
  if (explicitExpected == ActionKindV1.call && toCall == 0) {
    errors.add(
      'pack=$packId step=$stepIndex family=${family.name}: illegal explicit expected CALL with nothing to call',
    );
  }

  if (!_allowedActionsContainKindV1(
    allowedActions: allowedActions,
    actionKind: truth.expectedActionFamilyV1,
  )) {
    errors.add(
      'pack=$packId step=$stepIndex family=${family.name}: expected action is not legal in allowed actions',
    );
  }

  if (!_whyCoherentWithExpectedV1(
    whyLine: truth.whyV1,
    expectedAction: truth.expectedActionFamilyV1,
    toCall: toCall,
    isPreflop: isPreflop,
  )) {
    errors.add(
      'pack=$packId step=$stepIndex family=${family.name}: expected/why coherence failure',
    );
  }

  final acceptableSortedUnique = truth.acceptableActionsV1.toSet().toList()
    ..sort();
  if (truth.acceptableActionsV1.length != acceptableSortedUnique.length ||
      !_listEqualsV1(truth.acceptableActionsV1, acceptableSortedUnique)) {
    errors.add(
      'pack=$packId step=$stepIndex family=${family.name}: acceptable actions must be deduped and sorted',
    );
  }
  for (final action in truth.acceptableActionsV1) {
    if (!allowedActions.contains(action)) {
      errors.add(
        'pack=$packId step=$stepIndex family=${family.name}: acceptable action "$action" is not legal for step',
      );
    }
    if (_actionTokenMatchesKindV1(action, truth.expectedActionFamilyV1)) {
      errors.add(
        'pack=$packId step=$stepIndex family=${family.name}: acceptable action "$action" duplicates expected family',
      );
    }
  }

  return errors;
}

ActionKindV1? _explicitExpectedActionKindV1(
  String? raw, {
  required bool isPreflop,
  required int toCall,
}) {
  final explicit = raw?.trim().toLowerCase().replaceAll('-', '_');
  if (explicit == null || explicit.isEmpty) {
    return null;
  }
  final kind = switch (explicit) {
    'fold' => ActionKindV1.fold,
    'check' => ActionKindV1.check,
    'call' => ActionKindV1.call,
    'bet' => ActionKindV1.bet,
    'raise' || 'raise_to' || 'raise_min' => ActionKindV1.raise,
    _ => null,
  };
  if (kind == null) {
    return null;
  }
  return canonicalizeLearnerActionKindV1(
    kind: kind,
    isPreflop: isPreflop,
    toCall: toCall,
  );
}

List<String> _normalizedAllowedActionsV1(
  List<String>? allowedActions, {
  required bool isPreflop,
  required int toCall,
}) {
  final normalized = <String>{};
  for (final raw in allowedActions ?? const <String>[]) {
    final token = canonicalizeLearnerActionTokenV1(
      token: raw,
      isPreflop: isPreflop,
      toCall: toCall,
    );
    if (token.isEmpty) continue;
    normalized.add(token);
  }
  final ordered = normalized.toList()..sort();
  return ordered;
}

List<String> _acceptableActionsV1({
  required List<String> allowedActions,
  required ActionKindV1 expectedAction,
}) {
  final acceptable =
      allowedActions
          .where((token) => !_actionTokenMatchesKindV1(token, expectedAction))
          .toSet()
          .toList()
        ..sort();
  return acceptable;
}

bool _actionTokenMatchesKindV1(String token, ActionKindV1 kind) {
  switch (kind) {
    case ActionKindV1.fold:
      return token == 'fold';
    case ActionKindV1.check:
      return token == 'check';
    case ActionKindV1.call:
      return token == 'call';
    case ActionKindV1.bet:
      return token == 'bet';
    case ActionKindV1.raise:
      return token == 'raise' || token == 'raise_to' || token == 'raise_min';
  }
}

bool _allowedActionsContainKindV1({
  required List<String> allowedActions,
  required ActionKindV1 actionKind,
}) {
  return allowedActions.any(
    (token) => _actionTokenMatchesKindV1(token, actionKind),
  );
}

String _actionKindLabelV1(
  ActionKindV1 kind, {
  required bool isPreflop,
  required int toCall,
  List<String>? allowedActions,
}) {
  final canonicalKind = canonicalizeLearnerActionKindV1(
    kind: kind,
    isPreflop: isPreflop,
    toCall: toCall,
  );
  switch (kind) {
    case ActionKindV1.fold:
      return 'FOLD';
    case ActionKindV1.check:
      return 'CHECK';
    case ActionKindV1.call:
      return 'CALL';
    case ActionKindV1.bet:
      if (canonicalKind == ActionKindV1.raise) {
        return _actionKindLabelV1(
          ActionKindV1.raise,
          isPreflop: isPreflop,
          toCall: toCall,
          allowedActions: allowedActions,
        );
      }
      return 'BET';
    case ActionKindV1.raise:
      final actions = _normalizedAllowedActionsV1(
        allowedActions,
        isPreflop: isPreflop,
        toCall: toCall,
      );
      final hasRaiseMin = actions.contains('raise_min');
      final hasRaiseTo = actions.contains('raise_to');
      final hasRaise = actions.contains('raise');
      if (hasRaiseMin && !hasRaiseTo && !hasRaise) {
        return 'RAISE MIN';
      }
      if (hasRaiseTo) {
        return 'RAISE TO';
      }
      if (hasRaise) {
        return 'RAISE';
      }
      return 'RAISE';
  }
}

String _scenarioWhyLineV1({
  required ActionKindV1 expectedAction,
  required int toCall,
  required bool isPreflop,
}) {
  if (toCall > 0) {
    switch (expectedAction) {
      case ActionKindV1.raise:
        return 'Why: This spot rewards aggression more than calling.';
      case ActionKindV1.call:
        return 'Why: Call keeps dominated hands in while staying legal.';
      case ActionKindV1.fold:
        return 'Why: Folding avoids paying off in a low-equity spot.';
      case ActionKindV1.check:
      case ActionKindV1.bet:
        return 'Why: You must call, fold, or raise when facing a bet.';
    }
  }
  switch (expectedAction) {
    case ActionKindV1.bet:
      return 'Why: Betting is the higher-EV play here.';
    case ActionKindV1.check:
      return 'Why: Check is free and keeps this spot controlled.';
    case ActionKindV1.fold:
      return 'Why: Folding for free gives up equity.';
    case ActionKindV1.call:
      return 'Why: There is nothing to call. Check is free.';
    case ActionKindV1.raise:
      if (isPreflop) {
        return 'Why: Preflop with nothing to call still uses check or raise.';
      }
      return 'Why: There is nothing to call. Bet is the first action.';
  }
}

String _scenarioCorrectLineV1({
  required ActionKindV1 expectedAction,
  required int toCall,
  required bool isPreflop,
  List<String>? allowedActions,
}) {
  if (toCall == 0 && expectedAction == ActionKindV1.check) {
    return 'Correct: Check is free.';
  }
  if (toCall == 0 && expectedAction == ActionKindV1.bet) {
    return 'Correct: Bet starts the action.';
  }
  if (toCall == 0 && expectedAction == ActionKindV1.raise && isPreflop) {
    final raiseLabel = _actionKindLabelV1(
      ActionKindV1.raise,
      isPreflop: isPreflop,
      toCall: toCall,
      allowedActions: allowedActions,
    );
    return 'Correct: $raiseLabel keeps the preflop action honest.';
  }
  if (toCall > 0 && expectedAction == ActionKindV1.call) {
    return 'Correct: Call matches the bet.';
  }
  if (toCall > 0 && expectedAction == ActionKindV1.fold) {
    return 'Correct: Fold ends the hand.';
  }
  if (toCall > 0 && expectedAction == ActionKindV1.raise) {
    final raiseLabel = _actionKindLabelV1(
      ActionKindV1.raise,
      isPreflop: isPreflop,
      toCall: toCall,
      allowedActions: allowedActions,
    );
    if (raiseLabel == 'RAISE MIN') {
      return 'Correct: RAISE MIN applies pressure.';
    }
    if (raiseLabel == 'RAISE TO') {
      return 'Correct: RAISE TO applies pressure.';
    }
    return 'Correct: Raise increases the bet.';
  }
  return 'Correct: Spot resolved.';
}

String _scenarioIncorrectLineV1({required ActionKindV1 expectedAction}) {
  switch (expectedAction) {
    case ActionKindV1.fold:
      return 'You can do that, but folding is better here.';
    case ActionKindV1.check:
      return 'You can do that, but checking is better here.';
    case ActionKindV1.call:
      return 'You can do that, but calling is better here.';
    case ActionKindV1.bet:
      return 'You can do that, but betting is better here.';
    case ActionKindV1.raise:
      return 'You can do that, but raising is better here.';
  }
}

String _requiredFocusLabelV1({
  required ActionKindV1 expectedAction,
  required int toCall,
}) {
  if (toCall > 0) return 'facing_bet_decision';
  switch (expectedAction) {
    case ActionKindV1.bet:
    case ActionKindV1.raise:
      return 'initiative_pressure';
    case ActionKindV1.check:
    case ActionKindV1.call:
    case ActionKindV1.fold:
      return 'to_call_discipline';
  }
}

bool _whyCoherentWithExpectedV1({
  required String whyLine,
  required ActionKindV1 expectedAction,
  required int toCall,
  required bool isPreflop,
}) {
  final normalized = whyLine.trim().toLowerCase();
  if (!normalized.startsWith('why:')) return false;
  if (toCall > 0 &&
      (expectedAction == ActionKindV1.check ||
          expectedAction == ActionKindV1.bet)) {
    return normalized.contains('must call, fold, or raise');
  }
  switch (expectedAction) {
    case ActionKindV1.raise:
      if (isPreflop && toCall == 0) {
        return normalized.contains('check or raise') ||
            normalized.contains('preflop');
      }
      return normalized.contains('aggression') ||
          normalized.contains('pressure') ||
          normalized.contains('raise');
    case ActionKindV1.bet:
      return normalized.contains('bet');
    case ActionKindV1.call:
      return normalized.contains('call');
    case ActionKindV1.check:
      return normalized.contains('check');
    case ActionKindV1.fold:
      return normalized.contains('fold');
  }
}

bool _listEqualsV1(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
