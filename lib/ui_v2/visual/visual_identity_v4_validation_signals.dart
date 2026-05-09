class V4IdentityValidationSignals {
  final Map<String, String> signals = {};

  void setSignal(String key, String value) {
    signals[key] = value;
  }

  Map<String, String> export() {
    return {'v4_identity_validation_signals': 'ok', ...signals};
  }
}
