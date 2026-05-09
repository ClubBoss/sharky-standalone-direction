import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final start = DateTime.now();
  final version = _parseVersion(args) ?? 'vNext';

  final releaseSummaryFile = File('release/_reports/release_summary.txt');
  final mobileSummaryFile = File('release/_reports/mobile_build_summary.txt');

  if (!await releaseSummaryFile.exists()) {
    stderr.writeln('Missing release/_reports/release_summary.txt');
    exit(1);
  }
  if (!await mobileSummaryFile.exists()) {
    stderr.writeln('Missing release/_reports/mobile_build_summary.txt');
    exit(1);
  }

  final releaseSummary = await releaseSummaryFile.readAsString();
  final mobileSummary = await mobileSummaryFile.readAsString();

  final releaseSteps = _parseReleaseSummary(releaseSummary);
  final mobileInfo = _parseMobileSummary(mobileSummary);
  final telemetryEvents = <Map<String, dynamic>>[]
    ..addAll(_extractTelemetry(releaseSummary))
    ..addAll(_extractTelemetry(mobileSummary));

  final qaSummary = _buildQaSummary(releaseSteps);

  final buffer = StringBuffer()
    ..writeln('### Poker Analyzer Release Notes $version ###')
    ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('')
    ..writeln('#### 1) Build Overview')
    ..writeln('- Platform: ${mobileInfo.platform}')
    ..writeln('- Duration: ${mobileInfo.durationSec}s')
    ..writeln('- Binary Size: ${mobileInfo.sizeBytes} bytes')
    ..writeln('- Artifact: ${mobileInfo.artifactPath}')
    ..writeln('')
    ..writeln('#### 2) QA Summary')
    ..writeln(
      qaSummary.isEmpty
          ? '- QA summary unavailable'
          : qaSummary.map((line) => '- $line').join('\n'),
    )
    ..writeln('')
    ..writeln('#### 3) Telemetry Events Summary');

  if (telemetryEvents.isEmpty) {
    buffer.writeln('- No telemetry events captured');
  } else {
    for (final event in telemetryEvents) {
      final label = event['event'] ?? 'unknown_event';
      final payload = Map<String, dynamic>.from(event)..remove('event');
      buffer.writeln('- $label: ${jsonEncode(payload)}');
    }
  }

  buffer
    ..writeln('')
    ..writeln('#### 4) Next Release Checklist')
    ..writeln('- [ ] Verify localized assets updated')
    ..writeln('- [ ] Run mobile smoke tests on devices')
    ..writeln('- [ ] Tag repository and push build artifacts')
    ..writeln('- [ ] Announce release to QA and product teams');

  final notesDir = Directory('release/_reports');
  await notesDir.create(recursive: true);
  final notesFile = File('${notesDir.path}/final_release_notes.md');
  await notesFile.writeAsString(buffer.toString());

  final end = DateTime.now();
  final telemetry = jsonEncode({
    'event': 'release_notes_generated',
    'version': version,
    'duration_sec': end.difference(start).inSeconds,
    'telemetry_events': telemetryEvents.length,
    'timestamp': end.toUtc().toIso8601String(),
  });
  stdout.writeln(telemetry);
}

String? _parseVersion(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--version=')) {
      return arg.substring('--version='.length);
    }
  }
  return null;
}

class _ReleaseStep {
  const _ReleaseStep({
    required this.label,
    required this.status,
    required this.durationSec,
    required this.output,
  });

  final String label;
  final String status;
  final int durationSec;
  final String output;
}

class _MobileInfo {
  const _MobileInfo({
    required this.platform,
    required this.durationSec,
    required this.sizeBytes,
    required this.artifactPath,
  });

  final String platform;
  final int durationSec;
  final int sizeBytes;
  final String artifactPath;
}

