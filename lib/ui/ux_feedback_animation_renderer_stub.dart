import 'ux_feedback_animation_models.dart';

class AnimationHost {
  const AnimationHost();
}

Future<void> playFeedback(
  FeedbackAnimationSpec spec,
  AnimationHost host,
) async {
  throw UnsupportedError(
    'UxFeedbackAnimations.playFeedback requires Flutter runtime.',
  );
}
