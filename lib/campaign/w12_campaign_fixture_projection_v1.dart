/// Pure, non-registering projection of the W12 source-owned fixture.
///
/// This preserves the authored pattern-replay rep contract without creating a
/// route, campaign registry entry, progress mutation, or runtime admission.
class W12CampaignFixtureProjectionV1 {
  const W12CampaignFixtureProjectionV1({
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

  factory W12CampaignFixtureProjectionV1.fromFixture(
    Map<String, Object?> fixtureRep,
  ) {
    return W12CampaignFixtureProjectionV1(
      worldId: _requiredString(fixtureRep, 'world_id'),
      sessionId: _requiredString(fixtureRep, 'session_id'),
      repId: _requiredString(fixtureRep, 'rep_id'),
      sourceRef: _requiredString(fixtureRep, 'source_ref'),
      visibleState: _requiredString(fixtureRep, 'visible_state'),
      learnerPrompt: _requiredString(fixtureRep, 'learner_prompt'),
      legalChoices: _requiredStringList(fixtureRep, 'legal_choices'),
      expectedAnswer: _requiredString(fixtureRep, 'expected_answer'),
      targetSkillId: _requiredString(fixtureRep, 'target_skill_id'),
      errorType: _requiredString(fixtureRep, 'error_type'),
      correctFeedback: _requiredString(fixtureRep, 'correct_feedback'),
      incorrectFeedback: _requiredString(fixtureRep, 'incorrect_feedback'),
      repairCue: _requiredString(fixtureRep, 'repair_cue'),
      telemetryInputs: _requiredStringList(fixtureRep, 'telemetry_inputs'),
    );
  }
}

List<W12CampaignFixtureProjectionV1> projectW12CampaignFixtureV1(
  Map<String, Object?> fixture,
) {
  if (_requiredString(fixture, 'world_id') != 'world12' ||
      _requiredString(fixture, 'session_id') != 'w12.s01') {
    throw ArgumentError.value(
      fixture,
      'fixture',
      'Expected the W12.S01 source-owned fixture.',
    );
  }
  final rawReps = fixture['reps'];
  if (rawReps is! List) {
    throw ArgumentError.value(rawReps, 'reps', 'Expected a rep list.');
  }
  return List<W12CampaignFixtureProjectionV1>.unmodifiable(
    rawReps.map((rawRep) {
      if (rawRep is! Map) {
        throw ArgumentError.value(rawRep, 'rep', 'Expected a rep object.');
      }
      return W12CampaignFixtureProjectionV1.fromFixture(
        Map<String, Object?>.from(rawRep),
      );
    }),
  );
}

String _requiredString(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! String || value.trim().isEmpty) {
    throw ArgumentError.value(value, key, 'Expected a non-empty string.');
  }
  return value;
}

List<String> _requiredStringList(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! List || value.any((item) => item is! String || item.isEmpty)) {
    throw ArgumentError.value(value, key, 'Expected a non-empty string list.');
  }
  return List<String>.unmodifiable(value.cast<String>());
}
