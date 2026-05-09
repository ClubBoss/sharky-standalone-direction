Map<String, Object> fuseESMWithPersonaContext({
  required Map<String, Object> esmBundle,
  required Map<String, Object> v4ProfileContext,
  Map<String, Object>? attentionToneBundle,
}) {
  final primary = (esmBundle['primary_state'] ?? 'steady').toString();
  final secondary =
      esmBundle['secondary_modifiers'] as Map<String, Object>? ??
      const <String, Object>{};
  final confidence = (esmBundle['confidence'] is num)
      ? (esmBundle['confidence'] as num).toInt()
      : 0;

  final traits = <String, Object>{
    'is_v4_active': v4ProfileContext['is_v4_active'] ?? false,
    'activation_bundle':
        v4ProfileContext['v4_activation_bundle'] ?? const <String, Object>{},
    'persona_tone': v4ProfileContext['persona_tone'] ?? 'neutral',
  };

  final hints = <String, Object>{
    'primary': primary,
    'tilt_risk': secondary['tilt_risk'] ?? false,
    'focus_shift': secondary['focus_shift'] ?? false,
  };

  final attentionTone = attentionToneBundle == null
      ? const <String, Object>{}
      : Map<String, Object>.unmodifiable(attentionToneBundle);

  return Map<String, Object>.unmodifiable(<String, Object>{
    'persona_state': primary,
    'persona_secondary': Map<String, Object>.unmodifiable(secondary),
    'confidence': confidence,
    'traits': Map<String, Object>.unmodifiable(traits),
    'hints': Map<String, Object>.unmodifiable(hints),
    'attention_tone': attentionTone,
  });
}
