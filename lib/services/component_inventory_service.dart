import 'dart:convert';
import 'dart:io';

/// Exception thrown when the component inventory scanner cannot read a file.
class ComponentInventoryException implements IOException {
  const ComponentInventoryException(this.message);

  final String message;

  @override
  String toString() => 'ComponentInventoryException: $message';
}

/// Collects metadata about component usage across Flutter UI directories.
class ComponentInventoryService {
  const ComponentInventoryService();

  static const List<String> _defaultRoots = ['lib/widgets', 'lib/screens'];

  static const Map<String, List<String>> _componentCatalog = {
    'buttons': ['TextButton', 'ElevatedButton', 'OutlinedButton', 'IconButton'],
    'inputs': ['TextField', 'TextFormField', 'DropdownButton'],
    'display': ['Text', 'RichText', 'Icon', 'Image'],
    'chips': ['Chip', 'InputChip', 'FilterChip'],
    'navigation': ['AppBar', 'BottomNavigationBar', 'Drawer', 'TabBar'],
    'lists': ['ListTile', 'ListView', 'GridView'],
    'surfaces': ['Card', 'Material', 'Container'],
    'wrappers': ['Scaffold', 'SafeArea', 'GestureDetector'],
  };

  static final Map<String, RegExp> _componentRegexes = Map.unmodifiable(
    _buildComponentRegexes(),
  );

  Future<ComponentInventoryBundle> collect({List<String>? directories}) async {
    final scanRoots = directories ?? _defaultRoots;
    final accumulator = <String, _GroupAccumulator>{
      for (final key in _componentCatalog.keys) key: _GroupAccumulator(),
    };

    for (final root in scanRoots) {
      final directory = Directory(root);
      if (!await directory.exists()) {
        continue;
      }
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }
        if (!entity.path.endsWith('.dart')) {
          continue;
        }
        final content = await _readFileContent(entity);
        _scanContent(content, accumulator);
      }
    }

    final components = <String, List<String>>{};
    final counts = <String, int>{};

    for (final entry in _componentCatalog.entries) {
      final group = entry.key;
      final accumulatorEntry = accumulator[group]!;
      final names = entry.value.where(accumulatorEntry.seen.contains).toList()
        ..sort();
      components[group] = List.unmodifiable(names);
      counts[group] = accumulatorEntry.count;
    }

    return ComponentInventoryBundle(
      components: components,
      counts: counts,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<String> _readFileContent(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return latin1.decode(bytes);
    } on FileSystemException catch (exception) {
      throw ComponentInventoryException(
        'Unable to read ${file.path}: ${exception.message}',
      );
    }
  }

  void _scanContent(
    String content,
    Map<String, _GroupAccumulator> accumulator,
  ) {
    for (final entry in _componentCatalog.entries) {
      final group = entry.key;
      final groupAccumulator = accumulator[group]!;
      for (final component in entry.value) {
        final regex = _componentRegexes[component]!;
        final matches = regex.allMatches(content).length;
        if (matches > 0) {
          groupAccumulator.record(component, matches);
        }
      }
    }
  }

  static Map<String, RegExp> _buildComponentRegexes() {
    final regexes = <String, RegExp>{};
    for (final components in _componentCatalog.values) {
      for (final component in components) {
        regexes[component] = RegExp(r'\b' + RegExp.escape(component) + r'\b');
      }
    }
    return regexes;
  }
}

class ComponentInventoryBundle {
  ComponentInventoryBundle({
    required Map<String, List<String>> components,
    required Map<String, int> counts,
    required this.timestamp,
  }) : components = Map.unmodifiable(components),
       counts = Map.unmodifiable(counts);

  final Map<String, List<String>> components;
  final Map<String, int> counts;
  final DateTime timestamp;

  int get componentGroupCount =>
      counts.values.where((count) => count > 0).length;

  Map<String, Object?> toJson() => {
    'components': components,
    'counts': counts,
    'timestamp': timestamp.toIso8601String(),
  };
}

class _GroupAccumulator {
  _GroupAccumulator();

  final Set<String> seen = <String>{};
  int count = 0;

  void record(String component, int occurrences) {
    seen.add(component);
    count += occurrences;
  }
}
