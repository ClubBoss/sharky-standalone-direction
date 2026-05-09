class V4IdentityActivationSupervisor {
  final Map<String, dynamic> activationContext;

  const V4IdentityActivationSupervisor({required this.activationContext});

  Map<String, dynamic> evaluate() {
    final handshake = activationContext['activationHandshake'];
    final allowed = handshake?['allowed'] == true;
    return {
      'systemReady': allowed,
      'reason': allowed
          ? 'activation handshake permits visual enablement'
          : 'activation handshake not satisfied',
    };
  }
}
