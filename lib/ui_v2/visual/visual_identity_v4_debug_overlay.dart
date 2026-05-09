import 'package:flutter/widgets.dart'
    show StatelessWidget, Widget, Text, Positioned, Key, BuildContext;

class VisualIdentityV4DebugOverlay extends StatelessWidget {
  const VisualIdentityV4DebugOverlay({
    Key? key,
    required this.kernelStatus,
    required this.tokenStatus,
    required this.binderStatus,
  }) : super(key: key);

  final String kernelStatus;
  final String tokenStatus;
  final String binderStatus;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 32,
      left: 8,
      child: Text(
        'V4 kernel=$kernelStatus; tokens=$tokenStatus; binder=$binderStatus',
      ),
    );
  }
}
