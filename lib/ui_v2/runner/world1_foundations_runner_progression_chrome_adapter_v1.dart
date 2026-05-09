import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/canonical/learner_journey_finish_framing_v1.dart';
import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1.dart';

@immutable
class World1FoundationsEarlyEntryPayoffV1 {
  const World1FoundationsEarlyEntryPayoffV1({
    required this.completionBodyText,
    required this.nextSessionProgressLabel,
    required this.nextUpHeadlineText,
  });

  final String completionBodyText;
  final String nextSessionProgressLabel;
  final String nextUpHeadlineText;
}

World1FoundationsEarlyEntryPayoffV1? resolveWorld1FoundationsEarlyEntryPayoffV1(
  String moduleId,
) {
  final normalized = moduleId.trim().toLowerCase();
  return switch (normalized) {
    'world1_act0_table_literacy' => const World1FoundationsEarlyEntryPayoffV1(
      completionBodyText:
          'You can now find Button, small blind, and big blind without guessing.',
      nextSessionProgressLabel: 'World 1 · Pack 2 of 7 · First action choices',
      nextUpHeadlineText: 'First action choices',
    ),
    'world1_act0_action_literacy' => const World1FoundationsEarlyEntryPayoffV1(
      completionBodyText:
          'You can now choose fold, call, and raise from the right seat without action order feeling random.',
      nextSessionProgressLabel: 'World 1 · Pack 3 of 7 · Street flow reads',
      nextUpHeadlineText: 'Street flow reads',
    ),
    'world1_act0_street_flow' => const World1FoundationsEarlyEntryPayoffV1(
      completionBodyText:
          'You can now keep the action-order anchor while reading flop, turn, and river changes.',
      nextSessionProgressLabel: 'World 1 · Pack 4 of 7 · Campaign spine',
      nextUpHeadlineText: 'Campaign spine',
    ),
    _ => null,
  };
}

String? resolveWorld1FoundationsEarlyEntryAuthorityLabelV1(String moduleId) {
  final normalized = moduleId.trim().toLowerCase();
  return switch (normalized) {
    'world1_act0_table_literacy' => 'Table map',
    'world1_act0_action_literacy' => 'First action choices',
    'world1_act0_street_flow' => 'Street flow reads',
    _ => null,
  };
}

SessionDrillRunnerProgressionChromeContractV1?
resolveWorld1FoundationsRunnerProgressionChromeContractV1({
  required String moduleId,
  required int currentStepIndex,
  required int totalSteps,
}) {
  final normalized = moduleId.trim().toLowerCase();
  final node = canonicalTruthNodeByPackIdV1()[normalized];
  if (node == null) {
    return null;
  }

  final world = node.world;
  final order = canonicalTruthCampaignPackOrderForWorldV1(world);
  if (order.isEmpty) {
    return null;
  }
  final currentPackIndex = order.indexOf(normalized);
  if (currentPackIndex < 0) {
    return null;
  }

  final nextPackIndex = currentPackIndex + 1;
  final hasNextPack = nextPackIndex < order.length;
  final earlyEntryPayoff = hasNextPack
      ? resolveWorld1FoundationsEarlyEntryPayoffV1(normalized)
      : null;
  final authorityLabel = resolveWorld1FoundationsEarlyEntryAuthorityLabelV1(
    normalized,
  );
  final totalStepCount = totalSteps <= 0 ? 1 : totalSteps;
  final stepNumber = currentStepIndex + 1;
  final modeLabel =
      authorityLabel ??
      switch (node.modeFamily) {
        CanonicalTruthModeFamilyV1.seatQuiz => 'Foundations',
        CanonicalTruthModeFamilyV1.campaignSpine => 'Campaign Spine',
        _ => 'Campaign Pack',
      };
  final titleText = 'World $world';
  final packProgressLabel = 'Pack ${currentPackIndex + 1} of ${order.length}';
  return SessionDrillRunnerProgressionChromeContractV1(
    titleText: titleText,
    statusText:
        '$modeLabel · $packProgressLabel · Step $stepNumber of $totalStepCount',
    completionBodyText:
        earlyEntryPayoff?.completionBodyText ??
        (hasNextPack
            ? learnerJourneyNextLessonReadyTextV1(
                'World $world · Pack ${nextPackIndex + 1} of ${order.length}',
              )
            : learnerJourneyBackToMapForNextLessonTextV1()),
    nextSessionId: hasNextPack ? order[nextPackIndex] : null,
    nextSessionProgressLabel:
        earlyEntryPayoff?.nextSessionProgressLabel ??
        (hasNextPack
            ? 'World $world · Pack ${nextPackIndex + 1} of ${order.length}'
            : null),
  );
}
