import 'dart:convert';
import 'dart:io';

import 'dynamic_theme_spec.dart';
import 'dynamic_visual_theme_bridge_stub.dart'
    if (dart.library.ui) 'dynamic_visual_theme_bridge_flutter.dart'
    as bridge;

Future<void> main(List<String> args) async {
  final integration = DynamicVisualAiIntegration();
  await integration.run();
}

/// Bridges design AI sync outputs into dynamic theme specifications.
class DynamicVisualAiIntegration {
  DynamicVisualAiIntegration({
    this.designSummaryPath = 'release/_reports/design_ai_sync_summary.txt',
    this.profilePath = 'release/_reports/personalization_profile.json',
    this.summaryPath =
        'release/_reports/dynamic_visual_integration_summary.txt',
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
  });

  final String designSummaryPath;
  final String profilePath;
  final String summaryPath;
  final String telemetryPath;

  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final design = await _DesignSyncSummary.load(designSummaryPath);
    final profile = await _PersonalizationProfile.load(profilePath);
    final spec = _buildSpec(design, profile);
    DynamicThemeManager.instance.cacheSpec(spec);

    await _withReportsWritable(() async {
      await _writeSummary(spec, design, profile, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(
        spec,
        design,
        profile,
        stopwatch.elapsedMilliseconds,
      );
    });

    stdout.writeln(
      'dynamic_visual_ai_integration: accent=${spec.accentHex} '
      'spacing=${spec.spacingScale} typography=${spec.typographyWeight}',
    );
  }

  Future<void> _writeSummary(
    DynamicThemeSpec spec,
    _DesignSyncSummary design,
    _PersonalizationProfile profile,
    int durationMs,
  ) async {
    final buffer = StringBuffer()
      ..writeln('DYNAMIC VISUAL INTEGRATION')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln()
      ..writeln('Inputs')
      ..writeln(
        '- Design accent       : ${design.accentToken} (${design.accentHex})',
      )
      ..writeln('- Design spacing scale: ${design.spacingScale}')
      ..writeln('- Design typography   : ${design.typographyToken}')
      ..writeln('- Profile accuracy    : ${_pct(profile.accuracy)}')
      ..writeln('- Profile speed (ms)  : ${profile.speedMs.toStringAsFixed(0)}')
      ..writeln('- Profile xp rate     : ${profile.xpRate.toStringAsFixed(2)}')
      ..writeln()
      ..writeln('Dynamic theme outputs')
      ..writeln('- Accent color        : ${spec.accentHex}')
      ..writeln('- Brightness          : ${spec.brightness}')
      ..writeln(
        '- Spacing scale       : ${spec.spacingScale.toStringAsFixed(2)}',
      )
      ..writeln(
        '- Typography weight   : ${spec.typographyWeight.toStringAsFixed(0)}',
      )
      ..writeln(
        '- Overlay strength    : ${spec.overlayStrength.toStringAsFixed(2)}',
      )
      ..writeln(
        '- Visual density adj. : ${spec.densityDelta.toStringAsFixed(2)} '
        '(horizontal/vertical)',
      )
      ..writeln()
      ..writeln('Integration guidance')
      ..writeln(
        '1. Apply `applyDynamicTheme(context)` during app launch or profile switches.',
      )
      ..writeln(
        '2. Use `spec.spacingMultiplier(double base)` for gutters/margins.',
      )
      ..writeln(
        '3. Regenerate typography styles with `spec.typographyWeight` for headers.',
      )
      ..writeln('4. ${spec.recommendation}')
      ..writeln();

    await File(summaryPath).writeAsString('${buffer.toString()}');
  }

  Future<void> _emitTelemetry(
    DynamicThemeSpec spec,
    _DesignSyncSummary design,
    _PersonalizationProfile profile,
    int durationMs,
  ) async {
    final payload = <String, Object?>{
      'event': 'dynamic_visual_integration_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'design': {
        'accent_token': design.accentToken,
        'spacing_token': design.spacingToken,
        'typography_token': design.typographyToken,
      },
      'profile': {
        'accuracy': profile.accuracy,
        'speed_ms': profile.speedMs,
        'xp_rate': profile.xpRate,
      },
      'spec': spec.toJson(),
      'duration_ms': durationMs,
    };

