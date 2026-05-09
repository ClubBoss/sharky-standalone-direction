import 'dart:math';

import 'package:poker_analyzer/engine/simulation_ai_agent.dart';

class AIPersona {
  const AIPersona({
    required this.id,
    required this.displayName,
    required this.behaviorLabel,
    required this.aggression,
    required this.bluffRate,
    required this.delayMs,
    required this.delayJitter,
    required this.earlyStreetModifier,
    required this.lateStreetModifier,
  });

  final String id;
  final String displayName;
  final String behaviorLabel;
  final double aggression;
  final double bluffRate;
  final int delayMs;
  final double delayJitter;
  final double earlyStreetModifier;
  final double lateStreetModifier;

  String get fullLabel => '$displayName - $behaviorLabel';

  AIPersona copyWith({
    String? id,
    String? displayName,
    String? behaviorLabel,
    double? aggression,
    double? bluffRate,
    int? delayMs,
    double? delayJitter,
    double? earlyStreetModifier,
    double? lateStreetModifier,
  }) {
    return AIPersona(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      behaviorLabel: behaviorLabel ?? this.behaviorLabel,
      aggression: aggression ?? this.aggression,
      bluffRate: bluffRate ?? this.bluffRate,
      delayMs: delayMs ?? this.delayMs,
      delayJitter: delayJitter ?? this.delayJitter,
      earlyStreetModifier: earlyStreetModifier ?? this.earlyStreetModifier,
      lateStreetModifier: lateStreetModifier ?? this.lateStreetModifier,
    );
  }
}

class PersonaAgent {
  const PersonaAgent({required this.persona, required this.agent});

  final AIPersona persona;
  final SimulationAIAgent agent;
}

class AIAgentFactory {
  AIAgentFactory({int? seed}) : _random = Random(seed ?? 4040);

  final Random _random;

  static const List<_PersonaTemplate> _templates = <_PersonaTemplate>[
    _PersonaTemplate(
      id: 'crazy_carl',
      displayName: 'Crazy Carl',
      behaviorLabel: 'Aggressive',
      aggression: 0.85,
      bluffRate: 0.30,
      delayMs: 900,
      delayJitter: 0.22,
      earlyStreetModifier: 1.08,
      lateStreetModifier: 1.15,
    ),
    _PersonaTemplate(
      id: 'risky_rick',
      displayName: 'Risky Rick',
      behaviorLabel: 'Loose',
      aggression: 0.80,
      bluffRate: 0.28,
      delayMs: 1100,
      delayJitter: 0.28,
      earlyStreetModifier: 1.02,
      lateStreetModifier: 1.10,
    ),
    _PersonaTemplate(
      id: 'safeplay_sam',
      displayName: 'SafePlay Sam',
      behaviorLabel: 'Careful',
      aggression: 0.45,
      bluffRate: 0.12,
      delayMs: 1250,
      delayJitter: 0.12,
      earlyStreetModifier: 0.94,
      lateStreetModifier: 0.98,
    ),
    _PersonaTemplate(
      id: 'sleepy_leo',
      displayName: 'Sleepy Leo',
      behaviorLabel: 'Passive',
      aggression: 0.40,
      bluffRate: 0.10,
      delayMs: 1450,
      delayJitter: 0.18,
      earlyStreetModifier: 0.90,
      lateStreetModifier: 0.95,
    ),
    _PersonaTemplate(
      id: 'calm_alex',
      displayName: 'Calm Alex',
      behaviorLabel: 'Balanced',
      aggression: 0.55,
      bluffRate: 0.18,
      delayMs: 1200,
      delayJitter: 0.18,
      earlyStreetModifier: 1.00,
      lateStreetModifier: 1.05,
    ),
  ];

  PersonaAgent createById(String id) {
    final template = _templates.firstWhere(
      (item) => item.id == id,
      orElse: () => _templates.first,
    );
    return _build(template, randomize: false);
  }

  PersonaAgent createRandom() {
    final template = _templates[_random.nextInt(_templates.length)];
    return _build(template, randomize: true);
  }

  PersonaAgent createUnknown() {
    final template = _templates[_random.nextInt(_templates.length)];
    final alias = _random.nextBool() ? 'Random Ray' : 'Mystery Mia';
    final noise = _randomRange(-0.1, 0.1);
    final persona = template
        .instantiate(random: _random, randomize: true, aggressionNoise: noise)
        .copyWith(
          id: 'unknown_${template.id}',
          displayName: alias,
          behaviorLabel: template.behaviorLabel,
        );
    return PersonaAgent(persona: persona, agent: _createAgent(persona));
  }

  PersonaAgent _build(_PersonaTemplate template, {required bool randomize}) {
    final persona = template.instantiate(
      random: _random,
      randomize: randomize,
      aggressionNoise: randomize ? _randomRange(-0.05, 0.05) : 0.0,
    );
    return PersonaAgent(persona: persona, agent: _createAgent(persona));
  }

  SimulationAIAgent _createAgent(AIPersona persona) {
    return SimulationAIAgent(
      aggression: persona.aggression,
      baseBluffRate: persona.bluffRate,
      earlyStreetModifier: persona.earlyStreetModifier,
      lateStreetModifier: persona.lateStreetModifier,
      baseDelayMs: persona.delayMs,
      delayJitter: persona.delayJitter,
      seed: _random.nextInt(1 << 31),
    );
  }

  double _randomRange(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
}

class _PersonaTemplate {
  const _PersonaTemplate({
    required this.id,
    required this.displayName,
    required this.behaviorLabel,
    required this.aggression,
    required this.bluffRate,
    required this.delayMs,
    required this.delayJitter,
    required this.earlyStreetModifier,
    required this.lateStreetModifier,
  });

  final String id;
  final String displayName;
  final String behaviorLabel;
  final double aggression;
  final double bluffRate;
  final int delayMs;
  final double delayJitter;
  final double earlyStreetModifier;
  final double lateStreetModifier;

  AIPersona instantiate({
    required Random random,
    required bool randomize,
    required double aggressionNoise,
  }) {
    final modifier = randomize ? 1 + _boundedNoise(random) : 1.0;
    final tunedAggression = (aggression * modifier + aggressionNoise).clamp(
      0.0,
      1.0,
    );
    final tunedBluff = (bluffRate * modifier).clamp(0.05, 0.30);
    final delayValue = (delayMs * modifier).round();
    final tunedDelay = delayValue.clamp(600, 2000).toInt();
    final tunedJitter = (delayJitter + aggressionNoise.abs() * 0.2).clamp(
      0.05,
      0.35,
    );
    final tunedEarly = (earlyStreetModifier * (1 + aggressionNoise * 0.3))
        .clamp(0.8, 1.2);
    final tunedLate = (lateStreetModifier * (1 + aggressionNoise * 0.3)).clamp(
      0.85,
      1.25,
    );

    return AIPersona(
      id: id,
      displayName: displayName,
      behaviorLabel: behaviorLabel,
      aggression: tunedAggression,
      bluffRate: tunedBluff,
      delayMs: tunedDelay,
      delayJitter: tunedJitter,
      earlyStreetModifier: tunedEarly,
      lateStreetModifier: tunedLate,
    );
  }

  double _boundedNoise(Random random) {
    return (random.nextDouble() * 0.2) - 0.1;
  }
}
