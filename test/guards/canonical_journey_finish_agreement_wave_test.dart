import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/canonical/learner_journey_finish_framing_v1.dart';
import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart';

void main() {
  test(
    'canonical learner journey completion framing agrees on next-lesson readiness',
    () {
      expect(
        learnerJourneyNextLessonReadyTextV1('World 1 · Pack 5 of 7'),
        'Next lesson ready: World 1 · Pack 5 of 7.',
      );
      expect(
        learnerJourneyBackToMapForNextLessonTextV1(),
        'Back to the map when you are ready for the next lesson.',
      );

      expect(
        progressionRouteCompletionBodyTextForSessionWorldV1(
          world: 2,
          nextSessionProgressLabel: 'World 2 · Session 2 of 10',
        ),
        contains('Next lesson ready: World 2 · Session 2 of 10.'),
      );

      final world1Contract =
          resolveWorld1FoundationsRunnerProgressionChromeContractV1(
            moduleId: 'world1_spine_campaign_v1',
            currentStepIndex: 0,
            totalSteps: 10,
          );
      expect(
        world1Contract!.completionBodyText,
        'Next lesson ready: World 1 · Pack 5 of 7.',
      );
    },
  );
}
