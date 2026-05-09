class V4IdentityActivationFlag {
  final bool enabled;

  const V4IdentityActivationFlag({required this.enabled});

  Map<String, dynamic> export() {
    return {'enabled': enabled};
  }
}
