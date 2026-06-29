import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/canonical/learner_journey_finish_framing_v1.dart';
import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';

@immutable
class SessionDrillRunnerProgressionChromeInputV1 {
  const SessionDrillRunnerProgressionChromeInputV1({
    required this.sessionId,
    required this.stepLabel,
    required this.currentDrillIndex,
    required this.totalDrills,
    required this.drillId,
    this.currentChainStepIndex = 0,
    this.totalChainSteps = 0,
    this.isWorld2SurfacedScenarioSession = false,
  });

  final String sessionId;
  final String stepLabel;
  final int currentDrillIndex;
  final int totalDrills;
  final String drillId;
  final int currentChainStepIndex;
  final int totalChainSteps;
  final bool isWorld2SurfacedScenarioSession;
}

@immutable
class SessionDrillRunnerProgressionChromeContractV1 {
  const SessionDrillRunnerProgressionChromeContractV1({
    required this.titleText,
    required this.statusText,
    required this.completionBodyText,
    this.nextSessionId,
    this.nextSessionProgressLabel,
  });

  final String titleText;
  final String statusText;
  final String completionBodyText;
  final String? nextSessionId;
  final String? nextSessionProgressLabel;

  bool get hasNextSession => nextSessionId != null;
}

SessionDrillRunnerProgressionChromeContractV1
resolveSessionDrillRunnerProgressionChromeContractV1(
  SessionDrillRunnerProgressionChromeInputV1 input,
) {
  final progression = _resolveCanonicalSessionProgressionV1(input.sessionId);
  if (progression != null) {
    final sessionWorld = resolveSessionWorldForSessionIdV1(input.sessionId);
    final nextBody = progression.nextSessionProgressLabel == null
        ? sessionWorld != null
              ? progressionRouteTerminalBodyTextForSessionWorldV1(
                  world: sessionWorld,
                )
              : learnerJourneyBackToMapForNextLessonTextV1()
        : sessionWorld != null
        ? progressionRouteCompletionBodyTextForSessionWorldV1(
            world: sessionWorld,
            nextSessionProgressLabel: progression.nextSessionProgressLabel!,
          )
        : learnerJourneyNextLessonReadyTextV1(
            progression.nextSessionProgressLabel!,
          );
    return SessionDrillRunnerProgressionChromeContractV1(
      titleText: progression.headerLabel,
      statusText:
          '${progression.headerLabel} \u00B7 ${progression.sessionProgressLabel} \u00B7 ${input.stepLabel}',
      completionBodyText: nextBody,
      nextSessionId: progression.nextSessionId,
      nextSessionProgressLabel: progression.nextSessionProgressLabel,
    );
  }

  if (!input.isWorld2SurfacedScenarioSession) {
    final chainText = input.totalChainSteps > 0
        ? ' step ${input.currentChainStepIndex + 1}/${input.totalChainSteps}'
        : '';
    final kindDetails = chainText.isEmpty ? '' : ',$chainText';
    return SessionDrillRunnerProgressionChromeContractV1(
      titleText: 'Drill Player ${input.sessionId}',
      statusText:
          'Drill ${input.currentDrillIndex + 1}/${input.totalDrills}: ${input.drillId}$kindDetails',
      completionBodyText: learnerJourneyBackToMapForNextLessonTextV1(),
    );
  }

  final totalSteps = input.totalChainSteps > 0
      ? input.totalChainSteps
      : input.totalDrills;
  final stepNumber = input.totalChainSteps > 0
      ? input.currentChainStepIndex + 1
      : input.currentDrillIndex + 1;
  final upperSessionId = input.sessionId.trim().toUpperCase();
  return SessionDrillRunnerProgressionChromeContractV1(
    titleText: 'World 2 Session',
    statusText:
        'Session $upperSessionId \u00B7 ${input.stepLabel} \u00B7 Step $stepNumber of $totalSteps',
    completionBodyText: learnerJourneyBackToMapForNextLessonTextV1(),
  );
}

@immutable
class _CanonicalSessionProgressionFrameV1 {
  const _CanonicalSessionProgressionFrameV1({
    required this.headerLabel,
    required this.sessionProgressLabel,
    this.nextSessionId,
    this.nextSessionProgressLabel,
  });

  final String headerLabel;
  final String sessionProgressLabel;
  final String? nextSessionId;
  final String? nextSessionProgressLabel;
}

_CanonicalSessionProgressionFrameV1? _resolveCanonicalSessionProgressionV1(
  String sessionId,
) {
  final normalized = sessionId.trim().toLowerCase();
  final trackKind = canonicalTruthWorld10TrackKindForSessionIdV1(normalized);
  if (trackKind != null) {
    final sequence = canonicalTruthPlayableTrackSessionEntriesForWorld10V1(
      trackKind,
    );
    return _buildSequenceFrameV1(
      sequence: sequence
          .map((entry) => entry.sessionId)
          .toList(growable: false),
      currentSessionId: normalized,
      headerLabel: 'World 10 ${_trackLabelV1(trackKind)} Track',
    );
  }

  final worldMatch = RegExp(r'^w(\d+)\.s(\d{2})$').firstMatch(normalized);
  if (worldMatch == null) {
    return null;
  }
  final world = int.tryParse(worldMatch.group(1) ?? '');
  if (world == null || world < 2) {
    return null;
  }
  final sequence = canonicalTruthPlayableSessionEntriesForWorldV1(
    world,
  ).map((entry) => entry.sessionId).toList(growable: false);
  return _buildSequenceFrameV1(
    sequence: sequence,
    currentSessionId: normalized,
    headerLabel: 'World $world',
  );
}

_CanonicalSessionProgressionFrameV1? _buildSequenceFrameV1({
  required List<String> sequence,
  required String currentSessionId,
  required String headerLabel,
}) {
  if (sequence.isEmpty) {
    return null;
  }
  final normalizedSequence = sequence
      .map((item) => item.trim().toLowerCase())
      .toList(growable: false);
  final currentIndex = normalizedSequence.indexOf(currentSessionId);
  if (currentIndex < 0) {
    return null;
  }
  final nextIndex = currentIndex + 1;
  final hasNext = nextIndex < normalizedSequence.length;
  return _CanonicalSessionProgressionFrameV1(
    headerLabel: headerLabel,
    sessionProgressLabel:
        'Session ${currentIndex + 1} of ${normalizedSequence.length}',
    nextSessionId: hasNext ? normalizedSequence[nextIndex] : null,
    nextSessionProgressLabel: hasNext
        ? '$headerLabel \u00B7 Session ${nextIndex + 1} of ${normalizedSequence.length}'
        : null,
  );
}

String _trackLabelV1(String trackKind) {
  return switch (trackKind.trim().toLowerCase()) {
    'cash' => 'Cash',
    'tournament' => 'Tournament',
    'mixed' => 'Mixed',
    _ => trackKind.trim().toUpperCase(),
  };
}
