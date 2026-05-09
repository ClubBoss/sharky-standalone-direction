class TokenLiftResolutionPackV1 {
  const TokenLiftResolutionPackV1(this._resolutionBlueprintV2);

  final Map<String, dynamic> _resolutionBlueprintV2;

  Map<String, dynamic> asReadOnlyMap() => <String, dynamic>{
    'resolution_v2': _resolutionBlueprintV2,
  };
}
