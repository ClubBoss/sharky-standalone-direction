import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/table/table_surface.dart';

typedef World1ResolvePortraitTableHeightV1 =
    double Function(BoxConstraints tableConstraints, Size mediaSize);

class World1SurfacedTableSectionComposerInputV1 {
  const World1SurfacedTableSectionComposerInputV1({
    required this.fillsAvailableSpace,
    required this.tableKey,
    required this.blockTableInteractions,
    required this.tableBuilder,
    required this.resolvePortraitHeight,
  });

  final bool fillsAvailableSpace;
  final Key tableKey;
  final bool blockTableInteractions;
  final WidgetBuilder tableBuilder;
  final World1ResolvePortraitTableHeightV1 resolvePortraitHeight;
}

Widget buildWorld1SurfacedTableSectionV1(
  World1SurfacedTableSectionComposerInputV1 input,
) {
  return Flexible(
    fit: input.fillsAvailableSpace ? FlexFit.tight : FlexFit.loose,
    child: Builder(
      builder: (context) {
        final media = MediaQuery.of(context);
        final portrait = media.size.height > media.size.width;
        final tableViewport = KeyedSubtree(
          key: input.tableKey,
          child: portrait
              ? SizedBox.expand(child: input.tableBuilder(context))
              : TableSurface(child: input.tableBuilder(context)),
        );
        final tableViewportWithPrelude = IgnorePointer(
          ignoring: input.blockTableInteractions,
          child: tableViewport,
        );
        if (!portrait) {
          return tableViewportWithPrelude;
        }
        return LayoutBuilder(
          builder: (context, tableConstraints) {
            final resolvedHeight = input.resolvePortraitHeight(
              tableConstraints,
              media.size,
            );
            return SizedBox(
              width: double.infinity,
              height: resolvedHeight,
              child: tableViewportWithPrelude,
            );
          },
        );
      },
    ),
  );
}
