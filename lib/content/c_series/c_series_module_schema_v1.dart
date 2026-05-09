class CSeriesModuleSchemaV1 {
  const CSeriesModuleSchemaV1();

  Map<String, Object> buildEmptySchema() => <String, Object>{
    'schema_version': 'v1',
    'title': '<unset>',
    'theory': const <Object>[],
    'drills': const <Object>[],
    'recaps': const <Object>[],
    'checkpoints': const <Object>[],
    'diagnostics': 'schema_placeholder',
    'ready': false,
  };

  Map<String, Object> validateModule(Map<String, Object> module) {
    const List<String> required = <String>[
      'title',
      'theory',
      'drills',
      'recaps',
      'checkpoints',
    ];
    final List<String> missing =
        required.where((key) => !module.containsKey(key)).toList()..sort();
    final List<String> extra =
        module.keys.where((key) => !_allowedKeys.contains(key)).toList()
          ..sort();
    final bool valid = missing.isEmpty && extra.isEmpty;
    return <String, Object>{
      'schema_version': 'v1',
      'valid': valid,
      'missing_fields': missing,
      'extra_fields': extra,
    };
  }

  static const List<String> _allowedKeys = <String>[
    'schema_version',
    'title',
    'theory',
    'drills',
    'recaps',
    'checkpoints',
    'diagnostics',
    'ready',
  ];
}