    await File(telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

/// Shared entry-point for the Flutter layer to apply the latest dynamic theme.
Future<bridge.ThemeData> applyDynamicTheme(
  bridge.BuildContext context, {
  DynamicThemeSpec? spec,
  bridge.ThemeData? baseTheme,
}) async {
  final resolved = spec ?? await DynamicThemeManager.instance.loadSpec();
  return bridge.applyDynamicThemeBridge(context, resolved, baseTheme);
}

class DynamicThemeManager {
  DynamicThemeManager._();

  static final DynamicThemeManager instance = DynamicThemeManager._();

  DynamicThemeSpec? _cachedSpec;
  DateTime? _lastLoaded;

  void cacheSpec(DynamicThemeSpec spec) {
    _cachedSpec = spec;
    _lastLoaded = DateTime.now();
  }

  Future<DynamicThemeSpec> loadSpec() async {
    final cacheIsFresh =
        _cachedSpec != null &&
        _lastLoaded != null &&
        DateTime.now().difference(_lastLoaded!) < const Duration(minutes: 5);
    if (cacheIsFresh) {
      return _cachedSpec!;
    }

    final design = await _DesignSyncSummary.load(
      'release/_reports/design_ai_sync_summary.txt',
    );
    final profile = await _PersonalizationProfile.load(
      'release/_reports/personalization_profile.json',
    );
    final spec = _buildSpec(design, profile);
    cacheSpec(spec);
    return spec;
  }
}

DynamicThemeSpec _buildSpec(
  _DesignSyncSummary design,
  _PersonalizationProfile profile,
) {
  final brightness = (profile.speedMs <= 3800 || profile.accuracy >= 0.8)
      ? 'light'
      : 'dark';
  final densityDelta = (design.spacingScale - 1) * 2.5;
  final recommendation = profile.speedMs <= 3600
      ? 'Keep hero modules lively; maintain lighter overlays.'
      : 'Use denser cards with higher overlay opacity.';

  return DynamicThemeSpec(
    accentHex: design.accentHex,
    spacingScale: design.spacingScale,
    typographyWeight: design.typographyWeight,
    overlayStrength: design.overlayStrength,
    brightness: brightness,
    densityDelta: densityDelta,
    recommendation: recommendation,
  );
}

class _DesignSyncSummary {
  const _DesignSyncSummary({
    required this.accentToken,
    required this.accentHex,
    required this.spacingToken,
    required this.spacingScale,
    required this.typographyToken,
    required this.typographyWeight,
    required this.overlayStrength,
  });

  static Future<_DesignSyncSummary> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const _DesignSyncSummary(
        accentToken: 'AppColors.primaryBrand',
        accentHex: '#00B894',
        spacingToken: 'AppSpacing.base',
        spacingScale: 1.0,
        typographyToken: 'AppTypography.h1',
        typographyWeight: 600,
        overlayStrength: 0.2,
      );
    }

    final lines = await file.readAsLines();
    String accentToken = 'AppColors.primaryBrand';
    String accentHex = '#00B894';
    String spacingToken = 'AppSpacing.base';
    double spacingScale = 1.0;
    String typographyToken = 'AppTypography.h1';
    double typographyWeight = 600;
    double overlayStrength = 0.2;

    final accentRegex = RegExp(
      r'AppColors accent : ([^\s]+) \((#[0-9A-Fa-f]{6})\)',
    );
    final spacingRegex = RegExp(
      r'AppSpacing scale : ([^\s]+) \(scale=([0-9.]+)\)',
    );
    final typographyRegex = RegExp(
      r'AppTypography set: ([^\s]+) \(weight=([0-9.]+)\)',
    );
    final overlayRegex = RegExp(r'Overlay strength : ([0-9.]+)');

    for (final line in lines) {
      final trimmed = line.trim();
      final accentMatch = accentRegex.firstMatch(trimmed);
      if (accentMatch != null) {
        accentToken = accentMatch.group(1)!;
        accentHex = accentMatch.group(2)!;
        continue;
      }
      final spacingMatch = spacingRegex.firstMatch(trimmed);
      if (spacingMatch != null) {
        spacingToken = spacingMatch.group(1)!;
        spacingScale = double.tryParse(spacingMatch.group(2)!) ?? 1.0;
        continue;
      }
      final typographyMatch = typographyRegex.firstMatch(trimmed);
      if (typographyMatch != null) {
        typographyToken = typographyMatch.group(1)!;
        typographyWeight =
            double.tryParse(typographyMatch.group(2)!) ?? typographyWeight;
        continue;
      }
      final overlayMatch = overlayRegex.firstMatch(trimmed);
      if (overlayMatch != null) {
        overlayStrength =
            double.tryParse(overlayMatch.group(1)!) ?? overlayStrength;
      }
    }

    return _DesignSyncSummary(
      accentToken: accentToken,
      accentHex: accentHex,
      spacingToken: spacingToken,
      spacingScale: spacingScale,
      typographyToken: typographyToken,
      typographyWeight: typographyWeight,
      overlayStrength: overlayStrength,
    );
  }

  final String accentToken;
  final String accentHex;
  final String spacingToken;
  final double spacingScale;
  final String typographyToken;
  final double typographyWeight;
  final double overlayStrength;
}

class _PersonalizationProfile {
  const _PersonalizationProfile({
    required this.accuracy,
    required this.speedMs,
    required this.xpRate,
  });

  static Future<_PersonalizationProfile> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const _PersonalizationProfile(
        accuracy: 0.7,
        speedMs: 4200,
        xpRate: 1.0,
      );
    }

    try {
      final raw = json.decode(await file.readAsString());
      if (raw is! Map<String, Object?>) {
        return const _PersonalizationProfile(
          accuracy: 0.7,
          speedMs: 4200,
          xpRate: 1.0,
        );
      }

      final fingerprint =
          (raw['fingerprint'] as Map<String, Object?>?) ?? <String, Object?>{};

      return _PersonalizationProfile(
        accuracy: _toDouble(fingerprint['accuracy']) ?? 0.7,
        speedMs: _toDouble(fingerprint['speed_ms']) ?? 4200,
        xpRate: _toDouble(fingerprint['xp_rate']) ?? 1.0,
      );
    } catch (_) {
      return const _PersonalizationProfile(
        accuracy: 0.7,
        speedMs: 4200,
        xpRate: 1.0,
      );
    }
  }

  final double accuracy;
  final double speedMs;
  final double xpRate;
}

String _pct(double value) => '${(value * 100).toStringAsFixed(1)}%';

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
