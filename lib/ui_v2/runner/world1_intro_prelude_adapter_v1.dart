import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';

@immutable
class World1IntroPreludeAdapterV1 {
  const World1IntroPreludeAdapterV1({required this.sections});

  final RunnerHostSectionResponsibilityV1 sections;

  bool shouldShowIntroSurface({
    required bool preludeVisible,
    required bool introVisible,
  }) {
    return sections.showIntro && (preludeVisible || introVisible);
  }
}

World1IntroPreludeAdapterV1 buildWorld1IntroPreludeAdapterV1() {
  return const World1IntroPreludeAdapterV1(
    sections: RunnerHostSectionResponsibilityV1(
      showIntro: true,
      showSourceMeta: false,
      showRecap: false,
      showCompletionInHeader: false,
      showEmbeddedFeedbackBelowTable: false,
    ),
  );
}
