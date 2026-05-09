import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/ui_v2/runner/factual_runner_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_source_meta_contract_v1.dart';

@immutable
class LegacyDrillRunnerItemV1 {
  const LegacyDrillRunnerItemV1({
    required this.prompt,
    required this.detailsPrompt,
    required this.explanation,
    required this.correctFeedback,
    required this.incorrectFeedback,
    this.factualFamily,
    this.sourceMeta = const RunnerHostSourceMetaContractV1(),
    this.options,
    this.correctOptionIndex,
  });

  final String prompt;
  final String detailsPrompt;
  final String explanation;
  final String correctFeedback;
  final String incorrectFeedback;
  final FactualRunnerHostFamilyV1? factualFamily;
  final RunnerHostSourceMetaContractV1 sourceMeta;
  final List<String>? options;
  final int? correctOptionIndex;

  bool get isQuiz =>
      options != null &&
      options!.isNotEmpty &&
      correctOptionIndex != null &&
      correctOptionIndex! >= 0 &&
      correctOptionIndex! < options!.length;
}

LegacyDrillRunnerItemV1 normalizeLegacyDrillRunnerItemV1(
  Map<String, dynamic> item,
) {
  final prompt = _firstNonEmptyStringV1(<Object?>[
    item['question'],
    item['prompt'],
    item['goal_text'],
    item['goal'],
    item['instruction_text'],
  ], fallback: 'Unknown Question');
  final detailsPrompt = _normalizeDetailsPromptV1(item, prompt);
  final explanation = _firstNonEmptyStringV1(<Object?>[
    item['rationale'],
    item['explanation'],
    item['reaction_text'],
    item['why_v1'],
  ]);
  final correctFeedback = _firstNonEmptyStringV1(<Object?>[
    item['feedback_correct_v1'],
    explanation,
  ]);
  final incorrectFeedback = _firstNonEmptyStringV1(<Object?>[
    item['feedback_incorrect_v1'],
    explanation,
  ]);
  final factualFamily = _normalizeFactualFamilyV1(item);
  final sourceMeta = _normalizeSourceMetaV1(item);
  final options = _normalizeOptionsV1(item);
  final correctOptionIndex = _resolveCorrectOptionIndexV1(item, options);
  return LegacyDrillRunnerItemV1(
    prompt: prompt,
    detailsPrompt: detailsPrompt,
    explanation: explanation,
    correctFeedback: correctFeedback,
    incorrectFeedback: incorrectFeedback,
    factualFamily: factualFamily,
    sourceMeta: sourceMeta,
    options: options,
    correctOptionIndex: correctOptionIndex,
  );
}

FactualRunnerHostFamilyV1? _normalizeFactualFamilyV1(
  Map<String, dynamic> item,
) {
  return parseFactualRunnerHostFamilyV1(item['factual_family_v1']);
}

RunnerHostSourceMetaContractV1 _normalizeSourceMetaV1(
  Map<String, dynamic> item,
) {
  final entries = <RunnerHostSourceMetaEntryV1>[];
  _addSourceMetaEntryV1(
    entries,
    testKey: 'legacy_drill_runner_source_street_v1',
    label: 'Street',
    value: item['street_context'],
    uppercase: true,
  );
  _addSourceMetaEntryV1(
    entries,
    testKey: 'legacy_drill_runner_source_outs_v1',
    label: 'Outs',
    value: item['outs_count_v1'],
  );
  _addSourceMetaEntryV1(
    entries,
    testKey: 'legacy_drill_runner_source_board_v1',
    label: 'Board',
    value: item['board_context_v1'],
  );
  _addSourceMetaEntryV1(
    entries,
    testKey: 'legacy_drill_runner_source_texture_tag_v1',
    label: 'Texture',
    value: item['texture_tag_v1'],
  );
  _addSourceMetaEntryV1(
    entries,
    testKey: 'legacy_drill_runner_source_format_v1',
    label: 'Format',
    value: item['format_context_v1'],
  );
  _addSourceMetaEntryV1(
    entries,
    testKey: 'legacy_drill_runner_source_hero_seat_v1',
    label: 'Hero Seat',
    value: item['hero_seat_v1'],
  );
  _addSourceMetaEntryV1(
    entries,
    testKey: 'legacy_drill_runner_source_villain_seat_v1',
    label: 'Villain Seat',
    value: item['villain_seat_v1'],
  );
  _addSourceMetaEntryV1(
    entries,
    testKey: 'legacy_drill_runner_source_scope_v1',
    label: 'Scope',
    value: item['guided_scope'],
  );
  _addSourceMetaEntryV1(
    entries,
    testKey: 'legacy_drill_runner_source_action_kind_v1',
    label: 'Action Kind',
    value: item['expected_action_kind'],
    useBodySmall: true,
  );
  _addSourceMetaEntryV1(
    entries,
    testKey: 'legacy_drill_runner_source_spot_kind_v1',
    label: 'Spot Kind',
    value: item['spot_kind'],
    useBodySmall: true,
  );
  return RunnerHostSourceMetaContractV1(
    entries: List<RunnerHostSourceMetaEntryV1>.unmodifiable(entries),
  );
}

