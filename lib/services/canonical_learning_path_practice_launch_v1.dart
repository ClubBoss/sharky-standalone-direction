import 'package:poker_analyzer/canonical/learning_path_canonical_launch_eligibility_v1.dart';
import 'package:poker_analyzer/models/learning_path_stage_model.dart';
import 'package:poker_analyzer/models/stage_type.dart';

enum CanonicalLearningPathPracticeLaunchFamilyV1 {
  canonicalWorld1Runner,
  legacyTrainingPack,
}

class CanonicalLearningPathPracticeLaunchPlanV1 {
  const CanonicalLearningPathPracticeLaunchPlanV1._({
    required this.family,
    required this.packId,
    this.canonicalModuleId,
  });

  const CanonicalLearningPathPracticeLaunchPlanV1.canonicalWorld1Runner({
    required String packId,
    required String canonicalModuleId,
  }) : this._(
         family:
             CanonicalLearningPathPracticeLaunchFamilyV1.canonicalWorld1Runner,
         packId: packId,
         canonicalModuleId: canonicalModuleId,
       );

  const CanonicalLearningPathPracticeLaunchPlanV1.legacyTrainingPack({
    required String packId,
  }) : this._(
         family: CanonicalLearningPathPracticeLaunchFamilyV1.legacyTrainingPack,
         packId: packId,
       );

  final CanonicalLearningPathPracticeLaunchFamilyV1 family;
  final String packId;
  final String? canonicalModuleId;

  bool get launchesCanonicalWorld1Runner =>
      family ==
      CanonicalLearningPathPracticeLaunchFamilyV1.canonicalWorld1Runner;
}

CanonicalLearningPathPracticeLaunchPlanV1
resolveCanonicalLearningPathPracticeLaunchPlanV1(LearningPathStageModel stage) {
  if (stage.type == StageType.practice) {
    final resolved = canonicalRunnerModuleIdForLearningPathPracticePackIdV1(
      stage.packId,
    );
    if (resolved != null) {
      final declared = stage.canonicalModuleId;
      if (declared == null || declared == resolved) {
        return CanonicalLearningPathPracticeLaunchPlanV1.canonicalWorld1Runner(
          packId: stage.packId,
          canonicalModuleId: resolved,
        );
      }
    }
  }

  return CanonicalLearningPathPracticeLaunchPlanV1.legacyTrainingPack(
    packId: stage.packId,
  );
}

bool shouldLaunchCanonicalWorld1RunnerForLearningPathStageV1(
  LearningPathStageModel stage,
) {
  return resolveCanonicalLearningPathPracticeLaunchPlanV1(
    stage,
  ).launchesCanonicalWorld1Runner;
}

String? canonicalWorld1ModuleIdForLearningPathStageV1(
  LearningPathStageModel stage,
) {
  return resolveCanonicalLearningPathPracticeLaunchPlanV1(
    stage,
  ).canonicalModuleId;
}
