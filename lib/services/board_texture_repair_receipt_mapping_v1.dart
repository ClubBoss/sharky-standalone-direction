import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';

export 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart'
    show SessionDrillRepairReceiptCandidateV1;

/// Creates provenance for authored W5 board-texture misses only.
///
/// This remains service-level mapping and reuses the existing Review consumer
/// and session-drill route without telemetry, schema, or content expansion.
SessionDrillRepairReceiptCandidateV1?
buildBoardTextureRepairReceiptCandidateV1({
  required String sourceSessionId,
  required SessionDrillItemV1 sourceDrill,
  required DrillEvalResultV1 evaluation,
  required String chosenActionId,
}) {
  final sessionId = sourceSessionId.trim().toLowerCase();
  final drillId = sourceDrill.drillId.trim();
  final spec = sourceDrill.spec;
  final actionId = chosenActionId.trim().toLowerCase();
  final expectedActionId = spec.expectedActionV1?.trim().toLowerCase() ?? '';
  final texture = spec.boardTextureV1?.trim().toLowerCase() ?? '';
  final target = _boardTextureRepairTargetBySourceV1['$sessionId:$drillId'];

  if (drillId.isEmpty ||
      drillId != spec.id.trim() ||
      spec.kind != DrillKindV1.boardTextureClassifier ||
      evaluation.isPass ||
      actionId.isEmpty ||
      expectedActionId.isEmpty ||
      texture.isEmpty ||
      target == null ||
      target.texture != texture) {
    return null;
  }

  return SessionDrillRepairReceiptCandidateV1(
    schemaVersion: 1,
    sourceWorldId: 'world_5',
    sourceSessionId: sessionId,
    sourceDrillId: drillId,
    drillFamilyId: 'board_texture_classifier_v1',
    missedSignalId: 'board_texture_$texture',
    missedSignalLabel: _boardTextureSignalLabelV1(texture),
    chosenActionId: actionId,
    expectedActionId: expectedActionId,
    targetSessionId: target.targetSessionId,
    targetDrillId: target.targetDrillId,
    targetKind:
        target.targetSessionId == sessionId && target.targetDrillId == drillId
        ? 'exact_replay'
        : 'same_signal_recheck',
    errorClass: evaluation.errorClass?.trim() ?? 'board_texture_miss',
  );
}

typedef _BoardTextureRepairTargetV1 = ({
  String targetSessionId,
  String targetDrillId,
  String texture,
});

const Map<String, _BoardTextureRepairTargetV1>
_boardTextureRepairTargetBySourceV1 = <String, _BoardTextureRepairTargetV1>{
  'w5.s01:classify_texture_intro_dry_raise_v1': (
    targetSessionId: 'w5.s01',
    targetDrillId: 'classify_texture_intro_dry_raise_v1',
    texture: 'dry',
  ),
  'w5.s01:classify_texture_intro_wet_call_v1': (
    targetSessionId: 'w5.s01',
    targetDrillId: 'classify_texture_intro_wet_call_v1',
    texture: 'wet',
  ),
  'w5.s01:classify_texture_intro_paired_fold_v1': (
    targetSessionId: 'w5.s01',
    targetDrillId: 'classify_texture_intro_paired_fold_v1',
    texture: 'paired',
  ),
  'w5.s06:classify_in_position_dry_raise_v1': (
    targetSessionId: 'w5.s10',
    targetDrillId: 'classify_texture_synthesis_dry_raise_v1',
    texture: 'dry',
  ),
  'w5.s10:classify_texture_synthesis_dry_raise_v1': (
    targetSessionId: 'w5.s06',
    targetDrillId: 'classify_in_position_dry_raise_v1',
    texture: 'dry',
  ),
};

String _boardTextureSignalLabelV1(String texture) {
  return switch (texture) {
    'dry' => 'Dry board texture',
    'wet' => 'Wet board texture',
    'paired' => 'Paired board texture',
    'connected' => 'Connected board texture',
    'high_card' => 'High-card board texture',
    _ => 'Board texture',
  };
}
