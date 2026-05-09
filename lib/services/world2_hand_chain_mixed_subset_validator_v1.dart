import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/world2_action_choice_policy_validator_v1.dart';
import 'package:poker_analyzer/services/world2_initiative_truth_validator_v1.dart';
import 'package:poker_analyzer/services/world2_outs_truth_validator_v1.dart';
import 'package:poker_analyzer/services/world2_position_truth_validator_v1.dart';

const Set<String> kWorld2HandChainMixedFactualReusableClusterIdsV1 = <String>{
  'w2_s07_position_then_initiative_v1',
  'w2_s08_texture_then_outs_v1',
  'w2_s09_position_initiative_texture_v1',
};
const Set<String> kWorld2HandChainMixedPositionInitiativePolicyClusterIdsV1 =
    <String>{'w2_s11_position_initiative_action_v1'};
const Set<String> kWorld2HandChainMixedTextureOutsFollowUpClusterIdsV1 =
    <String>{
      'w2_s10_texture_outs_action_v1',
      'w2_s13_texture_outs_continue_v1',
      'w2_s14_texture_outs_fold_v1',
    };
const Set<String> kWorld2HandChainMixedTextureOutsClusterIdsV1 = <String>{
  'w2_s08_texture_then_outs_v1',
};
const Set<String> kWorld2HandChainMixedCapstoneClusterIdsV1 = <String>{
  'w2_s12_world2_capstone_v1',
};

enum World2HandChainSubsetClassV1 {
  factualReusable,
  policyCoupled,
  capstoneComposition,
}

class World2HandChainMixedSubsetValidationReportV1 {
  const World2HandChainMixedSubsetValidationReportV1({
    required this.familySources,
    required this.checkedCount,
    required this.skippedCount,
    required this.checkedSources,
    required this.skippedSources,
    required this.skippedReasons,
    required this.issues,
    required this.factualSubsetSources,
    required this.policyCoupledSources,
    required this.capstoneSources,
  });

  final List<String> familySources;
  final int checkedCount;
  final int skippedCount;
  final List<String> checkedSources;
  final List<String> skippedSources;
  final Map<String, String> skippedReasons;
  final List<String> issues;
  final List<String> factualSubsetSources;
  final List<String> policyCoupledSources;
  final List<String> capstoneSources;
}

World2HandChainSubsetClassV1? classifyWorld2HandChainSubsetV1(
  DrillSpecV1 spec,
) {
  if (spec.kind != DrillKindV1.handChain) {
    return null;
  }
  if (kWorld2HandChainMixedFactualReusableClusterIdsV1.contains(
    spec.chainIdV1,
  )) {
    return World2HandChainSubsetClassV1.factualReusable;
  }
  if (kWorld2HandChainMixedPositionInitiativePolicyClusterIdsV1.contains(
        spec.chainIdV1,
      ) ||
      kWorld2HandChainMixedTextureOutsFollowUpClusterIdsV1.contains(
        spec.chainIdV1,
      )) {
    return World2HandChainSubsetClassV1.policyCoupled;
  }
  if (kWorld2HandChainMixedCapstoneClusterIdsV1.contains(spec.chainIdV1)) {
    return World2HandChainSubsetClassV1.capstoneComposition;
  }
  return null;
}

List<String> validateWorld2HandChainMixedSubsetSpecV1({
  required DrillSpecV1 spec,
  required String source,
}) {
  if (!_isSupportedWorld2HandChainMixedPilotSpecV1(spec)) {
    return const <String>[];
  }

  final issues = <String>[];
  final steps = spec.chainStepsV1!;
  if (spec.chainIdV1 == 'w2_s07_position_then_initiative_v1') {
    return _validatePositionThenInitiativePilotV1(
      spec: spec,
      source: source,
      steps: steps,
    );
  }
  if (spec.chainIdV1 == 'w2_s09_position_initiative_texture_v1') {
    return _validatePositionInitiativePolicyClusterV1(
      spec: spec,
      source: source,
      steps: steps,
    );
  }
  if (kWorld2HandChainMixedPositionInitiativePolicyClusterIdsV1.contains(
    spec.chainIdV1,
  )) {
    return _validatePositionInitiativePolicyClusterV1(
      spec: spec,
      source: source,
      steps: steps,
    );
  }
  if (kWorld2HandChainMixedTextureOutsFollowUpClusterIdsV1.contains(
    spec.chainIdV1,
  )) {
    return _validateTextureOutsFollowUpClusterV1(
      spec: spec,
      source: source,
      steps: steps,
    );
  }
  if (kWorld2HandChainMixedTextureOutsClusterIdsV1.contains(spec.chainIdV1)) {
    return _validateTextureOutsClusterV1(
      spec: spec,
      source: source,
      steps: steps,
    );
  }
  if (kWorld2HandChainMixedCapstoneClusterIdsV1.contains(spec.chainIdV1)) {
    return _validateCapstoneClusterV1(spec: spec, source: source, steps: steps);
  }
  return issues;
}

