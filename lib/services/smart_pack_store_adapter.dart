import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _summaryPath = '$_reportsDir/smart_pack_store_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

class SmartPackStoreAdapter {
  const SmartPackStoreAdapter();

  Future<List<SmartPackRecommendation>> fetchTopPacks({int limit = 3}) async {
    final file = File(_summaryPath);
    if (!await file.exists()) return const [];
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return const [];

      final clusters = decoded['clusters'];
      if (clusters is! List) return const [];

      final List<SmartPackRecommendation> recs = [];
      for (final cluster in clusters) {
        if (cluster is! Map<String, dynamic>) continue;
        final packs = cluster['packs'];
        if (packs is! List) continue;
        for (final pack in packs) {
          if (pack is! Map<String, dynamic>) continue;
          final recommendation = SmartPackRecommendation.fromJson(
            pack,
            clusterPersona: cluster['persona']?.toString(),
          );
          if (recommendation != null) {
            recs.add(recommendation);
          }
        }
      }

      recs.sort((a, b) => b.score.compareTo(a.score));
      return recs.take(limit).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> logTelemetry({
    required String action,
    SmartPackRecommendation? pack,
  }) async {
    final payload = <String, Object?>{
      'event': 'smart_pack_store_widget_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'action': action,
      if (pack != null) ...{
        'topic': pack.topic,
        'path': pack.path,
        'ev_percent': pack.evPercent,
        'resonance': pack.resonance,
      },
    };
    await _withReportsWritable(() async {
      final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
      sink.writeln(jsonEncode(payload));
      await sink.close();
    });
  }
}

class SmartPackRecommendation {
  const SmartPackRecommendation({
    required this.topic,
    required this.evUplift,
    required this.difficulty,
    required this.resonance,
    required this.path,
    required this.persona,
  });

  final String topic;
  final double evUplift;
  final double difficulty;
  final double resonance;
  final String path;
  final String persona;

  double get evPercent => (evUplift - 1).clamp(0, double.infinity) * 100;

  double get score => evUplift * (resonance <= 0 ? 1 : resonance);

  static SmartPackRecommendation? fromJson(
    Map<String, dynamic> json, {
    String? clusterPersona,
  }) {
    final topic = json['topic']?.toString();
    if (topic == null) return null;
    final ev = (json['ev_uplift'] as num?)?.toDouble() ?? 1;
    final difficulty = (json['difficulty'] as num?)?.toDouble() ?? 0.5;
    final resonance = (json['resonance'] as num?)?.toDouble() ?? 1.0;
    final path = json['path']?.toString() ?? '';
    final persona = clusterPersona ?? 'persona';
    return SmartPackRecommendation(
      topic: topic,
      evUplift: ev,
      difficulty: difficulty,
      resonance: resonance,
      path: path,
      persona: persona,
    );
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
