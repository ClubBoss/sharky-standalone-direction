import 'package:flutter/material.dart';

class TableV4PreviewScreenV1 extends StatefulWidget {
  static const routeName = '/table_preview';

  const TableV4PreviewScreenV1({super.key});

  @override
  State<TableV4PreviewScreenV1> createState() => _TableV4PreviewScreenV1State();
}

class _TableV4PreviewScreenV1State extends State<TableV4PreviewScreenV1> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Preview Screen Disabled for Build Stabilization.\n"
          "Please check console for other errors.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
