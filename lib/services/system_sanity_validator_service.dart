import 'dart:convert';
import 'dart:io';

class SystemSanityValidatorException implements IOException {
  const SystemSanityValidatorException(this.message);

  final String message;

  @override
  String toString() => 'SystemSanityValidatorException: $message';
}

class SystemSanityResult {
  SystemSanityResult({required this.invalidReports, required this.summary});

  final List<String> invalidReports;
  final Map<String, Object?> summary;
}

class SystemSanityValidatorService {
  const SystemSanityValidatorService();

  static const Map<String, List<String>> _requiredReports = {
    'release/_reports/stability_snapshot_v2.json': [
      'summary',
      'content_metrics',
    ],
    'release/_reports/planner_v2_plan.json': ['module_scores', 'routed_plan'],
    'release/_reports/explanation_routing_bundle.json': [
      'routing_order',
      'routing_map',
    ],
    'release/_reports/tutorial_overlay_spec.json': ['overlay_flow'],
    'release/_reports/component_library_bundle.json': ['patterns'],
    'release/_reports/visual_cohesion_v3.json': ['visual_cohesion_v3_index'],
    'release/_reports/content_cohesion_summary.json': ['modules'],
    'release/_reports/content_gap_summary.json': ['modules'],
  };

  Future<SystemSanityResult> validate() async {
    final invalid = <String>[];
    for (final entry in _requiredReports.entries) {
      final path = entry.key;
      final expectedKeys = entry.value;
      try {
        final bytes = await _readAsciiBytes(path);
        final decoded = json.decode(utf8.decode(bytes));
        if (decoded is! Map<String, Object?>) {
          throw SystemSanityValidatorException(
            'Invalid JSON structure at $path',
          );
        }
        for (final key in expectedKeys) {
          if (!decoded.containsKey(key)) {
            invalid.add(path);
            break;
          }
        }
      } on SystemSanityValidatorException catch (_) {
        invalid.add(path);
      } on FormatException catch (_) {
        invalid.add(path);
      } on FileSystemException {
        invalid.add(path);
      }
    }

    final sanityPass = invalid.isEmpty;
    final summary = {
      'sanity_pass': sanityPass,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return SystemSanityResult(invalidReports: invalid, summary: summary);
  }

  Future<List<int>> _readAsciiBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw SystemSanityValidatorException('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((byte) => byte > 127)) {
      throw SystemSanityValidatorException('Non-ASCII content in $path');
    }
    return bytes;
  }
}