List<_ReleaseStep> _parseReleaseSummary(String text) {
  final lines = const LineSplitter().convert(text);
  final steps = <_ReleaseStep>[];
  String? currentLabel;
  String status = 'UNKNOWN';
  int duration = 0;
  final outputBuffer = StringBuffer();
  var collectingOutput = false;

  for (final line in lines) {
    if (line.startsWith('--- ') && line.endsWith(' ---')) {
      if (currentLabel != null) {
        steps.add(
          _ReleaseStep(
            label: currentLabel,
            status: status,
            durationSec: duration,
            output: outputBuffer.toString(),
          ),
        );
      }
      currentLabel = line.substring(4, line.length - 4).trim().toLowerCase();
      status = 'UNKNOWN';
      duration = 0;
      outputBuffer.clear();
      collectingOutput = false;
    } else if (line.startsWith('Status:')) {
      status = line.substring('Status:'.length).trim();
    } else if (line.startsWith('Duration:')) {
      final raw = line.substring('Duration:'.length).trim();
      final value = int.tryParse(raw.replaceAll('s', ''));
      duration = value ?? 0;
    } else if (line.startsWith('Output:')) {
      collectingOutput = true;
      final raw = line.substring('Output:'.length).trim();
      if (raw.isNotEmpty && raw != '(no output)') {
        outputBuffer.writeln(raw);
      }
    } else if (collectingOutput) {
      if (line.trim().isEmpty) {
        collectingOutput = false;
      } else {
        outputBuffer.writeln(line);
      }
    }
  }

  if (currentLabel != null) {
    steps.add(
      _ReleaseStep(
        label: currentLabel,
        status: status,
        durationSec: duration,
        output: outputBuffer.toString(),
      ),
    );
  }

  return steps;
}

_MobileInfo _parseMobileSummary(String text) {
  final lines = const LineSplitter().convert(text);
  String platform = 'unknown';
  int duration = 0;
  int size = 0;
  String artifact = 'N/A';

  for (final line in lines) {
    if (line.startsWith('Platform:')) {
      platform = line.substring('Platform:'.length).trim();
    } else if (line.startsWith('Duration_sec:')) {
      final raw = line.substring('Duration_sec:'.length).trim();
      duration = int.tryParse(raw) ?? 0;
    } else if (line.startsWith('Artifact_size_bytes:')) {
      final raw = line.substring('Artifact_size_bytes:'.length).trim();
      size = int.tryParse(raw) ?? 0;
    } else if (line.startsWith('Artifact:')) {
      artifact = line.substring('Artifact:'.length).trim();
    }
  }

  return _MobileInfo(
    platform: platform,
    durationSec: duration,
    sizeBytes: size,
    artifactPath: artifact,
  );
}

List<String> _buildQaSummary(List<_ReleaseStep> steps) {
  final summary = <String>[];
  final packStep = steps.firstWhere(
    (step) => step.label == 'pack_validation',
    orElse: () => const _ReleaseStep(
      label: 'pack_validation',
      status: 'UNKNOWN',
      durationSec: 0,
      output: '',
    ),
  );
  summary.add('Pack validation: ${packStep.status} (${packStep.durationSec}s)');

  final regressionStep = steps.firstWhere(
    (step) => step.label == 'regression_qa',
    orElse: () => const _ReleaseStep(
      label: 'regression_qa',
      status: 'UNKNOWN',
      durationSec: 0,
      output: '',
    ),
  );
  summary.add(
    'Regression QA: ${regressionStep.status} (${regressionStep.durationSec}s)',
  );

  final statusMatches = RegExp(r'(FORMAT|ANALYZE|PACKS|TESTS)\s+(✅|❌)');
  for (final match in statusMatches.allMatches(regressionStep.output)) {
    final label = match.group(1) ?? '';
    final icon = match.group(2) ?? '';
    summary.add('QA $label: ${icon == '✅' ? 'PASS' : 'FAIL'}');
  }

  return summary;
}

List<Map<String, dynamic>> _extractTelemetry(String text) {
  final events = <Map<String, dynamic>>[];
  final lines = const LineSplitter().convert(text);
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic> && decoded['event'] != null) {
          events.add(decoded);
        }
      } catch (_) {
        // ignore malformed json line
      }
    }
  }
  return events;
}
