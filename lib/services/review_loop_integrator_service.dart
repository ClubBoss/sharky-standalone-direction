import 'dart:convert';
import 'dart:io';

class ReviewSuggestionBundle {
  ReviewSuggestionBundle({
    required this.module,
    required this.cohesionScore,
    required this.gapWarnings,
    required this.highOrderFlags,
    required this.priorityScore,
  });

  final String module;
  final double cohesionScore;
  final List<String> gapWarnings;
  final List<String> highOrderFlags;
  final double priorityScore;

  Map<String, Object?> toJson() => {
    'module': module,
    'cohesion_score': cohesionScore,
    'gap_warnings': gapWarnings,
    'high_order_flags': highOrderFlags,
    'priority_score': priorityScore,
  };
}

class ReviewLoopIntegratorService {
  const ReviewLoopIntegratorService();

  Future<List<ReviewSuggestionBundle>> integrate() async {
    final cohesion = await _loadJson(
      'release/_reports/content_cohesion_summary.json',
    );
    final gap = await _loadJson('release/_reports/content_gap_summary.json');
    final highOrder = await _loadJson(
      'release/_reports/high_order_synthesis_summary.json',
    );

    final cohesionMap = <String, double>{};
    if (cohesion['modules'] is List) {
      for (final entry in cohesion['modules'] as List) {
        if (entry is Map && entry['module'] is String) {
          final score = _toDouble(entry['cohesion_score']) ?? 0.0;
          cohesionMap[entry['module'] as String] = score.clamp(0.0, 1.0);
        }
      }
    }

    final gapModules = <Map<String, dynamic>>[];
    if (gap['modules'] is List) {
      for (final entry in gap['modules'] as List) {
        if (entry is Map<String, dynamic> && entry['module'] is String) {
          gapModules.add(entry);
        }
      }
    }

    final highOrderFlags = <String>[];
    final highOrderVerdict = ((highOrder['verdict'] as String?) ?? '')
        .toUpperCase();
    final highOrderPass = highOrderVerdict == 'PASS';
    highOrderFlags.add(highOrderPass ? 'HIGH_ORDER_PASS' : 'HIGH_ORDER_FAIL');
    final highOrderPenalty = highOrderPass ? 0.0 : 1.0;

    final bundles = <ReviewSuggestionBundle>[];
    for (final moduleEntry in gapModules) {
      final moduleName = moduleEntry['module'] as String;
      final missingConcepts =
          (moduleEntry['missing_concepts'] as List?)?.cast<String>() ?? [];
      final densityWarnings =
          (moduleEntry['density_warnings'] as List?)?.cast<String>() ?? [];
      final cohesionScore = cohesionMap[moduleName] ?? 0.0;
      final gapWarnings = <String>[]
        ..addAll(missingConcepts)
        ..addAll(densityWarnings);
      final priorityScore =
          ((_oneMinus(cohesionScore)) * 0.4) +
          (min1(gapWarnings.length / 5) * 0.35) +
          (highOrderPenalty * 0.25);
      bundles.add(
        ReviewSuggestionBundle(
          module: moduleName,
          cohesionScore: cohesionScore,
          gapWarnings: gapWarnings,
          highOrderFlags: List.from(highOrderFlags),
          priorityScore: priorityScore.clamp(0.0, 1.0),
        ),
      );
    }

    return bundles;
  }

  double _oneMinus(double value) => (1.0 - value).clamp(0.0, 1.0);

  double min1(double value) => value < 1.0 ? value : 1.0;

  Future<Map<String, Object?>> _loadJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing report: $path');
    }
    final content = await file.readAsBytes();
    if (!_isAscii(content)) {
      throw StateError('Non-ASCII content: $path');
    }
    try {
      final decoded = json.decode(utf8.decode(content));
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
      throw StateError('Report not a JSON object: $path');
    } catch (error) {
      throw StateError('Invalid JSON ($path): $error');
    }
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool _isAscii(List<int> bytes) {
    return bytes.every((b) => b <= 127);
  }
}
