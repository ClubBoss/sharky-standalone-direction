class TableV4QAMiniGuideV1 {
  const TableV4QAMiniGuideV1();

  static Map<String, Object> build() {
    return <String, Object>{
      'qa_miniguide_v1': <String, String>{
        'audit': 'Audit bridge reconciles issues across the stack.',
        'cohesion': 'Cohesion reviews spacing/typography consistency.',
        'contrast': 'Contrast checks basic alpha/visibility ranges.',
        'dashboard': 'Dashboard groups visual QA metrics.',
        'health': 'Health ledger unifies aggregated health signals.',
        'manifest': 'Manifest summarizes all QA surface contracts.',
        'megasurface': 'Mega-surface aggregates full pipeline outputs.',
        'orchestrator': 'Consolidates issue lists + weighted severity.',
        'readiness': 'Readiness captures section-level ok flags.',
        'weights': 'Severity→weight mapping used for scoring.',
      },
    };
  }
}
