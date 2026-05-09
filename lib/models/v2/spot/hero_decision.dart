import 'package:meta/meta.dart';

@immutable
class HeroDecision {
  const HeroDecision({
    this.action,
    this.size,
    this.notes,
    this.timestamp,
    this.options = const [],
    this.villainAction,
    this.street = 0,
    this.explanation,
  });

  factory HeroDecision.fromJson(Map<String, Object?> json) => HeroDecision(
    action: json['action']?.toString(),
    size: (json['size'] as num?)?.toDouble(),
    notes: json['notes']?.toString(),
    timestamp: _parseDate(json['timestamp']),
    options: _stringList(json['options']),
    villainAction: json['villainAction']?.toString(),
    street: (json['street'] as num?)?.toInt() ?? 0,
    explanation: json['explanation']?.toString(),
  );

  final String? action;
  final double? size;
  final String? notes;
  final DateTime? timestamp;
  final List<String> options;
  final String? villainAction;
  final int street;
  final String? explanation;

  Map<String, Object?> toJson() => {
    if (action != null) 'action': action,
    if (size != null) 'size': size,
    if (notes != null) 'notes': notes,
    if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    if (options.isNotEmpty) 'options': List<String>.from(options),
    if (villainAction != null) 'villainAction': villainAction,
    if (street != 0) 'street': street,
    if (explanation != null) 'explanation': explanation,
  };

  HeroDecision copyWith({
    String? action,
    double? size,
    String? notes,
    DateTime? timestamp,
    List<String>? options,
    String? villainAction,
    int? street,
    String? explanation,
  }) => HeroDecision(
    action: action ?? this.action,
    size: size ?? this.size,
    notes: notes ?? this.notes,
    timestamp: timestamp ?? this.timestamp,
    options: options ?? List<String>.from(this.options),
    villainAction: villainAction ?? this.villainAction,
    street: street ?? this.street,
    explanation: explanation ?? this.explanation,
  );
}

DateTime? _parseDate(Object? input) {
  final text = input?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return const [];
}
