import 'interpolation_utils.dart';
import 'motion_surface_orchestrator.dart';

class MotionSurfacePlayer {
  MotionSurfacePlayer(this.orchestrator);

  final MotionSurfaceOrchestrator orchestrator;
  List<Map<String, Object>> _previousFlow = const [];
  List<Map<String, Object>> _targetFlow = const [];
  List<Map<String, Object>> _interpolatedFlow = const [];

  List<Map<String, Object>> flow() =>
      _interpolatedFlow.isNotEmpty ? _interpolatedFlow : _targetFlow;

  Map<String, Object>? atIndex(int i) {
    final frames = flow();
    if (i < 0 || i >= frames.length) return null;
    return frames[i];
  }

  void advance(double dt) {
    _previousFlow = _targetFlow;
    _targetFlow = orchestrator.buildFlow();
    _applyInterpolation(dt);
  }

  void _applyInterpolation(double dt) {
    final t = InterpolationUtils.clamp01(dt * 12.0);
    if (_previousFlow.isEmpty || t >= 1.0) {
      _interpolatedFlow = _targetFlow;
      return;
    }
    final interpolated = <Map<String, Object>>[];
    for (var i = 0; i < _targetFlow.length; i++) {
      final target = _targetFlow[i];
      final previous = i < _previousFlow.length ? _previousFlow[i] : target;
      final prevTs = (previous['timestamp'] as num).toDouble();
      final targetTs = (target['timestamp'] as num).toDouble();
      interpolated.add({
        'timestamp': InterpolationUtils.lerp(prevTs, targetTs, t),
        'frames': target['frames'] as Object,
      });
    }
    _interpolatedFlow = interpolated;
  }
}
