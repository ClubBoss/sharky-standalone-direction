// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'module_progress_service.dart';

/// Filter modules by completion status
enum CompletionFilter { all, completed, incomplete }

/// Loads training content modules from canonical content/<module>/v1/
///
/// Discovers catalog metadata via assets/theory_index.json and prefers
/// canonical content bundles when present.
///
/// Loads:
/// - theory.md (markdown content)
/// - drills.jsonl (quiz questions)
/// - demos.jsonl (step-by-step walkthroughs, optional)
class ContentModuleLoaderService {
  static const String _ssotDocPath = 'docs/content/ssot_v1.md';
  static final ContentModuleLoaderService _instance =
      ContentModuleLoaderService();

  static ContentModuleLoaderService get instance {
    // TODO replace stub when logic is restored.
    return _instance;
  }

  final Map<String, TrainingModule> _cache = {};
  List<ModuleMetadata>? _index;
  bool _initialized = false;
  ModuleProgressService? _progressService;
  final Set<String> _loggedMissingAssets = {};
  final Set<String> _warnedLegacyModuleIds = {};
  final Set<String> _warnedMissingCanonicalModuleIds = {};
  bool _warnedLegacyIndexUsage = false;
  Future<Set<String>>? _assetManifestKeysFuture;

  /// Set the progress service for tracking completion status
  void setProgressService(ModuleProgressService service) {
    _progressService = service;
  }

  /// Initialize by loading the module index from assets/theory_index.json
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _warnLegacyIndexUsage();
      final indexJson = await rootBundle.loadString('assets/theory_index.json');
      final List<dynamic> indexData = json.decode(indexJson) as List<dynamic>;

      _index = indexData
          .map((item) => ModuleMetadata.fromJson(item as Map<String, dynamic>))
          .toList();

