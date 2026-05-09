/// Passive table board adaptive layout V1 (Phi-58.0).
class TableBoardAdaptiveLayoutV1 {
  const TableBoardAdaptiveLayoutV1(
    this.boardLayoutMap,
    this.cardLayoutMap,
    this.previewFakeHandMap,
  );

  final Object boardLayoutMap;
  final Object cardLayoutMap;
  final Object previewFakeHandMap;

  Map<String, Object> asReadOnlyMap() {
    final Object boardLayoutCandidate = boardLayoutMap;
    final Object cardLayoutCandidate = cardLayoutMap;
    final Object previewCandidate = previewFakeHandMap;
    final bool hasBoard =
        boardLayoutCandidate is Map && boardLayoutCandidate.isNotEmpty;
    final bool hasCard =
        cardLayoutCandidate is Map && cardLayoutCandidate.isNotEmpty;
    final bool hasPreview =
        previewCandidate is Map && previewCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasBoard) missing.add('board_layout_map');
    if (!hasCard) missing.add('card_layout_map');
    if (!hasPreview) missing.add('preview_fake_hand_map');
    final Map<String, Object> boardMap = hasBoard
        ? boardLayoutCandidate as Map<String, Object>
        : <String, Object>{};
    final Map<String, Object> cardMap = hasCard
        ? cardLayoutCandidate as Map<String, Object>
        : <String, Object>{};
    final Map<String, Object> previewMap = hasPreview
        ? (previewCandidate as Map)['fake_hand_preview']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};

    Map<String, Object> _cardSlot(String key, String fallbackKey) {
      if (previewMap[key] is Map) {
        final Map<String, Object> card = previewMap[key] as Map<String, Object>;
        if (card['layout_rect'] is Map) {
          return card['layout_rect'] as Map<String, Object>;
        }
      }
      if (cardMap[fallbackKey] is Map) {
        return cardMap[fallbackKey] as Map<String, Object>;
      }
      return <String, Object>{};
    }

    final Map<String, Object> centerZone =
        boardMap['board_rect'] is Map<String, Object>
        ? boardMap['board_rect'] as Map<String, Object>
        : <String, Object>{};
    final List<Object> seatZones = List<Object>.generate(
      9,
      (i) => <String, Object>{'seat': i},
      growable: false,
    );
    final double safePadding = boardMap['safe_padding'] is num
        ? (boardMap['safe_padding'] as num).toDouble()
        : 8.0;

    final Map<String, Object> boardAdaptiveLayout = <String, Object>{
      'center_zone': centerZone,
      'seat_zones': seatZones,
      'card_slots': <String, Object>{
        'p0': _cardSlot('card_1', 'card_slot_a_rect'),
        'p1': _cardSlot('card_2', 'card_slot_b_rect'),
      },
      'safe_padding': safePadding,
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'board_adaptive_layout': boardAdaptiveLayout,
      'readiness': readiness,
      'missing': missing,
    };
  }
}
