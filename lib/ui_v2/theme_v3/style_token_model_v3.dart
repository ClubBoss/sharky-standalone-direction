class StyleTokenModelV3 {
  final String surface;
  final String motion;
  final String fusion;

  const StyleTokenModelV3({
    required this.surface,
    required this.motion,
    required this.fusion,
  });

  static const StyleTokenModelV3 empty = StyleTokenModelV3(
    surface: '',
    motion: '',
    fusion: '',
  );

  @override
  String toString() => '';
}
