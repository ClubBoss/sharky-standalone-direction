import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class ContentReplayabilityService {
  static const _requiredFiles = <String>[
    'theory.md',
    'recap.md',
    'allowlist.txt',
    'drills.jsonl',
    'demos.jsonl',
    'quiz.jsonl',
  ];

  const ContentReplayabilityService();

  Future<ContentReplayabilityResult> run() async {
    final brokenModules = <String>[];
    final moduleIssues = <String, List<String>>{};

    final contentDir = Directory('content');
    if (!await contentDir.exists()) {
      return _buildResult(brokenModules, moduleIssues);
    }

    await for (final entry in contentDir.list(followLinks: false)) {
      if (entry is! Directory) {
        continue;
      }
      final moduleName = entry.uri.pathSegments.isNotEmpty
          ? entry.uri.pathSegments.last
          : entry.path;
      final moduleV1 = Directory('${entry.path}/v1');
      if (!await moduleV1.exists()) {
        continue;
      }
      final issues = await _validateModule(moduleName, moduleV1);
      if (issues.isNotEmpty) {
        brokenModules.add(moduleName);
        moduleIssues[moduleName] = issues;
      }
    }

    return _buildResult(brokenModules, moduleIssues);
  }

  Future<List<String>> _validateModule(
    String moduleName,
    Directory moduleV1,
  ) async {
    final issues = <String>[];

    for (final fileName in _requiredFiles) {
      final file = File('${moduleV1.path}/$fileName');
      if (!await file.exists()) {
        issues.add('$fileName missing');
        continue;
      }

      final readResult = await _readAsciiNonEmpty(file);
      if (!readResult.ok) {
        issues.add('$fileName: ${readResult.reason}');
        continue;
      }

      final content = readResult.content!;
      if (fileName == 'theory.md' || fileName == 'recap.md') {
        if (content.trim().isEmpty) {
          issues.add('$fileName: zero-length content');
        }
        continue;
      }

      if (fileName == 'allowlist.txt') {
        _validateAllowlist(content, issues);
        continue;
      }

      if (fileName == 'drills.jsonl') {
        _validateJsonl(
          moduleName,
          fileName,
          content,
          issues,
          requiredFields: ['action', 'spot', 'metadata'],
        );
        continue;
      }

      if (fileName == 'demos.jsonl') {
        _validateJsonl(
          moduleName,
          fileName,
          content,
          issues,
          requiredFields: ['action', 'spot', 'metadata'],
        );
        continue;
      }

      if (fileName == 'quiz.jsonl') {
        _validateJsonl(
          moduleName,
          fileName,
          content,
          issues,
          requiredFields: ['question', 'options'],
        );
        continue;
      }
    }

    return issues;
  }

  void _validateAllowlist(String content, List<String> issues) {
    final lines = content.split(RegExp(r'\r?\n'));
    final meaningful = lines.where((line) => line.trim().isNotEmpty).toList();
    if (meaningful.isEmpty) {
      issues.add('allowlist.txt: no entries');
    }
  }

  void _validateJsonl(
    String moduleName,
    String fileName,
    String content,
    List<String> issues, {
    required List<String> requiredFields,
  }) {
    final lines = content.split(RegExp(r'\r?\n'));
    var hasEntry = false;
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index].trim();
      if (line.isEmpty) {
        continue;
      }
      hasEntry = true;
      Map<String, dynamic>? entry;
      try {
        final decoded = jsonDecode(line);
        if (decoded is! Map) {
          issues.add(
            '$moduleName/$fileName line ${index + 1}: expected object',
          );
          continue;
        }
        entry = Map<String, dynamic>.from(decoded);
      } on FormatException catch (error) {
        issues.add(
          '$fileName line ${index + 1}: invalid JSON (${error.message})',
        );
        continue;
      }
      for (final field in requiredFields) {
        _validateField(fileName, index + 1, field, entry[field], issues);
      }
    }
    if (!hasEntry) {
      issues.add('$moduleName/$fileName: no entries');
    }
  }

  void _validateField(
    String fileName,
    int line,
    String field,
    Object? value,
    List<String> issues,
  ) {
    final descriptor = '$fileName line $line';
    if (value == null) {
      issues.add('$descriptor: missing $field');
      return;
    }
    if (field == 'action' || field == 'spot' || field == 'question') {
      if (value is! String || value.trim().isEmpty) {
        issues.add('$descriptor: $field must be a non-empty string');
      }
      return;
    }
    if (field == 'metadata') {
      if (value is! Map) {
        issues.add('$descriptor: metadata must be an object');
      }
      return;
    }
    if (field == 'options') {
      if (value is! List || value.isEmpty) {
        issues.add('$descriptor: options must be a non-empty list');
        return;
      }
      for (var idx = 0; idx < value.length; idx++) {
        final element = value[idx];
        if (element is! String || element.trim().isEmpty) {
          issues.add('$descriptor: options[$idx] must be a non-empty string');
        }
      }
    }
  }

  Future<_AsciiReadResult> _readAsciiNonEmpty(File file) async {
    try {
      final length = await file.length();
      if (length == 0) {
        return const _AsciiReadResult.error('empty file');
      }
      final bytes = await file.readAsBytes();
      if (!_isAsciiOnly(bytes)) {
        return const _AsciiReadResult.error('non-ASCII content');
      }
      return _AsciiReadResult.ok(utf8.decode(bytes));
    } on FileSystemException catch (error) {
      return _AsciiReadResult.error('unable to read file ($error)');
    }
  }

  ContentReplayabilityResult _buildResult(
    List<String> brokenModules,
    Map<String, List<String>> moduleIssues,
  ) {
    final timestamp = DateTime.now().toUtc();
    final summary = ContentReplayabilitySummary(
      replayable: brokenModules.isEmpty,
      timestamp: timestamp,
    );
    final result = ContentReplayabilityResult(
      brokenModules: brokenModules,
      summary: summary,
    );
    if (!summary.replayable) {
      final message = moduleIssues.entries
          .map((entry) => '${entry.key}: ${entry.value.join(', ')}')
          .join(' | ');
      throw ContentReplayabilityException(result, message);
    }
    return result;
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class ContentReplayabilityResult {
  final List<String> brokenModules;
  final ContentReplayabilitySummary summary;

  ContentReplayabilityResult({
    required this.brokenModules,
    required this.summary,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'broken_modules': brokenModules,
    'summary': summary.toJson(),
  };
}

class ContentReplayabilitySummary {
  final bool replayable;
  final DateTime timestamp;

  ContentReplayabilitySummary({
    required this.replayable,
    required this.timestamp,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'replayable': replayable,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ContentReplayabilityException implements Exception {
  final ContentReplayabilityResult result;
  final String message;

  ContentReplayabilityException(this.result, this.message);

  @override
  String toString() => 'ContentReplayabilityException: $message';
}

class _AsciiReadResult {
  final bool ok;
  final String? content;
  final String? reason;

  const _AsciiReadResult._(this.ok, this.content, this.reason);

  const _AsciiReadResult.ok(String content) : this._(true, content, null);

  const _AsciiReadResult.error(String reason) : this._(false, null, reason);
}
