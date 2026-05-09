import 'dart:convert';
import 'dart:io';

class ExplanationRoutingException implements IOException {
  const ExplanationRoutingException(this.message);

  final String message;

  @override
  String toString() => 'ExplanationRoutingException: $message';
}

class ExplanationRoutingBundle {
  ExplanationRoutingBundle({
    required this.routingOrder,
    required this.routingMap,
    required this.triggers,
    required this.summary,
    required this.timestamp,
  });

  final List<String> routingOrder;
  final Map<String, Object?> routingMap;
  final Map<String, List<String>> triggers;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'routing_order': routingOrder,
    'routing_map': routingMap,
    'triggers': triggers,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ExplanationRoutingService {
  const ExplanationRoutingService();

  static const _inputPath = 'release/_reports/player_profile_screen_spec.json';

  Future<ExplanationRoutingBundle> build() async {
    final spec = await _loadAsciiJson(_inputPath);

    final sections = _extractMap(spec['sections']);
    final summary = _extractMap(spec['summary']);

    final header =
        sections['header_section']?.toString() ?? 'Header section unavailable.';
    final hint =
        sections['hint_section']?.toString() ?? 'Hint section unavailable.';
    final training =
        sections['training_section']?.toString() ??
        'Training section unavailable.';
    final focus =
        (sections['focus_section'] as List?)?.whereType<String>().toList() ??
        const [];
    final suggestions =
        (sections['suggestions_section'] as List?)
            ?.whereType<String>()
            .toList() ??
        const [];

    final routingOrder = ['header', 'hint', 'training', 'focus', 'suggestions'];
    final routingMap = {
      'header': {'content': header, 'priority': 1},
      'hint': {'content': hint, 'priority': 2},
      'training': {'content': training, 'priority': 3},
      'focus': {'content': focus, 'priority': 4},
      'suggestions': {'content': suggestions, 'priority': 5},
    };
    final triggers = {
      'on_profile_open': ['header'],
      'after_summary_scroll': ['hint', 'training'],
      'on_focus_tap': ['focus', 'suggestions'],
    };

    return ExplanationRoutingBundle(
      routingOrder: routingOrder,
      routingMap: routingMap,
      triggers: triggers,
      summary: {'module_count': summary['module_count'] ?? 0},
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw ExplanationRoutingException('Missing spec $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw ExplanationRoutingException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw ExplanationRoutingException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  Map<String, Object?> _extractMap(Object? value) =>
      value is Map<String, Object?> ? value : const {};
}
