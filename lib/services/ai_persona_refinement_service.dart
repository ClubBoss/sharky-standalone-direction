import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _statsProfilePath = '$_reportsDir/player_stats_profile.json';
const String _personalizationSummaryPath =
    '$_reportsDir/ai_personalization_summary.txt';

class AiPersonaRefinementService {
  Future<AiPersonaRefinementResult> buildPersonas() async {
    final stats = await _loadStatsProfile();
    final clusters = await _parseClusters();

    final personas = <PersonaAssignment>[];
    final toneWeights = <String, double>{
      'coach': 0,
      'challenger': 0,
      'mentor': 0,
    };

    for (final cluster in clusters) {
      final persona = _derivePersona(cluster);
      personas.add(persona);
      toneWeights.update(
        persona.persona,
        (value) => value + persona.weight,
        ifAbsent: () => persona.weight,
      );
    }

    final totalWeight = toneWeights.values.fold<double>(
      0,
      (value, element) => value + element,
    );
    if (totalWeight > 0) {
      toneWeights.updateAll(
        (key, value) =>
            double.parse(((value / totalWeight) * 100).toStringAsFixed(2)),
      );
    }

    final definedCount = personas.where((p) => p.persona.isNotEmpty).length;
    final toneConsistency = clusters.isEmpty
        ? 100.0
        : (definedCount / clusters.length) * 100.0;

    return AiPersonaRefinementResult(
      personas: personas,
      toneWeights: toneWeights,
      toneConsistency: toneConsistency,
      statsProfile: stats,
    );
  }

  Future<Map<String, _StatProfile>> _loadStatsProfile() async {
    final file = File(_statsProfilePath);
    if (!await file.exists()) {
      return const {};
    }
    try {
      final decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      return decoded.map((key, value) {
        final map = value is Map ? value.cast<String, Object?>() : {};
        return MapEntry(
          key,
          _StatProfile(
            progress: (map['progress_0_1'] as num?)?.toDouble() ?? 0.0,
            rank: map['rank']?.toString() ?? 'Unranked',
          ),
        );
      });
    } catch (_) {
      return const {};
    }
  }

  Future<List<_ClusterData>> _parseClusters() async {
    final file = File(_personalizationSummaryPath);
    if (!await file.exists()) return const [];
    final clusters = <_ClusterData>[];
    final lines = await file.readAsLines();
    _ClusterData? current;
    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('- Cluster')) {
        if (current != null) {
          clusters.add(current);
        }
        final nameMatch = RegExp(r'"([^"]+)"').firstMatch(line);
        final sizeMatch = RegExp(r'size=([0-9]+)').firstMatch(line);
        current = _ClusterData(
          name: nameMatch?.group(1) ?? 'unknown',
          size: int.tryParse(sizeMatch?.group(1) ?? '') ?? 0,
          centroidSessions: 0,
          centroidDuration: 0,
          centroidEngagement: 0,
        );
      } else if (current != null && line.startsWith('Centroid:')) {
        current = current.copyWith(
          centroidSessions:
              _extractValue(line, r'sessions=([0-9.]+)') ??
              current.centroidSessions,
          centroidDuration:
              _extractValue(line, r'duration=([0-9.]+)') ??
              current.centroidDuration,
          centroidEngagement:
              _extractValue(line, r'engagement=([0-9.]+)') ??
              current.centroidEngagement,
        );
      }
    }
    if (current != null) {
      clusters.add(current);
    }
    return clusters;
  }

  double? _extractValue(String line, String pattern) {
    final match = RegExp(pattern).firstMatch(line);
    if (match == null) return null;
    return double.tryParse(match.group(1) ?? '');
  }

  PersonaAssignment _derivePersona(_ClusterData cluster) {
    String persona;
    double clarity;
    final engagement = cluster.centroidEngagement;
    final duration = cluster.centroidDuration;
    final sessions = cluster.centroidSessions;

    if (engagement >= 0.6 && duration >= 0.5) {
      persona = 'coach';
      clarity = 0.95;
    } else if (sessions >= 0.6) {
      persona = 'mentor';
      clarity = 0.92;
    } else {
      persona = 'challenger';
      clarity = 0.9;
    }
    final tone = persona == 'coach'
        ? 'Empathetic guidance with actionable nudges'
        : persona == 'mentor'
        ? 'Supportive storytelling rooted in mastery goals'
        : 'High-energy prompts with competitive framing';
    return PersonaAssignment(
      clusterName: cluster.name,
      persona: persona,
      sampleSize: cluster.size,
      tone: tone,
      clarity: clarity * 100,
      weight: cluster.size.toDouble(),
    );
  }
}

class AiPersonaRefinementResult {
  const AiPersonaRefinementResult({
    required this.personas,
    required this.toneWeights,
    required this.toneConsistency,
    required this.statsProfile,
  });

  final List<PersonaAssignment> personas;
  final Map<String, double> toneWeights;
  final double toneConsistency;
  final Map<String, _StatProfile> statsProfile;
}

class PersonaAssignment {
  const PersonaAssignment({
    required this.clusterName,
    required this.persona,
    required this.sampleSize,
    required this.tone,
    required this.clarity,
    required this.weight,
  });

  final String clusterName;
  final String persona;
  final int sampleSize;
  final String tone;
  final double clarity;
  final double weight;
}

class _StatProfile {
  const _StatProfile({required this.progress, required this.rank});

  final double progress;
  final String rank;
}

class _ClusterData {
  const _ClusterData({
    required this.name,
    required this.size,
    required this.centroidSessions,
    required this.centroidDuration,
    required this.centroidEngagement,
  });

  final String name;
  final int size;
  final double centroidSessions;
  final double centroidDuration;
  final double centroidEngagement;

  _ClusterData copyWith({
    double? centroidSessions,
    double? centroidDuration,
    double? centroidEngagement,
  }) {
    return _ClusterData(
      name: name,
      size: size,
      centroidSessions: centroidSessions ?? this.centroidSessions,
      centroidDuration: centroidDuration ?? this.centroidDuration,
      centroidEngagement: centroidEngagement ?? this.centroidEngagement,
    );
  }
}
