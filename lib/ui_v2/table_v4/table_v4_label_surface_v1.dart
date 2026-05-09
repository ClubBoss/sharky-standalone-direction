class TableV4LabelSurfaceV1 {
  const TableV4LabelSurfaceV1(this.seatData, this.potData, this.statusData);

  final Map<String, dynamic> seatData;
  final Map<String, dynamic> potData;
  final Map<String, dynamic> statusData;

  Map<String, Object> asReadOnlyMap() {
    final String potLabel = _stringFromMap(potData, <String>[
      'pot_label',
      'label',
      'text',
    ]);
    final List<String> seatLabels = _stringListFromMap(seatData, <String>[
      'seat_labels',
      'labels',
      'seats',
    ]);
    final String statusLabel = _stringFromMap(statusData, <String>[
      'status_label',
      'label',
      'text',
    ]);
    final bool ready =
        potLabel.isNotEmpty && seatLabels.isNotEmpty && statusLabel.isNotEmpty;
    return <String, Object>{
      'pot_label': potLabel,
      'seat_labels': seatLabels,
      'status_label': statusLabel,
      'surface_ready': ready,
    };
  }

  static String _stringFromMap(Map<String, dynamic> source, List<String> keys) {
    for (final String key in keys) {
      final Object? value = source[key];
      final String result = _valueToString(value);
      if (result.isNotEmpty) {
        return result;
      }
    }
    return '';
  }

  static List<String> _stringListFromMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final Object? value = source[key];
      final List<String> list = _valueToStringList(value);
      if (list.isNotEmpty) {
        return list;
      }
    }
    return <String>[];
  }

  static String _valueToString(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value is num) {
      return value.toString();
    }
    if (value is Map) {
      return _valueToString(value['text'] ?? value['label'] ?? value['title']);
    }
    return '';
  }

  static List<String> _valueToStringList(Object? value) {
    if (value is List) {
      return value
          .map(_valueToString)
          .where((entry) => entry.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String && value.isNotEmpty) {
      return <String>[value];
    }
    if (value is Map) {
      final List<String> entries = <String>[];
      final List<String> keys = value.keys.whereType<String>().toList()..sort();
      for (final String key in keys) {
        final String entry = _valueToString(value[key]);
        if (entry.isNotEmpty) {
          entries.add(entry);
        }
      }
      return entries;
    }
    return <String>[];
  }
}
