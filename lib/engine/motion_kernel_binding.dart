import 'card_motion_spec.dart';
import 'motion_orchestrator_input.dart';

class MotionKernelBinding {
  const MotionKernelBinding(this.input);

  factory MotionKernelBinding.fromSequences(
    List<CardMotionSequence> sequences,
  ) {
    final input = MotionOrchestratorInput.fromSequences(sequences);
    return MotionKernelBinding(input);
  }

  final MotionOrchestratorInput input;
}
