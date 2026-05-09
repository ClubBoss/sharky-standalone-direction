import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/audit_hub_operational_models_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/world_pedagogical_progression_audit_v1.dart';

const projectReadinessSsotPathV1 =
    'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md';
const worldReadinessRegistryPathV1 = 'docs/plan/WORLD_READINESS_REGISTRY_v1.md';
const productSurfaceReadinessPathV1 =
    'docs/plan/PRODUCT_SURFACE_READINESS_v1.md';
const auditHubOperationalSnapshotPathForSynthesisV1 =
    'assets/audit_hub_v1/operational_snapshot.json';

AuditHubOperationalDashboardV1 buildAuditHubOperationalDashboardV1({
  required Map<String, Object?> operationalSnapshot,
  required Map<String, Object> releaseReadinessSnapshot,
  required String projectReadinessSsotContent,
  String worldReadinessRegistryContent = '',
  String productSurfaceReadinessContent = '',
  String sourcePath = projectReadinessSsotPathV1,
  String worldRegistrySourcePath = worldReadinessRegistryPathV1,
  String productSurfaceSourcePath = productSurfaceReadinessPathV1,
  String currentReviewPath = '',
  String currentTopWavePacketPath = '',
  List<ReadinessEpicEvidenceV1> explicitEvidence =
      const <ReadinessEpicEvidenceV1>[],
}) {
  final ssot = parseProjectReadinessSsotV1(
    projectReadinessSsotContent,
    sourcePath: sourcePath,
  );
  final canonicalReadiness = buildCanonicalReadinessV1(
    ssot,
    operationalSnapshot: operationalSnapshot,
  );
  final recalibrationCandidate = buildReadinessRecalibrationCandidateV1(
    ssot: ssot,
    canonicalReadiness: canonicalReadiness,
    operationalSnapshot: operationalSnapshot,
    releaseReadinessSnapshot: releaseReadinessSnapshot,
    explicitEvidence: explicitEvidence,
  );
  final completionGapSynthesis = buildCompletionGapSynthesisV1(
    ssot: ssot,
    operationalSnapshot: operationalSnapshot,
    releaseReadinessSnapshot: releaseReadinessSnapshot,
    canonicalReadiness: canonicalReadiness,
    recalibrationCandidate: recalibrationCandidate,
    worldReadinessRegistryContent: worldReadinessRegistryContent,
    productSurfaceReadinessContent: productSurfaceReadinessContent,
    worldRegistrySourcePath: worldRegistrySourcePath,
    productSurfaceSourcePath: productSurfaceSourcePath,
    currentReviewPath: currentReviewPath,
    currentTopWavePacketPath: currentTopWavePacketPath,
  );
  return AuditHubOperationalDashboardV1(
    canonicalReadiness: canonicalReadiness,
    recalibrationCandidate: recalibrationCandidate,
    completionGapSynthesis: completionGapSynthesis,
  );
}

AuditHubOperationalDashboardV1
readAuditHubOperationalDashboardFromSnapshotFileV1(String snapshotPath) {
  final file = File(snapshotPath);
  if (!file.existsSync()) {
    throw StateError('Missing Audit Hub snapshot: $snapshotPath');
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw StateError('Invalid Audit Hub snapshot payload: $snapshotPath');
  }
  final snapshot = Map<String, Object?>.from(decoded);
  final canonicalReadiness = CanonicalReadinessV1.fromProjectHealthJson(
    Map<String, Object?>.from(
      snapshot['project_health'] as Map? ?? const <String, Object?>{},
    ),
  );
  final recalibrationCandidate = snapshot['readiness_recalibration_candidate'];
  if (recalibrationCandidate is Map) {
    return AuditHubOperationalDashboardV1(
      canonicalReadiness: canonicalReadiness,
      recalibrationCandidate: ReadinessRecalibrationCandidateV1.fromJson(
        Map<String, Object?>.from(recalibrationCandidate),
      ),
      completionGapSynthesis: snapshot['completion_gap_synthesis'] is Map
          ? CompletionGapSynthesisV1.fromJson(
              Map<String, Object?>.from(
                snapshot['completion_gap_synthesis'] as Map,
              ),
            )
          : const CompletionGapSynthesisV1(
              sourceTruthOwners: <String>[
                projectReadinessSsotPathV1,
                worldReadinessRegistryPathV1,
                productSurfaceReadinessPathV1,
              ],
              gaps: <CompletionGapEntryV1>[],
              topMachineFrontier: null,
              recommendedNextFrontier: null,
              pausedManualClusters: <String>[],
              nextBestMachineFrontiers: <CompletionGapEntryV1>[],
              why100NotReached: <String>[
                'Run the Audit Hub refresh path to compute the completion-gap synthesis layer.',
              ],
              allRemainingGapsCount: 0,
              machineReducibleRemainingCount: 0,
              manualBoundRemainingCount: 0,
            ),
    );
  }
  return AuditHubOperationalDashboardV1(
    canonicalReadiness: canonicalReadiness,
    recalibrationCandidate: ReadinessRecalibrationCandidateV1(
      canonicalReadinessSourcePath: canonicalReadiness.sourceSsotPath,
      canonicalReadiness: canonicalReadiness,
      status: ReadinessRecalibrationCandidateStatusV1.insufficientProof,
      candidateBlockMovements: const <CandidateBlockMovementV1>[],
      candidateEpicMovements: const <CandidateEpicMovementV1>[],
      candidateScoreDeltas: const CandidateScoreDeltasV1(
        coreDelta: 0,
        shipDelta: 0,
        finalDelta: 0,
      ),
      rawVsEffectiveNote:
          'Canonical readiness remains the reporting source of truth until a recalibration wave is explicitly admitted.',
      recalibrationJustifiedNow: false,
      recalibrationReason:
          'Snapshot is missing the readiness recalibration candidate layer.',
      proofGapsIfNotJustified: const <String>[
        'Run the Audit Hub refresh path to compute the readiness recalibration candidate.',
      ],
    ),
    completionGapSynthesis: const CompletionGapSynthesisV1(
      sourceTruthOwners: <String>[
        projectReadinessSsotPathV1,
        worldReadinessRegistryPathV1,
        productSurfaceReadinessPathV1,
      ],
      gaps: <CompletionGapEntryV1>[],
      topMachineFrontier: null,
      recommendedNextFrontier: null,
      pausedManualClusters: <String>[],
      nextBestMachineFrontiers: <CompletionGapEntryV1>[],
      why100NotReached: <String>[
        'Run the Audit Hub refresh path to compute the completion-gap synthesis layer.',
      ],
      allRemainingGapsCount: 0,
      machineReducibleRemainingCount: 0,
      manualBoundRemainingCount: 0,
    ),
  );
}

