import 'package:meta/meta.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/services/campaign_spine_runner_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';

const Map<int, String> _checkpointGlobalErrorClassByStepIndexV1 = <int, String>{
  0: 'range',
  1: 'timing',
  2: 'sizing',
  3: 'position',
  4: 'discipline',
  5: 'anchor',
};

@immutable
class CheckpointSeedV1 {
  const CheckpointSeedV1({required this.topErrorClasses});

  final List<String> topErrorClasses;
}

@immutable
class CheckpointSeededDrillV1 {
  const CheckpointSeededDrillV1({
    required this.drillId,
    required this.errorClass,
    required this.step,
  });

  final String drillId;
  final String errorClass;
  final MicroTaskStep step;
}

@visibleForTesting
List<CheckpointSeededDrillV1> buildCheckpointSeededDrillsV1({
  required List<MicroTaskStep> steps,
  required CheckpointSeedV1 seed,
  int targetCount = 6,
}) {
  if (steps.isEmpty || targetCount <= 0) {
    return const <CheckpointSeededDrillV1>[];
  }
  final normalizedSeed = <String>[];
  final seenSeed = <String>{};
  for (final raw in seed.topErrorClasses) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty || !seenSeed.add(normalized)) {
      continue;
    }
    normalizedSeed.add(normalized);
    if (normalizedSeed.length == 3) {
      break;
    }
  }
  final candidates = <CheckpointSeededDrillV1>[];
  for (var i = 0; i < steps.length; i++) {
    candidates.add(
      CheckpointSeededDrillV1(
        drillId: 'checkpoint_${(i + 1).toString().padLeft(2, '0')}',
        errorClass: _checkpointGlobalErrorClassByStepIndexV1[i] ?? 'checkpoint_misc',
        step: steps[i],
      ),
    );
  }
  final selected = <CheckpointSeededDrillV1>[];
  final selectedIds = <String>{};
  List<CheckpointSeededDrillV1> sortedForClass(String errorClass) {
    final filtered = candidates
        .where(
          (candidate) =>
              candidate.errorClass == errorClass &&
              !selectedIds.contains(candidate.drillId),
        )
        .toList(growable: false)
      ..sort((a, b) => a.drillId.compareTo(b.drillId));
    return filtered;
  }

  for (final errorClass in normalizedSeed) {
    final classItems = sortedForClass(errorClass);
    if (classItems.isEmpty) {
      continue;
    }
    final first = classItems.first;
    selected.add(first);
    selectedIds.add(first.drillId);
  }

  for (final errorClass in normalizedSeed) {
    final classItems = sortedForClass(errorClass);
    for (final item in classItems) {
      selected.add(item);
      selectedIds.add(item.drillId);
    }
  }

  final fallback = candidates
      .where((candidate) => !selectedIds.contains(candidate.drillId))
      .toList(growable: false)
    ..sort((a, b) => a.drillId.compareTo(b.drillId));
  for (final item in fallback) {
    selected.add(item);
  }
  final effectiveCount = targetCount < candidates.length
      ? targetCount
      : candidates.length;
  return List<CheckpointSeededDrillV1>.unmodifiable(
    selected.take(effectiveCount),
  );
}

class World1CanonicalCheckpointBootstrapResultV1 {
  const World1CanonicalCheckpointBootstrapResultV1({
    required this.steps,
    required this.stepIndex,
    required this.topErrorClasses,
    required this.stepErrorClasses,
  });

  final List<MicroTaskStep> steps;
  final int stepIndex;
  final List<String> topErrorClasses;
  final List<String> stepErrorClasses;
}

class World1CanonicalReviewQueueBootstrapResultV1 {
  const World1CanonicalReviewQueueBootstrapResultV1({
    required this.shouldPop,
    required this.queuedStepIndices,
    required this.feedback,
  });

  final bool shouldPop;
  final List<int> queuedStepIndices;
  final String feedback;
}

class World1CanonicalCampaignBootstrapResultV1 {
  const World1CanonicalCampaignBootstrapResultV1({
    required this.stepIndex,
    required this.bankroll,
    required this.rank,
    required this.calibrationCompleted,
    required this.calibrationBand,
  });

  final int stepIndex;
  final int bankroll;
  final int rank;
  final bool calibrationCompleted;
  final int calibrationBand;
}

