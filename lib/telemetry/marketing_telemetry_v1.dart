import 'dart:collection';

class MarketingTelemetryV1 {
  MarketingTelemetryV1()
    : _funnelName = 'none',
      _funnelStage = 0,
      _funnelValue = 0.0,
      _deltaAccuracy = 0.0,
      _deltaSpeed = 0.0,
      _friction = 0.0,
      _personaSignal = 'none',
      _coachingStyle = 'neutral';

  String _funnelName;
  int _funnelStage;
  double _funnelValue;
  double _deltaAccuracy;
  double _deltaSpeed;
  double _friction;
  String _personaSignal;
  String _coachingStyle;

  void recordFunnelEvent(String name, int stage, num value) {
    _funnelName = _sanitizeAscii(name, fallback: 'none');
    _funnelStage = _clampStage(stage);
    _funnelValue = value.toDouble();
  }

  void recordEngagementTick(num deltaAccuracy, num deltaSpeed, num friction) {
    _deltaAccuracy = deltaAccuracy.toDouble();
    _deltaSpeed = deltaSpeed.toDouble();
    _friction = friction.toDouble();
  }

  void recordPersonaInfluence(String personaSignal, String coachingStyle) {
    _personaSignal = _sanitizeAscii(personaSignal, fallback: 'none');
    _coachingStyle = _sanitizeAscii(coachingStyle, fallback: 'neutral');
  }

  Map<String, Object> exportTelemetryBundle() {
    final funnel = Map<String, Object>.unmodifiable({
      'name': _funnelName,
      'stage': _funnelStage,
      'value': _funnelValue,
    });
    final engagement = Map<String, Object>.unmodifiable({
      'delta_accuracy': _deltaAccuracy,
      'delta_speed': _deltaSpeed,
      'friction': _friction,
    });
    final personaInfluence = Map<String, Object>.unmodifiable({
      'persona_signal': _personaSignal,
      'coaching_style': _coachingStyle,
    });
    return UnmodifiableMapView<String, Object>({
      'funnel': funnel,
      'engagement': engagement,
      'persona_influence': personaInfluence,
    });
  }

  int _clampStage(int stage) {
    if (stage < 0) return 0;
    if (stage > 10) return 10;
    return stage;
  }

  String _sanitizeAscii(String input, {required String fallback}) {
    for (final codeUnit in input.codeUnits) {
      if (codeUnit > 127) {
        return fallback;
      }
    }
    return input.isEmpty ? fallback : input;
  }
}
