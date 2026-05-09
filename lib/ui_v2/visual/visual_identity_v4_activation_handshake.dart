class V4IdentityActivationHandshake {
  final Map<String, dynamic> readinessGate;
  final Map<String, dynamic> activationFlag;

  const V4IdentityActivationHandshake({
    required this.readinessGate,
    required this.activationFlag,
  });

  Map<String, dynamic> export() {
    final gateReady = readinessGate['ready'] == true;
    final flagEnabled = activationFlag['enabled'] == true;
    final allowed = gateReady && flagEnabled;
    return {
      'allowed': allowed,
      'reason': allowed ? 'activation permitted' : 'gate or flag not satisfied',
    };
  }
}
