import 'package:flutter/painting.dart';

import 'persona_renderer_v3.dart';
import 'persona_snapshot_registry_v3.dart';

class PersonaSnapshotBinderV3 {
  PersonaSnapshotBinderV3();

  static const Map<String, double> _motionMap = {
    'motion.fade': 0.3,
    'motion.slide': 0.5,
    'motion.scale': 0.4,
    'motion.none': 0.0,
  };

  static const Map<String, double> _fusionMap = {
    'fusion.soft': 2.0,
    'fusion.medium': 4.0,
    'fusion.strong': 8.0,
    'fusion.none': 0.0,
  };

  String _currentStyle = '';
  String _surfaceToken = '';
  String _fusionToken = '';
  double _motionFactor = 1.0;
  double _elevationFactor = 0.0;
  PersonaRendererV3V4Style? _v4Style;

  void syncStyle(String style) {
    _currentStyle = style;
    final surfaceToken = _segment(3);
    final motionToken = _segment(4);
    final fusionToken = _segment(5);
    _surfaceToken = surfaceToken;
    _fusionToken = fusionToken;
    _motionFactor = _motionMap[motionToken] ?? 1.0;
    _elevationFactor = _fusionMap[fusionToken] ?? 0.0;
  }

  String _segment(int index) {
    final parts = _currentStyle.split('|');
    if (parts.length > index) return parts[index];
    return '';
  }

  Map<String, dynamic> buildSnapshot() {
    return {
      'surfaceToken': _surfaceToken,
      'motionFactor': _motionFactor,
      'elevationFactor': _elevationFactor,
      'fusionToken': _fusionToken,
      if (_v4Style != null) ..._v4SnapshotMetadata(_v4Style!),
    };
  }

  void attachV4Style(PersonaRendererV3V4Style style) {
    _v4Style = style;
  }

  Map<String, dynamic> _v4SnapshotMetadata(PersonaRendererV3V4Style style) {
    return {
      'variant': PersonaSnapshotRegistryV3.personaV4,
      'v4Tint': _describeColor(style.tint),
      'v4LabelSize': style.labelStyle.fontSize?.toStringAsFixed(2) ?? 'null',
      'v4LabelWeight':
          style.labelStyle.fontWeight?.toString() ?? 'FontWeight.normal',
      'v4LetterSpacing':
          style.labelStyle.letterSpacing?.toStringAsFixed(2) ?? 'null',
      if (style.iconTone != null) 'v4IconTone': _describeColor(style.iconTone!),
      if (style.v4SurfaceRadius != null)
        'v4SurfaceRadius': style.v4SurfaceRadius!.toStringAsFixed(2),
      if (style.v4SurfaceElevation != null)
        'v4SurfaceElevation': style.v4SurfaceElevation!.toStringAsFixed(2),
      if (style.v4SurfaceSpacing != null)
        'v4SurfaceSpacing': style.v4SurfaceSpacing!.toStringAsFixed(2),
    };
  }

  String _describeColor(Color color) {
    return '0x${color.toARGB32().toRadixString(16).padLeft(8, '0')}';
  }

  Map<String, String> compareSnapshot(Map<String, dynamic> baseline) {
    final snapshot = buildSnapshot();
    final results = <String, String>{};
    for (final key in [
      'surfaceToken',
      'motionFactor',
      'elevationFactor',
      'fusionToken',
    ]) {
      final value = snapshot[key];
      final baseValue = baseline[key];
      results[key] = value == baseValue ? 'OK' : 'DIFF';
    }
    return results;
  }

  String writeSnapshotReport(Map<String, String> diff) {
    final buffer = StringBuffer('Persona Snapshot Report');
    diff.forEach((key, status) {
      buffer.writeln();
      buffer.write('$key: $status');
    });
    return buffer.toString();
  }
}
