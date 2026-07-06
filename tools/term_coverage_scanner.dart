import 'dart:convert';
import 'dart:io';

class _PriorityTerm {
  const _PriorityTerm({
    required this.term,
    required this.introductionPath,
    required this.definition,
  });

  final String term;
  final String introductionPath;
  final String definition;
}

class _BeginnerTermGuard {
  const _BeginnerTermGuard({
    required this.guardedPaths,
    required this.terms,
    required this.blockedUnownedAliases,
  });

  final List<String> guardedPaths;
  final List<_BeginnerTerm> terms;
  final List<String> blockedUnownedAliases;
}

class _BeginnerTerm {
  const _BeginnerTerm({
    required this.term,
    required this.canonicalForm,
    required this.aliases,
    required this.firstPermittedAppearance,
    required this.firstExplanation,
    required this.firstContextualDemonstration,
    required this.firstPermittedAssessment,
    required this.laterReuse,
  });

  final String term;
  final String canonicalForm;
  final List<String> aliases;
  final _EvidenceLocator firstPermittedAppearance;
  final _EvidenceLocator firstExplanation;
  final _EvidenceLocator firstContextualDemonstration;
  final _EvidenceLocator firstPermittedAssessment;
  final _EvidenceLocator laterReuse;
}

class _EvidenceLocator {
  const _EvidenceLocator({required this.path, required this.contains});

  final String path;
  final String contains;
}

class _TextLocation implements Comparable<_TextLocation> {
  const _TextLocation({
    required this.path,
    required this.sequence,
    required this.offset,
  });

  final String path;
  final int sequence;
  final int offset;

  @override
  int compareTo(_TextLocation other) {
    final sequenceComparison = sequence.compareTo(other.sequence);
    if (sequenceComparison != 0) return sequenceComparison;
    return offset.compareTo(other.offset);
  }
}

void main(List<String> arguments) {
  final rootPath = _readRootPath(arguments);
  final root = Directory(rootPath);
  final contractFile = File(
    '${root.path}/content/_meta/term_introduction_contract_v1.json',
  );

  if (!contractFile.existsSync()) {
    _fail('Term introduction contract missing: ${contractFile.path}');
  }

  final contract =
      jsonDecode(contractFile.readAsStringSync()) as Map<String, dynamic>;
  final terms = _readPriorityTerms(contract);
  final activeRoot = Directory(
    '${root.path}/${contract['active_learner_content_root'] as String}',
  );
  if (!activeRoot.existsSync()) {
    _fail('Active learner content root missing: ${activeRoot.path}');
  }

  final violations = <String>[];
  final activeFiles = _activeSessionFiles(activeRoot, root.path);

  for (final term in terms) {
    final introductionFile = File('${root.path}/${term.introductionPath}');
    if (!introductionFile.existsSync()) {
      violations.add(
        '${term.term}: introduction source missing: ${term.introductionPath}',
      );
      continue;
    }
    final introductionLines = introductionFile.readAsLinesSync();
    final definitionLine = introductionLines.indexWhere(
      (line) => line.contains(term.definition),
    );
    if (definitionLine == -1) {
      violations.add(
        '${term.term}: introduction definition missing from ${term.introductionPath}',
      );
      continue;
    }

    final introductionOrder = _curriculumOrder(term.introductionPath);
    if (introductionOrder == null) {
      violations.add(
        '${term.term}: introduction path is not an active session source: '
        '${term.introductionPath}',
      );
      continue;
    }

    final pattern = RegExp(
      '\\b${RegExp.escape(term.term)}\\b',
      caseSensitive: false,
    );
    for (var index = 0; index < definitionLine; index++) {
      if (pattern.hasMatch(introductionLines[index])) {
        violations.add(
          '${term.term}: use appears before its definition at '
          '${term.introductionPath}:${index + 1}',
        );
      }
    }
    for (final file in activeFiles) {
      final relativePath = _relativePath(root.path, file.path);
      final order = _curriculumOrder(relativePath);
      if (order == null || order.compareTo(introductionOrder) >= 0) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        if (pattern.hasMatch(lines[index])) {
          violations.add(
            '${term.term}: pre-introduction use at $relativePath:${index + 1}',
          );
        }
      }
    }
  }

  final beginnerGuard = _readBeginnerGuard(contract);
  if (beginnerGuard != null) {
    _scanBeginnerTerms(
      rootPath: root.path,
      guard: beginnerGuard,
      violations: violations,
    );
  }

  final referenceOnly = (contract['reference_only_tokens'] as List<dynamic>)
      .map((entry) => (entry as Map<String, dynamic>)['term'] as String)
      .join(', ');
  stdout.writeln('active learner session files: ${activeFiles.length}');
  stdout.writeln(
    'priority terms checked: ${terms.map((term) => term.term).join(', ')}',
  );
  if (beginnerGuard != null) {
    stdout.writeln(
      'beginner terms checked: '
      '${beginnerGuard.terms.map((term) => term.term).join(', ')}',
    );
  }
  stdout.writeln('reference-only tokens excluded: $referenceOnly');

  if (violations.isNotEmpty) {
    stderr.writeln('Term introduction safety violations:');
    for (final violation in violations) {
      stderr.writeln('- $violation');
    }
    exit(1);
  }

  stdout.writeln('term introduction safety: PASS');
}

