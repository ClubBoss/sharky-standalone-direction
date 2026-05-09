class GLBPackDescriptorV1 {
  final String id;
  final String version;
  final String family;
  final int moduleCount;
  final Object metadata;

  const GLBPackDescriptorV1({
    required this.id,
    required this.version,
    required this.family,
    required this.moduleCount,
    required this.metadata,
  });

  Map<String, Object> asMap() => <String, Object>{
    'id': id,
    'version': version,
    'family': family,
    'module_count': moduleCount,
    'metadata': metadata,
  };
}
