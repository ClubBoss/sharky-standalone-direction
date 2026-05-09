/// Passive card layout geometry for Table V4 (Phi-41).
class CardLayoutV2 {
  const CardLayoutV2({
    required this.boardLayoutMap,
    this.cardAspectRatio = 1.5,
    this.cardScale = 1.0,
  });

  final Map<String, Object> boardLayoutMap;
  final double cardAspectRatio;
  final double cardScale;

  Map<String, Object> run() {
    final List<String> cardLayoutMissing = <String>[];
    if (boardLayoutMap.isEmpty) cardLayoutMissing.add('board_layout_map');
    final dynamic boardRect = boardLayoutMap['board_rect'];
    if (boardRect is! Map) cardLayoutMissing.add('board_rect');

    double _readDim(String key) {
      if (boardRect is Map && boardRect[key] is num) {
        return (boardRect[key] as num).toDouble();
      }
      return 0.0;
    }

    final double bw = _readDim('w');
    final double bh = _readDim('h');
    final double minSide = bw < bh ? bw : bh;
    final double cardW = minSide * 0.085 * cardScale;
    final double cardH = cardW * cardAspectRatio;

    double _readSlot(String slot, String axis) {
      final dynamic slotMap = boardLayoutMap[slot];
      if (slotMap is Map && slotMap[axis] is num) {
        return (slotMap[axis] as num).toDouble();
      }
      return 0.0;
    }

    final double slotAX = _readSlot('card_slot_a', 'x');
    final double slotAY = _readSlot('card_slot_a', 'y');
    final double slotBX = _readSlot('card_slot_b', 'x');
    final double slotBY = _readSlot('card_slot_b', 'y');

    final Map<String, Object> cardLayoutMap = <String, Object>{
      'card_w': cardW,
      'card_h': cardH,
      'card_slot_a_rect': <String, double>{
        'x': slotAX,
        'y': slotAY,
        'w': cardW,
        'h': cardH,
      },
      'card_slot_b_rect': <String, double>{
        'x': slotBX,
        'y': slotBY,
        'w': cardW,
        'h': cardH,
      },
      'card_safe_zone': <String, double>{
        'dx': cardW * 0.06,
        'dy': cardH * 0.06,
      },
    };

    final bool cardLayoutReady = cardLayoutMissing.isEmpty;

    return <String, Object>{
      'card_layout_missing': cardLayoutMissing,
      'card_layout_ready': cardLayoutReady,
      'card_layout_map': cardLayoutMap,
    };
  }
}
