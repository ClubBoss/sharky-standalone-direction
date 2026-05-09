import 'dart:convert';
import 'dart:io';

class ComponentLibraryException implements IOException {
  const ComponentLibraryException(this.message);

  final String message;

  @override
  String toString() => 'ComponentLibraryException: $message';
}

class ComponentLibraryBundle {
  ComponentLibraryBundle({
    required this.patterns,
    required this.consolidationNotes,
    required this.visualRules,
    required this.timestamp,
  });

  final Map<String, Object?> patterns;
  final Map<String, Object?> consolidationNotes;
  final Map<String, Object?> visualRules;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'patterns': patterns,
    'consolidation_notes': consolidationNotes,
    'visual_rules': visualRules,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ComponentLibraryService {
  const ComponentLibraryService();

  static const _paths = [
    'release/_reports/layout_template_bundle.json',
    'release/_reports/component_unification_map.json',
    'release/_reports/visual_design_lift_spec.json',
    'release/_reports/component_inventory_summary.json',
  ];

  Future<ComponentLibraryBundle> build() async {
    final layout = await _loadAsciiJson(_paths[0]);
    final unification = await _loadAsciiJson(_paths[1]);
    final spec = await _loadAsciiJson(_paths[2]);
    final inventory = await _loadAsciiJson(_paths[3]);

    final canonical = _extractMap(unification['canonical_components']);
    final layoutTemplates = _extractMap(layout['screen_templates']);
    final cardTemplates = _extractMap(layout['card_templates']);
    final listTemplates = _extractMap(layout['list_templates']);
    final texture = _extractMap(spec['color_rules']);
    final spacing = _extractMap(spec['spacing_rules']);
    final componentsMap = _extractMap(inventory['components']);
    final buttons = componentsMap['buttons'];
    final cardInventory = componentsMap['surfaces'];
    final rowColumnTemplates = _extractMap(layout['row_column_templates']);

    final patterns = {
      'button': _buildButtonPattern(canonical, layoutTemplates, buttons),
      'card': _buildCardPattern(cardTemplates, spec, cardInventory),
      'input': _buildInputPattern(spec, inventory),
      'listtile': _buildListPattern(listTemplates),
      'navigation': _buildNavigationPattern(canonical),
      'container': _buildContainerPattern(spacing, canonical),
    };

    final consolidationNotes = {
      'deprecated': unification['consolidation_rules'],
      'conflicts': rowColumnTemplates,
      'candidates': spec['component_rules'],
    };

    final visualRules = {
      'colors': texture,
      'spacing': spacing,
      'radii': spec['radii_rules'],
      'shadows': spec['shadow_rules'],
    };

    return ComponentLibraryBundle(
      patterns: patterns,
      consolidationNotes: consolidationNotes,
      visualRules: visualRules,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw ComponentLibraryException('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw ComponentLibraryException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw ComponentLibraryException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  Map<String, Object?> _extractMap(Object? value) {
    if (value is Map<String, Object?>) return value;
    return const {};
  }

  Map<String, Object?> _buildButtonPattern(
    Map<String, Object?> canonical,
    Map<String, Object?> layoutTemplates,
    Object? buttons,
  ) {
    final primaryLayout = _extractMap(layoutTemplates['primary']);
    return {
      'primary': canonical['buttons'] ?? 'TextButton',
      'secondary': primaryLayout['safe_area'] ?? 'TextButton',
      'icon': buttons is List && buttons.isNotEmpty
          ? buttons.first
          : 'IconButton',
    };
  }

  Map<String, Object?> _buildCardPattern(
    Object? cardTemplates,
    Map<String, Object?> spec,
    Object? cardInventory,
  ) {
    final template = _extractMap(cardTemplates)['default'];
    final cardStyle = template is Map<String, Object?> ? template : {};
    return {
      'padding': cardStyle['padding'] ?? 12.0,
      'radius': cardStyle['radius'] ?? '8',
      'shadow': cardStyle['shadow'] ?? ['medium'],
      'inventory_count': (cardInventory is List ? cardInventory.length : 0),
    };
  }

  Map<String, Object?> _buildInputPattern(
    Map<String, Object?> spec,
    Map<String, Object?> inventory,
  ) {
    final components = _extractMap(inventory['components']);
    return {
      'baseline': spec['component_rules'],
      'availability': components['inputs'] ?? ['TextField'],
    };
  }

  Map<String, Object?> _buildListPattern(Object? listTemplates) {
    final listMap = _extractMap(listTemplates);
    final primary = _extractMap(listMap['primary']);
    final collection = _extractMap(listMap['collection']);
    return {
      'tile': primary['tile'] ?? 'ListTile',
      'divider': primary['divider'] ?? true,
      'container': collection['container'] ?? 'Card',
    };
  }

  Map<String, Object?> _buildNavigationPattern(
    Map<String, Object?> canonical,
  ) => {
    'appbar': canonical['navigation'] ?? 'AppBar',
    'tabs': canonical['navigation'] ?? 'TabBar',
  };

  Map<String, Object?> _buildContainerPattern(
    Map<String, Object?> spacing,
    Map<String, Object?> canonical,
  ) => {
    'padding': spacing['padding_variants'] ?? [8, 16],
    'background': canonical['cards'] ?? 'Card',
    'touch_target': 48,
  };
}
