import 'emotion_fusion_preflight_consistency_v4.dart';
import 'emotion_fusion_preflight_v4.dart';

class EmotionFusionPreflightDeltaV4 {
  EmotionFusionPreflightDeltaV4({
    required EmotionFusionPreflightV4 preflight,
    required EmotionFusionPreflightConsistencyV4 consistency,
  }) : moodFusionDelta =
           preflight.hasMoodFusion != consistency.moodFusionConsistent,
       toneFusionDelta =
           preflight.hasToneFusion != consistency.toneFusionConsistent,
       arousalFusionDelta =
           preflight.hasArousalFusion != consistency.arousalFusionConsistent,
       valenceFusionDelta =
           preflight.hasValenceFusion != consistency.valenceFusionConsistent;

  final bool moodFusionDelta;
  final bool toneFusionDelta;
  final bool arousalFusionDelta;
  final bool valenceFusionDelta;

  Map<String, Object?> asReadOnlyMap() => {
    'moodFusionDelta': moodFusionDelta,
    'toneFusionDelta': toneFusionDelta,
    'arousalFusionDelta': arousalFusionDelta,
    'valenceFusionDelta': valenceFusionDelta,
  };
}