String _readRootPath(List<String> arguments) {
  final rootIndex = arguments.indexOf('--root');
  if (rootIndex == -1) {
    return Directory.current.path;
  }
  if (rootIndex + 1 >= arguments.length) {
    _fail('Missing value for --root');
  }
  return arguments[rootIndex + 1];
}

List<_PriorityTerm> _readPriorityTerms(Map<String, dynamic> contract) {
  final rawTerms = contract['priority_terms'];
  if (rawTerms is! List<dynamic>) {
    _fail('Term introduction contract must contain priority_terms.');
  }
  return rawTerms
      .map((rawTerm) {
        final term = rawTerm as Map<String, dynamic>;
        return _PriorityTerm(
          term: term['term'] as String,
          introductionPath: term['introduction_path'] as String,
          definition: term['definition'] as String,
        );
      })
      .toList(growable: false);
}

_BeginnerTermGuard? _readBeginnerGuard(Map<String, dynamic> contract) {
  final rawGuard = contract['beginner_term_guard'];
  if (rawGuard == null) return null;
  if (rawGuard is! Map<String, dynamic>) {
    _fail('beginner_term_guard must be an object.');
  }
  final rawGuardedPaths = rawGuard['guarded_paths'];
  if (rawGuardedPaths is! List<dynamic>) {
    _fail('beginner_term_guard must contain guarded_paths.');
  }
  final rawTerms = rawGuard['terms'];
  if (rawTerms is! List<dynamic>) {
    _fail('beginner_term_guard must contain terms.');
  }
  final rawBlocked = rawGuard['blocked_unowned_aliases'];
  return _BeginnerTermGuard(
    guardedPaths: rawGuardedPaths.cast<String>().toList(growable: false),
    terms: rawTerms
        .map((rawTerm) {
          final term = rawTerm as Map<String, dynamic>;
          return _BeginnerTerm(
            term: term['term'] as String,
            canonicalForm: term['canonical_form'] as String,
            aliases: (term['aliases'] as List<dynamic>).cast<String>().toList(
              growable: false,
            ),
            firstPermittedAppearance: _readEvidenceLocator(
              term['first_permitted_appearance'],
              '${term['term']}.first_permitted_appearance',
            ),
            firstExplanation: _readEvidenceLocator(
              term['first_explanation'],
              '${term['term']}.first_explanation',
            ),
            firstContextualDemonstration: _readEvidenceLocator(
              term['first_contextual_demonstration'],
              '${term['term']}.first_contextual_demonstration',
            ),
            firstPermittedAssessment: _readEvidenceLocator(
              term['first_permitted_assessment'],
              '${term['term']}.first_permitted_assessment',
            ),
            laterReuse: _readEvidenceLocator(
              term['later_reuse'],
              '${term['term']}.later_reuse',
            ),
          );
        })
        .toList(growable: false),
    blockedUnownedAliases: rawBlocked is List<dynamic>
        ? rawBlocked.cast<String>().toList(growable: false)
        : const <String>[],
  );
}

