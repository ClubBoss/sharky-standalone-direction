import 'package:flutter/widgets.dart';

import 'typography_v4_injector_v1.dart';

/// Stateless widget layer for V4 action buttons (Phi-44.3).
class ActionButtonsV4WidgetLayerV1 extends StatelessWidget {
  const ActionButtonsV4WidgetLayerV1({
    super.key,
    required this.geometryMap,
    required this.paramsMap,
    required this.actionsMap,
    required this.touchHandlersMap,
    this.typographyInjectorMap = const <String, Object?>{},
    this.v4SpacingMap = const <String, Object?>{},
  });

  final Map<String, Object> geometryMap;
  final Map<String, Object> paramsMap;
  final Map<String, Object> actionsMap;
  final Map<String, Object> touchHandlersMap;
  final Map<String, Object?> typographyInjectorMap;
  final Map<String, Object?> v4SpacingMap;

  @override
  Widget build(BuildContext context) {
    final List<_ActionButtonSpec> specs = _resolveButtonSpecs();
    if (specs.isEmpty) {
      return const SizedBox.shrink();
    }

    final BorderRadius borderRadius = BorderRadius.all(
      Radius.circular(
        _readDouble(paramsMap, <String>['corner_radius', 'border_radius'], 12),
      ),
    );
    final Color backgroundColor = _readColor(
      _lookupParam(paramsMap, <String>[
        'background_color',
        'button_background_color',
      ]),
      const Color(0xFF223041),
    );
    final Color outlineColor = _readColor(
      _lookupParam(paramsMap, <String>['outline_color', 'border_color']),
      const Color(0xFF3A4E63),
    );
    final double outlineWidth = _readDouble(paramsMap, <String>[
      'outline_width',
      'border_width',
    ], 1);
    final Color textColor = _readColor(
      _lookupParam(paramsMap, <String>['text_color', 'label_color']),
      const Color(0xFFFFFFFF),
    );
    final double fontSize = _readDouble(paramsMap, <String>[
      'text_size',
      'font_size',
    ], 16);
    final double letterSpacing = _readDouble(paramsMap, <String>[
      'text_letter_spacing',
    ], 0);

    final TextStyle labelStyle = TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: letterSpacing,
      height: 1.0,
    );
    final TextStyle displayLabelStyle = _ensureContrastSafeStyle(
      _resolveLabelStyle(labelStyle),
    );

    final Offset buttonOffset = _buttonOffset();
    final List<Widget> children = <Widget>[
      for (final _ActionButtonSpec spec in specs)
        Positioned.fromRect(
          key: ValueKey<String>('action_button_${spec.id}'),
          rect: _offsetRect(spec.rect, buttonOffset),
          child: _buildButton(
            spec: spec,
            borderRadius: borderRadius,
            backgroundColor: backgroundColor,
            outlineColor: outlineColor,
            outlineWidth: outlineWidth,
            textStyle: displayLabelStyle,
          ),
        ),
    ];

