import 'package:poker_analyzer/campaign/w12_campaign_fixture_projection_v1.dart';

/// Lossless, non-registering route-admission contract for W12 source reps.
///
/// This preserves source-owned fixture/projection fields so a future route
/// decision can choose an active runner without inventing runtime semantics.
class W12RouteAdmissionBeatV1 {
  const W12RouteAdmissionBeatV1({
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

  factory W12RouteAdmissionBeatV1.fromProjection(
    W12CampaignFixtureProjectionV1 projection,
  ) {
    return W12RouteAdmissionBeatV1(
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

List<W12RouteAdmissionBeatV1> buildW12RouteAdmissionBeatsV1(
  Iterable<W12CampaignFixtureProjectionV1> projections,
) {
  return List<W12RouteAdmissionBeatV1>.unmodifiable(
    projections.map(W12RouteAdmissionBeatV1.fromProjection),
  );
}
