class ContentPersonalizationBridgeV1 {
  final Map<String, Object> data;

  const ContentPersonalizationBridgeV1(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({required Map<String, Object> tierD}) {
    return <String, Object>{
      'content_personalization_bridge_v1': <String, Object>{
        'tier_d': tierD,
        'metadata': 'placeholder_content_personalization_bridge_v1',
      },
    };
  }
}
