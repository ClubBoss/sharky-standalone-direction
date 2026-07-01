import 'package:poker_analyzer/canonical/learner_journey_finish_framing_v1.dart';

enum ProgressionRouteFamilyV1 { campaignPack, sessionWorld, trackSession }

class ProgressionRouteTargetV1 {
  const ProgressionRouteTargetV1({
    required this.family,
    this.world,
    this.trackKind,
  });

  final ProgressionRouteFamilyV1 family;
  final int? world;
  final String? trackKind;

  bool get isCrossFamilyRoute =>
      family == ProgressionRouteFamilyV1.sessionWorld ||
      family == ProgressionRouteFamilyV1.trackSession;

  String get routeLabel {
    switch (family) {
      case ProgressionRouteFamilyV1.campaignPack:
        return 'Campaign spine';
      case ProgressionRouteFamilyV1.sessionWorld:
        return 'World $world sessions';
      case ProgressionRouteFamilyV1.trackSession:
        return '${_displayTrackKindV1(trackKind)} track';
    }
  }
}

class ProgressionRouteStoryV1 {
  const ProgressionRouteStoryV1({
    required this.target,
    required this.ctaLabel,
    required this.semanticsLabel,
    required this.reasonLine,
  });

  final ProgressionRouteTargetV1 target;
  final String ctaLabel;
  final String semanticsLabel;
  final String reasonLine;
}

String progressionRouteReasonValueTextV1(String reasonLine) {
  final trimmed = reasonLine.trim();
  if (trimmed.isEmpty) return '';
  final whyPrefix = RegExp(r'^why:\s*', caseSensitive: false);
  return trimmed.replaceFirst(whyPrefix, '');
}

int? resolveSessionWorldForSessionIdV1(String sessionId) {
  final match = RegExp(
    r'^w(\d+)\.s\d+$',
  ).firstMatch(sessionId.trim().toLowerCase());
  return int.tryParse(match?.group(1) ?? '');
}

String progressionRouteHeadlineForTargetV1(ProgressionRouteTargetV1 target) {
  return 'Next up: ${target.routeLabel}';
}

bool isEarlyArcSessionWorldV1(int? world) =>
    world != null && world >= 2 && world <= 3;

bool _hasSpecificRouteHandoffCopyV1(int? world) =>
    world != null && world >= 2 && world <= 6;

bool _hasSpecificCompletionPayoffCopyV1(int? world) =>
    world != null && world >= 2 && world <= 6;

String? progressionRouteStageShiftValueForTargetV1(
  ProgressionRouteTargetV1 target,
) {
  if (target.family != ProgressionRouteFamilyV1.sessionWorld ||
      !_hasSpecificRouteHandoffCopyV1(target.world)) {
    return null;
  }
  return switch (target.world) {
    2 =>
      'Build Hand Discipline from position, price, and approved pressure cues',
    3 =>
      'Build Position Thinking from seat, hand bucket, and action-frame cues',
    5 => 'Build Board Awareness from texture, board shifts, and action context',
    6 =>
      'Build Range Thinking from board-aware pressure and likely hand groups',
    _ => null,
  };
}

String? progressionRouteStageShiftHeadlineForTargetV1(
  ProgressionRouteTargetV1 target,
) {
  final value = progressionRouteStageShiftValueForTargetV1(target);
  if (value == null || value.isEmpty) return null;
  return 'What changes now: $value';
}

String progressionRouteStatusLineForTargetV1(ProgressionRouteTargetV1 target) {
  if (target.family == ProgressionRouteFamilyV1.sessionWorld &&
      _hasSpecificRouteHandoffCopyV1(target.world)) {
    return switch (target.world) {
      2 => 'Stage shift - World 1 foundations -> World 2 Hand Discipline',
      3 => 'Stage shift - World 2 table reads -> World 3 Position Thinking',
      5 =>
        'Stage shift - World 4 Bet Purpose / Price -> World 5 Board Awareness',
      6 => 'Stage shift - World 5 Board Awareness -> World 6 Range Thinking',
      _ => 'Campaign route -> ${target.routeLabel}',
    };
  }
  return switch (target.family) {
    ProgressionRouteFamilyV1.trackSession =>
      'World 10 core -> ${target.routeLabel}',
    _ => 'Campaign route -> ${target.routeLabel}',
  };
}

