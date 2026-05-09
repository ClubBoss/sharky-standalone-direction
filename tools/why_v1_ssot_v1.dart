const Set<String> kWhyV1StagedSessionsV1 = <String>{
  'w1.s01',
  'w1.s02',
  'w1.s03',
  'w2.s01',
  'w2.s02',
  'w2.s03',
  'w3.s01',
  'w3.s02',
  'w3.s03',
  'w4.s01',
  'w4.s02',
  'w4.s03',
  'w5.s01',
  'w5.s02',
  'w5.s03',
  'w6.s01',
  'w6.s02',
  'w6.s03',
  'w7.s01',
  'w7.s02',
  'w7.s03',
  'w8.s01',
  'w8.s02',
  'w8.s03',
  'w9.s01',
  'w9.s02',
  'w9.s03',
};

int? worldIndexFromSessionIdV1(String sessionId) {
  final match = RegExp(r'^w(\d+)\.s\d{2}$').firstMatch(sessionId);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

bool isRuntimeValidWhyV1V1(Object? raw) {
  if (raw is! String) return false;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.contains('\n') || trimmed.contains('\r')) return false;
  if (trimmed.length < 8 || trimmed.length > 140) return false;
  for (final unit in trimmed.codeUnits) {
    if (unit < 32 || unit > 126) return false;
  }
  if (_isPlaceholderWhyV1V1(trimmed)) return false;
  return true;
}

bool hasFeedbackLabelMismatchV1({
  required Object? feedbackCorrectV1,
  required Object? feedbackIncorrectV1,
}) {
  final correct = _normalizeFeedbackV1(feedbackCorrectV1);
  if (correct != null && correct.startsWith('incorrect')) {
    return true;
  }
  final incorrect = _normalizeFeedbackV1(feedbackIncorrectV1);
  if (incorrect != null && incorrect.startsWith('correct')) {
    return true;
  }
  return false;
}

bool hasPrimaryCorrectContradictionV1(Object? feedbackCorrectV1) {
  final correct = _normalizeFeedbackV1(feedbackCorrectV1);
  if (correct == null) return false;
  return _kPrimaryCorrectContradictionSoftPassV1.hasMatch(correct);
}

bool hasGenericAcceptableFeedbackV1(Object? feedbackAcceptableV1) {
  final acceptable = _normalizeFeedbackV1(feedbackAcceptableV1);
  if (acceptable == null) return false;
  if (!acceptable.startsWith('acceptable.')) return true;
  if (_kGenericAcceptableFeedbackV1.hasMatch(acceptable)) return true;
  return false;
}

bool hasGenericIncorrectFeedbackV1(Object? feedbackIncorrectV1) {
  final incorrect = _normalizeFeedbackV1(feedbackIncorrectV1);
  if (incorrect == null) return false;
  if (!incorrect.startsWith('incorrect.')) return true;
  if (_kGenericIncorrectFeedbackV1.hasMatch(incorrect)) return true;
  return false;
}

bool hasSessionTodoPlaceholderLeakV1(Object? sessionTextRaw) {
  if (sessionTextRaw is! String) return false;
  return _kSessionTodoPlaceholderLeakV1.hasMatch(sessionTextRaw);
}

bool hasPromptAnswerLeakV1(Object? promptRaw) {
  final prompt = _normalizeFeedbackV1(promptRaw);
  if (prompt == null) return false;
  for (final marker in _kPromptLeakMarkersV1) {
    if (prompt.contains(marker)) return true;
  }
  if (_kPromptLeakActionCueV1.hasMatch(prompt)) return true;
  if (_kPromptLeakTemplateCueV1.hasMatch(prompt)) return true;
  if (_kPromptLeakOrdinalCueTemplateV1.hasMatch(prompt)) return true;
  if (_kPromptLeakProxyCueTemplateV1.hasMatch(prompt)) return true;
  return false;
}

