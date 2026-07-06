import 'package:poker_analyzer/services/canonical_atom_mapping_registry_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_persistence_v1.dart';

/// Reviewed source-target facts. A null [canonicalAtomId] is deliberate: this
/// catalog does not assert cross-family equivalence without mapping proof.
class CanonicalSourceTargetMetadataV1 {
  const CanonicalSourceTargetMetadataV1({
    required this.canonicalAtomId,
    required this.sourceFamily,
    required this.sourceWorld,
    required this.sourceSessionId,
    required this.exactTargetId,
    required this.signalFamilyId,
    required this.machineCueId,
    required this.learnerFacingClueName,
    required this.expectedActionId,
    required this.outcomeSemantics,
    required this.context,
    required this.downgradeScope,
    required this.curatedRepairAvailable,
    required this.curatedRecheckAvailable,
    required this.curatedProveAvailable,
    required this.contentOwner,
    required this.evidenceConfidence,
    required this.reviewStamp,
  });

  final String? canonicalAtomId;
  final String sourceFamily;
  final String sourceWorld;
  final String sourceSessionId;
  final String exactTargetId;
  final String signalFamilyId;
  final String machineCueId;
  final String learnerFacingClueName;
  final String expectedActionId;
  final String outcomeSemantics;
  final String context;
  final String downgradeScope;
  final bool curatedRepairAvailable;
  final bool curatedRecheckAvailable;
  final bool curatedProveAvailable;
  final String contentOwner;
  final String evidenceConfidence;
  final String reviewStamp;

  CanonicalAtomMappingInputV1 get tuple => CanonicalAtomMappingInputV1(
    sourceFamily: sourceFamily,
    sourceWorld: sourceWorld,
    sourceSessionId: sourceSessionId,
    exactTargetId: exactTargetId,
    signalFamilyId: signalFamilyId,
  );

  String get tupleKey => tuple.normalizedTupleKey;
}

/// Read-only catalog for reviewed W4/W5/W6 session-drill source targets.
///
/// This does not change retained events, receipt behavior, or the canonical
/// mapping registry. Unknown tuples intentionally return null.
class CanonicalSourceTargetMetadataCatalogV1 {
  const CanonicalSourceTargetMetadataCatalogV1();

  static const CanonicalSourceTargetMetadataV1 _w5DryTextureV1 =
      CanonicalSourceTargetMetadataV1(
        canonicalAtomId: null,
        sourceFamily: 'w5_session_drill',
        sourceWorld: 'world_5',
        sourceSessionId: 'w5.s01',
        exactTargetId: 'classify_texture_intro_dry_raise_v1',
        signalFamilyId: 'board_texture_dry',
        machineCueId: 'board_texture_dry',
        learnerFacingClueName: 'Dry board texture',
        expectedActionId: 'raise',
        outcomeSemantics: 'explicit_exact_target_result_v1',
        context: 'recheck',
        downgradeScope: 'source_local',
        curatedRepairAvailable: true,
        curatedRecheckAvailable: true,
        curatedProveAvailable: false,
        contentOwner: 'session_drill_content',
        evidenceConfidence: 'source_proven',
        reviewStamp: 'canonical_source_target_metadata_tiny_slice_v1',
      );

