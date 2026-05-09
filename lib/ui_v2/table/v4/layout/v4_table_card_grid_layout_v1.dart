import 'package:flutter/widgets.dart';

class V4TableCardGridLayoutV1 extends StatelessWidget {
  const V4TableCardGridLayoutV1({
    super.key,
    required this.cardLayoutHarness,
    required this.visualTokenAccessor,
  });

  final Object cardLayoutHarness;
  final Object visualTokenAccessor;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  Map<String, String> asReadOnlyMap() => {
    'harness': cardLayoutHarness.toString(),
    'accessor': visualTokenAccessor.toString(),
  };
}
