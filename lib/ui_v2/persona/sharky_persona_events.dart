import 'sharky_persona_rules.dart';
import 'sharky_persona_state.dart';

enum PersonaMotionCue { beat, fold, call, raise, street, winner }

class SharkyMotionSignal {
  const SharkyMotionSignal(this.cue, this.beat);

  final PersonaMotionCue cue;
  final double beat;

  SharkyMotionSignalType get type {
    switch (cue) {
      case PersonaMotionCue.beat:
        return SharkyMotionSignalType.beat;
      case PersonaMotionCue.fold:
        return SharkyMotionSignalType.fold;
      case PersonaMotionCue.call:
        return SharkyMotionSignalType.call;
      case PersonaMotionCue.raise:
        return SharkyMotionSignalType.raise;
      case PersonaMotionCue.street:
        return SharkyMotionSignalType.street;
      case PersonaMotionCue.winner:
        return SharkyMotionSignalType.winner;
    }
  }
}

enum PersonaMicroExpression { blink, microNod, microTilt, idleBounce }

enum PersonaExpression { idle, attentive, nod, celebrate, reassure, tilt }

class PersonaExpressionState {
  const PersonaExpressionState(this.expression, this.intensity);

  final PersonaExpression expression;
  final double intensity;
}

enum SharkyMotionSignalType { none, beat, fold, call, raise, street, winner }

class PersonaFusionState {
  const PersonaFusionState({
    required this.macro,
    required this.micro,
    required this.intensity,
    required this.beat,
    required this.signal,
  });

  final PersonaExpression macro;
  final PersonaMicroExpression micro;
  final double intensity;
  final double beat;
  final SharkyMotionSignalType signal;
}

class SharkyPersonaEvents {
  static SharkyPersonaState onXpGain() {
    return SharkyPersonaRules.defaultForMode(SharkyPersonaMode.engaged);
  }

  static SharkyPersonaState onMistake() {
    return SharkyPersonaRules.defaultForMode(SharkyPersonaMode.warning);
  }

  static SharkyPersonaState onStreak() {
    return SharkyPersonaRules.defaultForMode(SharkyPersonaMode.reward);
  }

  static SharkyPersonaState onIdle() {
    return SharkyPersonaRules.defaultForMode(SharkyPersonaMode.neutral);
  }

  static SharkyPersonaState onAction(String action) {
    return SharkyPersonaRules.defaultForMode(SharkyPersonaMode.engaged);
  }

  static SharkyPersonaState onStreetChange(String street) {
    final mode = street == 'river'
        ? SharkyPersonaMode.reward
        : SharkyPersonaMode.engaged;
    return SharkyPersonaRules.defaultForMode(mode);
  }

  static SharkyPersonaState onActiveSeat(int seat) {
    return SharkyPersonaRules.defaultForMode(SharkyPersonaMode.engaged);
  }
}