List<String> _validatePositionThenInitiativePilotV1({
  required DrillSpecV1 spec,
  required String source,
  required List<DrillChainStepV1> steps,
}) {
  final issues = <String>[];
  if (steps.length != 2) {
    issues.add(
      '$source: mixed hand_chain pilot requires exactly 2 authored steps',
    );
    return issues;
  }
  final firstStep = steps.first;
  final secondStep = steps.last;

  if (firstStep.street != 'preflop') {
    issues.add('$source: mixed hand_chain pilot step1 must stay preflop');
  }
  if (secondStep.street != 'flop') {
    issues.add('$source: mixed hand_chain pilot step2 must stay flop');
  }

  issues.addAll(
    _validateRepeatedSeatStateV1(
      source: source,
      firstStep: firstStep,
      secondStep: secondStep,
    ),
  );

  issues.addAll(
    validateWorld2PositionTruthSpecV1(
      spec: _buildPositionSpecFromStepV1(
        chainSpec: spec,
        step: firstStep,
        stepIndex: 1,
      ),
      source: '$source#step1',
    ),
  );
  issues.addAll(
    validateWorld2InitiativeTruthSpecV1(
      spec: _buildInitiativeSpecFromStepV1(
        chainSpec: spec,
        step: secondStep,
        stepIndex: 2,
      ),
      source: '$source#step2',
    ),
  );
  return issues;
}

List<String> _validatePositionInitiativePolicyClusterV1({
  required DrillSpecV1 spec,
  required String source,
  required List<DrillChainStepV1> steps,
}) {
  final issues = <String>[];
  if (steps.length != 3) {
    issues.add(
      '$source: mixed hand_chain cluster requires exactly 3 authored steps',
    );
    return issues;
  }

  final firstStep = steps[0];
  final secondStep = steps[1];
  final thirdStep = steps[2];

  if (firstStep.street != 'preflop') {
    issues.add('$source: mixed hand_chain cluster step1 must stay preflop');
  }
  if (secondStep.street != 'flop') {
    issues.add('$source: mixed hand_chain cluster step2 must stay flop');
  }
  if (thirdStep.street != 'flop') {
    issues.add('$source: mixed hand_chain cluster step3 must stay flop');
  }

  issues.addAll(
    _validateRepeatedSeatStateV1(
      source: source,
      firstStep: firstStep,
      secondStep: secondStep,
    ),
  );
  issues.addAll(
    _validateRepeatedSeatStateV1(
      source: source,
      firstStep: secondStep,
      secondStep: thirdStep,
    ),
  );

  issues.addAll(
    validateWorld2PositionTruthSpecV1(
      spec: _buildPositionSpecFromStepV1(
        chainSpec: spec,
        step: firstStep,
        stepIndex: 1,
      ),
      source: '$source#step1',
    ),
  );
  issues.addAll(
    validateWorld2InitiativeTruthSpecV1(
      spec: _buildInitiativeSpecFromStepV1(
        chainSpec: spec,
        step: secondStep,
        stepIndex: 2,
      ),
      source: '$source#step2',
    ),
  );
  issues.addAll(
    validateWorld2ActionChoicePolicyChainStepV1(
      step: thirdStep,
      source: '$source#step3',
    ),
  );
  return issues;
}

