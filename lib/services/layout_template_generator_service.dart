import 'dart:convert';
import 'dart:io';

class LayoutTemplateGeneratorException implements IOException {
  const LayoutTemplateGeneratorException(this.message);

  final String message;

  @override
  String toString() => 'LayoutTemplateGeneratorException: $message';
}

class LayoutTemplateBundle {
  LayoutTemplateBundle({
    required this.screenTemplates,
    required this.cardTemplates,
    required this.listTemplates,
    required this.rowColumnTemplates,
    required this.spacingTemplates,
    required this.componentPlacementTemplates,
    required this.timestamp,
  });

  final Map<String, Object?> screenTemplates;
  final Map<String, Object?> cardTemplates;
  final Map<String, Object?> listTemplates;
  final Map<String, Object?> rowColumnTemplates;
  final Map<String, Object?> spacingTemplates;
  final Map<String, Object?> componentPlacementTemplates;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'screen_templates': screenTemplates,
    'card_templates': cardTemplates,
    'list_templates': listTemplates,
    'row_column_templates': rowColumnTemplates,
    'spacing_templates': spacingTemplates,
    'component_placement_templates': componentPlacementTemplates,
    'timestamp': timestamp.toIso8601String(),
  };
}

class LayoutTemplateGeneratorService {
  const LayoutTemplateGeneratorService();

  static const _inputPath = 'release/_reports/component_unification_map.json';

  Future<LayoutTemplateBundle> build() async {
    final data = await _loadAsciiJson(_inputPath);

    final canonical = _extractMap(data['canonical_components']);
    final consolidation = _extractMap(data['consolidation_rules']);
    final visual = _extractMap(data['visual_rules']);
    final layoutCleanup = consolidation['layout_cleanup'];
    final spacing = visual['spacing'] as Map<String, Object?>?;

    final screenTemplates = _buildScreenTemplates(canonical, consolidation);
    final cardTemplates = _buildCardTemplates(visual, consolidation);
    final listTemplates = _buildListTemplates(canonical);
    final rowColumnTemplates = _buildRowColumnTemplates(layoutCleanup);
    final spacingTemplates = _buildSpacingTemplates(spacing ?? {});
    final componentPlacementTemplates = _buildComponentPlacementTemplates(
      canonical,
    );

    return LayoutTemplateBundle(
      screenTemplates: screenTemplates,
      cardTemplates: cardTemplates,
      listTemplates: listTemplates,
      rowColumnTemplates: rowColumnTemplates,
      spacingTemplates: spacingTemplates,
      componentPlacementTemplates: componentPlacementTemplates,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw LayoutTemplateGeneratorException('Missing map $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw LayoutTemplateGeneratorException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw LayoutTemplateGeneratorException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  Map<String, Object?> _extractMap(Object? value) {
    if (value is Map<String, Object?>) return value;
    return const {};
  }

  Map<String, Object?> _buildScreenTemplates(
    Map<String, Object?> canonical,
    Map<String, Object?> consolidation,
  ) {
    final wrappers =
        (consolidation['merged_wrappers'] as List?) ?? ['SafeArea'];
    final wrapper = wrappers.isNotEmpty ? wrappers.first : 'SafeArea';
    final paddingVariants =
        (consolidation['padding_normalization'] as List?) ?? ['16'];
    final screenPadding = paddingVariants.isNotEmpty
        ? paddingVariants.first
        : '16';
    return {
      'primary': {
        'wrapper': wrapper,
        'padding': screenPadding,
        'safe_area': canonical['navigation'] ?? 'AppBar',
      },
    };
  }

  Map<String, Object?> _buildCardTemplates(
    Map<String, Object?> visual,
    Map<String, Object?> consolidation,
  ) {
    final shadows = (visual['shadows'] as Map<String, Object?>?)?['elevations'];
    final radii = (visual['radii'] as Map<String, Object?>?)?['primary_radii'];
    final spacingScale =
        (visual['spacing'] as Map<String, Object?>?)?['suggested_scale'];
    return {
      'default': {
        'padding': spacingScale is List && spacingScale.isNotEmpty
            ? spacingScale.first
            : 12.0,
        'radius': radii is List && radii.isNotEmpty ? radii.first : '8',
        'shadow': shadows is List && shadows.isNotEmpty
            ? shadows
            : ['medium', 'low'],
      },
    };
  }

  Map<String, Object?> _buildListTemplates(Map<String, Object?> canonical) {
    return {
      'primary': {
        'tile': canonical['lists'] ?? 'ListTile',
        'divider': true,
        'dense': true,
      },
      'collection': {
        'container': canonical['cards'] ?? 'Card',
        'tile': canonical['lists'] ?? 'ListTile',
      },
    };
  }

  Map<String, Object?> _buildRowColumnTemplates(Object? rowLayout) {
    final layoutMap = rowLayout is Map<String, Object?> ? rowLayout : {};
    return {
      'row': {'max_nested_depth': 2, 'preferred_alignment': 'start'},
      'column': {
        'max_nested_depth': 2,
        'margin_cleanup': layoutMap['anomalies'] ?? [],
      },
    };
  }

  Map<String, Object?> _buildSpacingTemplates(Map<String, Object?> spacing) {
    final scale = spacing['suggested_scale'];
    return {
      'normalized': scale ?? [8, 16, 24],
      'padding_variants': spacing['padding_variants'] ?? [],
    };
  }

  Map<String, Object?> _buildComponentPlacementTemplates(
    Map<String, Object?> canonical,
  ) {
    return {
      'navigation': {
        'primary': canonical['navigation'] ?? 'AppBar',
        'fallback': canonical['lists'] ?? 'ListView',
      },
      'buttons': {
        'primary': canonical['buttons'] ?? 'ElevatedButton',
        'secondary': canonical['inputs'] ?? 'TextField',
      },
    };
  }
}
