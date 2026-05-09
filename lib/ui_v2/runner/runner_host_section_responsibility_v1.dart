import 'package:flutter/foundation.dart';

@immutable
class RunnerHostSectionResponsibilityV1 {
  const RunnerHostSectionResponsibilityV1({
    this.showIntro = false,
    this.showSourceMeta = false,
    this.showRecap = false,
    this.showCompletionInHeader = true,
    this.showEmbeddedFeedbackBelowTable = true,
  });

  final bool showIntro;
  final bool showSourceMeta;
  final bool showRecap;
  final bool showCompletionInHeader;
  final bool showEmbeddedFeedbackBelowTable;
}
