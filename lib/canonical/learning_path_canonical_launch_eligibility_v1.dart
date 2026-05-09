import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';

/// Explicit one-to-one mappings for learning-path practice ids that should
/// launch via the canonical World 1 runner once they are proven equivalent.
///
/// Keep this map intentionally small and append-only. Do not add entries unless
/// the learning-path practice id and canonical module id are known to be a
/// zero-ambiguity match.
const Map<String, String>
kLearningPathPracticeCanonicalRunnerModuleIdByPackIdV1 = <String, String>{
  'open_fold_early_mtt': 'world1_spine_campaign_v1',
};

/// Returns a canonical World 1 module id for a learning-path practice pack id
/// only when the match is exact or explicitly registered above.
String? canonicalRunnerModuleIdForLearningPathPracticePackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  if (kWorld1CanonicalModuleOrder.contains(normalized)) {
    return normalized;
  }
  return kLearningPathPracticeCanonicalRunnerModuleIdByPackIdV1[normalized];
}

String? canonicalModuleIdForLearningPathPracticePackIdV1(String packId) =>
    canonicalRunnerModuleIdForLearningPathPracticePackIdV1(packId);
