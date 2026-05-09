import 'package:flutter/material.dart';

class TapZonesV4WidgetLayerV1 extends StatelessWidget {
  const TapZonesV4WidgetLayerV1({
    Key? key,
    required this.geometryMap,
    required this.handlerMap,
    this.styleMap = const <String, Object>{},
  }) : super(key: key);

  final Map<String, Object> geometryMap;
  final Map<String, Object> handlerMap;
  final Map<String, Object> styleMap;

  @override
  Widget build(BuildContext context) {
    final List<String> zoneIds =
        geometryMap.keys.where((key) => geometryMap[key] is Map).toList()
          ..sort();
    if (zoneIds.isEmpty) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: zoneIds
          .map((zoneId) {
            final Rect rect = _readRect(geometryMap[zoneId]);
            if (rect.isEmpty) {
              return null;
            }
            final VoidCallback? handler = _toCallback(handlerMap[zoneId]);
            final double overlayOpacity = _readOpacity(styleMap[zoneId]);
            int overlayAlpha = (overlayOpacity * 255).round();
            if (overlayAlpha < 0) {
              overlayAlpha = 0;
            } else if (overlayAlpha > 255) {
              overlayAlpha = 255;
            }
            final Color overlayColor = overlayAlpha == 0
                ? Colors.transparent
                : Color.fromARGB(overlayAlpha, 0, 0, 0);
            return Positioned(
              left: rect.left,
              top: rect.top,
              width: rect.width,
              height: rect.height,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: handler,
                child: Container(color: overlayColor),
              ),
            );
          })
          .whereType<Widget>()
          .toList(),
    );
  }

  static Rect _readRect(Object? source) {
    if (source is Map<Object?, Object?>) {
      final double left = _toDouble(
        source['x'] ?? source['left'] ?? source['dx'],
        0.0,
      );
      final double top = _toDouble(
        source['y'] ?? source['top'] ?? source['dy'],
        0.0,
      );
      final double width = _toDouble(source['w'] ?? source['width'], 0.0);
      final double height = _toDouble(source['h'] ?? source['height'], 0.0);
      return Rect.fromLTWH(
        left,
        top,
        width < 0 ? 0 : width,
        height < 0 ? 0 : height,
      );
    }
    return Rect.zero;
  }

  static double _readOpacity(Object? spec) {
    if (spec is Map<Object?, Object?>) {
      final double rawOpacity = _toDouble(spec['opacity'], 0.0);
      return rawOpacity < 0 ? 0 : (rawOpacity > 1 ? 1 : rawOpacity);
    }
    return 0.0;
  }

  static double _toDouble(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static VoidCallback? _toCallback(Object? value) {
    if (value is VoidCallback) {
      return value;
    }
    return null;
  }
}
