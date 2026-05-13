import 'dart:convert';

enum ReadinessEpicStatusV1 {
  done('done', 1.00),
  humanProofPending('human_proof_pending', 0.85),
  proofPending('proof_pending', 0.70),
  inProgress('in_progress', 0.40),
  blocked('blocked', 0.20),
  notStarted('not_started', 0.00),
  deferred('deferred', null);

  const ReadinessEpicStatusV1(this.wireValue, this.rawWeight);

  final String wireValue;
  final double? rawWeight;

  static ReadinessEpicStatusV1 fromWire(String value) {
    return values.firstWhere(
      (status) => status.wireValue == value,
      orElse: () =>
          throw ArgumentError('Unknown readiness epic status: $value'),
    );
  }
}

enum ReadinessRecalibrationCandidateStatusV1 {
  noChange('no_change'),
  candidateIncrease('candidate_increase'),
  candidateDecrease('candidate_decrease'),
  insufficientProof('insufficient_proof');

  const ReadinessRecalibrationCandidateStatusV1(this.wireValue);

  final String wireValue;

  static ReadinessRecalibrationCandidateStatusV1 fromWire(String value) {
    return values.firstWhere(
      (status) => status.wireValue == value,
      orElse: () => throw ArgumentError(
        'Unknown readiness recalibration candidate status: $value',
      ),
    );
  }
}

enum ReadinessCandidateMovementDirectionV1 {
  increase('increase'),
  decrease('decrease');

  const ReadinessCandidateMovementDirectionV1(this.wireValue);

  final String wireValue;
}

enum CompletionGapAdmissibilityV1 {
  machineReducibleNow('machine_reducible_now'),
  truthLayerFirst('truth_layer_first'),
  proofManualOnly('proof_manual_only'),
  external('external');

  const CompletionGapAdmissibilityV1(this.wireValue);

  final String wireValue;

  static CompletionGapAdmissibilityV1 fromWire(String value) {
    return values.firstWhere(
      (admissibility) => admissibility.wireValue == value,
      orElse: () =>
          throw ArgumentError('Unknown completion-gap admissibility: $value'),
    );
  }
}

class ReadinessEpicRegistryEntryV1 {
  const ReadinessEpicRegistryEntryV1({
    required this.id,
    required this.blockId,
    required this.blockTitle,
    required this.title,
    required this.status,
    required this.blockingLevel,
  });

  final String id;
  final String blockId;
  final String blockTitle;
  final String title;
  final ReadinessEpicStatusV1 status;
  final String blockingLevel;
}

class CompletionGapEntryV1 {
  const CompletionGapEntryV1({
    required this.gapId,
    required this.sourceTruthOwner,
    required this.title,
    required this.category,
    required this.worldScope,
    required this.surfaceScope,
    required this.readinessBlocks,
    required this.epicMappings,
    required this.currentStatus,
    required this.admissibility,
    required this.likelySeam,
    required this.ownerFiles,
    required this.measurableProofPath,
    required this.prerequisiteBlockers,
    required this.evPriorityOrder,
    required this.nextFrontierReason,
  });

  final String gapId;
  final String sourceTruthOwner;
  final String title;
  final String category;
  final List<String> worldScope;
  final List<String> surfaceScope;
  final List<String> readinessBlocks;
  final List<String> epicMappings;
  final String currentStatus;
  final CompletionGapAdmissibilityV1 admissibility;
  final String likelySeam;
  final List<String> ownerFiles;
  final List<String> measurableProofPath;
  final List<String> prerequisiteBlockers;
  final int evPriorityOrder;
  final String nextFrontierReason;

