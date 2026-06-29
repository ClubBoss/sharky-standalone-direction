import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';

const String act0ConceptCandidatePracticeMappedV1 =
    'mapped_existing_practice_target_v1';
const String act0ConceptCandidatePracticeNoTargetUnknownConceptV1 =
    'no_target_unknown_concept_id_v1';
const String act0ConceptCandidatePracticeNoTargetRouteLockedV1 =
    'no_target_route_locked_v1';
const String act0ConceptCandidatePracticeNoTargetBridgeLimitedV1 =
    'no_target_bridge_limited_v1';
const String act0ConceptCandidatePracticeNoTargetUnsafeLaunchOwnerV1 =
    'no_target_unsafe_missing_launch_owner_v1';

class Act0ConceptCandidatePracticeMapResultV1 {
  const Act0ConceptCandidatePracticeMapResultV1._({
    required this.reasonCode,
    this.request,
  });

  const Act0ConceptCandidatePracticeMapResultV1.mapped({
    required Act0PracticeRepairQueueLaunchRequestV1 request,
  }) : this._(
         reasonCode: act0ConceptCandidatePracticeMappedV1,
         request: request,
       );

  const Act0ConceptCandidatePracticeMapResultV1.noTarget({
    required String reasonCode,
  }) : this._(reasonCode: reasonCode);

  final String reasonCode;
  final Act0PracticeRepairQueueLaunchRequestV1? request;

  bool get isMapped => request != null;
}

class Act0ConceptCandidatePracticeTargetSpecV1 {
  const Act0ConceptCandidatePracticeTargetSpecV1({
    required this.mappingId,
    required this.conceptFamilyId,
    required this.repairFocusId,
    required this.skillAtomId,
    required this.errorType,
    required this.sourceTaskId,
    required this.targetWorldId,
    required this.targetLessonId,
    required this.targetTaskId,
    this.bridgeLimited = false,
  });

  final String mappingId;
  final String conceptFamilyId;
  final String repairFocusId;
  final String skillAtomId;
  final String errorType;
  final String sourceTaskId;
  final String targetWorldId;
  final String targetLessonId;
  final String targetTaskId;
  final bool bridgeLimited;

  String get sortKey => mappingId.trim();
}

const List<Act0ConceptCandidatePracticeTargetSpecV1>
act0DefaultConceptCandidatePracticeTargetsV1 =
    <Act0ConceptCandidatePracticeTargetSpecV1>[
      Act0ConceptCandidatePracticeTargetSpecV1(
        mappingId: 'w1_no_bet_yet_action_read_to_check_drill_v1',
        conceptFamilyId: 'no_bet_yet',
        repairFocusId: 'no_bet_yet',
        skillAtomId: 'action_read',
        errorType: 'missed_action_read',
        sourceTaskId: 'actions_legal_context',
        targetWorldId: 'world_1',
        targetLessonId: 'fold_check_call_raise',
        targetTaskId: 'actions_check_drill',
      ),
    ];

Act0ConceptCandidatePracticeMapResultV1
mapAct0ConceptCandidateToPracticeLaunchRequestV1(
  Act0ConceptFamilyRepairCandidateV1? candidate, {
  List<Act0ConceptCandidatePracticeTargetSpecV1> allowlist =
      act0DefaultConceptCandidatePracticeTargetsV1,
}) {
  if (candidate == null) {
    return const Act0ConceptCandidatePracticeMapResultV1.noTarget(
      reasonCode: act0ConceptCandidatePracticeNoTargetUnknownConceptV1,
    );
  }
  final matches = allowlist.where((spec) => _matches(candidate, spec)).toList()
    ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
  if (matches.isEmpty) {
    return const Act0ConceptCandidatePracticeMapResultV1.noTarget(
      reasonCode: act0ConceptCandidatePracticeNoTargetUnknownConceptV1,
    );
  }
  final spec = matches.first;
  if (spec.bridgeLimited) {
    return const Act0ConceptCandidatePracticeMapResultV1.noTarget(
      reasonCode: act0ConceptCandidatePracticeNoTargetBridgeLimitedV1,
    );
  }
  if (!_isAllowedWorld(spec.targetWorldId)) {
    return const Act0ConceptCandidatePracticeMapResultV1.noTarget(
      reasonCode: act0ConceptCandidatePracticeNoTargetRouteLockedV1,
    );
  }
  final sourceKey = _repairFocusKey(candidate, spec);
  final queueItemId =
      'practice_repair_queue_v1|concept_candidate|${_keyPart(sourceKey)}';
  final request = Act0PracticeRepairQueueLaunchRequestV1(
    targetWorldId: spec.targetWorldId.trim(),
    targetLessonId: spec.targetLessonId.trim(),
    targetTaskId: spec.targetTaskId.trim(),
    targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
    sourceTaskId: spec.sourceTaskId.trim(),
    repairTaskId: spec.targetTaskId.trim(),
    repairFocusKey: sourceKey,
    queueItemId: queueItemId,
  );
  if (!request.isLaunchable) {
    return const Act0ConceptCandidatePracticeMapResultV1.noTarget(
      reasonCode: act0ConceptCandidatePracticeNoTargetUnsafeLaunchOwnerV1,
    );
  }
  return Act0ConceptCandidatePracticeMapResultV1.mapped(request: request);
}

bool _matches(
  Act0ConceptFamilyRepairCandidateV1 candidate,
  Act0ConceptCandidatePracticeTargetSpecV1 spec,
) {
  return candidate.conceptFamilyId.trim() == spec.conceptFamilyId.trim() &&
      candidate.repairFocusId.trim() == spec.repairFocusId.trim() &&
      candidate.skillAtomId.trim() == spec.skillAtomId.trim() &&
      candidate.errorType.trim() == spec.errorType.trim();
}

bool _isAllowedWorld(String worldId) {
  return const <String>{
    'world_1',
    'world_2',
    'world_3',
    'world_4',
    'world_5',
    'world_6',
  }.contains(worldId.trim());
}

String _repairFocusKey(
  Act0ConceptFamilyRepairCandidateV1 candidate,
  Act0ConceptCandidatePracticeTargetSpecV1 spec,
) {
  return <String>[
    spec.sourceTaskId.trim(),
    candidate.repairFocusId.trim(),
    candidate.skillAtomId.trim(),
    candidate.errorType.trim(),
  ].map(_keyPart).join('|');
}

String _keyPart(String value) => '${value.length}:$value';
