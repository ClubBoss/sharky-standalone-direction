import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@immutable
class SpotMeta {
  const SpotMeta._(this._data);

  const SpotMeta.empty() : _data = const {};

  factory SpotMeta([Map<String, Object?>? data]) {
    if (data == null || data.isEmpty) {
      return const SpotMeta.empty();
    }
    return SpotMeta._(Map.unmodifiable(data));
  }

  factory SpotMeta.fromJson(Object? json) {
    if (json is Map) {
      return SpotMeta(
        json.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    return const SpotMeta.empty();
  }

  final Map<String, Object?> _data;

  Map<String, Object?> toJson() => Map<String, Object?>.from(_data);

  T? read<T>(String key) => _data[key] as T?;

  SpotMeta copyWith(Map<String, Object?> updates) {
    final merged = Map<String, Object?>.from(_data)..addAll(updates);
    return SpotMeta(merged);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotMeta &&
          const MapEquality<String, Object?>().equals(_data, other._data);

  @override
  int get hashCode => const MapEquality<String, Object?>().hash(_data);
}
