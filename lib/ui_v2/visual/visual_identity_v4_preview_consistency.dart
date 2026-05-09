class V4IdentityPreviewConsistency {
  final Map<String, dynamic> snapshot;
  const V4IdentityPreviewConsistency(this.snapshot);

  Map<String, String> evaluate() {
    final result = <String, String>{};

    if (snapshot['effectiveStyle']?['radius'] != null &&
        snapshot['previewEnforcement']?['radius'] != null) {
      result['radius'] = 'ok';
    } else {
      result['radius'] = 'missing';
    }

    if (snapshot['effectiveStyle']?['shadow'] != null &&
        snapshot['previewEnforcement']?['shadowBlur'] != null) {
      result['shadow'] = 'ok';
    } else {
      result['shadow'] = 'missing';
    }

    if (snapshot['effectiveStyle']?['contrast'] != null &&
        snapshot['previewEnforcement']?['contrast'] != null) {
      result['contrast'] = 'ok';
    } else {
      result['contrast'] = 'missing';
    }

    if (snapshot['effectiveStyle']?['colorStrength'] != null &&
        snapshot['previewEnforcement']?['colorStrength'] != null) {
      result['color'] = 'ok';
    } else {
      result['color'] = 'missing';
    }

    return result;
  }
}
