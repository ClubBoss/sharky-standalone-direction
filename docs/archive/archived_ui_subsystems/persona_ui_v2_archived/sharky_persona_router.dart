import 'sharky_persona_state.dart';

class SharkyPersonaRouter {
  static const _defaultState = SharkyPersonaState(
    mode: SharkyPersonaMode.neutral,
    reaction: SharkyReaction.idle,
    message: 'Ready.',
  );

  SharkyPersonaState _state;

  SharkyPersonaRouter([SharkyPersonaState? state])
    : _state = state ?? _defaultState;

  SharkyPersonaState get state => _state;

  void setState(SharkyPersonaState next) {
    _state = next;
  }

  void apply(SharkyPersonaState next) => setState(next);
}
