import 'package:flutter/material.dart';

import '../explainers/explanation_inline_binder_v4.dart';

class HelpInfoIconV4 extends StatelessWidget {
  const HelpInfoIconV4({
    super.key,
    this.componentId,
    required this.binder,
    required this.isV4Active,
  });

  final String? componentId;
  final ExplanationInlineBinderV4 binder;
  final bool isV4Active;

  @override
  Widget build(BuildContext context) {
    // STUBBED to fix build error
    return const SizedBox();
  }
}
