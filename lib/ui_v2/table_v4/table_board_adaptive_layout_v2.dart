/// Passive table board adaptive layout V2 with static breakpoints (Phi-58.1).
class TableBoardAdaptiveLayoutV2 {
  const TableBoardAdaptiveLayoutV2(this.layoutV1Map);

  final Object layoutV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object layoutCandidate = layoutV1Map;
    final bool hasV1 = layoutCandidate is Map && layoutCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasV1) missing.add('layout_v1');
    final Map<String, Object> v1 = hasV1
        ? (layoutCandidate as Map)['board_adaptive_layout']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    if (v1.isEmpty) missing.add('board_adaptive_layout');
    Map<String, double> _rectFrom(Map<String, Object>? rect) {
      if (rect == null) return <String, double>{};
      double _d(String k) => rect[k] is num ? (rect[k] as num).toDouble() : 0.0;
      return <String, double>{
        'x': _d('x'),
        'y': _d('y'),
        'w': _d('w'),
        'h': _d('h'),
      };
    }

    Map<String, Object> _scaleRect(Map<String, Object> rect, double scale) {
      return <String, Object>{
        'x': (rect['x'] as num?)?.toDouble() ?? 0.0,
        'y': (rect['y'] as num?)?.toDouble() ?? 0.0,
        'w': ((rect['w'] as num?)?.toDouble() ?? 0.0) * scale,
        'h': ((rect['h'] as num?)?.toDouble() ?? 0.0) * scale,
      };
    }

    final Map<String, Object> centerRect = _rectFrom(
      v1['center_zone'] as Map<String, Object>?,
    );
    final Map<String, Object> cardSlots =
        v1['card_slots'] as Map<String, Object>? ?? <String, Object>{};
    final Map<String, Object> computedZones = <String, Object>{
      'center_zone': _scaleRect(centerRect, 1.0),
      'seat_zones': v1['seat_zones'] ?? <Object>[],
      'card_slots': <String, Object>{
        'p0': _scaleRect(
          (cardSlots['p0'] as Map<String, Object>? ?? <String, Object>{}),
          1.0,
        ),
        'p1': _scaleRect(
          (cardSlots['p1'] as Map<String, Object>? ?? <String, Object>{}),
          1.0,
        ),
      },
    };
    final double safePadding = v1['safe_padding'] is num
        ? (v1['safe_padding'] as num).toDouble()
        : 8.0;
    final Map<String, Object> breakpoints = <String, Object>{
      'compact': _scaleRect(centerRect, 0.9),
      'regular': _scaleRect(centerRect, 1.0),
      'expanded': _scaleRect(centerRect, 1.1),
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'board_adaptive_layout_v2': <String, Object>{
        'breakpoints': breakpoints,
        'computed_zones': computedZones,
        'safe_padding': <String, double>{
          'compact': safePadding * 0.9,
          'regular': safePadding,
          'expanded': safePadding * 1.1,
        },
      },
      'readiness': readiness,
      'missing': missing,
    };
  }
}
