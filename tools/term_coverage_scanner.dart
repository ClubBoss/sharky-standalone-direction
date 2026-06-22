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

  final referenceOnly = (contract['reference_only_tokens'] as List<dynamic>)
      .map((entry) => (entry as Map<String, dynamic>)['term'] as String)
      .join(', ');
  stdout.writeln('active learner session files: ${activeFiles.length}');
  stdout.writeln(
    'priority terms checked: ${terms.map((term) => term.term).join(', ')}',
  );
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
