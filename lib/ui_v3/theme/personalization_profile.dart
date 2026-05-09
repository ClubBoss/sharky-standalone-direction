import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/ai_personalization_service.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

/// Snapshot of personalization weights relevant to UI surfaces.
class PersonalizationSnapshot {
  const PersonalizationSnapshot({
    required this.mood,
    required this.recommendedModule,
  });

  final String mood;
  final String recommendedModule;

  static const PersonalizationSnapshot fallback = PersonalizationSnapshot(
    mood: 'neutral',
    recommendedModule: 'default_pack',
  );
}

/// Bridge that runs the AI personalization service and exposes a simplified API.
class PersonalizationBridge {
  PersonalizationBridge({
    String telemetryDir = 'telemetry',
    String sessionLogDir = 'export/sessions',
  }) : _service = AiPersonalizationService(
         telemetryDir: telemetryDir,
         sessionLogDir: sessionLogDir,
       );

  final AiPersonalizationService _service;

  Future<PersonalizationSnapshot> loadSnapshot() async {
    try {
      await _service.updatePersonalization();
      final visual = _service.adjustVisualProfile();
      final recommended = _service.getNextRecommendedPack();
      return PersonalizationSnapshot(
        mood: visual['mood']?.toString() ?? 'neutral',
        recommendedModule: recommended,
      );
    } catch (error, stackTrace) {
      debugPrint('Personalization load failed: $error');
      debugPrint('$stackTrace');
      return PersonalizationSnapshot.fallback;
    }
  }
}

/// Derived color palette driven by personalization signals.
class PersonalizationPalette {
  const PersonalizationPalette({
    required this.mood,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.accent,
    required this.badgeBackground,
    required this.badgeForeground,
  });

  final String mood;
  final LinearGradient backgroundGradient;
  final LinearGradient cardGradient;
  final Color accent;
  final Color badgeBackground;
  final Color badgeForeground;

  factory PersonalizationPalette.fromSnapshot(
    PersonalizationSnapshot snapshot,
  ) {
    switch (snapshot.mood) {
      case 'confident':
        return PersonalizationPalette(
          mood: snapshot.mood,
          backgroundGradient: _blendGradient(
            VisualThemeV3.primary,
            VisualThemeV3.success,
          ),
          cardGradient: _blendGradient(
            VisualThemeV3.secondaryAccent,
            VisualThemeV3.success,
          ),
          accent: VisualThemeV3.success,
          badgeBackground: VisualThemeV3.success.withValues(alpha: 0.12),
          badgeForeground: VisualThemeV3.success,
        );
      case 'frustrated':
        return PersonalizationPalette(
          mood: snapshot.mood,
          backgroundGradient: _blendGradient(
            VisualThemeV3.primary,
            VisualThemeV3.warning,
          ),
          cardGradient: _blendGradient(
            VisualThemeV3.warning,
            VisualThemeV3.accentSecondary,
          ),
          accent: VisualThemeV3.warning,
          badgeBackground: VisualThemeV3.warning.withValues(alpha: 0.18),
          badgeForeground: VisualThemeV3.warning,
        );
      default:
        return PersonalizationPalette(
          mood: snapshot.mood,
          backgroundGradient: VisualThemeV3.backgroundGradient,
          cardGradient: VisualThemeV3.brandBackgroundGradient,
          accent: VisualThemeV3.primary,
          badgeBackground: VisualThemeV3.primary.withValues(alpha: 0.08),
          badgeForeground: VisualThemeV3.primary,
        );
    }
  }

  static LinearGradient _blendGradient(Color base, Color accent) {
    final first = Color.lerp(base, accent, 0.15)!;
    final second = Color.lerp(base, accent, 0.35)!;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [first, second],
    );
  }
}
