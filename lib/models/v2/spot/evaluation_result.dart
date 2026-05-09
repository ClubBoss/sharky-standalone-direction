import 'package:meta/meta.dart';

@immutable
class SpotEvaluationResult {
  const SpotEvaluationResult({
    this.correct,
    this.expectedAction,
    this.userEquity,
    this.expectedEquity,
    this.ev,
    this.icmEv,
    this.accuracy,
    this.solverReference,
    Map<String, double>? equities,
    Map<String, Object?>? extra,
  }) : equities = equities ?? const {},
       extra = extra ?? const {};

  factory SpotEvaluationResult.fromJson(Map<String, Object?> json) =>
      SpotEvaluationResult(
        correct: json['correct'] is bool ? json['correct'] as bool : null,
        expectedAction: json['expectedAction']?.toString(),
        userEquity: (json['userEquity'] as num?)?.toDouble(),
        expectedEquity: (json['expectedEquity'] as num?)?.toDouble(),
        ev: (json['ev'] as num?)?.toDouble(),
        icmEv: (json['icmEv'] as num?)?.toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        solverReference: json['solverRef']?.toString(),
        equities: _doubleMap(json['equities']),
        extra: _objectMap(json['extra']),
      );

  final bool? correct;
  final String? expectedAction;
  final double? userEquity;
  final double? expectedEquity;
  final double? ev;
  final double? icmEv;
  final double? accuracy;
  final String? solverReference;
  final Map<String, double> equities;
  final Map<String, Object?> extra;

  Map<String, Object?> toJson() => {
    if (correct != null) 'correct': correct,
    if (expectedAction != null) 'expectedAction': expectedAction,
    if (userEquity != null) 'userEquity': userEquity,
    if (expectedEquity != null) 'expectedEquity': expectedEquity,
    if (ev != null) 'ev': ev,
    if (icmEv != null) 'icmEv': icmEv,
    if (accuracy != null) 'accuracy': accuracy,
    if (solverReference != null) 'solverRef': solverReference,
    if (equities.isNotEmpty) 'equities': Map<String, double>.from(equities),
    if (extra.isNotEmpty) 'extra': Map<String, Object?>.from(extra),
  };

  SpotEvaluationResult copyWith({
    bool? correct,
    String? expectedAction,
    double? userEquity,
    double? expectedEquity,
    double? ev,
    double? icmEv,
    double? accuracy,
    String? solverReference,
    Map<String, double>? equities,
    Map<String, Object?>? extra,
  }) => SpotEvaluationResult(
    correct: correct ?? this.correct,
    expectedAction: expectedAction ?? this.expectedAction,
    userEquity: userEquity ?? this.userEquity,
    expectedEquity: expectedEquity ?? this.expectedEquity,
    ev: ev ?? this.ev,
    icmEv: icmEv ?? this.icmEv,
    accuracy: accuracy ?? this.accuracy,
    solverReference: solverReference ?? this.solverReference,
    equities: equities ?? this.equities,
    extra: extra ?? this.extra,
  );
}

Map<String, double> _doubleMap(Object? source) {
  if (source is Map) {
    final result = <String, double>{};
    for (final entry in source.entries) {
      final value = (entry.value as num?)?.toDouble();
      if (value != null) {
        result[entry.key.toString()] = value;
      }
    }
    return result;
  }
  return const {};
}

Map<String, Object?> _objectMap(Object? source) {
  if (source is Map) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}
