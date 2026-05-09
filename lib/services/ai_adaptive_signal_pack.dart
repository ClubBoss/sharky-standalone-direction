import 'personalization_context.dart';
import '../ui_v3/theme/visual_micro_modifiers.dart';
import '../ui_v3/theme/visual_theme_v3.dart';
import 'difficulty_assist_router.dart';
import 'persona_behavior_router.dart';

class AIAdaptiveSignalPack {
  AIAdaptiveSignalPack({
    required this.ctx,
    required this.palette,
    required this.modifiers,
    required this.persona,
    required this.difficulty,
  });

  final PersonalizationContext ctx;
  final PersonalizationPalette palette;
  final VisualMicroModifiers modifiers;
  final PersonaBehaviorRouter persona;
  final DifficultyAssistRouter difficulty;

  PersonalizationPalette get theme => palette;
  PersonaBehaviorRouter get personaBehavior => persona;
  DifficultyAssistRouter get difficultySignals => difficulty;

  // TODO(Φ-AI): integrate active AI fusion logic here later.
}
