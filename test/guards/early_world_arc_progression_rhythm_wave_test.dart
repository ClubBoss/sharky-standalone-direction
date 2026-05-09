import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';
import 'package:poker_analyzer/personalization/learning_continuation_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';

void main() {
  test(
    'early-world progression rhythm stays aligned across route, handoff, continuation, and runner chrome',
    () {
      final world2Story = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world2_spine_campaign_v1',
        reviewRequired: false,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: '',
      );
      final world2Handoff = buildProgressionHandoffContextForPackV1(
        'world2_spine_campaign_v1',
      );
      const recommendation = PersonalizedRecommendationV1(
        recommendedFocusId: 'showdown_truth',
        reasonCode: 'showdown_truth_bridge',
        shortHintText:
            'You are ready to carry the same simple table anchors into the first World 2 session route.',
        recommendedNextAction: PersonalizedNextActionV1.nextModule,
        recommendedNextSessionTarget: 'w2.s01',
      );
      final world2Continuation =
          LearningContinuationFactoryV1.fromPersonalizedRecommendation(
            recommendation: recommendation,
            resolveModuleTitle: recommendedModuleTitleForId,
          );
      final world2Chrome = resolveSessionDrillRunnerProgressionChromeContractV1(
        const SessionDrillRunnerProgressionChromeInputV1(
          sessionId: 'w2.s01',
          stepLabel: 'Showdown Truth',
          currentDrillIndex: 0,
          totalDrills: 1,
          drillId: 'showdown_truth_intro',
        ),
      );

      expect(world2Story.target.world, 2);
      expect(
        world2Story.reasonLine,
        'Why: World 1 gave you position, action order, and simple preflop discipline. World 2 now asks you to read visible table truth before you choose.',
      );
      expect(world2Handoff, isNotNull);
      expect(
        world2Handoff!.statusLine,
        'Stage shift · World 1 foundations -> World 2 table reads',
      );
      expect(
        world2Handoff.continuationHeadline,
        'What changes now: Read visible table truth',
      );
      expect(world2Continuation, isNotNull);
      expect(
        world2Continuation!.headline,
        'What changes now: Read visible table truth',
      );
      expect(
        world2Chrome.completionBodyText,
        startsWith('World 2 keeps the same table-reading arc in view.'),
      );
      expect(
        world2Chrome.completionBodyText,
        contains('Next lesson ready: World 2 · Session 2 of '),
      );

      final world3Story = resolveProgressionRouteStoryForPackV1(
        nextPackId: 'world3_spine_campaign_v1',
        reviewRequired: false,
        activePackId: '',
        nextHandIndex: 0,
        rhythmReason: '',
      );
      final world3Handoff = buildProgressionHandoffContextForPackV1(
        'world3_spine_campaign_v1',
      );
      final world3Chrome = resolveSessionDrillRunnerProgressionChromeContractV1(
        const SessionDrillRunnerProgressionChromeInputV1(
          sessionId: 'w3.s01',
          stepLabel: 'Hand Categories',
          currentDrillIndex: 0,
          totalDrills: 1,
          drillId: 'hand_category_intro',
        ),
      );

      expect(world3Story.target.world, 3);
      expect(
        world3Story.reasonLine,
        'Why: World 2 grounded visible table truth and pressure reads. World 3 now turns that clarity into the first simple open / call / fold framework.',
      );
      expect(world3Handoff, isNotNull);
      expect(
        world3Handoff!.statusLine,
        'Stage shift · World 2 table reads -> World 3 preflop framework',
      );
      expect(
        world3Handoff.continuationHeadline,
        'What changes now: Build the first preflop framework',
      );
      expect(
        world3Chrome.completionBodyText,
        startsWith('World 3 keeps the same first-action framework in view.'),
      );
      expect(
        world3Chrome.completionBodyText,
        contains('Next lesson ready: World 3 · Session 2 of '),
      );
    },
  );
}
