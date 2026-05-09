import 'package:poker_analyzer/ui_v3/theme/adaptive_theme_bridge.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

import 'personalization_context.dart';
import 'persona_behavior_router.dart';

class PersonalizationHub {
  PersonalizationHub(this.ctx)
    : palette = VisualThemeV3.deriveFrom(ctx),
      adaptiveTheme = AdaptiveThemeBridge(ctx),
      behavior = PersonaBehaviorRouter(ctx);

  final PersonalizationContext ctx;
  final PersonalizationPalette palette;
  final AdaptiveThemeBridge adaptiveTheme;
  final PersonaBehaviorRouter behavior;

  PersonalizationPalette get themePalette => palette;
  PersonaBehaviorRouter get personaBehavior => behavior;
  AdaptiveThemeBridge get themeBridge => adaptiveTheme;

  // TODO(Φ-AI): integrate active adaptive logic here later.
}
