class RunnerRevealPayloadInputV1 {
  const RunnerRevealPayloadInputV1({
    required this.sourceId,
    required this.detailsPrompt,
  });

  final String sourceId;
  final String detailsPrompt;
}

class RunnerRevealPayloadResolvedV1 {
  const RunnerRevealPayloadResolvedV1({
    required this.sourceId,
    required this.revealedText,
    required this.canReveal,
  });

  final String sourceId;
  final String revealedText;
  final bool canReveal;

  bool get isAffordanceEnabled => canReveal;
}

RunnerRevealPayloadResolvedV1 resolveRunnerRevealPayloadV1(
  RunnerRevealPayloadInputV1 input,
) {
  final revealedText = input.detailsPrompt.trim();
  return RunnerRevealPayloadResolvedV1(
    sourceId: input.sourceId.trim(),
    revealedText: revealedText,
    canReveal: revealedText.isNotEmpty,
  );
}
