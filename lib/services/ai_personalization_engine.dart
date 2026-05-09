import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _statsProfilePath = '$_reportsDir/player_stats_profile.json';
const String _traitsProfilePath = '$_reportsDir/player_traits_profile.json';
const String _summaryPath = '$_reportsDir/ai_personalization_summary.txt';
const String _telemetryOutPath = '$_reportsDir/telemetry.jsonl';

const int _minSampleSize = 100;
const int _maxIterations = 30;

Future<void> main(List<String> args) async {
  final engine = AiPersonalizationEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AiPersonalizationEngine {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final samples = await _loadUserSamples();
    if (samples.length < _minSampleSize) {
      stderr.writeln(
        'Insufficient telemetry sample (${samples.length}). Need >= $_minSampleSize.',
      );
      return false;
    }

    final statsProfile = await _loadStatsProfile();
    final traits = await _loadTraitsProfile();

    final k = _suggestClusterCount(samples.length);
    final kMeans = _KMeans(k, samples.map((s) => s.vector).toList());
    final result = kMeans.run(maxIterations: _maxIterations);
    if (!result.converged) {
      stderr.writeln(
        'Clustering did not converge within $_maxIterations iterations.',
      );
      return false;
    }

    final clusters = _buildClusterInsights(
      samples: samples,
      assignments: result.assignments,
      centroids: result.centroids,
      statsProfile: statsProfile,
      traits: traits,
    );

    final summary = _buildSummary(
      clusters: clusters,
      sampleSize: samples.length,
      iterations: result.iterations,
    );

    await _withReportsWritable(() async {
      await File(_summaryPath).writeAsString(summary);
      await _appendTelemetry(
        clusters: clusters,
        sampleSize: samples.length,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    return true;
  }

  Future<List<_UserSample>> _loadUserSamples() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      throw StateError('Telemetry stream missing at $_telemetryPath');
    }
    final sessionStarts = <String, DateTime>{};
    final userFeatures = <String, _UserFeatures>{};
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      Map<String, Object?> decoded;
      try {
        decoded = json.decode(line) as Map<String, Object?>;
      } catch (_) {
        continue;
      }
      final event = decoded['event']?.toString() ?? '';
      if (!_telemetryEvents.contains(event)) continue;
      final userId = decoded['user_id']?.toString();
      if (userId == null || userId.isEmpty) continue;
      final features = userFeatures.putIfAbsent(userId, _UserFeatures.new);
      switch (event) {
        case 'session_start':
          final sessionId = decoded['session_id']?.toString();
          final timestamp = _safeParseDate(decoded['timestamp']);
          if (sessionId != null && timestamp != null) {
            sessionStarts[sessionId] = timestamp;
          }
          features.sessionStarts++;
          break;
        case 'session_end':
          final sessionId = decoded['session_id']?.toString();
          final timestamp = _safeParseDate(decoded['timestamp']);
          if (sessionId != null && timestamp != null) {
            final start = sessionStarts.remove(sessionId);
            if (start != null) {
              final duration = timestamp.difference(start).inSeconds;
              if (duration > 0) {
                features.totalSessionSeconds += duration;
              }
            }
          }
          features.sessionEnds++;
          break;
        case 'lesson_open':
          features.lessonOpens++;
          break;
        case 'quiz_complete':
          features.quizCompletes++;
          break;
        case 'recap_view':
          features.recapViews++;
          break;
      }
    }

    final samples = <_UserSample>[];
    var maxSessions = 1;
    var maxDuration = 1.0;
    var maxEngagement = 1;
    userFeatures.forEach((id, features) {
      maxSessions = max(maxSessions, features.sessionCount);
      maxDuration = max(maxDuration, features.averageSessionSeconds.toDouble());
      maxEngagement = max(maxEngagement, features.engagementActions);
    });

    userFeatures.forEach((id, features) {
      final sessionNorm = features.sessionCount / maxSessions;
      final durationNorm =
          features.averageSessionSeconds / (maxDuration == 0 ? 1 : maxDuration);
      final engagementNorm =
          features.engagementActions / (maxEngagement == 0 ? 1 : maxEngagement);
      samples.add(
        _UserSample(
          userId: id,
          features: features,
          vector: [sessionNorm, durationNorm, engagementNorm],
        ),
      );
    });

    return samples;
  }

  int _suggestClusterCount(int sampleSize) {
    if (sampleSize >= 400) return 4;
    if (sampleSize >= 200) return 3;
    return 2;
  }

  Future<Map<String, _StatProfile>> _loadStatsProfile() async {
    final file = File(_statsProfilePath);
    if (!await file.exists()) return {};
    try {
      final Map<String, dynamic> decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final result = <String, _StatProfile>{};
      decoded.forEach((key, value) {
        final map = value is Map ? value.cast<String, Object?>() : {};
        final progress = (map['progress_0_1'] as num?)?.toDouble() ?? 0.5;
        final xp = (map['xp'] as num?)?.toDouble() ?? 0;
        result[key] = _StatProfile(
          id: key,
          rank: map['rank']?.toString() ?? 'Novice',
          progress: progress.clamp(0, 1),
          xp: xp,
        );
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<List<String>> _loadTraitsProfile() async {
    final file = File(_traitsProfilePath);
    if (!await file.exists()) return const [];
    try {
      final Map<String, dynamic> decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final traits = decoded['traits'];
      if (traits is List) {
        return traits
            .whereType<Map>()
            .map((entry) => entry['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // ignore malformed traits
    }
    return const [];
  }

  List<_ClusterInsight> _buildClusterInsights({
    required List<_UserSample> samples,
    required List<int> assignments,
    required List<List<double>> centroids,
    required Map<String, _StatProfile> statsProfile,
    required List<String> traits,
  }) {
    final clusterMembers = <int, List<_UserSample>>{};
    for (var i = 0; i < assignments.length; i++) {
      clusterMembers.putIfAbsent(assignments[i], () => []).add(samples[i]);
    }
    final insights = <_ClusterInsight>[];
    clusterMembers.forEach((clusterIndex, members) {
      final centroid = centroids[clusterIndex];
      final avgSessions = _average(
        members.map((m) => m.features.sessionCount.toDouble()).toList(),
      );
      final avgDuration = _average(
        members
            .map((m) => m.features.averageSessionSeconds.toDouble())
            .toList(),
      );
      final avgEngagement = _average(
        members.map((m) => m.features.engagementActions.toDouble()).toList(),
      );
      final label = _generateClusterLabel(centroid);
      final weights = _generateContentWeights(
        centroid: centroid,
        statsProfile: statsProfile,
        traitNames: traits,
      );
      insights.add(
        _ClusterInsight(
          index: clusterIndex,
          label: label,
          memberCount: members.length,
          centroid: centroid,
          averageSessions: avgSessions,
          averageDurationSeconds: avgDuration,
          averageEngagementActions: avgEngagement,
          contentWeights: weights,
        ),
      );
    });
    insights.sort((a, b) => a.index.compareTo(b.index));
    return insights;
  }

  Map<String, double> _generateContentWeights({
    required List<double> centroid,
    required Map<String, _StatProfile> statsProfile,
    required List<String> traitNames,
  }) {
    final stats = statsProfile.isEmpty
        ? _defaultStatsPlaceholder()
        : statsProfile;
    final weights = <String, double>{};
    final engagementFactor = 0.8 + centroid[2];
    final sessionFactor = 0.8 + (1 - centroid[0]);
    final traitMultiplier = 1 + (0.05 * traitNames.length);

    stats.forEach((id, profile) {
      final need = (1 - profile.progress).clamp(0.1, 1.0);
      final xpFactor = profile.xp == 0 ? 1.0 : 1 / (1 + profile.xp / 500);
      final weight =
          need * engagementFactor * sessionFactor * xpFactor * traitMultiplier;
      weights[id] = weight;
    });

    final total = weights.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      final even = 1 / weights.length;
      return weights.map((key, _) => MapEntry(key, even));
    }
    return weights.map((key, value) => MapEntry(key, value / total));
  }

  Map<String, _StatProfile> _defaultStatsPlaceholder() {
    return {
      'fundamentals': const _StatProfile(
        id: 'fundamentals',
        rank: 'Novice',
        progress: 0.4,
        xp: 0,
      ),
      'advanced_lines': const _StatProfile(
        id: 'advanced_lines',
        rank: 'Novice',
        progress: 0.3,
        xp: 0,
      ),
      'mental_game': const _StatProfile(
        id: 'mental_game',
        rank: 'Novice',
        progress: 0.35,
        xp: 0,
      ),
    };
  }

  String _buildSummary({
    required List<_ClusterInsight> clusters,
    required int sampleSize,
    required int iterations,
  }) {
    final buffer = StringBuffer()
      ..writeln('AI PERSONALIZATION SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Sample size: $sampleSize users')
      ..writeln('Clusters: ${clusters.length}')
      ..writeln('Iterations: $iterations')
      ..writeln();
    for (final cluster in clusters) {
      buffer
        ..writeln(
          '- Cluster ${cluster.index + 1} "${cluster.label}" (size=${cluster.memberCount})',
        )
        ..writeln(
          '  Centroid: sessions=${cluster.centroid[0].toStringAsFixed(2)} '
          'duration=${cluster.centroid[1].toStringAsFixed(2)} '
          'engagement=${cluster.centroid[2].toStringAsFixed(2)}',
        )
        ..writeln(
          '  Averages: sessions=${cluster.averageSessions.toStringAsFixed(1)} '
          'avgDuration=${cluster.averageDurationSeconds.toStringAsFixed(1)}s '
          'engActions=${cluster.averageEngagementActions.toStringAsFixed(1)}',
        )
        ..writeln('  Content weights:');
      cluster.contentWeights.forEach((stat, weight) {
        buffer.writeln('    • $stat → ${(weight * 100).toStringAsFixed(1)}%');
      });
      buffer.writeln();
    }
    return buffer.toString();
  }

  Future<void> _appendTelemetry({
    required List<_ClusterInsight> clusters,
    required int sampleSize,
    required int durationMs,
  }) async {
    final payload = {
      'event': 'ai_personalization_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'sample_size': sampleSize,
      'clusters': clusters
          .map(
            (cluster) => {
              'label': cluster.label,
              'size': cluster.memberCount,
              'centroid': cluster.centroid,
              'content_weights': cluster.contentWeights,
            },
          )
          .toList(),
      'duration_ms': durationMs,
    };
    final sink = File(_telemetryOutPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

DateTime? _safeParseDate(Object? value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return null;
  }
}

double _average(List<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a + b) / values.length;
}

class _UserFeatures {
  int sessionStarts = 0;
  int sessionEnds = 0;
  int lessonOpens = 0;
  int quizCompletes = 0;
  int recapViews = 0;
  int totalSessionSeconds = 0;

  int get sessionCount => max(sessionStarts, sessionEnds);

  double get averageSessionSeconds {
    if (sessionCount == 0) return 0;
    return totalSessionSeconds / sessionCount;
  }

  int get engagementActions => lessonOpens + quizCompletes + recapViews;
}

class _UserSample {
  _UserSample({
    required this.userId,
    required this.features,
    required this.vector,
  });

  final String userId;
  final _UserFeatures features;
  final List<double> vector;
}

class _ClusterInsight {
  _ClusterInsight({
    required this.index,
    required this.label,
    required this.memberCount,
    required this.centroid,
    required this.averageSessions,
    required this.averageDurationSeconds,
    required this.averageEngagementActions,
    required this.contentWeights,
  });

  final int index;
  final String label;
  final int memberCount;
  final List<double> centroid;
  final double averageSessions;
  final double averageDurationSeconds;
  final double averageEngagementActions;
  final Map<String, double> contentWeights;
}

class _StatProfile {
  const _StatProfile({
    required this.id,
    required this.rank,
    required this.progress,
    required this.xp,
  });

  final String id;
  final String rank;
  final double progress;
  final double xp;
}

class _KMeansResult {
  _KMeansResult({
    required this.assignments,
    required this.centroids,
    required this.converged,
    required this.iterations,
  });

  final List<int> assignments;
  final List<List<double>> centroids;
  final bool converged;
  final int iterations;
}

class _KMeans {
  _KMeans(this.k, this.data);

  final int k;
  final List<List<double>> data;

  _KMeansResult run({required int maxIterations}) {
    if (data.isEmpty) {
      return _KMeansResult(
        assignments: const [],
        centroids: const [],
        converged: false,
        iterations: 0,
      );
    }
    final centroids = _initializeCentroids();
    final assignments = List<int>.filled(data.length, -1);
    var converged = false;
    var iteration = 0;
    for (; iteration < maxIterations; iteration++) {
      var changed = false;
      for (var i = 0; i < data.length; i++) {
        final newCluster = _nearestCentroid(data[i], centroids);
        if (assignments[i] != newCluster) {
          assignments[i] = newCluster;
          changed = true;
        }
      }
      if (!changed) {
        converged = true;
        break;
      }
      if (!_recomputeCentroids(assignments, centroids)) {
        converged = false;
        break;
      }
    }
    return _KMeansResult(
      assignments: assignments,
      centroids: centroids,
      converged: converged,
      iterations: iteration + 1,
    );
  }

  List<List<double>> _initializeCentroids() {
    final centroids = <List<double>>[];
    final step = (data.length / k).floor().clamp(1, data.length);
    for (var i = 0; i < k; i++) {
      final index = min(i * step, data.length - 1);
      centroids.add(List<double>.from(data[index]));
    }
    return centroids;
  }

  bool _recomputeCentroids(
    List<int> assignments,
    List<List<double>> centroids,
  ) {
    final sums = List.generate(
      k,
      (_) => List<double>.filled(data.first.length, 0),
    );
    final counts = List<int>.filled(k, 0);
    for (var i = 0; i < data.length; i++) {
      final cluster = assignments[i];
      if (cluster < 0 || cluster >= k) return false;
      counts[cluster]++;
      final vector = data[i];
      for (var j = 0; j < vector.length; j++) {
        sums[cluster][j] += vector[j];
      }
    }
    for (var cluster = 0; cluster < k; cluster++) {
      if (counts[cluster] == 0) {
        // reassign empty cluster to point with highest variance
        final targetIndex = _findLoneSample(assignments);
        if (targetIndex == null) return false;
        centroids[cluster] = List<double>.from(data[targetIndex]);
        continue;
      }
      for (var j = 0; j < centroids[cluster].length; j++) {
        centroids[cluster][j] = sums[cluster][j] / counts[cluster];
      }
    }
    return true;
  }

  int? _findLoneSample(List<int> assignments) {
    final counts = <int, int>{};
    for (final cluster in assignments) {
      counts[cluster] = (counts[cluster] ?? 0) + 1;
    }
    for (var i = 0; i < assignments.length; i++) {
      if (counts[assignments[i]] == 1) {
        return i;
      }
    }
    return assignments.isNotEmpty ? 0 : null;
  }

  int _nearestCentroid(List<double> vector, List<List<double>> centroids) {
    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < centroids.length; i++) {
      final distance = _euclideanDistance(vector, centroids[i]);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  double _euclideanDistance(List<double> a, List<double> b) {
    var sum = 0.0;
    for (var i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }
}

String _generateClusterLabel(List<double> centroid) {
  final session = centroid[0];
  final engagement = centroid[2];
  if (session >= 0.7 && engagement >= 0.7) {
    return 'immersive_pro';
  } else if (session >= 0.5 || engagement >= 0.5) {
    return 'steady_grinder';
  }
  return 'burst_learning';
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

const Set<String> _telemetryEvents = {
  'session_start',
  'session_end',
  'lesson_open',
  'quiz_complete',
  'recap_view',
};
