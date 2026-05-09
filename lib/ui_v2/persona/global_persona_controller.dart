import 'dart:ui' show Color;

import 'sharky_persona_router.dart';
import 'sharky_persona_events.dart';
import '../design/design_tokens.dart';
import 'clip_frame_spec.dart';
import 'clip_registry.dart';
import 'clip_sequence_spec.dart';
import 'clip_playback_engine.dart';
import 'clip_orchestrator.dart';
import 'persona_fusion_frame.dart';
import 'persona_reaction_kernel.dart';
import 'persona_reaction_state.dart';

class UnifiedPersonaEvent {
  const UnifiedPersonaEvent({
    required this.beat,
    required this.fusionIntensity,
    required this.clipOpacity,
    required this.tone,
  });

  final double beat;
  final double fusionIntensity;
  final double clipOpacity;
  final Color tone;
}

class GlobalPersonaController {
  static final instance = GlobalPersonaController._(ClipRegistry.empty);

  GlobalPersonaController._(this.registry);

  final SharkyPersonaRouter _router = SharkyPersonaRouter();
  double _lastMotionBeat = 0.0;
  SharkyMotionSignal? _lastMotionSignal;
  PersonaExpressionState _expression = const PersonaExpressionState(
    PersonaExpression.idle,
    0.0,
  );
  PersonaMicroExpression? _micro;
  PersonaFusionState? _fusion;
  List<ClipFrameSpec>? _pendingClip;
  ClipSequenceSpec? _activeClip;
  ClipPlaybackEngine? _clipEngine;
  final ClipRegistry registry;
  ClipOrchestrator? _clipOrchestrator;
  ClipFrameSpec? _lastClipFrame;
  final List<UnifiedPersonaEvent> _eventHistory = [];
  PersonaReactionState _reactionState = const PersonaReactionState(
    type: PersonaReactionType.idle,
    intensity: 0.0,
  );
  final PersonaReactionKernel _reactionKernel = const PersonaReactionKernel();
  UnifiedPersonaEvent? _lastUnifiedEvent;
  PersonaNodeSyncState? _lastNodeSyncState;

  SharkyPersonaRouter get router => _router;
  double get lastMotionBeat => _lastMotionBeat;
  SharkyMotionSignal? get lastMotionSignal => _lastMotionSignal;
  PersonaExpressionState get expression => _expression;
  PersonaMicroExpression? get microExpression => _micro;
  PersonaFusionState? get fusion => _fusion;
  List<ClipFrameSpec>? get pendingClip => _pendingClip;
  ClipSequenceSpec? get activeClip => _activeClip;
  ClipRegistry get clipRegistry => registry;
  ClipPlaybackEngine? get clipEngine => _clipEngine;
  ClipOrchestrator? get clipOrchestrator => _clipOrchestrator;
  ClipFrameSpec? get lastClipFrame => _lastClipFrame;
  PersonaReactionState get reactionState => _reactionState;
  UnifiedPersonaEvent? get lastUnifiedEvent => _lastUnifiedEvent;
  UnifiedPersonaEvent? get lastStableUnifiedEvent =>
      _eventHistory.isNotEmpty ? _eventHistory.last : _lastUnifiedEvent;

  void updateMotionBeat(double beat) {
    _lastMotionBeat = beat.clamp(0.0, 1.0);
    onMotionCue(PersonaMotionCue.beat, _lastMotionBeat);
  }

  void onMotionCue(PersonaMotionCue cue, double beat) {
    _lastMotionSignal = SharkyMotionSignal(cue, beat.clamp(0.0, 1.0));
    _expression = resolveExpression(_lastMotionSignal!);
    _micro = resolveMicroExpression(_lastMotionSignal!.beat);
    _fusion = _resolveFusion();
    emitUnifiedPersonaEvent(
      _lastMotionSignal!,
      latestFusionFrame ?? defaultFusionFrame(),
      _clipOrchestrator?.currentFrame() ?? defaultClipFrame(),
    );
    _reactionState = _reactionKernel.compute(
      _lastMotionSignal,
      latestFusionFrame,
      _lastClipFrame,
    );
  }

  void setActiveClip(ClipSequenceSpec? clip) {
    _activeClip = clip;
  }

  void bindClipPlayback(ClipPlaybackEngine engine) {
    _clipEngine = engine;
  }

  void bindClipOrchestrator(ClipOrchestrator orch) {
    _clipOrchestrator = orch;
  }

  void triggerClip(ClipSequenceSpec seq) {
    _activeClip = seq;
    if (_clipEngine != null) {
      _clipEngine!.reset();
    }
  }

  void maybeTriggerFromCue(SharkyMotionSignal signal) {
    switch (signal.type) {
      case SharkyMotionSignalType.fold:
        triggerClip(registry.getClip('foldSmall') ?? seqFallback('foldSmall'));
        break;
      case SharkyMotionSignalType.call:
        triggerClip(registry.getClip('callSmall') ?? seqFallback('callSmall'));
        break;
      case SharkyMotionSignalType.raise:
        triggerClip(
          registry.getClip('raiseStrong') ?? seqFallback('raiseStrong'),
        );
        break;
      case SharkyMotionSignalType.winner:
        triggerClip(
          registry.getClip('winnerBurst') ?? seqFallback('winnerBurst'),
        );
        break;
      default:
        break;
    }
  }

  ClipSequenceSpec seqFallback(String id) =>
      ClipSequenceSpec(id: id, frames: [const ClipFrameSpec(t: 0)]);