List<String> _validateTextureOutsFollowUpClusterV1({
  required DrillSpecV1 spec,
  required String source,
  required List<DrillChainStepV1> steps,
}) {
  final issues = <String>[];
  if (steps.length != 3) {
    issues.add(
      '$source: mixed hand_chain cluster requires exactly 3 authored steps',
    );
    return issues;
  }

  final firstStep = steps[0];
  final secondStep = steps[1];
  final thirdStep = steps[2];

  if (firstStep.street != 'flop') {
    issues.add('$source: mixed hand_chain cluster step1 must stay flop');
  }
  if (secondStep.street != 'flop') {
    issues.add('$source: mixed hand_chain cluster step2 must stay flop');
  }
  if (thirdStep.street != 'flop') {
    issues.add('$source: mixed hand_chain cluster step3 must stay flop');
  }

  issues.addAll(
    _validateRepeatedSeatStateV1(
      source: source,
      firstStep: firstStep,
      secondStep: secondStep,
    ),
  );
  issues.addAll(
    _validateRepeatedSeatStateV1(
      source: source,
      firstStep: secondStep,
      secondStep: thirdStep,
    ),
  );
  issues.addAll(
    _validateRepeatedBoardStateV1(
      source: source,
      firstStep: firstStep,
      secondStep: secondStep,
      label: 'steps 1 and 2',
      requireHoleCards: false,
    ),
  );
  issues.addAll(
    _validateRepeatedBoardStateV1(
      source: source,
      firstStep: secondStep,
      secondStep: thirdStep,
      label: 'steps 2 and 3',
      requireHoleCards: true,
    ),
  );

  issues.addAll(
    validateWorld2ActionChoicePolicyChainStepV1(
      step: firstStep,
      source: '$source#step1',
    ),
  );
  issues.addAll(
    validateWorld2OutsTruthChainStepV1(
      step: secondStep,
      source: '$source#step2',
    ),
  );
  issues.addAll(
    validateWorld2ActionChoicePolicyChainStepV1(
      step: thirdStep,
      source: '$source#step3',
    ),
  );
  return issues;
}

List<String> _validateTextureOutsClusterV1({
  required DrillSpecV1 spec,
  required String source,
  required List<DrillChainStepV1> steps,
}) {
  final issues = <String>[];
  if (steps.length != 2) {
    issues.add(
      '$source: mixed hand_chain cluster requires exactly 2 authored steps',
    );
    return issues;
  }

  final firstStep = steps.first;
  final secondStep = steps.last;

  if (firstStep.street != 'flop') {
    issues.add('$source: mixed hand_chain cluster step1 must stay flop');
  }
  if (secondStep.street != 'flop') {
    issues.add('$source: mixed hand_chain cluster step2 must stay flop');
  }

  issues.addAll(
    _validateRepeatedBoardStateV1(
      source: source,
      firstStep: firstStep,
      secondStep: secondStep,
      label: 'steps 1 and 2',
      requireHoleCards: false,
    ),
  );

  issues.addAll(
    validateWorld2ActionChoicePolicyChainStepV1(
      step: firstStep,
      source: '$source#step1',
    ),
  );
  issues.addAll(
    validateWorld2OutsTruthChainStepV1(
      step: secondStep,
      source: '$source#step2',
    ),
  );
  return issues;
}

List<String> _validateCapstoneClusterV1({
  required DrillSpecV1 spec,
  required String source,
  required List<DrillChainStepV1> steps,
}) {
  final issues = <String>[];
  if (steps.length != 4) {
    issues.add(
      '$source: mixed hand_chain cluster requires exactly 4 authored steps',
    );
    return issues;
  }

  final firstStep = steps[0];
  final secondStep = steps[1];
  final thirdStep = steps[2];
  final fourthStep = steps[3];

  if (firstStep.street != 'preflop') {
    issues.add('$source: mixed hand_chain cluster step1 must stay preflop');
  }
  if (secondStep.street != 'flop') {
    issues.add('$source: mixed hand_chain cluster step2 must stay flop');
  }
  if (thirdStep.street != 'flop') {
    issues.add('$source: mixed hand_chain cluster step3 must stay flop');
  }
  if (fourthStep.street != 'flop') {
    issues.add('$source: mixed hand_chain cluster step4 must stay flop');
  }

  issues.addAll(
    _validateRepeatedSeatStateV1(
      source: source,
      firstStep: firstStep,
      secondStep: secondStep,
    ),
  );
  issues.addAll(
    _validateRepeatedSeatStateV1(
      source: source,
      firstStep: secondStep,
      secondStep: thirdStep,
    ),
  );
  issues.addAll(
    _validateRepeatedSeatStateV1(
      source: source,
      firstStep: thirdStep,
      secondStep: fourthStep,
    ),
  );
  issues.addAll(
    _validateRepeatedBoardStateV1(
      source: source,
      firstStep: thirdStep,
      secondStep: fourthStep,
      label: 'steps 3 and 4',
      requireHoleCards: false,
    ),
  );

  issues.addAll(
    validateWorld2PositionTruthSpecV1(
      spec: _buildPositionSpecFromStepV1(
        chainSpec: spec,
        step: firstStep,
        stepIndex: 1,
      ),
      source: '$source#step1',
    ),
  );
  issues.addAll(
    validateWorld2InitiativeTruthSpecV1(
      spec: _buildInitiativeSpecFromStepV1(
        chainSpec: spec,
        step: secondStep,
        stepIndex: 2,
      ),
      source: '$source#step2',
    ),
  );
  issues.addAll(
    validateWorld2ActionChoicePolicyChainStepV1(
      step: thirdStep,
      source: '$source#step3',
    ),
  );
  issues.addAll(
    validateWorld2ActionChoicePolicyChainStepV1(
      step: fourthStep,
      source: '$source#step4',
    ),
  );
  return issues;
}

