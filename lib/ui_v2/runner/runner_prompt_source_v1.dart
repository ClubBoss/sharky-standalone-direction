class RunnerPromptSourceInputV1 {
  const RunnerPromptSourceInputV1({
    required this.canonicalPrompt,
    this.shortPromptOverride,
    this.detailsPromptOverride,
  });

  final String canonicalPrompt;
  final String? shortPromptOverride;
  final String? detailsPromptOverride;
}

class RunnerPromptSourceResolvedV1 {
  const RunnerPromptSourceResolvedV1({
    required this.shortPrompt,
    required this.detailsPrompt,
  });

  final String shortPrompt;
  final String detailsPrompt;
}

RunnerPromptSourceResolvedV1 resolveRunnerPromptSourceV1(
  RunnerPromptSourceInputV1 input,
) {
  final shortPrompt = _firstNonEmptyV1(
    input.shortPromptOverride,
    input.canonicalPrompt,
  );
  final detailsPrompt = _firstNonEmptyV1(
    input.detailsPromptOverride,
    shortPrompt,
  );
  return RunnerPromptSourceResolvedV1(
    shortPrompt: shortPrompt,
    detailsPrompt: detailsPrompt,
  );
}

String _firstNonEmptyV1(String? preferred, String fallback) {
  final preferredTrimmed = preferred?.trim();
  if (preferredTrimmed != null && preferredTrimmed.isNotEmpty) {
    return preferredTrimmed;
  }
  return fallback.trim();
}
