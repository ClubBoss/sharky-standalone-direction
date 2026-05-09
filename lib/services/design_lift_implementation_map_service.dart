import 'dart:convert';
import 'dart:io';

class DesignLiftImplementationMapException implements IOException {
  const DesignLiftImplementationMapException(this.message);

  final String message;

  @override
  String toString() => 'DesignLiftImplementationMapException: $message';
}

class DesignLiftImplementationMapBundle {
  DesignLiftImplementationMapBundle({
    required this.replacementTargets,
    required this.fileTargets,
    required this.layoutTargets,
    required this.styleTargets,
    required this.visualRules,
    required this.timestamp,
  });

  final List<String> replacementTargets;
  final List<String> fileTargets;
  final List<String> layoutTargets;
  final List<String> styleTargets;
  final Map<String, Object?> visualRules;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'replacement_targets': replacementTargets,
    'file_targets': fileTargets,
    'layout_targets': layoutTargets,
    'style_targets': styleTargets,
    'visual_rules': visualRules,
    'timestamp': timestamp.toIso8601String(),
  };
}

class DesignLiftImplementationMapService {
  const DesignLiftImplementationMapService();

  static const _inputPath = 'release/_reports/component_library_bundle.json';

  Future<DesignLiftImplementationMapBundle> build() async {
    final data = await _loadAsciiJson(_inputPath);

    final patterns = _extractMap(data['patterns']);
    final consolidation = _extractMap(data['consolidation_notes']);
    final visualRules = _extractMap(data['visual_rules']);

    final replacementTargets = patterns.keys.toList();
    final fileTargets = replacementTargets
        .map((name) => 'lib/widgets/${name}_template.dart')
        .toList();
    final deprecated = _extractList(consolidation['deprecated']);
    final conflictList = _extractList(consolidation['conflicts']);
    final layoutTargets = [
      ...patterns.entries.map(
        (entry) => '${entry.key}:${_describeLayout(entry.value)}',
      ),
      ...deprecated,
    ];
    final styleTargets = [
      ...visualRules.keys,
      ...conflictList,
    ].whereType<String>().toList();

    return DesignLiftImplementationMapBundle(
      replacementTargets: replacementTargets,
      fileTargets: fileTargets,
      layoutTargets: layoutTargets,
      styleTargets: styleTargets,
      visualRules: visualRules,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw DesignLiftImplementationMapException('Missing bundle $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw DesignLiftImplementationMapException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw DesignLiftImplementationMapException(
        'Invalid JSON structure in $path',
      );
    }
    return decoded;
  }

  Map<String, Object?> _extractMap(Object? value) {
    if (value is Map<String, Object?>) return value;
    return const {};
  }

  String _describeLayout(Object? value) {
    if (value is Map<String, Object?>) {
      return value.entries
          .map((entry) => '${entry.key}:${entry.value}')
          .join(',');
    }
    return value?.toString() ?? 'default';
  }

  List<String> _extractList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }
}