  void tickClip(double dtMs) {
    _clipOrchestrator?.tick(dtMs);
    _lastClipFrame = _clipOrchestrator?.currentFrame();
    if (_lastMotionSignal != null) {
      emitUnifiedPersonaEvent(
        _lastMotionSignal!,
        latestFusionFrame ?? defaultFusionFrame(),
        _lastClipFrame ?? defaultClipFrame(),
      );
    }
    _reactionState = _reactionKernel.compute(
      _lastMotionSignal,
      latestFusionFrame,
      _lastClipFrame,
    );
  }

  void emitUnifiedPersonaEvent(
    SharkyMotionSignal signal,
    PersonaFusionFrame fusion,
    ClipFrameSpec clip,
  ) {
    final normalizedBeat = signal.beat.clamp(0.0, 1.0);
    final fusionIntensity = fusion.intensity.clamp(0.0, 1.0);
    final clipOpacity = clip.opacity.clamp(0.0, 1.0);
    final tone = Color(DesignColors.accentStrong);
    final sanitized = UnifiedPersonaEvent(
      beat: normalizedBeat,
      fusionIntensity: fusionIntensity,
      clipOpacity: clipOpacity,
      tone: tone,
    );
    _lastUnifiedEvent = sanitized;
    if (_eventHistory.length >= 2) {
      _eventHistory.removeAt(0);
    }
    _eventHistory.add(sanitized);
  }

  void updateNodeSync(PersonaNodeSyncState state) {
    final sanitized = PersonaNodeSyncState(
      activeSeat: state.activeSeat,
      turnSeat: state.turnSeat,
      street: state.street,
      beat: state.beat.clamp(0.0, 1.0),
    );
    _lastNodeSyncState = sanitized;
  }

  PersonaNodeSyncState? get lastNodeSyncState => _lastNodeSyncState;

  PersonaFusionFrame? get latestFusionFrame {
    final frame = _lastClipFrame;
    if (frame == null) return null;
    final macro = _expression.expression;
    final micro = _micro ?? PersonaMicroExpression.idleBounce;
    return fuseClipWithExpressions(
      frame: frame,
      macro: macro,
      micro: micro,
      beat: _lastMotionBeat,
    );
  }

  PersonaFusionFrame fuseClipWithExpressions({
    required ClipFrameSpec frame,
    required PersonaExpression macro,
    required PersonaMicroExpression micro,
    required double beat,
  }) {
    final macroIntensity = _expression.intensity;
    final microIntensity = _microIntensity(micro);
    final scale = frame.scale * (1 + (beat * 0.12));
    final opacity = frame.opacity * (1 + (microIntensity * 0.15));
    final yLift = frame.yLift + (macroIntensity * 6.0);
    return PersonaFusionFrame(
      scale: scale,
      opacity: opacity.clamp(0.0, 1.0),
      yLift: yLift,
      intensity: macroIntensity,
    );
  }

  PersonaFusionFrame defaultFusionFrame() => const PersonaFusionFrame(
    scale: 1.0,
    opacity: 0.0,
    yLift: 0.0,
    intensity: 0.0,
  );

  ClipFrameSpec defaultClipFrame() =>
      const ClipFrameSpec(t: 0.0, scale: 1.0, yLift: 0.0, opacity: 0.0);

  double _microIntensity(PersonaMicroExpression micro) {
    switch (micro) {
      case PersonaMicroExpression.blink:
        return 0.2;
      case PersonaMicroExpression.microNod:
        return 0.4;
      case PersonaMicroExpression.microTilt:
        return 0.6;
      case PersonaMicroExpression.idleBounce:
        return 0.35;
    }
  }

  PersonaExpressionState resolveExpression(SharkyMotionSignal signal) {
    final beat = signal.beat;
    switch (signal.cue) {
      case PersonaMotionCue.beat:
        return PersonaExpressionState(PersonaExpression.idle, beat);
      case PersonaMotionCue.fold:
        return PersonaExpressionState(
          PersonaExpression.tilt,
          _clamp(0.4 + 0.3 * beat),
        );
      case PersonaMotionCue.call:
        return PersonaExpressionState(
          PersonaExpression.nod,
          _clamp(0.3 + 0.2 * beat),
        );
      case PersonaMotionCue.raise:
        return PersonaExpressionState(
          PersonaExpression.attentive,
          _clamp(0.6 + 0.3 * beat),
        );
      case PersonaMotionCue.street:
        return PersonaExpressionState(
          PersonaExpression.reassure,
          _clamp(0.3 + 0.3 * beat),
        );
      case PersonaMotionCue.winner:
        return PersonaExpressionState(
          PersonaExpression.celebrate,
          _clamp(0.7 + 0.3 * beat),
        );
    }
  }

  PersonaMicroExpression resolveMicroExpression(double beat) {
    if (beat < 0.15) {
      return PersonaMicroExpression.blink;
    }
    if (beat < 0.35) {
      return PersonaMicroExpression.microNod;
    }
    if (beat < 0.65) {
      return PersonaMicroExpression.idleBounce;
    }
    return PersonaMicroExpression.microTilt;
  }

  PersonaFusionState _resolveFusion() {
    final expression = _expression.expression;
    final intensity = _expression.intensity;
    final beat = _lastMotionBeat;
    final micro = _micro ?? PersonaMicroExpression.idleBounce;
    final signal = _lastMotionSignal?.type ?? SharkyMotionSignalType.none;
    return PersonaFusionState(
      macro: expression,
      micro: micro,
      intensity: intensity,
      beat: beat,
      signal: signal,
    );
  }

  static double _clamp(double value) => value.clamp(0.0, 1.0);
}

class PersonaNodeSyncState {
  const PersonaNodeSyncState({
    required this.activeSeat,
    required this.turnSeat,
    required this.street,
    required this.beat,
  });

  final int activeSeat;
  final int turnSeat;
  final String street;
  final double beat;
}
