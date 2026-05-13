import 'clip_frame_spec.dart';
import 'persona_fusion_frame.dart';
import 'persona_reaction_state.dart';
import 'sharky_persona_events.dart';

class PersonaReactionKernel {
  const PersonaReactionKernel();

  PersonaReactionState compute(
    SharkyMotionSignal? signal,
    PersonaFusionFrame? fusion,
    ClipFrameSpec? clip,
  ) {
    final fusionIntensity = fusion?.scale ?? 0.0;
    final clipOpacity = clip?.opacity ?? 0.0;
    final baseIntensity = (fusionIntensity + clipOpacity) / 2.0;
    final type = _mapSignalToReaction(signal);
    return PersonaReactionState(
      type: type,
      intensity: baseIntensity.clamp(0.0, 1.0),
    );
  }

  PersonaReactionType _mapSignalToReaction(SharkyMotionSignal? signal) {
    if (signal == null) {
      return PersonaReactionType.idle;
    }
    switch (signal.type) {
      case SharkyMotionSignalType.fold:
        return PersonaReactionType.warn;
      case SharkyMotionSignalType.call:
        return PersonaReactionType.pulse;
      case SharkyMotionSignalType.raise:
        return PersonaReactionType.focus;
      case SharkyMotionSignalType.street:
      case SharkyMotionSignalType.winner:
        return PersonaReactionType.celebrate;
      case SharkyMotionSignalType.beat:
      case SharkyMotionSignalType.none:
        return PersonaReactionType.idle;
    }
  }
}
