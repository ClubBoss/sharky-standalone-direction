import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

Widget buildCanonicalPathRootV1({
  MapDebugAutoOpenSurfaceV1? debugAutoOpenSurfaceV1,
}) {
  // Canonical root remains Act0 preview shell by product decision.
  // Keep this aligned with AGENTS.md Runtime Surface Canonical (Act0).
  return Act0ShellPreviewScreenV1(showPlacementOnStart: false);
}