String progressionRouteReasonLineForTargetV1(ProgressionRouteTargetV1 target) {
  switch (target.family) {
    case ProgressionRouteFamilyV1.campaignPack:
      return 'Why: Continue your next campaign route.';
    case ProgressionRouteFamilyV1.sessionWorld:
      if (_hasSpecificRouteHandoffCopyV1(target.world)) {
        return switch (target.world) {
          2 =>
            'Why: World 1 gave you position, action order, and simple preflop discipline. World 2 now trains when to fold, call, or raise from position, price, and approved pressure cues.',
          3 =>
            'Why: World 2 grounded visible table truth and pressure reads. World 3 now trains Position Thinking through position-first choices plus hand-bucket action frames before open, call, or fold.',
          5 =>
            'Why: World 4 trained Bet Purpose / Price by connecting intent, price, and action before the click. World 5 now trains Board Awareness through dry, wet, paired, and connected board reads before action.',
          6 =>
            'Why: World 5 trained Board Awareness before action. World 6 now introduces Range Thinking by connecting board-aware pressure to likely hand groups.',
          _ => 'Why: Your next learning route is ${target.routeLabel}.',
        };
      }
      return 'Why: Your next learning route is ${target.routeLabel}.';
    case ProgressionRouteFamilyV1.trackSession:
      final trackKind = _displayTrackKindV1(target.trackKind);
      return 'Why: Your next learning route is the $trackKind track.';
  }
}

String progressionRouteCompletionBodyTextForSessionWorldV1({
  required int world,
  required String nextSessionProgressLabel,
}) {
  if (_hasSpecificCompletionPayoffCopyV1(world)) {
    final lead = switch (world) {
      2 =>
        'World 2 trained fold, call, and raise discipline from position, price, and approved pressure cues.',
      3 =>
        'World 3 trained Position Thinking through position-first choices and hand-bucket action frames.',
      4 =>
        'World 4 trained Bet Purpose / Price by connecting why a bet is made, price, and action before the click.',
      5 =>
        'World 5 trained Board Awareness by reading dry, wet, paired, connected, and shifting boards before action.',
      6 =>
        'World 6 trained Range Thinking by reading broad range buckets and range width before action.',
      _ => 'Next lesson ready:',
    };
    return '$lead ${learnerJourneyNextLessonReadyTextV1(nextSessionProgressLabel)}';
  }
  return learnerJourneyNextLessonReadyTextV1(nextSessionProgressLabel);
}

String progressionRouteTerminalBodyTextForSessionWorldV1({required int world}) {
  return switch (world) {
    6 =>
      'World 6 completed Range Thinking: keep reading buckets and width before action. Visible Cards Change Ranges is ready next.',
    _ => learnerJourneyBackToMapForNextLessonTextV1(),
  };
}

String? progressionReviewCadenceValueForTargetV1({
  required ProgressionRouteTargetV1 target,
  required bool reviewRequired,
  required String rhythmReason,
}) {
  if (target.family != ProgressionRouteFamilyV1.sessionWorld ||
      !isEarlyArcSessionWorldV1(target.world)) {
    return null;
  }
  final normalizedReason = rhythmReason.trim().toLowerCase();
  final isCheckpointBeat =
      reviewRequired && normalizedReason == 'review required';
  return switch (target.world) {
    2 =>
      isCheckpointBeat
          ? 'Checkpoint review: lock the World 1 foundations before the next World 2 session.'
          : 'Quick review: refresh the World 1 foundations before the next World 2 session.',
    3 =>
      isCheckpointBeat
          ? 'Checkpoint review: lock the World 2 table-reading bridge before the next World 3 Position Thinking session.'
          : 'Quick review: refresh the World 2 table-reading bridge before the next World 3 Position Thinking session.',
    _ => null,
  };
}

ProgressionRouteTargetV1 resolveProgressionRouteTargetForPackIdV1(
  String packId,
) {
  final normalized = packId.trim().toLowerCase();
  final world = _worldForPackIdV1(normalized);
  final trackKind = _world10TrackKindForPackIdV1(normalized);
  if (trackKind != null) {
    return ProgressionRouteTargetV1(
      family: ProgressionRouteFamilyV1.trackSession,
      world: 10,
      trackKind: trackKind,
    );
  }
  if (world != null && world >= 2 && world <= 9) {
    return ProgressionRouteTargetV1(
      family: ProgressionRouteFamilyV1.sessionWorld,
      world: world,
    );
  }
  return ProgressionRouteTargetV1(
    family: ProgressionRouteFamilyV1.campaignPack,
    world: world,
  );
}