_EvidenceLocator _readEvidenceLocator(Object? raw, String fieldName) {
  if (raw is! Map<String, dynamic>) {
    _fail('$fieldName must be an evidence locator.');
  }
  return _EvidenceLocator(
    path: raw['path'] as String,
    contains: raw['contains'] as String,
  );
}

void _scanBeginnerTerms({
  required String rootPath,
  required _BeginnerTermGuard guard,
  required List<String> violations,
}) {
  final sequence = <String, int>{
    for (var index = 0; index < guard.guardedPaths.length; index++)
      guard.guardedPaths[index]: index,
  };
  final guardedText = <String, String>{};
  for (final path in guard.guardedPaths) {
    final file = File('$rootPath/$path');
    if (!file.existsSync()) {
      violations.add('beginner guard source missing: $path');
      continue;
    }
    guardedText[path] = file.readAsStringSync();
  }

  for (final blockedAlias in guard.blockedUnownedAliases) {
    final pattern = _termPattern(blockedAlias);
    for (final entry in guardedText.entries) {
      if (pattern.hasMatch(entry.value)) {
        violations.add(
          'blocked unowned beginner alias "$blockedAlias" appears in '
          '${entry.key}',
        );
      }
    }
  }

  for (final term in guard.terms) {
    if (term.aliases.isEmpty) {
      violations.add('${term.term}: must declare at least one alias');
      continue;
    }

    final appearance = _findEvidence(
      rootPath: rootPath,
      sequence: sequence,
      locator: term.firstPermittedAppearance,
      violations: violations,
      label: '${term.term}: first permitted appearance',
    );
    final explanation = _findEvidence(
      rootPath: rootPath,
      sequence: sequence,
      locator: term.firstExplanation,
      violations: violations,
      label: '${term.term}: first explanation',
    );
    final context = _findEvidence(
      rootPath: rootPath,
      sequence: sequence,
      locator: term.firstContextualDemonstration,
      violations: violations,
      label: '${term.term}: first contextual demonstration',
    );
    final assessment = _findEvidence(
      rootPath: rootPath,
      sequence: sequence,
      locator: term.firstPermittedAssessment,
      violations: violations,
      label: '${term.term}: first permitted assessment',
    );
    final laterReuse = _findEvidence(
      rootPath: rootPath,
      sequence: sequence,
      locator: term.laterReuse,
      violations: violations,
      label: '${term.term}: later reuse',
    );

    if (appearance == null ||
        explanation == null ||
        context == null ||
        assessment == null ||
        laterReuse == null) {
      continue;
    }
    if (explanation.compareTo(appearance) < 0) {
      violations.add('${term.term}: explanation appears before appearance');
    }
    if (context.compareTo(explanation) < 0) {
      violations.add(
        '${term.term}: abbreviation/context appears before explanation',
      );
    }
    if (assessment.compareTo(explanation) < 0) {
      violations.add('${term.term}: assessment appears before explanation');
    }
    if (assessment.compareTo(context) < 0) {
      violations.add(
        '${term.term}: assessment appears before contextual demonstration',
      );
    }
    if (laterReuse.compareTo(assessment) < 0) {
      violations.add('${term.term}: later reuse appears before assessment');
    }

    for (final alias in term.aliases) {
      final firstAlias = _findFirstAlias(
        alias: alias,
        guardedText: guardedText,
        sequence: sequence,
      );
      if (firstAlias == null) {
        violations.add('${term.term}: alias "$alias" never appears');
        continue;
      }
      if (firstAlias.compareTo(appearance) < 0) {
        violations.add(
          '${term.term}: alias "$alias" appears before first permitted '
          'appearance at ${firstAlias.path}',
        );
      }
      if (_isAbbreviation(alias) && firstAlias.compareTo(explanation) < 0) {
        violations.add(
          '${term.term}: abbreviation/context appears before explanation',
        );
      }
    }
  }
}

