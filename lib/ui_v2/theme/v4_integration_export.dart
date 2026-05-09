class V4IntegrationExport {
  const V4IntegrationExport();

  static Map<String, Object?> export(Map<String, Object?> normalizedChannel) {
    return {
      "channel": normalizedChannel,
      "keys": normalizedChannel.keys.toList(),
      "meta": {"count": normalizedChannel.length},
    };
  }
}
