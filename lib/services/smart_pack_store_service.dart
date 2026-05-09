import 'dart:convert';
import 'dart:io';

const String _expandedRoot = 'content_adaptive_expanded';
const String _reportsDir = 'release/_reports';
const String _personaSummaryPath =
    '$_reportsDir/ai_persona_refinement_summary.json';

class SmartPackStoreService {
  Future<SmartPackStoreResult> buildStorefront() async {
    final packs = await _scanExpandedPacks();
    final personas = await _loadPersonaClusters();

    final clusterAssignments = <ClusterPack>[];
    double totalEv = 0;
    int evCount = 0;

    for (final cluster in personas) {
      final eligible = packs.where((pack) => pack.evUplift >= 1.09).toList()
        ..sort((a, b) => b.evUplift.compareTo(a.evUplift));
      if (eligible.isNotEmpty) {
        clusterAssignments.add(
          ClusterPack(
            clusterName: cluster.cluster,
            persona: cluster.persona,
            packs: eligible.take(5).toList(),
          ),
        );
      } else {
        clusterAssignments.add(
          ClusterPack(
            clusterName: cluster.cluster,
            persona: cluster.persona,
            packs: const [],
          ),
        );
      }
    }

    for (final pack in packs) {
      totalEv += pack.evUplift;
      evCount++;
    }

    final averageEv = evCount == 0 ? 1.0 : totalEv / evCount;
    final coveredClusters = clusterAssignments
        .where((entry) => entry.packs.isNotEmpty)
        .length;
    final coverageRatio = personas.isEmpty
        ? 1.0
        : coveredClusters / personas.length;

    return SmartPackStoreResult(
      clusters: clusterAssignments,
      coverageRatio: coverageRatio,
      averageEv: averageEv,
      totalPacks: packs.length,
    );
  }

  Future<List<_ExpandedPack>> _scanExpandedPacks() async {
    final root = Directory(_expandedRoot);
    if (!await root.exists()) return const [];
    final packs = <_ExpandedPack>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.jsonl')) continue;
      final segments = entity.uri.pathSegments;
      final idx = segments.indexOf('content_adaptive_expanded');
      if (idx < 0 || idx + 2 >= segments.length) continue;
      final topic = segments[idx + 1];
      try {
        final lines = await entity.readAsLines();
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final decoded = json.decode(line);
          if (decoded is Map<String, Object?>) {
            final evScore = (decoded['ev_score'] as num?)?.toDouble() ?? 1.0;
            final difficulty =
                (decoded['difficulty'] as num?)?.toDouble() ?? 0.5;
            final resonance =
                (decoded['resonance_weight'] as num?)?.toDouble() ?? 1.0;
            packs.add(
              _ExpandedPack(
                topic: topic,
                evUplift: evScore,
                difficulty: difficulty,
                resonance: resonance,
                path: entity.path,
              ),
            );
          }
        }
      } catch (_) {
        continue;
      }
    }
    return packs;
  }

  Future<List<_PersonaCluster>> _loadPersonaClusters() async {
    final file = File(_personaSummaryPath);
    if (!await file.exists()) return const [];
    try {
      final Map<String, Object?> decoded =
          json.decode(await file.readAsString()) as Map<String, Object?>;
      final raw = decoded['personas'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map(
            (entry) => _PersonaCluster(
              cluster: entry['cluster']?.toString() ?? 'unknown',
              persona: entry['persona']?.toString() ?? '',
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

class SmartPackStoreResult {
  const SmartPackStoreResult({
    required this.clusters,
    required this.coverageRatio,
    required this.averageEv,
    required this.totalPacks,
  });

  final List<ClusterPack> clusters;
  final double coverageRatio;
  final double averageEv;
  final int totalPacks;
}

class ClusterPack {
  const ClusterPack({
    required this.clusterName,
    required this.persona,
    required this.packs,
  });

  final String clusterName;
  final String persona;
  final List<_ExpandedPack> packs;
}

class _ExpandedPack {
  const _ExpandedPack({
    required this.topic,
    required this.evUplift,
    required this.difficulty,
    required this.resonance,
    required this.path,
  });

  final String topic;
  final double evUplift;
  final double difficulty;
  final double resonance;
  final String path;
}

class _PersonaCluster {
  const _PersonaCluster({required this.cluster, required this.persona});

  final String cluster;
  final String persona;
}
