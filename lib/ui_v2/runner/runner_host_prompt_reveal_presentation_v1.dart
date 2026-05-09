import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_prompt_source_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_reveal_payload_v1.dart';

@immutable
class RunnerHostPromptRevealPresentationInputV1 {
  const RunnerHostPromptRevealPresentationInputV1({
    required this.sourceId,
    required this.canonicalPrompt,
    this.shortPromptOverride,
    this.detailsPromptOverride,
  });

  final String sourceId;
  final String canonicalPrompt;
  final String? shortPromptOverride;
  final String? detailsPromptOverride;
}

@immutable
class RunnerHostPromptRevealPresentationResolvedV1 {
  const RunnerHostPromptRevealPresentationResolvedV1({
    required this.prompt,
    required this.reveal,
  });

  final RunnerPromptSourceResolvedV1 prompt;
  final RunnerRevealPayloadResolvedV1 reveal;

  String get shortPrompt => prompt.shortPrompt;
  String get detailsPrompt => prompt.detailsPrompt;
  bool get canReveal => reveal.canReveal;
}

RunnerHostPromptRevealPresentationResolvedV1
resolveRunnerHostPromptRevealPresentationV1(
  RunnerHostPromptRevealPresentationInputV1 input,
) {
  final prompt = resolveRunnerPromptSourceV1(
    RunnerPromptSourceInputV1(
      canonicalPrompt: input.canonicalPrompt,
      shortPromptOverride: input.shortPromptOverride,
      detailsPromptOverride: input.detailsPromptOverride,
    ),
  );
  final reveal = resolveRunnerRevealPayloadV1(
    RunnerRevealPayloadInputV1(
      sourceId: input.sourceId,
      detailsPrompt: prompt.detailsPrompt,
    ),
  );
  return RunnerHostPromptRevealPresentationResolvedV1(
    prompt: prompt,
    reveal: reveal,
  );
}
