import '../../services/personalization_context.dart';
import 'visual_theme_v3.dart';

class AdaptiveThemeBridge {
  AdaptiveThemeBridge(this.ctx) : palette = VisualThemeV3.deriveFrom(ctx);

  final PersonalizationContext ctx;
  final PersonalizationPalette palette;

  bool get isActive => false;
}
