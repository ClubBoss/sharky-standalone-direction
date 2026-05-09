import 'dart:convert';
import 'dart:io';

import 'ux_feedback_animation_models.dart';
import 'ux_feedback_animation_renderer_stub.dart'
    if (dart.library.ui) 'ux_feedback_animation_renderer_flutter.dart'
    as renderer;

const String _summaryPath =
    'release/_reports/ux_feedback_animation_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

class UxFeedbackAnimations {
  static final Map<UxFeedbackType, FeedbackAnimationSpec> _specs =
      <UxFeedbackType, FeedbackAnimationSpec>{
        UxFeedbackType.success: const FeedbackAnimationSpec(
          type: UxFeedbackType.success,
          primaryHex: '#00B894',
          secondaryHex: '#2ECC71',
          durationMs: 800,
          scale: 1.05,
          icon: 'trophy',
          description: 'Great read!',
          hapticPattern: 'lightSuccess',
        ),
        UxFeedbackType.error: const FeedbackAnimationSpec(
          type: UxFeedbackType.error,
          primaryHex: '#B73239',
          secondaryHex: '#F04848',
          durationMs: 600,
          scale: 0.9,
          icon: 'error',
          description: 'Let’s adjust.',
          hapticPattern: 'error',
        ),
        UxFeedbackType.levelUp: const FeedbackAnimationSpec(
          type: UxFeedbackType.levelUp,
          primaryHex: '#D8B243',
          secondaryHex: '#F5E15B',
          durationMs: 1100,
          scale: 1.2,
          icon: 'level',
          description: 'Level up!',
          hapticPattern: 'heavySuccess',
        ),
      };

  static FeedbackAnimationSpec spec(UxFeedbackType type) => _specs[type]!;

  static Future<void> playFeedback(
    UxFeedbackType type,
    renderer.AnimationHost host,
  ) => renderer.playFeedback(spec(type), host);

  static Future<void> generateSummary() async {
    final stopwatch = Stopwatch()..start();
    await _withReportsWritable(() async {
      await _writeSummary(stopwatch.elapsedMilliseconds);
      await _emitTelemetry(stopwatch.elapsedMilliseconds);
    });
  }

  static Future<void> _writeSummary(int durationMs) async {
    final buffer = StringBuffer()
      ..writeln('UX FEEDBACK ANIMATION SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln()
      ..writeln('Supported feedback types:');
    for (final spec in _specs.values) {
      buffer
        ..writeln('- ${spec.type.name}')
        ..writeln(
          '  Colors: ${spec.primaryHex} → ${spec.secondaryHex} | Duration: '
          '${spec.durationMs}ms | Scale: ${spec.scale}',
        )
        ..writeln(
          '  Copy: ${spec.description} | Haptics: ${spec.hapticPattern}',
        )
        ..writeln();
    }
    await File(_summaryPath).writeAsString('${buffer.toString()}');
  }

  static Future<void> _emitTelemetry(int durationMs) async {
    final payload = <String, Object?>{
      'event': 'ux_feedback_animation_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'animations': _specs.entries
          .map(
            (entry) => {
              'type': entry.key.name,
              'duration_ms': entry.value.durationMs,
              'scale': entry.value.scale,
              'primary': entry.value.primaryHex,
              'secondary': entry.value.secondaryHex,
            },
          )
          .toList(),
      'duration_ms': durationMs,
    };

    await File(_telemetryPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

Future<void> main(List<String> args) async {
  await UxFeedbackAnimations.generateSummary();
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
