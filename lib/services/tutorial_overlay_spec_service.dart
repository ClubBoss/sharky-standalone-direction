import 'dart:convert';
import 'dart:io';

class TutorialOverlaySpecException implements IOException {
  const TutorialOverlaySpecException(this.message);

  final String message;

  @override
  String toString() => 'TutorialOverlaySpecException: $message';
}

class TutorialOverlaySpec {
  TutorialOverlaySpec({
    required this.overlayFlow,
    required this.summary,
    required this.timestamp,
  });

  final Map<String, Object?> overlayFlow;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'overlay_flow': overlayFlow,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class TutorialOverlaySpecService {
  const TutorialOverlaySpecService();

  static const _inputPath = 'release/_reports/explanation_routing_bundle.json';

  Future<TutorialOverlaySpec> build() async {
    final bundle = await _loadAsciiJson(_inputPath);

    final routingMap = _extractMap(bundle['routing_map']);
    final triggers = _extractMap(bundle['triggers']);
    final summary = _extractMap(bundle['summary']);

    final overlayFlow = {
      'steps': [
        _buildStep('header', routingMap['header'], triggers['on_profile_open']),
        _buildStep(
          'hint',
          routingMap['hint'],
          triggers['after_summary_scroll'],
        ),
        _buildStep(
          'training',
          routingMap['training'],
          triggers['after_summary_scroll'],
        ),
        _buildStep('focus', routingMap['focus'], triggers['on_focus_tap']),
        _buildStep(
          'suggestions',
          routingMap['suggestions'],
          triggers['on_focus_tap'],
        ),
      ],
    };

    return TutorialOverlaySpec(
      overlayFlow: overlayFlow,
      summary: {'module_count': summary['module_count'] ?? 0},
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw TutorialOverlaySpecException('Missing bundle $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw TutorialOverlaySpecException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw TutorialOverlaySpecException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  Map<String, Object?> _buildStep(String id, Object? content, Object? trigger) {
    return {'id': id, 'content': content, 'trigger': trigger};
  }

  Map<String, Object?> _extractMap(Object? value) =>
      value is Map<String, Object?> ? value : const {};
}
