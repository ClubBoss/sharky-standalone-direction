class TableUIBootEnvelopeV1 {
  const TableUIBootEnvelopeV1(this.tableUIBootSpecV1Map);

  final Object tableUIBootSpecV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> spec =
        tableUIBootSpecV1Map is Map &&
            (tableUIBootSpecV1Map as Map)['table_ui_boot_spec_v1'] is Map
        ? (tableUIBootSpecV1Map as Map)['table_ui_boot_spec_v1']
              as Map<String, Object>
        : <String, Object>{};
    final bool ready = spec.isNotEmpty;
    final List<String> missing = <String>[if (!ready) 'table_ui_boot_spec_v1'];
    return <String, Object>{
      'table_ui_boot_envelope_v1': <String, Object>{
        'envelope': <String, Object>{
          'boot_spec': ready ? spec : <String, Object>{},
        },
        'envelope_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}
