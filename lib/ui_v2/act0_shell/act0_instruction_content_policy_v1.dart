class Act0InstructionContentPolicyV1 {
  // Compact instructional hosts should feel like one complete beat, not a
  // one-line caption or a mini article.
  static const int compactTargetSegmentLength = 118;
  static const int regularTargetSegmentLength = 136;
  static const int compactMaxSegmentsPerBlock = 3;
  static const int maxSentencesPerSegment = 2;
}

class Act0InstructionContentAuditIssueV1 {
  const Act0InstructionContentAuditIssueV1({
    required this.scope,
    required this.message,
  });

  final String scope;
  final String message;

  @override
  String toString() => '$scope: $message';
}

List<String> act0BuildInstructionBlocksV1({
  required String text,
  required bool compact,
}) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) {
    return const <String>[];
  }

  final sentences = normalized
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  if (sentences.length <= 1) {
    return <String>[normalized];
  }

  if (compact) {
    return _groupCompactLearningRailSentencesV1(<String>[
      for (final sentence in sentences)
        ..._splitMeaningfulCompactSentenceV1(sentence),
    ]);
  }

  final segments = <String>[];
  final buffer = StringBuffer();

  void flush() {
    final value = buffer.toString().trim();
    if (value.isNotEmpty) {
      segments.add(value);
    }
    buffer.clear();
  }

  for (final sentence in sentences) {
    final candidate = buffer.isEmpty
        ? sentence
        : '${buffer.toString().trim()} $sentence';
    if (buffer.isNotEmpty &&
        candidate.length >
            Act0InstructionContentPolicyV1.regularTargetSegmentLength) {
      flush();
    }
    if (buffer.isNotEmpty) {
      buffer.write(' ');
    }
    buffer.write(sentence);
  }
  flush();

  return segments.isEmpty ? <String>[normalized] : segments;
}

List<String> act0BuildLearningRailSupportSegmentsV1({
  required String hint,
  required List<String> focusLabels,
  required bool compact,
}) {
  final hasHint = hint.trim().isNotEmpty;
  final fallback = focusLabels.take(2).join(' · ');
  final source = hasHint ? hint : fallback;
  return act0BuildInstructionBlocksV1(text: source, compact: compact);
}

List<Act0InstructionContentAuditIssueV1> act0AuditInstructionBlockV1({
  required String scope,
  required String text,
  required bool compact,
}) {
  if (text.replaceAll(RegExp(r'\s+'), ' ').trim().isEmpty) {
    return const <Act0InstructionContentAuditIssueV1>[];
  }

  final segments = act0BuildInstructionBlocksV1(text: text, compact: compact);
  final issues = <Act0InstructionContentAuditIssueV1>[];

  if (compact &&
      segments.length >
          Act0InstructionContentPolicyV1.compactMaxSegmentsPerBlock) {
    issues.add(
      Act0InstructionContentAuditIssueV1(
        scope: scope,
        message:
            'produces ${segments.length} compact segments; expected at most ${Act0InstructionContentPolicyV1.compactMaxSegmentsPerBlock}',
      ),
    );
  }

  for (var index = 0; index < segments.length; index++) {
    final segment = segments[index].trim();
    final sentenceCount = RegExp(r'[.!?]').allMatches(segment).length;
    if (sentenceCount > Act0InstructionContentPolicyV1.maxSentencesPerSegment) {
      issues.add(
        Act0InstructionContentAuditIssueV1(
          scope: '$scope segment ${index + 1}',
          message:
              'contains $sentenceCount sentences; expected at most ${Act0InstructionContentPolicyV1.maxSentencesPerSegment}',
        ),
      );
    }
    if (!RegExp(r'[.!?]$').hasMatch(segment)) {
      issues.add(
        Act0InstructionContentAuditIssueV1(
          scope: '$scope segment ${index + 1}',
          message: 'should end as a finished thought with terminal punctuation',
        ),
      );
    }
  }

  return issues;
}

List<String> _groupCompactLearningRailSentencesV1(
  List<String> sentences, {
  int targetLength = Act0InstructionContentPolicyV1.compactTargetSegmentLength,
}) {
  final segments = <String>[];
  final buffer = StringBuffer();

  void flush() {
    final value = buffer.toString().trim();
    if (value.isNotEmpty) {
      segments.add(value);
    }
    buffer.clear();
  }

  for (final sentence in sentences) {
    final candidate = buffer.isEmpty
        ? sentence
        : '${buffer.toString().trim()} $sentence';
    if (buffer.isNotEmpty && candidate.length > targetLength) {
      flush();
    }
    if (buffer.isNotEmpty) {
      buffer.write(' ');
    }
    buffer.write(sentence);
  }
  flush();

  return segments.isEmpty ? sentences : segments;
}

List<String> _splitMeaningfulCompactSentenceV1(
  String sentence, {
  int maxLength = Act0InstructionContentPolicyV1.compactTargetSegmentLength,
}) {
  final normalized = sentence.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty || normalized.length <= maxLength) {
    return normalized.isEmpty ? const <String>[] : <String>[normalized];
  }

  final strongClauses = normalized
      .split(RegExp(r'\s+[—:;]\s+'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (strongClauses.length > 1) {
    return strongClauses;
  }

  final commaClauses = normalized
      .split(RegExp(r',\s+'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (commaClauses.length > 1) {
    return commaClauses;
  }

  return <String>[normalized];
}