ProgressionRouteStoryV1 resolveProgressionRouteStoryForPackV1({
  required String nextPackId,
  required bool reviewRequired,
  required String activePackId,
  required int nextHandIndex,
  required String rhythmReason,
}) {
  final normalizedNextPackId = nextPackId.trim().toLowerCase();
  final normalizedActivePackId = activePackId.trim().toLowerCase();
  final target = resolveProgressionRouteTargetForPackIdV1(normalizedNextPackId);
  if (reviewRequired) {
    final reason = rhythmReason.trim();
    final cadenceValue = progressionReviewCadenceValueForTargetV1(
      target: target,
      reviewRequired: reviewRequired,
      rhythmReason: reason,
    );
    return ProgressionRouteStoryV1(
      target: target,
      ctaLabel: 'REVIEW MISSED',
      semanticsLabel: 'Open review queue session',
      reasonLine: cadenceValue != null
          ? 'Why: $cadenceValue'
          : reason.isEmpty
          ? 'Why: Review is due.'
          : 'Why: $reason.',
    );
  }
  if (normalizedNextPackId.isEmpty) {
    return ProgressionRouteStoryV1(
      target: target,
      ctaLabel: 'START NOW',
      semanticsLabel: 'Open next learning step',
      reasonLine: 'Why: No next progression step is available yet.',
    );
  }
  switch (target.family) {
    case ProgressionRouteFamilyV1.campaignPack:
      final isResumingActivePack =
          normalizedActivePackId == normalizedNextPackId && nextHandIndex > 0;
      return ProgressionRouteStoryV1(
        target: target,
        ctaLabel: isResumingActivePack ? 'CONTINUE CAMPAIGN' : 'START CAMPAIGN',
        semanticsLabel: isResumingActivePack
            ? 'Continue current campaign route'
            : 'Open next campaign route',
        reasonLine: _campaignReasonLineV1(normalizedNextPackId),
      );
    case ProgressionRouteFamilyV1.sessionWorld:
      final world = target.world ?? 0;
      return ProgressionRouteStoryV1(
        target: target,
        ctaLabel: 'OPEN WORLD $world',
        semanticsLabel: 'Open World $world session route',
        reasonLine: progressionRouteReasonLineForTargetV1(target),
      );
    case ProgressionRouteFamilyV1.trackSession:
      final trackKind = _displayTrackKindV1(target.trackKind);
      return ProgressionRouteStoryV1(
        target: target,
        ctaLabel: 'OPEN ${trackKind.toUpperCase()} TRACK',
        semanticsLabel: 'Open the $trackKind track route',
        reasonLine: progressionRouteReasonLineForTargetV1(target),
      );
  }
}

String _campaignReasonLineV1(String normalizedNextPackId) {
  if (normalizedNextPackId.endsWith('_spine_followup_v1_b0')) {
    return 'Why: To-call accuracy needs reinforcement.';
  }
  if (normalizedNextPackId.endsWith('_spine_followup_v1_b2')) {
    return 'Why: Expected-action accuracy needs reinforcement.';
  }
  return 'Why: Continue your next campaign route.';
}

int? _worldForPackIdV1(String normalizedPackId) {
  final match = RegExp(r'^world(\d+)_').firstMatch(normalizedPackId);
  return int.tryParse(match?.group(1) ?? '');
}

String? _world10TrackKindForPackIdV1(String normalizedPackId) {
  switch (normalizedPackId) {
    case 'world10_spine_followup_v1_b0':
      return 'cash';
    case 'world10_spine_followup_v1_b1':
      return 'tournament';
    case 'world10_spine_followup_v1_b2':
      return 'mixed';
  }
  return null;
}

String _displayTrackKindV1(String? trackKind) {
  switch ((trackKind ?? '').trim().toLowerCase()) {
    case 'cash':
      return 'Cash';
    case 'tournament':
      return 'Tournament';
    case 'mixed':
      return 'Mixed';
  }
  return 'Applied';
}
