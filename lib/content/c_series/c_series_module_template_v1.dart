class CSeriesModuleTemplateV1 {
  const CSeriesModuleTemplateV1();

  Map<String, Object> buildTemplate(String moduleId) => <String, Object>{
    'schema_version': 'v1',
    'module_id': moduleId,
    'title': '<unset>',
    'theory': const <Object>[],
    'drills': const <Object>[],
    'recaps': const <Object>[],
    'checkpoints': const <Object>[],
    'diagnostics': 'template_placeholder',
    'ready': false,
  };

  Map<String, Object> validateTemplate(Map<String, Object> tpl) {
    const List<String> expected = <String>[
      'schema_version',
      'module_id',
      'title',
      'theory',
      'drills',
      'recaps',
      'checkpoints',
      'diagnostics',
      'ready',
    ];
    final List<String> missing =
        expected.where((key) => !tpl.containsKey(key)).toList()..sort();
    final List<String> extra =
        tpl.keys.where((key) => !expected.contains(key)).toList()..sort();
    final bool valid = missing.isEmpty && extra.isEmpty;
    return <String, Object>{
      'schema_version': 'v1',
      'valid': valid,
      'missing_fields': missing,
      'extra_fields': extra,
    };
  }
}
