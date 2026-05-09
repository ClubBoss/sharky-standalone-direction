import 'package:flutter/foundation.dart';

class Phase1DebugLogCaptureV1 {
  Phase1DebugLogCaptureV1._();

  static final Phase1DebugLogCaptureV1 instance = Phase1DebugLogCaptureV1._();

  static const int _maxLines = 2000;
  final List<String> _lines = [];
  DebugPrintCallback? _original;

  bool get isEnabled => _original != null;

  List<String> get lines => List.unmodifiable(_lines);

  void clear() {
    _lines.clear();
  }

  void enableCapture() {
    if (isEnabled) return;
    assert(kDebugMode);
    _original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null && message.contains('PHASE1_')) {
        _lines.add(message);
        if (_lines.length > _maxLines) {
          _lines.removeRange(0, _lines.length - _maxLines);
        }
      }
      _original?.call(message ?? '', wrapWidth: wrapWidth);
    };
  }

  void disableCapture() {
    if (!isEnabled) return;
    debugPrint = _original!;
    _original = null;
  }
}
