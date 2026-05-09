import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';

String resolveWorld1CanonicalEntryPackIdV1({
  required Set<String> completedPackIds,
  required String fallbackPackId,
}) {
  for (final packId in kWorld1CanonicalModuleOrder) {
    if (!completedPackIds.contains(packId)) {
      return packId;
    }
  }
  return fallbackPackId.trim();
}
