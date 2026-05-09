import 'dart:convert';
import 'dart:io';

class VisualCohesionSummary {
  VisualCohesionSummary({
    required this.domains,
    required this.stale,
    required this.missing,
    required this.failDomainCount,
    required this.visualRiskScore,
  });

  final Map<String, bool> domains;
  final List<String> stale;
  final List<String> missing;
  final int failDomainCount;
  final double visualRiskScore;
}

class VisualCohesionProbeService {
  const VisualCohesionProbeService();

  Future<VisualCohesionSummary> analyze() async {
    final file = File('release/_reports/stability_snapshot_summary.json');
    if (!await file.exists()) {
      throw StateError('Missing stability snapshot');
    }
    final bytes = await file.readAsBytes();
    if (!_isAscii(bytes)) throw StateError('Non-ASCII snapshot');
    final decoded = json.decode(utf8.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw StateError('Snapshot must be JSON object');
    }
    final domains = <String, bool>{};
    final rawDomains = decoded['domains'];
    if (rawDomains is Map<String, Object?>) {
      rawDomains.forEach((key, value) {
        domains[key] = (value as bool?) ?? false;
      });
    } else {
      throw StateError('Missing domains map');
    }
    final stale = (decoded['stale'] as List<dynamic>?)?.cast<String>() ?? [];
    final missing =
        (decoded['missing'] as List<dynamic>?)?.cast<String>() ?? [];
    final failCount = domains.values.where((pass) => !pass).length;
    final risk =
        ((stale.length * 0.4) + (missing.length * 0.4) + (failCount * 0.2))
            .clamp(0.0, 1.0);
    return VisualCohesionSummary(
      domains: domains,
      stale: stale,
      missing: missing,
      failDomainCount: failCount,
      visualRiskScore: risk,
    );
  }

  bool _isAscii(List<int> bytes) => bytes.every((b) => b >= 0 && b <= 127);
}