String _normalizeDetailsPromptV1(Map<String, dynamic> item, String prompt) {
  final parts = <String>[];
  _addDistinctPartV1(
    parts,
    label: 'Instruction',
    value: item['instruction_text'],
  );
  _addDistinctPartV1(parts, label: 'Goal', value: item['goal_text']);
  _addDistinctPartV1(parts, label: 'Goal', value: item['goal']);
  _addDistinctPartV1(parts, label: 'Goal', value: item['lesson_goal']);
  if (parts.isEmpty) {
    return prompt;
  }
  return parts.join('\n\n');
}

void _addSourceMetaEntryV1(
  List<RunnerHostSourceMetaEntryV1> entries, {
  required String testKey,
  required String label,
  required Object? value,
  bool uppercase = false,
  bool useBodySmall = false,
}) {
  var normalizedValue = value?.toString().trim() ?? '';
  if (normalizedValue.isEmpty) {
    return;
  }
  if (uppercase) {
    normalizedValue = normalizedValue.toUpperCase();
  }
  entries.add(
    RunnerHostSourceMetaEntryV1(
      testKey: testKey,
      text: '$label: $normalizedValue',
      useBodySmall: useBodySmall,
    ),
  );
}

void _addDistinctPartV1(
  List<String> parts, {
  required String label,
  required Object? value,
}) {
  final normalizedValue = value?.toString().trim() ?? '';
  if (normalizedValue.isEmpty) {
    return;
  }
  final labeledPart = '$label\n$normalizedValue';
  if (!parts.contains(labeledPart)) {
    parts.add(labeledPart);
  }
}

List<String>? _normalizeOptionsV1(Map<String, dynamic> item) {
  final rawOptions = item['options'] ?? item['answer_choices'];
  if (rawOptions is! List) {
    return null;
  }
  final normalized = rawOptions
      .map((value) => value.toString().trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  return normalized.isEmpty ? null : normalized;
}

int? _resolveCorrectOptionIndexV1(
  Map<String, dynamic> item,
  List<String>? options,
) {
  if (options == null || options.isEmpty) {
    return null;
  }
  final answerIndex = item['answer_index'];
  if (answerIndex is int && answerIndex >= 0 && answerIndex < options.length) {
    return answerIndex;
  }
  final answer = item['answer'];
  if (answer is int && answer >= 0 && answer < options.length) {
    return answer;
  }
  final correctAnswer = item['correct_answer']?.toString().trim();
  if (correctAnswer == null || correctAnswer.isEmpty) {
    return null;
  }
  final index = options.indexWhere((option) => option == correctAnswer);
  return index >= 0 ? index : null;
}

String _firstNonEmptyStringV1(
  List<Object?> candidates, {
  String fallback = '',
}) {
  for (final candidate in candidates) {
    final text = candidate?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }
  }
  return fallback;
}
