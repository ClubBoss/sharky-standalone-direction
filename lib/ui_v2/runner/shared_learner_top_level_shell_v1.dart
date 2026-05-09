import 'package:flutter/material.dart';

class SharedLearnerTopLevelShellContractV1 {
  const SharedLearnerTopLevelShellContractV1({
    required this.backgroundColor,
    this.appBar,
    this.wrapBodyInSafeArea = true,
    this.safeAreaBottom = false,
    this.resizeToAvoidBottomInset = true,
  });

  final Color backgroundColor;
  final PreferredSizeWidget? appBar;
  final bool wrapBodyInSafeArea;
  final bool safeAreaBottom;
  final bool resizeToAvoidBottomInset;
}

class SharedLearnerTopLevelShellV1 extends StatelessWidget {
  const SharedLearnerTopLevelShellV1({
    super.key,
    required this.contract,
    required this.child,
  });

  final SharedLearnerTopLevelShellContractV1 contract;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final body = contract.wrapBodyInSafeArea
        ? SafeArea(bottom: contract.safeAreaBottom, child: child)
        : child;

    return Scaffold(
      backgroundColor: contract.backgroundColor,
      appBar: contract.appBar,
      resizeToAvoidBottomInset: contract.resizeToAvoidBottomInset,
      body: body,
    );
  }
}
