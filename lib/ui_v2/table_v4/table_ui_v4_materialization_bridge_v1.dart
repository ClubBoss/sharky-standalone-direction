/// Counter - Phi-58.0
///
/// Passive bridge for Table UI V4 materialization.
class TableUIV4MaterializationBridgeV1 {
  const TableUIV4MaterializationBridgeV1(
    this.themeV4Controller,
    this.activationSyncMap,
  );

  final Object themeV4Controller;
  final Object activationSyncMap;

  Map<String, Object?> asReadOnlyMap() {
    final dynamic controller = themeV4Controller;
    final bool v4Active = (controller as dynamic)?.isActive == true;
    final Object? tintToken = controller?.tintToken;
    final Object? surfaceToken = controller?.surfaceToken;
    final Object? spacingToken = controller?.spacingToken;
    return <String, Object?>{
      'v4_active': v4Active,
      'tint_token': tintToken,
      'surface_token': surfaceToken,
      'spacing_token': spacingToken,
    };
  }
}
