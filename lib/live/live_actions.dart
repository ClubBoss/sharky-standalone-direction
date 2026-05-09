import "dart:core" as core;
import 'dart:core';
// ASCII-only; pure Dart (no Flutter deps)

import 'live_mode.dart';
import 'live_ui_maps.dart';
import 'live_module_utils.dart';

/// Returns the primary action label for a module in given mode, or null.
/// ASCII-only; no i18n yet.
String? livePrimaryAction(String moduleId, TrainingMode mode) {
  late final bool isLiveModule = isLiveModuleId(moduleId);
  late final bool isPracticeModule = isPracticeModuleId(moduleId);
  if (isLiveModule) return kLivePrimaryAction;
  if (mode == TrainingMode.live && isPracticeModule) return kLivePrimaryAction;
  return null;
}
