import 'package:flutter/widgets.dart';

import 'renderers/table_meta_renderer_v2.dart';

class TableUIFullAssemblyV1 extends StatelessWidget {
  final TableMetaRendererV2 meta;

  const TableUIFullAssemblyV1({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: meta,
        );
      },
    );
  }
}
