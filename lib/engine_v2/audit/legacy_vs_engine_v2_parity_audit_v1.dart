import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart'
    as campaign_pack_registry;
import 'package:poker_analyzer/services/campaign_spine_runner_v1.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';

import '../engine_v2.dart';

class CampaignPointerV1 {
  const CampaignPointerV1({
    required this.packId,
    required this.worldId,
    required this.beatIndex,
  });

  final String packId;
  final int worldId;
  final int beatIndex;

  String get pointerId => 'w$worldId:$packId:$beatIndex';
}

enum ParityVerdictV1 { correct, incorrect }

enum ParityErrorBucketV1 { none, sizing, range, timing, logic }

class NormalizedOutcomeSignalV1 {
  const NormalizedOutcomeSignalV1({
    required this.verdict,
    required this.errorBucket,
    this.code,
  });

  final ParityVerdictV1 verdict;
  final ParityErrorBucketV1 errorBucket;
  final String? code;
}

class ParityMismatchDetailV1 {
  const ParityMismatchDetailV1({
    required this.pointerId,
    required this.legacy,
    required this.engineV2,
  });

  final String pointerId;
  final NormalizedOutcomeSignalV1 legacy;
  final NormalizedOutcomeSignalV1 engineV2;
}

class ParitySkipDetailV1 {
  const ParitySkipDetailV1({
    required this.pointerId,
    required this.reasonCode,
    required this.reason,
  });

  final String pointerId;
  final String reasonCode;
  final String reason;
}

class ParityAuditResultV1 {
  const ParityAuditResultV1({
    required this.total,
    required this.compared,
    required this.mismatches,
    required this.skipped,
    required this.mismatchDetails,
    required this.skipDetails,
  });

  final int total;
  final int compared;
  final int mismatches;
  final int skipped;
  final List<ParityMismatchDetailV1> mismatchDetails;
  final List<ParitySkipDetailV1> skipDetails;
}

ParityAuditResultV1 runParityAuditV1({
  required List<CampaignPointerV1> pointers,
}) {
  final sortedPointers = List<CampaignPointerV1>.from(pointers)
    ..sort((a, b) {
      final worldOrder = a.worldId.compareTo(b.worldId);
      if (worldOrder != 0) return worldOrder;
      final packOrder = a.packId.compareTo(b.packId);
      if (packOrder != 0) return packOrder;
      return a.beatIndex.compareTo(b.beatIndex);
    });

  final store = _CampaignRegistryStoreV1();
  final runner = CampaignSpineRunnerV1(store: store);
  final adapter = const ReplayerToEngineV2AdapterV1();
  final engine = const EngineV2();

  var compared = 0;
  var skipped = 0;
  final mismatchDetails = <ParityMismatchDetailV1>[];
  final skipDetails = <ParitySkipDetailV1>[];

  for (final pointer in sortedPointers) {
    final pointerId = pointer.pointerId;
    final handCount = store.handCountForPackId(pointer.packId);
    if (handCount <= 0) {
      skipped++;
      skipDetails.add(
        ParitySkipDetailV1(
          pointerId: pointerId,
          reasonCode: 'missing_pack',
          reason: 'Campaign pack missing or empty',
        ),
      );
      continue;
    }
    if (pointer.beatIndex < 0 || pointer.beatIndex >= handCount) {
      skipped++;
      skipDetails.add(
        ParitySkipDetailV1(
          pointerId: pointerId,
          reasonCode: 'invalid_beat_index',
          reason: 'Beat index out of range',
        ),
      );
      continue;
    }

    final beat = store.beatForPackIdAndIndex(pointer.packId, pointer.beatIndex);
    final runnerPointer = CampaignSpineBeatPointerV1(
      packId: pointer.packId,
      worldId: pointer.worldId,
      beatIndex: pointer.beatIndex,
      totalBeats: handCount,
      beat: beat,
    );

    final replayer = runner.scenarioForPointer(runnerPointer);
    final legacyPlan = CampaignSpineRunPlanV1(
      pointer: runnerPointer,
      scenario: replayer,
    );
    final legacyRun = runner.runScenario(plan: legacyPlan);
    final legacySummary = runner.buildOutcomeSummary(
      plan: legacyPlan,
      result: legacyRun,
    );
    final legacySignal = _normalizeLegacy(legacySummary);

    final interop = adapter.tryConvert(
      scenarioId: 'parity_$pointerId',
      replayer: replayer,
    );
    if (!interop.isSuccess || interop.scenario == null) {
      skipped++;
      final reasonCode = interop.violations.isEmpty
          ? 'interop_failed'
          : interop.violations.first.code;
      final reason = interop.violations.isEmpty
          ? 'Engine v2 interop conversion failed'
          : interop.violations.map((v) => '${v.code}:${v.message}').join(';');
      skipDetails.add(
        ParitySkipDetailV1(
          pointerId: pointerId,
          reasonCode: reasonCode,
          reason: reason,
        ),
      );
      continue;
    }

    final engineRun = engine.runScenarioWithEvaluation(interop.scenario!);
    final engineSignal = _normalizeEngineV2(engineRun.outcome);

    compared++;
    if (!_signalsMatch(legacySignal, engineSignal)) {
      mismatchDetails.add(
        ParityMismatchDetailV1(
          pointerId: pointerId,
          legacy: legacySignal,
          engineV2: engineSignal,
        ),
      );
    }
  }

  return ParityAuditResultV1(
    total: sortedPointers.length,
    compared: compared,
    mismatches: mismatchDetails.length,
    skipped: skipped,
    mismatchDetails: List<ParityMismatchDetailV1>.unmodifiable(mismatchDetails),
    skipDetails: List<ParitySkipDetailV1>.unmodifiable(skipDetails),
  );
}

