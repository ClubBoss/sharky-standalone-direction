import 'dart:io';

import 'package:poker_analyzer/services/recommendation_generator_v1.dart';
import 'package:poker_analyzer/services/recommendation_persona_link_v1.dart';
import 'package:poker_analyzer/services/recommendation_scoring_v1.dart';

int runRecommendationConsistencyGate({
  required List<Map<String, Object?>> srItems,
  required Map<String, Object?> persona,
  required Map<String, List<Map<String, Object?>>> srQueues,
}) {
  final itemIds = <String>{};
  final baseScores = <String, double>{};

  for (final srItem in srItems) {
    final rawId = srItem['id'];
    if (rawId is! String || rawId.isEmpty || !_isAscii(rawId)) {
      stdout.writeln('ERR: invalid id');
      return 2;
    }
    itemIds.add(rawId);

    final score = scoreItem(srItem: srItem, persona: persona);
    if (score.isNaN || !score.isFinite) {
      stdout.writeln('ERR: invalid score for $rawId');
      return 2;
    }
    baseScores[rawId] = score;
  }

  final recommendations = generateRecommendations(
    srItems: srItems,
    persona: persona,
    limit: srItems.length,
  );
  for (final recommendation in recommendations) {
    final id = recommendation['id'];
    if (id is! String || !_isAscii(id) || !itemIds.contains(id)) {
      stdout.writeln('ERR: invalid recommendation id');
      return 2;
    }
  }

  final linkedScores = applyPersonaSRLink(
    baseScores: baseScores,
    persona: persona,
    srQueues: srQueues,
  );

  for (final entry in linkedScores.entries) {
    final id = entry.key;
    if (!_isAscii(id) || !itemIds.contains(id)) {
      stdout.writeln('ERR: invalid linked id $id');
      return 2;
    }
    final value = entry.value;
    if (value.isNaN || !value.isFinite) {
      stdout.writeln('ERR: invalid linked score for $id');
      return 2;
    }
  }

  final finalSorted = linkedScores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final finalIds = finalSorted.map((entry) => entry.key).toSet();
  if (!finalIds.every(itemIds.contains)) {
    stdout.writeln('ERR: final list contains unknown ids');
    return 2;
  }

  stdout.writeln('OK: recommendation pipeline valid');
  return 0;
}

bool _isAscii(String value) => value.codeUnits.every((unit) => unit <= 127);
