class V4IdentityValidationMapper {
  const V4IdentityValidationMapper();

  Map<String, String> mapToLedger(Map<String, dynamic>? source) {
    if (source == null) return {};
    final out = <String, String>{};
    source.forEach((k, v) {
      out[k] = v.toString();
    });
    return out;
  }
}
