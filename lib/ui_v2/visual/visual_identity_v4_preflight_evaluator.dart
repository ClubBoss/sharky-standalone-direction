class V4IdentityPreflightEvaluator {
  const V4IdentityPreflightEvaluator();

  Map<String, String> evaluate({Map<String, String>? preflightBundle}) {
    return {
      'v4_identity_preflight_evaluator': 'ok',
      if (preflightBundle != null) ...preflightBundle,
    };
  }
}
