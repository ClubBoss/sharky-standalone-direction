class ContentPackIndexV2 {
  final Map<String, Object> data;

  const ContentPackIndexV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({required List<String> packIds}) {
    return <String, Object>{
      'content_pack_index_v2': <String, Object>{
        'packs': packIds,
        'metadata': 'placeholder_content_pack_index_v2',
      },
    };
  }
}
