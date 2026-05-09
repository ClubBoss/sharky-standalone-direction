import 'dart:convert';

/// Passive structure checker for Tap-to-Explain v1.
class T2ECheckerV1 {
  const T2ECheckerV1({
    required this.theoryLines,
    required this.explanationLines,
  });

  final List<String> theoryLines;
  final List<String> explanationLines;

  Map<String, Object> analyze() {
    final List<Map<String, Object?>> explanations = _parse(explanationLines);
    final bool explanationsValidJson =
        explanations.length == explanationLines.length;
    final bool uniqueIds = _unique(explanations);
    return <String, Object>{
      'has_theory': theoryLines.isNotEmpty,
      'explanations_valid_json': explanationsValidJson,
      'unique_ids': uniqueIds,
    };
  }

  List<Map<String, Object?>> _parse(List<String> lines) {
    final List<Map<String, Object?>> parsed = <Map<String, Object?>>[];
    for (final String line in lines) {
      try {
        final dynamic value = jsonDecode(line);
        if (value is Map<String, Object?>) parsed.add(value);
      } catch (_) {
        break;
      }
    }
    return parsed;
  }

  bool _unique(List<Map<String, Object?>> items) {
    final Set<Object?> ids = <Object?>{};
    for (final Map<String, Object?> item in items) {
      final Object? id = item['id'];
      if (id == null) continue;
      if (!ids.add(id)) return false;
    }
    return true;
  }
}
