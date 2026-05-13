import '../profile/persona_profile_model_v1.dart';
import '../profile/persona_profile_overlay_v1.dart';

class PersonaProfileBundleV1 {
  const PersonaProfileBundleV1({required this.model, required this.overlay});

  final PersonaProfileModelV1 model;
  final PersonaProfileOverlayV1 overlay;
}