World2HandChainMixedSubsetValidationReportV1
validateWorld2HandChainMixedSubsetDirectoryV1(String rootPath) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError(
      'World 2 hand_chain mixed subset validator root not found: $rootPath',
    );
  }

  final issues = <String>[];
  var checkedCount = 0;
  var skippedCount = 0;
  final familySources = <String>[];
  final checkedSources = <String>[];
  final skippedSources = <String>[];
  final skippedReasons = <String, String>{};
  final factualSubsetSources = <String>[];
  final policyCoupledSources = <String>[];
  final capstoneSources = <String>[];
  final files =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final spec = DrillSpecV1.fromJsonString(file.readAsStringSync());
    if (spec.kind != DrillKindV1.handChain) {
      continue;
    }
    familySources.add(file.path);
    if (!_isSupportedWorld2HandChainMixedPilotSpecV1(spec)) {
      skippedCount += 1;
      skippedSources.add(file.path);
      skippedReasons[file.path] =
          'excluded: bounded mixed hand_chain validator supports only the factual reusable cluster ${kWorld2HandChainMixedFactualReusableClusterIdsV1.toList()..sort()}, the position-initiative-policy cluster ${kWorld2HandChainMixedPositionInitiativePolicyClusterIdsV1.toList()..sort()}, the texture-outs-followup cluster ${kWorld2HandChainMixedTextureOutsFollowUpClusterIdsV1.toList()..sort()}, and the capstone cluster ${kWorld2HandChainMixedCapstoneClusterIdsV1.toList()..sort()}';
      continue;
    }
    checkedCount += 1;
    checkedSources.add(file.path);
    switch (classifyWorld2HandChainSubsetV1(spec)) {
      case World2HandChainSubsetClassV1.factualReusable:
        factualSubsetSources.add(file.path);
        break;
      case World2HandChainSubsetClassV1.policyCoupled:
        policyCoupledSources.add(file.path);
        break;
      case World2HandChainSubsetClassV1.capstoneComposition:
        capstoneSources.add(file.path);
        break;
      case null:
        break;
    }
    issues.addAll(
      validateWorld2HandChainMixedSubsetSpecV1(spec: spec, source: file.path),
    );
  }

  return World2HandChainMixedSubsetValidationReportV1(
    familySources: List<String>.unmodifiable(familySources),
    checkedCount: checkedCount,
    skippedCount: skippedCount,
    checkedSources: List<String>.unmodifiable(checkedSources),
    skippedSources: List<String>.unmodifiable(skippedSources),
    skippedReasons: Map<String, String>.unmodifiable(skippedReasons),
    issues: List<String>.unmodifiable(issues),
    factualSubsetSources: List<String>.unmodifiable(factualSubsetSources),
    policyCoupledSources: List<String>.unmodifiable(policyCoupledSources),
    capstoneSources: List<String>.unmodifiable(capstoneSources),
  );
}

bool _isSupportedWorld2HandChainMixedPilotSpecV1(DrillSpecV1 spec) {
  return spec.kind == DrillKindV1.handChain &&
      (kWorld2HandChainMixedFactualReusableClusterIdsV1.contains(
            spec.chainIdV1,
          ) ||
          kWorld2HandChainMixedPositionInitiativePolicyClusterIdsV1.contains(
            spec.chainIdV1,
          ) ||
          kWorld2HandChainMixedCapstoneClusterIdsV1.contains(spec.chainIdV1) ||
          kWorld2HandChainMixedTextureOutsFollowUpClusterIdsV1.contains(
            spec.chainIdV1,
          )) &&
      spec.chainStepsV1 != null;
}

