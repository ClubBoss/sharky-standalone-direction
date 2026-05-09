import 'dart:convert';
import 'dart:io';

const Set<String> kAct0AllowedVersionFilesV1 = <String>{
  'theory.md',
  'drills.jsonl',
  'manifest.json',
};

const List<String> kAct0TheoryRequiredSubstringsV1 = <String>[
  'Preflop starts left of the Big Blind.',
  'After the flop, action starts with the Small Blind',
];

const List<Pattern> kAct0ForbiddenStrategyPatternsV1 = <Pattern>[
  'always',
  'never',
  'you should',
  'must raise',
  'must bet',
  'must call',
  'must fold',
];

const List<String> kAct0AntiJargonTokensV2 = <String>[
  'top pair',
  'kicker',
  'range',
];

const int kDefinitionWindowLinesV2 = 3;
const int kMaxBulletBlockLinesV2 = 12;

class ContentQualityValidationResultV1 {
  ContentQualityValidationResultV1({
    required this.filesChecked,
    required this.errors,
  });

  final int filesChecked;
  final List<String> errors;

  bool get isSuccess => errors.isEmpty;
}

Future<ContentQualityValidationResultV1> validateContentVersionDirV1(
  Directory dir,
) async {
  final errors = <String>[];
  var filesChecked = 0;

  final files = dir.listSync(followLinks: false).whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    filesChecked += 1;
    final name = file.uri.pathSegments.last;
    try {
      final content = await file.readAsString();
      if (name == 'theory.md') {
        _validateTheoryFileV1(file, content, errors);
      } else if (name == 'drills.jsonl') {
        _validateDrillsJsonlFileV1(file, content, errors);
      } else if (name == 'manifest.json') {
        _validateManifestJsonFileV1(file, content, errors);
      }
    } catch (e) {
      errors.add('${_relativePathV1(file.path)}: read failed ($e)');
    }
  }

  _validateAllowedLayoutV1(dir, files, errors);

  return ContentQualityValidationResultV1(
    filesChecked: filesChecked,
    errors: errors,
  );
}

void _validateAllowedLayoutV1(
  Directory dir,
  List<File> files,
  List<String> errors,
) {
  final moduleId = _inferModuleIdFromPathV1(dir.path);
  if (!moduleId.startsWith('world1_act0_')) {
    return;
  }
  final unexpected =
      files
          .map((f) => f.uri.pathSegments.last)
          .where((name) => !kAct0AllowedVersionFilesV1.contains(name))
          .toList()
        ..sort();
  if (unexpected.isNotEmpty) {
    errors.add(
      '${_relativePathV1(dir.path)}: unexpected files for Act0 bundle: ${unexpected.join(', ')}',
    );
  }
}

void _validateTheoryFileV1(File file, String content, List<String> errors) {
  final rel = _relativePathV1(file.path);
  if (content.trim().isEmpty) {
    errors.add('$rel empty markdown');
    return;
  }
  if (!content.contains('#')) {
    errors.add('$rel missing heading marker (#)');
  }

  final moduleId = _inferModuleIdFromPathV1(file.path);
  if (_isAct0ModuleV1(moduleId)) {
    final normalized = content.toLowerCase();
    for (final pattern in kAct0ForbiddenStrategyPatternsV1) {
      final text = pattern.toString().toLowerCase();
      if (normalized.contains(text)) {
        errors.add('$rel contains forbidden Act0 strategy language: "$text"');
      }
    }
    _validateMarkdownDensityV1(rel, content, errors);
    _validateAct0AntiJargonV2(rel, content, errors);
    _validateBlindCapitalizationV2(rel, content, errors);
  }
  if (_isBeginnerScopeModuleV2(moduleId)) {
    _validateStreetTerminologyV2(rel, content, errors);
  }
  if (moduleId == 'world1_act0_table_literacy') {
    for (final needle in kAct0TheoryRequiredSubstringsV1) {
      if (!content.contains(needle)) {
        errors.add(
          '$rel missing required Act0 fundamentals line containing: "$needle"',
        );
      }
    }
    if (!content.contains('best five-card hand')) {
      errors.add('$rel missing required showdown best-five concept');
    }
    if (!content.contains('High Card (no pair)')) {
      errors.add(
        '$rel missing required hand ladder anchor: "High Card (no pair)"',
      );
    }
  }
}