Future<World1CanonicalCheckpointBootstrapResultV1?>
bootstrapWorld1CheckpointSeedV1({
  required List<MicroTaskStep> steps,
  required int stepIndex,
  required String checkpointPackId,
  required MicroTaskStep Function(MicroTaskStep step) checkpointCueMapper,
  Future<List<String>> Function(String packId)? loadSeedClasses,
}) async {
  final seedClasses =
      await (loadSeedClasses ?? ProgressService.getCheckpointSeedForPackV1)(
        checkpointPackId,
      );
  final seeded = buildCheckpointSeededDrillsV1(
    steps: steps,
    seed: CheckpointSeedV1(topErrorClasses: seedClasses),
    targetCount: 6,
  );
  if (seeded.isEmpty) {
    return null;
  }
  final seededSteps = seeded
      .map((entry) => checkpointCueMapper(entry.step))
      .toList(growable: false);
  return World1CanonicalCheckpointBootstrapResultV1(
    steps: seededSteps,
    stepIndex: stepIndex.clamp(0, seededSteps.length - 1),
    topErrorClasses: List<String>.from(seedClasses),
    stepErrorClasses: seeded
        .map((entry) => entry.errorClass)
        .toList(growable: false),
  );
}

Future<World1CanonicalReviewQueueBootstrapResultV1>
bootstrapWorld1ReviewQueueSessionV1({
  required String packId,
  required int stepCount,
  Future<List<ReviewRefV1>> Function(String packId)? loadReviewQueue,
}) async {
  final normalizedPackId = packId.trim().toLowerCase();
  if (normalizedPackId.isEmpty) {
    return const World1CanonicalReviewQueueBootstrapResultV1(
      shouldPop: false,
      queuedStepIndices: <int>[],
      feedback: 'Review queued spots.',
    );
  }
  try {
    final refs =
        await (loadReviewQueue ?? ProgressService.getReviewQueueForPackV1)(
          normalizedPackId,
        );
    final queued = refs
        .map((ref) => ref.stepIndex)
        .where((index) => index >= 0 && index < stepCount)
        .toList(growable: false)
      ..sort();
    if (queued.isEmpty) {
      return const World1CanonicalReviewQueueBootstrapResultV1(
        shouldPop: true,
        queuedStepIndices: <int>[],
        feedback: 'Review queued spots.',
      );
    }
    return World1CanonicalReviewQueueBootstrapResultV1(
      shouldPop: false,
      queuedStepIndices: queued,
      feedback: 'Review queued spots.',
    );
  } catch (_) {
    return const World1CanonicalReviewQueueBootstrapResultV1(
      shouldPop: true,
      queuedStepIndices: <int>[],
      feedback: 'Review queued spots.',
    );
  }
}

Future<World1CanonicalCampaignBootstrapResultV1>
bootstrapWorld1CampaignStateV1({
  required String moduleId,
  required int stepIndex,
  required int stepCount,
  required bool shouldBootstrapCampaignProgress,
  required Future<CampaignSpineRunPlanV1> Function() startRun,
  Future<int> Function()? getBankrollBalance,
  Future<int> Function()? getRank,
  Future<bool> Function()? isCalibrationCompleted,
  Future<int?> Function()? getCalibrationBand,
  Future<void> Function(String packId)? setActivePackId,
  Future<void> Function(int index)? setNextHandIndex,
}) async {
  CampaignSpineRunPlanV1? runPlan;
  if (shouldBootstrapCampaignProgress) {
    try {
      runPlan = await startRun();
    } catch (_) {
      runPlan = null;
    }
  }
  var resolvedStepIndex = stepIndex;
  if (runPlan != null &&
      runPlan.pointer.packId == moduleId &&
      runPlan.pointer.beatIndex != resolvedStepIndex &&
      runPlan.pointer.beatIndex >= 0 &&
      runPlan.pointer.beatIndex < stepCount) {
    resolvedStepIndex = runPlan.pointer.beatIndex;
  }
  final bankroll =
      await (getBankrollBalance ?? ProgressService.getSpineBankrollBalance)();
  final rank = await (getRank ?? ProgressService.getSpineRankV1)();
  final calibrationCompleted =
      await (isCalibrationCompleted ??
          ProgressService.isSpineCalibrationCompletedV1)();
  final calibrationBand =
      await (getCalibrationBand ?? ProgressService.getSpineCalibrationBandV1)();
  if (shouldBootstrapCampaignProgress && runPlan == null) {
    await (setActivePackId ?? ProgressService.setSpineActivePackIdV1)(moduleId);
    await (setNextHandIndex ?? ProgressService.setSpineNextHandIndexV1)(
      resolvedStepIndex,
    );
  }
  return World1CanonicalCampaignBootstrapResultV1(
    stepIndex: resolvedStepIndex,
    bankroll: bankroll,
    rank: rank,
    calibrationCompleted: calibrationCompleted,
    calibrationBand:
        calibrationBand ?? ProgressService.spineCalibrationBandIntermediate,
  );
}
