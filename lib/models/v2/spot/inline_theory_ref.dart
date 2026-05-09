import 'package:meta/meta.dart';

@immutable
class InlineTheoryRef {
  const InlineTheoryRef({
    required this.id,
    this.anchor,
    this.section,
    this.url,
  });

  factory InlineTheoryRef.fromJson(Map<String, Object?> json) =>
      InlineTheoryRef(
        id: json['id']?.toString() ?? '',
        anchor: json['anchor']?.toString(),
        section: json['section']?.toString(),
        url: json['url']?.toString(),
      );

  final String id;
  final String? anchor;
  final String? section;
  final String? url;

  Map<String, Object?> toJson() => {
    'id': id,
    if (anchor != null) 'anchor': anchor,
    if (section != null) 'section': section,
    if (url != null) 'url': url,
  };
}