  static const List<CanonicalSourceTargetMetadataV1> _expansionRecordsV2 =
      <CanonicalSourceTargetMetadataV1>[
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w5_session_drill',
          sourceWorld: 'world_5',
          sourceSessionId: 'w5.s01',
          exactTargetId: 'classify_texture_intro_wet_call_v1',
          signalFamilyId: 'board_texture_wet',
          machineCueId: 'board_texture_wet',
          learnerFacingClueName: 'Wet board texture',
          expectedActionId: 'call',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'canonical_source_target_metadata_expansion_v2',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w5_session_drill',
          sourceWorld: 'world_5',
          sourceSessionId: 'w5.s01',
          exactTargetId: 'classify_texture_intro_paired_fold_v1',
          signalFamilyId: 'board_texture_paired',
          machineCueId: 'board_texture_paired',
          learnerFacingClueName: 'Paired board texture',
          expectedActionId: 'fold',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'canonical_source_target_metadata_expansion_v2',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w6_session_drill',
          sourceWorld: 'world_6',
          sourceSessionId: 'w6.s01',
          exactTargetId: 'classify_strong_overpair_fit',
          signalFamilyId: 'range_bucket_strong',
          machineCueId: 'range_bucket_strong',
          learnerFacingClueName: 'Strong range bucket',
          expectedActionId: 'strong',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d0_w6_repair_authority_reconciliation_v1',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w6_session_drill',
          sourceWorld: 'world_6',
          sourceSessionId: 'w6.s01',
          exactTargetId: 'classify_strong_clean_fit',
          signalFamilyId: 'range_bucket_strong',
          machineCueId: 'range_bucket_strong',
          learnerFacingClueName: 'Strong range bucket',
          expectedActionId: 'strong',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d0_w6_repair_authority_reconciliation_v1',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w6_session_drill',
          sourceWorld: 'world_6',
          sourceSessionId: 'w6.s01',
          exactTargetId: 'classify_missed_low_cards_no_draw',
          signalFamilyId: 'range_bucket_missed',
          machineCueId: 'range_bucket_missed',
          learnerFacingClueName: 'Missed range bucket',
          expectedActionId: 'missed',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d0_w6_repair_authority_reconciliation_v1',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w6_session_drill',
          sourceWorld: 'world_6',
          sourceSessionId: 'w6.s01',
          exactTargetId: 'classify_missed_overcards_no_draw',
          signalFamilyId: 'range_bucket_missed',
          machineCueId: 'range_bucket_missed',
          learnerFacingClueName: 'Missed range bucket',
          expectedActionId: 'missed',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d0_w6_repair_authority_reconciliation_v1',
        ),
      ];

  static const List<CanonicalSourceTargetMetadataV1> _waveDRecordsV1 =
      <CanonicalSourceTargetMetadataV1>[
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w5_session_drill',
          sourceWorld: 'world_5',
          sourceSessionId: 'w5.s06',
          exactTargetId: 'classify_texture_synthesis_dry_raise_v1',
          signalFamilyId: 'board_texture_dry',
          machineCueId: 'board_texture_dry',
          learnerFacingClueName: 'Dry board texture',
          expectedActionId: 'raise',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d_minimum_same_signal_repair_v1',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w5_session_drill',
          sourceWorld: 'world_5',
          sourceSessionId: 'w5.s10',
          exactTargetId: 'classify_in_position_dry_raise_v1',
          signalFamilyId: 'board_texture_dry',
          machineCueId: 'board_texture_dry',
          learnerFacingClueName: 'Dry board texture',
          expectedActionId: 'raise',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d_minimum_same_signal_repair_v1',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w6_session_drill',
          sourceWorld: 'world_6',
          sourceSessionId: 'w6.s02',
          exactTargetId: 'classify_late_position_more_hands',
          signalFamilyId: 'range_width_wider',
          machineCueId: 'range_width_wider',
          learnerFacingClueName: 'Wider range',
          expectedActionId: 'wider',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d_minimum_same_signal_repair_v1',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w6_session_drill',
          sourceWorld: 'world_6',
          sourceSessionId: 'w6.s02',
          exactTargetId: 'classify_button_range_wider',
          signalFamilyId: 'range_width_wider',
          machineCueId: 'range_width_wider',
          learnerFacingClueName: 'Wider range',
          expectedActionId: 'wider',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d_minimum_same_signal_repair_v1',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w6_session_drill',
          sourceWorld: 'world_6',
          sourceSessionId: 'w6.s02',
          exactTargetId: 'classify_big_blind_continue_narrower',
          signalFamilyId: 'range_width_narrower',
          machineCueId: 'range_width_narrower',
          learnerFacingClueName: 'Narrower range',
          expectedActionId: 'narrower',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d_minimum_same_signal_repair_v1',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w6_session_drill',
          sourceWorld: 'world_6',
          sourceSessionId: 'w6.s02',
          exactTargetId: 'classify_continue_range_narrower',
          signalFamilyId: 'range_width_narrower',
          machineCueId: 'range_width_narrower',
          learnerFacingClueName: 'Narrower range',
          expectedActionId: 'narrower',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d_minimum_same_signal_repair_v1',
        ),
        CanonicalSourceTargetMetadataV1(
          canonicalAtomId: null,
          sourceFamily: 'w4_session_drill',
          sourceWorld: 'world_4',
          sourceSessionId: 'w4.s02',
          exactTargetId: 'choose_raise_repeat',
          signalFamilyId: 'denial_equity_charge',
          machineCueId: 'denial_equity_charge',
          learnerFacingClueName: 'Charge live overcards and draws',
          expectedActionId: 'raise',
          outcomeSemantics: 'explicit_exact_target_result_v1',
          context: 'recheck',
          downgradeScope: 'source_local',
          curatedRepairAvailable: true,
          curatedRecheckAvailable: true,
          curatedProveAvailable: false,
          contentOwner: 'session_drill_content',
          evidenceConfidence: 'source_proven',
          reviewStamp: 'stage_1b_wave_d_minimum_same_signal_repair_v1',
        ),
      ];

  static final Map<String, CanonicalSourceTargetMetadataV1>
  _reviewedMetadataByTupleV1 = <String, CanonicalSourceTargetMetadataV1>{
    _w5DryTextureV1.tupleKey: _w5DryTextureV1,
    for (final metadata in _expansionRecordsV2) metadata.tupleKey: metadata,
    for (final metadata in _waveDRecordsV1) metadata.tupleKey: metadata,
  };

  CanonicalSourceTargetMetadataV1? resolve(CanonicalAtomMappingInputV1 input) =>
      _reviewedMetadataByTupleV1[input.normalizedTupleKey];

  CanonicalSourceTargetMetadataV1? forRetainedResult(
    SessionDrillRetainedResultEventV1 event,
  ) => resolve(
    CanonicalAtomMappingInputV1(
      sourceFamily: event.sourceFamily,
      sourceWorld: event.worldId,
      sourceSessionId: event.sourceSessionId,
      exactTargetId: event.targetDrillId,
      signalFamilyId: event.signalFamilyId,
    ),
  );
}
