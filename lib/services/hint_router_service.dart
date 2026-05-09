import 'dart:convert';
import 'dart:io';

class HintRouterException implements IOException {
  const HintRouterException(this.message);

  final String message;

  @override
  String toString() => 'HintRouterException: $message';
}

class HintRoutingBundle {
  HintRoutingBundle({
    required this.tier,
    required this.placementCandidates,
    required this.toneRules,
    required this.layoutFocus,
    required this.timestamp,
  });

  final String tier;
  final Map<String, bool> placementCandidates;
  final Map<String, Object?> toneRules;
  final List<String> layoutFocus;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'tier': tier,
    'placement_candidates': placementCandidates,
    'tone_rules': toneRules,
    'layout_focus': layoutFocus,
    'timestamp': timestamp.toIso8601String(),
  };
}

class HintRouterService {
  const HintRouterService();

  static const _inputPath = 'release/_reports/hint_orchestration_bundle.json';

  Future<HintRoutingBundle> build() async {
    final data = await _loadAsciiJson(_inputPath);

    final hintEnergy = _extractDouble(data['hint_energy']);
    final hintDepth = _extractDouble(data['hint_depth']);
    final recommended = _extractStringList(data['recommended_hint_types']);
    final toneRules = _extractToneRules(data);
    final layoutFocus = _extractLayoutFocus(data);

    final tier = _computeTier(hintEnergy);
    final placement = _buildPlacementCandidates(hintDepth, recommended);

    return HintRoutingBundle(
      tier: tier,
      placementCandidates: placement,
      toneRules: toneRules,
      layoutFocus: layoutFocus,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw HintRouterException('Missing hint orchestration bundle at $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw HintRouterException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw HintRouterException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  double _extractDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, bool> _buildPlacementCandidates(
    double depth,
    List<String> types,
  ) {
    final normalized = types.map((type) => type.toLowerCase()).toSet();
    return {
      'visual': depth > 0.4 && normalized.contains('visual'),
      'learning': depth > 0.3 && normalized.contains('learning'),
      'brief': normalized.contains('brief'),
    };
  }

  String _computeTier(double energy) {
    if (energy >= 0.7) return 'high';
    if (energy >= 0.4) return 'medium';
    return 'low';
  }

  Map<String, Object?> _extractToneRules(Map<String, Object?> data) {
    final tone = data['tone_rules'];
    if (tone is! Map<String, Object?>) {
      throw HintRouterException('Missing tone rules');
    }
    return tone;
  }

  List<String> _extractLayoutFocus(Map<String, Object?> data) {
    final focus = data['layout_focus'];
    if (focus is! List) {
      throw HintRouterException('Missing layout focus');
    }
    return focus.whereType<String>().toList();
  }

  List<String> _extractStringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }
}
