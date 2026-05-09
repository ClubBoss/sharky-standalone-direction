import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final service = DesignAiSyncService();
  await service.run();
}

class DesignAiSyncService {
  DesignAiSyncService({
    this.profilePath = 'release/_reports/personalization_profile.json',
    this.summaryPath = 'release/_reports/design_ai_sync_summary.txt',
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
  });

  final String profilePath;
  final String summaryPath;
  final String telemetryPath;

  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final profile = await _PersonalizationProfile.load(profilePath);
    final bridge = _ThemeBridge.fromProfile(profile);

    await _withReportsWritable(() async {
      await _writeSummary(profile, bridge, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(profile, bridge, stopwatch.elapsedMilliseconds);
    });

    stdout.writeln(
      'design_ai_sync_service: accent=${bridge.accentToken} '
      'spacing=${bridge.spacingToken} typography=${bridge.typographyToken}',
    );
  }

  Future<void> _writeSummary(
    _PersonalizationProfile profile,
    _ThemeBridge bridge,
    int durationMs,
  ) async {
    final buffer = StringBuffer()
      ..writeln('DESIGN AI SYNC SUMMARY')
      ..writeln('======================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln()
      ..writeln('Personalization snapshot:')
      ..writeln('- Accuracy         : ${_pct(profile.accuracy)}')
      ..writeln('- Speed (ms)       : ${profile.speedMs.toStringAsFixed(0)}')
      ..writeln('- XP rate          : ${profile.xpRate.toStringAsFixed(2)}')
      ..writeln('- Top topic        : ${profile.topTopic}')
      ..writeln()
      ..writeln('Mapped theme tokens:')
      ..writeln(
        '- AppColors accent : ${bridge.accentToken} '
        '(${bridge.accentHex})',
      )
      ..writeln(
        '- AppSpacing scale : ${bridge.spacingToken} '
        '(scale=${bridge.spacingScale.toStringAsFixed(2)})',
      )
      ..writeln(
        '- AppTypography set: ${bridge.typographyToken} '
        '(weight=${bridge.typographyWeight.toStringAsFixed(0)})',
      )
      ..writeln(
        '- Overlay strength : ${bridge.overlayStrength.toStringAsFixed(2)}',
      )
      ..writeln()
      ..writeln('Recommended adjustments:')
      ..writeln('1. Update AppColors.accent to ${bridge.accentHex}.')
      ..writeln(
        '2. Apply ${bridge.spacingToken} to AppSpacing gutters to '
        'match engagement tempo.',
      )
      ..writeln(
        '3. Set ${bridge.typographyToken} weight to '
        '${bridge.typographyWeight.toStringAsFixed(0)} for hero banners.',
      )
      ..writeln('4. ${bridge.recommendation}')
      ..writeln();

    await File(summaryPath).writeAsString('${buffer.toString()}');
  }

  Future<void> _emitTelemetry(
    _PersonalizationProfile profile,
    _ThemeBridge bridge,
    int durationMs,
  ) async {
    final payload = <String, Object?>{
      'event': 'design_ai_sync_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'profile': {
        'accuracy': profile.accuracy,
        'speed_ms': profile.speedMs,
        'xp_rate': profile.xpRate,
        'top_topic': profile.topTopic,
      },
      'theme_tokens': {
        'accent_token': bridge.accentToken,
        'accent_hex': bridge.accentHex,
        'spacing_token': bridge.spacingToken,
        'spacing_scale': bridge.spacingScale,
        'typography_token': bridge.typographyToken,
        'typography_weight': bridge.typographyWeight,
        'overlay_strength': bridge.overlayStrength,
      },
      'duration_ms': durationMs,
    };

    await File(telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class _PersonalizationProfile {
  const _PersonalizationProfile({
    required this.accuracy,
    required this.speedMs,
    required this.xpRate,
    required this.topTopic,
  });

  static Future<_PersonalizationProfile> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const _PersonalizationProfile(
        accuracy: 0.7,
        speedMs: 4200,
        xpRate: 1.0,
        topTopic: 'general',
      );
    }

    try {
      final raw = json.decode(await file.readAsString());
      if (raw is! Map<String, Object?>) {
        return const _PersonalizationProfile(
          accuracy: 0.7,
          speedMs: 4200,
          xpRate: 1.0,
          topTopic: 'general',
        );
      }
      final fingerprint =
          (raw['fingerprint'] as Map<String, Object?>?) ?? <String, Object?>{};
      final topicBias =
          (fingerprint['topic_bias'] as Map<String, Object?>?) ??
          <String, Object?>{};
      final sortedTopics =
          topicBias.entries
              .map((e) => MapEntry(e.key, _toDouble(e.value) ?? 0))
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value));
      final topTopic = sortedTopics.isEmpty
          ? 'general'
          : sortedTopics.first.key;

      return _PersonalizationProfile(
        accuracy: _toDouble(fingerprint['accuracy']) ?? 0.7,
        speedMs: _toDouble(fingerprint['speed_ms']) ?? 4200,
        xpRate: _toDouble(fingerprint['xp_rate']) ?? 1.0,
        topTopic: topTopic,
      );
    } catch (_) {
      return const _PersonalizationProfile(
        accuracy: 0.7,
        speedMs: 4200,
        xpRate: 1.0,
        topTopic: 'general',
      );
    }
  }

  final double accuracy;
  final double speedMs;
  final double xpRate;
  final String topTopic;
}

