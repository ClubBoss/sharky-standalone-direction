class V4SnapshotRegistry {
  const V4SnapshotRegistry(this.baseline);

  final Map<String, String> baseline;

  static const Map<String, String> baselineValues = {
    'surface':
        'Color(alpha: 1.0000, red: 0.9961, green: 0.9686, blue: 1.0000, colorSpace: ColorSpace.sRGB)',
    'surfaceTint':
        'Color(alpha: 1.0000, red: 0.9961, green: 0.9686, blue: 1.0000, colorSpace: ColorSpace.sRGB)',
    'shadowColor':
        'Color(alpha: 0.1216, red: 0.0078, green: 0.0078, blue: 0.0078, colorSpace: ColorSpace.sRGB)',
    'elevCard': '2.0',
    'elevChip': '2.0',
    'iconColor':
        'Color(alpha: 1.0000, red: 0.0000, green: 0.0000, blue: 0.0000, colorSpace: ColorSpace.sRGB)',
  };
}
