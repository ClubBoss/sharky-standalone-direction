class CSeriesMixedCheckpoint0105V1 {
  const CSeriesMixedCheckpoint0105V1();

  static Map<String, Object> build() => <String, Object>{
    'schema_version': 'v1',
    'checkpoint_id': 'c_series_mixed_checkpoint_0105_v1',
    'title': 'Mixed Checkpoint — Modules C01–C05',
    'questions': <Map<String, Object>>[
      <String, Object>{
        'answer': 'BTN ahead',
        'id': 'q1',
        'options': <String>['BTN ahead', 'BB ahead', 'Neutral'],
        'prompt':
            'You face a BTN open. Which range advantage concept from C02 applies?',
      },
      <String, Object>{
        'answer': 'Range protection',
        'id': 'q2',
        'options': <String>['Range protection', 'Equity denial', 'Thin value'],
        'prompt': 'On a low paired board, which C03 heuristic applies most?',
      },
      <String, Object>{
        'answer': 'Small',
        'id': 'q3',
        'options': <String>['Small', 'Overbet', 'Check always'],
        'prompt': 'C-Bet sizing rule from C04 for dry flops:',
      },
      <String, Object>{
        'answer': 'Pot control',
        'id': 'q4',
        'options': <String>['Pot control', 'Pot building', 'Jam'],
        'prompt': 'Turn/Runout shift (C05): when equity drops, preferred line?',
      },
    ],
    'diagnostics': 'c_series_mixed_checkpoint_0105_stub_v1',
    'ready': false,
  };
}