ProjectReadinessSsotV1 parseProjectReadinessSsotV1(
  String content, {
  String sourcePath = projectReadinessSsotPathV1,
}) {
  final coreScore = _extractDoubleValue(
    content,
    RegExp(r'Core Product Readiness = `([0-9.]+) / 100`'),
    fallbackPattern: RegExp(r'Core Product Readiness: `([0-9.]+) / 100`'),
  );
  final shipScore = _extractDoubleValue(
    content,
    RegExp(r'Ship / Distribution Readiness = `([0-9.]+) / 100`'),
    fallbackPattern: RegExp(
      r'Ship / Distribution Readiness: `([0-9.]+) / 100`',
    ),
  );
  final finalScore = _extractDoubleValue(
    content,
    RegExp(r'Final Product Readiness = `([0-9.]+) / 100`'),
    fallbackPattern: RegExp(r'Final Product Readiness: `([0-9.]+) / 100`'),
  );

  final topBottleneckBlock = _extractStringValue(
    content,
    RegExp(r'Top bottleneck blocks:\s*\n\n1\. `([^`]+)`'),
  );
  final topBottleneckEpic = _extractStringValue(
    content,
    RegExp(r'Top bottleneck epics:\s*\n\n1\. ([^\n]+)'),
  ).replaceAll('`', '');

  final blockWeights = <String, int>{};
  for (final match in RegExp(
    r'- `([A-N])=([0-9]+)`',
    multiLine: true,
  ).allMatches(content)) {
    blockWeights[match.group(1)!] = int.parse(match.group(2)!);
  }

  final blockScores = <String, double>{};
  for (final match in RegExp(
    r'- `([A-N])=([0-9.]+)`',
    multiLine: true,
  ).allMatches(content)) {
    final blockId = match.group(1)!;
    final score = double.parse(match.group(2)!);
    if (!blockScores.containsKey(blockId) || score <= 1.0) {
      blockScores[blockId] = score;
    }
  }

  final hardBlockers = _extractBulletSection(content, 'Hard blockers:');
  final softBlockers = _extractBulletSection(content, 'Soft blockers:');

  final epics = <String, ReadinessEpicRegistryEntryV1>{};
  String? currentBlockId;
  String? currentBlockTitle;
  String? currentEpicId;
  String? currentEpicTitle;
  String? currentBlockingLevel;
  ReadinessEpicStatusV1? currentStatus;

  void flushCurrentEpic() {
    if (currentBlockId == null ||
        currentBlockTitle == null ||
        currentEpicId == null ||
        currentEpicTitle == null ||
        currentStatus == null ||
        currentBlockingLevel == null) {
      return;
    }
    epics[currentEpicId] = ReadinessEpicRegistryEntryV1(
      id: currentEpicId,
      blockId: currentBlockId,
      blockTitle: currentBlockTitle,
      title: currentEpicTitle,
      status: currentStatus,
      blockingLevel: currentBlockingLevel,
    );
  }

  for (final rawLine in const LineSplitter().convert(content)) {
    final line = rawLine.trimRight();
    final blockMatch = RegExp(r'^### ([A-N]) (.+)$').firstMatch(line);
    if (blockMatch != null) {
      flushCurrentEpic();
      currentEpicId = null;
      currentEpicTitle = null;
      currentStatus = null;
      currentBlockingLevel = null;
      currentBlockId = blockMatch.group(1);
      currentBlockTitle = blockMatch.group(2);
      continue;
    }

    final epicHeadingMatch = RegExp(
      r'^#### ([A-N]\d+)\. (.+)$',
    ).firstMatch(line);
    if (epicHeadingMatch != null) {
      flushCurrentEpic();
      currentEpicId = epicHeadingMatch.group(1);
      currentEpicTitle = epicHeadingMatch.group(2);
      currentStatus = null;
      currentBlockingLevel = null;
      continue;
    }

    if (line.startsWith('- id: ')) {
      currentEpicId = line.substring(6).trim();
      continue;
    }
    if (line.startsWith('- title: ')) {
      currentEpicTitle = line.substring(9).trim();
      continue;
    }
    if (line.startsWith('- status: ')) {
      currentStatus = ReadinessEpicStatusV1.fromWire(line.substring(10).trim());
      continue;
    }
    if (line.startsWith('- blocking_level: ')) {
      currentBlockingLevel = line.substring(18).trim();
      continue;
    }
  }
  flushCurrentEpic();

  return ProjectReadinessSsotV1(
    sourcePath: sourcePath,
    coreReadinessPercent: coreScore,
    shipReadinessPercent: shipScore,
    finalReadinessPercent: finalScore,
    topBottleneckBlock: topBottleneckBlock,
    topBottleneckEpic: topBottleneckEpic,
    blockWeights: blockWeights,
    blockScores: blockScores,
    epics: epics,
    hardBlockers: hardBlockers,
    softBlockers: softBlockers,
  );
}

CanonicalReadinessV1 buildCanonicalReadinessV1(
  ProjectReadinessSsotV1 ssot, {
  required Map<String, Object?> operationalSnapshot,
}) {
  final existingProjectHealth = Map<String, Object?>.from(
    operationalSnapshot['project_health'] as Map? ?? const <String, Object?>{},
  );
  final whatBlocksHundredNow =
      (existingProjectHealth['what_blocks_hundred_now'] as List<Object?>? ??
              const <Object?>[])
          .whereType<String>()
          .toList();

  return CanonicalReadinessV1(
    sourceSsotPath: ssot.sourcePath,
    coreReadinessPercent: ssot.coreReadinessPercent,
    shipReadinessPercent: ssot.shipReadinessPercent,
    finalReadinessPercent: ssot.finalReadinessPercent,
    topBottleneckBlock: ssot.topBottleneckBlock,
    topBottleneckEpic: ssot.topBottleneckEpic,
    confidenceNote:
        'Percentages and bottleneck order come from ${ssot.sourcePath}. The hub does not rescore readiness; it evaluates whether current live truth justifies an explicit SSOT recalibration wave.',
    whatBlocksHundredNow: whatBlocksHundredNow,
    hardBlockers: ssot.hardBlockers,
    softBlockers: ssot.softBlockers,
    explanation:
        'Core/Ship/Final values remain the canonical readiness outputs from the active SSOT. The recalibration candidate layer is subordinate live evidence about whether a real SSOT recalibration wave is justified.',
  );
}

ReadinessRecalibrationCandidateV1 buildReadinessRecalibrationCandidateV1({
  required ProjectReadinessSsotV1 ssot,
  required CanonicalReadinessV1 canonicalReadiness,
  required Map<String, Object?> operationalSnapshot,
  required Map<String, Object> releaseReadinessSnapshot,
  List<ReadinessEpicEvidenceV1> explicitEvidence =
      const <ReadinessEpicEvidenceV1>[],
}) {
  final proofGaps = _collectProofGaps(
    operationalSnapshot: operationalSnapshot,
    releaseReadinessSnapshot: releaseReadinessSnapshot,
  );
  final automaticEvidence = _deriveAutomaticEvidenceFromLiveTruth(
    ssot: ssot,
    releaseReadinessSnapshot: releaseReadinessSnapshot,
  );

  final justifiedEpicMovements = <CandidateEpicMovementV1>[];
  final insufficientProofReasons = <String>[];

  for (final evidence in <ReadinessEpicEvidenceV1>[
    ...automaticEvidence,
    ...explicitEvidence,
  ]) {
    final canonicalEpic = ssot.epics[evidence.epicId];
    if (canonicalEpic == null ||
        canonicalEpic.status == evidence.candidateStatus) {
      continue;
    }
    if (!evidence.justified) {
      insufficientProofReasons.add(evidence.reason);
      continue;
    }
    final direction =
        (evidence.candidateStatus.rawWeight ?? 0) >
            (canonicalEpic.status.rawWeight ?? 0)
        ? ReadinessCandidateMovementDirectionV1.increase
        : ReadinessCandidateMovementDirectionV1.decrease;
    justifiedEpicMovements.add(
      CandidateEpicMovementV1(
        epicId: canonicalEpic.id,
        blockId: canonicalEpic.blockId,
        blockTitle: canonicalEpic.blockTitle,
        canonicalStatus: canonicalEpic.status,
        candidateStatus: evidence.candidateStatus,
        direction: direction,
        evidenceRefs: evidence.evidenceRefs,
        reason: evidence.reason,
      ),
    );
  }

  if (justifiedEpicMovements.isEmpty) {
    final status = insufficientProofReasons.isNotEmpty
        ? ReadinessRecalibrationCandidateStatusV1.insufficientProof
        : ReadinessRecalibrationCandidateStatusV1.noChange;
    final reason = insufficientProofReasons.isNotEmpty
        ? 'Refresh required or live proof is insufficient to justify exact SSOT epic-state movement.'
        : 'No justified readiness change. Current live truth does not prove any SSOT epic-state movement.';
    final gaps = <String>[...proofGaps, ...insufficientProofReasons];
    return ReadinessRecalibrationCandidateV1(
      canonicalReadinessSourcePath: canonicalReadiness.sourceSsotPath,
      canonicalReadiness: canonicalReadiness,
      status: status,
      candidateBlockMovements: const <CandidateBlockMovementV1>[],
      candidateEpicMovements: const <CandidateEpicMovementV1>[],
      candidateScoreDeltas: const CandidateScoreDeltasV1(
        coreDelta: 0,
        shipDelta: 0,
        finalDelta: 0,
      ),
      rawVsEffectiveNote:
          'Canonical readiness remains the reporting source of truth. Raw score drift is ignored unless explicit SSOT epic-state movement is justified, and any future candidate movement would still be capped by prerequisite and proof-floor rules where applicable.',
      recalibrationJustifiedNow: false,
      recalibrationReason: reason,
      proofGapsIfNotJustified: gaps.isEmpty
          ? const <String>[
              'No exact epic movement is justified from current live truth.',
            ]
          : gaps,
    );
  }

  final candidateStatuses = <String, ReadinessEpicStatusV1>{
    for (final epic in ssot.epics.values) epic.id: epic.status,
  };
  for (final movement in justifiedEpicMovements) {
    candidateStatuses[movement.epicId] = movement.candidateStatus;
  }

  final touchedBlocks =
      justifiedEpicMovements
          .map((movement) => movement.blockId)
          .toSet()
          .toList()
        ..sort();
  final candidateBlockMovements = <CandidateBlockMovementV1>[];
  for (final blockId in touchedBlocks) {
    final before = _computeBlockScoreV1(
      ssot: ssot,
      blockId: blockId,
      candidateStatuses: <String, ReadinessEpicStatusV1>{},
    );
    final after = _computeBlockScoreV1(
      ssot: ssot,
      blockId: blockId,
      candidateStatuses: candidateStatuses,
    );
    final blockTitle = ssot.epics.values
        .firstWhere((epic) => epic.blockId == blockId)
        .blockTitle;
    candidateBlockMovements.add(
      CandidateBlockMovementV1(
        blockId: blockId,
        blockTitle: blockTitle,
        rawScoreBefore: before.rawScore,
        rawScoreAfter: after.rawScore,
        effectiveScoreBefore: before.effectiveScore,
        effectiveScoreAfter: after.effectiveScore,
        effectiveCapReason: after.rawScore > after.effectiveScore
            ? after.capReason
            : null,
      ),
    );
  }

  final scoreDeltas = _computeScoreDeltasV1(
    ssot: ssot,
    candidateStatuses: candidateStatuses,
  );
  final hasIncrease = justifiedEpicMovements.any(
    (movement) =>
        movement.direction == ReadinessCandidateMovementDirectionV1.increase,
  );
  final hasDecrease = justifiedEpicMovements.any(
    (movement) =>
        movement.direction == ReadinessCandidateMovementDirectionV1.decrease,
  );
  final status = hasIncrease && !hasDecrease
      ? ReadinessRecalibrationCandidateStatusV1.candidateIncrease
      : (!hasIncrease && hasDecrease
            ? ReadinessRecalibrationCandidateStatusV1.candidateDecrease
            : ReadinessRecalibrationCandidateStatusV1.insufficientProof);
  final rawVsEffectiveNote =
      candidateBlockMovements.any(
        (movement) => (movement.effectiveCapReason ?? '').isNotEmpty,
      )
      ? 'Candidate raw score movement is computed from SSOT epic-state weights, but reported readiness remains capped by the SSOT proof-floor and prerequisite rules until the affected blocks clear those caps.'
      : 'Candidate raw and effective scores are identical for the justified movements in this pass.';

  return ReadinessRecalibrationCandidateV1(
    canonicalReadinessSourcePath: canonicalReadiness.sourceSsotPath,
    canonicalReadiness: canonicalReadiness,
    status: status,
    candidateBlockMovements: candidateBlockMovements,
    candidateEpicMovements: justifiedEpicMovements,
    candidateScoreDeltas: scoreDeltas,
    rawVsEffectiveNote: rawVsEffectiveNote,
    recalibrationJustifiedNow:
        status != ReadinessRecalibrationCandidateStatusV1.insufficientProof,
    recalibrationReason:
        'Current live truth justifies explicit SSOT recalibration candidate movement in ${justifiedEpicMovements.length} epic(s).',
    proofGapsIfNotJustified: const <String>[],
  );
}