      _initialized = true;
    } catch (e) {
      // Fail gracefully - return empty index
      _index = [];
      _initialized = true;
      print('Warning: Failed to load theory_index.json: $e');
    }
  }

  /// Get list of all available module metadata
  Future<List<ModuleMetadata>> getModuleIndex() async {
    if (!_initialized) await initialize();
    return List.unmodifiable(_index ?? []);
  }

  /// Get modules filtered by category
  Future<List<ModuleMetadata>> getModulesByCategory(String category) async {
    final index = await getModuleIndex();
    return index.where((m) => m.category == category).toList();
  }

  /// Get modules filtered by completion status and optional search query
  Future<List<ModuleMetadata>> getModulesByCompletion(
    CompletionFilter filter, {
    String? category,
    String? query,
  }) async {
    final index = await getModuleIndex();

    // First filter by category if specified
    var filtered = category != null
        ? index.where((m) => m.category == category).toList()
        : index;

    // Then filter by completion status
    if (filter == CompletionFilter.all) {
      // continue to apply query if provided
    } else {
      if (_progressService == null) {
        // If no progress service, return all for 'all', empty for completed/incomplete
        return [];
      }

      filtered = filtered.where((m) {
        final isCompleted = _progressService!.isModuleCompleted(m.id);
        return filter == CompletionFilter.completed
            ? isCompleted
            : !isCompleted;
      }).toList();
    }

    // Finally, apply search query on module id (case-insensitive)
    if (query != null) {
      final q = query.trim().toLowerCase();
      if (q.isNotEmpty) {
        filtered = filtered
            .where((m) => m.id.toLowerCase().contains(q))
            .toList();
      }
    }

    return filtered;
  }

  /// Load a specific training module by ID
  Future<TrainingModule?> loadModule(String moduleId) async {
    if (!_initialized) await initialize();

    if (_cache.containsKey(moduleId)) {
      return _cache[moduleId];
    }

    final metadata = _index?.firstWhere(
      (m) => m.id == moduleId,
      orElse: () => throw ModuleNotFoundException(moduleId),
    );

    if (metadata == null) {
      print('Warning: Module $moduleId not found in index');
      return null;
    }

    try {
      final Set<String> assetKeys = await _assetManifestKeys();
      final bool hasCanonicalBundle = await _hasCanonicalBundleV1(
        moduleId,
        assetKeys,
      );
      final TrainingModule? module = hasCanonicalBundle
          ? await _loadCanonicalModuleV1(moduleId, metadata, assetKeys)
          : await _loadLegacyFallbackModule(moduleId, metadata);
      if (module == null) {
        return null;
      }
      _cache[moduleId] = module;
      return module;
    } catch (e) {
      print('Error loading module $moduleId: $e');
      return null;
    }
  }

  /// Load multiple modules by IDs
  Future<List<TrainingModule>> loadModules(List<String> moduleIds) async {
    final modules = <TrainingModule>[];
    for (final id in moduleIds) {
      final module = await loadModule(id);
      if (module != null) {
        modules.add(module);
      }
    }
    return modules;
  }

  /// Load all modules in a category
  Future<List<TrainingModule>> loadCategory(String category) async {
    final metadata = await getModulesByCategory(category);
    final moduleIds = metadata.map((m) => m.id).toList();
    return loadModules(moduleIds);
  }

  List<ModuleSpot> getSpots(String moduleId) {
    // TODO replace stub when logic is restored.
    return const [];
  }

  Future<String> getModuleTitle(String moduleId, {String locale = 'en'}) async {
    // TODO replace stub when logic is restored.
    return moduleId;
  }

  /// Clear cache (useful for testing or memory management)
  void clearCache() {
    _cache.clear();
  }

  // Private helper methods

  Future<Set<String>> _assetManifestKeys() {
    return _assetManifestKeysFuture ??= _loadAssetManifestKeys();
  }

  Future<Set<String>> _loadAssetManifestKeys() async {
    try {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final decoded = jsonDecode(manifestRaw);
      if (decoded is Map<String, dynamic>) {
        return decoded.keys.toSet();
      }
      if (decoded is Map) {
        return decoded.keys.map((key) => key.toString()).toSet();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Warning: Failed to read AssetManifest.json: $e');
      }
    }
    return <String>{};
  }

  Future<bool> _hasCanonicalBundleV1(
    String moduleId,
    Set<String> assetKeys,
  ) async {
    final prefix = 'content/$moduleId/v1/';
    return assetKeys.contains('${prefix}theory.md') ||
        assetKeys.contains('${prefix}manifest.json');
  }

  bool _assetExists(Set<String> assetKeys, String path) {
    return assetKeys.contains(path);
  }

  String _canonicalModuleAssetPath(String moduleId, String fileName) {
    return 'content/$moduleId/v1/$fileName';
  }

  Future<TrainingModule?> _loadCanonicalModuleV1(
    String moduleId,
    ModuleMetadata metadata,
    Set<String> assetKeys,
  ) async {
    final theoryPath = _canonicalModuleAssetPath(moduleId, 'theory.md');
    final drillsPath = _canonicalModuleAssetPath(moduleId, 'drills.jsonl');
    final demosPath = _canonicalModuleAssetPath(moduleId, 'demos.jsonl');
    final theory = await _loadAssetString(theoryPath);
    final drills = _assetExists(assetKeys, drillsPath)
        ? await _loadDrills(drillsPath)
        : const <Drill>[];
    final demos = _assetExists(assetKeys, demosPath)
        ? await _loadDemos(demosPath)
        : const <Demo>[];

    return _buildLoadedModule(
      moduleId: moduleId,
      metadata: metadata,
      theory: theory,
      drills: drills,
      demos: demos,
    );
  }

  Future<TrainingModule?> _loadLegacyFallbackModule(
    String moduleId,
    ModuleMetadata metadata,
  ) async {
    _warnMissingCanonicalBundle(moduleId);
    final theoryPath = _legacyModuleAssetPath(moduleId, 'theory.md');
    final drillsPath = _legacyModuleAssetPath(moduleId, 'drills.jsonl');
    final demosPath = _legacyModuleAssetPath(moduleId, 'demos.jsonl');
    final theory = await _loadAssetString(theoryPath);
    final drills = await _loadDrills(drillsPath);
    final demos = await _loadDemos(demosPath);

    final module = _buildLoadedModule(
      moduleId: moduleId,
      metadata: metadata,
      theory: theory,
      drills: drills,
      demos: demos,
    );
    if (module == null && kDebugMode) {
      debugPrint(
        'Module $moduleId is unavailable: no canonical content/$moduleId/v1 bundle '
        'and legacy assets/content fallback was not loadable.',
      );
    }
    return module;
  }

  TrainingModule? _buildLoadedModule({
    required String moduleId,
    required ModuleMetadata metadata,
    required String theory,
    required List<Drill> drills,
    required List<Demo> demos,
  }) {
    if (theory.trim().isEmpty && drills.isEmpty && demos.isEmpty) {
      return null;
    }
    final isCompleted = _progressService?.isModuleCompleted(moduleId) ?? false;
    return TrainingModule(
      id: moduleId,
      title: metadata.title,
      category: metadata.category,
      theory: theory,
      drills: drills,
      demos: demos,
      isCompleted: isCompleted,
    );
  }

  String _legacyModuleAssetPath(String moduleId, String fileName) {
    _warnLegacyModuleUsage(moduleId);
    return 'assets/content/$moduleId/v1/$fileName';
  }

  void _warnLegacyIndexUsage() {
    if (!kDebugMode || _warnedLegacyIndexUsage) {
      return;
    }
    _warnedLegacyIndexUsage = true;
    debugPrint(
      'ContentModuleLoaderService is using legacy assets/theory_index.json. '
      'Canonical authored content lives under content/. See $_ssotDocPath.',
    );
  }

  void _warnMissingCanonicalBundle(String moduleId) {
    if (!kDebugMode || !_warnedMissingCanonicalModuleIds.add(moduleId)) {
      return;
    }
    debugPrint(
      'ContentModuleLoaderService did not find canonical content/$moduleId/v1. '
      'Falling back to legacy assets/content/$moduleId if available. '
      'See $_ssotDocPath.',
    );
  }

  void _warnLegacyModuleUsage(String moduleId) {
    if (!kDebugMode || !_warnedLegacyModuleIds.add(moduleId)) {
      return;
    }
    debugPrint(
      'ContentModuleLoaderService is loading legacy assets/content/$moduleId. '
      'Do not treat assets/content/ as SSOT. See $_ssotDocPath. '
      'TODO: migrate this flow to content/... once the module has an equivalent canonical bundle.',
    );
  }

  Future<String> _loadAssetString(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      if (!_loggedMissingAssets.contains(path)) {
        _loggedMissingAssets.add(path);
        debugPrint('Warning: Failed to load asset $path: $e');
      }
      return '';
    }
  }

  Future<List<Drill>> _loadDrills(String path) async {
    try {
      final content = await rootBundle.loadString(path);
      final lines = content.split('\n');

      final drills = <Drill>[];
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        try {
          final drillJson = json.decode(trimmed) as Map<String, dynamic>;
          drills.add(Drill.fromJson(drillJson));
        } catch (e) {
          print('Warning: Failed to parse drill line in $path: $e');
          continue;
        }
      }

      return drills;
    } catch (e) {
      print('Warning: Failed to load drills from $path: $e');
      return [];
    }
  }

  Future<List<Demo>> _loadDemos(String path) async {
    try {
      final content = await rootBundle.loadString(path);
      final lines = content.split('\n');

      final demos = <Demo>[];
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        try {
          final demoJson = json.decode(trimmed) as Map<String, dynamic>;
          demos.add(Demo.fromJson(demoJson));
        } catch (e) {
          print('Warning: Failed to parse demo line in $path: $e');
          continue;
        }
      }

      return demos;
    } catch (e) {
      print('Warning: Failed to load demos from $path: $e');
      return [];
    }
  }

  /// Get all available categories
  Future<List<String>> getCategories() async {
    final index = await getModuleIndex();
    final categories = <String>{};
    for (final module in index) {
      categories.add(module.category);
    }
    return categories.toList()..sort();
  }

  /// Search modules by title or ID
  Future<List<ModuleMetadata>> searchModules(String query) async {
    final index = await getModuleIndex();
    final lowerQuery = query.toLowerCase();

    return index
        .where(
          (m) =>
              m.id.toLowerCase().contains(lowerQuery) ||
              m.title.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Invalidate cached module to force reload with updated completion status
  void invalidateModuleCache(String moduleId) {
    _cache.remove(moduleId);
  }

  /// Refresh completion status for a cached module
  void refreshModuleCompletion(String moduleId) {
    if (_cache.containsKey(moduleId) && _progressService != null) {
      final module = _cache[moduleId]!;
      final isCompleted = _progressService!.isModuleCompleted(moduleId);
      _cache[moduleId] = module.copyWith(isCompleted: isCompleted);
    }
  }
}

/// Metadata about a training module from theory_index.json
class ModuleMetadata {
  final String id;
  final String title;
  final String category;
  final String uri;

  ModuleMetadata({
    required this.id,
    required this.title,
    required this.category,
    required this.uri,
  });

  factory ModuleMetadata.fromJson(Map<String, dynamic> json) => ModuleMetadata(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    category: json['category'] as String? ?? 'misc',
    uri: json['uri'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'uri': uri,
  };
}

/// Complete training module with theory, drills, and demos
class TrainingModule {
  final String id;
  final String title;
  final String category;
  final String theory;
  final List<Drill> drills;
  final List<Demo> demos;
  final bool isCompleted;

  TrainingModule({
    required this.id,
    required this.title,
    required this.category,
    required this.theory,
    required this.drills,
    required this.demos,
    this.isCompleted = false,
  });

  /// Extract section from theory markdown
  String? getTheorySection(String sectionName) {
    final lines = theory.split('\n');
    final buffer = StringBuffer();
    bool inSection = false;

    for (final line in lines) {
      if (line.trim() == sectionName) {
        inSection = true;
        continue;
      }

      // Stop at next section header (plain text without #)
      if (inSection &&
          line.isNotEmpty &&
          !line.startsWith(' ') &&
          line == line.trim() &&
          line != sectionName &&
          _isSectionHeader(line)) {
        break;
      }

      if (inSection) {
        buffer.writeln(line);
      }
    }

    final result = buffer.toString().trim();
    return result.isEmpty ? null : result;
  }

  bool _isSectionHeader(String line) {
    final headers = [
      'What it is',
      'Why it matters',
      'Rules of thumb',
      'Mini example',
      'Common mistakes',
      'Contrast line',
      'Mini-glossary',
    ];
    return headers.contains(line);
  }

  /// Create a copy of this module with updated completion status
  TrainingModule copyWith({bool? isCompleted}) => TrainingModule(
    id: id,
    title: title,
    category: category,
    theory: theory,
    drills: drills,
    demos: demos,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'theory_length': theory.length,
    'drill_count': drills.length,
    'demo_count': demos.length,
    'is_completed': isCompleted,
  };
}

class ModuleSpot {
  final String id;
  final String description;

  const ModuleSpot({required this.id, required this.description});
}

/// Drill/quiz question from drills.jsonl
class Drill {
  final String id;
  final String spotKind;
  final List<String> target;
  final String prompt;
  final String answer;
  final String rationale;
  final int difficulty;
  final String? instructionText;
  final String? goalText;
  final String? guidedScope;
  final String? isoGroup;

  Drill({
    required this.id,
    required this.spotKind,
    required this.target,
    required this.prompt,
    required this.answer,
    required this.rationale,
    this.difficulty = 1,
    this.instructionText,
    this.goalText,
    this.guidedScope,
    this.isoGroup,
  });

  factory Drill.fromJson(Map<String, dynamic> json) => Drill(
    id: json['id'] as String? ?? '',
    spotKind: json['spot_kind'] as String? ?? 'unknown',
    target:
        (json['target'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [],
    prompt: json['prompt'] as String? ?? json['question'] as String? ?? '',
    answer: json['answer'] as String? ?? '',
    // Backward-compatible fallback: older/beta content may provide only
    // `reaction_text` while newer modules use `rationale`.
    rationale:
        (json['rationale'] as String? ??
                json['reaction_text'] as String? ??
                json['explanation'] as String? ??
                json['goal'] as String? ??
                '')
            .trim(),
    difficulty: json['difficulty'] as int? ?? 1,
    instructionText: json['instruction_text'] as String?,
    goalText: json['goal_text'] as String?,
    guidedScope: json['guided_scope'] as String?,
    isoGroup: json['iso_group'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'spot_kind': spotKind,
    'target': target,
    'prompt': prompt,
    'answer': answer,
    'rationale': rationale,
    'difficulty': difficulty,
    if (instructionText != null) 'instruction_text': instructionText,
    if (goalText != null) 'goal_text': goalText,
    if (guidedScope != null) 'guided_scope': guidedScope,
    if (isoGroup != null) 'iso_group': isoGroup,
  };
}

/// Demo walkthrough from demos.jsonl
class Demo {
  final String id;
  final String spotKind;
  final List<String> tokens;
  final List<String> steps;

  Demo({
    required this.id,
    required this.spotKind,
    required this.tokens,
    required this.steps,
  });

  factory Demo.fromJson(Map<String, dynamic> json) => Demo(
    id: json['id'] as String? ?? '',
    spotKind: json['spot_kind'] as String? ?? 'unknown',
    tokens:
        (json['tokens'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [],
    steps:
        (json['steps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'spot_kind': spotKind,
    'tokens': tokens,
    'steps': steps,
  };
}

/// Exception thrown when a module is not found
class ModuleNotFoundException implements Exception {
  final String moduleId;

  ModuleNotFoundException(this.moduleId);

  @override
  String toString() => 'Module not found: $moduleId';
}
