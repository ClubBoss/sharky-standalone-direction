class MicroQuiz0105V1 {
  const MicroQuiz0105V1();

  static Map<String, Object> build() => <String, Object>{
    'schema_version': 'v1',
    'quiz_id': 'micro_quiz_0105_v1',
    'title': 'Micro-Quiz — Modules C01–C05',
    'questions': <Map<String, Object>>[
      <String, Object>{
        'answer': 'Set of hands',
        'id': 'q1',
        'options': <String>['Set of hands', 'Single hand', 'Random guess'],
        'prompt': 'C01: What is a range?',
      },
      <String, Object>{
        'answer': 'IP',
        'id': 'q2',
        'options': <String>['IP', 'OOP', 'Neither'],
        'prompt': 'C02: IP vs OOP — which usually has initiative?',
      },
      <String, Object>{
        'answer': 'Low/connected',
        'id': 'q3',
        'options': <String>['Low/connected', 'High/dry', 'Paired high'],
        'prompt': 'C03: Deep-dive — which board favors the preflop caller?',
      },
      <String, Object>{
        'answer': 'Small',
        'id': 'q4',
        'options': <String>['Small', 'Overbet', 'Check always'],
        'prompt': 'C04: On dry flops, preferred c-bet size?',
      },
      <String, Object>{
        'answer': 'Pot control',
        'id': 'q5',
        'options': <String>['Pot control', 'Jam', 'Overbet'],
        'prompt': 'C05: When equity drops OTT, typical line?',
      },
    ],
    'diagnostics': 'micro_quiz_0105_stub_v1',
    'ready': false,
  };
}
