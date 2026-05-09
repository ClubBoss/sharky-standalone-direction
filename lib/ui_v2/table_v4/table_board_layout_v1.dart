/// Passive adaptive table board layout generator (Phi-40).
class TableBoardLayoutV1 {
  const TableBoardLayoutV1({
    required this.visualRoutingMap,
    required this.width,
    required this.height,
  });

  final Map<String, Object> visualRoutingMap;
  final double width;
  final double height;

  Map<String, Object> run() {
    final List<String> boardLayoutMissing = <String>[];
    if (width <= 0 || height <= 0) boardLayoutMissing.add('invalid_size');
    if (visualRoutingMap.isEmpty)
      boardLayoutMissing.add('visual_routing_missing');

    final double w = width;
    final double h = height;
    final double minSide = w < h ? w : h;

    final Map<String, Object> boardLayoutMap = <String, Object>{
      'board_rect': <String, double>{'x': 0.0, 'y': 0.0, 'w': w, 'h': h},
      'card_slot_a': <String, double>{'x': w * 0.38, 'y': h * 0.44},
      'card_slot_b': <String, double>{'x': w * 0.46, 'y': h * 0.44},
      'pot_slot': <String, double>{'x': w * 0.45, 'y': h * 0.36},
      'action_zone': <String, double>{
        'x': 0.0,
        'y': h * 0.72,
        'w': w,
        'h': h * 0.28,
      },
      'highlight_zone': <String, double>{
        'x': w * 0.33,
        'y': h * 0.30,
        'r': minSide * 0.12,
      },
    };

    final bool boardLayoutReady = boardLayoutMissing.isEmpty;

    return <String, Object>{
      'board_layout_missing': boardLayoutMissing,
      'board_layout_ready': boardLayoutReady,
      'board_layout_map': boardLayoutMap,
    };
  }
}
