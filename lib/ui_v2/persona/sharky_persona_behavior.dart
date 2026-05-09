import 'sharky_persona_events.dart';
import 'sharky_persona_router.dart';

class SharkyPersonaBehavior {
  static void applyThinkPulse(SharkyPersonaRouter router) {
    router.setState(SharkyPersonaEvents.onXpGain());
  }

  static void applyCelebrate(SharkyPersonaRouter router) {
    router.setState(SharkyPersonaEvents.onStreak());
  }

  static void applyWarning(SharkyPersonaRouter router) {
    router.setState(SharkyPersonaEvents.onMistake());
  }
}
