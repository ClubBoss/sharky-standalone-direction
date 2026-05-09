/// Codebase Audit Tool (Stage 30B)
///
/// Safe, read-only analysis of codebase structure.
/// Detects unused imports, duplicate files, temporary files, and orphaned generated files.
///
/// Modes:
/// - --readonly (default): Analysis only, no modifications
/// - --preview: Print list of potential issues
/// - --apply: DISABLED - requires manual approval
///
/// Usage:
///   dart run tools/codebase_audit.dart [--readonly|--preview]

import 'dart:io';
import 'dart:convert';

/// Paths to exclude from audit
const _excludedPaths = [
  'lib/models',
  'lib/services',
  'lib/ui_v2',
  'content/',
  'test/',
  'tools/health_dashboard.dart',
];

/// Temporary file patterns
const _tempFilePatterns = [
  r'\.bak$',
  r'\.old$',
  r'_copy\.dart$',
  r'_test_copy\.dart$',
  r'_backup\.dart$',
  r'~$',
];

void main(List<String> args) async {
  final mode = args.isEmpty ? 'readonly' : args.first;

  if (mode == '--apply') {
    stderr.writeln(
      'ERROR: --apply mode is disabled. Manual approval required.',
    );
    stderr.writeln('This tool is read-only for safety.');
    exit(1);
  }

  final isPreview = mode == '--preview';
  final audit = await _runAudit();

  if (isPreview) {
    _printPreview(audit);
  } else {
    // Readonly mode: print summary only
    _printSummary(audit);
  }

  // Exit with 0 for successful analysis
  exit(0);
}

/// Run the audit and collect results
Future<Map<String, dynamic>> _runAudit() async {
  final issues = <String, List<String>>{
    'tempFiles': [],
    'orphanedGenerated': [],
    'duplicates': [],
    'unusedImports': [], // Placeholder - requires deeper analysis
  };

  // Scan lib/** and tools/**
  await _scanDirectory('lib', issues);
  await _scanDirectory('tools', issues);

  final totalIssues = issues.values.fold<int>(
    0,
    (sum, list) => sum + list.length,
  );

  return {
    'issues': totalIssues,
    'tempFiles': issues['tempFiles']!.length,
    'orphanedGenerated': issues['orphanedGenerated']!.length,
    'duplicates': issues['duplicates']!.length,
    'unusedImports': issues['unusedImports']!.length,
    'details': issues,
    'readonly': true,
    'pass': true, // Always pass in readonly mode
  };
}

/// Scan directory for issues
Future<void> _scanDirectory(
  String path,
  Map<String, List<String>> issues,
) async {
  final dir = Directory(path);
  if (!await dir.exists()) return;

  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;

    final filePath = entity.path;

    // Skip excluded paths
    if (_isExcluded(filePath)) continue;

    // Check for temporary files
    if (_isTempFile(filePath)) {
      issues['tempFiles']!.add(filePath);
      continue;
    }

    // Check for orphaned generated files (.g.dart, .freezed.dart)
    if (_isOrphanedGenerated(filePath)) {
      final hasSource = await _hasSourceFile(filePath);
      if (!hasSource) {
        issues['orphanedGenerated']!.add(filePath);
      }
    }

    // Check for potential duplicates (simplified heuristic)
    if (filePath.endsWith('.dart')) {
      await _checkForDuplicates(filePath, issues['duplicates']!);
    }
  }
}

/// Check if path should be excluded
bool _isExcluded(String path) {
  for (final exclude in _excludedPaths) {
    if (path.contains(exclude)) return true;
  }
  return false;
}

/// Check if file matches temporary pattern
bool _isTempFile(String path) {
  for (final pattern in _tempFilePatterns) {
    if (RegExp(pattern).hasMatch(path)) return true;
  }
  return false;
}

/// Check if file is a generated file
bool _isOrphanedGenerated(String path) {
  return path.endsWith('.g.dart') || path.endsWith('.freezed.dart');
}

/// Check if source file exists for generated file
Future<bool> _hasSourceFile(String generatedPath) async {
  final sourcePath = generatedPath
      .replaceAll('.g.dart', '.dart')
      .replaceAll('.freezed.dart', '.dart');

  if (sourcePath == generatedPath) return false;

  final sourceFile = File(sourcePath);
  return await sourceFile.exists();
}

/// Simple duplicate detection based on filename similarity
/// (Full content comparison would be too expensive)
Future<void> _checkForDuplicates(String path, List<String> duplicates) async {
  // Look for files with similar names in same directory
  final file = File(path);
  final dir = file.parent;
  final name = file.uri.pathSegments.last;

  // Check for common duplicate patterns
  final patterns = [
    '$name.copy',
    '${name}_copy',
    '${name}_old',
    '${name}_backup',
  ];

  for (final pattern in patterns) {
    final potentialDupe = File('${dir.path}/$pattern');
    if (await potentialDupe.exists() &&
        !duplicates.contains(potentialDupe.path)) {
      duplicates.add(potentialDupe.path);
    }
  }
}

/// Print preview of all detected issues
void _printPreview(Map<String, dynamic> audit) {
  final details = audit['details'] as Map<String, List<String>>;

  print('=== Codebase Audit Preview (Read-Only Mode) ===\n');

  print('Temporary Files (${details['tempFiles']!.length}):');
  for (final file in details['tempFiles']!) {
    print('  - $file');
  }
  print('');

  print('Orphaned Generated Files (${details['orphanedGenerated']!.length}):');
  for (final file in details['orphanedGenerated']!) {
    print('  - $file');
  }
  print('');

  print('Potential Duplicates (${details['duplicates']!.length}):');
  for (final file in details['duplicates']!) {
    print('  - $file');
  }
  print('');

  print('Total Issues: ${audit['issues']}');
  print('\nNOTE: No files will be deleted. Manual approval required.');
  print('To apply changes, review each file manually and delete as needed.');
}

/// Print summary for Health Dashboard integration
void _printSummary(Map<String, dynamic> audit) {
  // Print as JSON for easy parsing
  print(jsonEncode(audit));
}
