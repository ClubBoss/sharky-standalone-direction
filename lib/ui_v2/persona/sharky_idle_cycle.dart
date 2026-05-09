import 'sharky_persona_events.dart';
import 'sharky_persona_router.dart';

class SharkyIdleCycle {
  static int _counter = 0;

  static void onIdleTick(SharkyPersonaRouter router) {
    _counter++;

    if (_counter % 60 == 0) {
      router.setState(SharkyPersonaEvents.onXpGain());
      return;
    }

    if (_counter % 120 == 0) {
      router.setState(SharkyPersonaEvents.onIdle());
    }
  }
}