class _ThemeBridge {
  const _ThemeBridge({
    required this.accentToken,
    required this.accentHex,
    required this.spacingToken,
    required this.spacingScale,
    required this.typographyToken,
    required this.typographyWeight,
    required this.overlayStrength,
    required this.recommendation,
  });

  factory _ThemeBridge.fromProfile(_PersonalizationProfile profile) {
    final palettes = <String, String>{
      'focus': '#00B894', // AppColors.primaryBrand
      'momentum': '#D8B243', // AppColors.accent
      'calm': '#675729', // AppColors.icmPost
    };
    final mood = profile.accuracy >= 0.78
        ? 'focus'
        : (profile.xpRate >= 1.1 ? 'momentum' : 'calm');
    final accentToken = switch (mood) {
      'focus' => 'AppColors.primaryBrand',
      'momentum' => 'AppColors.accent',
      _ => 'AppColors.icmPost',
    };
    final accentHex = palettes[mood]!;

    final baseSpacing =
        1.0 +
        ((profile.speedMs <= 3800 ? 0.1 : -0.05) +
            (profile.xpRate - 1.0) * 0.2);
    final spacingScale = double.parse(
      baseSpacing.clamp(0.85, 1.25).toStringAsFixed(2),
    );
    final spacingToken = spacingScale > 1
        ? 'AppSpacing.comfortable'
        : spacingScale < 1
        ? 'AppSpacing.tight'
        : 'AppSpacing.base';

    final typographyWeight = (600 + ((profile.xpRate - 1) * 1200))
        .clamp(500, 700)
        .toDouble();
    final typographyToken = profile.topTopic.contains('drill')
        ? 'AppTypography.h3'
        : 'AppTypography.h1';

    final overlayStrength = (profile.accuracy * 0.35).clamp(0.1, 0.35);
    final recommendation = profile.speedMs <= 3600
        ? 'Lean into lighter overlays for faster UI handoffs.'
        : 'Increase surface contrast on AppColors.surfaceVariant.';

    return _ThemeBridge(
      accentToken: accentToken,
      accentHex: accentHex,
      spacingToken: spacingToken,
      spacingScale: spacingScale,
      typographyToken: typographyToken,
      typographyWeight: typographyWeight,
      overlayStrength: overlayStrength,
      recommendation: recommendation,
    );
  }

  final String accentToken;
  final String accentHex;
  final String spacingToken;
  final double spacingScale;
  final String typographyToken;
  final double typographyWeight;
  final double overlayStrength;
  final String recommendation;
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