  CompletionGapEntryV1 copyWith({
    String? gapId,
    String? sourceTruthOwner,
    String? title,
    String? category,
    List<String>? worldScope,
    List<String>? surfaceScope,
    List<String>? readinessBlocks,
    List<String>? epicMappings,
    String? currentStatus,
    CompletionGapAdmissibilityV1? admissibility,
    String? likelySeam,
    List<String>? ownerFiles,
    List<String>? measurableProofPath,
    List<String>? prerequisiteBlockers,
    int? evPriorityOrder,
    String? nextFrontierReason,
  }) {
    return CompletionGapEntryV1(
      gapId: gapId ?? this.gapId,
      sourceTruthOwner: sourceTruthOwner ?? this.sourceTruthOwner,
      title: title ?? this.title,
      category: category ?? this.category,
      worldScope: worldScope ?? this.worldScope,
      surfaceScope: surfaceScope ?? this.surfaceScope,
      readinessBlocks: readinessBlocks ?? this.readinessBlocks,
      epicMappings: epicMappings ?? this.epicMappings,
      currentStatus: currentStatus ?? this.currentStatus,
      admissibility: admissibility ?? this.admissibility,
      likelySeam: likelySeam ?? this.likelySeam,
      ownerFiles: ownerFiles ?? this.ownerFiles,
      measurableProofPath: measurableProofPath ?? this.measurableProofPath,
      prerequisiteBlockers: prerequisiteBlockers ?? this.prerequisiteBlockers,
      evPriorityOrder: evPriorityOrder ?? this.evPriorityOrder,
      nextFrontierReason: nextFrontierReason ?? this.nextFrontierReason,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'gap_id': gapId,
      'source_truth_owner': sourceTruthOwner,
      'title': title,
      'category': category,
      'world_scope': worldScope,
      'surface_scope': surfaceScope,
      'readiness_blocks': readinessBlocks,
      'epic_mappings': epicMappings,
      'current_status': currentStatus,
      'admissibility': admissibility.wireValue,
      'likely_seam': likelySeam,
      'owner_files': ownerFiles,
      'measurable_proof_path': measurableProofPath,
      'prerequisite_blockers': prerequisiteBlockers,
      'ev_priority_order': evPriorityOrder,
      'next_frontier_reason': nextFrontierReason,
    };
  }

  factory CompletionGapEntryV1.fromJson(Map<String, Object?> json) {
    return CompletionGapEntryV1(
      gapId: json['gap_id'] as String? ?? '',
      sourceTruthOwner: json['source_truth_owner'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      worldScope: (json['world_scope'] as List<Object?>? ?? const [])
          .whereType<String>()
          .toList(),
      surfaceScope: (json['surface_scope'] as List<Object?>? ?? const [])
          .whereType<String>()
          .toList(),
      readinessBlocks: (json['readiness_blocks'] as List<Object?>? ?? const [])
          .whereType<String>()
          .toList(),
      epicMappings: (json['epic_mappings'] as List<Object?>? ?? const [])
          .whereType<String>()
          .toList(),
      currentStatus: json['current_status'] as String? ?? '',
      admissibility: CompletionGapAdmissibilityV1.fromWire(
        json['admissibility'] as String? ?? 'external',
      ),
      likelySeam: json['likely_seam'] as String? ?? '',
      ownerFiles: (json['owner_files'] as List<Object?>? ?? const [])
          .whereType<String>()
          .toList(),
      measurableProofPath:
          (json['measurable_proof_path'] as List<Object?>? ?? const [])
              .whereType<String>()
              .toList(),
      prerequisiteBlockers:
          (json['prerequisite_blockers'] as List<Object?>? ?? const [])
              .whereType<String>()
              .toList(),
      evPriorityOrder: json['ev_priority_order'] as int? ?? 0,
      nextFrontierReason: json['next_frontier_reason'] as String? ?? '',
    );
  }
}

class CompletionGapSynthesisV1 {
  const CompletionGapSynthesisV1({
    required this.sourceTruthOwners,
    required this.gaps,
    required this.topMachineFrontier,
    required this.recommendedNextFrontier,
    required this.pausedManualClusters,
    required this.nextBestMachineFrontiers,
    required this.why100NotReached,
    required this.allRemainingGapsCount,
    required this.machineReducibleRemainingCount,
    required this.manualBoundRemainingCount,
  });

