import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_source_meta_contract_v1.dart';

@immutable
class World1DetailsSurfaceAdapterV1 {
  const World1DetailsSurfaceAdapterV1({
    required this.presentation,
    required this.sections,
    this.sourceMeta = const RunnerHostSourceMetaContractV1(),
  });

  final RunnerHostPromptRevealPresentationResolvedV1 presentation;
  final RunnerHostSectionResponsibilityV1 sections;
  final RunnerHostSourceMetaContractV1 sourceMeta;

  bool get canOpenDetailsSheet => presentation.canReveal;
}

World1DetailsSurfaceAdapterV1 buildWorld1DetailsSurfaceAdapterV1({
  required String sourceId,
  required String canonicalPrompt,
  String? shortPromptOverride,
  String? detailsPromptOverride,
}) {
  return World1DetailsSurfaceAdapterV1(
    presentation: resolveRunnerHostPromptRevealPresentationV1(
      RunnerHostPromptRevealPresentationInputV1(
        sourceId: sourceId,
        canonicalPrompt: canonicalPrompt,
        shortPromptOverride: shortPromptOverride,
        detailsPromptOverride: detailsPromptOverride,
      ),
    ),
    sections: const RunnerHostSectionResponsibilityV1(
      showIntro: false,
      showSourceMeta: false,
      showRecap: true,
      showCompletionInHeader: false,
      showEmbeddedFeedbackBelowTable: false,
    ),
    sourceMeta: const RunnerHostSourceMetaContractV1(),
  );
}
