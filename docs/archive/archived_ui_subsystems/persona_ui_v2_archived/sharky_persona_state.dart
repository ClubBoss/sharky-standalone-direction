import 'sharky_persona_router.dart'; // ignore: unused_import

enum SharkyReaction { idle, think, hint, celebrate }

enum SharkyPersonaMode { neutral, engaged, warning, reward }

class SharkyPersonaState {
  final SharkyPersonaMode mode;
  final SharkyReaction reaction;
  final String message;

  const SharkyPersonaState({
    required this.mode,
    required this.reaction,
    required this.message,
  });
}
