import 'package:test/test.dart';
import 'package:poker_analyzer/engine/simulation_motion_kernel.dart';

void main() {
  group('Interpolation pipeline smoke', () {
    test('dt smoothing clamps and smooths consistently', () {
      final kernel = SimulationMotionKernel();
      final first = kernel.smoothDtForTesting(0.1);
      expect(first, closeTo(0.05, 1e-9));
      final second = kernel.smoothDtForTesting(0.02);
      expect(second, closeTo(0.0455, 1e-6));
    });

    test('jitter guard zeroes micro deltas', () {
      final kernel = SimulationMotionKernel();
      final tiny = kernel.smoothDtForTesting(0.0005);
      expect(tiny, equals(0.0));
    });

    test('interpolation advance keeps flow stable', () {
      final kernel = SimulationMotionKernel();
      kernel.tick(0.016);
      final firstFlow = kernel.motionSurfacePlayer.flow();
      kernel.tick(0.016);
      final secondFlow = kernel.motionSurfacePlayer.flow();
      expect(firstFlow, isNotEmpty);
      expect(secondFlow, isNotEmpty);
      expect(firstFlow.first['timestamp'], isNotNull);
    });
  });
}