  final List<String> sourceTruthOwners;
  final List<CompletionGapEntryV1> gaps;
  final CompletionGapEntryV1? topMachineFrontier;
  final CompletionGapEntryV1? recommendedNextFrontier;
  final List<String> pausedManualClusters;
  final List<CompletionGapEntryV1> nextBestMachineFrontiers;
  final List<String> why100NotReached;
  final int allRemainingGapsCount;
  final int machineReducibleRemainingCount;
  final int manualBoundRemainingCount;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'source_truth_owners': sourceTruthOwners,
      'gaps': gaps.map((gap) => gap.toJson()).toList(),
      'top_machine_frontier': topMachineFrontier?.toJson(),
      'recommended_next_frontier': recommendedNextFrontier?.toJson(),
      'paused_manual_clusters': pausedManualClusters,
      'next_best_machine_frontiers': nextBestMachineFrontiers
          .map((gap) => gap.toJson())
          .toList(),
      'why_100_not_reached': why100NotReached,
      'all_remaining_gaps_count': allRemainingGapsCount,
      'machine_reducible_remaining_count': machineReducibleRemainingCount,
      'manual_bound_remaining_count': manualBoundRemainingCount,
    };
  }

  factory CompletionGapSynthesisV1.fromJson(Map<String, Object?> json) {
    return CompletionGapSynthesisV1(
      sourceTruthOwners:
          (json['source_truth_owners'] as List<Object?>? ?? const [])
              .whereType<String>()
              .toList(),
      gaps: (json['gaps'] as List<Object?>? ?? const [])
          .whereType<Map>()
          .map(
            (gap) =>
                CompletionGapEntryV1.fromJson(Map<String, Object?>.from(gap)),
          )
          .toList(),
      topMachineFrontier: json['top_machine_frontier'] is Map
          ? CompletionGapEntryV1.fromJson(
              Map<String, Object?>.from(json['top_machine_frontier'] as Map),
            )
          : null,
      recommendedNextFrontier: json['recommended_next_frontier'] is Map
          ? CompletionGapEntryV1.fromJson(
              Map<String, Object?>.from(
                json['recommended_next_frontier'] as Map,
              ),
            )
          : null,
      pausedManualClusters:
          (json['paused_manual_clusters'] as List<Object?>? ?? const [])
              .whereType<String>()
              .toList(),
      nextBestMachineFrontiers:
          (json['next_best_machine_frontiers'] as List<Object?>? ?? const [])
              .whereType<Map>()
              .map(
                (gap) => CompletionGapEntryV1.fromJson(
                  Map<String, Object?>.from(gap),
                ),
              )
              .toList(),
      why100NotReached:
          (json['why_100_not_reached'] as List<Object?>? ?? const [])
              .whereType<String>()
              .toList(),
      allRemainingGapsCount: json['all_remaining_gaps_count'] as int? ?? 0,
      machineReducibleRemainingCount:
          json['machine_reducible_remaining_count'] as int? ?? 0,
      manualBoundRemainingCount:
          json['manual_bound_remaining_count'] as int? ?? 0,
    );
  }
}

class CanonicalReadinessV1 {
  const CanonicalReadinessV1({
    required this.sourceSsotPath,
    required this.coreReadinessPercent,
    required this.shipReadinessPercent,
    required this.finalReadinessPercent,
    required this.topBottleneckBlock,
    required this.topBottleneckEpic,
    required this.confidenceNote,
    required this.whatBlocksHundredNow,
    required this.hardBlockers,
    required this.softBlockers,
    required this.explanation,
  });

  final String sourceSsotPath;
  final double coreReadinessPercent;
  final double shipReadinessPercent;
  final double finalReadinessPercent;
  final String topBottleneckBlock;
  final String topBottleneckEpic;
  final String confidenceNote;
  final List<String> whatBlocksHundredNow;
  final List<String> hardBlockers;
  final List<String> softBlockers;
  final String explanation;

