import 'package:flutter/widgets.dart';

class V4TableRendererSkeletonV1 extends StatelessWidget {
  const V4TableRendererSkeletonV1({
    super.key,
    required this.cardGridLayout,
    required this.chipsPotModel,
    required this.visualTokenAccessor,
  });

  final Object cardGridLayout;
  final Object chipsPotModel;
  final Object visualTokenAccessor;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  Map<String, String> asReadOnlyMap() => {
    'grid': cardGridLayout.toString(),
    'chips_pot': chipsPotModel.toString(),
    'accessor': visualTokenAccessor.toString(),
  };
}