CompletionGapSynthesisV1 buildCompletionGapSynthesisV1({
  required ProjectReadinessSsotV1 ssot,
  required Map<String, Object?> operationalSnapshot,
  required Map<String, Object> releaseReadinessSnapshot,
  required CanonicalReadinessV1 canonicalReadiness,
  required ReadinessRecalibrationCandidateV1 recalibrationCandidate,
  required String worldReadinessRegistryContent,
  required String productSurfaceReadinessContent,
  required String worldRegistrySourcePath,
  required String productSurfaceSourcePath,
  required String currentReviewPath,
  required String currentTopWavePacketPath,
}) {
  final blockTitles = <String, String>{
    for (final epic in ssot.epics.values) epic.blockId: epic.blockTitle,
  };
  final worldRegistryRows = parseWorldReadinessRegistryRowsV1(
    worldReadinessRegistryContent,
  );
  final worldRegistryById = <String, WorldReadinessRegistryRowV1>{
    for (final row in worldRegistryRows) row.worldId: row,
  };
  final productSurfaceFamilies = parseProductSurfaceFamiliesV1(
    productSurfaceReadinessContent,
  );
  final topWavePacket = Map<String, Object?>.from(
    operationalSnapshot['top_wave_packet'] as Map? ?? const <String, Object?>{},
  );
  final queueEntries =
      (operationalSnapshot['codex_work_queue'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final blockerClusters =
      (operationalSnapshot['blocker_clusters'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList();
  final clusterById = <String, Map<String, Object?>>{
    for (final cluster in blockerClusters)
      if ((cluster['cluster_id'] as String?)?.isNotEmpty ?? false)
        cluster['cluster_id'] as String: cluster,
  };
  final unificationByWorldId = <String, Map<String, Object?>>{};
  for (final entry
      in (operationalSnapshot['unification_matrix'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)) {
    final worldId = entry['world_id'] as String?;
    if (worldId != null && !unificationByWorldId.containsKey(worldId)) {
      unificationByWorldId[worldId] = entry;
    }
  }
  final worldTruthSurfaceById = <String, Map<String, Object?>>{};
  for (final entry
      in (operationalSnapshot['world_truth_surfaces'] as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)) {
    final worldId = entry['world_id'] as String?;
    if (worldId != null && !worldTruthSurfaceById.containsKey(worldId)) {
      worldTruthSurfaceById[worldId] = entry;
    }
  }
  final worldOwnershipInventoryById = <String, Map<String, Object?>>{};
  for (final entry
      in (operationalSnapshot['world_route_ownership_inventories']
                  as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)) {
    final worldId = entry['world_id'] as String?;
    if (worldId != null && !worldOwnershipInventoryById.containsKey(worldId)) {
      worldOwnershipInventoryById[worldId] = entry;
    }
  }
  final worldVisualInstrumentationById = <String, Map<String, Object?>>{};
  for (final entry
      in (operationalSnapshot['world_visual_instrumentation_surfaces']
                  as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)) {
    final worldId = entry['world_id'] as String?;
    if (worldId != null &&
        !worldVisualInstrumentationById.containsKey(worldId)) {
      worldVisualInstrumentationById[worldId] = entry;
    }
  }
  final worldScreenshotEvidenceById = <String, Map<String, Object?>>{};
  for (final entry
      in (operationalSnapshot['world_screenshot_evidence_surfaces']
                  as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)) {
    final worldId = entry['world_id'] as String?;
    if (worldId != null && !worldScreenshotEvidenceById.containsKey(worldId)) {
      worldScreenshotEvidenceById[worldId] = entry;
    }
  }

  final gaps = _normalizeCompletionGapRoutingV1(<CompletionGapEntryV1>[
    ..._buildQueueGapEntriesV1(
      queueEntries: queueEntries,
      releaseReadinessSnapshot: releaseReadinessSnapshot,
      topWavePacketPath: currentTopWavePacketPath,
      reviewPath: currentReviewPath,
      productSurfaceSourcePath: productSurfaceSourcePath,
      productSurfaceFamilies: productSurfaceFamilies,
      topWavePacket: topWavePacket,
      clusterById: clusterById,
    ),
    ..._buildWorldGapEntriesV1(
      worlds: (operationalSnapshot['worlds'] as List<Object?>? ?? const [])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(),
      worldRegistryById: worldRegistryById,
      worldRegistrySourcePath: worldRegistrySourcePath,
      blockTitles: blockTitles,
      unificationByWorldId: unificationByWorldId,
      worldTruthSurfaceById: worldTruthSurfaceById,
      worldOwnershipInventoryById: worldOwnershipInventoryById,
      worldVisualInstrumentationById: worldVisualInstrumentationById,
      worldScreenshotEvidenceById: worldScreenshotEvidenceById,
    ),
    ..._buildPedagogicalProgressionGapEntriesV1(
      operationalSnapshot: operationalSnapshot,
    ),
  ])..sort(_compareCompletionGapsV1);

  final topMachineFrontier = gaps
      .where(
        (gap) =>
            gap.admissibility ==
            CompletionGapAdmissibilityV1.machineReducibleNow,
      )
      .cast<CompletionGapEntryV1?>()
      .firstWhere((gap) => gap != null, orElse: () => null);
  final nextBestMachineFrontiers = gaps
      .where(
        (gap) =>
            gap.admissibility ==
            CompletionGapAdmissibilityV1.machineReducibleNow,
      )
      .skip(topMachineFrontier == null ? 0 : 1)
      .take(3)
      .toList();
  final recommendedNextFrontier = gaps
      .where(
        (gap) => gap.admissibility != CompletionGapAdmissibilityV1.external,
      )
      .cast<CompletionGapEntryV1?>()
      .firstWhere((gap) => gap != null, orElse: () => null);
  final why100NotReached = <String>{
    ...canonicalReadiness.whatBlocksHundredNow,
    ...recalibrationCandidate.proofGapsIfNotJustified,
    ..._buildPedagogicalProgressionWhy100NotReachedV1(
      operationalSnapshot: operationalSnapshot,
    ),
  }.toList()..sort();
  final pausedManualClusters = gaps
      .where(
        (gap) =>
            gap.category == 'cluster' &&
            gap.admissibility == CompletionGapAdmissibilityV1.proofManualOnly,
      )
      .map((gap) => gap.title)
      .toList();

  return CompletionGapSynthesisV1(
    sourceTruthOwners: <String>[
      ssot.sourcePath,
      worldRegistrySourcePath,
      productSurfaceSourcePath,
      if (currentReviewPath.isNotEmpty) currentReviewPath,
      if (currentTopWavePacketPath.isNotEmpty) currentTopWavePacketPath,
      auditHubOperationalSnapshotPathForSynthesisV1,
    ],
    gaps: gaps,
    topMachineFrontier: topMachineFrontier,
    recommendedNextFrontier: recommendedNextFrontier,
    pausedManualClusters: pausedManualClusters,
    nextBestMachineFrontiers: nextBestMachineFrontiers,
    why100NotReached: why100NotReached,
    allRemainingGapsCount: gaps.length,
    machineReducibleRemainingCount: gaps
        .where(
          (gap) =>
              gap.admissibility ==
              CompletionGapAdmissibilityV1.machineReducibleNow,
        )
        .length,
    manualBoundRemainingCount: gaps
        .where(
          (gap) =>
              gap.admissibility == CompletionGapAdmissibilityV1.proofManualOnly,
        )
        .length,
  );
}

List<CompletionGapEntryV1> _buildPedagogicalProgressionGapEntriesV1({
  required Map<String, Object?> operationalSnapshot,
}) {
  final summary = Map<String, Object?>.from(
    operationalSnapshot['pedagogical_progression_truth'] as Map? ??
        const <String, Object?>{},
  );
  final openFindingCount =
      (summary['open_finding_count'] as num?)?.toInt() ?? 0;
  if (openFindingCount == 0) {
    return const <CompletionGapEntryV1>[];
  }

  final affectedWorlds =
      (summary['affected_worlds'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toList(growable: false);
  final topCategories =
      (summary['top_categories'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toList(growable: false);
  final reports =
      (operationalSnapshot['world_pedagogical_progression_surfaces']
                  as List<Object?>? ??
              const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final ownerFiles = <String>{
    progressionPrerequisiteMatrixPathV1,
    worldPedagogicalProgressionAuditSourcePathV1,
    for (final worldId in affectedWorlds.take(4))
      'content/worlds/world${worldId.substring(1).toLowerCase()}/v1/world.md',
  }.toList(growable: false);
  final measurableProofPath = <String>[
    for (final worldId in affectedWorlds.take(4))
      'dart run $worldPedagogicalProgressionAuditToolPathV1 --world=${worldId.substring(1)} --json',
  ];
  final blockers = <String>[
    ...(summary['coverage_notes'] as List<Object?>? ?? const <Object?>[])
        .whereType<String>(),
    ...reports
        .expand(
          (report) =>
              (report['findings'] as List<Object?>? ?? const <Object?>[])
                  .whereType<Map>()
                  .take(1)
                  .map(
                    (finding) => '${finding['gap_id']}: ${finding['reason']}',
                  ),
        )
        .take(4),
  ];

  return <CompletionGapEntryV1>[
    CompletionGapEntryV1(
      gapId: 'cluster_pedagogical_progression_truth',
      sourceTruthOwner: progressionPrerequisiteMatrixPathV1,
      title: 'Pedagogical Correctness / Progression',
      category: 'cluster',
      worldScope: affectedWorlds,
      surfaceScope: topCategories,
      readinessBlocks: const <String>['D', 'F', 'J', 'G'],
      epicMappings: const <String>[
        'D Feedback / Explanation Quality',
        'F Learning Effect / Pedagogy',
        'J Onboarding / Trust / First-Session Framing',
        'G Cross-World Product Consistency',
      ],
      currentStatus: 'truth_surfaced',
      admissibility: CompletionGapAdmissibilityV1.truthLayerFirst,
      likelySeam: topCategories.isEmpty
          ? 'pedagogical/progression truth'
          : topCategories.join(' | '),
      ownerFiles: ownerFiles,
      measurableProofPath: measurableProofPath,
      prerequisiteBlockers: blockers,
      evPriorityOrder: 111,
      nextFrontierReason:
          'Pedagogical/progression issues are now surfaced as repo-owned truth and should be understood before later-world or release-grade finish work is claimed as coherent.',
    ),
  ];
}

List<String> _buildPedagogicalProgressionWhy100NotReachedV1({
  required Map<String, Object?> operationalSnapshot,
}) {
  final summary = Map<String, Object?>.from(
    operationalSnapshot['pedagogical_progression_truth'] as Map? ??
        const <String, Object?>{},
  );
  final openFindingCount =
      (summary['open_finding_count'] as num?)?.toInt() ?? 0;
  if (openFindingCount == 0) {
    return const <String>[];
  }
  return <String>[
    'Pedagogical / progression truth now surfaces $openFindingCount open finding(s) that still need governed interpretation before 100/100 can be claimed honestly.',
  ];
}

class _BlockScoreComputationV1 {
  const _BlockScoreComputationV1({
    required this.rawScore,
    required this.effectiveScore,
    required this.capReason,
  });

  final double rawScore;
  final double effectiveScore;
  final String capReason;
}

_BlockScoreComputationV1 _computeBlockScoreV1({
  required ProjectReadinessSsotV1 ssot,
  required String blockId,
  required Map<String, ReadinessEpicStatusV1> candidateStatuses,
}) {
  final activeEpics = ssot.epics.values
      .where(
        (epic) =>
            epic.blockId == blockId &&
            epic.status != ReadinessEpicStatusV1.deferred,
      )
      .toList();
  if (activeEpics.isEmpty) {
    return const _BlockScoreComputationV1(
      rawScore: 0,
      effectiveScore: 0,
      capReason: '',
    );
  }

  final statuses = activeEpics
      .map((epic) => candidateStatuses[epic.id] ?? epic.status)
      .toList();
  final rawScore =
      statuses
          .map((status) => status.rawWeight ?? 0)
          .reduce((value, element) => value + element) /
      statuses.length;

  var cap = 1.0;
  var capReason = '';
  if (statuses.every((status) => status == ReadinessEpicStatusV1.done)) {
    cap = 1.0;
  } else if (statuses.any(
    (status) =>
        status == ReadinessEpicStatusV1.blocked ||
        status == ReadinessEpicStatusV1.inProgress ||
        status == ReadinessEpicStatusV1.notStarted,
  )) {
    cap = 0.40;
    capReason =
        'Active epics remain below proof floor; reporting stays capped at in_progress effective closure (0.40).';
  } else if (statuses.any(
    (status) => status == ReadinessEpicStatusV1.proofPending,
  )) {
    cap = 0.70;
    capReason =
        'Active epics still depend on machine-proof floor closure; reporting stays capped at proof_pending effective closure (0.70).';
  } else if (statuses.any(
    (status) => status == ReadinessEpicStatusV1.humanProofPending,
  )) {
    cap = 0.85;
    capReason =
        'Only required human proof remains open; reporting stays capped at human_proof_pending effective closure (0.85).';
  }

  return _BlockScoreComputationV1(
    rawScore: double.parse(rawScore.toStringAsFixed(4)),
    effectiveScore: double.parse(rawScore.clamp(0, cap).toStringAsFixed(4)),
    capReason: capReason,
  );
}

CandidateScoreDeltasV1 _computeScoreDeltasV1({
  required ProjectReadinessSsotV1 ssot,
  required Map<String, ReadinessEpicStatusV1> candidateStatuses,
}) {
  final allBlockIds = ssot.blockWeights.keys.toList()..sort();
  final beforeScores = <String, _BlockScoreComputationV1>{
    for (final blockId in allBlockIds)
      blockId: _computeBlockScoreV1(
        ssot: ssot,
        blockId: blockId,
        candidateStatuses: const <String, ReadinessEpicStatusV1>{},
      ),
  };
  final afterScores = <String, _BlockScoreComputationV1>{
    for (final blockId in allBlockIds)
      blockId: _computeBlockScoreV1(
        ssot: ssot,
        blockId: blockId,
        candidateStatuses: candidateStatuses,
      ),
  };

  final beforeCore = _weightedReadinessPercentV1(
    ssot: ssot,
    blockScores: beforeScores,
    includeShip: false,
  );
  final afterCore = _weightedReadinessPercentV1(
    ssot: ssot,
    blockScores: afterScores,
    includeShip: false,
  );
  final beforeShip = _weightedReadinessPercentV1(
    ssot: ssot,
    blockScores: beforeScores,
    includeShip: true,
  );
  final afterShip = _weightedReadinessPercentV1(
    ssot: ssot,
    blockScores: afterScores,
    includeShip: true,
  );
  final beforeFinal = _weightedReadinessPercentV1(
    ssot: ssot,
    blockScores: beforeScores,
    includeShip: null,
  );
  final afterFinal = _weightedReadinessPercentV1(
    ssot: ssot,
    blockScores: afterScores,
    includeShip: null,
  );

  return CandidateScoreDeltasV1(
    coreDelta: double.parse((afterCore - beforeCore).toStringAsFixed(1)),
    shipDelta: double.parse((afterShip - beforeShip).toStringAsFixed(1)),
    finalDelta: double.parse((afterFinal - beforeFinal).toStringAsFixed(1)),
  );
}

double _weightedReadinessPercentV1({
  required ProjectReadinessSsotV1 ssot,
  required Map<String, _BlockScoreComputationV1> blockScores,
  required bool? includeShip,
}) {
  final selectedBlockIds = ssot.blockWeights.keys.where((blockId) {
    final isShip = blockId.codeUnitAt(0) >= 'K'.codeUnitAt(0);
    if (includeShip == null) return true;
    return includeShip ? isShip : !isShip;
  }).toList();
  final totalWeight = selectedBlockIds
      .map((blockId) => ssot.blockWeights[blockId] ?? 0)
      .fold<int>(0, (sum, value) => sum + value);
  if (totalWeight == 0) return 0;
  final weightedValue = selectedBlockIds.fold<double>(0, (sum, blockId) {
    final weight = ssot.blockWeights[blockId] ?? 0;
    final score = blockScores[blockId]?.effectiveScore ?? 0;
    return sum + (score * weight);
  });
  return double.parse(((weightedValue / totalWeight) * 100).toStringAsFixed(1));
}

List<ReadinessEpicEvidenceV1> _deriveAutomaticEvidenceFromLiveTruth({
  required ProjectReadinessSsotV1 ssot,
  required Map<String, Object> releaseReadinessSnapshot,
}) {
  final evidence = <ReadinessEpicEvidenceV1>[];
  final m1 = ssot.epics['M1'];
  if (m1 != null &&
      m1.status == ReadinessEpicStatusV1.done &&
      ((releaseReadinessSnapshot['baselineDocPresent'] as bool? ?? true) ==
              false ||
          (releaseReadinessSnapshot['releaseDryRunGateScriptPresent']
                      as bool? ??
                  true) ==
              false ||
          (releaseReadinessSnapshot['world1ReleaseGateScriptPresent']
                      as bool? ??
                  true) ==
              false)) {
    evidence.add(
      const ReadinessEpicEvidenceV1(
        epicId: 'M1',
        candidateStatus: ReadinessEpicStatusV1.blocked,
        evidenceRefs: <String>['tools/release_readiness_snapshot_v1.dart'],
        reason:
            'Current release-readiness snapshot contradicts the prerequisites that support canonical M1 closure.',
      ),
    );
  }
  return evidence;
}

List<String> _collectProofGaps({
  required Map<String, Object?> operationalSnapshot,
  required Map<String, Object> releaseReadinessSnapshot,
}) {
  final gaps = <String>{};
  final projectHealth = Map<String, Object?>.from(
    operationalSnapshot['project_health'] as Map? ?? const <String, Object?>{},
  );
  for (final gap
      in (projectHealth['what_blocks_hundred_now'] as List<Object?>? ??
          const <Object?>[])) {
    if (gap is String && gap.trim().isNotEmpty) {
      gaps.add(gap);
    }
  }

  final latestRun = Map<String, Object?>.from(
    operationalSnapshot['latest_run'] as Map? ?? const <String, Object?>{},
  );
  for (final blocker
      in (latestRun['key_blockers'] as List<Object?>? ?? const <Object?>[])) {
    if (blocker is String && blocker.trim().isNotEmpty) {
      gaps.add(blocker);
    }
  }

  if (releaseReadinessSnapshot['goNoGoStateIsHold'] == true) {
    gaps.add('Release readiness snapshot still reports HOLD on current main.');
  }
  if (releaseReadinessSnapshot['humanReviewStatePending'] == true) {
    gaps.add('Human release review remains pending on current main.');
  }
  if (releaseReadinessSnapshot['rollbackTruthSaysUnresolved'] == true) {
    gaps.add('Rollback truth remains unresolved on current main.');
  }
  if (releaseReadinessSnapshot['operationalDashboardTruthSaysNoCanonicalDashboard'] ==
      true) {
    gaps.add(
      'Operational dashboard ownership still lacks a canonical governed decision owner.',
    );
  }

  return gaps.toList()..sort();
}

class WorldReadinessRegistryRowV1 {
  const WorldReadinessRegistryRowV1({
    required this.worldId,
    required this.qualitySummary,
    required this.readinessLinks,
    required this.contentClarity,
    required this.pedagogyLearningEffect,
    required this.feedbackExplanationQuality,
    required this.learnerLanguageNaturalness,
    required this.contentRuntimeAlignment,
    required this.crossWorldConsistencyFit,
    required this.topOpenGaps,
    required this.evidenceRefs,
    required this.releaseGradeBlockerNote,
  });

  final String worldId;
  final String qualitySummary;
  final List<String> readinessLinks;
  final String contentClarity;
  final String pedagogyLearningEffect;
  final String feedbackExplanationQuality;
  final String learnerLanguageNaturalness;
  final String contentRuntimeAlignment;
  final String crossWorldConsistencyFit;
  final List<String> topOpenGaps;
  final List<String> evidenceRefs;
  final String releaseGradeBlockerNote;

  String get readinessStatus {
    final statuses = <String>[
      contentClarity,
      pedagogyLearningEffect,
      feedbackExplanationQuality,
      learnerLanguageNaturalness,
      contentRuntimeAlignment,
      crossWorldConsistencyFit,
    ];
    if (statuses.every((status) => status == 'done')) {
      return 'done';
    }
    if (statuses.contains('human_proof_pending')) {
      return 'human_proof_pending';
    }
    if (statuses.contains('proof_pending')) {
      return 'proof_pending';
    }
    if (statuses.contains('blocked')) {
      return 'blocked';
    }
    return 'in_progress';
  }
}

List<WorldReadinessRegistryRowV1> parseWorldReadinessRegistryRowsV1(
  String content,
) {
  final rows = <WorldReadinessRegistryRowV1>[];
  for (final rawLine in const LineSplitter().convert(content)) {
    final line = rawLine.trimRight();
    if (!line.startsWith('| `W')) {
      continue;
    }
    final columns = line
        .split('|')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (columns.length < 13) {
      continue;
    }
    final worldId = columns[0].replaceAll('`', '');
    rows.add(
      WorldReadinessRegistryRowV1(
        worldId: worldId,
        qualitySummary: columns[2],
        readinessLinks: columns[3]
            .split(',')
            .map((part) => part.replaceAll('`', '').trim())
            .where((part) => part.isNotEmpty)
            .toList(),
        contentClarity: columns[4].replaceAll('`', ''),
        pedagogyLearningEffect: columns[5].replaceAll('`', ''),
        feedbackExplanationQuality: columns[6].replaceAll('`', ''),
        learnerLanguageNaturalness: columns[7].replaceAll('`', ''),
        contentRuntimeAlignment: columns[8].replaceAll('`', ''),
        crossWorldConsistencyFit: columns[9].replaceAll('`', ''),
        topOpenGaps: columns[10]
            .split(';')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList(),
        evidenceRefs: columns[11]
            .split(';')
            .map((part) => part.replaceAll('`', '').trim())
            .where((part) => part.isNotEmpty)
            .toList(),
        releaseGradeBlockerNote: columns[12],
      ),
    );
  }
  return rows;
}

List<String> parseProductSurfaceFamiliesV1(String content) {
  final families = <String>[];
  for (final rawLine in const LineSplitter().convert(content)) {
    final line = rawLine.trimRight();
    if (!line.startsWith('| `')) {
      continue;
    }
    final columns = line
        .split('|')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (columns.isEmpty || columns[0] == 'Surface family') {
      continue;
    }
    families.add(columns[0].replaceAll('`', ''));
  }
  return families;
}

List<CompletionGapEntryV1> _buildQueueGapEntriesV1({
  required List<Map<String, Object?>> queueEntries,
  required Map<String, Object> releaseReadinessSnapshot,
  required String topWavePacketPath,
  required String reviewPath,
  required String productSurfaceSourcePath,
  required List<String> productSurfaceFamilies,
  required Map<String, Object?> topWavePacket,
  required Map<String, Map<String, Object?>> clusterById,
}) {
  final gaps = <CompletionGapEntryV1>[];
  for (final entry in queueEntries) {
    final clusterId = entry['cluster_id'] as String? ?? 'unknown_cluster';
    final title = entry['title'] as String? ?? clusterId;
    final blockerLevel = entry['blocker_level'] as String? ?? 'unknown';
    final cluster = clusterById[clusterId] ?? const <String, Object?>{};
    final sourceTruthOwner = clusterId == 'visual_proof_truth'
        ? productSurfaceSourcePath
        : (topWavePacketPath.isNotEmpty ? topWavePacketPath : reviewPath);

    CompletionGapAdmissibilityV1 admissibility;
    final prerequisites = <String>[];
    var currentStatus = blockerLevel;
    final proofRequirements =
        (entry['proof_requirements'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    if (clusterId == 'ops_release_confidence' &&
        ((releaseReadinessSnapshot['goNoGoStateIsHold'] as bool? ?? false) ||
            (releaseReadinessSnapshot['humanReviewStatePending'] as bool? ??
                false) ||
            (releaseReadinessSnapshot['rollbackTruthSaysUnresolved'] as bool? ??
                false) ||
            (releaseReadinessSnapshot['operationalDashboardTruthSaysNoCanonicalDashboard']
                    as bool? ??
                false))) {
      admissibility = CompletionGapAdmissibilityV1.proofManualOnly;
      currentStatus = 'paused_on_manual_boundary';
      if (releaseReadinessSnapshot['goNoGoStateIsHold'] == true) {
        prerequisites.add('Current bounded go/no-go verdict is still HOLD.');
      }
      if (releaseReadinessSnapshot['humanReviewStatePending'] == true) {
        prerequisites.add('Human release review remains pending.');
      }
      if (releaseReadinessSnapshot['rollbackTruthSaysUnresolved'] == true) {
        prerequisites.add('Rollback truth remains unresolved.');
      }
      if (releaseReadinessSnapshot['operationalDashboardTruthSaysNoCanonicalDashboard'] ==
          true) {
        prerequisites.add(
          'Operational dashboard ownership still lacks a canonical governed owner.',
        );
      }
    } else if (clusterId == 'visual_proof_truth') {
      admissibility = CompletionGapAdmissibilityV1.external;
      prerequisites.add(
        'Current visual proof lane is only admissible when screenshot-backed evidence or shared/local family drift is actively red or yellow.',
      );
      if (productSurfaceFamilies.isNotEmpty) {
        prerequisites.add(
          'Surface families remain governed by $productSurfaceSourcePath.',
        );
      }
    } else if (proofRequirements.contains('human_review_required')) {
      admissibility = CompletionGapAdmissibilityV1.proofManualOnly;
      prerequisites.add('Current cluster still requires bounded human review.');
    } else if ((entry['rerun_commands'] as List<Object?>? ?? const [])
        .isNotEmpty) {
      admissibility = CompletionGapAdmissibilityV1.machineReducibleNow;
    } else {
      admissibility = CompletionGapAdmissibilityV1.external;
      prerequisites.add(
        'Current queue entry does not expose a bounded executable seam.',
      );
    }

    gaps.add(
      CompletionGapEntryV1(
        gapId: 'cluster_$clusterId',
        sourceTruthOwner: sourceTruthOwner,
        title: title,
        category: 'cluster',
        worldScope: (entry['affected_worlds'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList(),
        surfaceScope: (entry['affected_surfaces'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList(),
        readinessBlocks:
            (entry['readiness_blocks'] as List<Object?>? ?? const [])
                .whereType<String>()
                .toList(),
        epicMappings: (entry['epic_mappings'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList(),
        currentStatus: currentStatus,
        admissibility: admissibility,
        likelySeam: entry['likely_seam'] as String? ?? '',
        ownerFiles: (entry['owner_files'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList(),
        measurableProofPath:
            admissibility == CompletionGapAdmissibilityV1.machineReducibleNow
            ? (entry['rerun_commands'] as List<Object?>? ?? const [])
                  .whereType<String>()
                  .toList()
            : const <String>[],
        prerequisiteBlockers: prerequisites,
        evPriorityOrder: entry['rank'] as int? ?? 999,
        nextFrontierReason:
            entry['why_now'] as String? ??
            entry['reason'] as String? ??
            topWavePacket['summary'] as String? ??
            '',
      ),
    );
  }
  return gaps;
}

List<CompletionGapEntryV1> _normalizeCompletionGapRoutingV1(
  List<CompletionGapEntryV1> gaps,
) {
  final admissibleCandidates = gaps
      .where(
        (gap) =>
            gap.admissibility ==
                CompletionGapAdmissibilityV1.machineReducibleNow ||
            gap.admissibility == CompletionGapAdmissibilityV1.truthLayerFirst,
      )
      .toList(growable: false);

  return gaps
      .map((gap) {
        if (gap.admissibility !=
                CompletionGapAdmissibilityV1.machineReducibleNow &&
            gap.admissibility != CompletionGapAdmissibilityV1.truthLayerFirst) {
          return gap;
        }
        if (!_isLaterWorldCandidateV1(gap)) {
          return gap;
        }

        final blockingCandidates =
            admissibleCandidates
                .where((candidate) => candidate.gapId != gap.gapId)
                .where(
                  (candidate) => _blocksLaterWorldSelectionV1(candidate, gap),
                )
                .toList(growable: false)
              ..sort(_compareCompletionGapsV1);

        if (blockingCandidates.isNotEmpty) {
          final blockingSummary = blockingCandidates
              .take(4)
              .map(
                (candidate) =>
                    '${candidate.title} [${candidate.admissibility.wireValue}]',
              )
              .join(' | ');
          return gap.copyWith(
            admissibility: CompletionGapAdmissibilityV1.external,
            prerequisiteBlockers: <String>[
              ...gap.prerequisiteBlockers,
              'Routing normalization: later-world candidates stay under-normalized until reranking proves no admissible earlier-world bounded wave remains.',
              'Routing normalization: later-world candidates stay under-normalized until reranking proves no admissible higher-criticality or stronger product-cohesion bounded wave remains.',
              'Routing normalization blockers: $blockingSummary',
            ],
            nextFrontierReason:
                'Under-normalized later-world candidate; recompute routing truth after higher-priority admissible gaps are reranked or cleared.',
          );
        }

        return gap.copyWith(
          prerequisiteBlockers: <String>[
            ...gap.prerequisiteBlockers,
            'Routing normalization proof: no admissible earlier-world bounded wave remains ahead of this later-world candidate.',
            'Routing normalization proof: no admissible higher-criticality or stronger product-cohesion bounded wave remains ahead of this later-world candidate.',
            'Routing normalization proof: this later-world candidate remained the strongest bounded frontier after normalized reranking.',
          ],
          nextFrontierReason:
              '${gap.nextFrontierReason} Routing truth was normalized and no stronger earlier-world or higher-criticality admissible frontier remained.',
        );
      })
      .toList(growable: false);
}

List<CompletionGapEntryV1> _buildWorldGapEntriesV1({
  required List<Map<String, Object?>> worlds,
  required Map<String, WorldReadinessRegistryRowV1> worldRegistryById,
  required String worldRegistrySourcePath,
  required Map<String, String> blockTitles,
  required Map<String, Map<String, Object?>> unificationByWorldId,
  required Map<String, Map<String, Object?>> worldTruthSurfaceById,
  required Map<String, Map<String, Object?>> worldOwnershipInventoryById,
  required Map<String, Map<String, Object?>> worldVisualInstrumentationById,
  required Map<String, Map<String, Object?>> worldScreenshotEvidenceById,
}) {
  final gaps = <CompletionGapEntryV1>[];
  var priority = 100;
  for (final world in worlds) {
    final readinessStatus = world['readiness_status'] as String? ?? '';
    if (readinessStatus == 'done') {
      continue;
    }
    final worldId = world['world_id'] as String? ?? 'unknown_world';
    final registryRow = worldRegistryById[worldId];
    final unification = unificationByWorldId[worldId];
    final truthSurface = worldTruthSurfaceById[worldId];
    final ownershipInventory = worldOwnershipInventoryById[worldId];
    final visualInstrumentation = worldVisualInstrumentationById[worldId];
    final screenshotEvidence = worldScreenshotEvidenceById[worldId];
    final screenshotEvidenceCount =
        world['screenshot_evidence_count'] as int? ?? 0;
    final ownershipTruth = world['ownership_truth'] as String? ?? '';
    final visualHealth = world['visual_health'] as String? ?? '';
    final truthSurfaceStatus =
        truthSurface?['proof_surface_status'] as String? ?? '';
    final truthSurfaceSummary =
        truthSurface?['proof_surface_truth'] as String? ?? '';
    final truthSurfaceBlockingGaps =
        (truthSurface?['blocking_gaps'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    final truthSurfaceOwnerFiles =
        (truthSurface?['owner_files'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    final truthSurfaceCommands =
        (truthSurface?['measurable_proof_path'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    final ownershipInventoryStatus =
        ownershipInventory?['inventory_status'] as String? ?? '';
    final ownershipInventorySummary =
        ownershipInventory?['summary'] as String? ?? '';
    final ownershipInventoryBlockingGaps =
        (ownershipInventory?['blocking_gaps'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    final ownershipInventoryOwnerFiles =
        (ownershipInventory?['owner_files'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    final ownershipInventoryCommands =
        (ownershipInventory?['measurable_proof_path'] as List<Object?>? ??
                const [])
            .whereType<String>()
            .toList();
    final visualInstrumentationStatus =
        visualInstrumentation?['instrumentation_status'] as String? ?? '';
    final visualInstrumentationSummary =
        visualInstrumentation?['proof_surface_truth'] as String? ?? '';
    final visualInstrumentationBlockingGaps =
        (visualInstrumentation?['blocking_gaps'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    final visualInstrumentationOwnerFiles =
        (visualInstrumentation?['owner_files'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    final visualInstrumentationCommands =
        (visualInstrumentation?['measurable_proof_path'] as List<Object?>? ??
                const [])
            .whereType<String>()
            .toList();
    final screenshotEvidenceStatus =
        screenshotEvidence?['evidence_status'] as String? ?? '';
    final screenshotEvidenceSummary =
        screenshotEvidence?['proof_surface_truth'] as String? ?? '';
    final screenshotEvidenceBlockingGaps =
        (screenshotEvidence?['blocking_gaps'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    final screenshotEvidenceOwnerFiles =
        (screenshotEvidence?['owner_files'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    final screenshotEvidenceCommands =
        (screenshotEvidence?['measurable_proof_path'] as List<Object?>? ??
                const [])
            .whereType<String>()
            .toList();
    final topOpenGaps = (world['top_open_gaps'] as List<Object?>? ?? const [])
        .whereType<String>()
        .expand(
          (gap) => gap
              .split(';')
              .map((part) => part.trim())
              .where((part) => part.isNotEmpty),
        )
        .toList();
    CompletionGapAdmissibilityV1 admissibility;
    final prerequisites = <String>[];
    final remainingTruthBlockers = <String>[
      if (ownershipTruth.startsWith('No explicit') &&
          ownershipInventoryStatus != 'executable')
        'explicit shared/local ownership inventory',
      if (visualHealth == 'not_instrumented' &&
          visualInstrumentationStatus != 'executable')
        'visual instrumentation',
      if (screenshotEvidenceCount == 0 &&
          screenshotEvidenceStatus != 'executable')
        'screenshot-backed evidence',
    ];
    if (readinessStatus == 'human_proof_pending') {
      admissibility = CompletionGapAdmissibilityV1.proofManualOnly;
      prerequisites.add(
        '$worldId still requires release-grade human proof before stronger closure claims.',
      );
    } else if (readinessStatus == 'proof_pending' &&
        remainingTruthBlockers.isNotEmpty) {
      admissibility = CompletionGapAdmissibilityV1.truthLayerFirst;
      if (truthSurfaceStatus == 'executable') {
        prerequisites.add(truthSurfaceSummary);
        if (ownershipInventoryStatus == 'executable') {
          prerequisites.add(ownershipInventorySummary);
        } else if (ownershipInventoryBlockingGaps.isNotEmpty) {
          prerequisites.addAll(ownershipInventoryBlockingGaps);
        }
        if (visualInstrumentationStatus == 'executable') {
          prerequisites.add(visualInstrumentationSummary);
        } else if (visualInstrumentationBlockingGaps.isNotEmpty) {
          prerequisites.addAll(visualInstrumentationBlockingGaps);
        }
        if (screenshotEvidenceStatus == 'executable') {
          prerequisites.add(screenshotEvidenceSummary);
        } else if (screenshotEvidenceBlockingGaps.isNotEmpty) {
          prerequisites.addAll(screenshotEvidenceBlockingGaps);
        }
        if (remainingTruthBlockers.isNotEmpty) {
          prerequisites.add(
            '$worldId still needs ${remainingTruthBlockers.join(', ')} before a bounded reduction wave is honest.',
          );
        }
      } else {
        prerequisites.add(
          '$worldId lacks a strong enough executable proof surface for an honest bounded reduction wave.',
        );
        prerequisites.addAll(truthSurfaceBlockingGaps);
      }
    } else if (readinessStatus == 'proof_pending' &&
        truthSurfaceStatus == 'executable' &&
        ownershipInventoryStatus == 'executable' &&
        visualInstrumentationStatus == 'executable' &&
        screenshotEvidenceStatus == 'executable') {
      admissibility = CompletionGapAdmissibilityV1.machineReducibleNow;
    } else if (readinessStatus == 'proof_pending' ||
        readinessStatus == 'in_progress' ||
        readinessStatus == 'blocked') {
      admissibility = CompletionGapAdmissibilityV1.external;
      prerequisites.add(
        '$worldId remains open in the registry, but current hub truth does not expose a bounded machine-reducible seam yet.',
      );
    } else {
      admissibility = CompletionGapAdmissibilityV1.external;
    }

    final readinessBlocks =
        (world['primary_readiness_links'] as List<Object?>? ?? const [])
            .whereType<String>()
            .toList();
    final epicMappings = readinessBlocks
        .map((blockId) => '$blockId ${blockTitles[blockId] ?? ''}'.trim())
        .toList();
    final likelySeam =
        unification?['owner_seam_blocking_unification'] as String? ??
        _firstOrEmptyV1(registryRow?.topOpenGaps) ??
        _firstOrEmptyV1(topOpenGaps) ??
        '';
    final ownerFiles = <String>{
      ...?registryRow?.evidenceRefs,
      ...truthSurfaceOwnerFiles,
      ...ownershipInventoryOwnerFiles,
      ...visualInstrumentationOwnerFiles,
      ...screenshotEvidenceOwnerFiles,
      if (registryRow == null) worldRegistrySourcePath,
    }.toList(growable: false);
    final measurableProofPath = <String>[
      if (admissibility == CompletionGapAdmissibilityV1.machineReducibleNow)
        ...truthSurfaceCommands,
      if (admissibility == CompletionGapAdmissibilityV1.machineReducibleNow)
        ...ownershipInventoryCommands,
      if (admissibility == CompletionGapAdmissibilityV1.machineReducibleNow)
        ...visualInstrumentationCommands,
      if (admissibility == CompletionGapAdmissibilityV1.machineReducibleNow)
        ...screenshotEvidenceCommands,
      if (admissibility == CompletionGapAdmissibilityV1.machineReducibleNow)
        ...?registryRow?.evidenceRefs,
      if (admissibility == CompletionGapAdmissibilityV1.truthLayerFirst &&
          truthSurfaceStatus == 'executable')
        ...truthSurfaceCommands,
      if (admissibility == CompletionGapAdmissibilityV1.truthLayerFirst &&
          ownershipInventoryStatus == 'executable')
        ...ownershipInventoryCommands,
      if (admissibility == CompletionGapAdmissibilityV1.truthLayerFirst &&
          visualInstrumentationStatus == 'executable')
        ...visualInstrumentationCommands,
      if (admissibility == CompletionGapAdmissibilityV1.truthLayerFirst &&
          screenshotEvidenceStatus == 'executable')
        ...screenshotEvidenceCommands,
    ];
    gaps.add(
      CompletionGapEntryV1(
        gapId: 'world_gap_${worldId.toLowerCase()}',
        sourceTruthOwner: worldRegistrySourcePath,
        title: '$worldId ${world['title'] as String? ?? ''}'.trim(),
        category: 'world_quality',
        worldScope: <String>[worldId],
        surfaceScope: topOpenGaps,
        readinessBlocks: readinessBlocks,
        epicMappings: epicMappings,
        currentStatus: readinessStatus,
        admissibility: admissibility,
        likelySeam: likelySeam,
        ownerFiles: ownerFiles,
        measurableProofPath: measurableProofPath,
        prerequisiteBlockers: prerequisites,
        evPriorityOrder: priority++,
        nextFrontierReason:
            registryRow?.releaseGradeBlockerNote ??
            world['release_grade_blocker_note'] as String? ??
            '',
      ),
    );
  }
  return gaps;
}

int _compareCompletionGapsV1(
  CompletionGapEntryV1 left,
  CompletionGapEntryV1 right,
) {
  const rank = <CompletionGapAdmissibilityV1, int>{
    CompletionGapAdmissibilityV1.machineReducibleNow: 0,
    CompletionGapAdmissibilityV1.truthLayerFirst: 1,
    CompletionGapAdmissibilityV1.proofManualOnly: 2,
    CompletionGapAdmissibilityV1.external: 3,
  };
  final byAdmissibility = (rank[left.admissibility] ?? 99).compareTo(
    rank[right.admissibility] ?? 99,
  );
  if (byAdmissibility != 0) {
    return byAdmissibility;
  }
  final byCriticality = _routingCriticalityRankV1(
    left,
  ).compareTo(_routingCriticalityRankV1(right));
  if (byCriticality != 0) {
    return byCriticality;
  }
  final byCohesion = _routingCohesionRankV1(
    left,
  ).compareTo(_routingCohesionRankV1(right));
  if (byCohesion != 0) {
    return byCohesion;
  }
  final byLane = _worldLaneRankV1(left).compareTo(_worldLaneRankV1(right));
  if (byLane != 0) {
    return byLane;
  }
  final byWorld = _earliestWorldNumberV1(
    left,
  ).compareTo(_earliestWorldNumberV1(right));
  if (byWorld != 0) {
    return byWorld;
  }
  return left.evPriorityOrder.compareTo(right.evPriorityOrder);
}

bool _blocksLaterWorldSelectionV1(
  CompletionGapEntryV1 blocker,
  CompletionGapEntryV1 candidate,
) {
  if (blocker.admissibility == CompletionGapAdmissibilityV1.external ||
      blocker.admissibility == CompletionGapAdmissibilityV1.proofManualOnly) {
    return false;
  }
  if (_routingCriticalityRankV1(blocker) <
      _routingCriticalityRankV1(candidate)) {
    return true;
  }
  if (_routingCohesionRankV1(blocker) < _routingCohesionRankV1(candidate)) {
    return true;
  }

  final blockerLane = _worldLaneRankV1(blocker);
  final candidateLane = _worldLaneRankV1(candidate);
  if (blockerLane < candidateLane) {
    return true;
  }

  final blockerWorld = _earliestWorldNumberV1(blocker);
  final candidateWorld = _earliestWorldNumberV1(candidate);
  return blockerWorld < candidateWorld;
}

bool _isLaterWorldCandidateV1(CompletionGapEntryV1 gap) {
  return _worldLaneRankV1(gap) > 0 && _earliestWorldNumberV1(gap) < 99;
}

int _routingCriticalityRankV1(CompletionGapEntryV1 gap) {
  final text = _routingSearchTextV1(gap);
  final earliestWorld = _earliestWorldNumberV1(gap);
  final laneRank = _worldLaneRankV1(gap);

  if (_isCriticalProductCohesionGapV1(text)) {
    return 0;
  }
  if (_isEarlyPedagogyGapV1(gap, text)) {
    return 1;
  }
  if (earliestWorld <= 4) {
    return 2;
  }
  if (laneRank == 1) {
    return 3;
  }
  if (laneRank == 2) {
    return 4;
  }
  return 5;
}

int _routingCohesionRankV1(CompletionGapEntryV1 gap) {
  return _isCriticalProductCohesionGapV1(_routingSearchTextV1(gap)) ? 0 : 1;
}

bool _isCriticalProductCohesionGapV1(String text) {
  return text.contains('shared runner') ||
      text.contains('shared host') ||
      text.contains('shared surface') ||
      text.contains('shared/local') ||
      text.contains('shell') ||
      text.contains('route ownership') ||
      text.contains('continuity') ||
      text.contains('cohesion') ||
      text.contains('unification') ||
      text.contains('first-user');
}

bool _isEarlyPedagogyGapV1(CompletionGapEntryV1 gap, String text) {
  if (_earliestWorldNumberV1(gap) > 4) {
    return false;
  }
  return text.contains('pedagog') ||
      text.contains('progression') ||
      text.contains('onboarding') ||
      text.contains('feedback') ||
      text.contains('explanation') ||
      text.contains('framing');
}

int _worldLaneRankV1(CompletionGapEntryV1 gap) {
  final earliestWorld = _earliestWorldNumberV1(gap);
  if (earliestWorld <= 4) {
    return 0;
  }
  if (earliestWorld <= 8) {
    return 1;
  }
  if (earliestWorld <= 10) {
    return 2;
  }
  return 3;
}

int _earliestWorldNumberV1(CompletionGapEntryV1 gap) {
  final worldNumbers = gap.worldScope
      .map(_tryParseWorldNumberV1)
      .whereType<int>()
      .toList(growable: false);
  if (worldNumbers.isEmpty) {
    return 99;
  }
  worldNumbers.sort();
  return worldNumbers.first;
}

int? _tryParseWorldNumberV1(String worldId) {
  if (!worldId.startsWith('W')) {
    return null;
  }
  return int.tryParse(worldId.substring(1));
}

String _routingSearchTextV1(CompletionGapEntryV1 gap) {
  return <String>[
    gap.title,
    gap.category,
    gap.likelySeam,
    gap.nextFrontierReason,
    ...gap.surfaceScope,
    ...gap.epicMappings,
    ...gap.prerequisiteBlockers,
  ].join(' | ').toLowerCase();
}

String? _firstOrEmptyV1(List<String>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.first;
}

double _extractDoubleValue(
  String content,
  RegExp preferredPattern, {
  RegExp? fallbackPattern,
}) {
  final preferred = preferredPattern.firstMatch(content);
  if (preferred != null) {
    return double.parse(preferred.group(1)!);
  }
  if (fallbackPattern != null) {
    final fallback = fallbackPattern.firstMatch(content);
    if (fallback != null) {
      return double.parse(fallback.group(1)!);
    }
  }
  throw StateError('Unable to extract numeric value using $preferredPattern');
}

String _extractStringValue(String content, RegExp pattern) {
  final match = pattern.firstMatch(content);
  if (match == null) {
    throw StateError('Unable to extract string value using $pattern');
  }
  return match.group(1)!.trim();
}

List<String> _extractBulletSection(String content, String heading) {
  final headingIndex = content.indexOf(heading);
  if (headingIndex == -1) return const <String>[];
  final slice = content.substring(headingIndex + heading.length);
  final values = <String>[];
  for (final line in const LineSplitter().convert(slice)) {
    if (line.trim().isEmpty) {
      if (values.isNotEmpty) break;
      continue;
    }
    if (!line.trimLeft().startsWith('- ')) {
      if (values.isNotEmpty) break;
      continue;
    }
    values.add(line.trim().substring(2).replaceAll('`', ''));
  }
  return values;
}
