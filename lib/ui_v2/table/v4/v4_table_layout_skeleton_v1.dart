import 'package:flutter/widgets.dart';

class V4TableLayoutSkeletonV1 extends StatelessWidget {
  const V4TableLayoutSkeletonV1({super.key, required this.visualTokenAccessor});

  final Object visualTokenAccessor;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  Map<String, String> asReadOnlyMap() => {
    'accessor': visualTokenAccessor.toString(),
  };
}
