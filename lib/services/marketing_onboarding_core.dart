import 'dart:convert';
import 'dart:io';

/// Service responsible for recording marketing/onboarding events and reporting
/// aggregated metrics.
class MarketingOnboardingCore {
  MarketingOnboardingCore({
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
    this.summaryPath = 'release/_reports/onboarding_metrics_summary.txt',
  });

  final String telemetryPath;
  final String summaryPath;

  /// Records a marketing/onboarding event to telemetry.jsonl.
  Future<void> recordEvent(
    String event, {
    Map<String, Object?> metadata = const {},
  }) async {
    final payload = <String, Object?>{
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
      'category': 'marketing_onboarding',
      'metadata': metadata,
    };
    await File(telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  /// Recomputes onboarding metrics and writes the summary/report.
  Future<void> updateMetrics() async {
    final metrics = await _aggregateMetrics();
    await _withReportsWritable(() async {
      await _writeSummary(metrics);
      await _emitTelemetry(metrics);
    });
  }

  Future<_OnboardingMetrics> _aggregateMetrics() async {
    final file = File(telemetryPath);
    if (!await file.exists()) {
      return const _OnboardingMetrics();
    }
    final lines = await file.readAsLines();
    var firstLaunch = 0;
    var signupCompleted = 0;
    var tutorialStarted = 0;
    var tutorialFinished = 0;

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      dynamic payload;
      try {
        payload = json.decode(line);
      } catch (_) {
        continue;
      }
      if (payload is! Map<String, dynamic>) continue;
      final event = payload['event']?.toString();
      switch (event) {
        case 'first_launch':
          firstLaunch++;
          break;
        case 'signup_completed':
          signupCompleted++;
          break;
        case 'tutorial_started':
          tutorialStarted++;
          break;
        case 'tutorial_finished':
          tutorialFinished++;
          break;
        default:
          continue;
      }
    }

    final completionRate = signupCompleted == 0
        ? 0.0
        : (tutorialFinished / signupCompleted) * 100;

    return _OnboardingMetrics(
      firstLaunch: firstLaunch,
      signupCompleted: signupCompleted,
      tutorialStarted: tutorialStarted,
      tutorialFinished: tutorialFinished,
      completionRate: completionRate,
    );
  }

  Future<void> _writeSummary(_OnboardingMetrics metrics) async {
    final buffer = StringBuffer()
      ..writeln('ONBOARDING METRICS SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('First launches: ${metrics.firstLaunch}')
      ..writeln('Signup completed: ${metrics.signupCompleted}')
      ..writeln('Tutorial started: ${metrics.tutorialStarted}')
      ..writeln('Tutorial finished: ${metrics.tutorialFinished}')
      ..writeln(
        'Onboarding completion rate: '
        '${metrics.completionRate.toStringAsFixed(1)}%',
      );

    await File(summaryPath).writeAsString('${buffer.toString()}\n');
  }

  Future<void> _emitTelemetry(_OnboardingMetrics metrics) async {
    final payload = <String, Object?>{
      'event': 'onboarding_metrics_updated',
      'timestamp': DateTime.now().toIso8601String(),
      'first_launch': metrics.firstLaunch,
      'signup_completed': metrics.signupCompleted,
      'tutorial_started': metrics.tutorialStarted,
      'tutorial_finished': metrics.tutorialFinished,
      'completion_rate': double.parse(
        metrics.completionRate.toStringAsFixed(1),
      ),
    };
    await File(telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
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
    final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
    if (result.exitCode != 0) {
      stderr.writeln(
        'marketing_onboarding_core: chmod failed '
        '(${result.exitCode}): ${result.stderr}',
      );
    }
  }
}

class _OnboardingMetrics {
  const _OnboardingMetrics({
    this.firstLaunch = 0,
    this.signupCompleted = 0,
    this.tutorialStarted = 0,
    this.tutorialFinished = 0,
    this.completionRate = 0,
  });

  final int firstLaunch;
  final int signupCompleted;
  final int tutorialStarted;
  final int tutorialFinished;
  final double completionRate;
}
