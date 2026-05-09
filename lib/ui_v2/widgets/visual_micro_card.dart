import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/ui_v2/widgets/section_header.dart';
import 'package:poker_analyzer/ui_v2/widgets/section_surface.dart';

/// A compact card that pairs a section header with a fixed-height diagram slot.
/// Φ-Series v2/Visual Cohesion freeze: keep this Surface/Header layer stable
/// and avoid expanding its responsibilities without stakeholder alignment.
class VisualMicroCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget diagram;
  final List<Widget> body;
  final EdgeInsetsGeometry padding;
  final double diagramHeight;

  const VisualMicroCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.diagram,
    this.body = const [],
    this.padding = const EdgeInsets.all(lessonSpacingMedium),
    this.diagramHeight = 96,
  });

  @override
  Widget build(BuildContext context) {
    return SectionSurface(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: lessonSpacingMedium),
          SizedBox(height: diagramHeight, child: diagram),
          if (body.isNotEmpty) ...[
            const SizedBox(height: lessonSpacingMedium),
            ...body,
          ],
        ],
      ),
    );
  }
}

Widget buildVisualMicroCardArrowDiagram(
  BuildContext context, {
  required String startLabel,
  required String endLabel,
}) {
  const arrowColor = Colors.white70;
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LessonNumericText(startLabel, style: LessonTypography.title(context)),
        const SizedBox(width: lessonSpacingSmall),
        const Icon(Icons.arrow_forward, size: 18, color: arrowColor),
        const SizedBox(width: lessonSpacingSmall),
        LessonNumericText(endLabel, style: LessonTypography.title(context)),
      ],
    ),
  );
}

Widget buildVisualMicroCardDryWetDiagram(BuildContext context) {
  return buildVisualMicroCardArrowDiagram(
    context,
    startLabel: 'Dry calls',
    endLabel: 'Wet calls',
  );
}
