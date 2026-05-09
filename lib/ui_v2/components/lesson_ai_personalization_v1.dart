class LessonLeakTracker {
  LessonLeakTracker({
    this.windowSize = 24,
    this.threshold = 3,
    this.cooldownDecisions = 12,
  });

  final int windowSize;
  final int threshold;
  final int cooldownDecisions;

  int _seqIndex = 0;
  int _cooldownRemaining = 0;
  final List<_LessonDecision> _history = [];

  String? registerDecision({required bool isCorrect, String? errorClass}) {
    if (_cooldownRemaining > 0) {
      _cooldownRemaining -= 1;
    }
    final record = _LessonDecision(
      isCorrect: isCorrect,
      errorClass: errorClass,
      seqIndex: _seqIndex,
    );
    _seqIndex += 1;
    _history.add(record);
    if (_history.length > windowSize) {
      _history.removeAt(0);
    }
    if (isCorrect) return null;
    final dominant = _dominantLeakKey();
    if (dominant == null) return null;
    if (_cooldownRemaining > 0) return null;
    _cooldownRemaining = cooldownDecisions;
    return dominant;
  }

  String? summaryLeakKey() => _dominantLeakKey();

  void reset() {
    _history.clear();
    _seqIndex = 0;
    _cooldownRemaining = 0;
  }

  String? _dominantLeakKey() {
    if (_history.isEmpty) return null;
    final counts = <String, int>{};
    final lastIndex = <String, int>{};
    for (final entry in _history) {
      final key = entry.errorClass;
      if (key == null) continue;
      counts[key] = (counts[key] ?? 0) + 1;
      lastIndex[key] = entry.seqIndex;
    }
    if (counts.isEmpty) return null;
    var maxCount = 0;
    for (final count in counts.values) {
      if (count > maxCount) {
        maxCount = count;
      }
    }
    if (maxCount < threshold) return null;
    final candidates = counts.entries
        .where((entry) => entry.value == maxCount)
        .map((entry) => entry.key)
        .toList();
    if (candidates.length == 1) return candidates.first;
    var bestKey = candidates.first;
    for (final key in candidates.skip(1)) {
      final bestIndex = lastIndex[bestKey] ?? -1;
      final keyIndex = lastIndex[key] ?? -1;
      if (keyIndex > bestIndex) {
        bestKey = key;
        continue;
      }
      if (keyIndex < bestIndex) {
        continue;
      }
      if (_stableOrderIndex(key) < _stableOrderIndex(bestKey)) {
        bestKey = key;
      }
    }
    return bestKey;
  }

  int _stableOrderIndex(String key) {
    final index = _stableLeakOrder.indexOf(key);
    if (index == -1) return _stableLeakOrder.length + key.hashCode;
    return index;
  }
}

class LessonLeakLabels {
  static const Map<String, _LeakLabel> _labels = {
    'range': _LeakLabel(en: 'Range advantage', ru: 'Range preimushchestvo'),
    'board': _LeakLabel(en: 'Board texture', ru: 'Tekstura doski'),
    'position': _LeakLabel(en: 'Position', ru: 'Pozitsiya'),
    'sizing': _LeakLabel(en: 'Sizing', ru: 'Razmer stavki'),
    'blocker': _LeakLabel(en: 'Blockers', ru: 'Blokery'),
    'value': _LeakLabel(en: 'Value', ru: 'Valyu'),
    'bluff': _LeakLabel(en: 'Bluffing', ru: 'Blaf'),
    'discipline': _LeakLabel(en: 'Discipline', ru: 'Disiplina'),
    'timing': _LeakLabel(en: 'Timing', ru: 'Timing'),
    'general': _LeakLabel(en: 'Decision quality', ru: 'Kachestvo resheniy'),
  };

  static String labelFor(String key, {required bool isRu}) {
    final label = _labels[key] ?? _labels['general']!;
    return label.en;
  }

  static String patternLine(String key, {required bool isRu}) {
    final label = _normalizeLabel(labelFor(key, isRu: isRu));
    // AI Personalization v1: EN-only (localization deferred to Localization Core stage).
    return 'Pattern: repeated $label.';
  }

  static String summaryLine(String key, {required bool isRu}) {
    final label = _normalizeLabel(labelFor(key, isRu: isRu));
    return 'Main leak: $label.';
  }

  static String nudgeLine(String key) {
    final label = _normalizeLabel(labelFor(key, isRu: false));
    return 'Focus for next hands: $label.';
  }

  static String _normalizeLabel(String label) => label.toLowerCase();
}

class _LessonDecision {
  const _LessonDecision({
    required this.isCorrect,
    required this.errorClass,
    required this.seqIndex,
  });

  final bool isCorrect;
  final String? errorClass;
  final int seqIndex;
}

class _LeakLabel {
  const _LeakLabel({required this.en, required this.ru});

  final String en;
  final String ru;
}

// AI Personalization v1.x: closed (next changes require new phase decision).
// Next Phase: started (implementation gated by future prompts).
const List<String> _stableLeakOrder = <String>[
  'range',
  'board',
  'position',
  'sizing',
  'blocker',
  'value',
  'bluff',
  'discipline',
  'timing',
  'general',
];