List<String> _validateRepeatedSeatStateV1({
  required String source,
  required DrillChainStepV1 firstStep,
  required DrillChainStepV1 secondStep,
}) {
  final issues = <String>[];
  if (firstStep.playerCountV1 != secondStep.playerCountV1) {
    issues.add(
      '$source: mixed hand_chain pilot requires stable player_count_v1 across steps 1 and 2',
    );
  }
  if (firstStep.heroSeatV1 != secondStep.heroSeatV1) {
    issues.add(
      '$source: mixed hand_chain pilot requires stable hero_seat_v1 across steps 1 and 2',
    );
  }
  if (firstStep.villainSeatV1 != secondStep.villainSeatV1) {
    issues.add(
      '$source: mixed hand_chain pilot requires stable villain_seat_v1 across steps 1 and 2',
    );
  }
  if (!_sameStringListV1(firstStep.activeSeatsV1, secondStep.activeSeatsV1)) {
    issues.add(
      '$source: mixed hand_chain pilot requires stable active_seats_v1 across steps 1 and 2',
    );
  }
  if (!_sameStringListV1(firstStep.foldedSeatsV1, secondStep.foldedSeatsV1)) {
    issues.add(
      '$source: mixed hand_chain pilot requires stable folded_seats_v1 across steps 1 and 2',
    );
  }
  if (!_sameStringListV1(firstStep.emptySeatsV1, secondStep.emptySeatsV1)) {
    issues.add(
      '$source: mixed hand_chain pilot requires stable empty_seats_v1 across steps 1 and 2',
    );
  }
  return issues;
}

List<String> _validateRepeatedBoardStateV1({
  required String source,
  required DrillChainStepV1 firstStep,
  required DrillChainStepV1 secondStep,
  required String label,
  required bool requireHoleCards,
}) {
  final issues = <String>[];
  if (!_sameStringListV1(firstStep.boardCardsV1, secondStep.boardCardsV1)) {
    issues.add(
      '$source: mixed hand_chain cluster requires stable board_cards_v1 across $label',
    );
  }
  if (requireHoleCards) {
    if (!_sameStringListV1(
      firstStep.heroHoleCardsV1,
      secondStep.heroHoleCardsV1,
    )) {
      issues.add(
        '$source: mixed hand_chain cluster requires stable hero_hole_cards_v1 across $label',
      );
    }
  }
  return issues;
}

bool _sameStringListV1(List<String>? left, List<String>? right) {
  if (left == null || right == null) {
    return left == right;
  }
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) {
      return false;
    }
  }
  return true;
}

DrillSpecV1 _buildPositionSpecFromStepV1({
  required DrillSpecV1 chainSpec,
  required DrillChainStepV1 step,
  required int stepIndex,
}) {
  return DrillSpecV1(
    id: '${chainSpec.id}#step$stepIndex',
    kind: DrillKindV1.positionThinkingChoice,
    prompt: step.prompt,
    expected: DrillExpectedV1(actionId: step.expectedActionV1),
    errorClass: step.errorClass,
    questionShapeV1: step.questionShapeV1,
    whyV1: step.whyV1,
    availableActionsV1: step.availableActionsV1,
    streetV1: step.street,
    playerCountV1: step.playerCountV1,
    heroSeatV1: step.heroSeatV1,
    villainSeatV1: step.villainSeatV1,
    activeSeatsV1: step.activeSeatsV1,
    foldedSeatsV1: step.foldedSeatsV1,
    emptySeatsV1: step.emptySeatsV1,
    feedbackCorrectV1: step.feedbackCorrectV1,
    feedbackIncorrectV1: step.feedbackIncorrectV1,
  );
}

DrillSpecV1 _buildInitiativeSpecFromStepV1({
  required DrillSpecV1 chainSpec,
  required DrillChainStepV1 step,
  required int stepIndex,
}) {
  return DrillSpecV1(
    id: '${chainSpec.id}#step$stepIndex',
    kind: DrillKindV1.initiativeAggressorChoice,
    prompt: step.prompt,
    expected: DrillExpectedV1(actionId: step.expectedActionV1),
    errorClass: step.errorClass,
    whyV1: step.whyV1,
    availableActionsV1: step.availableActionsV1,
    streetV1: step.street,
    playerCountV1: step.playerCountV1,
    heroSeatV1: step.heroSeatV1,
    villainSeatV1: step.villainSeatV1,
    activeSeatsV1: step.activeSeatsV1,
    foldedSeatsV1: step.foldedSeatsV1,
    emptySeatsV1: step.emptySeatsV1,
    lastAggressorV1: step.lastAggressorV1,
    initiativeOwnerV1: step.initiativeOwnerV1,
    feedbackCorrectV1: step.feedbackCorrectV1,
    feedbackIncorrectV1: step.feedbackIncorrectV1,
  );
}
