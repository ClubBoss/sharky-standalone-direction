class V4CardLayoutHarnessV1 {
  const V4CardLayoutHarnessV1({
    required this.cardGeometryDescriptor,
    required this.vectorCardEngine,
    required this.visualTokenAccessor,
  });

  final Object cardGeometryDescriptor;
  final Object vectorCardEngine;
  final Object visualTokenAccessor;

  Map<String, String> asReadOnlyMap() => {
    'geometry': cardGeometryDescriptor.toString(),
    'engine': vectorCardEngine.toString(),
    'accessor': visualTokenAccessor.toString(),
  };
}
