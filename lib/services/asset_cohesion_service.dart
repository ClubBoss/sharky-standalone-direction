import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class AssetCohesionService {
  static const _requiredDirs = <String>[
    'assets',
    'assets/mascot',
    'assets/icons',
    'assets/ui',
  ];

  const AssetCohesionService();

  Future<AssetCohesionResult> run() async {
    final issues = <String>[];
    final invalidAssets = <String>[];
    final orphanEntries = <String>[];

    final missingDirs = <String>[];
    for (final dir in _requiredDirs) {
      if (!await Directory(dir).exists()) {
        missingDirs.add(dir);
      }
    }
    if (missingDirs.isNotEmpty) {
      issues.add('Missing directories: ${missingDirs.join(', ')}');
      _throwResult(
        issues,
        invalidAssets,
        orphanEntries,
        'Required asset directories missing',
      );
    }

    final declaredAssets = await _loadPubspecAssets();
    final declaredSet = declaredAssets.toSet();
    final declaredLower = <String, List<String>>{};
    for (final entry in declaredAssets) {
      declaredLower.putIfAbsent(entry.toLowerCase(), () => []).add(entry);
    }

    final matchedDeclared = <String>{};
    final pathCounts = <String, int>{};

    final assetsDir = Directory('assets');
    await for (final entity in assetsDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }
      final ext = entity.path.toLowerCase();
      if (!ext.endsWith('.svg') && !ext.endsWith('.png')) {
        continue;
      }
      final relativePath = _relativeAssetPath(entity);
      final count = pathCounts.update(
        relativePath,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      if (count == 2) {
        issues.add('Duplicate asset path: $relativePath');
      }

      final declaredMatch = _matchDeclaredAsset(
        relativePath,
        declaredSet,
        declaredLower,
        matchedDeclared,
        issues,
      );

      final length = await entity.length();
      if (length == 0) {
        invalidAssets.add(relativePath);
        issues.add('Empty asset file: $relativePath');
      }

      if (relativePath.endsWith('.svg')) {
        final bytes = await entity.readAsBytes();
        if (!_isAsciiOnly(bytes)) {
          invalidAssets.add(relativePath);
          issues.add('Non-ASCII SVG asset: $relativePath');
        }
      }

      if (!declaredMatch) {
        issues.add('Asset not declared in pubspec: $relativePath');
      }
    }

    for (final declared in declaredSet) {
      if (!matchedDeclared.contains(declared)) {
        orphanEntries.add(declared);
        issues.add('Pubspec asset missing on disk: $declared');
      }
    }

    final result = _buildResult(issues, invalidAssets, orphanEntries);
    if (!result.summary.cohesive) {
      throw AssetCohesionException(result, 'Asset cohesion check failed');
    }
    return result;
  }

  Future<List<String>> _loadPubspecAssets() async {
    final file = File('pubspec.yaml');
    if (!await file.exists()) {
      _throwResult(
        ['pubspec.yaml is missing'],
        const [],
        const [],
        'pubspec.yaml not found',
      );
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      _throwResult(
        ['pubspec.yaml must not be empty'],
        const [],
        const [],
        'pubspec.yaml empty',
      );
    }
    if (!_isAsciiOnly(bytes)) {
      _throwResult(
        ['pubspec.yaml must be ASCII'],
        const [],
        const [],
        'pubspec.yaml contains non-ASCII bytes',
      );
    }
    final content = utf8.decode(bytes);
    final lines = content.split(RegExp(r'\r?\n'));
    var inAssets = false;
    final entries = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (!inAssets) {
        if (trimmed.startsWith('assets:')) {
          inAssets = true;
        }
        continue;
      }
      if (trimmed.isEmpty) {
        continue;
      }
      if (!line.startsWith(' ') && !line.startsWith('\t')) {
        break;
      }
      if (trimmed.startsWith('-')) {
        var entry = trimmed.substring(1).trim();
        if ((entry.startsWith('"') && entry.endsWith('"')) ||
            (entry.startsWith("'") && entry.endsWith("'"))) {
          entry = entry.substring(1, entry.length - 1);
        }
        if (entry.isNotEmpty) {
          entries.add(entry.replaceAll('\\', '/'));
        }
      }
    }
    if (entries.isEmpty) {
      _throwResult(
        ['pubspec.yaml assets list is empty'],
        const [],
        const [],
        'pubspec.yaml assets list missing',
      );
    }
    return entries;
  }

  String _relativeAssetPath(File file) {
    final root = Directory('assets').absolute.path;
    final absolute = file.absolute.path;
    var relative = absolute.replaceFirst(root, '');
    relative = relative.replaceAll('\\', '/');
    relative = relative.replaceFirst(RegExp(r'^/+'), '');
    return 'assets/$relative';
  }

  bool _matchDeclaredAsset(
    String path,
    Set<String> declaredSet,
    Map<String, List<String>> declaredLower,
    Set<String> matchedDeclared,
    List<String> issues,
  ) {
    if (declaredSet.contains(path)) {
      matchedDeclared.add(path);
      return true;
    }
    final lower = path.toLowerCase();
    final matches = declaredLower[lower];
    if (matches != null && matches.isNotEmpty) {
      matchedDeclared.add(matches.first);
      issues.add(
        'Asset casing mismatch: $path vs pubspec entry ${matches.first}',
      );
      return true;
    }
    return false;
  }

  AssetCohesionResult _buildResult(
    List<String> issues,
    List<String> invalidAssets,
    List<String> orphanEntries,
  ) {
    final summary = AssetCohesionSummary(
      cohesive:
          issues.isEmpty && invalidAssets.isEmpty && orphanEntries.isEmpty,
      timestamp: DateTime.now().toUtc(),
    );
    return AssetCohesionResult(
      issues: List<String>.from(issues),
      invalidAssets: List<String>.from(invalidAssets),
      orphanEntries: List<String>.from(orphanEntries),
      summary: summary,
    );
  }

  Never _throwResult(
    List<String> issues,
    List<String> invalidAssets,
    List<String> orphanEntries,
    String message,
  ) {
    final result = AssetCohesionResult(
      issues: List<String>.from(issues),
      invalidAssets: List<String>.from(invalidAssets),
      orphanEntries: List<String>.from(orphanEntries),
      summary: AssetCohesionSummary(
        cohesive: false,
        timestamp: DateTime.now().toUtc(),
      ),
    );
    throw AssetCohesionException(result, message);
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class AssetCohesionResult {
  final List<String> issues;
  final List<String> orphanEntries;
  final List<String> invalidAssets;
  final AssetCohesionSummary summary;

  AssetCohesionResult({
    required this.issues,
    required this.orphanEntries,
    required this.invalidAssets,
    required this.summary,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'issues': issues,
    'orphan_entries': orphanEntries,
    'invalid_assets': invalidAssets,
    'summary': summary.toJson(),
  };
}

class AssetCohesionSummary {
  final bool cohesive;
  final DateTime timestamp;

  AssetCohesionSummary({required this.cohesive, required this.timestamp});

  Map<String, Object?> toJson() => <String, Object?>{
    'cohesive': cohesive,
    'timestamp': timestamp.toIso8601String(),
  };
}

class AssetCohesionException implements Exception {
  final AssetCohesionResult result;
  final String message;

  AssetCohesionException(this.result, this.message);

  @override
  String toString() => 'AssetCohesionException: $message';
}
