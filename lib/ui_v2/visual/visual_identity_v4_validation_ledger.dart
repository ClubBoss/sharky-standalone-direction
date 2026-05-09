class V4IdentityValidationLedger {
  final Map<String, String> ledger = {};

  void setEntry(String key, String value) {
    ledger[key] = value;
  }

  Map<String, String> export() {
    return {'v4_identity_validation_ledger': 'ok', ...ledger};
  }
}
