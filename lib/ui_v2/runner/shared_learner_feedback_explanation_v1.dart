import 'package:flutter/foundation.dart';

enum SharedLearnerFeedbackVerdictV1 { fail, softPass, correct }

enum SharedLearnerFeedbackComparisonStyleV1 {
  strongerLine,
  correctAnswer,
}

@immutable
class SharedLearnerFeedbackExplanationV1 {
  const SharedLearnerFeedbackExplanationV1({
    required this.headlineText,
    this.teachingText,
    this.guidanceText,
  });

  final String headlineText;
  final String? teachingText;
  final String? guidanceText;

  String composeInlineText({String separator = ' '}) {
    return <String>[
      headlineText.trim(),
      if ((teachingText ?? '').trim().isNotEmpty) teachingText!.trim(),
      if ((guidanceText ?? '').trim().isNotEmpty) guidanceText!.trim(),
    ].join(separator);
  }

  String? composeSupportingText({String separator = ' '}) {
    final segments = <String>[
      if ((teachingText ?? '').trim().isNotEmpty) teachingText!.trim(),
      if ((guidanceText ?? '').trim().isNotEmpty) guidanceText!.trim(),
    ];
    if (segments.isEmpty) {
      return null;
    }
    return segments.join(separator);
  }
}

SharedLearnerFeedbackExplanationV1 buildSharedLearnerFeedbackExplanationV1({
  required SharedLearnerFeedbackVerdictV1 verdict,
  required SharedLearnerFeedbackComparisonStyleV1 comparisonStyle,
  required String expectedLabel,
  String? chosenLabel,
  String? teachingText,
  String? guidanceText,
  String? fallbackTeachingText,
  String? fallbackGuidanceText,
}) {
  final expected = _normalizeDisplayLabelV1(
    expectedLabel,
    fallback: comparisonStyle ==
            SharedLearnerFeedbackComparisonStyleV1.strongerLine
        ? 'the stronger line'
        : 'the right answer',
  );
  final chosen = _normalizeDisplayLabelV1(chosenLabel);
  final notice = _normalizeFeedbackSegmentV1(
    teachingText ?? fallbackTeachingText,
    prefix: 'Notice',
  );
  final nextTime = _normalizeFeedbackSegmentV1(
    guidanceText ?? fallbackGuidanceText,
    prefix: 'Next time',
  );

  return SharedLearnerFeedbackExplanationV1(
    headlineText: _headlineTextV1(
      verdict: verdict,
      comparisonStyle: comparisonStyle,
      expected: expected,
      chosen: chosen,
    ),
    teachingText: notice,
    guidanceText: nextTime,
  );
}

String? normalizeSharedLearnerNoticeTextV1(
  String? source, {
  String? fallback,
}) => _normalizeFeedbackSegmentV1(source ?? fallback, prefix: 'Notice');

String? normalizeSharedLearnerNextTimeTextV1(
  String? source, {
  String? fallback,
}) => _normalizeFeedbackSegmentV1(source ?? fallback, prefix: 'Next time');

SharedLearnerFeedbackExplanationV1? tryParseSharedLearnerFeedbackExplanationV1(
  String? source,
) {
  final trimmed = source?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  final noticeIndex = trimmed.indexOf(' Notice:');
  final nextTimeIndex = trimmed.indexOf(' Next time:');
  final markers = <int>[
    if (noticeIndex >= 0) noticeIndex,
    if (nextTimeIndex >= 0) nextTimeIndex,
  ]..sort();
  final headlineEnd = markers.isEmpty ? trimmed.length : markers.first;
  final headlineText = trimmed.substring(0, headlineEnd).trim();
  if (!isSharedLearnerComparisonHeadlineV1(headlineText)) {
    return null;
  }

  String? teachingText;
  if (noticeIndex >= 0) {
    final noticeEnd =
        nextTimeIndex >= 0 && nextTimeIndex > noticeIndex
        ? nextTimeIndex
        : trimmed.length;
    teachingText = trimmed.substring(noticeIndex + 1, noticeEnd).trim();
  }

  String? guidanceText;
  if (nextTimeIndex >= 0) {
    guidanceText = trimmed.substring(nextTimeIndex + 1).trim();
  }

  return SharedLearnerFeedbackExplanationV1(
    headlineText: headlineText,
    teachingText: teachingText,
    guidanceText: guidanceText,
  );
}

bool isSharedLearnerComparisonHeadlineV1(String source) {
  final trimmed = source.trim();
  return trimmed.startsWith('Better line:') ||
      trimmed.startsWith('Better answer:') ||
      trimmed.contains(' is the stronger line here.') ||
      trimmed.contains(' is the right answer here.') ||
      trimmed.contains(' works, but ');
}

String _headlineTextV1({
  required SharedLearnerFeedbackVerdictV1 verdict,
  required SharedLearnerFeedbackComparisonStyleV1 comparisonStyle,
  required String expected,
  required String? chosen,
}) {
  switch (verdict) {
    case SharedLearnerFeedbackVerdictV1.fail:
      if (comparisonStyle == SharedLearnerFeedbackComparisonStyleV1.strongerLine) {
        if (chosen != null) {
          return 'Better line: $expected. $chosen is weaker here.';
        }
        return 'Better line: $expected.';
      }
      if (chosen != null) {
        return 'Better answer: $expected. $chosen misses this scene.';
      }
      return 'Better answer: $expected.';
    case SharedLearnerFeedbackVerdictV1.softPass:
      if (comparisonStyle == SharedLearnerFeedbackComparisonStyleV1.strongerLine) {
        if (chosen != null) {
          return '$chosen works, but $expected is the stronger line here.';
        }
        return 'There is a stronger line here: $expected.';
      }
      if (chosen != null) {
        return '$chosen works, but $expected is the cleaner answer here.';
      }
      return 'There is a cleaner answer here: $expected.';
    case SharedLearnerFeedbackVerdictV1.correct:
      final confirmed = chosen ?? expected;
      if (comparisonStyle == SharedLearnerFeedbackComparisonStyleV1.strongerLine) {
        return '$confirmed is the stronger line here.';
      }
      return '$confirmed is the right answer here.';
  }
}

String? _normalizeFeedbackSegmentV1(String? source, {required String prefix}) {
  final normalized = _normalizeSentenceV1(source);
  if (normalized.isEmpty) {
    return null;
  }
  return '$prefix: $normalized';
}

String _normalizeDisplayLabelV1(String? source, {String? fallback}) {
  final normalized = source
      ?.trim()
      .replaceAll('_', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
  if (normalized == null || normalized.isEmpty) {
    return fallback ?? 'UNKNOWN';
  }
  return normalized;
}

String _normalizeSentenceV1(String? source) {
  if (source == null) {
    return '';
  }
  var value = source.trim();
  if (value.isEmpty) {
    return '';
  }
  value = value.replaceFirst(
    RegExp(r'^(expected|you chose|incorrect|correct|why|fix|notice|next time):\s*', caseSensitive: false),
    '',
  ).trim();
  value = value.replaceFirst(
    RegExp(r'^(incorrect|correct)\.\s*', caseSensitive: false),
    '',
  ).trim();
  if (value.isEmpty) {
    return '';
  }
  if (!value.endsWith('.')) {
    value = '$value.';
  }
  return value;
}
