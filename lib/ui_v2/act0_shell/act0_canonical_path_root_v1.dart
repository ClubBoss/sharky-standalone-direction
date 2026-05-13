import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

Widget buildCanonicalPathRootV1() {
  // Canonical root remains Act0 preview shell by product decision.
  // Keep this aligned with AGENTS.md Runtime Surface Canonical (Act0).
  return Act0ShellPreviewScreenV1(showPlacementOnStart: false);
}
