class V4AdaptivePersonaEntryPointV1 {
  const V4AdaptivePersonaEntryPointV1({
    required this.shellBinding,
    required this.surface,
    required this.facade,
  });

  final Object shellBinding;
  final Object surface;
  final Object facade;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'shell': shellBinding.toString(),
    'surface': surface.toString(),
    'facade': facade.toString(),
  });
}
