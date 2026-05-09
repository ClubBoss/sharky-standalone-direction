import 'package:flutter/material.dart';

/// Stateless palette builder for the QA overlay.
class TableV4QAOverlayPaletteV1 {
  const TableV4QAOverlayPaletteV1();

  static Map<String, Object> build() {
    return <String, Object>{
      'bg_color': Color.fromARGB(180, 0, 0, 0),
      'text_color': Colors.white,
      'line_color': Color.fromARGB(220, 255, 255, 255),
      'alpha': 0.90,
      'ready': true,
    };
  }
}
