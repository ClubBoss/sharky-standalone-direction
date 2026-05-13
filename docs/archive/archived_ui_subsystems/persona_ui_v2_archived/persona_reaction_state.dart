enum PersonaReactionType { idle, pulse, focus, celebrate, warn }

class PersonaReactionState {
  const PersonaReactionState({required this.type, required this.intensity});

  final PersonaReactionType type;
  final double intensity;
}
