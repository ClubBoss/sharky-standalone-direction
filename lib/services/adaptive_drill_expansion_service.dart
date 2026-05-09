import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _semanticSummaryPath =
    '$_reportsDir/semantic_drill_enhancer_summary.txt';
const String _resonanceSummaryPath =
    '$_reportsDir/ux_emotional_resonance_summary.json';
const String _calibrationSummaryPath =
    '$_reportsDir/personalization_calibration_summary.json';

class AdaptiveDrillExpansionService {
  Future<AdaptiveDrillExpansionResult> expand() async {
    final semanticTopics = await _loadSemanticTopics();
    final resonanceWeight = await _readResonanceWeight();
    final adaptationWeight = await _readAdaptationWeight();

    final expandedTopics = <ExpandedTopic>[];
    for (final topic in semanticTopics) {
      final evScore = topic.baseEv * resonanceWeight * adaptationWeight;
      final reinforce = evScore >= 1.09;
      if (reinforce) {
        await _writeExpansionPack(topic.name, evScore);
      }
      expandedTopics.add(
        ExpandedTopic(
          name: topic.name,
          baseEv: topic.baseEv,
          resonanceWeight: resonanceWeight,
          adaptationWeight: adaptationWeight,
          evScore: evScore,
          reinforce: reinforce,
        ),
      );
    }

    final averageEv = expandedTopics.isEmpty
        ? 1.0
        : expandedTopics.map((t) => t.evScore).reduce((a, b) => a + b) /
              expandedTopics.length;

    return AdaptiveDrillExpansionResult(
      topics: expandedTopics,
      averageEv: averageEv,
    );
  }

  Future<List<_SemanticTopic>> _loadSemanticTopics() async {
    final file = File(_semanticSummaryPath);
    if (!await file.exists()) return const [];
    final topics = <_SemanticTopic>[];
    final lines = await file.readAsLines();

    String? currentName;
    double? pendingUplift;
    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('- ')) {
        final match = RegExp(r'-\s+([a-z0-9_]+)').firstMatch(line);
        if (match != null) {
          currentName = match.group(1);
          pendingUplift = null;
        }
      } else if (line.contains('uplift=')) {
        final match = RegExp(r'uplift=([0-9.]+)%').firstMatch(line);
        if (match != null) {
          pendingUplift = double.tryParse(match.group(1) ?? '');
          if (currentName != null && pendingUplift != null) {
            final baseEv = 1 + (pendingUplift / 100);
            topics.add(_SemanticTopic(name: currentName, baseEv: baseEv));
            currentName = null;
            pendingUplift = null;
          }
        }
      }
    }
    return topics;
  }

  Future<double> _readResonanceWeight() async {
    final file = File(_resonanceSummaryPath);
    if (!await file.exists()) return 1.0;
    try {
      final Map<String, dynamic> decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final value = (decoded['average_resonance'] as num?)?.toDouble();
      if (value == null) return 1.0;
      return (value / 100).clamp(0.5, 1.5);
    } catch (_) {
      return 1.0;
    }
  }

  Future<double> _readAdaptationWeight() async {
    final file = File(_calibrationSummaryPath);
    if (!await file.exists()) return 1.0;
    try {
      final Map<String, dynamic> decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final score = (decoded['adaptation_score'] as num?)?.toDouble();
      if (score == null) return 1.0;
      return (score / 100).clamp(0.5, 1.5);
    } catch (_) {
      return 1.0;
    }
  }

  Future<void> _writeExpansionPack(String topic, double evScore) async {
    final dir = Directory('content_adaptive_expanded/$topic/v1');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File('${dir.path}/drills.jsonl');
    final payload = {
      'topic': topic,
      'ev_score': double.parse(evScore.toStringAsFixed(4)),
      'generated': DateTime.now().toIso8601String(),
      'recommendation': evScore >= 1.2
          ? 'intensive_reinforcement'
          : 'moderate_reinforcement',
    };
    await file.writeAsString('${jsonEncode(payload)}\n', mode: FileMode.append);
  }
}

class AdaptiveDrillExpansionResult {
  const AdaptiveDrillExpansionResult({
    required this.topics,
    required this.averageEv,
  });

  final List<ExpandedTopic> topics;
  final double averageEv;
}

class ExpandedTopic {
  const ExpandedTopic({
    required this.name,
    required this.baseEv,
    required this.resonanceWeight,
    required this.adaptationWeight,
    required this.evScore,
    required this.reinforce,
  });

  final String name;
  final double baseEv;
  final double resonanceWeight;
  final double adaptationWeight;
  final double evScore;
  final bool reinforce;
}

class _SemanticTopic {
  const _SemanticTopic({required this.name, required this.baseEv});

  final String name;
  final double baseEv;
}
