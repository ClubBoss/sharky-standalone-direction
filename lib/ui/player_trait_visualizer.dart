import 'dart:convert';
import 'dart:io';

import 'player_trait_visualizer_models.dart';
import 'player_trait_visualizer_stub.dart'
    if (dart.library.ui) 'player_trait_visualizer_flutter.dart'
    as bridge;

const String _traitsProfilePath = 'release/_reports/player_traits_profile.json';
const String _summaryPath =
    'release/_reports/player_trait_visualizer_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

class PlayerTraitVisualizer {
  static Future<void> showTraitGain(dynamic context, TraitGainEvent event) =>
      bridge.showTraitGain(context, event);

  static Future<void> generateSummary() async {
    final stopwatch = Stopwatch()..start();
    final traits = await _loadTraits();

    await _withReportsWritable(() async {
      await _writeSummary(traits, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(traits, stopwatch.elapsedMilliseconds);
    });
  }

  static Future<List<Map<String, Object?>>> _loadTraits() async {
    final file = File(_traitsProfilePath);
    if (!await file.exists()) return const [];
    try {
      final raw = json.decode(await file.readAsString());
      final traits = (raw as Map)['traits'];
      if (traits is List) {
        return traits
            .cast<Map>()
            .map((e) => e.cast<String, Object?>())
            .toList();
      }
    } catch (_) {
      // ignore malformed
    }
    return const [];
  }

  static Future<void> _writeSummary(
    List<Map<String, Object?>> traits,
    int durationMs,
  ) async {
    final buffer = StringBuffer()
      ..writeln('PLAYER TRAIT VISUALIZER SUMMARY')
      ..writeln('===============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln();
    if (traits.isEmpty) {
      buffer.writeln('No traits profile found.');
    } else {
      buffer.writeln('Trait cues:');
      for (final trait in traits) {
        buffer.writeln(
          '- ${trait['name']} (${trait['rarity']}) '
          '${trait['temporary'] == true ? '[Temporary]' : '[Permanent]'}',
        );
        buffer.writeln('  ${trait['description']}');
      }
    }
    buffer.writeln();
    await File(_summaryPath).writeAsString('${buffer.toString()}');
  }

  static Future<void> _emitTelemetry(
    List<Map<String, Object?>> traits,
    int durationMs,
  ) async {
    final payload = <String, Object?>{
      'event': 'player_trait_visualizer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'traits': traits.map((trait) => trait['name']).toList(),
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
  await PlayerTraitVisualizer.generateSummary();
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
