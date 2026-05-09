class V4IdentityVisualEnablement {
  final Map<String, dynamic> activationSupervisor;
  final Map<String, dynamic> activationFlag;

  const V4IdentityVisualEnablement({
    required this.activationSupervisor,
    required this.activationFlag,
  });

  Map<String, dynamic> export() {
    final systemReady = activationSupervisor['systemReady'] == true;
    final flagEnabled = activationFlag['enabled'] == true;
    final allowed = systemReady && flagEnabled;
    return {
      'canApplyV4Visuals': allowed,
      'reason': allowed
          ? 'supervisor and flag permit V4 visuals'
          : 'supervisor or flag not satisfied',
    };
  }
}