_TextLocation? _findEvidence({
  required String rootPath,
  required Map<String, int> sequence,
  required _EvidenceLocator locator,
  required List<String> violations,
  required String label,
}) {
  final file = File('$rootPath/${locator.path}');
  if (!file.existsSync()) {
    violations.add('$label source missing: ${locator.path}');
    return null;
  }
  final text = file.readAsStringSync();
  final offset = text.indexOf(locator.contains);
  if (offset == -1) {
    violations.add('$label snippet missing from ${locator.path}');
    return null;
  }
  return _TextLocation(
    path: locator.path,
    sequence: _sequenceForPath(locator.path, sequence),
    offset: offset,
  );
}

_TextLocation? _findFirstAlias({
  required String alias,
  required Map<String, String> guardedText,
  required Map<String, int> sequence,
}) {
  _TextLocation? first;
  final pattern = _termPattern(alias);
  for (final entry in guardedText.entries) {
    final match = pattern.firstMatch(entry.value);
    if (match == null) continue;
    final location = _TextLocation(
      path: entry.key,
      sequence: _sequenceForPath(entry.key, sequence),
      offset: match.start + (match.group(1)?.length ?? 0),
    );
    if (first == null || location.compareTo(first) < 0) {
      first = location;
    }
  }
  return first;
}

RegExp _termPattern(String term) {
  return RegExp(
    r'(^|[^A-Za-z0-9_])' + RegExp.escape(term) + r'(?=[^A-Za-z0-9_]|$)',
    caseSensitive: false,
  );
}

bool _isAbbreviation(String alias) {
  final lettersOnly = alias.replaceAll(RegExp(r'[^A-Za-z]'), '');
  return lettersOnly.length >= 2 && lettersOnly == lettersOnly.toUpperCase();
}

int _sequenceForPath(String path, Map<String, int> sequence) {
  final direct = sequence[path];
  if (direct != null) return direct;
  final order = _curriculumOrder(path);
  if (order == null) return sequence.length + 100000;
  return sequence.length +
      (order.world * 10000) +
      (order.session * 100) +
      order.sourceRank;
}

List<File> _activeSessionFiles(Directory activeRoot, String rootPath) {
  final files = activeRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) {
        final path = _relativePath(rootPath, file.path);
        return _curriculumOrder(path) != null &&
            (path.endsWith('.md') || path.endsWith('.json'));
      })
      .toList(growable: false);
  files.sort((left, right) {
    final leftOrder = _curriculumOrder(_relativePath(rootPath, left.path))!;
    final rightOrder = _curriculumOrder(_relativePath(rootPath, right.path))!;
    return leftOrder.compareTo(rightOrder);
  });
  return files;
}

_CurriculumOrder? _curriculumOrder(String path) {
  final normalized = path.replaceAll('\\', '/');
  final match = RegExp(
    r'world(\d+)/v1/(?:sessions/w\d+\.s(\d+)|tracks/[^/]+/sessions/[^/]+\.s(\d+))/(.*)$',
  ).firstMatch(normalized);
  if (match == null) {
    return null;
  }
  final trailingPath = match.group(4)!;
  return _CurriculumOrder(
    world: int.parse(match.group(1)!),
    session: int.parse(match.group(2) ?? match.group(3)!),
    sourceRank: trailingPath == 'session.md' ? 0 : 1,
    path: trailingPath,
  );
}

String _relativePath(String rootPath, String path) {
  final normalizedRoot = rootPath
      .replaceAll('\\', '/')
      .replaceFirst(RegExp(r'/$'), '');
  final normalizedPath = path.replaceAll('\\', '/');
  return normalizedPath.startsWith('$normalizedRoot/')
      ? normalizedPath.substring(normalizedRoot.length + 1)
      : normalizedPath;
}

class _CurriculumOrder implements Comparable<_CurriculumOrder> {
  const _CurriculumOrder({
    required this.world,
    required this.session,
    required this.sourceRank,
    required this.path,
  });

  final int world;
  final int session;
  final int sourceRank;
  final String path;

  @override
  int compareTo(_CurriculumOrder other) {
    final worldComparison = world.compareTo(other.world);
    if (worldComparison != 0) return worldComparison;
    final sessionComparison = session.compareTo(other.session);
    if (sessionComparison != 0) return sessionComparison;
    final sourceComparison = sourceRank.compareTo(other.sourceRank);
    if (sourceComparison != 0) return sourceComparison;
    return path.compareTo(other.path);
  }
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