NormalizedOutcomeSignalV1 _normalizeLegacy(OutcomeSummaryV1 summary) {
  final verdict = summary.outcomeKind == OutcomeKindV1.success
      ? ParityVerdictV1.correct
      : ParityVerdictV1.incorrect;
  return NormalizedOutcomeSignalV1(
    verdict: verdict,
    errorBucket: _bucketFromCode(summary.errorType),
    code: summary.errorType,
  );
}

NormalizedOutcomeSignalV1 _normalizeEngineV2(OutcomeV1 outcome) {
  final verdict = outcome.verdict == DecisionVerdictV1.correct
      ? ParityVerdictV1.correct
      : ParityVerdictV1.incorrect;
  final error = outcome.error;
  return NormalizedOutcomeSignalV1(
    verdict: verdict,
    errorBucket: _bucketFromCode(error?.type.name),
    code: error?.code,
  );
}

ParityErrorBucketV1 _bucketFromCode(String? code) {
  final normalized = (code ?? '').trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'none') {
    return ParityErrorBucketV1.none;
  }
  if (normalized.contains('sizing') ||
      normalized.contains('bet') ||
      normalized.contains('raise')) {
    return ParityErrorBucketV1.sizing;
  }
  if (normalized.contains('range')) {
    return ParityErrorBucketV1.range;
  }
  if (normalized.contains('timing') ||
      normalized.contains('check') ||
      normalized.contains('call')) {
    return ParityErrorBucketV1.timing;
  }
  return ParityErrorBucketV1.logic;
}

bool _signalsMatch(
  NormalizedOutcomeSignalV1 legacy,
  NormalizedOutcomeSignalV1 engineV2,
) {
  return legacy.verdict == engineV2.verdict &&
      legacy.errorBucket == engineV2.errorBucket;
}

class _CampaignRegistryStoreV1 implements CampaignSpineProgressStoreV1 {
  @override
  campaign_pack_registry.MicroTaskStep beatForPackIdAndIndex(
    String packId,
    int index,
  ) {
    final normalized = packId.trim().toLowerCase();
    final pack = campaign_pack_registry.kCampaignPacksV1[normalized];
    if (pack == null || pack.isEmpty) {
      throw StateError('Unknown campaign pack: $packId');
    }
    if (index < 0 || index >= pack.length) {
      throw RangeError.index(index, pack, 'index');
    }
    return pack[index];
  }

  @override
  Future<void> clearActivePackId() async {}

  @override
  Future<String?> getActivePackId() async => null;

  @override
  Future<int> getNextHandIndex() async => 0;

  @override
  Future<String> getNextPackToRun() async => 'world1_spine_campaign_v1';

  @override
  int handCountForPackId(String packId) {
    return campaign_pack_registry.campaignHandCountForPackIdV1(packId);
  }

  @override
  Future<bool> isPackCompleted(String packId) async => false;

  @override
  Future<void> markPackCompleted(String packId) async {}

  @override
  Future<void> setActivePackId(String packId) async {}

  @override
  Future<void> setNextHandIndex(int index) async {}

  @override
  int worldIndexForPackId(String packId) {
    final match = RegExp(r'^world(\d+)_').firstMatch(packId.trim());
    if (match == null) {
      throw StateError('Cannot parse world index from packId: $packId');
    }
    return int.parse(match.group(1)!);
  }
}