bool hasDirectChooseActionPromptLeakV1(Object? promptRaw) {
  final prompt = _normalizeFeedbackV1(promptRaw);
  if (prompt == null) return false;
  return _kDirectChooseActionPromptLeakV1.hasMatch(prompt);
}

bool hasActionFocusCueLeakV1(Object? promptRaw) {
  final prompt = _normalizeFeedbackV1(promptRaw);
  if (prompt == null) return false;
  return _kActionFocusCueLeakV1.hasMatch(prompt);
}

const List<String> _kPromptLeakMarkersV1 = <String>[
  'choose the expected action',
  'expected action',
  'expected answer',
  'correct answer',
  'answer is',
  'proxy asks for',
];

final RegExp _kPromptLeakActionCueV1 = RegExp(
  r'\b(?:tap|click)\s+(?:fold|call|raise|check|jam|all-in)\b',
);

final RegExp _kPromptLeakTemplateCueV1 = RegExp(
  r'\bin this(?: [a-z0-9_-]+){0,6} spot,\s*choose\s+(?:fold|call|raise|check|jam|all-in)(?:\.|$)',
);

final RegExp _kPromptLeakOrdinalCueTemplateV1 = RegExp(
  r'\bwhen the (?:first|second|third|fourth|fifth|sixth|seventh|eighth|ninth|tenth) cue appears,\s*choose\s+(?:fold|call|raise|check|jam|all-in)(?:\.|$)',
);

final RegExp _kPromptLeakProxyCueTemplateV1 = RegExp(
  r'\bproxy\b[^.]{0,120}\bchoose\s+(?:fold|call|raise|check|jam|all-in)\b',
);

final RegExp _kDirectChooseActionPromptLeakV1 = RegExp(
  r'^choose\s+(?:fold|call|raise)\.?$',
);

final RegExp _kActionFocusCueLeakV1 = RegExp(
  r'\bfocus:\s*(?:fold|call|raise|check|bet|jam|all-in)\b',
  caseSensitive: false,
);

final RegExp _kSessionTodoPlaceholderLeakV1 = RegExp(
  r'(^|\s)TODO($|\s)',
  caseSensitive: false,
  multiLine: true,
);

final RegExp _kPrimaryCorrectContradictionSoftPassV1 = RegExp(
  r'\bworse than our recommended play\b',
);

final RegExp _kGenericAcceptableFeedbackV1 = RegExp(
  r'^acceptable\.\s*(?:'
  r'legal,? but worse than (?:our )?recommended play|'
  r'this is legal but weaker|'
  r'this is weaker|'
  r'weaker but okay|'
  r'fine but weaker|'
  r'ok but weaker'
  r')\.?$',
);

final RegExp _kGenericIncorrectFeedbackV1 = RegExp(
  r'^incorrect\.\s*(?:'
  r'try again|'
  r'that is weaker|'
  r'not the best play|'
  r'wrong choice|'
  r'wrong'
  r')?\.?$',
);

bool _isPlaceholderWhyV1V1(String value) {
  final normalized = value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) return true;
  if (normalized == 'todo' ||
      normalized == 'tbd' ||
      normalized == 'placeholder' ||
      normalized == 'lorem ipsum' ||
      normalized == 'coming soon' ||
      normalized == 'n/a' ||
      normalized == 'na') {
    return true;
  }
  if (normalized.startsWith('todo ') ||
      normalized.startsWith('tbd ') ||
      normalized.startsWith('placeholder ')) {
    return true;
  }
  return false;
}

String? _normalizeFeedbackV1(Object? raw) {
  if (raw is! String) return null;
  final normalized = raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) return null;
  return normalized;
}

bool sessionHasAtLeastOneValidWhyV1V1({
  required List<Map<String, Object?>> drillJsonsOrRawWhyValues,
}) {
  for (final entry in drillJsonsOrRawWhyValues) {
    final candidate = entry.containsKey('why_v1')
        ? entry['why_v1']
        : (entry.containsKey('value') ? entry['value'] : entry['raw']);
    if (isRuntimeValidWhyV1V1(candidate)) {
      return true;
    }
  }
  return false;
}
