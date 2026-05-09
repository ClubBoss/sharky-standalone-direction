import 'sharky_persona_state.dart';

class SharkyPersonaRules {
  static SharkyPersonaState defaultForMode(SharkyPersonaMode mode) {
    switch (mode) {
      case SharkyPersonaMode.neutral:
        return const SharkyPersonaState(
          mode: SharkyPersonaMode.neutral,
          reaction: SharkyReaction.idle,
          message: 'Ready.',
        );
      case SharkyPersonaMode.engaged:
        return const SharkyPersonaState(
          mode: SharkyPersonaMode.engaged,
          reaction: SharkyReaction.think,
          message: 'Thinking...',
        );
      case SharkyPersonaMode.warning:
        return const SharkyPersonaState(
          mode: SharkyPersonaMode.warning,
          reaction: SharkyReaction.hint,
          message: 'Careful.',
        );
      case SharkyPersonaMode.reward:
        return const SharkyPersonaState(
          mode: SharkyPersonaMode.reward,
          reaction: SharkyReaction.celebrate,
          message: 'Nice!',
        );
    }
  }
}
