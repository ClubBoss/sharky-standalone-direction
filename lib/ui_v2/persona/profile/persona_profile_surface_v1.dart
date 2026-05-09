import 'package:flutter/material.dart';

import '../../components_v3/panel_v3.dart';

class PersonaProfileSurfaceV1 extends StatelessWidget {
  const PersonaProfileSurfaceV1({
    super.key,
    required this.personaName,
    required this.staticTraits,
    required this.aiInsights,
    this.readOnly = true,
  });

  final String personaName;
  final Map<String, Object> staticTraits;
  final Map<String, Object> aiInsights;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle =
        theme.textTheme.titleLarge ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
    final labelStyle =
        theme.textTheme.labelLarge ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
    final bodyStyle =
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
    final insightStyle =
        (theme.textTheme.bodySmall ??
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w400))
            .copyWith(fontFamily: 'monospace');
    final traitWidgets = _buildTraitWidgets(labelStyle, bodyStyle);
    final insightsText = _buildInsightText();

    return Stack(
      children: [
        Positioned.fill(child: PanelV3()),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(personaName, style: titleStyle),
              const SizedBox(height: 12),
              if (traitWidgets.isNotEmpty) ...[
                const Text('Traits', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                ...traitWidgets,
              ] else ...[
                Text('traits pending', style: labelStyle),
              ],
              const SizedBox(height: 18),
              Text('Insights', style: labelStyle),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  insightsText.isEmpty ? 'insights pending' : insightsText,
                  style: insightStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTraitWidgets(TextStyle keyStyle, TextStyle valueStyle) {
    final widgets = <Widget>[];
    for (final entry in staticTraits.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: Text(entry.key, style: keyStyle)),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(entry.value.toString(), style: valueStyle),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  String _buildInsightText() {
    if (aiInsights.isEmpty) return '';
    final buffer = StringBuffer();
    for (final entry in aiInsights.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }
    return buffer.toString().trimRight();
  }
}
