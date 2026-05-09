import 'package:flutter/material.dart';

import 'typography_v4_injector_v1.dart';

/// Lightweight V4 widget layer that renders the pot, seat, and status labels.
class TableViewV4WidgetLayerV1 extends StatelessWidget {
  const TableViewV4WidgetLayerV1({
    super.key,
    required this.v4LabelSurfaceMap,
    this.typographyInjectorMap = const <String, Object?>{},
    this.v4LabelProviderMap,
    this.v4SpacingMap = const <String, Object?>{},
  });

  final Map<String, Object> v4LabelSurfaceMap;
  final Map<String, Object?> typographyInjectorMap;
  final Map<String, Object>? v4LabelProviderMap;
  final Map<String, Object?> v4SpacingMap;

  @override
  Widget build(BuildContext context) {
    final String potText = _stringFromKeys(v4LabelSurfaceMap, <String>[
      'pot_label',
      'pot',
      'pot_text',
    ]);
    final List<String> seatTexts = _stringListFromKeys(
      v4LabelSurfaceMap,
      <String>['seat_labels', 'seats', 'seat_list'],
    );
    final String statusText = _stringFromKeys(v4LabelSurfaceMap, <String>[
      'status_label',
      'status',
      'timer_label',
    ]);

    final TextStyle potStyle = _resolveV4(
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
    final TextStyle seatStyle = _resolveV4(
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
    );
    final TextStyle statusStyle = _resolveV4(
      const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Colors.white60,
      ),
    );

    final Offset labelOffset = _resolveFinalOffset('label');
    return Padding(
      padding: EdgeInsets.only(left: labelOffset.dx, top: labelOffset.dy),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: _offsetInsets(_resolveFinalOffset('pot')),
            child: Text(potText, style: potStyle),
          ),
          if (seatTexts.isNotEmpty) const SizedBox(height: 4),
          for (final String seat in seatTexts)
            Padding(
              padding: _offsetInsets(_resolveFinalOffset('seat')),
              child: Text(
                seat,
                style: seatStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 6),
          Padding(
            padding: _offsetInsets(_resolveFinalOffset('status')),
            child: Text(statusText, style: statusStyle),
          ),
        ],
      ),
    );
  }

  TextStyle _resolveV4(TextStyle base) {
    if (!_isInjectorReady) {
      return base;
    }
    return TypographyV4InjectorV1.styleFromReadOnlyMap(
      typographyInjectorMap,
      base,
    );
  }

  bool get _isInjectorReady {
    if (typographyInjectorMap['readiness'] != true) {
      return false;
    }
    final Object? injectorBody =
        typographyInjectorMap['typography_v4_injector_v1'];
    if (injectorBody is! Map<String, Object?>) {
      return false;
    }
    return injectorBody['v4_active'] == true;
  }

  static String _stringFromKeys(
    Map<String, Object> source,
    List<String> candidates,
  ) {
    for (final String key in candidates) {
      final String value = _string(source[key]);
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static List<String> _stringListFromKeys(
    Map<String, Object> source,
    List<String> candidates,
  ) {
    for (final String key in candidates) {
      final List<String> list = _stringList(source[key]);
      if (list.isNotEmpty) {
        return list;
      }
    }
    return <String>[];
  }

  static String _string(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value is num) {
      return value.toString();
    }
    if (value is Map) {
      final String fallback = _string(
        value['text'] ?? value['label'] ?? value['title'],
      );
      if (fallback.isNotEmpty) {
        return fallback;
      }
      if (value['display'] is String &&
          (value['display'] as String).isNotEmpty) {
        return value['display'] as String;
      }
    }
    return '';
  }

  double _readSpacing(String key, double fallback) =>
      _toDouble(v4SpacingMap[key]) ?? fallback;

  double _clampLabelOffset(double value) => value.clamp(-24.0, 24.0);

  static List<String> _stringList(Object? value) {
    if (value is List) {
      final List<String> result = <String>[];
      for (final Object? entry in value) {
        final String text = _string(entry);
        if (text.isNotEmpty) {
          result.add(text);
        }
      }
      return result;
    }
    if (value is Map) {
      final List<String> result = <String>[];
      final List<String> keys = value.keys.whereType<String>().toList()..sort();
      for (final String key in keys) {
        final String text = _string(value[key]);
        if (text.isNotEmpty) {
          result.add(text);
        }
      }
      return result;
    }
    if (value is String && value.isNotEmpty) {
      return <String>[value];
    }
    return <String>[];
  }

  static double? _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Offset _resolveFinalOffset(String prefix) => Offset(
    _microClampOffset(_clampLabelOffset(_readSpacing('${prefix}_dx', 0))),
    _microClampOffset(_clampLabelOffset(_readSpacing('${prefix}_dy', 0))),
  );

  EdgeInsets _offsetInsets(Offset offset) =>
      EdgeInsets.only(left: offset.dx, top: offset.dy);

  double _microClampOffset(double value) => value.clamp(-2.0, 2.0);
}
