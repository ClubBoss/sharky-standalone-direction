import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart';
import 'package:poker_analyzer/services/canonical_training_session_launch_plan_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  TrainingPackTemplateV2 buildTemplate(
    String id, {
    List<TrainingPackSpot>? spots,
  }) {
    return TrainingPackTemplateV2(
      id: id,
      name: id,
      trainingType: TrainingType.pushFold,
      spots: spots ?? <TrainingPackSpot>[TrainingPackSpot(id: 'spot_1')],
    );
  }

  test('world1 packs resolve to the canonical world1 runner family', () async {
    final plan = await resolveCanonicalTrainingSessionLaunchPlanV1(
      buildTemplate('world1_spine_campaign_v1'),
    );

    expect(
      plan.family,
      CanonicalTrainingSessionLaunchFamilyV1.canonicalWorld1Runner,
    );
    expect(plan.templateId, 'world1_spine_campaign_v1');
    expect(plan.world1ModeV1, kWorld1RunnerModeCampaignSpine);
    expect(plan.world1ModuleTitleV1, isNotEmpty);
  });

  test(
    'review sources keep canonical world1 launches on review mode',
    () async {
      final plan = await resolveCanonicalTrainingSessionLaunchPlanV1(
        buildTemplate('world1_spine_campaign_v1'),
        source: 'review_single:world1_spine_campaign_v1',
      );

      expect(
        plan.family,
        CanonicalTrainingSessionLaunchFamilyV1.canonicalWorld1Runner,
      );
      expect(plan.world1ModeV1, kWorld1RunnerModeReviewQueue);
    },
  );

  test(
    'theory-only packs resolve to the shared theory preview family',
    () async {
      final plan = await resolveCanonicalTrainingSessionLaunchPlanV1(
        buildTemplate(
          'theory_pack_v1',
          spots: <TrainingPackSpot>[
            TrainingPackSpot(id: 'theory_1', type: 'theory'),
            TrainingPackSpot(id: 'theory_2', type: 'theory'),
          ],
        ),
      );

      expect(plan.family, CanonicalTrainingSessionLaunchFamilyV1.theoryPreview);
    },
  );

  test(
    'session-drill packs resolve through the surfaced session family',
    () async {
      final plan = await resolveCanonicalTrainingSessionLaunchPlanV1(
        buildTemplate('starter_pushfold_10bb'),
        hasSessionDrillsOverrideV1: (_) async => true,
      );

      expect(plan.family, CanonicalTrainingSessionLaunchFamilyV1.sessionDrill);
    },
  );

  test('remaining packs stay on the legacy training-session family', () async {
    final plan = await resolveCanonicalTrainingSessionLaunchPlanV1(
      buildTemplate('starter_pushfold_10bb'),
      hasSessionDrillsOverrideV1: (_) async => false,
    );

    expect(
      plan.family,
      CanonicalTrainingSessionLaunchFamilyV1.legacyTrainingSession,
    );
  });
}