  Map<String, Object?> toProjectHealthJson() {
    return <String, Object?>{
      'source_ssot_path': sourceSsotPath,
      'core_readiness_percent': coreReadinessPercent,
      'ship_readiness_percent': shipReadinessPercent,
      'final_readiness_percent': finalReadinessPercent,
      'top_bottleneck_block': topBottleneckBlock,
      'top_bottleneck_epic': topBottleneckEpic,
      'confidence_note': confidenceNote,
      'what_blocks_hundred_now': whatBlocksHundredNow,
      'hard_blockers': hardBlockers,
      'soft_blockers': softBlockers,
      'explanation': explanation,
    };
  }

  Map<String, Object?> toCanonicalReadinessJson() {
    return <String, Object?>{
      'source_ssot_path': sourceSsotPath,
      'core_readiness_percent': coreReadinessPercent,
      'ship_readiness_percent': shipReadinessPercent,
      'final_readiness_percent': finalReadinessPercent,
      'top_bottleneck_block': topBottleneckBlock,
      'top_bottleneck_epic': topBottleneckEpic,
    };
  }

  factory CanonicalReadinessV1.fromProjectHealthJson(
    Map<String, Object?> json,
  ) {
    return CanonicalReadinessV1(
      sourceSsotPath: json['source_ssot_path'] as String? ?? '',
      coreReadinessPercent:
          (json['core_readiness_percent'] as num?)?.toDouble() ?? 0,
      shipReadinessPercent:
          (json['ship_readiness_percent'] as num?)?.toDouble() ?? 0,
      finalReadinessPercent:
          (json['final_readiness_percent'] as num?)?.toDouble() ?? 0,
      topBottleneckBlock: json['top_bottleneck_block'] as String? ?? '',
      topBottleneckEpic: json['top_bottleneck_epic'] as String? ?? '',
      confidenceNote: json['confidence_note'] as String? ?? '',
      whatBlocksHundredNow:
          (json['what_blocks_hundred_now'] as List<Object?>? ?? const [])
              .whereType<String>()
              .toList(),
      hardBlockers: (json['hard_blockers'] as List<Object?>? ?? const [])
          .whereType<String>()
          .toList(),
      softBlockers: (json['soft_blockers'] as List<Object?>? ?? const [])
          .whereType<String>()
          .toList(),
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class CandidateEpicMovementV1 {
  const CandidateEpicMovementV1({
    required this.epicId,
    required this.blockId,
    required this.blockTitle,
    required this.canonicalStatus,
    required this.candidateStatus,
    required this.direction,
    required this.evidenceRefs,
    required this.reason,
  });

  final String epicId;
  final String blockId;
  final String blockTitle;
  final ReadinessEpicStatusV1 canonicalStatus;
  final ReadinessEpicStatusV1 candidateStatus;
  final ReadinessCandidateMovementDirectionV1 direction;
  final List<String> evidenceRefs;
  final String reason;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'epic_id': epicId,
      'block_id': blockId,
      'block_title': blockTitle,
      'canonical_status': canonicalStatus.wireValue,
      'candidate_status': candidateStatus.wireValue,
      'direction': direction.wireValue,
      'evidence_refs': evidenceRefs,
      'reason': reason,
    };
  }

  factory CandidateEpicMovementV1.fromJson(Map<String, Object?> json) {
    return CandidateEpicMovementV1(
      epicId: json['epic_id'] as String? ?? '',
      blockId: json['block_id'] as String? ?? '',
      blockTitle: json['block_title'] as String? ?? '',
      canonicalStatus: ReadinessEpicStatusV1.fromWire(
        json['canonical_status'] as String? ?? 'not_started',
      ),
      candidateStatus: ReadinessEpicStatusV1.fromWire(
        json['candidate_status'] as String? ?? 'not_started',
      ),
      direction: ReadinessCandidateMovementDirectionV1.values.firstWhere(
        (direction) =>
            direction.wireValue == (json['direction'] as String? ?? ''),
      ),
      evidenceRefs: (json['evidence_refs'] as List<Object?>? ?? const [])
          .whereType<String>()
          .toList(),
      reason: json['reason'] as String? ?? '',
    );
  }
}

class CandidateBlockMovementV1 {
  const CandidateBlockMovementV1({
    required this.blockId,
    required this.blockTitle,
    required this.rawScoreBefore,
    required this.rawScoreAfter,
    required this.effectiveScoreBefore,
    required this.effectiveScoreAfter,
    this.effectiveCapReason,
  });

