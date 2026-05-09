import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

Widget buildSection(BuildContext context, Map<String, Object?> section) {
  final sectionId = (section['section_id'] as String?) ?? 'section';
  switch (sectionId) {
    case 'persona_overview':
      return buildSectionPersonaOverview(context, section);
    case 'training_focus':
      return buildSectionTrainingFocus(context, section);
    case 'explanations':
      return buildSectionExplanations(context, section);
    case 'localization':
      return buildSectionLocalization(context, section);
    default:
      return buildSectionFallback(context, section);
  }
}

Widget buildSectionPersonaOverview(
  BuildContext context,
  Map<String, Object?> section,
) {
  final nodes = _extractNodes(section);
  return _sectionContainer(
    context,
    'Persona Overview',
    nodes.map((node) => _buildNode(context, node)).toList(),
  );
}

Widget buildSectionTrainingFocus(
  BuildContext context,
  Map<String, Object?> section,
) {
  final nodes = _extractNodes(section);
  return _sectionContainer(
    context,
    'Training Focus',
    nodes.map((node) => _buildNode(context, node)).toList(),
  );
}

Widget buildSectionExplanations(
  BuildContext context,
  Map<String, Object?> section,
) {
  final nodes = _extractNodes(section);
  return _sectionContainer(
    context,
    'Insights',
    nodes.map((node) => _buildNode(context, node)).toList(),
  );
}

Widget buildSectionLocalization(
  BuildContext context,
  Map<String, Object?> section,
) {
  final nodes = _extractNodes(section);
  return _sectionContainer(
    context,
    'Localization Status',
    nodes.map((node) => _buildNode(context, node)).toList(),
  );
}

Widget buildSectionFallback(
  BuildContext context,
  Map<String, Object?> section,
) {
  final nodes = _extractNodes(section);
  return _sectionContainer(
    context,
    'Section',
    nodes.map((node) => _buildNode(context, node)).toList(),
  );
}

List<Map<String, Object?>> _extractNodes(Map<String, Object?> section) {
  final rawNodes = section['nodes'];
  if (rawNodes is! List<Object?>) {
    return const [];
  }
  return rawNodes.whereType<Map<String, Object?>>().toList();
}

Map<String, Object?> _ensureMap(Object? source) {
  if (source is Map<String, Object?>) {
    return source;
  }
  return const {};
}

Widget _sectionContainer(
  BuildContext context,
  String title,
  List<Widget> children,
) {
  final theme = Theme.of(context);
  final brand = theme.extension<BrandTheme>();
  final sectionPadding = brand?.spacingLarge ?? AppSpacing.lg;
  final radius = brand?.radius ?? AppSpacing.lg;
  final blur = brand?.elevationMed ?? 4.0;
  final content = children.isNotEmpty ? children : [_emptyPlaceholder(context)];
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow.withOpacity(0.3),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: EdgeInsets.all(sectionPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.heading(context, title),
        SizedBox(height: AppSpacing.sm),
        for (var index = 0; index < content.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == content.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: content[index],
          ),
      ],
    ),
  );
}

Widget _buildNode(BuildContext context, Map<String, Object?> node) {
  final component = ((node['component'] as String?) ?? '').toLowerCase();
  final props = _ensureMap(node['props']);
  final spacingToken = props['spacing'] is num
      ? (props['spacing'] as num).toDouble()
      : AppSpacing.sm;
  final radiusToken = props['radius'] is num
      ? (props['radius'] as num).toDouble()
      : AppSpacing.sm;
  switch (component) {
    case 'title':
    case 'heading':
      return AppText.heading(context, _nodeLabel(node));
    case 'body':
      return AppText.body(context, _nodeLabel(node));
    case 'card':
    case 'appcard':
      return AppCard(
        spacing: spacingToken,
        radius: radiusToken,
        color: AppColors.lightCard,
        shadowColor: AppColors.shadow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.heading(context, _nodeLabel(node)),
            SizedBox(height: AppSpacing.xs),
            AppText.body(context, 'Details view'),
          ],
        ),
      );
    case 'list-block':
    case 'list':
      return AppListBlock(
        title: _nodeLabel(node),
        entries: List.generate(3, (index) => 'Item ${index + 1}'),
        spacing: spacingToken,
      );
    default:
      return AppText.body(context, _nodeLabel(node));
  }
}

Widget _emptyPlaceholder(BuildContext context) {
  return Text(
    'No content available yet.',
    style: AppTypography.caption.copyWith(color: AppColors.textSecondaryDark),
  );
}

String _nodeLabel(Map<String, Object?> node) {
  final blockId = node['block_id'] as String? ?? 'block';
  final component = node['component'] as String? ?? 'component';
  return '$component ($blockId)';
}

class AppText {
  static Widget heading(BuildContext context, String value) {
    return Text(
      value,
      style: AppTypography.h1.copyWith(color: AppColors.textPrimaryDark),
    );
  }

  static Widget body(BuildContext context, String value) {
    return Text(
      value,
      style: AppTypography.body.copyWith(color: AppColors.textSecondaryDark),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.spacing = AppSpacing.sm,
    this.radius = AppSpacing.sm,
    this.color,
    this.shadowColor,
  });

  final Widget child;
  final double spacing;
  final double radius;
  final Color? color;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color ?? AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      surfaceTintColor: Colors.transparent,
      shadowColor: shadowColor ?? AppColors.shadow,
      child: Padding(padding: EdgeInsets.all(spacing), child: child),
    );
  }
}

class AppListBlock extends StatelessWidget {
  const AppListBlock({
    super.key,
    required this.title,
    required this.entries,
    this.spacing = AppSpacing.sm,
  });

  final String title;
  final List<String> entries;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.heading(context, title),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: AppText.body(context, entry),
                ),
                if (index < entries.length - 1)
                  Divider(color: AppColors.outlineSoft, height: AppSpacing.xs),
              ],
            );
          }),
        ],
      ),
    );
  }
}
