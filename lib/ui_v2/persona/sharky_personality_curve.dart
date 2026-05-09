import 'sharky_persona_events.dart';
import 'sharky_persona_router.dart';
import 'sharky_persona_state.dart';

class SharkyPersonalityCurve {
  static int _cooldown = 0;

  static void applyCooldown(SharkyPersonaRouter router) {
    _cooldown++;

    if (router.state.mode == SharkyPersonaMode.neutral) {
      _cooldown = 0;
      return;
    }

    if (_cooldown > 180) {
      router.setState(SharkyPersonaEvents.onIdle());
      _cooldown = 0;
    }
  }
}
