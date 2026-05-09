import 'dart:convert';
import 'dart:io';

class StabilityDomain {
  StabilityDomain({
    required this.key,
    required this.path,
    required this.requiredKeys,
  });

  final String key;
  final String path;
  final List<String> requiredKeys;
}

class StabilitySnapshot {
  StabilitySnapshot({
    required this.domains,
    required this.stale,
    required this.missing,
  });

  final Map<String, bool> domains;
  final List<String> stale;
  final List<String> missing;
}

class StabilityQaBridgeService {
  const StabilityQaBridgeService();

  static final _domains = [
    StabilityDomain(
      key: 'synthesis',
      path: 'release/_reports/high_order_synthesis_summary.json',
      requiredKeys: ['verdict', 'high_order_synthesis_index', 'generated_at'],
    ),
    StabilityDomain(
      key: 'cohesion',
      path: 'release/_reports/content_cohesion_summary.json',
      requiredKeys: ['modules', 'verdict', 'generated_at'],
    ),
    StabilityDomain(
      key: 'gaps',
      path: 'release/_reports/content_gap_summary.json',
      requiredKeys: ['modules', 'generated_at'],
    ),
    StabilityDomain(
      key: 'review',
      path: 'release/_reports/review_loop_integrator_summary.json',
      requiredKeys: ['bundles', 'generated_at'],
    ),
    StabilityDomain(
      key: 'reinforcement',
      path: 'release/_reports/reinforcement_planner_summary.json',
      requiredKeys: ['plans', 'generated_at'],
    ),
    StabilityDomain(
      key: 'router',
      path: 'release/_reports/adaptive_content_router_summary.json',
      requiredKeys: ['groups', 'generated_at'],
    ),
    StabilityDomain(
      key: 'planner',
      path: 'release/_reports/planner_bridge_summary.json',
      requiredKeys: ['groups', 'generated_at'],
    ),
    StabilityDomain(
      key: 'harness',
      path: 'release/_reports/adaptive_plan_harness_summary.json',
      requiredKeys: ['groups', 'generated_at'],
    ),
  ];

  Future<StabilitySnapshot> snapshot() async {
    final domainsStatus = <String, bool>{};
    final stale = <String>[];
    final missing = <String>[];
    final now = DateTime.now().toUtc();
    for (final domain in _domains) {
      try {
        final file = File(domain.path);
        if (!await file.exists()) {
          domainsStatus[domain.key] = false;
          missing.add(domain.path);
          continue;
        }
        final bytes = await file.readAsBytes();
        if (!_isAscii(bytes)) throw StateError('Non-ASCII ${domain.path}');
        final decoded = json.decode(utf8.decode(bytes));
        if (decoded is! Map<String, Object?>)
          throw StateError('Not object ${domain.path}');
        for (final key in domain.requiredKeys) {
          if (!decoded.containsKey(key)) {
            domainsStatus[domain.key] = false;
            throw StateError('Missing key $key in ${domain.path}');
          }
        }
        final timestamp = _parseTimestamp(decoded);
        if (timestamp == null ||
            now.difference(timestamp) > const Duration(hours: 24)) {
          stale.add(domain.path);
          domainsStatus[domain.key] = false;
          continue;
        }
        domainsStatus[domain.key] = true;
      } catch (_) {
        domainsStatus[domain.key] = domainsStatus[domain.key] ?? false;
      }
    }
    return StabilitySnapshot(
      domains: domainsStatus,
      stale: stale,
      missing: missing,
    );
  }

  DateTime? _parseTimestamp(Map<String, Object?> decoded) {
    final field =
        decoded['generated_at'] as String? ??
        decoded['generated'] as String? ??
        decoded['timestamp'] as String?;
    if (field == null) return null;
    return DateTime.tryParse(field)?.toUtc();
  }

  bool _isAscii(List<int> bytes) => bytes.every((b) => b >= 0 && b <= 127);
}
