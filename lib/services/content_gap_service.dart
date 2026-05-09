import 'dart:convert';
import 'dart:io';

const List<String> _requiredFiles = [
  'theory.md',
  'drills.jsonl',
  'demos.jsonl',
  'quiz.jsonl',
  'recap.md',
  'allowlist.txt',
];

class ModuleGapInfo {
  ModuleGapInfo({
    required this.module,
    required this.missingFiles,
    required this.missingConcepts,
    required this.densityWarnings,
    required this.anomalies,
    required this.passed,
  });

  final String module;
  final List<String> missingFiles;
  final List<String> missingConcepts;
  final List<String> densityWarnings;
  final List<String> anomalies;
  final bool passed;

  Map<String, Object?> toJson() => {
    'module': module,
    'missing_files': missingFiles,
    'missing_concepts': missingConcepts,
    'density_warnings': densityWarnings,
    'anomalies': anomalies,
    'passed': passed,
  };
}

class ContentGapService {
  const ContentGapService();

  Future<List<ModuleGapInfo>> analyze() async {
    final base = Directory('content');
    if (!await base.exists()) return [];
    final modules = <ModuleGapInfo>[];
    await for (final moduleDir in base.list(
      followLinks: false,
      recursive: false,
    )) {
      final moduleName = moduleDir.uri.pathSegments.lastWhere(
        (segment) => segment.isNotEmpty && segment != 'content',
        orElse: () => moduleDir.path,
      );
      final v1Dir = Directory('${moduleDir.path}/v1');
      if (!await v1Dir.exists()) continue;
      final missingFiles = <String>[];
      for (final file in _requiredFiles) {
        final candidate = File('${v1Dir.path}/$file');
        if (!await candidate.exists()) {
          missingFiles.add(file);
          continue;
        }
        if (!await _isFileAscii(candidate)) {
          missingFiles.add(file);
        }
        if (file == 'allowlist.txt' && await candidate.length() == 0) {
          missingFiles.add(file);
        }
      }
      final gapInfo = await _inspectModule(moduleName, v1Dir, missingFiles);
      modules.add(gapInfo);
    }
    return modules;
  }

  Future<ModuleGapInfo> _inspectModule(
    String module,
    Directory dir,
    List<String> missingFiles,
  ) async {
    final theoryFile = File('${dir.path}/theory.md');
    final drillsFile = File('${dir.path}/drills.jsonl');
    final demosFile = File('${dir.path}/demos.jsonl');
    final quizFile = File('${dir.path}/quiz.jsonl');
    final allowlistFile = File('${dir.path}/allowlist.txt');

    final theoryKeywords = await _extractKeywords(
      await _readAscii(theoryFile.path),
    );
    final drillsTags = await _extractTags(
      drillsFile.path,
      skipIfMissing: missingFiles.isNotEmpty,
    );
    final demosTags = await _extractTags(
      demosFile.path,
      skipIfMissing: missingFiles.isNotEmpty,
    );
    final allowlist = await _readAscii(allowlistFile.path);

    final missingConcepts = <String>[];
    for (final keyword in theoryKeywords) {
      if (!drillsTags.contains(keyword) &&
          !demosTags.contains(keyword) &&
          !_containsInFile(keyword, quizFile)) {
        missingConcepts.add(keyword);
      }
    }
    for (final allow in allowlist.split('\n')) {
      final trimmed = allow.trim().toLowerCase();
      if (trimmed.isEmpty) continue;
      if (!theoryKeywords.contains(trimmed) &&
          !drillsTags.contains(trimmed) &&
          !demosTags.contains(trimmed)) {
        missingConcepts.add(trimmed);
      }
    }

    final densityWarnings = <String>[];
    final drillsCount = await _lineCount(drillsFile);
    final demosCount = await _lineCount(demosFile);
    if (demosCount == 0 && drillsCount > 0) {
      densityWarnings.add('demo_count_zero');
    } else if (drillsCount == 0 && demosCount > 0) {
      densityWarnings.add('drill_count_zero');
    } else if (drillsCount > demosCount * 3) {
      densityWarnings.add('drills_heavy');
    } else if (demosCount > drillsCount * 3) {
      densityWarnings.add('demos_heavy');
    }
    final anomalies = <String>[];
    if (await quizFile.exists() && theoryKeywords.length < 50) {
      anomalies.add('small_theory_set');
    }
    final allowlistContent = allowlist.trim();
    if (allowlistContent.isEmpty) {
      missingFiles.add('allowlist.txt');
    }
    missingConcepts.sort();
    final passed =
        missingFiles.isEmpty &&
        missingConcepts.isEmpty &&
        allowlistContent.isNotEmpty;
    return ModuleGapInfo(
      module: module,
      missingFiles: missingFiles,
      missingConcepts: missingConcepts,
      densityWarnings: densityWarnings,
      anomalies: anomalies,
      passed: passed,
    );
  }

  Future<String> _readAscii(String path) async {
    final file = File(path);
    if (!await file.exists()) return '';
    final content = await file.readAsString();
    if (!_isAscii(content)) return '';
    return content;
  }

  bool _isAscii(String content) {
    for (final code in content.codeUnits) {
      if (code > 127) return false;
    }
    return true;
  }

  Future<Set<String>> _extractKeywords(String text) async {
    if (text.isEmpty) return {};
    final tokens = text
        .toLowerCase()
        .split(RegExp(r'[^a-z]+'))
        .where((token) => token.isNotEmpty);
    return tokens.toSet();
  }

  Future<Set<String>> _extractTags(
    String path, {
    bool skipIfMissing = false,
  }) async {
    final file = File(path);
    if (!await file.exists()) return {};
    final tags = <String>{};
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final decoded = json.decode(line) as Map<String, dynamic>;
        if (decoded['tags'] is List) {
          for (final tag in decoded['tags']) {
            if (tag is String) tags.add(tag.toLowerCase());
          }
        }
      } catch (_) {
        if (!skipIfMissing) rethrow;
      }
    }
    return tags;
  }

  Future<int> _lineCount(File file) async {
    if (!await file.exists()) return 0;
    return await file.readAsLines().then((lines) => lines.length);
  }

  bool _containsInFile(String keyword, File file) {
    if (!file.existsSync()) return false;
    final content = file.readAsStringSync().toLowerCase();
    return content.contains(keyword);
  }

  Future<bool> _isFileAscii(File file) async {
    final content = await file.readAsBytes();
    for (final byte in content) {
      if (byte > 127) return false;
    }
    return true;
  }
}