  final String blockId;
  final String blockTitle;
  final double rawScoreBefore;
  final double rawScoreAfter;
  final double effectiveScoreBefore;
  final double effectiveScoreAfter;
  final String? effectiveCapReason;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'block_id': blockId,
      'block_title': blockTitle,
      'raw_score_before': rawScoreBefore,
      'raw_score_after': rawScoreAfter,
      'effective_score_before': effectiveScoreBefore,
      'effective_score_after': effectiveScoreAfter,
      'effective_cap_reason': effectiveCapReason,
    };
  }

  factory CandidateBlockMovementV1.fromJson(Map<String, Object?> json) {
    return CandidateBlockMovementV1(
      blockId: json['block_id'] as String? ?? '',
      blockTitle: json['block_title'] as String? ?? '',
      rawScoreBefore: (json['raw_score_before'] as num?)?.toDouble() ?? 0,
      rawScoreAfter: (json['raw_score_after'] as num?)?.toDouble() ?? 0,
      effectiveScoreBefore:
          (json['effective_score_before'] as num?)?.toDouble() ?? 0,
      effectiveScoreAfter:
          (json['effective_score_after'] as num?)?.toDouble() ?? 0,
      effectiveCapReason: json['effective_cap_reason'] as String?,
    );
  }
}

class CandidateScoreDeltasV1 {
  const CandidateScoreDeltasV1({
    required this.coreDelta,
    required this.shipDelta,
    required this.finalDelta,
  });

