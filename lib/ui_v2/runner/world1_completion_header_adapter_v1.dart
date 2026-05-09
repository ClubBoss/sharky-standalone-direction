import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';

@immutable
class World1CompletionHeaderAdapterV1 {
  const World1CompletionHeaderAdapterV1({required this.sections});

  final RunnerHostSectionResponsibilityV1 sections;

  bool shouldShowOutcomeStatus({required bool outcomeVisible}) {
    return sections.showCompletionInHeader && outcomeVisible;
  }
}

World1CompletionHeaderAdapterV1 buildWorld1CompletionHeaderAdapterV1() {
  return const World1CompletionHeaderAdapterV1(
    sections: RunnerHostSectionResponsibilityV1(
      showIntro: false,
      showSourceMeta: false,
      showRecap: false,
      showCompletionInHeader: true,
      showEmbeddedFeedbackBelowTable: false,
    ),
  );
}
