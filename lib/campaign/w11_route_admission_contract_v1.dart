import 'package:poker_analyzer/campaign/w11_campaign_fixture_projection_v1.dart';

/// Lossless, non-registering route-admission contract for W11 source reps.
///
/// This is deliberately separate from the legacy campaign-pack runtime shape.
/// It preserves the W11 source-owned fixture/projection fields so a future
/// route proof can choose a runner or adapter without inventing seat/action
/// semantics.
class W11RouteAdmissionBeatV1 {
  const W11RouteAdmissionBeatV1({
    required this.worldId,
    required this.sessionId,
    required this.repId,
    required this.sourceRef,
    required this.visibleState,
    required this.learnerPrompt,
    required this.legalChoices,
    required this.expectedAnswer,
    required this.targetSkillId,
    required this.errorType,
    required this.correctFeedback,
    required this.incorrectFeedback,
    required this.repairCue,
    required this.telemetryInputs,
  });

  final String worldId;
  final String sessionId;
  final String repId;
  final String sourceRef;
  final String visibleState;
  final String learnerPrompt;
  final List<String> legalChoices;
  final String expectedAnswer;
  final String targetSkillId;
  final String errorType;
  final String correctFeedback;
  final String incorrectFeedback;
  final String repairCue;
  final List<String> telemetryInputs;

  String get routeBeatId => '$worldId.$sessionId.$repId';

  factory W11RouteAdmissionBeatV1.fromProjection(
    W11CampaignFixtureProjectionV1 projection,
  ) {
    return W11RouteAdmissionBeatV1(
      worldId: projection.worldId,
      sessionId: projection.sessionId,
      repId: projection.repId,
      sourceRef: projection.sourceRef,
      visibleState: projection.visibleState,
      learnerPrompt: projection.learnerPrompt,
      legalChoices: projection.legalChoices,
      expectedAnswer: projection.expectedAnswer,
      targetSkillId: projection.targetSkillId,
      errorType: projection.errorType,
      correctFeedback: projection.correctFeedback,
      incorrectFeedback: projection.incorrectFeedback,
      repairCue: projection.repairCue,
      telemetryInputs: projection.telemetryInputs,
    );
  }
}

List<W11RouteAdmissionBeatV1> buildW11RouteAdmissionBeatsV1(
  Iterable<W11CampaignFixtureProjectionV1> projections,
) {
  return List<W11RouteAdmissionBeatV1>.unmodifiable(
    projections.map(W11RouteAdmissionBeatV1.fromProjection),
  );
}