bool _isAct0ModuleV1(String moduleId) => moduleId.startsWith('world1_act0_');

bool _isBeginnerScopeModuleV2(String moduleId) {
  return _isAct0ModuleV1(moduleId) || moduleId.startsWith('intro_');
}

void _validateAct0AntiJargonV2(
  String rel,
  String content,
  List<String> errors,
) {
  final lines = const LineSplitter().convert(content);
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final normalized = line.toLowerCase();
    for (final token in kAct0AntiJargonTokensV2) {
      if (!normalized.contains(token)) {
        continue;
      }
      if (_hasNearbyDefinitionMarkerV2(lines, i, token)) {
        continue;
      }
      errors.add(
        '$rel contains Act0 jargon without nearby definition: "$token"',
      );
    }
  }
}

bool _hasNearbyDefinitionMarkerV2(List<String> lines, int index, String token) {
  final start = (index - kDefinitionWindowLinesV2).clamp(0, lines.length - 1);
  final end = (index + kDefinitionWindowLinesV2).clamp(0, lines.length - 1);
  final tokenPattern = RegExp(
    '\\b${RegExp.escape(token)}\\b',
    caseSensitive: false,
  );
  for (var i = start; i <= end; i++) {
    final line = lines[i];
    if (line.contains('Definition:')) {
      return true;
    }
    if (tokenPattern.hasMatch(line) &&
        line.contains('(') &&
        line.contains(')')) {
      return true;
    }
  }
  return false;
}

void _validateBlindCapitalizationV2(
  String rel,
  String content,
  List<String> errors,
) {
  if (RegExp(r'\bbig blind\b').hasMatch(content)) {
    errors.add('$rel must capitalize "Big Blind" in Act0 theory');
  }
  if (RegExp(r'\bsmall blind\b').hasMatch(content)) {
    errors.add('$rel must capitalize "Small Blind" in Act0 theory');
  }
}

void _validateStreetTerminologyV2(
  String rel,
  String content,
  List<String> errors,
) {
  if (RegExp(r'(^|[.!?]\s+)preflop\b', multiLine: true).hasMatch(content)) {
    errors.add('$rel must capitalize "Preflop" at sentence start');
  }

  final lines = const LineSplitter().convert(content);
  final tokenPattern = RegExp(r'\b(Flop|Turn|River)\b');
  for (final line in lines) {
    for (final match in tokenPattern.allMatches(line)) {
      final prefix = line.substring(0, match.start);
      if (_isAllowedCapitalizedStreetUsageV2(prefix)) {
        continue;
      }
      final token = match.group(1)!;
      errors.add(
        '$rel must keep "$token" lowercase unless it starts a sentence, label, or defined link',
      );
    }
  }
}

bool _isAllowedCapitalizedStreetUsageV2(String prefix) {
  if (prefix.trim().isEmpty) {
    return true;
  }
  if (RegExp(r'^\s*[-*]\s*$').hasMatch(prefix)) {
    return true;
  }
  final trimmed = prefix.trimRight();
  if (trimmed.endsWith('[[')) {
    return true;
  }
  if (trimmed.endsWith('.') || trimmed.endsWith('!') || trimmed.endsWith('?')) {
    return true;
  }
  return false;
}

void _validateMarkdownDensityV1(
  String rel,
  String content,
  List<String> errors,
) {
  final lines = const LineSplitter().convert(content);
  final paragraphBuffer = <String>[];
  var bulletBlockLines = 0;

  void flushParagraph() {
    if (paragraphBuffer.isEmpty) return;
    final text = paragraphBuffer.join(' ').trim();
    if (text.length > 320) {
      errors.add('$rel has paragraph longer than 320 chars');
    }
    paragraphBuffer.clear();
  }

  void flushBulletBlock() {
    if (bulletBlockLines > kMaxBulletBlockLinesV2) {
      errors.add(
        '$rel has bullet block longer than $kMaxBulletBlockLinesV2 lines',
      );
    }
    bulletBlockLines = 0;
  }

  for (final rawLine in lines) {
    final line = rawLine.trimRight();
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      flushParagraph();
      flushBulletBlock();
      continue;
    }
    if (trimmed.startsWith('@') || trimmed.startsWith('#')) {
      flushParagraph();
      flushBulletBlock();
      continue;
    }
    if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      flushParagraph();
      bulletBlockLines += 1;
      continue;
    }
    flushBulletBlock();
    paragraphBuffer.add(trimmed);
  }

  flushParagraph();
  flushBulletBlock();
}