  final double coreDelta;
  final double shipDelta;
  final double finalDelta;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'core_delta': coreDelta,
      'ship_delta': shipDelta,
      'final_delta': finalDelta,
    };
  }

  factory CandidateScoreDeltasV1.fromJson(Map<String, Object?> json) {
    return CandidateScoreDeltasV1(
      coreDelta: (json['core_delta'] as num?)?.toDouble() ?? 0,
      shipDelta: (json['ship_delta'] as num?)?.toDouble() ?? 0,
      finalDelta: (json['final_delta'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ReadinessRecalibrationCandidateV1 {
  const ReadinessRecalibrationCandidateV1({
    required this.canonicalReadinessSourcePath,
    required this.canonicalReadiness,
    required this.status,
    required this.candidateBlockMovements,
    required this.candidateEpicMovements,
    required this.candidateScoreDeltas,
    required this.rawVsEffectiveNote,
    required this.recalibrationJustifiedNow,
    required this.recalibrationReason,
    required this.proofGapsIfNotJustified,
  });

  final String canonicalReadinessSourcePath;
  final CanonicalReadinessV1 canonicalReadiness;
  final ReadinessRecalibrationCandidateStatusV1 status;
  final List<CandidateBlockMovementV1> candidateBlockMovements;
  final List<CandidateEpicMovementV1> candidateEpicMovements;
  final CandidateScoreDeltasV1 candidateScoreDeltas;
  final String rawVsEffectiveNote;
  final bool recalibrationJustifiedNow;
  final String recalibrationReason;
  final List<String> proofGapsIfNotJustified;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'canonical_readiness_source_path': canonicalReadinessSourcePath,
      'canonical_readiness': canonicalReadiness.toCanonicalReadinessJson(),
      'recalibration_candidate_status': status.wireValue,
      'candidate_block_movements': candidateBlockMovements
          .map((movement) => movement.toJson())
          .toList(),
      'candidate_epic_movements': candidateEpicMovements
          .map((movement) => movement.toJson())
          .toList(),
      'candidate_score_deltas': candidateScoreDeltas.toJson(),
      'raw_vs_effective_note': rawVsEffectiveNote,
      'recalibration_justified_now': recalibrationJustifiedNow,
      'recalibration_reason': recalibrationReason,
      'proof_gaps_if_not_justified': proofGapsIfNotJustified,
    };
  }

  factory ReadinessRecalibrationCandidateV1.fromJson(
    Map<String, Object?> json,
  ) {
    return ReadinessRecalibrationCandidateV1(
      canonicalReadinessSourcePath:
          json['canonical_readiness_source_path'] as String? ?? '',
      canonicalReadiness: CanonicalReadinessV1.fromProjectHealthJson(
        Map<String, Object?>.from(
          json['canonical_readiness'] as Map? ?? const <String, Object?>{},
        ),
      ),
      status: ReadinessRecalibrationCandidateStatusV1.fromWire(
        json['recalibration_candidate_status'] as String? ?? 'no_change',
      ),
      candidateBlockMovements:
          (json['candidate_block_movements'] as List<Object?>? ?? const [])
              .whereType<Map>()
              .map(
                (movement) => CandidateBlockMovementV1.fromJson(
                  Map<String, Object?>.from(movement),
                ),
              )
              .toList(),
      candidateEpicMovements:
          (json['candidate_epic_movements'] as List<Object?>? ?? const [])
              .whereType<Map>()
              .map(
                (movement) => CandidateEpicMovementV1.fromJson(
                  Map<String, Object?>.from(movement),
                ),
              )
              .toList(),
      candidateScoreDeltas: CandidateScoreDeltasV1.fromJson(
        Map<String, Object?>.from(
          json['candidate_score_deltas'] as Map? ?? const <String, Object?>{},
        ),
      ),
      rawVsEffectiveNote: json['raw_vs_effective_note'] as String? ?? '',
      recalibrationJustifiedNow:
          json['recalibration_justified_now'] as bool? ?? false,
      recalibrationReason: json['recalibration_reason'] as String? ?? '',
      proofGapsIfNotJustified:
          (json['proof_gaps_if_not_justified'] as List<Object?>? ?? const [])
              .whereType<String>()
              .toList(),
    );
  }
}

class ReadinessEpicEvidenceV1 {
  const ReadinessEpicEvidenceV1({
    required this.epicId,
    required this.candidateStatus,
    required this.evidenceRefs,
    required this.reason,
    this.justified = true,
  });

  final String epicId;
  final ReadinessEpicStatusV1 candidateStatus;
  final List<String> evidenceRefs;
  final String reason;
  final bool justified;
}

class ProjectReadinessSsotV1 {
  const ProjectReadinessSsotV1({
    required this.sourcePath,
    required this.coreReadinessPercent,
    required this.shipReadinessPercent,
    required this.finalReadinessPercent,
    required this.topBottleneckBlock,
    required this.topBottleneckEpic,
    required this.blockWeights,
    required this.blockScores,
    required this.epics,
    required this.hardBlockers,
    required this.softBlockers,
  });

  final String sourcePath;
  final double coreReadinessPercent;
  final double shipReadinessPercent;
  final double finalReadinessPercent;
  final String topBottleneckBlock;
  final String topBottleneckEpic;
  final Map<String, int> blockWeights;
  final Map<String, double> blockScores;
  final Map<String, ReadinessEpicRegistryEntryV1> epics;
  final List<String> hardBlockers;
  final List<String> softBlockers;
}

class AuditHubOperationalDashboardV1 {
  const AuditHubOperationalDashboardV1({
    required this.canonicalReadiness,
    required this.recalibrationCandidate,
    required this.completionGapSynthesis,
  });

  final CanonicalReadinessV1 canonicalReadiness;
  final ReadinessRecalibrationCandidateV1 recalibrationCandidate;
  final CompletionGapSynthesisV1 completionGapSynthesis;

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'project_health': canonicalReadiness.toProjectHealthJson(),
      'readiness_recalibration_candidate': recalibrationCandidate.toJson(),
      'completion_gap_synthesis': completionGapSynthesis.toJson(),
    });
  }
}