    return Stack(children: children);
  }

  TextStyle _resolveLabelStyle(TextStyle base) =>
      TypographyV4InjectorV1.styleFromReadOnlyMap(typographyInjectorMap, base);

  TextStyle _ensureContrastSafeStyle(TextStyle style) {
    final Color? color = style.color;
    if (color == null) {
      return style;
    }
    final int clampedAlpha = (color.a.clamp(96, 255)).toInt();
    if (clampedAlpha == color.a) {
      return style;
    }
    return style.copyWith(color: color.withAlpha(clampedAlpha));
  }

  Rect _offsetRect(Rect rect, Offset offset) => rect.shift(offset);

  Offset _buttonOffset() => Offset(
    _microClampButtonOffset(_clampButtonOffset(_readSpacing('action_dx', 0))),
    _microClampButtonOffset(_clampButtonOffset(_readSpacing('action_dy', 0))),
  );

  double _readSpacing(String key, double fallback) =>
      _spacingValue(v4SpacingMap[key], fallback);

  double _clampButtonOffset(double value) => value.clamp(-40.0, 40.0);

  double _microClampButtonOffset(double value) => value.clamp(-2.0, 2.0);

  Widget _buildButton({
    required _ActionButtonSpec spec,
    required BorderRadius borderRadius,
    required Color backgroundColor,
    required Color outlineColor,
    required double outlineWidth,
    required TextStyle textStyle,
  }) {
    final VoidCallback? handler = _resolveHandler(spec.actionKey);
    final BoxDecoration decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      border: outlineWidth > 0 && outlineColor.a > 0
          ? Border.all(color: outlineColor, width: outlineWidth)
          : null,
    );

    return GestureDetector(
      key: ValueKey<String>('gesture_${spec.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: handler,
      child: Container(
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          spec.label,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<_ActionButtonSpec> _resolveButtonSpecs() {
    final List<Map<String, Object>> buttonEntries =
        _resolveGeometryButtonEntries();
    if (buttonEntries.isEmpty) {
      return <_ActionButtonSpec>[];
    }
    final Map<String, Map<String, Object>> actionIndex = _indexActions();

    final List<_ActionButtonSpec> specs = <_ActionButtonSpec>[];
    for (int i = 0; i < buttonEntries.length; i++) {
      final Map<String, Object> entry = buttonEntries[i];
      final Rect? rect = _rectFrom(entry['rect'] ?? entry);
      if (rect == null || rect.width <= 0 || rect.height <= 0) {
        continue;
      }
      final String entryId = _asciiKey(
        _stringFrom(
          entry['id'] ?? entry['key'] ?? entry['action_id'] ?? 'button_$i',
        ),
        fallback: 'button_$i',
      );
      final String actionKey = _asciiKey(
        _stringFrom(entry['action_id'] ?? entry['id'] ?? entryId),
        fallback: entryId,
      );
      final Map<String, Object>? actionData =
          actionIndex[actionKey] ?? actionIndex[entryId];
      final String label = _asciiLabel(
        _stringFrom(
          actionData?['label'] ??
              actionData?['text'] ??
              entry['label'] ??
              entry['text'] ??
              actionKey,
        ),
        actionKey.toUpperCase(),
      );
      specs.add(
        _ActionButtonSpec(
          id: entryId,
          actionKey: actionKey,
          label: label,
          rect: rect,
        ),
      );
    }
    return specs;
  }

  Map<String, Map<String, Object>> _indexActions() {
    final Map<String, Map<String, Object>> index =
        <String, Map<String, Object>>{};
    final Iterable<Map<String, Object>> entries = _collectActionEntries(
      actionsMap,
    );
    int fallbackIndex = 0;
    for (final Map<String, Object> entry in entries) {
      final String id = _asciiKey(
        _stringFrom(entry['id'] ?? entry['key'] ?? entry['action_id']),
        fallback: 'action_$fallbackIndex',
      );
      fallbackIndex += 1;
      index[id] = entry;
    }
    return index;
  }

  Iterable<Map<String, Object>> _collectActionEntries(Object? root) {
    final List<Map<String, Object>> result = <Map<String, Object>>[];
    final List<Object?> queue = <Object?>[root];
    final Set<Object?> visited = <Object?>{};
    while (queue.isNotEmpty) {
      final Object? current = queue.removeAt(0);
      if (current == null || visited.contains(current)) {
        continue;
      }
      visited.add(current);
      if (current is List) {
        result.addAll(_listOfMaps(current));
        for (final Object? item in current) {
          if (item is Map || item is List) {
            queue.add(item);
          }
        }
        continue;
      }
      if (current is Map) {
        for (final String key in <String>[
          'actions',
          'buttons',
          'entries',
          'items',
        ]) {
          final Object? candidate = current[key];
          result.addAll(_listOfMaps(candidate));
        }
        for (final Object? value in current.values) {
          if (value is Map || value is List) {
            queue.add(value);
          }
        }
      }
    }
    return result;
  }

  List<Map<String, Object>> _resolveGeometryButtonEntries() {
    final List<Object?> queue = <Object?>[geometryMap];
    final Set<Object?> visited = <Object?>{};
    while (queue.isNotEmpty) {
      final Object? current = queue.removeAt(0);
      if (current == null || visited.contains(current)) {
        continue;
      }
      visited.add(current);
      if (current is Map) {
        for (final String key in <String>[
          'button_slots',
          'buttons',
          'entries',
          'items',
          'layout',
        ]) {
          final List<Map<String, Object>> list = _listOfMaps(current[key]);
          if (list.isNotEmpty) {
            return list;
          }
        }
        for (final Object? value in current.values) {
          if (value is Map || value is List) {
            queue.add(value);
          }
        }
      } else if (current is List) {
        for (final Object? item in current) {
          if (item is Map || item is List) {
            queue.add(item);
          }
        }
      }
    }
    return <Map<String, Object>>[];
  }

  Rect? _rectFrom(Object? raw) {
    if (raw is Rect) {
      return raw;
    }
    if (raw is List && raw.length >= 4) {
      final double left = _toDouble(raw[0], 0);
      final double top = _toDouble(raw[1], 0);
      final double width = _toDouble(raw[2], 0);
      final double height = _toDouble(raw[3], 0);
      if (width <= 0 || height <= 0) {
        return null;
      }
      return Rect.fromLTWH(left, top, width, height);
    }
    final Map<String, Object> rectMap;
    if (raw is Map) {
      rectMap = raw['rect'] is Map ? _asMap(raw['rect']) : _asMap(raw);
    } else {
      rectMap = <String, Object>{};
    }
    if (rectMap.isEmpty) {
      return null;
    }
    final double left = _toDouble(
      rectMap['x'] ?? rectMap['left'] ?? rectMap['dx'],
      0,
    );
    final double top = _toDouble(
      rectMap['y'] ?? rectMap['top'] ?? rectMap['dy'],
      0,
    );
    double width = _toDouble(
      rectMap['w'] ?? rectMap['width'] ?? rectMap['dw'],
      -1,
    );
    double height = _toDouble(
      rectMap['h'] ?? rectMap['height'] ?? rectMap['dh'],
      -1,
    );
    final double right = _toDouble(rectMap['right'], double.nan);
    final double bottom = _toDouble(rectMap['bottom'], double.nan);
    if (width <= 0 && !right.isNaN) {
      width = right - left;
    }
    if (height <= 0 && !bottom.isNaN) {
      height = bottom - top;
    }
    if (width <= 0 || height <= 0) {
      return null;
    }
    return Rect.fromLTWH(left, top, width, height);
  }

  List<Map<String, Object>> _listOfMaps(Object? source) {
    if (source is List) {
      final List<Map<String, Object>> result = <Map<String, Object>>[];
      for (final Object? item in source) {
        final Map<String, Object> mapItem = _asMap(item);
        if (mapItem.isNotEmpty) {
          result.add(mapItem);
        }
      }
      return result;
    }
    if (source is Map) {
      final List<Map<String, Object>> result = <Map<String, Object>>[];
      for (final Object? value in source.values) {
        final Map<String, Object> mapItem = _asMap(value);
        if (mapItem.isNotEmpty) {
          result.add(mapItem);
        }
      }
      return result;
    }
    return <Map<String, Object>>[];
  }

  Map<String, Object> _asMap(Object? input) {
    if (input is Map) {
      final Map<String, Object> result = <String, Object>{};
      input.forEach((dynamic key, dynamic value) {
        if (key is String) {
          result[key] = value;
        }
      });
      return result;
    }
    return <String, Object>{};
  }

  Object? _lookupParam(Map<String, Object> source, List<String> keys) {
    for (final String key in keys) {
      if (source.containsKey(key)) {
        return source[key];
      }
    }
    return null;
  }

  double _readDouble(
    Map<String, Object> source,
    List<String> keys,
    double fallback,
  ) {
    for (final String key in keys) {
      if (source.containsKey(key)) {
        return _toDouble(source[key], fallback);
      }
    }
    return fallback;
  }

  static double _spacingValue(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  double _toDouble(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback;
  }

  Color _readColor(Object? input, Color fallback) {
    if (input is Color) {
      return input;
    }
    if (input is int) {
      return Color(input);
    }
    if (input is String) {
      final String value = input.trim();
      if (value.startsWith('#')) {
        final String hex = value.substring(1);
        if (hex.length == 6 || hex.length == 8) {
          final int parsed = int.parse(
            hex.length == 6 ? 'FF$hex' : hex,
            radix: 16,
          );
          return Color(parsed);
        }
      }
      final Color? named = _namedColor(value);
      if (named != null) {
        return named;
      }
    }
    return fallback;
  }

  Color? _namedColor(String name) {
    switch (name.toLowerCase()) {
      case 'black':
        return const Color(0xFF000000);
      case 'white':
        return const Color(0xFFFFFFFF);
      case 'red':
        return const Color(0xFFFF0000);
      case 'blue':
        return const Color(0xFF0000FF);
      case 'green':
        return const Color(0xFF00FF00);
      case 'yellow':
        return const Color(0xFFFFFF00);
      case 'orange':
        return const Color(0xFFFFA500);
      case 'purple':
        return const Color(0xFF800080);
      case 'teal':
        return const Color(0xFF008080);
      case 'gray':
      case 'grey':
        return const Color(0xFF888888);
      default:
        return null;
    }
  }

  String? _stringFrom(Object? value) {
    if (value is String) {
      return value;
    }
    if (value is num) {
      return value.toString();
    }
    return null;
  }

  String _asciiKey(String? value, {required String fallback}) {
    if (value == null || value.isEmpty) {
      return fallback;
    }
    final String ascii = value.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
    return ascii.isEmpty ? fallback : ascii;
  }

  String _asciiLabel(String? value, String fallback) {
    if (value == null || value.isEmpty) {
      return fallback;
    }
    final String ascii = value.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
    return ascii.isEmpty ? fallback : ascii;
  }

  VoidCallback? _resolveHandler(String actionKey) {
    if (actionKey.isEmpty) {
      return null;
    }
    final List<String> candidates = <String>[
      actionKey,
      actionKey.toLowerCase(),
      actionKey.toUpperCase(),
    ];
    for (final String candidate in candidates) {
      final VoidCallback? handler = _findHandler(touchHandlersMap, candidate);
      if (handler != null) {
        return handler;
      }
    }
    return null;
  }

  VoidCallback? _findHandler(Object? root, String key) {
    final List<Object?> queue = <Object?>[root];
    final Set<Object?> visited = <Object?>{};
    while (queue.isNotEmpty) {
      final Object? current = queue.removeAt(0);
      if (current == null || visited.contains(current)) {
        continue;
      }
      visited.add(current);
      if (current is Map) {
        final Object? value = current[key];
        if (value is VoidCallback) {
          return value;
        }
        for (final Object? next in current.values) {
          if (next is Map || next is List) {
            queue.add(next);
          }
        }
      } else if (current is List) {
        for (final Object? item in current) {
          if (item is Map || item is List) {
            queue.add(item);
          }
        }
      }
    }
    return null;
  }
}

class _ActionButtonSpec {
  const _ActionButtonSpec({
    required this.id,
    required this.actionKey,
    required this.label,
    required this.rect,
  });

  final String id;
  final String actionKey;
  final String label;
  final Rect rect;
}
