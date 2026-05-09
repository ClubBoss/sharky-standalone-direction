import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

enum CanonicalTrainingSessionLaunchFamilyV1 {
  canonicalWorld1Runner,
  theoryPreview,
  sessionDrill,
  legacyTrainingSession,
}

class CanonicalTrainingSessionLaunchPlanV1 {
  const CanonicalTrainingSessionLaunchPlanV1._({
    required this.family,
    required this.templateId,
    this.world1ModuleTitleV1,
    this.world1ModeV1,
  });

  const CanonicalTrainingSessionLaunchPlanV1.canonicalWorld1Runner({
    required String templateId,
    required String world1ModuleTitleV1,
    required String world1ModeV1,
  }) : this._(
         family: CanonicalTrainingSessionLaunchFamilyV1.canonicalWorld1Runner,
         templateId: templateId,
         world1ModuleTitleV1: world1ModuleTitleV1,
         world1ModeV1: world1ModeV1,
       );

  const CanonicalTrainingSessionLaunchPlanV1.theoryPreview({
    required String templateId,
  }) : this._(
         family: CanonicalTrainingSessionLaunchFamilyV1.theoryPreview,
         templateId: templateId,
       );

  const CanonicalTrainingSessionLaunchPlanV1.sessionDrill({
    required String templateId,
  }) : this._(
         family: CanonicalTrainingSessionLaunchFamilyV1.sessionDrill,
         templateId: templateId,
       );

  const CanonicalTrainingSessionLaunchPlanV1.legacyTrainingSession({
    required String templateId,
  }) : this._(
         family: CanonicalTrainingSessionLaunchFamilyV1.legacyTrainingSession,
         templateId: templateId,
       );

  final CanonicalTrainingSessionLaunchFamilyV1 family;
  final String templateId;
  final String? world1ModuleTitleV1;
  final String? world1ModeV1;

  bool get launchesCanonicalWorld1Runner =>
      family == CanonicalTrainingSessionLaunchFamilyV1.canonicalWorld1Runner;

  bool get launchesTheoryPreview =>
      family == CanonicalTrainingSessionLaunchFamilyV1.theoryPreview;

  bool get launchesSessionDrill =>
      family == CanonicalTrainingSessionLaunchFamilyV1.sessionDrill;

  bool get launchesLegacyTrainingSession =>
      family == CanonicalTrainingSessionLaunchFamilyV1.legacyTrainingSession;
}

Future<CanonicalTrainingSessionLaunchPlanV1>
resolveCanonicalTrainingSessionLaunchPlanV1(
  TrainingPackTemplateV2 template, {
  String? source,
  Future<bool> Function(String templateId)? hasSessionDrillsOverrideV1,
}) async {
  if (hasWorld1MicroTaskPack(template.id)) {
    return CanonicalTrainingSessionLaunchPlanV1.canonicalWorld1Runner(
      templateId: template.id,
      world1ModuleTitleV1: recommendedModuleTitleForId(template.id),
      world1ModeV1: source != null && source.startsWith('review_')
          ? kWorld1RunnerModeReviewQueue
          : kWorld1RunnerModeCampaignSpine,
    );
  }

  if (template.spots.every((spot) => spot.type == 'theory')) {
    return CanonicalTrainingSessionLaunchPlanV1.theoryPreview(
      templateId: template.id,
    );
  }

  final hasSessionDrills =
      hasSessionDrillsOverrideV1 ??
      const DrillRuntimeAdapterV1().hasSessionDrills;
  if (await hasSessionDrills(template.id)) {
    return CanonicalTrainingSessionLaunchPlanV1.sessionDrill(
      templateId: template.id,
    );
  }

  return CanonicalTrainingSessionLaunchPlanV1.legacyTrainingSession(
    templateId: template.id,
  );
}
