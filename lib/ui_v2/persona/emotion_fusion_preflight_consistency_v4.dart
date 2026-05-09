import 'emotion_fusion_preflight_v4.dart';
import 'emotion_fusion_synthesis_v4.dart';

class EmotionFusionPreflightConsistencyV4 {
  EmotionFusionPreflightConsistencyV4({
    required EmotionFusionPreflightV4 preflight,
    required EmotionFusionSynthesisV4 synthesis,
  }) : moodFusionConsistent =
           preflight.hasMoodFusion == (synthesis.fusion['moodFusion'] != null),
       toneFusionConsistent =
           preflight.hasToneFusion == (synthesis.fusion['toneFusion'] != null),
       arousalFusionConsistent =
           preflight.hasArousalFusion ==
           (synthesis.fusion['arousalFusion'] != null),
       valenceFusionConsistent =
           preflight.hasValenceFusion ==
           (synthesis.fusion['valenceFusion'] != null);

  final bool moodFusionConsistent;
  final bool toneFusionConsistent;
  final bool arousalFusionConsistent;
  final bool valenceFusionConsistent;

  Map<String, Object?> asReadOnlyMap() => {
    'moodFusionConsistent': moodFusionConsistent,
    'toneFusionConsistent': toneFusionConsistent,
    'arousalFusionConsistent': arousalFusionConsistent,
    'valenceFusionConsistent': valenceFusionConsistent,
  };
}