void _validateManifestJsonFileV1(
  File file,
  String content,
  List<String> errors,
) {
  if (content.trim().isEmpty) {
    errors.add('${_relativePathV1(file.path)} empty manifest');
    return;
  }
  try {
    final decoded = jsonDecode(content);
    if (decoded is! Map) {
      errors.add(
        '${_relativePathV1(file.path)} manifest must be a JSON object',
      );
    }
  } catch (e) {
    errors.add('${_relativePathV1(file.path)} invalid JSON ($e)');
  }
}

void _validateDrillsJsonlFileV1(
  File file,
  String content,
  List<String> errors,
) {
  final rel = _relativePathV1(file.path);
  final ids = <String>{};
  final lines = const LineSplitter().convert(content);

  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i].trim();
    if (raw.isEmpty) {
      continue;
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (e) {
      errors.add('$rel:${i + 1} invalid JSON ($e)');
      continue;
    }
    if (decoded is! Map) {
      errors.add('$rel:${i + 1} not an object');
      continue;
    }
    final entry = decoded.cast<String, dynamic>();
    final id = entry['id'];
    if (id is! String || id.trim().isEmpty) {
      errors.add('$rel:${i + 1} missing id');
    } else if (!ids.add(id.trim())) {
      errors.add('$rel:${i + 1} duplicate id: $id');
    }

    _requireNonEmptyStringIfPresentV1(rel, i + 1, entry, 'question', errors);
    _requireNonEmptyStringIfPresentV1(rel, i + 1, entry, 'prompt', errors);
    _requireNonEmptyStringIfPresentV1(
      rel,
      i + 1,
      entry,
      'instruction_text',
      errors,
    );
    _requireNonEmptyStringIfPresentV1(rel, i + 1, entry, 'goal_text', errors);

    final hasAnyPrompt =
        _hasNonEmptyStringV1(entry['question']) ||
        _hasNonEmptyStringV1(entry['prompt']) ||
        _hasNonEmptyStringV1(entry['instruction_text']) ||
        _hasNonEmptyStringV1(entry['goal']);
    if (!hasAnyPrompt) {
      errors.add('$rel:${i + 1} missing prompt/question/goal text');
    }

    final answerChoices = entry['answer_choices'];
    if (answerChoices is List) {
      final correctAnswer = entry['correct_answer'];
      if (correctAnswer is! String || correctAnswer.trim().isEmpty) {
        errors.add('$rel:${i + 1} choice drill missing correct_answer');
      } else {
        final matches = answerChoices.where((e) => e == correctAnswer).length;
        if (matches != 1) {
          errors.add(
            '$rel:${i + 1} choice drill must have exactly one matching correct_answer',
          );
        }
      }
    }

    final options = entry['options'];
    if (options is List) {
      final answer = entry['answer'];
      if (answer is! int || answer < 0 || answer >= options.length) {
        errors.add(
          '$rel:${i + 1} options drill must have exactly one valid answer index',
        );
      }
    }
  }
}

void _requireNonEmptyStringIfPresentV1(
  String rel,
  int lineNumber,
  Map<String, dynamic> entry,
  String key,
  List<String> errors,
) {
  if (!entry.containsKey(key)) {
    return;
  }
  final value = entry[key];
  if (value is! String || value.trim().isEmpty) {
    errors.add('$rel:$lineNumber empty $key');
  }
}

bool _hasNonEmptyStringV1(Object? value) {
  return value is String && value.trim().isNotEmpty;
}

String _inferModuleIdFromPathV1(String path) {
  final normalized = path.replaceAll('\\', '/');
  final marker = 'content/';
  final markerIndex = normalized.indexOf(marker);
  if (markerIndex < 0) {
    return 'unknown_module';
  }
  final remainder = normalized.substring(markerIndex + marker.length);
  final parts = remainder.split('/');
  if (parts.isEmpty || parts.first.trim().isEmpty) {
    return 'unknown_module';
  }
  return parts.first.trim();
}

String _relativePathV1(String path) {
  final root = Directory.current.path;
  if (path.startsWith(root)) {
    return path.substring(root.length + 1);
  }
  return path;
}
