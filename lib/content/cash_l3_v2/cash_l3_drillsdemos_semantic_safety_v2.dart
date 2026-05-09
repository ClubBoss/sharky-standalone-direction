/// Passive semantic safety checker for Cash L3 drills/demos v2.
class CashL3DrillsDemosSemanticSafetyV2 {
  const CashL3DrillsDemosSemanticSafetyV2({
    required this.drillsStruct,
    required this.demosStruct,
  });

  final List<String> drillsStruct;
  final List<String> demosStruct;

  Map<String, Object> check() {
    final List<String> forbiddenTokens = <String>[];
    final List<String> malformedEntries = <String>[];
    final List<String> idMismatch = <String>[];

    void scan(List<String> entries, String label) {
      for (final String line in entries) {
        final String trimmed = line.trimRight();
        if (!_hasIdPrefix(trimmed)) {
          malformedEntries.add(trimmed);
          continue;
        }
        final int colon = trimmed.indexOf(':');
        final String id = trimmed.substring(0, colon).trim();
        if (id.isEmpty) {
          idMismatch.add(trimmed);
        }
        for (final String token in _forbiddenList) {
          if (trimmed.contains(token) && !forbiddenTokens.contains(token)) {
            forbiddenTokens.add(token);
          }
        }
        if (trimmed.contains('::') || RegExp(r'<[^>]+>').hasMatch(trimmed)) {
          if (!forbiddenTokens.contains('markup')) {
            forbiddenTokens.add('markup');
          }
        }
      }
    }

    scan(drillsStruct, 'drill');
    scan(demosStruct, 'demo');

    final bool safetyReady =
        forbiddenTokens.isEmpty &&
        malformedEntries.isEmpty &&
        idMismatch.isEmpty;

    return <String, Object>{
      'forbidden_tokens': forbiddenTokens,
      'malformed_entries': malformedEntries,
      'id_mismatch': idMismatch,
      'safety_ready': safetyReady,
    };
  }

  bool _hasIdPrefix(String line) {
    final int colon = line.indexOf(':');
    return colon > 0;
  }

  List<String> get _forbiddenList => const <String>[
    'TODO',
    'FIXME',
    'TBD',
    'solver-equity',
    'GTO-solver',
    'Pio',
    'Snowie',
  ];
}
