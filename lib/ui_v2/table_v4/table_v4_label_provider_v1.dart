class TableV4LabelProviderV1 {
  const TableV4LabelProviderV1(
    this.tableStateMap,
    this.seatStateMap,
    this.potStateMap,
  );

  final Map<String, dynamic> tableStateMap;
  final Map<String, dynamic> seatStateMap;
  final Map<String, dynamic> potStateMap;

  Map<String, Object> asReadOnlyMap() {
    final String potLabel = _valueToString(
      potStateMap['amount'] ?? potStateMap['label'],
    );
    final List<String> seatLabels = _seatLabels();
    final String statusLabel = _valueToString(tableStateMap['status']);
    final bool ready =
        potLabel.isNotEmpty && statusLabel.isNotEmpty && seatLabels.isNotEmpty;
    return <String, Object>{
      'pot_label': potLabel,
      'seat_labels': seatLabels,
      'status_label': statusLabel,
      'provider_ready': ready,
    };
  }

  List<String> _seatLabels() {
    final List<String> keys = seatStateMap.keys.whereType<String>().toList()
      ..sort();
    final List<String> result = <String>[];
    for (final String key in keys) {
      final Object? entry = seatStateMap[key];
      final String label = _valueToString(entry);
      if (label.isNotEmpty) {
        result.add(label);
      }
    }
    return result;
  }

  static String _valueToString(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value is num) {
      return value.toString();
    }
    if (value is Map) {
      return _valueToString(value['label'] ?? value['text'] ?? value['title']);
    }
    return '';
  }
}
