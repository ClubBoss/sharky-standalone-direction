import 'dart:io';

const _asciiLimit = 0x7F;

class FileStructureIntegrityService {
  static const _requiredDirectories = <String>[
    'release',
    'release/_reports',
    'content',
    'content/core',
    'content/core_final',
    'lib/services',
    'tools',
  ];

  static const _requiredReportFiles = <String>[
    'stability_snapshot_v2.json',
    'system_sanity_result.json',
    'content_consistency_result.json',
    'telemetry_integrity_result.json',
    'cache_reliability_result.json',
    'planner_v2_plan.json',
    'explanation_routing_bundle.json',
    'tutorial_overlay_spec.json',
    'visual_cohesion_v3.json',
  ];

  const FileStructureIntegrityService();

  Future<FileStructureIntegrityResult> run() async {
    final missingPaths = <String>[];
    final invalidFiles = <String>[];

    for (final path in _requiredDirectories) {
      if (!await Directory(path).exists()) {
        missingPaths.add(path);
      }
    }

    await _validateRequiredReports(invalidFiles);
    await _validateReportDirectoryFiles(invalidFiles);
    await _validateContentV1(invalidFiles);

    final timestamp = DateTime.now().toUtc();
    final summary = FileStructureIntegritySummary(
      structurePass: missingPaths.isEmpty && invalidFiles.isEmpty,
      timestamp: timestamp,
    );

    final result = FileStructureIntegrityResult(
      missingPaths: missingPaths,
      invalidFiles: invalidFiles,
      summary: summary,
    );

    if (!summary.structurePass) {
      final messageParts = <String>[];
      if (missingPaths.isNotEmpty) {
        messageParts.add('Missing directories: ${missingPaths.join(', ')}');
      }
      if (invalidFiles.isNotEmpty) {
        messageParts.add('Invalid files: ${invalidFiles.join(', ')}');
      }
      throw FileStructureIntegrityException(result, messageParts.join(' | '));
    }

    return result;
  }

  Future<void> _validateRequiredReports(List<String> invalidFiles) async {
    for (final fileName in _requiredReportFiles) {
      final file = File('release/_reports/$fileName');
      if (!await file.exists()) {
        _recordInvalid(invalidFiles, file.path);
        continue;
      }
      if (!await _isValidFile(file)) {
        _recordInvalid(invalidFiles, file.path);
      }
    }
  }

  Future<void> _validateReportDirectoryFiles(List<String> invalidFiles) async {
    final dir = Directory('release/_reports');
    if (!await dir.exists()) {
      return;
    }
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }
      if (!await _isValidFile(entity)) {
        _recordInvalid(invalidFiles, entity.path);
      }
    }
  }

  Future<void> _validateContentV1(List<String> invalidFiles) async {
    final contentDir = Directory('content');
    if (!await contentDir.exists()) {
      return;
    }
    await for (final entry in contentDir.list(followLinks: false)) {
      if (entry is! Directory) {
        continue;
      }
      final v1Dir = Directory('${entry.path}/v1');
      if (!await v1Dir.exists()) {
        continue;
      }
      await for (final entity in v1Dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }
        if (!await _isValidFile(entity)) {
          _recordInvalid(invalidFiles, entity.path);
        }
      }
    }
  }

  Future<bool> _isValidFile(File file) async {
    try {
      final length = await file.length();
      if (length == 0) {
        return false;
      }
      final bytes = await file.readAsBytes();
      return _isAsciiOnly(bytes);
    } on FileSystemException {
      return false;
    }
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);

  void _recordInvalid(List<String> invalidFiles, String path) {
    if (!invalidFiles.contains(path)) {
      invalidFiles.add(path);
    }
  }
}

class FileStructureIntegrityResult {
  final List<String> missingPaths;
  final List<String> invalidFiles;
  final FileStructureIntegritySummary summary;

  FileStructureIntegrityResult({
    required this.missingPaths,
    required this.invalidFiles,
    required this.summary,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'missing_paths': missingPaths,
    'invalid_files': invalidFiles,
    'summary': summary.toJson(),
  };
}

class FileStructureIntegritySummary {
  final bool structurePass;
  final DateTime timestamp;

  FileStructureIntegritySummary({
    required this.structurePass,
    required this.timestamp,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'structure_pass': structurePass,
    'timestamp': timestamp.toIso8601String(),
  };
}

class FileStructureIntegrityException implements Exception {
  final FileStructureIntegrityResult result;
  final String message;

  FileStructureIntegrityException(this.result, this.message);

  @override
  String toString() => 'FileStructureIntegrityException: $message';
}
